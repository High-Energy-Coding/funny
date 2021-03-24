defmodule Funny.Repo.Migrations.AddSomeUniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:persons, [:username])
    create unique_index(:persons, [:email])
  end
end
