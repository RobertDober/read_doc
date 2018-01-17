defmodule ReadDoc.Types do
  defmacro __using__( _options \\ [] ) do
    quote do
      @type list_or_unit(t) :: t | list(t)

      @type maybe(t) :: nil | t

      @type numbered_line :: { String.t, number }
      @type numbered_lines :: list(numbered_line)

      @type pair(lhs, rhs) :: {lhs, rhs}

      @type rgx_run_result :: nil | list(String.t) | list(pair(integer(), integer()))

      @type string? :: maybe(String.t)

    end
  end
end
