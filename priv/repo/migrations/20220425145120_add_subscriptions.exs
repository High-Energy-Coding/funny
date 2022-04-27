defmodule Funny.Repo.Migrations.AddSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :endpoint, :string
      add :expirationTime, :string
      add :keys, :jsonb

      add :person_id, references(:persons, on_delete: :nothing, type: :binary_id)
      timestamps()
    end

    create unique_index(:subscriptions, [:endpoint])
  end
end
