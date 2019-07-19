# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# It is also run when you use `mix ecto.setup` or `mix ecto.reset`
#

admins = [
  %{email: "zack@example.com", password: "password"},
]

users = []

for user <- users do
  {:ok, user} = Doorman.Accounts.create_user(user)
  Doorman.Accounts.confirm_user(user)
end

for admin <- admins do
  {:ok, admin} = Doorman.Accounts.create_user(admin)
  Doorman.Accounts.confirm_user(admin)
  Doorman.Accounts.make_admin(admin)
end
