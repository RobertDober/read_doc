defmodule ReadDoc.StateMachine.State do
  use ReadDoc.Types

  alias ReadDoc.Options
  alias ReadDoc.StateMachine.Result

  defstruct state: :copy,
            opendoc: %{for: nil, line_nb: 0},
            options: %Options{}

  @type state_t :: :copy | :remove_old
  @type opendoc_t :: %{for: maybe(String.t()), line_nb: number}
  @type t :: %__MODULE__{state: state_t, opendoc: opendoc_t, options: Options.t()}

  @spec open(t, String.t(), Result.t()) :: t
  def open(state, opendoc, result),
    do: %{state | state: :remove_old, opendoc: %{for: opendoc, line_nb: Result.next_lnb(result)}}

  @spec opened_at(t) :: number
  def opened_at(%{opendoc: %{for: nil}}), do: 0
  def opened_at(%{opendoc: %{line_nb: line_nb}}), do: line_nb

  @spec current_open(t) :: maybe(String.t())
  def current_open(%{opendoc: %{for: for}}), do: for

  @spec format_opendoc(String.t(), number) :: String.t()
  def format_opendoc(for, line_nb), do: "#{for} (opened in line #{line_nb})"

  def format_opendoc(state) do
    format_opendoc(state.opendoc.for, state.opendoc.line_nb)
  end
end
