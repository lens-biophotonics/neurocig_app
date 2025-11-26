defmodule App.Repo.Migrations.CreateTypeStrings do
  use Ecto.Migration

  def change do
    create table(:type_strings) do
      add :type_string, :string

      timestamps(type: :utc_datetime)
    end
  end
end
