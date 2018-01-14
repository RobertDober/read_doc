defmodule ReadDoc.Pair do
  use ReadDoc.Types

  @moduledoc """
    Funcitions working on Pairs
  """ 
  @doc """
  first extracts first element of a tuple
      iex> first({1, nil})
      1

      iex> first({nil, 1})
      nil
  """
  @spec first(pair(e, any)) :: e when e: any
  def first({h, _}), do: h
end
