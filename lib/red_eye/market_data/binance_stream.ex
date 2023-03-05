defmodule RedEye.MarketData.BinanceStream do
  require Logger
  use WebSockex

  @stream_endpoint "wss://stream.binance.com:443/ws/btcusdt@ticker"

  def start_link(opts \\ []) do
    WebSockex.start_link(@stream_endpoint, __MODULE__, [], opts)
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected!")
    {:ok, state}
  end

  def handle_ping({:ping, msg}, state) do
    Logger.info("Ping frame received replying with Pong")
    Logger.info(IO.inspect(msg))

    {:reply, {:pong, msg}, state}
  end

  @doc """
  This is the primitive for sending messages to the binance websocket server, used for things
  like subscribing and unsubscribing to stuff like klines and trades.

  This thing is always expecting a map of config stuff which it will turn into JSON

  send_frame(pid, frame)
  """
  @spec send_frame(atom | pid | {:global, any} | {:via, atom, any}, any) ::
          :ok
          | {:error,
             %{
               :__exception__ => true,
               :__struct__ =>
                 WebSockex.ConnError
                 | WebSockex.FrameEncodeError
                 | WebSockex.InvalidFrameError
                 | WebSockex.NotConnectedError,
               optional(:close_code) => any,
               optional(:connection_state) => any,
               optional(:frame) => any,
               optional(:frame_payload) => any,
               optional(:frame_type) => any,
               optional(:original) => any,
               optional(:reason) => any
             }}
  def send_frame(client, frame) do
    frame =
      frame
      |> Jason.encode!()

    Logger.info("Sending message: #{IO.inspect(frame)}")

    WebSockex.send_frame(client, {:text, frame})
  end

  def handle_frame({:text, msg}, state) do
    case Jason.decode(msg) do
      {:ok, event} -> handle_event(event)
      {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
    end

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  @doc """
    {
      "e": "24hrTicker",  // Event type
      "E": 1672515782136, // Event time
      "s": "BNBBTC",      // Symbol
      "p": "0.0015",      // Price change
      "P": "250.00",      // Price change percent
      "w": "0.0018",      // Weighted average price
      "x": "0.0009",      // First trade(F)-1 price (first trade before the 24hr rolling window)
      "c": "0.0025",      // Last price
      "Q": "10",          // Last quantity
      "b": "0.0024",      // Best bid price
      "B": "10",          // Best bid quantity
      "a": "0.0026",      // Best ask price
      "A": "100",         // Best ask quantity
      "o": "0.0010",      // Open price
      "h": "0.0025",      // High price
      "l": "0.0010",      // Low price
      "v": "10000",       // Total traded base asset volume
      "q": "18",          // Total traded quote asset volume
      "O": 0,             // Statistics open time
      "C": 86400000,      // Statistics close time
      "F": 0,             // First trade ID
      "L": 18150,         // Last trade Id
      "n": 18151          // Total number of trades
    }

  """
  def handle_event(%{
        "e" => "24hrTicker",
        "s" => symbol,
        "p" => price_change,
        "P" => price_change_percent,
        "c" => last_price
      }) do
    %{
      "type" => "24hrTicker",
      symbol => %{
        price_change: price_change,
        price_change_percent: price_change_percent,
        last_price: last_price
      }
    }
    |> broadcast(:ticker)
  end

  def handle_event(event) do
    Logger.info("Incoming event: #{inspect(event)}")
  end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    Logger.info("Disconnected: #{inspect(disconnect_map)}")
    Logger.info("Disconnected state: #{inspect(state)}")
    super(disconnect_map, state)
  end

  defp broadcast(event, type) do
    Phoenix.PubSub.broadcast(
      RedEye.PubSub,
      "charts",
      {event, type}
    )
  end
end
