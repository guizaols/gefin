class AdicionaCampoLiberacaoDrFaixaDeDiasPermitidoEmPagamentoRecebimentoMovimento < ActiveRecord::Migration
  def self.up
    add_column :recebimento_de_contas, :liberacao_dr_faixa_de_dias_permitido, :boolean
    add_column :pagamento_de_contas, :liberacao_dr_faixa_de_dias_permitido, :boolean
    add_column :movimentos, :liberacao_dr_faixa_de_dias_permitido, :boolean
  end

  def self.down
    remove_column :recebimento_de_contas, :liberacao_dr_faixa_de_dias_permitido
    remove_column :pagamento_de_contas, :liberacao_dr_faixa_de_dias_permitido
    remove_column :movimentos, :liberacao_dr_faixa_de_dias_permitido
  end
end
