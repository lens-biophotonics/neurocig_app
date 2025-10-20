defmodule App.Annotations.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "annotations" do
    belongs_to :video, App.Videos.Video
    field :frame, :integer
    field :mouse_id, :integer
    field :bb_x1, :float
    field :bb_y1, :float
    field :bb_x2, :float
    field :bb_y2, :float
    field :nose_x, :float
    field :nose_y, :float
    field :earL_x, :float
    field :earL_y, :float
    field :earR_x, :float
    field :earR_y, :float
    field :tailB_x, :float
    field :tailB_y, :float

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(attrs, [
      :video_id,
      :frame,
      :mouse_id,
      :bb_x1,
      :bb_y1,
      :bb_x2,
      :bb_y2,
      :nose_x,
      :nose_y,
      :earL_x,
      :earL_y,
      :earR_x,
      :earR_y,
      :tailB_x,
      :tailB_y
    ])
  end
end
