defmodule Support.Helpers do
  alias ReadDoc.Options

  def run(input, options \\ []) do
    options = Map.merge(%Options{}, options |> Enum.into(%{}))
    ReadDoc.StateMachine.run(input, Options.finalize(options))
  end

  def run!(input, options \\ []) do
    options = Map.merge(%Options{}, options |> Enum.into(%{}))
    ReadDoc.StateMachine.run!(input, Options.finalize(options), "filename")
  end
end
