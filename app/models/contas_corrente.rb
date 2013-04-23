class ContasCorrente < ActiveRecord::Base  

  acts_as_audited

  CAIXA = 0
  BANCO = 1

  #RELACIONAMENTOS
  belongs_to :agencia
  belongs_to :unidade
  belongs_to :conta_contabil, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_id"
  has_many :convenios
  has_many :arquivo_remessas

  #VALIDAÇÕES
  validates_presence_of :descricao, :unidade, :conta_contabil, :message => "é inválido."
  validates_inclusion_of :identificador, :in => [BANCO, CAIXA],:message => "é inválido."
  validates_presence_of :agencia, :message => "é inválido.", :if => :conta_em_banco?
  validates_numericality_of :numero_conta, :if => :conta_em_banco?, :message => 'é inválido.'
  validates_length_of :digito_verificador, :is => 1, :if => :conta_em_banco?, :message => "é inválido."
 
  #ATRIBUTOS VIRTUAIS E FORMATAÇÕES
  attr_accessor :saldo_inicial_em_reais, :saldo_atual_em_reais, :nome_identificador
  data_br_field :data_abertura, :data_encerramento
  converte_para_data_para_formato_date :data_abertura, :data_encerramento
  cria_readers_e_writers_para_valores_em_dinheiro :saldo_inicial, :saldo_atual
  cria_readers_e_writers_para_o_nome_dos_atributos :unidade, :agencia, :conta_contabil

  def conta_em_banco?
    identificador == BANCO
  end

  def self.tipos
    [['Banco', BANCO], ['Caixa', CAIXA]]
  end
  
  HUMANIZED_ATTRIBUTES = {
    :numero_conta => "O campo número da conta",
    :digito_verificador => "O campo dígito verificador",
    :descricao => "O campo descrição",
    :unidade => "O campo unidade",
    :agencia => "O campo agência",
    :identificador => "O campo identificador",
    :conta_contabil => "O campo conta contábil"
  }
  
  def initialize(attributes = {})
    attributes['ativo'] ||= true
    attributes['data_abertura'] ||= Date.today
    super   
  end

  def validate
    errors.add :saldo_inicial, "deve ser maior do que zero." if self.saldo_inicial && self.saldo_inicial <= 0
  end
  
  def resumo_conta_corrente
    identificador == BANCO ? "#{self.numero_conta}-#{self.digito_verificador} - #{self.descricao}" : "#{self.descricao}"
  end

  def resumo
    resumo_conta_corrente
  end
  
  def nome_identificador
    if self.identificador == BANCO
      "Banco"
    elsif self.identificador == CAIXA
      "Caixa"
    end
  end

  def verifica_saldo(params, unidade_id)
    @sqls = ['(contas_correntes.id = ?) AND (movimentos.unidade_id = ?)']; @variaveis = [self.id, unidade_id]
    (@sqls << '(itens_movimentos.tipo = ?)'; @variaveis << params['tipo']) unless params['tipo'].blank?
    (@sqls << '(movimentos.data_lancamento > ?)'; @variaveis << params['data_min'].to_date) unless params['data_min'].blank?
    (@sqls << '(movimentos.data_lancamento < ?)'; @variaveis << params['data_max'].to_date) unless params['data_max'].blank?
    (@sqls << '(parcelas.forma_de_pagamento = ?)'; @variaveis << params['forma_pagamento']) unless params['forma_pagamento'].blank?
    ItensMovimento.sum(:valor, :include => [{:movimento => :parcela}, {:plano_de_conta => :contas_corrente}], :conditions => [@sqls.join(' AND ')] + @variaveis)
  end

  def verifica_saldo_beta(params, unidade_id)
    anos = []
    ano_data_inicial = params['data_min'].to_date.year if !params['data_min'].blank?
    ano_data_final = params['data_max'].to_date.year if !params['data_max'].blank?

    intervalo = ano_data_inicial..ano_data_final
    (intervalo).collect do |ano|
      anos << ano
    end
    conta_contabil_da_conta_corrente = ContasCorrente.find_by_id(self.id).conta_contabil.codigo_contabil
    entidade_id = Unidade.find_by_id(unidade_id).entidade_id
    ids = PlanoDeConta.find(:all, :conditions => ['entidade_id = ? AND codigo_contabil = ? AND ano IN (?)', entidade_id, conta_contabil_da_conta_corrente, anos]).collect(&:id)

    @sqls = ['(itens_movimentos.plano_de_conta_id IN (?)) AND (movimentos.unidade_id = ?)']; @variaveis = [ids, unidade_id]
    (@sqls << '(itens_movimentos.tipo = ?)'; @variaveis << params['tipo']) unless params['tipo'].blank?
    #(@sqls << '(movimentos.data_lancamento > ?)'; @variaveis << params['data_min'].to_date) unless params['data_min'].blank?
    (@sqls << '(movimentos.data_lancamento < ?)'; @variaveis << params['data_max'].to_date) unless params['data_max'].blank?
    (@sqls << '(parcelas.forma_de_pagamento = ?)'; @variaveis << params['forma_pagamento']) unless params['forma_pagamento'].blank?
    ItensMovimento.sum(:valor, :include => [{:movimento => :parcela}, :plano_de_conta], :conditions => [@sqls.join(' AND ')] + @variaveis)
  end

  def saldo_anterior_beta(data_min, data_max, unidade_id, forma_pagamento = nil)
    self.verifica_saldo_beta({'tipo' => 'D', 'data_min' => data_min, 'data_max' => data_max, 'forma_pagamento' => forma_pagamento}, unidade_id) -
      self.verifica_saldo_beta({'tipo' => 'C', 'data_min' => data_min, 'data_max' => data_max, 'forma_pagamento' => forma_pagamento}, unidade_id)
  end
  
  def saldo_anterior(data, unidade_id, forma_pagamento = nil)
    self.verifica_saldo({'tipo' => 'D', 'data_max' => data, 'forma_pagamento' => forma_pagamento}, unidade_id) -
      self.verifica_saldo({'tipo' => 'C', 'data_max' => data, 'forma_pagamento' => forma_pagamento}, unidade_id)
  end

  def self.select_conta_corrent(unidade)
    Unidade.find(unidade).contas_corrente.collect {|c| [c.descricao, c.id] }
  end
end
