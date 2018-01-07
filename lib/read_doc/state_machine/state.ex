defmodule ReadDoc.StateMachine.State do

  alias ReadDoc.Options
  
  defstruct state: :copy,
            opendoc: %{for: nil, line_nb: 0},
            options: %Options{}


  def open(state, opendoc, result), do:
    %{state | state: :remove_old, opendoc: %{for: opendoc, line_nb: Result.next_lnb(result)}}

  def opened_at(%{opendoc: %{for: nil}}), do: 0
  def opened_at(%{opendoc: %{line_nb: line_nb}}), do: line_nb

  def current_open(%{opendoc: %{for: for}}), do: for

  def format_opendoc(for, line_nb), do:
    "#{for} (opened in line #{line_nb})"
  defp format_opendoc(state) do 
    format_opendoc(state.opendoc.for, state.opendoc.line_nb)
  end

end
