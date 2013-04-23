class AdicionaCampoProjetandoEmRecebimentoDeConta < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :projetando, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :projetando
  end
end
