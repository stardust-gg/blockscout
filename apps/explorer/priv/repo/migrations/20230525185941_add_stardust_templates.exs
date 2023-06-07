defmodule Explorer.Repo.Migrations.AddStardustTemplates do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add(:name, :string)
      add(:symbol, :string, null: true)
      add(:cap, :decimal, default: 0)
      add(:game_id, :decimal)
      add(:circulating_supply, :decimal, default: 0)
    end

    alter table(:token_instances) do
      add(:template_id, references(:templates, on_delete: :nothing), null: true)
      add(:image_url, :string, null: true)
    end

    create index(:token_instances, [:template_id])
    create index(:templates, [:circulating_supply])
  end
end
