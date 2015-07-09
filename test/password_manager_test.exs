defmodule PasswordManagerTest do
  use ExUnit.Case

  test "can create Record" do
    pr = %PasswordManager.Record{title: "my_bank"}
    assert pr.title == "my_bank"
    assert pr.user == ""
  end

  test "search by title" do
    pr1 = %PasswordManager.Record{title: "t1"}
    pr2 = %PasswordManager.Record{title: "t2"}
    assert PasswordManager.search([pr1, pr2], "t2") == [pr2]

    pr3 = %PasswordManager.Record{title: "t2 t3"}
    assert PasswordManager.search([pr1, pr2, pr3], "t2") == [pr2, pr3]
  end

  test "search by notes" do
    pr1 = %PasswordManager.Record{title: "t1", notes: "my bank"}
    pr2 = %PasswordManager.Record{title: "t2", notes: "my yahoo account"}
    assert PasswordManager.search([pr1, pr2], "bank") == [pr1]
    assert PasswordManager.search([pr1, pr2], "my") == [pr1, pr2]
    assert PasswordManager.search([pr1, pr2], "acc") == [pr2]
  end

  test "search is case insensitive" do
    pr1 = %PasswordManager.Record{title: "CaSe1"}
    pr2 = %PasswordManager.Record{title: "CaSe2"}
    assert PasswordManager.search([pr1, pr2], "CASE1") == [pr1]
  end

  test "duplicate? checks title to detect duplicate Records" do
    pr1 = %PasswordManager.Record{title: "MyBank"}
    pr2 = %PasswordManager.Record{title: "MyOtherBank"}
    assert PasswordManager.duplicate?([pr1, pr2], "MyBank")
    assert PasswordManager.duplicate?([pr1, pr2], "mYbank")
    assert not PasswordManager.duplicate?([pr1, pr2], "MyNewBank")
  end

  test "find_index returns the index of the Record keyed by title" do
    pr1 = %PasswordManager.Record{title: "MyBank"}
    pr2 = %PasswordManager.Record{title: "MyOtherBank"}
    assert PasswordManager.find_index([pr1, pr2], "myBank") == 0
    assert PasswordManager.find_index([pr1, pr2], "myotherbank") == 1
  end

  test "update title" do
    pr1 = %PasswordManager.Record{title: "MyBank", user: "Hulk",
                                  password: "1234", notes: "Bank with big money."}
    pr2 = %PasswordManager.Record{title: "MyOtherBank", user: "Hulk",
                                  password: "1234", notes: "Bank with vacation savings."}
    records = PasswordManager.update([pr1, pr2], 0, :title, "BigPiggy")
    assert Enum.at(records, 0) == %PasswordManager.Record{title: "BigPiggy", user: "Hulk",
                                                          password: "1234",
                                                          notes: "Bank with big money."}
    assert Enum.at(records, 1) == pr2
  end

  test "update password" do
    pr1 = %PasswordManager.Record{title: "MyBank", user: "Hulk",
                                  password: "1234", notes: "Bank with big money."}
    pr2 = %PasswordManager.Record{title: "MyOtherBank", user: "Hulk",
                                  password: "1234", notes: "Bank with vacation savings."}
    records = PasswordManager.update([pr1, pr2], 1, :password, "xxx")
    assert Enum.at(records, 0) == pr1
    assert Enum.at(records, 1) == %PasswordManager.Record{title: "MyOtherBank", user: "Hulk",
                                                          password: "xxx",
                                                          notes: "Bank with vacation savings."}
  end

  test "save records db" do
    file_name = "test_save.db"
    pr1 = %PasswordManager.Record{title: "MyBank", user: "Hulk",
                                  password: "1234", notes: "Bank with big money."}
    pr2 = %PasswordManager.Record{title: "MyOtherBank", user: "Hulk",
                                  password: "1234", notes: "Bank with vacation savings."}
    assert PasswordManager.save([pr1, pr2], "my_password_123", file_name) == :ok

    records = PasswordManager.load("my_password_123", file_name)
    File.rm!(file_name)
    assert length(records) == 2
    assert Enum.at(records, 0) == pr1
    assert Enum.at(records, 1) == pr2
  end

  test "returns empty list when db does not exist" do
    records = PasswordManager.load("my_password_123", "test_load.db")
    assert Enum.empty?(records)
  end

  test "creates a 1 based title map for records" do
    pr1 = %PasswordManager.Record{title: "MyBank", user: "Hulk",
                                  password: "1234", notes: "Bank with big money."}
    pr2 = %PasswordManager.Record{title: "MyOtherBank", user: "Hulk",
                                  password: "1234", notes: "Bank with vacation savings."}

    titles = PasswordManager.make_indexed_titles([pr1, pr2])
    assert titles != nil
    assert Map.size(titles) == 2
    assert titles[1] == "MyBank"
    assert titles[2] == "MyOtherBank"
  end
end
