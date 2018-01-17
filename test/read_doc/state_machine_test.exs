defmodule ReadDoc.StateMachineTest do
  use ExUnit.Case

  import Support.Helpers

  describe "state machine, nothing to be inserted" do

    test "because empty" do
      assert run([]) == {[], []}
    end

    @no_trigger ~w{line_1 line_2}
    test "because no end trigger" do
      assert run(@no_trigger) == {@no_trigger, []}
    end

    @only_end ["<!-- end @doc X -->", "line 1"]
    test "because no begin trigger - warn and autocorrect" do
      assert run(@only_end) == {["line 1"], [%ReadDoc.Message{lnb: 1, message: "ignoring end @doc of X (opened in line 1) as we are not inside a @doc block", severity: :warning}]}
    end

    test "because no begin trigger - warn and do not autocorrect" do
      assert run(@only_end, fix_errors: false) == {@only_end, [%ReadDoc.Message{lnb: 1, message: "ignoring end @doc of X (opened in line 1) as we are not inside a @doc block", severity: :warning}]}
    end

  end

  describe "state machine, insert one doc, no warnings" do
    @only_doc ["<!-- begin @doc Main -->", "<!-- end @doc Main -->"]
    test "only doc" do
        assert run(@only_doc) == {["<!-- begin @doc Main -->",
         "  This is Main",
         "  This is Main",
         "  This is Main",
         "<!-- end @doc Main -->"], []}
    end

    @only_doc_with_removed ["<!-- begin @doc Main.alpha -->", "inside", "still inside", "<!-- end @doc Main.alpha -->"]
    test "only doc with removed" do
      assert run(@only_doc_with_removed) == {["<!-- begin @doc Main.alpha -->",
       "  This is Main.alpha",
       "<!-- end @doc Main.alpha -->"], []}
    end

    @doc_at_beg ["<!-- begin @doc Main -->", "<!-- end @doc Main -->", "after"]
    test "only doc (at begin)" do
      assert run(@doc_at_beg) == {["<!-- begin @doc Main -->",
       "  This is Main",
       "  This is Main",
       "  This is Main",
       "<!-- end @doc Main -->",
       "after"], []}
    end

    @doc_at_end ["before", "<!-- begin @doc Main -->", "<!-- end @doc Main -->"]
    test "only doc (at end)" do
      assert run(@doc_at_end) == {[ "before",
        "<!-- begin @doc Main -->",
        "  This is Main",
        "  This is Main",
        "  This is Main",
        "<!-- end @doc Main -->"], []}
    end
  end

  describe "state machine, insert one doc, warnings" do
    @missing_end ["<!-- begin @doc Main -->"]
    test "edge case, missing end" do
      assert run(@missing_end) == {["<!-- begin @doc Main -->",
       "  This is Main",
       "  This is Main",
       "  This is Main"], [%ReadDoc.Message{lnb: 1, message: "end @doc for Main (opened in line 1) missing", severity: :warning}]}
    end

    @missing_end2 ["one", "<!-- begin @doc Main -->"]
    test "edge case, missing end 2nd line" do
      assert run(@missing_end2) == {["one",
       "<!-- begin @doc Main -->",
       "  This is Main",
       "  This is Main",
       "  This is Main"], [%ReadDoc.Message{lnb: 2, message: "end @doc for Main (opened in line 2) missing", severity: :warning}]}
    end
  end


  describe "state machine, complex example" do 
    
    @complex [ "<!-- begin @doc Main -->",
      "dissapears",
      "<!-- end @doc Main -->",
      "ramains",
      " <!-- begin @doc Main.Second -->",
      "",
      " <!-- end @doc Main.Second -->",
      "# <!-- end @doc Main -->",
      "<!-- begin @doc Main.Second.yes_doc --> ",
      "<!-- end @doc Main.Second.yes_doc --> ",
      "suffix"
    ]
    test "no warnings" do 
      assert run(@complex) == {[ "<!-- begin @doc Main -->",
        "  This is Main",
        "  This is Main",
        "  This is Main",
        "<!-- end @doc Main -->",
        "ramains",
        " <!-- begin @doc Main.Second -->",
        "  This is Main.Second",
        " <!-- end @doc Main.Second -->",
        "# <!-- end @doc Main -->",
        "<!-- begin @doc Main.Second.yes_doc --> ",
        "  This is yes_doc",
        "<!-- end @doc Main.Second.yes_doc --> ",
        "suffix"
      ], []}
    end

    @illegal_end [ "<!-- begin @doc Main -->",
      "<!-- end @doc Main.alpha -->",
      "<!-- end @doc Main -->",
      "ramains",
      " <!-- begin @doc Main.Second -->",
      "",
      " <!-- end @doc Main.Second -->",
      "# <!-- end @doc Main -->",
      "<!-- begin @doc Main.Second.yes_doc --> ",
      "<!-- end @doc Main.Second.yes_doc --> ",
      "suffix"
    ]
    test "illegal end warnings" do 
      assert run(@illegal_end) == {[ "<!-- begin @doc Main -->",
        "  This is Main",
        "  This is Main",
        "  This is Main",
        "<!-- end @doc Main -->",
        "ramains",
        " <!-- begin @doc Main.Second -->",
        "  This is Main.Second",
        " <!-- end @doc Main.Second -->",
        "# <!-- end @doc Main -->",
        "<!-- begin @doc Main.Second.yes_doc --> ",
        "  This is yes_doc",
        "<!-- end @doc Main.Second.yes_doc --> ",
        "suffix"
      ],
      [%ReadDoc.Message{lnb: 2, message: "ignoring end @doc of Main.alpha (opened in line 2) as we are inside a @doc block for Main (opened in line 1)", severity: :warning}]}
    end


    @many_warns [ "<!-- begin @doc Main -->",
      "<!-- begin @doc Main.alpha -->",
      "<!-- end @doc Main -->",
      "ramains",
      " <!-- begin @doc Main.Second -->",
      "",
      " <!-- end @doc Main.Second -->",
      "<!-- begin @doc DoesNotExist -->",
      "<!-- end @doc DoesNotExist -->",
      "# <!-- end @doc Main -->",
      "<!-- begin @doc Main.Second.yes_doc --> ",
      "<!-- end @doc Main.Second.yes_doc --> ",
      "suffix"
    ]
    test "many warnings" do 
        assert run(@many_warns) == {[ "<!-- begin @doc Main -->",
          "<!-- begin @doc Main.alpha -->",
          "  This is Main",
          "  This is Main",
          "  This is Main",
          "<!-- end @doc Main -->",
          "ramains",
          " <!-- begin @doc Main.Second -->",
          "  This is Main.Second",
          " <!-- end @doc Main.Second -->",
          "<!-- begin @doc DoesNotExist -->",
          "<!-- end @doc DoesNotExist -->",
          "# <!-- end @doc Main -->",
          "<!-- begin @doc Main.Second.yes_doc --> ",
          "  This is yes_doc",
          "<!-- end @doc Main.Second.yes_doc --> ",
          "suffix"
        ],
      [%ReadDoc.Message{lnb: 12, message: "end @doc missing for DoesNotExist (opened in line 11)", severity: :warning},
       %ReadDoc.Message{lnb: 2, message: "ignoring begin @doc of Main.alpha (opened in line 2) as we are inside a @doc block for Main (opened in line 1)", severity: :warning}]}
    end
  end
end
