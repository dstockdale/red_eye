defmodule RedEye.Accounts.BybitReq do
  @moduledoc """
  The API code ot fetch the latest account info from ByBit
  """
  @base_url "https://api.bybit.com"

  alias RedEye.Accounts.BybitOption

  def base_url do
    Req.new(base_url: @base_url)
  end

  def fetch_account_info do
    opts = BybitOption.new()

    query_str = ""
    signature = gen_signature(query_str, opts)

    headers = %{
      "X-BAPI-API-KEY" => opts.api_key,
      "X-BAPI-TIMESTAMP" => opts.timestamp,
      "X-BAPI-RECV-WINDOW" => opts.recv_window,
      "X-BAPI-SIGN" => signature
    }

    Req.get(base_url(),
      url: "/v5/account/info",
      headers: headers
    )
  end

  def fetch_transaction_log do
    opts = BybitOption.new()

    query_str = ""
    # %{"accountType" => "UNIFIED", "currency" => "USDT", "timestamp" => opts.timestamp}
    # |> URI.encode_query()

    signature = gen_signature(query_str, opts)

    headers = %{
      "X-BAPI-API-KEY" => opts.api_key,
      "X-BAPI-TIMESTAMP" => Integer.to_string(opts.timestamp),
      "X-BAPI-RECV-WINDOW" => opts.recv_window,
      "X-BAPI-SIGN" => signature,
      "X-BAPI-SIGN-TYPE" => "2",
      "content-type" => "application/json"
    }

    Req.get(base_url(),
      url: "/v5/account/transaction-log?#{query_str}",
      headers: headers
    )
  end

  defp gen_signature(payload, opts) do
    string = "#{opts.timestamp}#{opts.api_key}#{opts.recv_window}#{payload}"

    :crypto.mac(:hmac, :sha256, opts.api_key, string)
    |> Base.encode16()
  end
end
