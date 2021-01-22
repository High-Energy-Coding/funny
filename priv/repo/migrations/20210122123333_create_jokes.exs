defmodule Funny.Repo.Migrations.CreateJokes do
  use Ecto.Migration

  def change do
    create table(:jokes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :person_id, references(:persons, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:jokes, [:person_id])
  end
end
