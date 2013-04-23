class Localidade < ActiveRecord::Base

  #acts_as_audited

  #CONSTANTES 
  ESTADOS = {'AC' => 'ACRE', 'AL' => 'ALAGOAS', 'AP' => 'AMAPÁ', 'AM' => 'AMAZONAS', 'BA' => 'BAHIA', 'CE' => 'CEARÁ', 
    'DF' => 'DISTRITO FEDERAL', 'GO' => 'GOIÁS', 'ES' => 'ESPÍRITO SANTO', 'MA' => 'MARANHÃO', 'MT' => 'MATO GROSSO', 
    'MS' => 'MATO GROSSO DO SUL', 'MG' => 'MINAS GERAIS', 'PA' => 'PARÁ', 'PB' => 'PARAÍBA', 'PR' => 'PARANÁ', 
    'PE' => 'PERNAMBUCO', 'PI' => 'PIAUÍ', 'RJ' => 'RIO DE JANEIRO', 'RN' => 'RIO GRANDE DO NORTE', 'RS' => 'RIO GRANDE DO SUL',
    'RO' => 'RONDÔNIA', 'RR' => 'RORAIMA', 'SP' => 'SÃO PAULO', 'SC' => 'SANTA CATARINA', 'SE' => 'SERGIPE', 'TO' => 'TOCANTINS'}
  HUMANIZED_ATTRIBUTES = { :uf => 'UF' }
  
  #VALIDAÇÕES
  validates_presence_of :nome, :message => "deve ser preenchido."
  validates_inclusion_of :uf, :in => Localidade::ESTADOS.keys.sort, :message => "não está incluído na lista."
  
  #RELACIONAMENTOS
  has_many :unidades
  has_many :pessoas
  has_many :agencias
  
  #ATRIBUTOS VIRTUAIS
  attr_accessor :mensagem_de_erro
  
  def self.retorna_estados_como_array
    Localidade::ESTADOS.collect { |key, value| ["#{value} - #{key}", key]}.sort
  end
  
  def nome_localidade
    "#{nome} - #{uf}"
  end
  
  def before_destroy
    self.mensagem_de_erro = []
    if !self.unidades.blank?
      self.mensagem_de_erro << "* Não foi possível excluir, pois esta localidade está vinculada a UNIDADES"
    end
    if !self.pessoas.blank?
      self.mensagem_de_erro << "* Não foi possível excluir, pois esta localidade está vinculada a PESSOAS"
    end
    if !self.agencias.blank?
      self.mensagem_de_erro << "* Não foi possível excluir, pois esta localidade está vinculada a AGÊNCIAS"
    end
    return false unless self.mensagem_de_erro.blank?
  end  

  def resumo
    nome_localidade
  end
  
end
