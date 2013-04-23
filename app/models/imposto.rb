class Imposto < ActiveRecord::Base

  acts_as_audited
  
  MUNICIPAL = 0
  ESTADUAL = 1
  FEDERAL = 2
  TIPOS_DE_ALIQUOTA = [MUNICIPAL, ESTADUAL, FEDERAL]
  TIPOS_DE_ALIQUOTA_VERBOSE = ['Municipal', 'Estadual', 'Federal']

  INCIDE = 0
  RETEM = 1
  CLASSIFICACOES_DAS_ALIQUOTAS = [INCIDE, RETEM]
  CLASSIFICACOES_DAS_ALIQUOTAS_VERBOSE = ['Incide', 'Retém']

  #VALIDAÇÕES
  validates_presence_of :entidade, :message => 'deve ser preenchido.'
  validates_presence_of :descricao, :message => 'deve ser preenchido.'
  validates_presence_of :sigla, :message => 'deve ser preenchido.'
  validates_presence_of :aliquota, :message => 'deve ser preenchido.'
  validates_presence_of :tipo, :message => 'deve ser preenchido.'
  validates_presence_of :classificacao, :message => 'deve ser preenchido.'
  validates_presence_of :conta_credito, :message => 'deve ser preenchido.'
  validates_presence_of :conta_debito, :message => 'deve ser preenchido.', :if => Proc.new {|imposto| imposto.classificacao == INCIDE}
  
  #RELACIONAMENTOS
  belongs_to :entidade
  belongs_to :conta_debito, :class_name => 'PlanoDeConta', :foreign_key => 'conta_debito_id'
  belongs_to :conta_credito, :class_name => 'PlanoDeConta', :foreign_key => 'conta_credito_id'
  
  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  attr_protected :entidade_id
  cria_readers_e_writers_para_o_nome_dos_atributos :conta_credito, :conta_debito

  HUMANIZED_ATTRIBUTES = {
    :descricao => 'O campo descrição',
    :sigla => 'O campo sigla',
    :aliquota => 'O campo alíquota',
    :tipo =>'O campo tipo',
    :classificacao => 'O campo classificação',
    :conta_credito => 'O campo conta crédito',
    :conta_debito =>'O campo conta débito',
  }

  def before_validation
    self.aliquota = aliquota_before_type_cast.real.to_f if self.aliquota
  end

  def tipo_de_aliquota_verbose
    TIPOS_DE_ALIQUOTA_VERBOSE[tipo] rescue ''
  end  
  
  def classificacoes_das_aliquotas_verbose
    CLASSIFICACOES_DAS_ALIQUOTAS_VERBOSE[classificacao] rescue ''
  end  
  
  def self.retorna_tipos_de_aliquota
    return [['Municipal', 0], ['Estadual', 1], ['Federal', 2]]
  end 

  def self.retorna_classificacoes_das_aliquotas
    return [['Incide', 0], ['Retém', 1]]
  end

end
