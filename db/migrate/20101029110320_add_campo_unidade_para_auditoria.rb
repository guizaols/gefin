class AddCampoUnidadeParaAuditoria < ActiveRecord::Migration
  def self.up
    add_column :audits, :unidade_id, :integer
  end

  def self.down
    remove_column :audits, :unidade_id
  end
end
