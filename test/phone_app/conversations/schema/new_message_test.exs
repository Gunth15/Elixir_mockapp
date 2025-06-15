defmodule PhoneApp.Conversations.Schema.NewMessageTest do
  use ExUnit.Case, async: true

  alias PhoneApp.Conversations.Schema.NewMessage

  describe "changeset/1" do
    test "fields are required" do
      cs = NewMessage.changeset(%{})

      # cs.errors must pattern match to have errors
      assert [
               to: {"can't be blank", _},
               body: {"can't be blank", _}
             ] = cs.errors
    end

    test "the country code is added if not present" do
      assert(
        %{
          errors: [],
          changes: %{to: "+1 5005500006"}
        } = NewMessage.changeset(%{"body" => "test", "to" => "5005500006"})
      )
    end

    test "the phone app number is validated" do
      assert %{
               errors: [to: {"is an invalid phone number", _}]
             } = NewMessage.changeset(%{"body" => "test", "to" => "+1 111-222-3333"})
    end
  end
end
