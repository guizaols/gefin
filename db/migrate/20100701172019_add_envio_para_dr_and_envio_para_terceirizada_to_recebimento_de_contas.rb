class AddEnvioParaDrAndEnvioParaTerceirizadaToRecebimentoDeContas < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :envio_para_dr, :boolean
    add_column :recebimento_de_contas, :envio_para_terceirizada, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :envio_para_terceirizada
    remove_column :recebimento_de_contas, :envio_para_dr
  end
end
