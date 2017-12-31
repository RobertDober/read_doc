defmodule ReadDoc.DocExtractorTest do
  use ExUnit.Case

  alias ReadDoc.DocExtractor, as: E
  
  describe "Moduledoc" do 
    test "moduledoc" do 
      assert E.extract_doc("module", "Support.Example") == """
  modduledoc for example
  """
    end

    test "no moduledoc" do
      assert E.extract_doc("module", "Support.Example1") == nil
    end
  end

  describe "Functiondoc" do
    test "exists" do
      assert E.extract_doc("function", "Support.Example") == """
  modduledoc for example
  """
    end
  end
end
