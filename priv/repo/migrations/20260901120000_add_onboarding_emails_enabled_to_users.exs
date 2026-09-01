defmodule Plausible.Repo.Migrations.AddOnboardingEmailsEnabledToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :onboarding_emails_enabled, :boolean, null: false, default: false
    end
  end
end
