defmodule ReadDoc.DocExtractor do


  @upperCase ~r{\A[[:upper:]]}u

  @doc """
  Extracts the moduledoc or doc of a function from a module
  """
  def extract_doc(module_or_function_name) do
    module_or_function_name
    |> extract_untrimmed_doc()
    |> trim_trailing()
  end

  defp extract_untrimmed_doc(module_or_function_name) do
    case split_name(module_or_function_name) do
      [function_name, module_name] -> _extract_doc(function_name, module_name) 
      [""]                         -> raise ArgumentError, "no module name provided"
      [module_name]                -> _extract_doc(module_name)
    end
  end

  defp _extract_doc(module_name) do
    if Regex.match?(@upperCase, module_name) do
      extract_module_doc(String.to_atom("Elixir.#{module_name}"))
    else
      raise ArgumentError, "no module name provided, for function #{module_name}"
    end
  end

  defp _extract_doc(function_name, module_name) do
    if Regex.match?(@upperCase, function_name) do
      extract_module_doc(String.to_atom("Elixir.#{module_name}.#{function_name}"))
    else
      extract_function_doc(String.to_atom("Elixir.#{module_name}"), String.to_atom(function_name))
    end
  end

  defp extract_module_doc(module) do
    case Code.get_docs(module, :moduledoc) do
      {_, docs} when is_binary(docs) ->
        docs
        _ -> nil
    end
  end

  defp extract_function_doc(module, function) do
    case Code.get_docs(module, :docs) do
      nil  -> nil
      code -> code
      |> Enum.find_value(find_doc_fn(function))
    end
  end


  defp find_doc_fn( function_name ) do
    fn {{name, _arity}, _lnb, _def, _options, doc} -> 
    name == function_name && doc
    end
  end

  defp split_name(module_or_function_name) do
    module_or_function_name
      |> String.reverse()
      |> String.split(".", parts: 2)
      |> Enum.map(&String.reverse/1)
  end

  defp trim_trailing(nil), do: nil
  defp trim_trailing(str), do: str |> String.trim_trailing()
end
