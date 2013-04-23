class Compromisso < ActiveRecord::Base

  extend BuscaExtendida
  acts_as_audited

  #RELACIONAMENTOS  
  belongs_to :unidade  
  belongs_to :conta, :polymorphic => true

  #VALIDAÇOES  
  validates_presence_of :conta, :message => "deve ser preenchido."
  validates_presence_of :unidade, :message => "deve ser preenchido."
  validates_presence_of :descricao, :data_agendada, :message => "deve ser preenchido."

  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES 
  data_br_field :data_agendada
  converte_para_data_para_formato_date :data_agendada, :message => "deve ser preenchido."
  attr_protected :unidade_id
  attr_accessor :current_usuario

  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {
    :conta => 'O campo conta',
    :descricao =>'O campo descrição',
    :data_agendada =>'O campo data do agendamento',
    :unidade => 'O campo unidade',
  }

  def after_create
    HistoricoOperacao.cria_follow_up("Criado compromisso '#{self.descricao}'", self.current_usuario, self.conta)
  end

  def self.retorna_tipos_de_parametro 
    return   ['Cliente Negativado no SPC','Contrato Enviado ao Jurídico','Enviar Carta Cobrança 1',
      'Enviar Carta de Cobrança 2','Enviar Carta Jurídica','Ligar para o Cliente',
      'Promessa de Pagto para essa data','Retornar Ligação','Solicitado a Unidade Negativação no SPC',
      'Título Apontado em Cartório','Virá Negociar Débitos em Atraso']
  end

  def self.pesquisa_agendamentos(contar_ou_retornar,unidade_id,params)
    @sqls = []; @variaveis = []
    @sqls << "(compromissos.unidade_id = ?)"; @variaveis << unidade_id
    @sqls << '(pessoas.id = ?) AND (pessoas.cliente = true)'
    if !params['nome_cliente'].blank?
      @variaveis << params['cliente_id'].to_i
    else
      @variaveis << params['nome_cliente']
    end
    unless params['periodo_min'].blank? && params['periodo_max'].blank?
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'compromissos.data_agendada'
    end
    Compromisso.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa})
  end

  def nome_conta
    self.conta.numero_de_controle.to_s rescue ''
  end
end
