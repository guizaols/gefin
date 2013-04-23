class AdicionaParcelaMaeEmParcela < ActiveRecord::Migration
  def self.up
      add_column :parcelas, :parcela_mae_id, :integer
      add_column :parcelas, :numero_parcela_filha, :string
  end

  def self.down
    remove_column :parcelas, :parcela_mae_id
    remove_column :parcelas, :numero_parcela_filha
  end
end
