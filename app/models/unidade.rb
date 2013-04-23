class Unidade < ActiveRecord::Base

  #VALIDAÇÕES 
  validates_presence_of :entidade, :nome_caixa_zeus, :message => "deve ser preenchido."
  validates_presence_of :nome, :senha_baixa_dr, :message => "deve ser preenchido."
  validates_presence_of :sigla, :message => "deve ser preenchido."
  validates_numericality_of :limitediasparaestornodeparcelas, :lancamentoscontaspagar ,:lancamentoscontasreceber,:lancamentosmovimentofinanceiro, :greater_than_or_equal_to => 0, :message => 'deve ser preenchido e ser maior ou igual a zero.'
  usar_como_cnpj :cnpj

  #RELACIONAMENTOS
  has_many :servicos
  has_many :arquivo_remessas
  has_many :parametro_conta_valores
  has_many :contas_corrente
  has_many :compromissos    
  has_many :usuarios
  has_many :pagamento_de_contas
  has_many :pessoas
  belongs_to :unidade_organizacional
  has_one :unidade_filha, :class_name => 'Unidade', :foreign_key => 'unidade_mae_id'
  belongs_to :unidade_mae, :class_name => 'Unidade'
  belongs_to :entidade
  belongs_to :localidade

  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  attr_accessor :mensagem_de_erro, :nome_unidade_organizacional
  serialize :telefone
  serialize :dr_telefone
  data_br_field :data_de_referencia, :data_limite_minima, :data_limite_maxima
  converte_para_data_para_formato_date :data_de_referencia, :data_limite_minima, :data_limite_maxima
  cria_readers_e_writers_para_o_nome_dos_atributos :localidade, :unidade_organizacional

  SIM = 1
  NAO = 2

  HUMANIZED_ATTRIBUTES = {
    :entidade_id => 'O campo entidade', 
    :nome => 'O campo nome',
    :nome_caixa_zeus => 'O campo Nome do Caixa Zeus',
    :sigla =>'O campo sigla',
    :lancamentoscontaspagar => 'O campo lançamento de contas a pagar',
    :lancamentoscontasreceber => 'O campo lançamento de contas a receber',
    :lancamentosmovimentofinanceiro => 'O campo lançamento de movimento financeiro',
    :limitediasparaestornodeparcelas => 'O campo de limite para o estorno de parcelas',
    :senha_baixa_dr => 'O campo senha para baixa DR',
    :convenio => 'O campo convenio',
    :data_limite_minima => 'O campo data miníma para cadastro de registros',
    :data_limite_maxima => 'O campo data máxima para cadastro de registros',
    :nome_cedente => 'O campo nome do cedente',
    :unidade_organizacional => 'O campo unidade organizacional',
    :contabilizacao_agendada => 'O campo contabilização agendada'
  }

  def initialize(attributes = {})
    super
    self.lancamentoscheques = 5
    self.lancamentoscartoes = 5
    self.lancamentoscontaspagar = 5
    self.lancamentoscontasreceber = 5
    self.lancamentosmovimentofinanceiro = 5
    self.limitediasparaestornodeparcelas = 5
    self.dr_nome = "Preencher"
    self.dr_email = "Preencher"
    self.dr_fax = "Preencher"
    self.dr_telefone  = ["Preencher"]
    self.senha_baixa_dr = 'teste'
    if attributes.blank?
      self.ativa = true
      self.data_de_referencia = Date.today
    end
  end

  def before_destroy
    if !self.pagamento_de_contas.blank?
      self.mensagem_de_erro = "Não foi possível excluir, pois a unidade #{self.nome} possui contas a pagar vinculadas"
      return false
    end
  end

  def validate
    errors.add :nome_cedente, 'deve possuir menos de 75 caracteres' if !self.nome_cedente.blank? && self.nome_cedente.size > 75
    valida_datas_limites
  end

  def telefone
    super || []
  end
  
  def before_validation
    self.dr_telefone.reject!(&:blank?)
    self.telefone.reject!(&:blank?)
  end

  def self.retorna_unidade_para_select
    Unidade.all(:order => 'nome ASC').collect{|unidade| [unidade.nome, unidade.id]}
  end

  def self.retorna_unidade_para_select_com_entidade(usuario)
    entidade_usuario_id = usuario.entidade_id
    unless entidade_usuario_id.blank?
     # Unidade.find(:all, :conditions => ['entidade_id = ?', entidade_usuario_id], :order => 'nome ASC').collect{|unidade| [unidade.nome, unidade.id]}
   
    Unidade.find(:all, :conditions => ['entidade_id = ? AND unidade_mae_id  IS NULL', entidade_usuario_id], :order => 'nome ASC').collect{|unidade| [unidade.nome, unidade.id]}
   
    else
     # Unidade.all(:order => 'nome ASC').collect{|unidade| [unidade.nome, unidade.id]}
      Unidade.all(:conditions=>['unidade_mae_id  IS NULL'],:order => 'nome ASC').collect{|unidade| [unidade.nome, unidade.id]}
    end
  end

  def nome_unidade
    "#{nome}"
  end

  def resumo
    nome_unidade
  end

  def verifica_senha_dr(senha)
    self.senha_baixa_dr == senha ? true : false
  end

  def valida_datas_limites
    if self.data_limite_minima.blank? && !self.data_limite_maxima.blank?
      errors.add :data_limite_minima, "deve ser preenchido"
    elsif !self.data_limite_minima.blank? && self.data_limite_maxima.blank?
      errors.add :data_limite_maxima, "deve ser preenchido"
    elsif !self.data_limite_minima.blank? && !self.data_limite_maxima.blank?
      if self.data_limite_minima.to_date > self.data_limite_maxima.to_date
        errors.add :data_limite_maxima, "deve ser maior do que a data miníma para cadastro de registros registros"
      end
    end
  end

  def parametro_conta_valor_cliente(ano)
    ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::CLIENTES, :unidade_id => self.id, :ano => ano}
  end

  def parametro_conta_valor_fornecedor(ano)
    ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::FORNECEDOR, :unidade_id => self.id, :ano => ano}
  end

  def parametro_conta_valor_faturamento(ano)
    ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::FATURAMENTO, :unidade_id => self.id, :ano => ano}
  end

  def parametro_conta_valor_juros_multas_renegociados(ano)
    ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::JUROS_E_MULTAS_DE_CONTRATOS_RENEGOCIADOS, :unidade_id => self.id, :ano => ano}
  end

  def parametro_conta_valor_pessoa_fisica(ano)
    ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::DESCONTO_PF, :unidade_id => self.id, :ano => ano}
  end

  def parametro_conta_valor_pessoa_juridica(ano)
    ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::DESCONTO_PJ, :unidade_id => self.id, :ano => ano}
  end

  def parametro_conta_valor_cartoes(ano, bandeira)
    case bandeira
    when Cartao::VISACREDITO
      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_VISACREDITO, :unidade_id => self.id, :ano => ano}
    when Cartao::REDECARD
      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_REDECARD, :unidade_id => self.id, :ano => ano}
    when Cartao::MASTERCARD
      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_MASTERCARD, :unidade_id => self.id, :ano => ano}
      #    when Cartao::DINERS
      #      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_DINERS, :unidade_id => self.id, :ano => ano}
    when Cartao::AMERICANEXPRESS
      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_AMERICANEXPRESS, :unidade_id => self.id, :ano => ano}
    when Cartao::MAESTRO
      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_MAESTRO, :unidade_id => self.id, :ano => ano}
      #    when Cartao::CREDICARD
      #      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_CREDICARD, :unidade_id => self.id, :ano => ano}
      #    when Cartao::OUROCARD
      #      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_OUROCARD, :unidade_id => self.id, :ano => ano}
    when Cartao::VISADEBITO
      ParametroContaValor.first :conditions => {:tipo => ParametroContaValor::PARAMETRO_VISADEBITO, :unidade_id => self.id, :ano => ano}
    end
  end

end
