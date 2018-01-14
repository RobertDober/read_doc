defmodule ReadDoc.StateMachine.Result do
  use ReadDoc.Types

  alias ReadDoc.Message
  import ReadDoc.Pair, only: [first: 1]

  import ReadDoc.Enum, only: [map_reverse: 2]

  defstruct lines: [],
            messages: []
  
  @type t :: %__MODULE__{lines: list(numbered_line), messages: Message.ts}
  @type result_tuple :: {list(String.t), Message.ts}

  @spec add_lines( t, list_or_unit(String.t)) :: t
  def add_lines(result, lines) when is_binary(lines) do
    add_lines(result, String.split(lines, "\n"))
  end
  def add_lines(result, lines) do
    lines
    |> Enum.reduce(result, fn line, r -> add_line(r, line) end)
  end

  @spec add_line( t, String.t ) :: t
  def add_line(result, line) do
    %{result | lines: [{line, next_lnb(result)}|result.lines]}
  end

  @spec add_numbered_line( t, numbered_line() ) :: t
  def add_numbered_line(result, {line, _}) do
    add_line(result, line)
  end

  @spec add_numbered_line_unless( t, numbered_line(), boolean() ) :: t
  def add_numbered_line_unless( result, {line, _}, false ) do
    add_line(result, line)
  end
  def add_numbered_line_unless( result, {line, _}, true ) do
    result
  end


  @spec add_message( t, Message.t ) :: t
  def add_message(result=%{messages: messages}, message), do: %{result | messages: [message | messages]}

  @spec add_warning( t, String.t ) :: t
  def add_warning(result, message), do: add_warning(result, message, next_lnb(result))
  @spec add_warning( t, String.t, number ) :: t
  def add_warning(result, message, lnb), do: add_message(result, Message.warning(message, lnb))

  @spec finalize( t ) :: result_tuple()
  def finalize(%{messages: messages, lines: lines}) do
    { lines |> map_reverse(&first/1), messages }
  end

  @spec next_lnb( t ) :: number
  def next_lnb(%{lines: []}), do: 1
  def next_lnb(%{lines: [{_, lnb}|_]}), do: lnb + 1
end
