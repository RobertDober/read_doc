defmodule Mix.Tasks.ReadDoc do
  @shortdoc """
  Extract ex_doc documentation from modules or functions into a file.
  """

  @moduledoc """
  The documentation to be extracted and its location in the target file
  are indicated by two lines, a start line and an end line which act as
  parentheses that are kept, the lines between them are replaced by the
  doc strings defined by the start and end line's content.
  
  E.g. if a file (typically `README.md` contains the following content:

        Preface
        <!-- begin doc: module My.Module -->
           Some text
        <!-- end doc: module My.Module -->
        Epilogue


  running the `read_doc` task with `README.md`, will replace `Some text`
  with the moduledoc string of `My.Module`.
  """
  
  use Mix.Task

  def run(args) do
    IO.inspect args
  end
end
