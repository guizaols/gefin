class Convenio < ActiveRecord::Base

  SIMPLES = 1
  VINCULADA = 2
  REGISTRADA = 3
  DESCONTADA = 4
  DIRETA_ESPECIAL = 5

  ATIVO = 1
  INATIVO = 2

  COBRANCA = 1
  PAGAMENTO = 2

  TIPOS_DE_DOCUMENTO = [['CPMF','CPMF'],
    ['SERVIÇOS EDUCACIONAIS - CONTRATO RECEBIMENTO','CTRSE'],
    ['SERVIÇOS TEC. TECNOLÓGICOS - CONTRATO RECEBIMENTO','CTRST'],
    ['CHPRE - CHEQUE PRÉ-DATADO','CHPRE'],
    ['CTP - CONTRATO - PAGAMENTO','CTP'],
    ['CTR - CONTRATO - RECEBIMENTO','CTR'],
    ['CTREV - EVENTOS - CONTRATO RECEBIMENTO','CTREV'],
    ['DESPESAS BANCÁRIAS ','DB'],
    ['NF - NOTA FISCAL','NF'],
    ['NFS - NOTA FISCAL DE SERVIÇOS','NFS'],
    ['NTE - NUMERÁRIO EM TRÂNSITO ENTRADA','NTE'],
    ['NTS - NUMERÁRIO EM TRÂNSITO SAÍDA','NTS'],
    ['OP - ORDEM PAGAMENTO','OP'],
    ['OR - ORDEM RECEBIMENTO','OR'],
    ['RPA - RECIBO PAGAMENTO AUTÔNOMO','RPA'],
    ['TRE - TRANSFERÊNCIAS ENTRE CONTAS - ENTRADA','TRE'],
    ['TRS - TRANSFERÊNCIAS ENTRE CONTAS - SAÍDAS','TRS'],
    ['CTRC - CONHECIMENTO TRANSP. RODOV. CARGAS','CTRC']]

  belongs_to :contas_corrente, :foreign_key => 'contas_corrente_id'
  belongs_to :banco
  belongs_to :agencia
  belongs_to :servico
  has_many :arquivo_remessas

  attr_accessor :novo_tipo_de_servico
  before_validation :criar_novo_tipo_de_servico
  #validates_presence_of :numero, :tipo_de_servico, :quantidade_de_trasmissao
  validates_inclusion_of :quantidade_de_trasmissao, :in => 1..2
  validates_inclusion_of :tipo_convenio, :in => [COBRANCA, PAGAMENTO]
  validates_inclusion_of :tipo_convenio_boleto, :in => [SIMPLES, VINCULADA, REGISTRADA, DESCONTADA, DIRETA_ESPECIAL]
  validates_inclusion_of :situacao, :in => [ATIVO,INATIVO]
  validates_presence_of :contas_corrente_id#, :if => :convenio_pagamento?
  validates_uniqueness_of :numero
  cria_readers_e_writers_para_o_nome_dos_atributos :servico, :banco, :agencia, :contas_corrente
  serialize :instrucoes
  
  #    add_column :convenios, :ident_distribuicao,:integer
  #    add_column :convenios, :ident_aceite, :integer


  HUMANIZED_ATTRIBUTES = {
    :indicativo_sacador=>"O campo indicativo de sacador",
    :local_pagamento=>"O campo local de pagamento",
    :instrucoes=>"O campo instruções",
    :reservado_empresa=>"O campo reservado da empresa",
    :numero_convenio_banco=>"O campo número do convênio do banco",
    :numero_bordero=>"O campo número do borderô",
    :cod_operacao=>"O campo código operação",
    :cod_respons=>"O campo código respons",
    :tipo_convenio_boleto=>"O campo tipo convênio de boleto",
    :local_emissao_documento=>"O campo local de emissão do documento",
    :numero => "O campo número",
    :tipo_de_servico => "O campo tipo de serviço",
    :quantidade_de_trasmissao => "O campo quantidade de trasmissão",
    :tipo_convenio=>"O campo tipo convênio",
    :banco_id=>"O campo banco",
    :agencia_id=>"O campo agência",
    :servico_id=>"O campo serviço",
    :situacao=>"O campo situação",
    :data_registro=>"O campo data registro",
    :numero_carteira=>"O campo número carteira",
    :variacao_carteira=>"O campo variação carteira",
    :tipo_documento=>"O campo tipo de documento",
    :contas_corrente_id => 'O campo conta corrente'
  }

  def criar_novo_tipo_de_servico
    self.tipo_de_servico = novo_tipo_de_servico unless novo_tipo_de_servico.blank?
  end

  def before_validation
    self.instrucoes.reject!(&:blank?)
  end

  def initialize(attributes = {})
    attributes["data_registro"] ||= Date.today.to_s_br
    super
  end

  def instrucoes
    super || []
  end

  def convenio_pagamento?
    self.tipo_convenio == PAGAMENTO
  end

  def tipo_convenio_verbose
    case tipo_convenio
    when PAGAMENTO; 'Pagamento'
    when COBRANCA; 'Cobrança'
    end
  end

end
