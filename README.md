# Doorman

Doorman is designed to work with phone-based building intercoms (like DoorKing) to allow automatic access for a limited period of time. For example, if you're hosting a party in your apartment and you want to automatically let your guests into the building, Doorman can let them in without constantly bothering you.

Building access intercoms like DoorKing work by having each resident's phone number. When a guest selects their name at the intercom, it calls the resident's phone and opens a voice channel. If the resident presses "9" on their phone, the intercom system will buzz open the door.

Doorman can automate this process when many guests are expected. When a "door" is created in Doorman, it generates a Twilio phone number that can be used in the building intercom instead. Doorman will then intercept calls from the intercom, and normally simply forward them to the resident. However, the user can tell Doorman to automatically buzz people in when they use the intercom instead. The guest is let into the building, and the resident gets a text message that someone entered.

## Development

Doorman is a [Phoenix](http://www.phoenixframework.org/) app.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
