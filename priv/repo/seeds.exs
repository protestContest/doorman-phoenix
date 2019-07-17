# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

users = [
  %{email: "zack@example.com", password: "password"},
]

for user <- users do
  {:ok, user} = Doorman.Accounts.create_user(user)
  Doorman.Accounts.confirm_user(user)
end
