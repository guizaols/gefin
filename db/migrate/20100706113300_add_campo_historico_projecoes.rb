class AddCampoHistoricoProjecoes < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :historico_projecoes, :string
  end

  def self.down
    remove_column :recebimento_de_contas, :historico_projecoes
  end
end
