class AddArquivRemessaIdToParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :arquivo_remessa_id, :integer
  end

  def self.down
    remove_column :parcelas, :arquivo_remessa_id
  end
end
