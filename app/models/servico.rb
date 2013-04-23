class Servico < ActiveRecord::Base

  acts_as_audited

  validates_presence_of :descricao, :unidade, :modalidade, :message => "deve ser preenchido"
  belongs_to :unidade
  attr_accessor :novo_modalidade, :mensagem_de_erro
  before_validation :criar_nova_modalidade
  attr_protected :unidade_id
  has_many :convenios

  HUMANIZED_ATTRIBUTES = {
    :descricao => "O campo descrição",
    :modalidade => "O campo modalidade",
    :unidade_id => "O campo unidade"
  }

  def before_destroy
    if possui_algum_contrato?
      self.mensagem_de_erro = "Não foi possível excluir o serviço #{self.descricao.upcase}, pois existem contratos vinculados à ele."
      return false
    end
  end

  def possui_algum_contrato?
    conta_a_receber = RecebimentoDeConta.all :conditions => ["servico_id = ?", self.id]
    conta_a_receber.blank? ? false : true
  end

  def criar_nova_modalidade
    self.modalidade = novo_modalidade unless novo_modalidade.blank?
  end
  
  def initialize(attributes = {})
    attributes['ativo'] ||= true
    super
  end

  def resumo
    descricao
  end

end
