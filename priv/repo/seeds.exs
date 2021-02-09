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
alias Funny.Catalog.Family

{:ok, %{id: griffin_fam_id}} = Family.insert(%{name: "Griffin"})

{:ok, %{id: peter_id}} =
  Person.insert(%{
    name: "Peter",
    family_id: griffin_fam_id,
    username: "pgriffin",
    password: "1234"
  })

{:ok, %{id: simpsons_fam_id}} = Family.insert(%{name: "Simpsons"})

{:ok, %{id: homer_id}} =
  Person.insert(%{
    name: "Homer",
    family_id: simpsons_fam_id,
    username: "hsimpson",
    password: "1234"
  })

{:ok, %{id: marge_id}} = Person.insert(%{name: "Marge", family_id: simpsons_fam_id})
{:ok, _} = Person.insert(%{name: "Bart", family_id: simpsons_fam_id})
{:ok, _} = Person.insert(%{name: "Lisa", family_id: simpsons_fam_id})
{:ok, _} = Person.insert(%{name: "Maggie", family_id: simpsons_fam_id})

[
  "You mean \"he\" is going into labor"
]
|> Enum.each(
  &Joke.insert(%{
    person_id: peter_id,
    content: &1
  })
)

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
