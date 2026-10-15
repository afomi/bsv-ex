defmodule BSV.EntropyError do
  @moduledoc "Raised when a configured entropy provider cannot produce valid output."
  defexception [:reason]

  @impl true
  def exception(reason),
    do: %__MODULE__{reason: reason}

  @impl true
  def message(%__MODULE__{reason: reason}),
    do: "Entropy provider failed: #{inspect(reason)}"
end
