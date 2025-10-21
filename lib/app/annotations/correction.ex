defmodule App.Corrections.Correction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "corrections" do
    belongs_to :video, App.Videos.Video
    field :frame, :integer
    field :mouse_from, :integer
    field :mouse_to, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(correction, attrs) do
    correction
    |> cast(attrs, [:video_id, :frame, :mouse_from, :mouse_to])
    |> validate_required([:video_id, :frame, :mouse_from, :mouse_to])
    |> validate_mouse_ids()
    |> unique_constraint([:video_id, :frame, :mouse_from, :mouse_to])
  end

  def validate_mouse_ids(changeset) do
    if get_field(changeset, :mouse_from) == get_field(changeset, :mouse_to) do
      add_error(changeset, :mouse_to, "mouse_to must be different from mouse_from")
    else
      changeset
    end
  end
end
