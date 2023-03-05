defmodule RedEye.Streams do
  alias RedEye.MarketData.BinanceStream

  # def active_chart_subscriptions do
  #   chart_symbols = RedEye.MarketData.find_binance_candle_symbols()
  # end

  @spec get_binance_subscriptions ::
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
  def get_binance_subscriptions do
    client = binance_stream()
    msg_id = id()

    msg = %{method: "LIST_SUBSCRIPTIONS", id: msg_id}

    BinanceStream.send_frame(client, msg)
  end

  defp binance_stream, do: Process.whereis(:binance_stream)

  defp id, do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
