defmodule PhoneApp.Repo.Migrations.CreateSmsMessage do
  use Ecto.Migration

  def change do
    create table(:sms_messages) do
      add :contact_id, :integer, null: false

      add :message_sid, :text, null: false
      add :account_sid, :text, null: false

      add :body, :text, null: false
      add :from, :text, null: false
      add :to, :text, null: false

      add :status, :text, null: false
      add :direction, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:sms_messages, [:contact_id])
    create unique_index(:sms_messages, [:message_sid])
  end
end
