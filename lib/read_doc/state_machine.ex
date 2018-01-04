defmodule ReadDoc.StateMachine do
  alias ReadDoc.Options
  import ReadDoc.DocExtractor, only: [extract_doc: 1]

  defstruct state: :copy,
            opendoc: %{for: nil, line_nb: 0},
            options: %Options{}

  def run(lines, options) do
    lines
    |> Stream.zip(Stream.iterate(1, &(&1 + 1)))
    |> Enum.to_list()
    |> state_machine([], %__MODULE__{options: options})
  end

  @copy_state %{state: :copy}
  @doc false
  defp state_machine(lines, result, state)
  defp state_machine([], result, @copy_state), do: result |> Enum.reverse()
  defp state_machine([], result, state) do
    if !state.options.silent do
      IO.puts :stderr, "end @doc for #{format_opendoc(state)} missing"
    end
    case extract_doc_with_warning(state) do
      nil -> result
      doc -> add_doc(doc, result)
    end
    |> Enum.reverse()
  end
  defp state_machine([line|rest], result, state = @copy_state) do
    case begin_doc_match(line, state) do 
      nil          -> substate_inside_copy(line, rest, result, state)
      [_, opendoc] -> state_machine(rest, push(line, result), %{state | opendoc: %{for: opendoc, line_nb: 0}})
    end
  end
  defp state_machine([line|rest], :remove_old, opendoc, result, options) do
    case end_doc_match(line, options) do
      nil -> substate_inside_remove(line, rest, opendoc, result, options)
      [_, ^opendoc] -> substate_replace_doc(line, rest, opendoc, result, options)
      [_, opendoc_prime] -> substate_ignore_illegal_close(rest, opendoc, opendoc_prime, result, options)
    end
  end

  defp substate_ignore_illegal_close(rest, opendoc, opendoc_prime, result, options) do 
    if !options.silent do 
      IO.puts :stderr, "ignoring end @doc of #{opendoc_prime} as we are inside a @doc block for #{opendoc}"
    end
    state_machine(rest, :remove_old, opendoc, result, options)
  end

  defp substate_ignore_illegal_open(line, rest, opendoc, opendoc_prime, result, options) do 
    if !options.silent do
      IO.puts :stderr, "ignoring begin @doc of #{opendoc_prime} as we are inside a @doc block for #{opendoc}"
    end
    if options.fix_errors do
      state_machine(rest, :remove_old, opendoc, result, options)
    else
      state_machine(rest, :remove_old, opendoc, push(line, result), options)
    end
  end

  defp substate_illegal_close_in_copy(line, rest, closedoc, result, state) do 
    if !state.options.silent do
      IO.puts :stderr, "ignoring end @doc of #{closedoc} as we are not inside a @doc block"
    end
    if state.options.fix_errors do 
      state_machine(rest, result, state)
    else
      state_machine(rest, push(line, result), state)
    end
  end

  defp substate_inside_copy(line, rest, result, state) do 
    case end_doc_match(line, state) do 
      nil -> state_machine(rest, push(line, result), state)
      [_, closedoc] -> substate_illegal_close_in_copy(line, rest, closedoc, result, state)
    end
    
  end

  defp substate_inside_remove(line, rest, opendoc, result, options) do 
    case begin_doc_match(line, options) do 
      nil -> state_machine(rest, :remove_old, opendoc, result, options)
      [_, opendoc_prime] -> substate_ignore_illegal_open(line, rest, opendoc, opendoc_prime, result, options)
    end
  end

  defp substate_replace_doc(line, rest, opendoc, result, options) do 
    case extract_doc_with_warning(opendoc, options) do
      nil -> state_machine(rest, :copy, nil, push(line, result), options)
      doc -> state_machine(rest, :copy, nil, push(line, add_doc(doc, result)), options)
    end
  end


  # ------------------------------------
  # Helpers
  # ------------------------------------
  defp add_doc(docstring, result) do
    docstring
    |> String.split("\n")
    |> add_doc_lines(result)
  end

  defp add_doc_lines([], result), do: result
  defp add_doc_lines([line | rest], [{_, rlnb}|_] = result) do
    add_doc_lines(rest, [{line, rlnb+1} | result])
  end

  defp begin_doc_match({line, _}, state) do
    Regex.run state.options.begin_rgx, line
  end

  defp end_doc_match({line, _}, state) do
    Regex.run state.options.end_rgx, line
  end

  defp extract_doc_with_warning(state) do 
    case extract_doc(state.opendoc.for) do 
      nil ->
        if !state.options.silent do
          IO.puts :stderr, "No documentation found for #{format_opendoc(state)}"
        end
        nil
      doc -> doc
    end
  end

  defp format_opendoc(state) do 
    "#{state.opendoc.for}:#{state.opendoc.line_nb}"
  end

  defp push(line, []), do: [{line, 1}]
  defp push(line, [{_, lnb}|_] = result), do: [{line, lnb+1} | result]
end
