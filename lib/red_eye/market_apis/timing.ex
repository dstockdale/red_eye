defmodule RedEye.MarketApis.Timing do
  @doc """
  Given a date in the past this will return a list of unix timestamps (in milliseconds)
  for feeding to things like the Binance API when you need to loop though many start times
  to get backfill data for instance.
  """
  @spec date_range(Date.t()) :: list
  def date_range(date) do
    dt1 = DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
    unix_start = DateTime.to_unix(dt1)

    Enum.to_list(0..diff_in_mins(dt1))
    |> Enum.chunk_every(1000)
    |> Enum.with_index()
    |> Enum.map(fn {_item, i} ->
      (i * 60_000 + unix_start) * 1_000
    end)
  end

  defp diff_in_mins(dt1) do
    dt2 = DateTime.utc_now()
    DateTime.diff(dt2, dt1, :minute)
  end
end
