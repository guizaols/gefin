class Banco < ActiveRecord::Base

  acts_as_audited

  #VALIDAÇÕES
  validates_presence_of :descricao,:message=>"é inválido."
  validates_presence_of :codigo_do_banco,:message=>"deve ser preenchido"
  
  #RELACIONAMENTOS
  has_many :agencias,:dependent=>:destroy
  has_many :cheques
  has_many :pessoas
  has_many :convenios
  
  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  attr_accessor :mensagem_de_erro
  
  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {
    :descricao => "O campo descrição",
    :codigo_do_banco => "O campo código do banco"
  }
  
  def initialize(attributes = {})
    attributes['ativo'] ||= true
    super
  end
  
  def before_destroy
    if !self.agencias.blank?
      self.mensagem_de_erro = "Não foi possível excluir, pois #{self.descricao} possui agências vinculadas."
      return false
    end
  end
  
  def nome_banco
    "#{codigo_do_banco} - #{descricao}"
  end

  def resumo
    nome_banco
  end

end
