defmodule App.Behavior.Annotation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "behavior_annotations" do
    belongs_to :video, App.Videos.Video
    field :frame, :integer
    field :mouse_id, :integer
    field :behavior, :string
    field :start_stop, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(annotation, attrs) do
    annotation
    |> cast(dbg(App.Utils.to_integers(attrs, ["frame", "mouse_id"])), [
      :video_id,
      :frame,
      :mouse_id,
      :behavior,
      :start_stop
    ])
    |> validate_required([:video_id, :frame, :mouse_id, :behavior, :start_stop], message: "error")
    |> unique_constraint([:video_id, :frame, :mouse_id, :behavior, :start_stop],
      name: :behavior_annotations_unique_index,
      error_key: :frame,
      message: "record already exists"
    )
  end
end
