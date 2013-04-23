class AddPorcentagemMultaEPorcentagemJurosToParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :porcentagem_multa, :float
    add_column :parcelas, :porcentagem_juros, :float
  end

  def self.down
     remove_column :parcelas, :porcentagem_multa
     remove_column :parcelas, :porcentagem_juros
  end
end
