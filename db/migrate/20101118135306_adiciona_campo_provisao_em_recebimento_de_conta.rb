class AdicionaCampoProvisaoEmRecebimentoDeConta < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :provisao, :integer
  end

  def self.down
    remove_column :recebimento_de_contas, :provisao
  end
end
