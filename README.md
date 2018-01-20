# ReadDoc

[![Build Status](https://travis-ci.org/RobertDober/read_doc.svg?branch=master)](https://travis-ci.org/RobertDober/read_doc)
[![Hex.pm](https://img.shields.io/hexpm/v/read_doc.svg)](https://hex.pm/packages/read_doc)
[![Coverage Status](https://coveralls.io/repos/github/RobertDober/read_doc/badge.svg?branch=master)](https://coveralls.io/github/RobertDober/read_doc?branch=master)
[![Inline docs](http://inch-ci.org/github/RobertDober/read_doc.svg?branch=master)](http://inch-ci.org/github/RobertDober/read_doc)

Insert ExDoc documentation into files.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `read_doc` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:read_doc, "~> 0.1.0"}
  ]
end
```

## Usage

<!-- begin @doc Tasks.ReadDoc -->
The documentation to be extracted and its location in the target file
are indicated by two lines, a start line and an end line which act as
parentheses that are kept, the lines between them are replaced by the
doc strings defined by the start and end line's content.

E.g. if a file (typically `README.md`) contains the following content:

      Preface
      <!-- begin @doc: My.Module -->
         Some text
      <!-- end @doc: My.Module -->
      Epilogue


running the `read_doc` task with `README.md`, will replace `Some text`
with the moduledoc string of `My.Module`.

Also if the name designates a function, the docsring of the given function
will be replaced, e.g.

      <!-- begin @doc: My.Module.shiny_fun -->
        ...
      <!-- end @doc: My.Module.shiny_fun -->
<!-- end @doc Tasks.ReadDoc -->


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/read_doc](https://hexdocs.pm/read_doc).

