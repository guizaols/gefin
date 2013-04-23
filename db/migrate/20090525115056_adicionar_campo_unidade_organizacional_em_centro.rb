class AdicionarCampoUnidadeOrganizacionalEmCentro < ActiveRecord::Migration
  def self.up
    add_column :centros, :unidade_organizacional_id, :integer
  end

  def self.down
    remove_column :centros, :unidade_organizacional_id
  end
end
