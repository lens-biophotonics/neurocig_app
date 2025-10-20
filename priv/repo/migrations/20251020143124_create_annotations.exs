defmodule App.Repo.Migrations.CreateAnnotations do
  use Ecto.Migration

  def change do
    create table(:annotations) do
      add :video_id, references(:videos, on_delete: :delete_all), null: false

      add :frame, :integer
      add :mouse_id, :integer

      add :bb_x1, :float
      add :bb_y1, :float
      add :bb_x2, :float
      add :bb_y2, :float

      add :nose_x, :float
      add :nose_y, :float

      add :earL_x, :float
      add :earL_y, :float

      add :earR_x, :float
      add :earR_y, :float

      add :tailB_x, :float
      add :tailB_y, :float

      timestamps(type: :utc_datetime)
    end

    create unique_index(:annotations, [:video_id, :frame, :mouse_id])
  end
end
