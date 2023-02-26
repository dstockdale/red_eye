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

  def handle_frame({type, msg}, state) do
    IO.puts("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")
    {:ok, state}
  end

  # def handle_frame({type, msg}, state) do
  #   IO.inspect(type)

  #   case Jason.decode(msg) do
  #     {:ok, event} -> process_event(event)
  #     {:error, _} -> Logger.error("Unable to parse msg: #{msg}")
  #   end

  #   {:ok, state}
  # end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  # defp process_event(event) do
  #   IO.inspect(event)
  # end

  def handle_disconnect(%{reason: {:local, reason}}, state) do
    Logger.info("Local close with reason: #{inspect(reason)}")
    {:ok, state}
  end

  def handle_disconnect(disconnect_map, state) do
    super(disconnect_map, state)
  end
end
