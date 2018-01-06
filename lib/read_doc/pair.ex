defmodule ReadDoc.Pair do
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
  def first({h, _}), do: h
end
