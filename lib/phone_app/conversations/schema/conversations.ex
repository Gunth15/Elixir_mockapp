defmodule PhoneApp.Conversations.Schema.Conversations do
  alias PhoneApp.Conversations.Query
  @enforce_keys [:contact, :messages]
  defstruct @enforce_keys
end
