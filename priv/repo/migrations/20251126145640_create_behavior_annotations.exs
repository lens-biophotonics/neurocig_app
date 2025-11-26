defmodule App.Repo.Migrations.CreateBehaviorAnnotation do
  use Ecto.Migration

  def change do
    create table(:behavior_annotations) do
      add :video_id, references(:videos, on_delete: :nothing)

      add :frame, :integer
      add :mouse_id, :integer
      add :behavior, :string
      add :start_stop, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(
             :behavior_annotations,
             [
               :video_id,
               :frame,
               :mouse_id,
               :behavior,
               :start_stop
             ],
             name: :behavior_annotations_unique_index
           )
  end
end
