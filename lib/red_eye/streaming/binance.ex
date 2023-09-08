defmodule RedEye.Streaming.Binance do
  @moduledoc """
  Handles connecting to Binances unauthed websocket endpoint for streaming all their market data
  for candles mostly.

  Not the same as an authed connection that could execute a trade etc.
  """

  use GenServer

  require Logger
  require Mint.HTTP

  alias RedEye.MarketData.Ticker
  alias RedEye.MarketData.BinanceSpotCandle

  defstruct [:conn, :websocket, :request_ref, :caller, :status, :resp_headers, :closing?]

  @url "wss://stream.binance.com:443/stream"

  def subscribe(list, id) when is_list(list) and is_integer(id) do
    %{"method" => "SUBSCRIBE", "params" => list, "id" => id}
    |> send_message()
  end

  def unsubscribe(list, id) when is_list(list) and is_integer(id) do
    %{"method" => "UNSUBSCRIBE", "params" => list, "id" => id}
    |> send_message()
  end

  def send_message(map) when is_map(map) do
    send_message(Jason.encode!(map))
  end

  def send_message(text) do
    GenServer.call(__MODULE__, {:send_text, text})
  end

  @spec die! :: true
  def die! do
    Process.whereis(__MODULE__)
    |> Process.exit(:kill)
  end

  def status do
    case Process.whereis(__MODULE__) do
      pid when is_pid(pid) ->
        {:ok, %{pid: pid, state: :sys.get_state(pid)}}

      _ ->
        :error
    end
  end

  def start_link(args \\ []) do
    with {:ok, socket} <- GenServer.start_link(__MODULE__, args, name: __MODULE__),
         {:ok, :connected} <- GenServer.call(socket, {:connect, @url}) do
      # RedEye.Streaming.Watcher.auto_subscribe()
      {:ok, socket}
    end
  end

  @impl GenServer
  def init([]) do
    {:ok, %__MODULE__{}}
  end

  def close_connection do
    GenServer.cast(__MODULE__, :close)
  end

  @impl GenServer
  def handle_cast(:close, state) do
    do_close(state)
  end

  @impl GenServer
  def handle_call({:send_text, text}, _from, state) do
    {:ok, state} = send_frame(state, {:text, text})
    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_call({:connect, url}, from, state) do
    uri = URI.parse(url)

    http_scheme =
      case uri.scheme do
        "ws" -> :http
        "wss" -> :https
      end

    ws_scheme =
      case uri.scheme do
        "ws" -> :ws
        "wss" -> :wss
      end

    path =
      case uri.query do
        nil -> uri.path
        query -> uri.path <> "?" <> query
      end

    with {:ok, conn} <- Mint.HTTP.connect(http_scheme, uri.host, uri.port, protocols: [:http1]),
         {:ok, conn, ref} <- Mint.WebSocket.upgrade(ws_scheme, conn, path, []) do
      state = %{state | conn: conn, request_ref: ref, caller: from}
      {:noreply, state}
    else
      {:error, reason} ->
        {:reply, {:error, reason}, state}

      {:error, conn, reason} ->
        {:reply, {:error, reason}, put_in(state.conn, conn)}
    end
  end

  @impl GenServer
  def handle_info(message, state) do
    case Mint.WebSocket.stream(state.conn, message) do
      {:ok, conn, responses} ->
        state = put_in(state.conn, conn) |> handle_responses(responses)
        if state.closing?, do: do_close(state), else: {:noreply, state}

      {:error, conn, reason, _responses} ->
        state = put_in(state.conn, conn) |> reply({:error, reason})
        {:noreply, state}

      :unknown ->
        {:noreply, state}
    end
  end

  defp handle_responses(state, responses)

  defp handle_responses(%{request_ref: ref} = state, [{:status, ref, status} | rest]) do
    put_in(state.status, status)
    |> handle_responses(rest)
  end

  defp handle_responses(%{request_ref: ref} = state, [{:headers, ref, resp_headers} | rest]) do
    put_in(state.resp_headers, resp_headers)
    |> handle_responses(rest)
  end

  defp handle_responses(%{request_ref: ref} = state, [{:done, ref} | rest]) do
    case Mint.WebSocket.new(state.conn, ref, state.status, state.resp_headers) do
      {:ok, conn, websocket} ->
        %{state | conn: conn, websocket: websocket, status: nil, resp_headers: nil}
        |> reply({:ok, :connected})
        |> handle_responses(rest)

      {:error, conn, reason} ->
        put_in(state.conn, conn)
        |> reply({:error, reason})
    end
  end

  defp handle_responses(%{request_ref: ref, websocket: websocket} = state, [
         {:data, ref, data} | rest
       ])
       when websocket != nil do
    case Mint.WebSocket.decode(websocket, data) do
      {:ok, websocket, frames} ->
        put_in(state.websocket, websocket)
        |> handle_frames(frames)
        |> handle_responses(rest)

      {:error, websocket, reason} ->
        put_in(state.websocket, websocket)
        |> reply({:error, reason})
    end
  end

  defp handle_responses(state, [_response | rest]) do
    handle_responses(state, rest)
  end

  defp handle_responses(state, []), do: state

  defp send_frame(state, frame) do
    with {:ok, websocket, data} <- Mint.WebSocket.encode(state.websocket, frame),
         state = put_in(state.websocket, websocket),
         {:ok, conn} <- Mint.WebSocket.stream_request_body(state.conn, state.request_ref, data) do
      {:ok, put_in(state.conn, conn)}
    else
      {:error, %Mint.WebSocket{} = websocket, reason} ->
        {:error, put_in(state.websocket, websocket), reason}

      {:error, conn, reason} ->
        {:error, put_in(state.conn, conn), reason}
    end
  end

  def handle_frames(state, frames) do
    Enum.reduce(frames, state, fn
      # reply to pings with pongs
      {:ping, data}, state ->
        {:ok, state} = send_frame(state, {:pong, data})
        state

      {:close, _code, reason}, state ->
        Logger.debug("Closing connection: #{inspect(reason)}")
        %{state | closing?: true}

      {:text, text}, state ->
        Logger.debug("Received: #{inspect(text)}")
        Logger.debug("State: #{inspect(state)}")

        case Jason.decode(text) do
          {:ok, msg} -> handle_msg(msg)
          {:error, _} -> Logger.error("Unable to parse JSON: #{text}")
        end

        state

      frame, state ->
        Logger.debug("Unexpected frame received: #{inspect(frame)}")
        state
    end)
  end

  def handle_msg(%{
        "data" => %{
          "e" => "24hrTicker",
          "s" => symbol,
          "p" => price_change,
          "P" => price_change_percent,
          "c" => last_price
        }
      }) do
    Ticker.new(
      symbol: symbol,
      price_change: price_change,
      price_change_percent: price_change_percent,
      last_price: last_price
    )
    |> stash()
    |> broadcast(:ticker)
  end

  def handle_msg(%{
        "data" => %{
          "e" => "kline",
          "k" => %{
            "t" => kline_open_time,
            "T" => kline_close_time,
            "i" => interval,
            "Q" => taker_buy_base_asset_volume,
            "V" => taker_buy_quote_asset_volume,
            "o" => open,
            "c" => close,
            "h" => high,
            "l" => low,
            "n" => number_of_trades,
            "q" => quote_asset_volume,
            "v" => volume,
            "x" => kline_closed
          },
          "s" => symbol
        }
      }) do
    %BinanceSpotCandle{
      symbol: symbol,
      kline_open_time: kline_open_time,
      kline_close_time: kline_close_time,
      interval: interval,
      taker_buy_base_asset_volume: taker_buy_base_asset_volume,
      taker_buy_quote_asset_volume: taker_buy_quote_asset_volume,
      open: open,
      close: close,
      high: high,
      low: low,
      number_of_trades: number_of_trades,
      quote_asset_volume: quote_asset_volume,
      volume: volume,
      kline_closed: kline_closed,
      unix_time: kline_open_time
    }
    |> broadcast(:kline)
  end

  def handle_msg(msg) do
    Logger.info("Incoming msg ***: #{inspect(msg)}")
  end

  defp stash(%Ticker{symbol: symbol} = ticker) do
    RedEye.MarketData.Bucket.put(:symbols, symbol, ticker)
    ticker
  end

  defp do_close(state) do
    # Streaming a close frame may fail if the server has already closed
    # for writing.
    _ = send_frame(state, :close)
    Mint.HTTP.close(state.conn)
    {:stop, :normal, state}
  end

  defp reply(state, response) do
    if state.caller, do: GenServer.reply(state.caller, response)
    put_in(state.caller, nil)
  end

  defp broadcast(data, event) do
    Phoenix.PubSub.broadcast(
      RedEye.PubSub,
      "charts",
      {event, data}
    )
  end
end
