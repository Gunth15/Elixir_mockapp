defmodule PhoneApp.Conversations.Query.ContactStoreTest do
  alias PhoneApp.Conversations.Query.ContactStore
  use PhoneApp.DataCase, async: true

  alias PhoneApp.Conversations.Query, ContactStore

  describe "upsert_contact/1" do
    @incoming %{
      from: "111-222-3333",
      to: "999-888-7777",
      direction: :incoming
    }

    @outgoing %{@incoming | direction: :outgoing}

    test "a new contact is created, based on direction" do
      assert {:ok, contact} = ContactStore.upsert_contact(@incoming)
      assert contact.id
      assert contact.phone_number = "111-222-333"

      assert {:ok, contact2} = ContactStore.upsert_contact(@outgoing)
      assert contact2.id
      assert contact.id != contact2.id
      assert contact2.phone_number == "999-888-7777"
    end

    test "a contact with the same phone number is updated" do
      assert {:ok, contact} = ContactStore.upsert_contact(@incoming)
      assert {:ok, contact2} = ContactStore.upsert_contact(@incoming)

      assert contact2.updated_at != contact.updated_at

      assert Map.delete(contact2, :updated_at) == Map.delete(contact, :updated_at)
    end
  end

  describe "get_contact!/1" do
    test "no contact raises an error" do
      assert_raise(Ecto.NoResultsError, fn ->
        ContactStore.get_contact(0)
      end)
    end

    test "a contact is returned" do
      assert {:ok, contact} = ContactStore.upsert_contact(@incoming)
      assert ContactStore.get_contact!(contact.id) == contact
    end
  end
end
