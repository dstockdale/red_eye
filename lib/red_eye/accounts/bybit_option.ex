defmodule RedEye.Accounts.BybitOption do
  defstruct recv_window: 5000,
            api_key: "0enjWC7Acu2UtW7m1p",
            secret_key: "0oWwRT577SjhiGjpJjQ8wZlh2iBdxDIBg91w",
            timestamp: 0

  def new(opts \\ %__MODULE__{}) do
    %__MODULE__{opts | timestamp: timestamp()}
  end

  def timestamp do
    DateTime.utc_now()
    |> DateTime.to_unix(:millisecond)
  end
end
