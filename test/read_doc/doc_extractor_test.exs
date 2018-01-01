defmodule ReadDoc.DocExtractorTest do
  use ExUnit.Case

  alias ReadDoc.DocExtractor, as: E
  
  describe "Moduledoc" do 
    test "moduledoc" do 
      assert E.extract_doc("Support.Example") == """
  modduledoc for example
  """
    end

    test "no moduledoc" do
      assert E.extract_doc("Support.Example1") == nil
    end

    test "no module" do
      assert E.extract_doc("Support.NoSuchExample") == nil
    end
  end

  describe "Functiondoc" do
    test "exists" do
      assert E.extract_doc("Support.Example.a_function") == """
  A function doc
  """
    end

    test "does (probably) not exist" do
      assert E.extract_doc("Support.Example.fn_48718cc6fdd8a8acb2fa4db261ea0a81") == nil
    end

    test "a function with no module" do 
      assert E.extract_doc("Support.NoSuchExample.fn_48718cc6fdd8a8acb2fa4db261ea0a81") == nil
    end
  end

  describe "RealWorld Example" do 
    test "String moduledoc" do 
      assert Regex.match?(~r{\AA String in Elixir}, E.extract_doc("String"))
    end

    test "String, existing function's doc" do 
      assert Regex.match?(~r{Returns the number of Unicode}, E.extract_doc("String.length"))
    end

    test "String, inexistant function's doc" do
      assert E.extract_doc("String.fn_48718cc6fdd8a8acb2fa4db261ea0a81") == nil
    end
  end

  describe "Edge Cases" do 
    test "empty module, no function" do 
      assert_raise(ArgumentError, "no module name provided", fn ->
        E.extract_doc("")
      end)
    end

    test "no module, just fucntion" do 
      assert_raise(ArgumentError, "no module name provided, for function xxx", fn ->
        E.extract_doc("xxx")
      end)
      
    end

    
  end
end
