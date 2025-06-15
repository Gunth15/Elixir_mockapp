defmodule PhoneAppWeb.MessageHTML do
  use PhoneAppWeb, :html
  # Define attributes that go into the message form component
  alias PhoneApp.Conversations

  attr :changeset, Ecto.Changeset, required: true
  attr :contact, Conversations.Schema.Contact, required: false
  def message_form(assigns)

  # Alternate Button for something(idk)
  attr :type, :string, default: "button", values: ["button", "submit"]
  slot :inner_block, required: true

  # Maybe a good scheme is to put tiny components
  def slot_button(assigns) do
    ~H"""
    <button type={@type} class="rounded border bg-white text-gray-700 px-4 py-2">
      {render_slot(@inner_block)}
    </button>
    """
  end

  embed_templates "message_html/*"
end
