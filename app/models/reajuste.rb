class Reajuste < ActiveRecord::Base

  acts_as_audited

  #RELACIONAMENTOS
  belongs_to :conta, :polymorphic => true
  belongs_to :usuario

  #VALIDAÇOES
  validates_presence_of :conta, :message => 'deve ser preenchido.'
  validates_presence_of :usuario, :message => 'deve ser preenchido.'
  validates_presence_of :valor_reajuste, :message => 'deve ser preenchido.'
  validates_presence_of :data_reajuste, :message => 'deve ser preenchido.'

  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  data_br_field :data_reajuste
  converte_para_data_para_formato_date :data_reajuste, :message => 'deve ser preenchida.'
  attr_accessor :current_usuario

  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {
    :conta => 'O campo conta',
    :valor_reajuste => 'O campo valor do reajuste',
    :data_reajuste => 'O campo data do agendamento',
    :usuario => 'O campo usuário'
  }

  def initialize(params = {})
    super
    self.conta_type = 'RecebimentoDeConta'
  end

  def validate
    if self.conta.reajustes.length > self.conta.unidade.numero_de_reajustes
      errors.add :base, '* O número de reajustes ultrapassou o estabelecido nas configurações do sistema'
    end
  end

end
