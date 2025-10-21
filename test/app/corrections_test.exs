defmodule App.CorrectionsTest do
  use App.DataCase

  alias App.Corrections

  describe "corrections" do
    alias App.Corrections.Correction

    import App.CorrectionsFixtures

    @invalid_attrs %{frame: nil, mouse_from: nil, mouse_to: nil}

    test "list_corrections/0 returns all corrections" do
      correction = correction_fixture()
      assert Corrections.list_corrections() == [correction]
    end

    test "get_correction!/1 returns the correction with given id" do
      correction = correction_fixture()
      assert Corrections.get_correction!(correction.id) == correction
    end

    test "create_correction/1 with valid data creates a correction" do
      valid_attrs = %{frame: 42, mouse_from: 42, mouse_to: 42}

      assert {:ok, %Correction{} = correction} = Corrections.create_correction(valid_attrs)
      assert correction.frame == 42
      assert correction.mouse_from == 42
      assert correction.mouse_to == 42
    end

    test "create_correction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Corrections.create_correction(@invalid_attrs)
    end

    test "update_correction/2 with valid data updates the correction" do
      correction = correction_fixture()
      update_attrs = %{frame: 43, mouse_from: 43, mouse_to: 43}

      assert {:ok, %Correction{} = correction} =
               Corrections.update_correction(correction, update_attrs)

      assert correction.frame == 43
      assert correction.mouse_from == 43
      assert correction.mouse_to == 43
    end

    test "update_correction/2 with invalid data returns error changeset" do
      correction = correction_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Corrections.update_correction(correction, @invalid_attrs)

      assert correction == Corrections.get_correction!(correction.id)
    end

    test "delete_correction/1 deletes the correction" do
      correction = correction_fixture()
      assert {:ok, %Correction{}} = Corrections.delete_correction(correction)
      assert_raise Ecto.NoResultsError, fn -> Corrections.get_correction!(correction.id) end
    end

    test "change_correction/1 returns a correction changeset" do
      correction = correction_fixture()
      assert %Ecto.Changeset{} = Corrections.change_correction(correction)
    end
  end
end
