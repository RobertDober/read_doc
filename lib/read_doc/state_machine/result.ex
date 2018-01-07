defmodule ReadDoc.StateMachine.Result do

  alias ReadDoc.Message
  import ReadDoc.Pair, only: [first: 1]

  import ReadDoc.Enum, only: [map_reverse: 2]

  defstruct lines: [],
            messages: []
  
  def add_lines(result, lines) when is_binary(lines) do
    lines
    |> String.split("\n")
    |> add_lines(result)
  end
  def add_lines(result, lines) do
    lines
    |> Enum.each(&add_line(result, &1))
  end

  def add_line(result, line), do: %{result | lines: [{line, next_lnb(result)}|result.lines]}

  def add_message(result=%{messages: messages}, message), do: %{result | messages: [message | messages]}

  def add_warning(result, message, lnb), do: add_message(result, Message.warning(message, lnb))

  def finalize(%{messages: messages, lines: lines}) do
    { lines |> map_reverse(&first/1), messages }
  end

  def next_lnb(%{lines: []}), do: 1
  def next_lnb(%{lines: [{_, lnb}|_]}), do: lnb + 1
end
