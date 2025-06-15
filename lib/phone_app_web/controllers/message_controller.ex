defmodule PhoneAppWeb.MessageController do
  use PhoneAppWeb, :controller

  plug :load_conversation_list

  def index(conn, _params) do
    case conn.assigns.conversation_list do
      [%{contact: contact} | _] ->
        path = ~p(/messages/#{contact.id})
        redirect(conn, to: path)

      [] ->
        redirect(conn, to: ~p(/messages/new))
    end
  end

  def show(conn, params = %{"contact_id" => contact_id}) do
    contact = PhoneApp.Conversations.get_contact!(contact_id)
    conversation = PhoneApp.Conversations.load_conversations_with(contact)

    conn
    |> assign(:conversation, conversation)
    |> assign(:changeset, changeset(params))
    |> render("show.html")
  end

  def new(conn, params) do
    render(conn, "new.html", changeset: changeset(params))
  end

  def create(conn, params) do
    create_changeset = changeset(params)

    case Ecto.Changeset.apply_action(create_changeset, :insert) do
      {:ok, message_params} ->
        case PhoneApp.Conversations.send_sms_message(message_params) do
          {:error, err} when is_bitstring(err) ->
            conn
            |> put_flash(:error, err)
            |> new(params)

          {:ok, _result} ->
            redirect(conn, to: ~p(/messages))
        end

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp load_conversation_list(conn, _params) do
    conversations = PhoneApp.Conversations.load_conversations_list()
    assign(conn, :conversation_list, conversations)
  end

  defp changeset(params) do
    conversation_params = Map.get(params, "message", %{})
    PhoneApp.Conversations.new_message_changeset(conversation_params)
  end
end
