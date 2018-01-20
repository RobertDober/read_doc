defmodule ReadDoc.Message do
  defstruct message: "",
            lnb: 0,
            severity: :warning

  @type severity_type :: :warning
  @type t :: %__MODULE__{message: String.t(), lnb: number, severity: severity_type}
  @type ts :: list(t)

  @spec warning(String.t(), number) :: t
  def warning(message, lnb), do: %__MODULE__{message: message, lnb: lnb}

  @spec emit_messages(ts, String.t()) :: :ok
  def emit_messages(messages, file) do
    messages
    |> Enum.sort(fn %{lnb: l}, %{lnb: r} -> l <= r end)
    |> Enum.each(&emit_message(&1, file))
  end

  @spec emit_message(t, String.t()) :: :ok
  defp emit_message(%{message: message, lnb: lnb}, file) do
    IO.puts(:stderr, "#{file}:#{lnb} #{message}")
  end
end
