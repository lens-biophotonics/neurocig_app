defmodule App.BehaviorTest do
  use App.DataCase

  alias App.Behavior

  describe "behavior_annotation" do
    alias App.Behavior.Annotation

    import App.BehaviorFixtures

    @invalid_attrs %{behavior: nil, frame: nil, mouse_id: nil}

    test "list_behavior_annotation/0 returns all behavior_annotation" do
      annotation = annotation_fixture()
      assert Behavior.list_behavior_annotation() == [annotation]
    end

    test "get_annotation!/1 returns the annotation with given id" do
      annotation = annotation_fixture()
      assert Behavior.get_annotation!(annotation.id) == annotation
    end

    test "create_annotation/1 with valid data creates a annotation" do
      valid_attrs = %{behavior: "some behavior", frame: 42, mouse_id: 42}

      assert {:ok, %Annotation{} = annotation} = Behavior.create_annotation(valid_attrs)
      assert annotation.behavior == "some behavior"
      assert annotation.frame == 42
      assert annotation.mouse_id == 42
    end

    test "create_annotation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Behavior.create_annotation(@invalid_attrs)
    end

    test "update_annotation/2 with valid data updates the annotation" do
      annotation = annotation_fixture()
      update_attrs = %{behavior: "some updated behavior", frame: 43, mouse_id: 43}

      assert {:ok, %Annotation{} = annotation} = Behavior.update_annotation(annotation, update_attrs)
      assert annotation.behavior == "some updated behavior"
      assert annotation.frame == 43
      assert annotation.mouse_id == 43
    end

    test "update_annotation/2 with invalid data returns error changeset" do
      annotation = annotation_fixture()
      assert {:error, %Ecto.Changeset{}} = Behavior.update_annotation(annotation, @invalid_attrs)
      assert annotation == Behavior.get_annotation!(annotation.id)
    end

    test "delete_annotation/1 deletes the annotation" do
      annotation = annotation_fixture()
      assert {:ok, %Annotation{}} = Behavior.delete_annotation(annotation)
      assert_raise Ecto.NoResultsError, fn -> Behavior.get_annotation!(annotation.id) end
    end

    test "change_annotation/1 returns a annotation changeset" do
      annotation = annotation_fixture()
      assert %Ecto.Changeset{} = Behavior.change_annotation(annotation)
    end
  end

  describe "type_strings" do
    alias App.Behavior.TypeString

    import App.BehaviorFixtures

    @invalid_attrs %{type_string: nil}

    test "list_type_strings/0 returns all type_strings" do
      type_string = type_string_fixture()
      assert Behavior.list_type_strings() == [type_string]
    end

    test "get_type_string!/1 returns the type_string with given id" do
      type_string = type_string_fixture()
      assert Behavior.get_type_string!(type_string.id) == type_string
    end

    test "create_type_string/1 with valid data creates a type_string" do
      valid_attrs = %{type_string: "some type_string"}

      assert {:ok, %TypeString{} = type_string} = Behavior.create_type_string(valid_attrs)
      assert type_string.type_string == "some type_string"
    end

    test "create_type_string/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Behavior.create_type_string(@invalid_attrs)
    end

    test "update_type_string/2 with valid data updates the type_string" do
      type_string = type_string_fixture()
      update_attrs = %{type_string: "some updated type_string"}

      assert {:ok, %TypeString{} = type_string} = Behavior.update_type_string(type_string, update_attrs)
      assert type_string.type_string == "some updated type_string"
    end

    test "update_type_string/2 with invalid data returns error changeset" do
      type_string = type_string_fixture()
      assert {:error, %Ecto.Changeset{}} = Behavior.update_type_string(type_string, @invalid_attrs)
      assert type_string == Behavior.get_type_string!(type_string.id)
    end

    test "delete_type_string/1 deletes the type_string" do
      type_string = type_string_fixture()
      assert {:ok, %TypeString{}} = Behavior.delete_type_string(type_string)
      assert_raise Ecto.NoResultsError, fn -> Behavior.get_type_string!(type_string.id) end
    end

    test "change_type_string/1 returns a type_string changeset" do
      type_string = type_string_fixture()
      assert %Ecto.Changeset{} = Behavior.change_type_string(type_string)
    end
  end
end
