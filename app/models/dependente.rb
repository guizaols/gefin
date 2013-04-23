class Dependente < ActiveRecord::Base

  acts_as_audited
  
  #VALIDAÇÕES
  validates_presence_of :nome, :pessoa, :message => 'deve ser preenchido'
  validates_presence_of :nome_do_pai, :nome_da_mae, :message => 'deve ser preenchido', :if => Proc.new{|d| d.pessoa && d.pessoa.tipo_pessoa == Pessoa::FISICA}
  validates_presence_of :data_de_nascimento, :message => 'deve ser preenchido'

  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  data_br_field :data_de_nascimento
  converte_para_data_para_formato_date :data_de_nascimento

  #RELACIONAMENTOS
  belongs_to :pessoa
  
  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {
    :nome_da_mae => "O campo nome da mãe",
    :nome_do_pai => "O campo nome do pai",
    :nome => "O campo dependente"
  }
  
  def resumo
    nome
  end
  
end
