class Historico < ActiveRecord::Base

  acts_as_audited

  #VALIDAÇÕES
  validates_presence_of :descricao, :message => 'é inválido.'
  validates_presence_of :entidade, :message => 'é inválida.'
  
  #RELACIONAMENTOS
  belongs_to :entidade

  #CONSTANTES
  HUMANIZED_ATTRIBUTES = { :descricao => 'O campo descrição', :entidade => 'O campo entidade' }
  
end
