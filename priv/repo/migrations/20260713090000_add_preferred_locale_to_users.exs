defmodule Plausible.Repo.Migrations.AddPreferredLocaleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :preferred_locale, :string, null: false, default: "fi"
    end
  end
end
