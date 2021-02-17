# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Funny.Repo.insert!(%Funny.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
#
alias Funny.Catalog.Person
alias Funny.Catalog.Joke

{:ok, %{id: homer_id}} = Person.insert(%{name: "Homer", username: "hsimpson", password: "1234"})
{:ok, %{id: marge_id}} = Person.insert(%{name: "Marge"})
{:ok, _} = Person.insert(%{name: "Bart"})
{:ok, _} = Person.insert(%{name: "Lisa"})
{:ok, _} = Person.insert(%{name: "Maggie"})

[
  "Facts Are Meaningless. You Could Use Facts To Prove Anything That's Even Remotely True.",
  "D'oh!",
  "You’ll have to speak up. I’m wearing a towel."
]
|> Enum.each(
  &Joke.insert(%{
    person_id: homer_id,
    content: &1
  })
)

[
  "Homer, there’s something I don’t like about that severed hand.",
  "I brought you a tuna sandwich. They say it’s brain food. I guess because there’s so much dolphin in there."
]
|> Enum.each(
  &Joke.insert(%{
    person_id: marge_id,
    content: &1
  })
)
