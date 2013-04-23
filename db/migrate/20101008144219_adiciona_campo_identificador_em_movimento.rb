class AdicionaCampoIdentificadorEmMovimento < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :lancamento_inicial, :boolean
  end

  def self.down
    remove_column :movimentos, :lancamento_inicial
  end
end
