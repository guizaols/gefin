class Agencia < ActiveRecord::Base

  acts_as_audited

  #VALIDAÇÕES
  validates_presence_of :nome, :numero, :digito_verificador, :localidade, :banco, :message => "é inválido."
  validates_presence_of :entidade, :message => "é inválida."

  #RELACIONAMENTOS
  belongs_to :banco
  belongs_to :localidade

  has_many :pessoas
  has_many :convenios
  belongs_to :entidade
  has_many :conta_corrente

  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  cria_readers_e_writers_para_o_nome_dos_atributos :localidade, :banco
  
  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {
    :nome => "O campo nome",
    :numero => "O campo número",
    :digito_verificador => "O campo dígito verificador",
    :banco => "O campo banco",
    :localidade => "O campo localidade"
  }

  def initialize(attributes = {})
    attributes['ativo'] ||= true
    super
  end

  def nome_agencia
    "#{numero} - #{nome}"
  end

  def resumo
    nome_agencia
  end

  def self.importar_agencias(entidade_id, entidade_corrente_id)
    agencias = Agencia.find(:all, :conditions => ['entidade_id = ?', entidade_id])
    #validation = false
    begin
      Agencia.transaction do
        agencias.each do |agencia|
          verifica_agencia = Agencia.find_by_entidade_id_and_nome_and_numero(entidade_corrente_id, agencia.nome, agencia.numero)
          if verifica_agencia.blank?
            nova_agencia = agencia.clone
            nova_agencia.entidade_id = entidade_corrente_id
            nova_agencia.save!
            #validation = true
          end
        end
        #validation ? [true, 'Agências importadas com sucesso!'] : [true, 'Você está tentando importar dados já existentes!']
        [true, 'Agências importadas com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

end
