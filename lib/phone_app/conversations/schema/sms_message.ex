defmodule PhoneApp.Conversations.Schema.SmsMessage do
  use Ecto.Schema

  @timestamps_opts [type: :utc_datetime_usec]

  schema "sms_messages" do
    # 1-to-many relationship with the other person in the conversation
    belongs_to :contact, PhoneApp.Conversations.Schema.Contact

    # Holds the message identifier for Twilio's message objects
    field :message_sid, :string

    # Holds the account identifier that interacted with Twilio.
    field :account_sid, :string

    # Holds the full text contents of the SMS message
    field :body, :string

    # The phone number that sent the SMS message
    field :from, :string
    # The phone number that recieved the SMS message field :to, :string
    field :to, :string
    # Holds the current state of the SMS message from Twilio
    field :status, :string

    # Whether this message was received inbound or sent outbound
    field :direction, Ecto.Enum, values: [:incoming, :outgoing]

    timestamps()
  end

  import Ecto.Changeset

  def changeset(attrs) do
    fields = [
      :contact_id,
      :message_sid,
      :account_sid,
      :body,
      :from,
      :to,
      :status,
      :direction
    ]

    %__MODULE__{}
    |> cast(attrs, fields)
    |> validate_required(fields)
    |> unique_constraint([:message_sid])
  end

  def update_changeset(attrs, struct = %__MODULE__{}) do
    fields = [:status]

    struct
    |> cast(attrs, fields)
    |> validate_required(fields)
  end
end
