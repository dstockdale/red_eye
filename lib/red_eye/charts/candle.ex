defmodule RedEye.Charts.Candle do
  @moduledoc """
  Candle struct
  """
  defstruct [:time, :high, :low, :open, :close]

  defimpl Jason.Encoder, for: RedEye.Charts.Candle do
    @impl Jason.Encoder
    def encode(value, opts) do
      {time, rest} = Map.pop(value, :time)

      rest
      |> Map.from_struct()
      |> Map.new(fn {k, v} -> {k, Decimal.to_float(v)} end)
      |> Map.put(:time, time)
      |> Jason.Encode.map(opts)
    end
  end

  @spec list_candles(map()) :: list
  def list_candles(list_of_maps) do
    list_of_maps
    |> Enum.map(fn item ->
      struct(__MODULE__, item)
    end)
  end
end
