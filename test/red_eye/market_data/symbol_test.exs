defmodule RedEye.MarketData.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = RedEye.MarketData.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert RedEye.MarketData.Bucket.get(bucket, "BTCUSDT") == nil

    RedEye.MarketData.Bucket.put(bucket, "BTCUSDT", 3)
    assert RedEye.MarketData.Bucket.get(bucket, "BTCUSDT") == 3
  end

  test "lists all values", %{bucket: bucket} do
    assert RedEye.MarketData.Bucket.get(bucket, "BTCUSDT") == nil

    RedEye.MarketData.Bucket.put(bucket, "BTCUSDT", 3)
    assert RedEye.MarketData.Bucket.list(bucket) == %{"BTCUSDT" => 3}
  end
end
