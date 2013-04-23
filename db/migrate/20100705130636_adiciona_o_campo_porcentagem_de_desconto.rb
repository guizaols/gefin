class AdicionaOCampoPorcentagemDeDesconto < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :percentual_de_desconto, :integer
  end

  def self.down
    remove_column :parcelas, :percentual_de_desconto
  end
end
