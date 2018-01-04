defmodule ReadDocTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  import Support.Helpers

  doctest ReadDoc



  describe "state machine, one insertion" do
    
    @insertion ["<!-- begin @doc Main -->","<!-- end @doc Main -->"]
    test "edge case, only insertion" do 
      assert run(@insertion) == ["<!-- begin @doc Main -->",
        "  This is Main\n  This is Main\n  This is Main",
       "<!-- end @doc Main -->"]
    end

    @missing_end ["<!-- begin @doc Main -->"]
    test "edge case, missing end" do 
      assert capture_io( :stderr, fn ->
      assert run(@missing_end) == ["<!-- begin @doc Main -->",
        "  This is Main\n  This is Main\n  This is Main"]
      end) == "end @doc for Main missing\n"
      
    end
  end



end
