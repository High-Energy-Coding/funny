defmodule Funny.Repo.Migrations.CreateFamilies do
  use Ecto.Migration

  def change do
    create table(:families, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string

      timestamps()
    end

    alter table(:persons) do
      add :family_id, references("families", on_delete: :nilify_all)
    end
  end
end
