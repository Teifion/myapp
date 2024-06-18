defmodule MyApp.Repo.Migrations.CreateUserTokens do
  use Ecto.Migration

  def change do
    create_if_not_exists table(:account_users, primary_key: false) do
      add(:id, :uuid, primary_key: true, null: false)
      add(:name, :string)
      add(:email, :string)
      add(:password, :string)

      add(:groups, {:array, :string})
      add(:permissions, {:array, :string})

      add(:trust_score, :integer)
      add(:behaviour_score, :integer)
      add(:social_score, :integer)

      add(:last_login_at, :utc_datetime)
      add(:last_logout_at, :utc_datetime)
      add(:last_played_at, :utc_datetime)

      add(:restrictions, {:array, :string}, default: [])
      add(:restricted_until, :utc_datetime)

      add(:shadow_banned?, :boolean, default: false)

      add(:smurf_of_id, references(:account_users, on_delete: :nothing, type: :uuid))

      timestamps()
    end

    execute "CREATE INDEX IF NOT EXISTS lower_username ON account_users (LOWER(name))"
    create_if_not_exists(unique_index(:account_users, [:email]))

    create_if_not_exists table(:account_extra_user_data, primary_key: false) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid),
        primary_key: true,
        type: :uuid
      )

      add(:data, :jsonb)
    end

    create table(:account_user_tokens) do
      add(:user_id, references(:account_users, on_delete: :nothing, type: :uuid), type: :uuid)

      add :identifier_code, :string
      add :renewal_code, :string

      add :context, :string
      add :user_agent, :string
      add :ip, :string

      add :expires_at, :utc_datetime
      add :last_used_at, :utc_datetime

      timestamps()
    end

    create index(:account_user_tokens, [:identifier_code])
    create index(:account_user_tokens, [:user_id])
  end
end
