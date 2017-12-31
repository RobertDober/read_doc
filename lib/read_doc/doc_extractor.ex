defmodule ReadDoc.DocExtractor do


  def extract_doc(type, module_name)
  def extract_doc("module", module_name) do
    module = String.to_atom("Elixir.#{module_name}")

    docs = case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          case Code.get_docs(module, :moduledoc) do
            {_, docs} when is_binary(docs) ->
              docs
            _ -> nil
          end
        else
          nil
        end
      _ -> nil
    end

  def extract_doc("function", module_and_function_name) do

    [function_name, module_name] = module_and_function_name
      |> String.reverse()
      |> String.split(".", parts: 2)
      |> Enum.map(&String.reverse/1)

    module = String.to_atom("Elixir." <> module_name)
    func   = String.to_atom(function_name)

    docs # || "No module documentation available for #{name}\n"
  end

end

