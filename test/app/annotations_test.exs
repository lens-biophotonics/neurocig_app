defmodule App.AnnotationsTest do
  use App.DataCase

  alias App.Annotations

  describe "annotations" do
    alias App.Annotations.Annotation

    import App.AnnotationsFixtures

    @invalid_attrs %{frame_id: nil}

    test "list_annotations/0 returns all annotations" do
      annotation = annotation_fixture()
      assert Annotations.list_annotations() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert Annotations.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      valid_attrs = %{frame_id: 42}

      assert {:ok, %Annotation{} = annotation} = Annotations.create_annotation(valid_attrs)
      assert annotation.frame_id == 42
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Annotations.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()
      update_attrs = %{frame_id: 43}

      assert {:ok, %Annotation{} = annotation} = Annotations.update_annotation(annotation, update_attrs)
      assert annotation.frame_id == 43
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()
      assert {:error, %Ecto.Changeset{}} = Annotations.update_annotation(annotation, @invalid_attrs)
      assert annotation == Annotations.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = Annotations.delete_annotation(annotation)
      assert_raise Ecto.NoResultsError, fn -> Annotations.get_annotation!(annotation.id) end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = Annotations.change_annotation(annotation)
    end
  end
end
