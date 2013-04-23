class AdicionaCampoVigenciaEmRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas,:vigencia,:integer
  end

  def self.down
    remove_column :recebimento_de_contas,:vigencia
  end
end
