# ReadDoc

[![Build Status](https://travis-ci.org/RobertDober/read_doc.svg?branch=master)](https://travis-ci.org/RobertDober/read_doc)
[![Hex.pm](https://img.shields.io/hexpm/v/read_doc.svg)](https://hex.pm/packages/read_doc)
[![Coverage Status](https://coveralls.io/repos/RobertDober/read_doc/badge.png)](https://coveralls.io/r/RobertDober/read_doc)
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

<!-- begin @doc Tasks.ReadDoc -->
## Abstract

Documentation of your project can be extracted into files containing
markers.

These markers are a marker to start insertion, which is of the form:

    <!-- begin @doc <ElixirIdentifier> -->

and

    <!-- end @doc <ElixirIdentifier> -->

Right now only `@moduledoc`  and `@doc` strings can be extracted, according to
if `<ElixirIdentifier>` refers to a module or a function.

E.g. if a file (typically `README.md`) contains the following content:

      Preface
      <!-- begin @doc: My.Module -->
         Some text
      <!-- end @doc: My.Module -->
      Epilogue


running

      mix read_doc README.md

will replace `Some text`
with the moduledoc string of `My.Module`.

## Limitations

- Docstrings for types, macros and callbacks cannot be accessed yet.
- Recursion is not supported, meaning that a docstring containing markers
  will not trigger the inclusion of the docstring indicated by these markers.
<!-- end @doc Tasks.ReadDoc -->

<!-- begin @doc ReadDoc.Options -->
## Usage:

    mix read_doc [options] files...

Each file is scanned for block of lines starting with `<!-- begin @doc...` and 
endifing with `<!-- end @doc...`.
Then the content between two matching lines is replaced with the corresponding docstring.

The following options are implemented

    --silent     no messages emitted to :stderr (defaults to false)
    --keep-copy  a copy of the original input file is kept by appending `.bup<n>` where n runs from 1 to the
                 next available number for which no copy exists yet (defaults to false)
    --fix-errors defaults to true! (deactivate via --no-fix-errors), and closing `<!-- end @doc...` lines
                 with no matching `<!-- begin @doc...` are removed from the input
    --begin-trigger defaults to `"\A \s* <!-- \s+ begin \s @doc \s ([\w.?!]+) \s+ --> \s* \z"`.
                    This values is interpreted as an extended regex indicating the begin of a docstring block, where
                    the first capture defines the module/function of the docstring
    --end-trigger defaults to `"\A \s* <!-- \s+ end \s @doc \s ([\w.?!]+) \s+ --> \s* \z"`.
                    This values is interpreted as an extended regex indicating the end of a docstring block, where
                    the first capture defines the module/function of the docstring
<!-- end @doc ReadDoc.Options -->

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/read_doc](https://hexdocs.pm/read_doc).

