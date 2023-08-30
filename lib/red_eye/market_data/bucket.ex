defmodule RedEye.MarketData.Bucket do
  use Agent

  @doc """
  Starts a new bucket.
  """
  def start_link(args) do
    Agent.start_link(fn -> %{} end, args)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  def get(bucket, key, struct) when is_struct(struct) do
    Agent.get(bucket, &Map.get(&1, key, struct))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Returns the contents of the bucket as a map
  """
  @spec list(atom | pid | {atom, any} | {:via, atom, any}) :: map()
  def list(bucket) do
    Agent.get(bucket, fn state -> state end)
  end

  @doc """
  Override default child_spec for Agent so we can have multiple instances the bucket
  with different ids.
  """
  def child_spec(name) do
    %{id: name, start: {__MODULE__, :start_link, [name]}}
  end
end
