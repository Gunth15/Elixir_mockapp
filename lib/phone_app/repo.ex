defmodule PhoneApp.Repo do
  use Ecto.Repo,
    otp_app: :phone_app,
    adapter: Ecto.Adapters.Postgres
end
