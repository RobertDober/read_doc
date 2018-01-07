defmodule ReadDoc.Message do
  defstruct message: "",
            lnb: 0,
            severity: :warning

  def warning(message, lnb), do: %__MODULE__{message: message, lnb: lnb}
end
