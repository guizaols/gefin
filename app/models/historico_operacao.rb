class HistoricoOperacao < ActiveRecord::Base

  acts_as_audited

  CARTA_COBRANCA_30_DIAS = 1
  CARTA_COBRANCA_60_DIAS = 2
  CARTA_COBRANCA_90_DIAS = 3
  CARTA_PROMOCIONAL = 4

  belongs_to :conta, :polymorphic => true
  belongs_to :usuario
  belongs_to :movimento
  validates_presence_of :conta, :message => 'é inválido', :if => Proc.new{|obj| !obj.conta.blank? }
  validates_presence_of :movimento, :message => 'é inválido', :if => Proc.new{|obj| !obj.movimento.blank? }
  validates_presence_of :usuario, :message => 'é inválido'
  validates_presence_of :descricao, :message => 'deve ser preenchido'

  def numero_carta_cobranca_verbose
    case numero_carta_cobranca
    when nil; 'Nenhuma'
    when CARTA_COBRANCA_30_DIAS; 'Carta de cobrança de 30 dias'
    when CARTA_COBRANCA_60_DIAS; 'Carta de cobrança de 60 dias'
    when CARTA_COBRANCA_90_DIAS; 'Carta de cobrança de 90 dias'
    when CARTA_PROMOCIONAL; 'Carta promocional'
    end
  end

  HUMANIZED_ATTRIBUTES = {
    :descricao => 'O campo descrição'
  }

  def self.cria_follow_up(descricao, usuario_corrente, conta = nil, justificativa = nil, numero_carta = nil, valor = nil, movimento = nil)
    historico_operacao = HistoricoOperacao.new(:descricao => descricao, :usuario => usuario_corrente, :conta => conta,
      :justificativa => justificativa, :numero_carta_cobranca => numero_carta, :valor => valor, :movimento => movimento)
    historico_operacao.save!
  end

end
