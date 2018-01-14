defmodule ReadDoc.Message do
  defstruct message: "",
            lnb: 0,
            severity: :warning

  @type severity_type :: :warning
  @type t :: %__MODULE__{message: String.t, lnb: number, severity: severity_type}
  @type ts :: list(t)

  @spec warning( String.t, number ) :: t
  def warning(message, lnb), do: %__MODULE__{message: message, lnb: lnb}

  @spec emit_message( t ) :: :ok
  def emit_message(%{message: message, lnb: lnb}) do
    IO.puts :stderr, "#{lnb}: #{message}"
  end
end
