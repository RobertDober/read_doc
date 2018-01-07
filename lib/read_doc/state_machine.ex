defmodule ReadDoc.StateMachine do
  alias ReadDoc.Options

  alias ReadDoc.Message
  alias ReadDoc.StateMachine.Result
  alias ReadDoc.StateMachine.State

  import ReadDoc.DocExtractor, only: [extract_doc: 1]


  def run!(lines, options) do
    with {output, messages} <- run(lines, options) do
      messages
        |> Enum.each(&Message.emit_message/1)
      output
    end
  end

  def run(lines, options) do
    lines
      |> Stream.zip(Stream.iterate(1, &(&1 + 1)))
      |> Enum.to_list()
      |> state_machine(%Result{}, %State{options: options})
  end

  @copy_state %{state: :copy}
  @doc false
  defp state_machine(lines, result, state)
  defp state_machine([], result, @copy_state), do: Result.finalize( result )
  defp state_machine([], result, state) do
    result_prime =
      Result.add_warning(result, "end @doc for #{State.format_opendoc(state)} missing", State.opened_at(state))
    case extract_doc(State.current_open(state)) do
      nil -> Result.add_warning(result_prime, "end @doc missing for #{State.format_opendoc(state)}")
      doc -> Result.add_lines(result_prime, doc)
    end
    |> Result.finalize()
  end
  defp state_machine([line|rest], result, state = @copy_state) do
    case begin_doc_match(line, state) do 
      nil          -> substate_inside_copy(line, rest, result, state)
      [_, opendoc] -> state_machine( rest,
                                     Result.add_line(result, line),
                                     State.open(state, opendoc, result) )
    end
  end
  # C1
  defp state_machine([line|rest], result, state=%{state: :remove_old, opendoc: %{for: opendoc}}) do
    case end_doc_match(line, state) do
      nil                -> substate_inside_remove(line, rest, result, state)
      [_, ^opendoc]      -> substate_replace_doc(line, rest, result, state)
      [_, opendoc_prime] -> substate_ignore_illegal_close(rest, opendoc_prime, result, state)
    end
  end

  defp substate_ignore_illegal_close(rest, opendoc_prime, result, state) do 
    result_prime =
      if !state.options.silent do 
        Result.add_warning "ignoring end @doc of #{State.format_opendoc(opendoc_prime, Result.next_lnb(result))} as we are inside a @doc block for #{State.format_opendoc state}"
      else
        result
      end
    state_machine(rest, result, state)
  end

  defp substate_ignore_illegal_open(line, rest, opendoc_prime, result, state) do 
    result_prime =
      if !state.options.silent do
        Result.add_warning(result, "ignoring begin @doc of #{State.format_opendoc(opendoc_prime, Result.next_lnb(result))} as we are inside a @doc block for #{State.format_opendoc state}")
      else
        result
      end
    state_machine(rest, Result.add_line(result_prime, line), state)
  end

  # CHECK
  defp substate_illegal_close_in_copy(line, rest, closedoc, result, state) do 
    result_prime =
      if !state.options.silent do
        Result.add_warning( "ignoring end @doc of #{State.format_opendoc(closedoc, Result.next_lnb(result))} as we are not inside a @doc block" )
      else
        result
      end
    if state.options.fix_errors do 
      state_machine(rest, result, state)
    else
      state_machine(rest, Result.add_line(result, line), state)
    end
  end

  # CHECK
  defp substate_inside_copy(line, rest, result, state) do 
    case end_doc_match(line, state) do 
      nil           -> state_machine(rest, Result.add_line(result, line), state)
      [_, closedoc] -> substate_illegal_close_in_copy(line, rest, closedoc, result, state)
    end
  end

  defp substate_inside_remove(line, rest, result, state) do 
    case begin_doc_match(line, state) do 
      nil                -> state_machine(rest, result, state)
      [_, opendoc_prime] -> substate_ignore_illegal_open(line, rest, opendoc_prime, result, state)
    end
  end

  defp substate_replace_doc(line, rest, result, state=%{opendoc: %{for: for}}) do 
    copy_state = %{state | state: :copy}
    case extract_doc(for) do
      nil -> state_machine( rest,
               Result.add_warning(result, "end @doc missing for #{State.format_opendoc(state)}")
               |> Result.add_line(line), copy_state)
      doc -> state_machine(rest, add_docs_with_line(result, doc, line), copy_state)
    end
  end

  def substate

  # ------------------------------------
  # Helpers
  # ------------------------------------

  defp add_docs_with_line(docs, line, result), do:
    result
    |> Result.add_lines(docs)
    |> Result.add_line(line)

  # CHECK
  defp begin_doc_match({line, _}, state) do
    Regex.run( state.options.begin_rgx, line )
  end

  # CHECK
  defp end_doc_match({line, _}, state) do
    Regex.run state.options.end_rgx, line
  end

end
