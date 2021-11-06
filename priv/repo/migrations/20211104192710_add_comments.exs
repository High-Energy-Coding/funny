defmodule Funny.Repo.Migrations.AddComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :string
      add :person_id, references(:persons, on_delete: :nothing, type: :binary_id)
      add :joke_id, references(:jokes, on_delete: :nothing, type: :binary_id)

      timestamps()
    end
  end
end
