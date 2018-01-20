defmodule ReadDoc.StateMachine do
  use ReadDoc.Types

  alias ReadDoc.Options

  alias ReadDoc.Message
  alias ReadDoc.StateMachine.Result
  alias ReadDoc.StateMachine.State

  import ReadDoc.DocExtractor, only: [extract_doc: 1]

  @type result_t() :: Result.result_tuple()

  @spec run!( list(String.t), Options.t, String.t ) :: list(String.t)
  def run!(lines, options, file) do
    with {output, messages} <- run(lines, options) do
      if !options.silent do
        Message.emit_messages(messages, file)
      end
      output
    end
  end

  @spec run( list(String.t), Options.t ) :: result_t()
  def run(lines, options) do
    lines
      |> Stream.zip(Stream.iterate(1, &(&1 + 1)))
      |> Enum.to_list()
      |> state_machine(%Result{}, %State{options: options})
  end

  @spec state_machine( numbered_lines(), Result.t, State.t ) :: result_t()
  defp state_machine([], result, state), do: _state_machine([], result, state)
  defp state_machine(lines =[_l|_], result, state) do
    # IO.inspect({state.opendoc[:for], l})
    _state_machine(lines, result, state)
  end


  @copy_state %{state: :copy}
  @spec _state_machine( numbered_lines(), Result.t, State.t ) :: result_t()
  defp _state_machine(lines, result, state)
  defp _state_machine([], result, @copy_state), do: Result.finalize( result )
  defp _state_machine([], result, state) do
    result_prime =
      Result.add_warning(result, "end @doc for #{State.format_opendoc(state)} missing", State.opened_at(state))
    case extract_doc(State.current_open(state)) do
      nil -> Result.add_warning(result_prime, "end @doc missing for #{State.format_opendoc(state)}")
      doc -> Result.add_lines(result_prime, doc)
    end
    |> Result.finalize()
  end
  defp _state_machine([line|rest], result, state = @copy_state) do
    case begin_doc_match(line, state) do 
      nil          -> substate_inside_copy(line, rest, result, state)
      [_, opendoc] -> state_machine( rest,
                                     Result.add_numbered_line(result, line),
                                     State.open(state, opendoc, result) )
    end
  end
  defp _state_machine([line|rest], result, state=%{state: :remove_old, opendoc: %{for: opendoc}}) do
    case end_doc_match(line, state) do
      nil                -> substate_inside_remove(line, rest, result, state)
      [_, ^opendoc]      -> substate_replace_doc(line, rest, result, state)
      [_, opendoc_prime] -> substate_ignore_illegal_close(rest, opendoc_prime, result, state)
    end
  end

  @spec substate_ignore_illegal_close( numbered_lines(), String.t, Result.t, State.t ) :: result_t
  defp substate_ignore_illegal_close(rest, opendoc_prime, result, state) do 
    result_prime =
      Result.add_warning(result, "ignoring end @doc of #{State.format_opendoc(opendoc_prime, Result.next_lnb(result))} as we are inside a @doc block for #{State.format_opendoc state}")
    state_machine(rest, result_prime, state)
  end

  @spec substate_ignore_illegal_open( numbered_line(), numbered_lines(), String.t, Result.t, State.t ) :: result_t()
  defp substate_ignore_illegal_open(line, rest, opendoc_prime, result, state) do 
    result_prime =
      Result.add_warning(result, "ignoring begin @doc of #{State.format_opendoc(opendoc_prime, Result.next_lnb(result))} as we are inside a @doc block for #{State.format_opendoc state}")
    state_machine(rest, Result.add_numbered_line(result_prime, line), state)
  end

  # CHECK
  @spec substate_illegal_close_in_copy( numbered_line(), numbered_lines(), String.t, Result.t, State.t ) :: result_t()
  defp substate_illegal_close_in_copy(line, rest, closedoc, result, state=%{options: %{fix_errors: fix_errors}}) do 
    result_prime =
      Result.add_warning(result, "ignoring end @doc of #{State.format_opendoc(closedoc, Result.next_lnb(result))} as we are not inside a @doc block" )
    state_machine(rest, Result.add_numbered_line_unless(result_prime, line, fix_errors), state)
  end

  # CHECK
  @spec substate_inside_copy( numbered_line(), numbered_lines(), Result.t, State.t ) :: result_t()
  defp substate_inside_copy(line, rest, result, state) do 
    case end_doc_match(line, state) do 
      nil           -> state_machine(rest, Result.add_numbered_line(result, line), state)
      [_, closedoc] -> substate_illegal_close_in_copy(line, rest, closedoc, result, state)
    end
  end

  @spec substate_inside_remove( numbered_line(), numbered_lines(), Result.t, State.t ) :: result_t()
  defp substate_inside_remove(line, rest, result, state) do 
    case begin_doc_match(line, state) do 
      nil                -> state_machine(rest, result, state)
      [_, opendoc_prime] -> substate_ignore_illegal_open(line, rest, opendoc_prime, result, state)
    end
  end

  @spec substate_replace_doc( numbered_line(), numbered_lines(), Result.t, State.t ) :: result_t()
  defp substate_replace_doc(line, rest, result, state=%{opendoc: %{for: for}}) do 
    copy_state = %{state | state: :copy}
    case extract_doc(for) do
      nil -> state_machine( rest,
               Result.add_warning(result, "doc not found for #{State.format_opendoc(state)}")
               |> Result.add_numbered_line(line), copy_state)
      doc -> state_machine(rest, add_docs_with_line(result, doc, line), copy_state)
    end
  end

  # ------------------------------------
  # Helpers
  # ------------------------------------

  @spec add_docs_with_line( Result.t, String.t, numbered_line() ) :: Result.t
  defp add_docs_with_line(result, docs, line) do
    result
    |> Result.add_lines(docs)
    |> Result.add_numbered_line(line)
  end

  # CHECK
  @spec begin_doc_match( numbered_line(), State.t ) :: rgx_run_result
  defp begin_doc_match({line, _}, state) do
    Regex.run( state.options.begin_rgx, line )
  end

  # CHECK
  @spec end_doc_match( numbered_line(), State.t ) :: rgx_run_result
  defp end_doc_match({line, _}, state) do
    Regex.run state.options.end_rgx, line
  end

end
