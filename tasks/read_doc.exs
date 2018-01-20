defmodule Mix.Tasks.ReadDoc do 

  use Mix.Task

  def run(args) do 
    Mix.Task.run "compile", []
    Tasks.ReadDoc.run(args)
  end
end
