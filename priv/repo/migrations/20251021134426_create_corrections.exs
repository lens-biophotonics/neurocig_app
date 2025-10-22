defmodule App.Repo.Migrations.CreateCorrections do
  use Ecto.Migration

  def change do
    create table(:corrections) do
      add :video_id, references(:videos, on_delete: :nothing)
      add :frame, :integer
      add :mouse_from, :integer
      add :mouse_to, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:corrections, [:video_id, :frame, :mouse_from, :mouse_to])
  end
end
