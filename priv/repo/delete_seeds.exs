#---
# Excerpted from "From Ruby to Elixir",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/sbelixir for more book information.
#---
# Script for removing all seeded data from the database. You can run it as:
#
#     mix run priv/repo/delete_seeds.exs
#

import Ecto.Query

from(
  m in PhoneApp.Conversations.Schema.SmsMessage,
  where: m.account_sid == "seed"
)
|> PhoneApp.Repo.delete_all()
