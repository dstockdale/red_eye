defmodule RedEyeWeb.ChartJSON do
  @doc """
  Renders a list of symbol.
  """
  def index(%{chart: charts}) do
    Jason.encode!(charts)
  end
end
