defmodule RedEye.Charts.ChartQueriesTest do
  use ExUnit.Case, async: true

  alias RedEye.Charts.ChartQueries
  alias Postgrex.Interval

  test "parse_interval returns correct Postgrex.Interval" do
    assert ChartQueries.parse_interval("1m") == %Interval{
             months: 0,
             days: 0,
             secs: 60,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("1 hour") == %Interval{
             months: 0,
             days: 0,
             secs: 3600,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("1h") == %Interval{
             months: 0,
             days: 0,
             secs: 3600,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("1 day") == %Interval{
             months: 0,
             days: 1,
             secs: 0,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("1d") == %Interval{
             months: 0,
             days: 1,
             secs: 0,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("1 week") == %Interval{
             months: 0,
             days: 7,
             secs: 0,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("3w") == %Interval{
             months: 0,
             days: 21,
             secs: 0,
             microsecs: 0
           }

    assert ChartQueries.parse_interval("1M") == %Interval{
             months: 1,
             days: 0,
             secs: 0,
             microsecs: 0
           }
  end
end
