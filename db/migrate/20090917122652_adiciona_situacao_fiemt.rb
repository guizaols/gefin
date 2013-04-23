class AdicionaSituacaoFiemt < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :situacao_fiemt, :integer
  end

  def self.down
    remove_column :recebimento_de_contas, :situacao_fiemt
  end
end
