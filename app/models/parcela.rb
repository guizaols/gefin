class Parcela < ActiveRecord::Base
  extend BuscaExtendida

  acts_as_audited

  #CONSTANTES
  #SITUAÇÕES DA PARCELA
  PENDENTE = 1
  QUITADA = 2
  CANCELADA = 3
  RENEGOCIADA = 4
  JURIDICO = 5
  PERMUTA = 6
  BAIXA_DO_CONSELHO = 7
  DESCONTO_EM_FOLHA = 8
  ENVIADO_AO_DR = 9
  DEVEDORES_DUVIDOSOS_ATIVOS = 10
  EVADIDA = 11
  ESTORNADA = 12

  DINHEIRO = 1
  BANCO = 2
  CHEQUE = 3
  CARTAO = 4

  OPCOES_SITUACAO_PARA_COMBO = [
    ['Baixa do conselho', BAIXA_DO_CONSELHO], ['Cancelado', CANCELADA], ['Desconto em Folha', DESCONTO_EM_FOLHA],
    ['Enviado ao DR', ENVIADO_AO_DR], ['Inativo', CANCELADA], ['Jurídico', JURIDICO],
    ['Pendente', PENDENTE], ['Permuta', PERMUTA], ['Perdas no Recebimento de Créditos - Clientes', DEVEDORES_DUVIDOSOS_ATIVOS],
    ['Quitada', QUITADA], ['Renegociado', RENEGOCIADA], ['Evadida', EVADIDA]
  ]
  
  MES = {1 => 'JAN', 2 => 'FEV', 3 => 'MAR', 4 => 'ABR', 5 => 'MAI', 6 => 'JUN',
    7 => 'JUL', 8 => 'AGO', 9 => 'SET', 10 => 'OUT', 11 => 'NOV', 12 => 'DEZ'}
  
  #Validações
  validates_inclusion_of :forma_de_pagamento, :in => [DINHEIRO, BANCO, CHEQUE, CARTAO], :message => 'deve ser preenchido', :if => Proc.new{ |parcela| !parcela.baixar_dr && !parcela.data_da_baixa.blank? }
  #  validates_presence_of :data_do_pagamento, :numero_do_comprovante, :message => "deve ser preenchido", :if => Proc.new{ |parcela| parcela.forma_de_pagamento == BANCO && parcela.conta_type == 'PagamentoDeConta'}
  validates_presence_of :numero_do_comprovante, :message => 'deve ser preenchido', :if => Proc.new{ |parcela| parcela.forma_de_pagamento == BANCO && parcela.conta_type == 'PagamentoDeConta'}
  validates_presence_of :conta_corrente, :message => 'deve ser preenchido', :if => Proc.new{ |parcela| parcela.forma_de_pagamento == BANCO }
  validates_presence_of :data_vencimento
  validates_numericality_of :valor, :greater_than => 0, :message => 'deve ser maior do que zero.'
  validates_presence_of :cheques, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.forma_de_pagamento == CHEQUE && !parcela.estornando}
  validates_presence_of :cartoes, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.forma_de_pagamento == CARTAO && !parcela.estornando}
  validates_presence_of :centro_multa, :unidade_organizacional_multa, :conta_contabil_multa, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.valor_da_multa > 0}
  validates_presence_of :centro_desconto, :unidade_organizacional_desconto, :conta_contabil_desconto, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.valor_do_desconto > 0}
  validates_presence_of :centro_juros, :unidade_organizacional_juros, :conta_contabil_juros, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.valor_dos_juros > 0}
  validates_presence_of :centro_outros, :conta_contabil_outros, :unidade_organizacional_outros, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.outros_acrescimos > 0}
  validates_presence_of :centro_honorarios, :conta_contabil_honorarios, :unidade_organizacional_honorarios, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.honorarios > 0}
  validates_presence_of :centro_protesto, :conta_contabil_protesto, :unidade_organizacional_protesto, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.protesto > 0}
  validates_presence_of :centro_taxa_boleto, :conta_contabil_taxa_boleto, :unidade_organizacional_taxa_boleto, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.taxa_boleto > 0}  
  validates_presence_of :centro_irrf, :conta_contabil_irrf, :unidade_organizacional_irrf, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.irrf > 0}
  validates_presence_of :centro_outros_impostos, :conta_contabil_outros_impostos, :unidade_organizacional_outros_impostos, :message => 'deve ser preenchido', :if => Proc.new{|parcela| parcela.outros_impostos > 0}
  validates_numericality_of :valor_liquido, :greater_than => 0, :message => 'deve ser maior do que zero.', :if => Proc.new{|parcela| !parcela.baixar_dr && !parcela.data_da_baixa.blank?}
  #Formatação
  data_br_field  :data_da_baixa, :data_do_pagamento,:data_vencimento,:data_envio_ao_dr
  converte_para_data_para_formato_date :data_vencimento, :data_da_baixa, :created_at, :data_do_pagamento,:data_envio_ao_dr

  #Atributos Virtuais  e Protegidos
  attr_writer :dados_do_rateio
  attr_accessor :baixando, :ano_contabil_atual, :replicar, :baixada, :dados_do_imposto, :aliquota, :valor_imposto,
    :retencao, :estornando, :dados_da_baixa, :nome_conta_corrente, :baixar_dr, :calcula_porcentagem, :baixando_parcialmente,
    :revertendo, :revertendo_evasao, :cancelando_com_ctr_canc
  cria_readers_para_valores_em_dinheiro :valor_liquido
  cria_readers_e_writers_para_valores_em_dinheiro :valor_dos_juros, :valor_do_desconto, :outros_acrescimos, :valor_da_multa,
    :honorarios, :protesto, :taxa_boleto, :irrf, :outros_impostos
  attr_protected :dados_do_rateio, :dados_do_imposto

  #Atributos virtuais usados para projecao
  attr_accessor :selecionada, :desconto_em_porcentagem, :valor_apos_ser_calculado, :ax_multa, :ax_juros
  attr_writer :preco_em_reais, :indice, :preco_formatado_em_reais
  cria_readers_para_valores_em_dinheiro :calcula_valor_total_da_parcela, :retorna_valor_de_correcao_pelo_indice
  
  cria_atributos_virtuais_para_auto_complete :unidade_organizacional_desconto, :centro_desconto, :conta_contabil_desconto,
    :centro_juros, :conta_contabil_juros, :unidade_organizacional_juros,
    :centro_multa, :conta_contabil_multa, :unidade_organizacional_multa,
    :centro_outros, :conta_contabil_outros, :unidade_organizacional_outros,
    :centro_honorarios, :conta_contabil_honorarios, :unidade_organizacional_honorarios,
    :centro_protesto, :conta_contabil_protesto, :unidade_organizacional_protesto,
    :centro_taxa_boleto, :conta_contabil_taxa_boleto, :unidade_organizacional_taxa_boleto,
    :centro_irrf, :conta_contabil_irrf, :unidade_organizacional_irrf,
    :centro_outros_impostos, :conta_contabil_outros_impostos, :unidade_organizacional_outros_impostos

  valida_anos_centro_e_unidade_organizacional :centro_desconto, :unidade_organizacional_desconto,
    :centro_juros, :unidade_organizacional_juros,
    :centro_multa, :unidade_organizacional_multa,
    :centro_outros, :unidade_organizacional_outros,
    :centro_honorarios, :unidade_organizacional_honorarios,
    :centro_protesto, :unidade_organizacional_protesto,
    :centro_taxa_boleto, :unidade_organizacional_taxa_boleto,
    :centro_irrf, :unidade_organizacional_irrf,
    :centro_outros_impostos, :unidade_organizacional_outros_impostos

  verifica_se_centro_pertence_a_unidade_organizacional :centro_desconto, :unidade_organizacional_desconto
  verifica_se_centro_pertence_a_unidade_organizacional :centro_juros, :unidade_organizacional_juros
  verifica_se_centro_pertence_a_unidade_organizacional :centro_multa, :unidade_organizacional_multa
  verifica_se_centro_pertence_a_unidade_organizacional :centro_outros, :unidade_organizacional_outros
  verifica_se_centro_pertence_a_unidade_organizacional :centro_honorarios, :unidade_organizacional_honorarios
  verifica_se_centro_pertence_a_unidade_organizacional :centro_protesto, :unidade_organizacional_protesto
  verifica_se_centro_pertence_a_unidade_organizacional :centro_taxa_boleto, :unidade_organizacional_taxa_boleto
  verifica_se_centro_pertence_a_unidade_organizacional :centro_irrf, :unidade_organizacional_taxa_boleto
  verifica_se_centro_pertence_a_unidade_organizacional :centro_outros_impostos, :unidade_organizacional_outros_impostos

  HUMANIZED_ATTRIBUTES = {
    :data_vencimento => "O campo data de vencimento",
    :valor => "O campo valor",
    :cheques => "Cheque",
    :cheques_conta=>"O campo conta do cheque",
    :cheques_nome_do_titular=>"O campo nome do titular",
    :cheques_data_para_deposito=>"O campo data para depósito do cheque",
    :cheques_numero => "O campo número do cheque",
    :cheques_conta_contabil_transitoria => "O campo conta contábil transitória",
    :cheques_agencia => "O campo agência do cheque",
    :cartoes => "Cartão",
    :cartoes_nome_do_titular => "O campo nome do titular do cartão",
    :cartoes_codigo_de_seguranca => "O campo código de segurança",
    :cartoes_validade => "O campo validade do cartão",
    :cartoes_numero => "O campo número do cartão",
    :cartoes_bandeira => "O campo bandeira do cartão",
    :data_da_baixa => "O campo data da baixa",
    :numero => "O campo número",
    :centro_juros => "O campo centro para juros",
    :centro_multa => "O campo centro para multa",
    :centro_outros => "O campo centro para outros",
    :centro_desconto => "O campo centro para desconto",
    :centro_honorarios => "O campo centro para honorarios",
    :centro_protesto => "O campo centro para protesto",
    :centro_taxa_boleto => "O campo centro para Taxa de Boleto",
    :centro_irrf => 'O campo centro para IRRF',
    :centro_outros_impostos => 'O campo centro para Outros Impostos',
    :unidade_organizacional_juros => "O campo unidade organizacional para Juros",
    :unidade_organizacional_multa => "O campo unidade organizacional para Multa",
    :unidade_organizacional_desconto => "O campo unidade organizacional para Desconto",
    :unidade_organizacional_outros => "O campo unidade organizacional para Outros",
    :unidade_organizacional_honorarios => "O campo unidade organizacional para Honorarios",
    :unidade_organizacional_protesto => "O campo unidade organizacional para Protesto",
    :unidade_organizacional_taxa_boleto => "O campo unidade organizacional para Taxa de Boleto",
    :unidade_organizacional_irrf => 'O campo unidade organizacional para IRRF',
    :unidade_organizacional_outros_impostos => 'O campo unidade organizacional para Outros Impostos',
    :conta_contabil_juros => "O campo conta contábil para Juros",
    :conta_contabil_outros => "O campo conta contábil para Outros",
    :conta_contabil_desconto=>"O campo conta contábil para Desconto",
    :conta_contabil_multa=>"O campo conta contábil para Multa",
    :conta_contabil_protesto=>"O campo conta contábil para Protesto",
    :conta_contabil_honorarios=>"O campo conta contábil para Honorarios",
    :conta_contabil_taxa_boleto=>"O campo conta contábil para Taxa de Boleto",
    :conta_contabil_irrf => 'O campo conta contábil para IRRF',
    :conta_contabil_outros_impostos => 'O campo conta contábil para Outros Impostos',
    :valor_liquido => "O campo valor líquido",
    :valor_dos_juros => "O campo valor para Juros",
    :valor_da_multa => "O campo valor para Multa",
    :valor_do_desconto => "O campo valor para Desconto",
    :outros_acrescimos => "O campo valor para Outros",
    :unidade_organizacional => "O campo unidade organizacional não é válido.",
    :justificativa_para_outros => "O campo Justificativa",
    :historico => "O campo histórico",
    :conta_corrente => "O campo conta corrente",
    :numero_do_comprovante => "O campo número do comprovante",
    :data_do_pagamento => "O campo data do pagamento",
    :forma_de_pagamento => "O campo forma de pagamento",
    :honorarios => "O campo valor para Honorários",
    :taxa_boleto => "O campo valor para Taxa de Boleto",
    :protesto => "O campo valor para Protesto",
    :irrf => 'O campo valor para IRRF',
    :outros_impostos => 'O campo valor para Outros Impostos'
  }

  #RELACIONAMENTOS
  has_one :parcela_filha, :class_name => 'Parcela', :foreign_key => 'parcela_original_id'
  belongs_to :parcela_original, :class_name => 'Parcela'
  belongs_to :conta, :polymorphic => true
  belongs_to :arquivo_remessa
  has_many :rateios, :dependent => :destroy
  has_many :lancamento_impostos, :dependent => :destroy
  has_many :cheques, :dependent => :destroy
  has_many :cartoes, :dependent => :destroy
  has_many :movimentos
  accepts_nested_attributes_for :cheques, :reject_if => proc { |atributos| atributos.all? { |chave, conteudo| conteudo.blank? } }
  accepts_nested_attributes_for :cartoes, :reject_if => proc { |atributos| atributos.all? { |chave, conteudo| conteudo.blank? } }

  #CENTRO
  belongs_to :centro_desconto, :class_name => 'Centro', :foreign_key => "centro_desconto_id"
  belongs_to :centro_outros, :class_name => 'Centro', :foreign_key => "centro_outros_id"
  belongs_to :centro_juros, :class_name => 'Centro', :foreign_key => "centro_juros_id"
  belongs_to :centro_multa, :class_name => 'Centro', :foreign_key => "centro_multa_id"
  belongs_to :centro_honorarios, :class_name => 'Centro', :foreign_key => "centro_honorarios_id"
  belongs_to :centro_protesto, :class_name => 'Centro', :foreign_key => "centro_protesto_id"
  belongs_to :centro_taxa_boleto, :class_name => 'Centro', :foreign_key => "centro_taxa_boleto_id"
  belongs_to :centro_irrf, :class_name => 'Centro', :foreign_key => "centro_irrf_id"
  belongs_to :centro_outros_impostos, :class_name => 'Centro', :foreign_key => "centro_outros_impostos_id"

  #UNIDADE ORGANIZACIONAL
  belongs_to :unidade_organizacional_desconto, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_desconto_id"
  belongs_to :unidade_organizacional_outros, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_outros_id"
  belongs_to :unidade_organizacional_juros, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_juros_id"
  belongs_to :unidade_organizacional_multa, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_multa_id"
  belongs_to :unidade_organizacional_honorarios, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_honorarios_id"
  belongs_to :unidade_organizacional_protesto, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_protesto_id"
  belongs_to :unidade_organizacional_taxa_boleto, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_taxa_boleto_id"
  belongs_to :unidade_organizacional_irrf, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_irrf_id"
  belongs_to :unidade_organizacional_outros_impostos, :class_name => 'UnidadeOrganizacional', :foreign_key => "unidade_organizacional_outros_impostos_id"
  
  #CONTA CONTABIL
  belongs_to :conta_contabil_desconto, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_desconto_id"
  belongs_to :conta_contabil_outros, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_outros_id"
  belongs_to :conta_contabil_juros, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_juros_id"
  belongs_to :conta_contabil_multa, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_multa_id"
  belongs_to :conta_contabil_honorarios, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_honorarios_id"
  belongs_to :conta_contabil_protesto, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_protesto_id"
  belongs_to :conta_contabil_taxa_boleto, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_taxa_boleto_id"
  belongs_to :conta_contabil_irrf, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_irrf_id"
  belongs_to :conta_contabil_outros_impostos, :class_name => 'PlanoDeConta', :foreign_key => "conta_contabil_outros_impostos_id"
  
  #CONTA CORRENTE
  belongs_to :conta_corrente, :class_name => "ContasCorrente", :foreign_key => "conta_corrente_id"
  cria_readers_e_writers_para_o_nome_dos_atributos :conta_corrente

  def initialize(attributes = {})
    ['valor_liquido', 'valor_da_multa', 'valor_dos_juros', 'valor_do_desconto', 'outros_acrescimos', 'honorarios', 'protesto', 'taxa_boleto', 'irrf', 'outros_impostos'].each{|indice| attributes[indice] ||= 0}
    attributes['data_da_baixa'] ||= nil
    super
    self.estornando = false
    self.revertendo = false
    self.revertendo_evasao = false
    self.cancelando_com_ctr_canc = false
  end

  def forma_de_pagamento_verbose
    case forma_de_pagamento
    when DINHEIRO; "Dinheiro"
    when BANCO; "Banco"
    when CHEQUE; "Cheque"
    when CARTAO; "Cartão"  
    end
  end

  def nome_conta_corrente
    self.conta_corrente.resumo_conta_corrente if self.conta_corrente && forma_de_pagamento == BANCO
  end

  def calcula_valor_total_da_parcela(projecao = false)
    porcento = self.percentual_de_desconto.to_f / 10000.0
    juros = projecao ? self.valor_dos_juros - (self.valor_dos_juros * porcento) : self.valor_dos_juros
    multa = projecao ? self.valor_da_multa - (self.valor_da_multa * porcento) : self.valor_da_multa
    irrf = self.irrf.blank? ? 0 : self.irrf
    outros_impostos = self.outros_impostos.blank? ? 0 : self.outros_impostos
    self.valor + juros + multa - self.valor_do_desconto + self.outros_acrescimos - self.soma_impostos_da_parcela + self.valores_novos_recebimentos - irrf - outros_impostos
  end

  def indice
    @indice.to_f
  end
  
  def retorna_valor_de_correcao_pelo_indice
    (self.indice / 100) * self.valor
  end

  def before_validation
    if baixando || baixar_dr
      self.valor_liquido = calcula_valor_total_da_parcela
      if self.valor_da_multa == 0
        self.centro_multa_id, self.unidade_organizacional_multa_id, self.conta_contabil_multa_id = [nil, nil, nil]
      end
      if self.valor_do_desconto == 0
        self.centro_desconto_id, self.unidade_organizacional_desconto_id, self.unidade_organizacional_desconto_id = [nil, nil, nil]
      end
      if self.valor_dos_juros == 0
        self.centro_juros_id, self.unidade_organizacional_juros_id, self.conta_contabil_juros_id = [nil, nil, nil]
      end
      if self.outros_acrescimos == 0
        self.centro_outros_id, self.unidade_organizacional_outros_id, self.conta_contabil_outros_id = [nil, nil, nil]
      end
      if self.honorarios == 0
        self.centro_honorarios_id, self.unidade_organizacional_honorarios_id, self.conta_contabil_honorarios_id = [nil, nil, nil]
      end
      if self.protesto == 0
        self.centro_protesto_id, self.unidade_organizacional_protesto_id, self.conta_contabil_protesto_id = [nil, nil, nil]
      end
      if self.taxa_boleto == 0
        self.centro_taxa_boleto_id, self.unidade_organizacional_taxa_boleto_id, self.conta_contabil_taxa_boleto_id = [nil, nil, nil]
      end
      if self.irrf == 0
        self.centro_irrf_id, self.unidade_organizacional_irrf_id, self.conta_contabil_irrf_id = [nil, nil, nil]
      end
      if self.outros_impostos == 0
        self.centro_outros_impostos_id, self.unidade_organizacional_outros_impostos_id, self.conta_contabil_outros_impostos_id = [nil, nil, nil]
      end
      self.cheques = [] if self.forma_de_pagamento != CHEQUE
      self.cartoes = [] if self.forma_de_pagamento != CARTAO
      if self.forma_de_pagamento == CHEQUE
        self.cheques.first.data_de_recebimento = self.data_da_baixa
      end
      self.situacao_antiga = self.situacao
      self.situacao = QUITADA
    end
  end

  def aliquota
    aliquota.nova_aliquota if aliquota
  end
  
  def valor_imposto
    valor.novo_valor if valor
  end

  def preco_em_reais
    self.valor.to_f/100
  end

  def preco_formatado_em_reais
    (self.valor.to_f/100).real.to_s
  end

  def dados_do_rateio
    unless @dados_do_rateio
      @dados_do_rateio = {}
      contador = 1
      self.rateios.sort_by(&:valor).each do |rateio|
        @dados_do_rateio[contador.to_s] ||= {}
        @dados_do_rateio[contador.to_s]['valor'] ||= format("%.2f", (rateio.valor / 100.0)).to_s
        @dados_do_rateio[contador.to_s]['porcentagem'] ||= (rateio.valor * 100.0) / self.valor
        @dados_do_rateio[contador.to_s]['centro_id'] ||= rateio.centro_id
        @dados_do_rateio[contador.to_s]['unidade_organizacional_id'] ||= rateio.unidade_organizacional_id
        @dados_do_rateio[contador.to_s]['conta_contabil_id'] ||= rateio.conta_contabil_id
        centro = Centro.find rateio.centro_id
        unidade_organizacional = UnidadeOrganizacional.find rateio.unidade_organizacional_id
        conta_contabil_nome = PlanoDeConta.find rateio.conta_contabil_id
        @dados_do_rateio[contador.to_s]['centro_nome'] ||= centro.codigo_centro + ' - ' + centro.nome
        @dados_do_rateio[contador.to_s]['unidade_organizacional_nome'] ||= unidade_organizacional.codigo_da_unidade_organizacional + ' - ' + unidade_organizacional.nome
        @dados_do_rateio[contador.to_s]['conta_contabil_nome'] ||= conta_contabil_nome.codigo_contabil + ' - ' + conta_contabil_nome.nome
        contador += 1
      end
    end
    @dados_do_rateio
  end

  def before_save
    if self.conta_type == 'RecebimentoDeConta' && self.conta.nao_permite_alteracao?
      raise('Este contrato não pode ser modificado pois encontra-se cancelado')
    end
    if baixando || baixar_dr
      self.justificativa_para_outros = nil if outros_acrescimos == 0
      if self.forma_de_pagamento != BANCO || self.conta_type != 'PagamentoDeConta'
        self.data_do_pagamento = nil
        self.numero_do_comprovante = nil
      end
      if !baixar_dr
        lancamento_contabil_de_baixa_da_parcela #if self.forma_de_pagamento != CARTAO
      end
    end
  end

  def validate
    valida_soma_dos_impostos_para_gravacao if self.conta_type == 'PagamentoDeConta'

    if self.data_da_baixa && self.data_da_baixa.to_date > Date.today
      errors.add :data_da_baixa, "não pode ser maior do que a data de hoje - #{Date.today.to_s_br}"
    end

    if (self.situacao == CANCELADA && self.cancelado_pelo_contrato == true)
      # Não entra na validação para cancelamento
    else
      if !self.cancelando_com_ctr_canc && !self.revertendo && !self.revertendo_evasao && self.situacao_was == CANCELADA && self.cancelado_pelo_contrato_was != true
        errors.add :situacao, 'da parcela é cancelada.'
      end
    end
    errors.add :situacao, 'da parcela é renegociada.' if self.situacao_was == RENEGOCIADA
    errors.add :base, 'A soma do valor dos itens do rateio não é igual ao valor da parcela.' if !dados_do_rateio.blank? && validade_do_valor_dos_itens_do_rateio && !self.estornando
    errors.add :base, 'Não é permitido vincular a mesma unidade organizacional, centro de responsabilidade e conta contábil para outro rateio da mesma parcela.' if dados_do_rateio && !validade_do_valor_das_unidades_organizacionais_e_dos_centros_em_itens_do_rateio.blank? && !self.estornando
    errors.add :base, 'Nâo é permitido vincular mais de um cheque para a mesma parcela.' if self.cheques.length > 1
    errors.add :base, 'Nâo é permitido vincular mais de um Cartão para a mesma parcela.' if self.cartoes.length > 1

    if baixando || baixar_dr
      if self.conta.is_a?(PagamentoDeConta) && self.situacao_was == ESTORNADA
        errors.add :base, 'Não é possível baixar uma parcela estornada'
      end
			if !data_limite_para_baixa_valida? && !validar_data_inicio_entre_limites
				errors.add :base, 'A data limite para baixa não está de acordo com as datas permitidas conforme as configurações.'
			end
      errors.add :base, 'É preciso cadastrar um conta caixa para efetuar a baixa em dinheiro.' if self.forma_de_pagamento == 1 && ContasCorrente.find_by_unidade_id_and_identificador(self.conta.unidade_id, ContasCorrente::CAIXA).blank?
      if self.forma_de_pagamento == 3
        errors.add :base, 'É preciso cadastrar um conta caixa para efetuar a baixa de cheques à vista.' if (ContasCorrente.find_by_unidade_id_and_identificador(self.conta.unidade_id, ContasCorrente::CAIXA).blank?) && (self.data_da_baixa == self.cheques.first.data_para_deposito)
        errors.add :base, 'A data para depósito do cheque deve ser maior ou igual a data da baixa' if  self.data_da_baixa && !self.cheques.blank? && self.cheques.first.data_para_deposito && self.data_da_baixa.to_date > self.cheques.first.data_para_deposito.to_date
      end
      errors.add :data_da_baixa, 'deve ser preenchido.' if self.data_da_baixa.blank?
      errors.add :data_da_baixa, 'não pode ser menor que a data de emissão do contrato.' if self.conta.is_a?(PagamentoDeConta) && self.data_da_baixa.to_date < self.conta.data_emissao.to_date
      errors.add :valor_do_desconto, 'é inválido' if self.valor_do_desconto>self.valor
      errors.add :base, 'Esta parcela já foi baixada' if self.baixada
      # errors.add :data_da_baixa,"deve ser maior ou igual a data da geração da parcela." if self.data_da_baixa && self.data_da_baixa.to_date < self.created_at.to_date
      errors.add :valor_da_multa, 'deve ser maior que zero' if self.valor_da_multa < 0
      errors.add :valor_dos_juros, 'deve ser maior que zero' if self.valor_dos_juros < 0
      errors.add :valor_do_desconto, 'deve ser maior que zero' if self.valor_do_desconto < 0
      errors.add :outros_acrescimos, 'deve ser maior que zero' if self.outros_acrescimos < 0
      errors.add :honorarios, 'deve ser maior que zero' if self.honorarios < 0 && self.conta_type == 'RecebimentoDeConta'
      errors.add :protesto, 'deve ser maior que zero' if self.protesto < 0 && self.conta_type == 'RecebimentoDeConta'
      errors.add :taxa_boleto, 'deve ser maior que zero' if self.taxa_boleto < 0 && self.conta_type == 'RecebimentoDeConta'      
      errors.add :irrf, 'deve ser maior que zero' if self.irrf < 0 && self.conta_type == 'PagamentoDeConta'
      errors.add :outros_impostos, 'deve ser maior que zero' if self.outros_impostos < 0 && self.conta_type == 'PagamentoDeConta'
      errors.add :justificativa_para_outros, 'deve ser preenchido' if self.outros_acrescimos > 0 && self.justificativa_para_outros.blank?
      errors.add :historico, 'deve ser preenchido' if self.historico.blank?
    end

    if !baixando || !baixar_dr
      if self.conta.is_a?(PagamentoDeConta) && self.conta.liberacao_dr_faixa_de_dias_permitido != true
        if !self.validar_data_inicio_entre_limites_para_funcionalidades && !self.validar_datas_para_funcionalidades
          errors.add :base, 'A operação não pode ser efetuada pois o limite de dias retroativos foi excedido'
        end
      end

      if self.conta.is_a?(RecebimentoDeConta) && self.conta.liberacao_dr_faixa_de_dias_permitido != true
        if !self.validar_data_inicio_entre_limites_para_funcionalidades && !self.validar_datas_para_funcionalidades
          errors.add :base, 'A operação não pode ser efetuada pois o limite de dias retroativos foi excedido'
        end
      end
    end

    erro = self.errors.instance_variable_get(:@errors)
    if erro.has_key?("lancamento_impostos") || erro.has_key?("rateios")
      erro.delete "lancamento_impostos"
      erro.delete "rateios"
      array_erros = []
      erro["base"].each { |i| array_erros << i }  if erro["base"]
      erro.delete "base"
      self.lancamento_impostos.each { |i| i.errors.full_messages.each { |e| array_erros << e } }
      self.rateios.each { |i| i.errors.full_messages.each { |e| array_erros << e } }
      erro["base"] = array_erros
    end
    erro["base"].uniq! if erro.has_key?("base")
  end

  def grava_itens_do_rateio(ano, usuario, alteracao_parcelas = false)
    begin
      if self.validar_datas_para_funcionalidades || self.validar_data_inicio_entre_limites_para_funcionalidades
        hash_contabil ||={}
        hash_contabil["debito"] ||={}
        hash_contabil["credito"] ||={}
        limpa_hash_itens_do_rateio unless dados_do_rateio.blank?
        return [false, 'Os dados do rateio estão em branco'] if dados_do_rateio.blank?
        Parcela.transaction do
          self.rateios.each{|i_rateio| i_rateio.destroy}
          dados_do_rateio.each do |numero_do_item_do_rateio, dados_do_item_do_rateio|
            calcula_porcentagem_do_rateio
            dados_do_item_do_rateio["unidade_organizacional_id"] = nil if dados_do_item_do_rateio["unidade_organizacional_nome"].blank?
            dados_do_item_do_rateio["centro_id"] = nil if dados_do_item_do_rateio["centro_nome"].blank?
            dados_do_item_do_rateio["conta_contabil_id"] = nil if dados_do_item_do_rateio["conta_contabil_nome"].blank?
            dados_do_item_do_rateio["valor"] = 0 if dados_do_item_do_rateio["valor"].blank?
            valor = dados_do_item_do_rateio["valor"].real.to_f * 100
            self.rateios.build :unidade_organizacional_id => dados_do_item_do_rateio["unidade_organizacional_id"], :centro_id => dados_do_item_do_rateio["centro_id"], :conta_contabil_id => dados_do_item_do_rateio["conta_contabil_id"], :valor => valor.round
            self.save || (raise self.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
          end
          replicar_para_todas_as_parcelas(ano, usuario) if self.replicar
          if self.conta.is_a?(PagamentoDeConta) && self.conta.provisao == PagamentoDeConta::SIM
            remove_movimento_e_itens(Movimento::PROVISAO)
            lanca_rateio(hash_contabil)
            valor_dos_impostos = lanca_imposto(hash_contabil)
            lancamento_diferenca_total_impostos(valor_dos_impostos, hash_contabil)
            efetua_lancamento!(ano, hash_contabil, Movimento::PROVISAO, self.conta.historico, self.conta.data_emissao)
          end
          if alteracao_parcelas
            HistoricoOperacao.cria_follow_up("A parcela #{self.numero} foi alterada", usuario, self.conta, nil, nil, self.valor)
          else
            self.reload
            self.rateios.each do |rat|
              mensagem = "A parcela #{self.numero} teve sua composição de rateio alterada --- "
              mensagem += "Conta Contábil: #{rat.conta_contabil.codigo_contabil} | "
              mensagem += "Unid. Org.: #{rat.unidade_organizacional.codigo_da_unidade_organizacional} | "
              mensagem += "Centro: #{rat.centro.codigo_centro} "
              HistoricoOperacao.cria_follow_up(mensagem, usuario, self.conta, nil, nil, rat.valor)
              mensagem = ''
            end
          end
          return [true, "Rateio gravado com sucesso!"]
        end
      else
        return [false, "Não é possível registrar o rateio com os limites retroativos estabelecidos."]
      end
    rescue Exception => e
      LANCAMENTOS_LOGGER.erro "Rateio: #{hash_contabil}", e
      [false, e.message]
    end
  end
  
  def remove_movimento_e_itens(tipo_do_movimento, cheque = nil, situacao_cheque = nil)
    movimentos = self.conta.movimentos.select{|obj| obj.provisao == tipo_do_movimento && self.id == obj.parcela_id && obj.cheque == cheque && obj.situacao_cheque == situacao_cheque}
    movimentos.each{|mov| Movimento.delete(mov) || raise('Não foi possível excluir o movimento')}
  end

  def remove_movimento_e_itens_com_tipo_de_movimento(tipo_do_movimento, tipo_movimento)
    movimentos = self.conta.movimentos.select{|obj| obj.provisao == tipo_do_movimento && self.id == obj.parcela_id && tipo_movimento == obj.tipo_lancamento}
    movimentos.each{|mov| Movimento.delete(mov) || raise('Não foi possível excluir o movimento')}
  end

  def remove_movimento_e_itens_cheque(tipo_do_movimento)
    movimentos = self.conta.movimentos.select{|obj| obj.provisao == tipo_do_movimento && self.id == obj.parcela_id && obj.cheque == true}
    movimentos.each{|mov| Movimento.delete(mov) || raise('Não foi possível excluir o movimento')}
  end

  def lanca_rateio(hash, verificacao = nil)
    tipo = self.conta.is_a?(PagamentoDeConta) ?  'D' : 'C'
    if dados_do_rateio.blank?
      if self.conta.is_a?(PagamentoDeConta)
        if verificacao == 'xunxo'
          insere_no_hash(hash, "credito", {:tipo => 'C', :unidade_organizacional => self.conta.unidade_organizacional,
              :plano_de_conta => self.conta.conta_contabil_receita, :centro => self.conta.centro, :valor => self.valor})
        else
          insere_no_hash(hash, tipo == 'C' ? 'credito' : 'debito', {:tipo => tipo, :unidade_organizacional => self.conta.unidade_organizacional,
              :plano_de_conta => self.conta.conta_contabil_receita, :centro => self.conta.centro, :valor => self.valor})
        end
      else
        if tipo == 'D'
          insere_no_hash(hash, 'debito', {:tipo => tipo, :unidade_organizacional => self.conta.unidade_organizacional,
              :plano_de_conta => self.conta.conta_contabil_receita, :centro => self.conta.centro, :valor => self.valor})
        else
          if self.conta.provisao == RecebimentoDeConta::SIM
            unless self.conta.unidade.blank?
              raise "Deve ser parametrizada uma conta contábil do tipo Cliente." if self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).blank?
            end
            insere_no_hash(hash, 'credito', {:tipo => tipo, :unidade_organizacional => self.conta.unidade_organizacional,
                :plano_de_conta => self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).conta_contabil, :centro => self.conta.centro, :valor => self.valor})
          else
            insere_no_hash(hash, 'credito', {:tipo => tipo, :unidade_organizacional => self.conta.unidade_organizacional,
                :plano_de_conta => self.conta.conta_contabil_receita, :centro => self.conta.centro, :valor => self.valor})
          end
        end
      end
    else
      dados_do_rateio.each do |chave, conteudo|
        valor = conteudo["valor"].real.to_f * 100
        if self.conta.is_a?(PagamentoDeConta)
          if verificacao == 'xunxo'
            insere_no_hash(hash, "credito", {:tipo => 'C', :unidade_organizacional => UnidadeOrganizacional.find_by_id(conteudo["unidade_organizacional_id"]),
                :plano_de_conta => PlanoDeConta.find_by_id(conteudo["conta_contabil_id"]), :centro => Centro.find_by_id(conteudo["centro_id"]), :valor => valor.round.to_i})
          else
            insere_no_hash(hash, tipo == 'C' ? 'credito' : 'debito', {:tipo => tipo, :unidade_organizacional => UnidadeOrganizacional.find_by_id(conteudo["unidade_organizacional_id"]),
                :plano_de_conta => PlanoDeConta.find_by_id(conteudo["conta_contabil_id"]), :centro => Centro.find_by_id(conteudo["centro_id"]), :valor => valor.round.to_i})
          end
        else
          if tipo == 'D'
            insere_no_hash(hash, 'debito', {:tipo => tipo, :unidade_organizacional => UnidadeOrganizacional.find_by_id(conteudo["unidade_organizacional_id"]),
                :plano_de_conta => PlanoDeConta.find_by_id(conteudo["conta_contabil_id"]), :centro => Centro.find_by_id(conteudo["centro_id"]), :valor => valor.round.to_i})
          else
            if self.conta.provisao == RecebimentoDeConta::SIM
              unless self.conta.unidade.blank?
                raise "Deve ser parametrizada uma conta contábil do tipo Cliente." if self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).blank?
              end
              insere_no_hash(hash, 'credito', {:tipo => tipo, :unidade_organizacional => UnidadeOrganizacional.find_by_id(conteudo["unidade_organizacional_id"]),
                  :plano_de_conta => self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).conta_contabil, :centro => Centro.find_by_id(conteudo["centro_id"]), :valor => valor.round.to_i})
            else
              insere_no_hash(hash, 'credito', {:tipo => tipo, :unidade_organizacional => UnidadeOrganizacional.find_by_id(conteudo["unidade_organizacional_id"]),
                  :plano_de_conta => PlanoDeConta.find_by_id(conteudo["conta_contabil_id"]), :centro => Centro.find_by_id(conteudo["centro_id"]), :valor => valor.round.to_i})
            end
          end
        end
      end
    end
  end

  def lanca_imposto(hash)
    soma_das_retencoes = 0
    outros = 0
    hash_rateios = []

    dados_do_imposto.each do |chave, conteudo|
      valor_rateio_imposto = []
      imposto = Imposto.find_by_id(conteudo['imposto_id'].to_i)
      retencao = (conteudo['valor_imposto'].real.to_f * 100).round.to_i

      if self.conta.rateio == PagamentoDeConta::SIM && !self.rateios.blank? && retencao > 0
        self.calcula_porcentagem.each do |key, value|
          if imposto.classificacao == Imposto::INCIDE
            valor_rateio_imposto << [imposto.conta_debito.id, (value['porcentagem'].round(2) * (retencao / 100)).to_i]
          else
            valor_rateio_imposto << (value['porcentagem'].round(2) * (retencao / 100)).to_i
          end
        end
      end

      if self.conta.rateio == PagamentoDeConta::NAO
        insere_no_hash(hash, 'credito', {:tipo => 'C', :unidade_organizacional => self.conta.unidade_organizacional,
            :plano_de_conta => imposto.conta_credito, :centro => self.conta.centro, :valor => retencao.round.to_i})
      end

      if imposto.classificacao == Imposto::INCIDE
        if self.conta.rateio == PagamentoDeConta::NAO
          insere_no_hash(hash, 'debito', {:tipo => 'D', :unidade_organizacional => self.conta.unidade_organizacional,
              :plano_de_conta => imposto.conta_debito, :centro => self.conta.centro, :valor => retencao.round.to_i})
        end
        if self.conta.rateio == PagamentoDeConta::SIM
          soma_impostos = 0
          hash_rateios = self.calcula_porcentagem
          valor_rateio_imposto.each do |valor|
            soma_impostos += valor[1]
          end
          acrescimo = retencao - soma_impostos
          if soma_impostos != retencao
            valor_rateio_imposto[valor_rateio_imposto.length-1][1] = valor_rateio_imposto.last[1] + acrescimo
          end
          1.upto(valor_rateio_imposto.length) do |i|
            if retencao > 0
              insere_no_hash(hash, 'debito', {:tipo => 'D',
                  :unidade_organizacional => UnidadeOrganizacional.find(hash_rateios[i-1]['unidade_organizacional']),
                  :plano_de_conta => PlanoDeConta.find(valor_rateio_imposto[i-1][0]),
                  :centro => Centro.find(hash_rateios[i-1]['centro']), :valor => valor_rateio_imposto[i-1][1]})
            end
          end
          insere_no_hash(hash, 'credito', {:tipo => 'C', :unidade_organizacional => self.conta.unidade_organizacional,
              :plano_de_conta => imposto.conta_credito, :centro => self.conta.centro, :valor => retencao.round.to_i})
        end
        outros += retencao.round.to_i
      else
        if self.conta.rateio == PagamentoDeConta::SIM
          insere_no_hash(hash, 'credito', {:tipo => 'C', :unidade_organizacional => self.conta.unidade_organizacional,
              :plano_de_conta => imposto.conta_credito, :centro => self.conta.centro, :valor => retencao.round.to_i})
        end
        soma_das_retencoes += retencao.round.to_i
      end
    end

    return soma_das_retencoes
  end

  def lancamento_diferenca_total_impostos(total_impostos, hash)
    insere_no_hash(hash, 'credito', {:tipo => 'C', :unidade_organizacional => self.conta.unidade_organizacional, :plano_de_conta => self.conta.conta_contabil_pessoa,
        :centro => self.conta.centro, :valor => self.valor - total_impostos})
  end

  def efetua_lancamento!(ano, hash, provisao, historico, data)
    lancamento_debito=[]
    lancamento_credito=[]
    hash['debito'].each do |chave, conteudo|
      lancamento_debito << conteudo
    end
    hash['credito'].each do |chave, conteudo|
      lancamento_credito << conteudo
    end
    Movimento.lanca_contabilidade(ano, [
        {:conta => self.conta, :historico => historico, :numero_de_controle => self.conta.numero_de_controle,
          :data_lancamento => data, :tipo_lancamento => 'S', :tipo_documento => self.conta.tipo_de_documento,
          :provisao => provisao, :pessoa_id => self.conta.pessoa_id, :numero_da_parcela => self.numero,
          :parcela_id => self.id},
        lancamento_debito, lancamento_credito], self.conta.unidade_id)
  end
  
  def insere_no_hash(hash, tipo, conteudo)
    if hash.blank?
      hash ||= {}
      hash["debito"] ||= {}
      hash["credito"] ||= {}
    end
    posicao = hash[tipo].length + 1
    hash[tipo][posicao.to_s] ||= conteudo
  end

  def lancamento_contabil_de_baixa_da_parcela
    hash_contabil ||={}
    conta_a_pagar = self.conta.is_a?(PagamentoDeConta)
    conta_a_receber = self.conta.is_a?(RecebimentoDeConta)

    insere_no_hash(hash_contabil, conta_a_pagar ? 'debito' : 'credito', {:plano_de_conta => self.conta_contabil_multa, :centro => self.centro_multa, :valor => self.valor_da_multa, :unidade_organizacional => self.unidade_organizacional_multa}) if self.valor_da_multa > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'debito' : 'credito', {:plano_de_conta => self.conta_contabil_juros, :centro => self.centro_juros, :valor => self.valor_dos_juros, :unidade_organizacional => self.unidade_organizacional_juros}) if self.valor_dos_juros > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'debito' : 'credito', {:plano_de_conta => self.conta_contabil_outros, :centro => self.centro_outros, :valor => self.outros_acrescimos, :unidade_organizacional => self.unidade_organizacional_outros}) if self.outros_acrescimos > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'credito' : 'debito', {:plano_de_conta => self.conta_contabil_desconto, :centro => self.centro_desconto, :valor => self.valor_do_desconto, :unidade_organizacional => self.unidade_organizacional_desconto}) if self.valor_do_desconto > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'debito' : 'credito', {:plano_de_conta => self.conta_contabil_honorarios, :centro => self.centro_honorarios, :valor => self.honorarios, :unidade_organizacional => self.unidade_organizacional_honorarios}) if self.honorarios > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'debito' : 'credito', {:plano_de_conta => self.conta_contabil_protesto, :centro => self.centro_protesto, :valor => self.protesto, :unidade_organizacional => self.unidade_organizacional_protesto}) if self.protesto > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'debito' : 'credito', {:plano_de_conta => self.conta_contabil_taxa_boleto, :centro => self.centro_taxa_boleto, :valor => self.taxa_boleto, :unidade_organizacional => self.unidade_organizacional_taxa_boleto}) if self.taxa_boleto > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'credito' : 'debito', {:plano_de_conta => self.conta_contabil_irrf, :centro => self.centro_irrf, :valor => self.irrf, :unidade_organizacional => self.unidade_organizacional_irrf}) if self.irrf > 0
    insere_no_hash(hash_contabil, conta_a_pagar ? 'credito' : 'debito', {:plano_de_conta => self.conta_contabil_outros_impostos, :centro => self.centro_outros_impostos, :valor => self.outros_impostos, :unidade_organizacional => self.unidade_organizacional_outros_impostos}) if self.outros_impostos > 0
    
    conta_corrente = ContasCorrente.find_by_unidade_id_and_identificador(self.conta.unidade_id, ContasCorrente::CAIXA)
    unless conta_corrente.blank?
      conta_contabil = conta_corrente.conta_contabil
    end

    if self.forma_de_pagamento == BANCO
      conta_contabil = self.conta_corrente.conta_contabil
    elsif self.forma_de_pagamento == CHEQUE
      conta_contabil = self.cheques.first.conta_contabil_transitoria
    elsif self.forma_de_pagamento == CARTAO
      if self.conta.unidade.parametro_conta_valor_cartoes(ano_contabil_atual, self.cartoes.first.bandeira).blank?
        raise "Deve ser parametrizada uma conta contábil para o Cartão escolhido - #{self.cartoes.first.bandeira_verbose}."
      else
        conta_contabil = self.conta.unidade.parametro_conta_valor_cartoes(ano_contabil_atual, self.cartoes.first.bandeira).conta_contabil
      end
    end

    # ESSE CARA
    insere_no_hash(hash_contabil, conta_a_pagar ? 'credito' : 'debito', {:plano_de_conta => conta_contabil, :centro => self.conta.centro, :valor => self.valor + self.valor_da_multa + self.valor_dos_juros + self.outros_acrescimos + self.valores_novos_recebimentos - self.irrf - self.outros_impostos - self.valor_do_desconto - self.soma_impostos_da_parcela, :unidade_organizacional => self.conta.unidade_organizacional})

    if conta_a_receber && self.conta.rateio == 1 && !baixando_parcialmente
      lanca_rateio(hash_contabil)
    elsif conta_a_receber
      # ESSE CARA
      # insere_no_hash(hash_contabil, "credito", {:plano_de_conta => self.conta.conta_contabil_receita, :centro => self.conta.centro, :valor => self.valor - self.soma_impostos_da_parcela, :unidade_organizacional => self.conta.unidade_organizacional})

      if self.conta.provisao == RecebimentoDeConta::SIM
        unless self.conta.unidade.blank?
          raise 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).blank?
        end
        insere_no_hash(hash_contabil, 'credito', {:plano_de_conta => self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).conta_contabil, :centro => self.conta.centro, :valor => self.valor - self.soma_impostos_da_parcela, :unidade_organizacional => self.conta.unidade_organizacional})
      else
        insere_no_hash(hash_contabil, 'credito', {:plano_de_conta => self.conta.conta_contabil_receita, :centro => self.conta.centro, :valor => self.valor - self.soma_impostos_da_parcela, :unidade_organizacional => self.conta.unidade_organizacional})
      end
    end

    if conta_a_pagar && self.conta.provisao == 1
      insere_no_hash(hash_contabil, 'debito', {:plano_de_conta => self.conta.conta_contabil_pessoa, :centro => self.conta.centro, :valor => self.valor - self.soma_impostos_da_parcela, :unidade_organizacional => self.conta.unidade_organizacional})
    elsif conta_a_pagar
      if self.conta.rateio == 1
        lanca_rateio(hash_contabil)
      else
        insere_no_hash(hash_contabil, 'debito', {:plano_de_conta => self.conta.conta_contabil_despesa, :centro => self.conta.centro, :valor => self.valor, :unidade_organizacional => self.conta.unidade_organizacional})
      end
      lanca_imposto(hash_contabil)
    end

    return efetua_lancamento!(ano_contabil_atual, hash_contabil, Movimento::BAIXA, self.historico, self.data_da_baixa) unless baixando_parcialmente
  end

  def limpa_hash_itens_do_rateio
    dados_do_rateio.each do |chave,conteudo|
      if conteudo["valor"].blank? && conteudo["centro_nome"] && conteudo["unidade_organizacional_nome"] && conteudo["centro_id"].blank? && conteudo["unidade_organizacional_id"].blank?
        dados_do_rateio.delete chave
      end
    end
  end

  def grava_dados_do_imposto_na_parcela(ano, usuario = nil)
    hash_contabil ||={}
    hash_contabil['debito'] ||={}
    hash_contabil['credito'] ||={}
    return false if data_da_baixa
    begin
      if self.data_limite_para_lancar_imposto(self.conta.data_emissao.to_date) || self.data_para_lancar_imposto_entre_periodo(self.conta.data_emissao.to_date)
        Parcela.transaction do
          self.lancamento_impostos.each{|lancamento| lancamento.destroy}
          if dados_do_imposto.blank?
            if(self.conta.is_a?(PagamentoDeConta) && self.conta.provisao == PagamentoDeConta::SIM)
              remove_movimento_e_itens(Movimento::PROVISAO)
              Movimento.lanca_contabilidade(ano, [
                  {:conta => self.conta, :historico => self.conta.historico, :numero_de_controle => self.conta.numero_de_controle,
                    :data_lancamento => self.conta.data_emissao, :tipo_lancamento => 'E', :tipo_documento => self.conta.tipo_de_documento,
                    :provisao => Movimento::PROVISAO, :unidade => self.conta.unidade, :pessoa => self.conta.pessoa,
                    :numero_da_parcela => self.numero, :parcela_id => self.id},
                  [{:plano_de_conta => self.conta.conta_contabil_despesa, :centro => self.conta.centro, :valor => self.valor,
                      :unidade_organizacional => self.conta.unidade_organizacional}],
                  [{:plano_de_conta => self.conta.conta_contabil_pessoa, :centro => self.conta.centro, :valor => self.valor,
                      :unidade_organizacional => self.conta.unidade_organizacional}]
                ], self.conta.unidade_id)
            end
            return [true, 'Dados do imposto na parcela salvos com sucesso!']
          end
          dados_do_imposto.each do |numero_do_item_do_imposto, dados_do_item_do_imposto|
            calcula_porcentagem_do_rateio
            valor = dados_do_item_do_imposto['valor_imposto'].real.quantia
            self.lancamento_impostos.build :imposto_id => dados_do_item_do_imposto['imposto_id'], :data_de_recolhimento => dados_do_item_do_imposto['data_de_recolhimento'], :valor_em_reais => valor
            self.save || raise('')
          end
          if self.conta.provisao == PagamentoDeConta::SIM
            remove_movimento_e_itens(Movimento::PROVISAO)
            if dados_do_rateio.blank?
              insere_no_hash(hash_contabil, 'debito', {:plano_de_conta => self.conta.conta_contabil_despesa, :unidade_organizacional => self.conta.unidade_organizacional, :centro => self.conta.centro, :valor => self.valor})
            else
              lanca_rateio(hash_contabil)
            end
            valor_dos_impostos = lanca_imposto(hash_contabil)
            lancamento_diferenca_total_impostos(valor_dos_impostos, hash_contabil)
            efetua_lancamento!(ano, hash_contabil, Movimento::PROVISAO, self.conta.historico, self.conta.data_emissao)
          end
          if usuario
            self.lancamento_impostos.each do |imposto|
              mensagem = "O Imposto #{imposto.imposto.descricao} foi adicionado a Parcela de nº #{self.numero}"
              HistoricoOperacao.cria_follow_up(mensagem, usuario, self.conta, nil, nil, imposto.valor)
            end
          end
          return [true, 'Dados do imposto na parcela salvos com sucesso!']
        end
      else
        return [false, '* Não é possível registrar o lançamento de imposto pois os limites retroativos estabelecidos foram excedidos!']
      end
    rescue Exception => e
      errors.add :base, e.message unless e.message == ''
      [false, e.message]
    end
  end

  def dados_do_imposto
    unless @dados_do_imposto
      @dados_do_imposto = {}
      contador = 1
      self.lancamento_impostos.each do |dados|
        @dados_do_imposto[contador.to_s] ||={}
        @dados_do_imposto[contador.to_s]['imposto_id'] ||= dados.imposto_id
        @dados_do_imposto[contador.to_s]['data_de_recolhimento'] ||= dados.data_de_recolhimento
        @dados_do_imposto[contador.to_s]['aliquota'] ||= Imposto.find(dados.imposto_id).aliquota
        @dados_do_imposto[contador.to_s]['valor_imposto'] ||= dados.valor/100.0
        contador+=1
      end
    end
    @dados_do_imposto
  end
  
  def dados_da_baixa
    if data_da_baixa && forma_de_pagamento
      return 'Pagamento efetuado em dinheiro' if forma_de_pagamento == 1
      return "Pagamento efetuado com cheque à vista do #{self.cheques.first.banco.descricao}, Número: #{self.cheques.first.numero}, Agência: #{self.cheques.first.agencia}, Conta Corrente: #{self.cheques.first.conta}." if (forma_de_pagamento == 3) && (self.cheques.first.data_de_recebimento == self.cheques.first.data_para_deposito)
      return "Pagamento efetuado com cheque pré-datado do #{self.cheques.first.banco.descricao}, Número: #{self.cheques.first.numero}, Agência: #{self.cheques.first.agencia}, Conta Corrente: #{self.cheques.first.conta}, Bom para: #{self.cheques.first.data_para_deposito}." if (forma_de_pagamento == 3) && (self.cheques.first.data_de_recebimento != self.cheques.first.data_para_deposito)
      return "Pagamento efetuado com cartão #{self.cartoes.first.bandeira_verbose}, Número: #{self.cartoes.first.numero}, Validade: #{self.cartoes.first.validade}." if (forma_de_pagamento == 4)
      return "Pagamento efetuado via depósito bancário no dia #{self.data_do_pagamento}, depósito efetuado no #{self.conta_corrente.agencia.banco.descricao}, Agência: #{self.conta_corrente.agencia.nome}, Número da agência: #{self.conta_corrente.agencia.numero}-#{self.conta_corrente.agencia.digito_verificador}, Conta Corrente: #{self.conta_corrente.numero_conta}-#{self.conta_corrente.digito_verificador}." if (forma_de_pagamento == 2)
    end
  end

  def valida_soma_dos_impostos_para_gravacao
    soma = 0
    dados_do_imposto.each do |_,dados_do_item_do_imposto|
      imposto = Imposto.find(dados_do_item_do_imposto['imposto_id'])
      soma += (dados_do_item_do_imposto['valor_imposto'].to_f*100).to_i if imposto.classificacao == Imposto::RETEM
    end
    errors.add :base, 'O valor da soma dos impostos deve ser menor que o valor da parcela. Por favor verifique.' if self.conta_type == 'PagamentoDeConta' && (soma == self.valor)
    errors.add :base, 'Valor dos impostos maior que o valor da parcela. Por favor verifique.' if self.conta_type == 'PagamentoDeConta' && (!valor.blank?) && (soma > valor)
  end

  def soma_impostos_da_parcela
    soma = 0
    lancamento_impostos.each do |imposto|
      soma += imposto.valor unless imposto.imposto.classificacao == Imposto::INCIDE
    end
    soma
  end

  def calcula_valor_liquido_da_parcela
    valor - soma_impostos_da_parcela
  end

  def validade_do_valor_dos_itens_do_rateio
    soma = 0
    dados_do_rateio.each do |numero_do_item_do_rateio, dados_do_item_do_rateio|
      valor = dados_do_item_do_rateio['valor'].blank? ? 0 : dados_do_item_do_rateio['valor']
      #      p 'VALOR DOS RATEIOS'
      #      p valor
      soma += valor.real.to_f * 100
    end
    #    p 'SOMA'
    #    p soma.to_i
    #    p self.valor
    #    p 'VALIDAÇÃO DO ITEM DO RATEIO'
    #    p soma
    #    p soma.round.to_i
    #    p self.valor
    #    p '**********************************************'

    if soma.round.to_i != self.valor
      true
    else
      false
    end
  end

  def validade_do_valor_das_unidades_organizacionais_e_dos_centros_em_itens_do_rateio
    itens_do_rateio = []
    dados_do_rateio.each do |numero_do_item_do_rateio, dados_do_item_do_rateio|
      itens_do_rateio << [dados_do_item_do_rateio["centro_id"],dados_do_item_do_rateio["unidade_organizacional_id"],dados_do_item_do_rateio["conta_contabil_id"]]
    end
    itens_do_rateio.group_by{|e| e}.reject{|key,e| e.length == 1}.collect(&:first)
  end

  def self.retorna_selecao(imposto_id)
    if (imposto_id.blank?)
      return ''
    else
      if imposto_id.to_s.include?('#')
        return imposto_id
      else
        return "#{imposto_id}##{Imposto.find(imposto_id).aliquota.to_f}##{Imposto.find(imposto_id).classificacao.to_i}"
      end
    end
  end

  def replicar_para_todas_as_parcelas(ano, usuario)
    dados_do_rateio_que_deve_ser_replicado = self.dados_do_rateio
    valores_dos_itens_do_rateio_que_devem_ser_replicados = []
    soma_dos_itens_do_rateio_que_devem_ser_replicados = 0
    outras_parcelas = Parcela.find_all_by_conta_id_and_conta_type(self.conta, self.conta_type)
    outras_parcelas.reject!{|parcela| parcela.id == self.id || parcela.data_da_baixa != nil}

    outras_parcelas.each do |parcela|
      valor_da_parcela = parcela.valor.to_f
      parcela.dados_do_rateio = nil
      dados_do_rateio_que_deve_ser_replicado.each do |chave, conteudo|
        parcela.dados_do_rateio[chave.to_s] ||= {}
        parcela.dados_do_rateio[chave.to_s]["centro_nome"] = conteudo["centro_nome"]
        parcela.dados_do_rateio[chave.to_s]["centro_id"] = conteudo["centro_id"]
        parcela.dados_do_rateio[chave.to_s]["unidade_organizacional_nome"] = conteudo["unidade_organizacional_nome"]
        parcela.dados_do_rateio[chave.to_s]["unidade_organizacional_id"] = conteudo["unidade_organizacional_id"]
        parcela.dados_do_rateio[chave.to_s]["conta_contabil_nome"] = conteudo["conta_contabil_nome"]
        parcela.dados_do_rateio[chave.to_s]["conta_contabil_id"] = conteudo["conta_contabil_id"]
        parcela.dados_do_rateio[chave.to_s]["valor"] = 0
        if self.replicar == nil
          valores_dos_itens_do_rateio_que_devem_ser_replicados << conteudo["valor"].real.to_f * 100
        else
          valores_dos_itens_do_rateio_que_devem_ser_replicados << conteudo['valor'].real.to_f * 100
        end
      end

      valores_dos_itens_do_rateio_que_devem_ser_replicados.each do |valor_item_rateio|
        soma_dos_itens_do_rateio_que_devem_ser_replicados += valor_item_rateio
      end

      if soma_dos_itens_do_rateio_que_devem_ser_replicados == valor_da_parcela
        # SE FOREM IGUAIS APENAS JOGO O VALOR DE CADA UM DO VETOR NO HASH
        valores_dos_itens_do_rateio_que_devem_ser_replicados.each_with_index do |conteudo,index|
          parcela.dados_do_rateio[(index+1).to_s]["valor"] = (conteudo / 100.0).to_s
        end
      else
        # SE FOREM DIFERENTES VEJO O VALOR DO ACRESCIMO E JOGO EM UM VALOR DO HASH
        acrescimo = valor_da_parcela - soma_dos_itens_do_rateio_que_devem_ser_replicados
        valores_dos_itens_do_rateio_que_devem_ser_replicados.each_with_index do |conteudo,index|
          if (index+1) != 1
            parcela.dados_do_rateio[(index+1).to_s]["valor"] = (conteudo / 100.0).to_s
          else
            parcela.dados_do_rateio[(index+1).to_s]["valor"] = ((conteudo+acrescimo) / 100.0).to_s
          end
        end
      end

      valores_dos_itens_do_rateio_que_devem_ser_replicados = []
      soma_dos_itens_do_rateio_que_devem_ser_replicados = 0
      parcela.grava_itens_do_rateio(ano, usuario)
    end
  end

  def situacao_verbose
    case situacao
    when PENDENTE; data_vencimento.to_date < Date.today ? 'Em atraso' : 'Vincenda'
    when QUITADA; 'Quitada'
    when CANCELADA;
      if conta.is_a?(RecebimentoDeConta)
        case conta.situacao_fiemt
        when RecebimentoDeConta::Enviado_ao_DR; 'Enviada ao DR'
        when RecebimentoDeConta::Devedores_Duvidosos_Ativos; 'Perdas no Recebimento de Créditos - Clientes'
        else 'Cancelada'
        end
      else
        'Cancelada'
      end
    when RENEGOCIADA; 'Renegociada'
    when JURIDICO; 'Jurídico'
    when PERMUTA; 'Permuta'
    when BAIXA_DO_CONSELHO; 'Baixa do Conselho'
    when DESCONTO_EM_FOLHA; 'Desconto em Folha'
    when EVADIDA; 'Evadida'
    when DEVEDORES_DUVIDOSOS_ATIVOS; 'Perdas no Recebimento de Créditos - Clientes'
    when ESTORNADA; 'Estornada'
    when ENVIADO_AO_DR;
      situacao_verbose = 'Enviada ao DR'
      if self.parcela_original_id
        case self.parcela_original.situacao
        when QUITADA;
          situacao_verbose += ' (baixada pela unidade)'
        end
      end
      situacao_verbose
    end
  end

  def situacao_antiga_verbose
    case situacao_antiga
    when PENDENTE; data_vencimento.to_date < Date.today ? 'Em atraso' : 'Vincenda'
    when QUITADA; 'Quitada'
    when CANCELADA;
      if conta.is_a?(RecebimentoDeConta)
        case conta.situacao_fiemt
        when RecebimentoDeConta::Enviado_ao_DR; 'Enviada ao DR'
        when RecebimentoDeConta::Devedores_Duvidosos_Ativos; 'Perdas no Recebimento de Créditos - Clientes'
        else 'Cancelada'
        end
      else
        'Cancelada'
      end
    when RENEGOCIADA; 'Renegociada'
    when JURIDICO; 'Jurídico'
    when PERMUTA; 'Permuta'
    when BAIXA_DO_CONSELHO; 'Baixa do Conselho'
    when DESCONTO_EM_FOLHA; 'Desconto em Folha'
    when EVADIDA; 'Evadida'
    when DEVEDORES_DUVIDOSOS_ATIVOS; 'Perdas no Recebimento de Créditos - Clientes'
    when ENVIADO_AO_DR;
      situacao_antiga_verbose = 'Enviada ao DR'
      if self.parcela_original_id
        case self.parcela_original.situacao_antiga
        when QUITADA;
          situacao_antiga_verbose += ' (baixada pela unidade)'
        end
      end
      situacao_antiga_verbose
    end
  end

  def self.retorna_data(data_de_recolhimento)
    if data_de_recolhimento.blank?
      return Date.today.to_s_br
    else
      return data_de_recolhimento
    end
  end

  def baixada
    !self.data_da_baixa_was.blank?
  end
  
  def renegociada
    self.situacao == RENEGOCIADA
  end

  def pode_estornar_parcela?
    if !baixada || self.situacao == CANCELADA || self.situacao == RENEGOCIADA
      return false
      #elsif (self.unidade && ((Date.today > data_da_baixa.to_date + unidade.limitediasparaestornodeparcelas) if !data_da_baixa.blank?))
      #return false
    elsif [CHEQUE,CARTAO].include?(self.forma_de_pagamento)
      self.cheques.collect(&:situacao).each do |situacao|
        return false if [Cheque::BAIXADO, Cheque::DEVOLVIDO, Cheque::REAPRESENTADO].include?(situacao)
      end
      return false if self.cartoes.collect(&:situacao).include?(Cartao::BAIXADO)
    end
    if self.conta.is_a?(RecebimentoDeConta) && self.conta.travado_pela_situacao?
      return false
    end
    return true
  end

  def estorna_parcela(usuario, justificativa, data, cartao = true, baixa_parcial_externa = false)
    
    return [false, 'A Data do Estorno deve ser preenhida'] if data.blank?
    return [false, 'A Justificativa deve ser preenhida'] if justificativa.blank?
    return [false, 'A Data do Estorno deve ser válida'] if data.length != 10
    return [false, 'A Data do Estorno não pode ser maior que a data de hoje'] if data.to_date > Date.today && cartao
    begin
      Parcela.transaction do
        if pode_estornar_parcela? && (validar_datas_entre_limites(data) || validar_datas_para_estorno(data))
          p 'oi11'
          unless self.parcela_mae_id #BAIXA NORMAL
            p 'oi12'
            self.data_da_baixa = nil
            self.valor_liquido = 0
            self.historico = nil
            self.observacoes = nil
            self.baixar_dr = nil
            self.situacao = self.situacao_antiga
            self.baixa_pela_dr = false
            self.valor_do_desconto = 0
            self.outros_acrescimos = 0
            self.justificativa_para_outros = nil
            self.valor_da_multa = 0
            self.conta_contabil_multa_id = nil
            self.unidade_organizacional_multa_id = nil
            self.centro_multa_id = nil
            self.valor_dos_juros = 0
            self.conta_contabil_juros_id = nil
            self.unidade_organizacional_juros_id = nil
            self.centro_juros_id = nil
            self.conta_contabil_outros_id = nil
            self.unidade_organizacional_outros_id = nil
            self.centro_outros_id = nil
            self.conta_contabil_desconto_id = nil
            self.unidade_organizacional_desconto_id = nil
            self.centro_desconto_id = nil
            self.protesto = 0
            self.honorarios = 0
            self.taxa_boleto = 0
            self.irrf = 0
            self.outros_impostos = 0
            self.unidade_organizacional_protesto_id = nil
            self.centro_protesto_id = nil
            self.conta_contabil_protesto_id = nil
            self.unidade_organizacional_taxa_boleto_id = nil
            self.centro_taxa_boleto_id = nil
            self.conta_contabil_taxa_boleto_id = nil
            self.unidade_organizacional_honorarios_id = nil
            self.centro_honorarios_id = nil
            self.conta_contabil_honorarios_id = nil
            self.unidade_organizacional_irrf_id = nil
            self.centro_irrf_id = nil
            self.conta_contabil_irrf_id = nil
            self.unidade_organizacional_outros_impostos_id = nil
            self.centro_outros_impostos_id = nil
            self.conta_contabil_outros_impostos_id = nil
            if self.forma_de_pagamento == BANCO
              self.forma_de_pagamento = nil
              self.conta_corrente = nil
              self.data_do_pagamento = nil
              self.numero_do_comprovante = nil
            elsif self.forma_de_pagamento == CHEQUE
              self.forma_de_pagamento = nil
              self.cheques.each{|cheque| cheque.destroy}
            elsif self.forma_de_pagamento == CARTAO
              self.forma_de_pagamento = nil
              self.cartoes.each{|cartao| cartao.destroy}
            end
            self.estornando = true
            if self.save
              if self.parcela_original #BAIXA NORMAL - PARCELA ORIGINAL
                self.parcela_original.data_da_baixa = nil
                self.parcela_original.valor_liquido = 0
                self.parcela_original.historico = nil
                self.parcela_original.observacoes = nil
                self.parcela_original.situacao = self.situacao_antiga
                self.parcela_original.baixa_pela_dr = false
                self.parcela_original.valor_do_desconto = 0
                self.parcela_original.outros_acrescimos = 0
                self.parcela_original.justificativa_para_outros = nil
                self.parcela_original.valor_da_multa = 0
                self.parcela_original.conta_contabil_multa_id = nil
                self.parcela_original.unidade_organizacional_multa_id = nil
                self.parcela_original.centro_multa_id = nil
                self.parcela_original.valor_dos_juros = 0
                self.parcela_original.conta_contabil_juros_id = nil
                self.parcela_original.unidade_organizacional_juros_id = nil
                self.parcela_original.centro_juros_id = nil
                self.parcela_original.conta_contabil_outros_id = nil
                self.parcela_original.unidade_organizacional_outros_id = nil
                self.parcela_original.centro_outros_id = nil
                self.parcela_original.conta_contabil_desconto_id = nil
                self.parcela_original.unidade_organizacional_desconto_id = nil
                self.parcela_original.centro_desconto_id = nil
                self.parcela_original.protesto = 0
                self.parcela_original.honorarios = 0
                self.parcela_original.taxa_boleto = 0
                self.parcela_original.unidade_organizacional_protesto_id = nil
                self.parcela_original.centro_protesto_id = nil
                self.parcela_original.conta_contabil_protesto_id = nil
                self.parcela_original.unidade_organizacional_taxa_boleto_id = nil
                self.parcela_original.centro_taxa_boleto_id = nil
                self.parcela_original.conta_contabil_taxa_boleto_id = nil
                self.parcela_original.unidade_organizacional_honorarios_id = nil
                self.parcela_original.centro_honorarios_id = nil
                self.parcela_original.conta_contabil_honorarios_id = nil
                if self.parcela_original.forma_de_pagamento == BANCO
                  self.parcela_original.forma_de_pagamento = nil
                  self.parcela_original.conta_corrente = nil
                  self.parcela_original.data_do_pagamento = nil
                  self.parcela_original.numero_do_comprovante = nil
                elsif self.parcela_original.forma_de_pagamento == CHEQUE
                  self.parcela_original.forma_de_pagamento = nil
                elsif self.parcela_original.forma_de_pagamento == CARTAO
                  self.parcela_original.forma_de_pagamento = nil
                end
                self.parcela_original.estornando = true
                self.parcela_original.save!
                self.parcela_original.estornando = false
              elsif self.parcela_filha #BAIXA NORMAL - PARCELA ESPELHO
                self.parcela_filha.data_da_baixa = nil
                self.parcela_filha.valor_liquido = 0
                self.parcela_filha.historico = nil
                self.parcela_filha.observacoes = nil
                self.parcela_filha.situacao = self.situacao_antiga
                self.parcela_filha.baixa_pela_dr = false
                self.parcela_filha.valor_do_desconto = 0
                self.parcela_filha.outros_acrescimos = 0
                self.parcela_filha.justificativa_para_outros = nil
                self.parcela_filha.valor_da_multa = 0
                self.parcela_filha.conta_contabil_multa_id = nil
                self.parcela_filha.unidade_organizacional_multa_id = nil
                self.parcela_filha.centro_multa_id = nil
                self.parcela_filha.valor_dos_juros = 0
                self.parcela_filha.conta_contabil_juros_id = nil
                self.parcela_filha.unidade_organizacional_juros_id = nil
                self.parcela_filha.centro_juros_id = nil
                self.parcela_filha.conta_contabil_outros_id = nil
                self.parcela_filha.unidade_organizacional_outros_id = nil
                self.parcela_filha.centro_outros_id = nil
                self.parcela_filha.conta_contabil_desconto_id = nil
                self.parcela_filha.unidade_organizacional_desconto_id = nil
                self.parcela_filha.centro_desconto_id = nil
                self.parcela_filha.protesto = 0
                self.parcela_filha.honorarios = 0
                self.parcela_filha.taxa_boleto = 0
                self.parcela_filha.unidade_organizacional_protesto_id = nil
                self.parcela_filha.centro_protesto_id = nil
                self.parcela_filha.conta_contabil_protesto_id = nil
                self.parcela_filha.unidade_organizacional_taxa_boleto_id = nil
                self.parcela_filha.centro_taxa_boleto_id = nil
                self.parcela_filha.conta_contabil_taxa_boleto_id = nil
                self.parcela_filha.unidade_organizacional_honorarios_id = nil
                self.parcela_filha.centro_honorarios_id = nil
                self.parcela_filha.conta_contabil_honorarios_id = nil
                if self.parcela_filha.forma_de_pagamento == BANCO
                  self.parcela_filha.forma_de_pagamento = nil
                  self.parcela_filha.conta_corrente = nil
                  self.parcela_filha.data_do_pagamento = nil
                  self.parcela_filha.numero_do_comprovante = nil
                elsif self.parcela_filha.forma_de_pagamento == CHEQUE
                  self.parcela_filha.forma_de_pagamento = nil
                elsif self.parcela_filha.forma_de_pagamento == CARTAO
                  self.parcela_filha.forma_de_pagamento = nil
                end
                self.parcela_filha.estornando = true
                self.parcela_filha.save!
                self.parcela_filha.estornando = false
              end
              HistoricoOperacao.cria_follow_up("Parcela #{self.numero} estornada", usuario, self.conta, justificativa, nil, self.valor)
              #remove_movimento_e_itens(Movimento::BAIXA)
              movimento = Movimento.find(:last,
                :conditions => ['parcela_id = ? AND provisao = ? AND tipo_lancamento = ?', self.id, Movimento::BAIXA, 'S'])
              if !movimento.blank?
                novo_mov = movimento.clone

                novo_mov.historico = self.historico.blank? ? (self.conta.historico + ' (Estorno de Baixa)') : (self.historico + ' (Estorno de Baixa)')
                novo_mov.tipo_lancamento = 'K'
                novo_mov.tipo_documento = self.conta.tipo_de_documento
                novo_mov.data_lancamento = data.to_date
                novo_mov.provisao = Movimento::PROVISAO
                novo_mov.pessoa_id = self.conta.pessoa_id
                novo_mov.numero_da_parcela = self.numero

                movimento.itens_movimentos.each do |item|
                  novo_mov.itens_movimentos << item.clone
                end
                novo_mov.save!
                novo_mov.itens_movimentos.each do |it|
                  if it.tipo == 'C'
                    it.tipo = 'D'
                  else
                    it.tipo = 'C'
                  end
                  it.save!
                end
              end
              self.baixando = false
              self.estornando = false
              return [true, 'Parcela estornada com sucesso!']
            else
              raise [false, 'Não foi possível estornar esta parcela']
            end
          else#BAIXA PARCIAL
              if baixa_parcial_externa

                  self.data_da_baixa = nil
            self.valor_liquido = 0
            self.historico = nil
            self.observacoes = nil
            self.baixar_dr = nil
            self.situacao = self.situacao_antiga
            self.baixa_pela_dr = false
            self.valor_do_desconto = 0
            self.outros_acrescimos = 0
            self.justificativa_para_outros = nil
            self.valor_da_multa = 0
            self.conta_contabil_multa_id = nil
            self.unidade_organizacional_multa_id = nil
            self.centro_multa_id = nil
            self.valor_dos_juros = 0
            self.conta_contabil_juros_id = nil
            self.unidade_organizacional_juros_id = nil
            self.centro_juros_id = nil
            self.conta_contabil_outros_id = nil
            self.unidade_organizacional_outros_id = nil
            self.centro_outros_id = nil
            self.conta_contabil_desconto_id = nil
            self.unidade_organizacional_desconto_id = nil
            self.centro_desconto_id = nil
            self.protesto = 0
            self.honorarios = 0
            self.taxa_boleto = 0
            self.irrf = 0
            self.outros_impostos = 0
            self.unidade_organizacional_protesto_id = nil
            self.centro_protesto_id = nil
            self.conta_contabil_protesto_id = nil
            self.unidade_organizacional_taxa_boleto_id = nil
            self.centro_taxa_boleto_id = nil
            self.conta_contabil_taxa_boleto_id = nil
            self.unidade_organizacional_honorarios_id = nil
            self.centro_honorarios_id = nil
            self.conta_contabil_honorarios_id = nil
            self.unidade_organizacional_irrf_id = nil
            self.centro_irrf_id = nil
            self.conta_contabil_irrf_id = nil
            self.unidade_organizacional_outros_impostos_id = nil
            self.centro_outros_impostos_id = nil
            self.conta_contabil_outros_impostos_id = nil
            if self.forma_de_pagamento == BANCO
              self.forma_de_pagamento = nil
              self.conta_corrente = nil
              self.data_do_pagamento = nil
              self.numero_do_comprovante = nil
            elsif self.forma_de_pagamento == CHEQUE
              self.forma_de_pagamento = nil
              self.cheques.each{|cheque| cheque.destroy}
            elsif self.forma_de_pagamento == CARTAO
              self.forma_de_pagamento = nil
              self.cartoes.each{|cartao| cartao.destroy}
            end
            self.estornando = true
            if self.save
              if self.parcela_original #BAIXA NORMAL - PARCELA ORIGINAL
                self.parcela_original.data_da_baixa = nil
                self.parcela_original.valor_liquido = 0
                self.parcela_original.historico = nil
                self.parcela_original.observacoes = nil
                self.parcela_original.situacao = self.situacao_antiga
                self.parcela_original.baixa_pela_dr = false
                self.parcela_original.valor_do_desconto = 0
                self.parcela_original.outros_acrescimos = 0
                self.parcela_original.justificativa_para_outros = nil
                self.parcela_original.valor_da_multa = 0
                self.parcela_original.conta_contabil_multa_id = nil
                self.parcela_original.unidade_organizacional_multa_id = nil
                self.parcela_original.centro_multa_id = nil
                self.parcela_original.valor_dos_juros = 0
                self.parcela_original.conta_contabil_juros_id = nil
                self.parcela_original.unidade_organizacional_juros_id = nil
                self.parcela_original.centro_juros_id = nil
                self.parcela_original.conta_contabil_outros_id = nil
                self.parcela_original.unidade_organizacional_outros_id = nil
                self.parcela_original.centro_outros_id = nil
                self.parcela_original.conta_contabil_desconto_id = nil
                self.parcela_original.unidade_organizacional_desconto_id = nil
                self.parcela_original.centro_desconto_id = nil
                self.parcela_original.protesto = 0
                self.parcela_original.honorarios = 0
                self.parcela_original.taxa_boleto = 0
                self.parcela_original.unidade_organizacional_protesto_id = nil
                self.parcela_original.centro_protesto_id = nil
                self.parcela_original.conta_contabil_protesto_id = nil
                self.parcela_original.unidade_organizacional_taxa_boleto_id = nil
                self.parcela_original.centro_taxa_boleto_id = nil
                self.parcela_original.conta_contabil_taxa_boleto_id = nil
                self.parcela_original.unidade_organizacional_honorarios_id = nil
                self.parcela_original.centro_honorarios_id = nil
                self.parcela_original.conta_contabil_honorarios_id = nil
                if self.parcela_original.forma_de_pagamento == BANCO
                  self.parcela_original.forma_de_pagamento = nil
                  self.parcela_original.conta_corrente = nil
                  self.parcela_original.data_do_pagamento = nil
                  self.parcela_original.numero_do_comprovante = nil
                elsif self.parcela_original.forma_de_pagamento == CHEQUE
                  self.parcela_original.forma_de_pagamento = nil
                elsif self.parcela_original.forma_de_pagamento == CARTAO
                  self.parcela_original.forma_de_pagamento = nil
                end
                self.parcela_original.estornando = true
                self.parcela_original.save!
                self.parcela_original.estornando = false
              elsif self.parcela_filha #BAIXA NORMAL - PARCELA ESPELHO
                self.parcela_filha.data_da_baixa = nil
                self.parcela_filha.valor_liquido = 0
                self.parcela_filha.historico = nil
                self.parcela_filha.observacoes = nil
                self.parcela_filha.situacao = self.situacao_antiga
                self.parcela_filha.baixa_pela_dr = false
                self.parcela_filha.valor_do_desconto = 0
                self.parcela_filha.outros_acrescimos = 0
                self.parcela_filha.justificativa_para_outros = nil
                self.parcela_filha.valor_da_multa = 0
                self.parcela_filha.conta_contabil_multa_id = nil
                self.parcela_filha.unidade_organizacional_multa_id = nil
                self.parcela_filha.centro_multa_id = nil
                self.parcela_filha.valor_dos_juros = 0
                self.parcela_filha.conta_contabil_juros_id = nil
                self.parcela_filha.unidade_organizacional_juros_id = nil
                self.parcela_filha.centro_juros_id = nil
                self.parcela_filha.conta_contabil_outros_id = nil
                self.parcela_filha.unidade_organizacional_outros_id = nil
                self.parcela_filha.centro_outros_id = nil
                self.parcela_filha.conta_contabil_desconto_id = nil
                self.parcela_filha.unidade_organizacional_desconto_id = nil
                self.parcela_filha.centro_desconto_id = nil
                self.parcela_filha.protesto = 0
                self.parcela_filha.honorarios = 0
                self.parcela_filha.taxa_boleto = 0
                self.parcela_filha.unidade_organizacional_protesto_id = nil
                self.parcela_filha.centro_protesto_id = nil
                self.parcela_filha.conta_contabil_protesto_id = nil
                self.parcela_filha.unidade_organizacional_taxa_boleto_id = nil
                self.parcela_filha.centro_taxa_boleto_id = nil
                self.parcela_filha.conta_contabil_taxa_boleto_id = nil
                self.parcela_filha.unidade_organizacional_honorarios_id = nil
                self.parcela_filha.centro_honorarios_id = nil
                self.parcela_filha.conta_contabil_honorarios_id = nil
                if self.parcela_filha.forma_de_pagamento == BANCO
                  self.parcela_filha.forma_de_pagamento = nil
                  self.parcela_filha.conta_corrente = nil
                  self.parcela_filha.data_do_pagamento = nil
                  self.parcela_filha.numero_do_comprovante = nil
                elsif self.parcela_filha.forma_de_pagamento == CHEQUE
                  self.parcela_filha.forma_de_pagamento = nil
                elsif self.parcela_filha.forma_de_pagamento == CARTAO
                  self.parcela_filha.forma_de_pagamento = nil
                end
                self.parcela_filha.estornando = true
                self.parcela_filha.save!
                self.parcela_filha.estornando = false
              end
              HistoricoOperacao.cria_follow_up("Parcela #{self.numero} estornada", usuario, self.conta, justificativa, nil, self.valor)
              #remove_movimento_e_itens(Movimento::BAIXA)
              movimento = Movimento.find(:last,
                :conditions => ['parcela_id = ? AND provisao = ? AND tipo_lancamento = ?', self.id, Movimento::BAIXA, 'S'])
              if !movimento.blank?
                novo_mov = movimento.clone

                novo_mov.historico = self.historico.blank? ? (self.conta.historico + ' (Estorno de Baixa)') : (self.historico + ' (Estorno de Baixa)')
                novo_mov.tipo_lancamento = 'K'
                novo_mov.tipo_documento = self.conta.tipo_de_documento
                novo_mov.data_lancamento = data.to_date
                novo_mov.provisao = Movimento::PROVISAO
                novo_mov.pessoa_id = self.conta.pessoa_id
                novo_mov.numero_da_parcela = self.numero

                movimento.itens_movimentos.each do |item|
                  novo_mov.itens_movimentos << item.clone
                end
                novo_mov.save!
                novo_mov.itens_movimentos.each do |it|
                  if it.tipo == 'C'
                    it.tipo = 'D'
                  else
                    it.tipo = 'C'
                  end
                  it.save!
                end
              end
              self.baixando = false
              self.estornando = false
              return [true, 'Parcela estornada com sucesso!']
            else
              raise [false, 'Não foi possível estornar esta parcela']
            end


                
              end




            #######################
            #p "baixa parcialllll"


            if self.conta.is_a?(PagamentoDeConta)
              numero_parcial = self.numero_parcela_filha
              parcela = Parcela.find(self.parcela_mae_id)
              self.valor_da_multa = 0
              self.valor_dos_juros = 0
              self.valor_liquido = self.valor - (self.valor_da_multa + self.valor_dos_juros)
              self.save!            
              valor_dos_impostos = self.lancamento_impostos.sum(:valor, :conditions => ['impostos.classificacao = ?', Imposto::RETEM], :include => :imposto)
              
              self.lancamento_impostos.each do |item|
                parcela.lancamento_impostos << item.clone
              end
              parcela.lancamento_impostos.each do |lanc|
                lanc.parcela_id = parcela.id
                lanc.save false
              end

              parcela.valor = parcela.valor + self.valor_liquido + valor_dos_impostos
              parcela.valor_liquido = parcela.calcula_valor_liquido_da_parcela
              parcela.numero = numero_parcial

              if !parcela.rateios.blank?
                1.upto(parcela.rateios.length) do |i|
                  parcela.rateios[i-1]['valor'] += (self.rateios[i-1]['valor'] + parcela.rateios[i-1]['valor'] + valor_dos_impostos)
                  parcela.rateios[i-1].save || (raise parcela.rateios[i-1].errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
                end
              end
            else
              numero_parcial = self.numero_parcela_filha
              parcela = Parcela.find(self.parcela_mae_id)
              self.valor_da_multa = 0
              self.valor_dos_juros = 0
              self.valor_liquido = self.valor - (self.valor_da_multa + self.valor_dos_juros)
              self.save!            
              parcela.valor = parcela.valor + self.valor_liquido
              parcela.numero = numero_parcial

              if !parcela.rateios.blank?
                1.upto(parcela.rateios.length) do |i|
                  parcela.rateios[i-1]['valor'] += self.rateios[i-1]['valor']
                  parcela.rateios[i-1].save || (raise parcela.rateios[i-1].errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
                end
              end
            end
            parcela.estornando = true
            parcela.save || raise([false, 'Não foi possível estornar esta parcela'])
            parcela.estornando = false
            if self.destroy
              HistoricoOperacao.cria_follow_up("Parcela #{numero_parcial} estornada", usuario, parcela.conta, justificativa, nil, self.valor)
              self.estornando = true

              movimento = Movimento.find(:last, :conditions => ['parcela_id = ? AND provisao = ? AND tipo_lancamento = ?',
                  self.id, Movimento::BAIXA, 'S'])
              if !movimento.blank?
                novo_mov = movimento.clone

                novo_mov.historico = self.historico.blank? ? (self.conta.historico + ' (Estorno de Baixa)') : (self.historico + ' (Estorno de Baixa)')
                novo_mov.tipo_lancamento = 'K'
                novo_mov.tipo_documento = self.conta.tipo_de_documento
                novo_mov.data_lancamento = data.to_date
                novo_mov.provisao = Movimento::PROVISAO
                novo_mov.pessoa_id = self.conta.pessoa_id
                novo_mov.numero_da_parcela = self.numero

                movimento.itens_movimentos.each do |item|
                  novo_mov.itens_movimentos << item.clone
                end
                novo_mov.save!
                novo_mov.itens_movimentos.each do |it|
                  if it.tipo == 'C'
                    it.tipo = 'D'
                  else
                    it.tipo = 'C'
                  end
                  it.save!
                end
              end

              #remove_movimento_e_itens(Movimento::BAIXA)
              self.estornando = false
              return [true, 'Parcela estornada com sucesso!']
            else
              raise [false, 'Não foi possível estornar esta parcela']
            end
          end
        else
          return [false, 'A data de estorno excedeu os limites permitidos']
        end
      end
    rescue Exception => e
      LANCAMENTOS_LOGGER.erro e.backtrace.join("\n")
      [false, e.message]
    end
  end

  def ano
    self.conta.try :ano
  end

  def mes_vencimento
    self.data_vencimento.to_date.strftime("%m").to_i
  end

  def mes_baixa
    self.data_da_baixa.to_date.strftime("%m").to_i
  end
  
  def servico
    self.conta.nome_servico
  end

  def self.recuperacao_de_creditos(unidade, params)
    soma_das_parcelas_a_receber = 0
    soma_das_parcelas_recebidas = 0
    recuperacao_de_creditos ||= {}
    contas = {}
    recuperacao_de_credito_detalhado ||= {}
    recuperacao_de_credito_detalhado_receber ||= {}
    month_numbers = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
    condicoes = ['recebimento_de_contas.unidade_id = ?', '(YEAR(data_vencimento) = ?)']
    condicoes << 'servicos.modalidade = ?' unless params['nome_modalidade'].blank?
    condicoes << 'MONTH(data_vencimento) >= ?' if month_numbers.include?(params['mes_inicial'])
    condicoes << 'MONTH(data_vencimento) <= ?' if month_numbers.include?(params['mes_final'])
    #    condicoes << '(((MONTH(data_vencimento) >= ?) AND (MONTH(data_vencimento) <= ?)) OR ((MONTH(data_da_baixa) >= ?) AND (MONTH(data_da_baixa) <= ?)))'
    parametros = [unidade, params['ano']]
    parametros << params['nome_modalidade'] unless params['nome_modalidade'].blank?
    parametros << params['mes_inicial'] if month_numbers.include?(params['mes_inicial'])
    parametros << params['mes_final'] if month_numbers.include?(params['mes_final'])

    condicoes_baixa = ['recebimento_de_contas.unidade_id = ?', 'YEAR(data_da_baixa) = ?']
    condicoes_baixa << 'servicos.modalidade = ?' unless params['nome_modalidade'].blank?
    condicoes_baixa << 'MONTH(data_da_baixa) >= ?' if month_numbers.include?(params['mes_inicial'])
    condicoes_baixa << 'MONTH(data_da_baixa) <= ?' if month_numbers.include?(params['mes_final'])
    find_options_baixa = {:include => [:conta => :servico], :conditions => [condicoes_baixa.join(' AND ')] + parametros}
    ParcelaRecebimentoDeConta.find(:all, find_options_baixa).group_by(&:mes_baixa).each do |mes, parcelas|
      if params['tipo_do_relatorio'] == '0'
        recuperacao_de_creditos[mes] ||= {}
        parcelas.each do |parcela|
          soma_das_parcelas_recebidas += parcela.valor_liquido if parcela.situacao == QUITADA
        end
        recuperacao_de_creditos[mes]['recebido'] = soma_das_parcelas_recebidas
        soma_das_parcelas_recebidas = 0
      end
    end

    find_options = {:include => [:conta => :servico], :conditions => [condicoes.join(' AND ')] + parametros}
    ParcelaRecebimentoDeConta.find(:all, find_options).group_by(&:mes_vencimento).each do |mes, parcelas|
			if params['tipo_do_relatorio'] == '0'
        recuperacao_de_creditos[mes] ||= {}
        parcelas.each do |parcela|
          soma_das_parcelas_a_receber += parcela.valor if parcela.verifica_situacoes
        end
        recuperacao_de_creditos[mes]['a_receber'] = soma_das_parcelas_a_receber
        #recuperacao_de_creditos[mes]['recebido'] = soma_das_parcelas_recebidas
        recuperacao_de_creditos[mes]['geral'] = recuperacao_de_creditos[mes]['recebido'] + recuperacao_de_creditos[mes]['a_receber']
        recuperacao_de_creditos[mes]['inadimplencia'] = (recuperacao_de_creditos[mes]['a_receber'].to_f > 0 || recuperacao_de_creditos[mes]['geral'] * 100 > 0) ? ((recuperacao_de_creditos[mes]['a_receber'].to_f / recuperacao_de_creditos[mes]['geral']) * 100).round(2) : 0
        soma_das_parcelas_a_receber = 0
        #soma_das_parcelas_recebidas = 0

      elsif params['tipo_do_relatorio'] == '1'
        parcelas.each do |parcela|
          recuperacao_de_credito_detalhado[parcela.servico] ||= {}
          recuperacao_de_credito_detalhado[parcela.servico]['anos_anteriores'] ||= 0
          recuperacao_de_credito_detalhado[parcela.servico][mes] ||= 0
          recuperacao_de_credito_detalhado[parcela.servico][mes] += parcela.valor_liquido if parcela.situacao == QUITADA
        end

        parcelas.each do |parcela|
          recuperacao_de_credito_detalhado_receber[parcela.servico] ||= {}
          recuperacao_de_credito_detalhado_receber[parcela.servico]['anos_anteriores'] ||= 0
          recuperacao_de_credito_detalhado_receber[parcela.servico][mes] ||= 0
          recuperacao_de_credito_detalhado_receber[parcela.servico][mes] += parcela.valor if parcela.verifica_situacoes
        end
      end
    end

    unless recuperacao_de_creditos.blank?
      ParcelaRecebimentoDeConta.all(:include => :conta, :conditions => ['recebimento_de_contas.unidade_id = ? AND YEAR(data_vencimento) < ?', unidade, params['ano']]).each do |parcela|
        soma_das_parcelas_a_receber += parcela.valor if parcela.verifica_situacoes
      end
      soma_das_parcelas_recebidas = 0
      ParcelaRecebimentoDeConta.all(:include => :conta, :conditions => ['recebimento_de_contas.unidade_id = ? AND YEAR(data_da_baixa) < ?', unidade, params['ano']]).each do |parcela|
        soma_das_parcelas_recebidas += parcela.valor_liquido if parcela.situacao == QUITADA
      end
      recuperacao_de_creditos['anos_anteriores'] ||= {}
      recuperacao_de_creditos['anos_anteriores']['recebido'] = soma_das_parcelas_recebidas
      recuperacao_de_creditos['anos_anteriores']['a_receber'] = soma_das_parcelas_a_receber
      recuperacao_de_creditos['anos_anteriores']['geral'] = soma_das_parcelas_recebidas + soma_das_parcelas_a_receber
      if recuperacao_de_creditos['anos_anteriores']['geral'] > 0
        recuperacao_de_creditos['anos_anteriores']['inadimplencia'] = ((recuperacao_de_creditos['anos_anteriores']['a_receber'].to_f / recuperacao_de_creditos['anos_anteriores']['geral']) * 100).round(2)
      else
        recuperacao_de_creditos['anos_anteriores']['inadimplencia'] = 0
      end
      return recuperacao_de_creditos
    end

    unless recuperacao_de_credito_detalhado.blank?
      ParcelaRecebimentoDeConta.all(:include => [:conta => :servico], :conditions => ['recebimento_de_contas.unidade_id = ? and YEAR(data_vencimento) < ?', unidade, params['ano']]).group_by(&:servico).each do |curso,parcelas|
        parcelas.each do |parcela|
          recuperacao_de_credito_detalhado[curso.to_s] ||= {}
          recuperacao_de_credito_detalhado[curso.to_s]['anos_anteriores'] ||= 0
          recuperacao_de_credito_detalhado_receber[curso.to_s] ||= {}
          recuperacao_de_credito_detalhado_receber[curso.to_s]['anos_anteriores'] ||= 0
          if (parcela.situacao == QUITADA)
            recuperacao_de_credito_detalhado[curso.to_s]['anos_anteriores'] += parcela.valor_liquido
          elsif (parcela.verifica_situacoes)
            recuperacao_de_credito_detalhado_receber[curso.to_s]['anos_anteriores'] += parcela.valor
          end
        end
      end
      contas['recebido'] ||= recuperacao_de_credito_detalhado
      contas['receber'] ||= recuperacao_de_credito_detalhado_receber
      return contas
    end
  end

  def unidade
    self.conta.try :unidade
  end

  def self.relatorio_para_totalizacao(contar_ou_retornar, unidade, params)
    @sqls = ['(recebimento_de_contas.unidade_id = ?)']; @variaveis = [unidade]

    params["periodo"] == 'recebimento' ? sqls = 'data_da_baixa' : sqls = 'data_vencimento'
    preencher_array_para_buscar_por_faixa_de_datas params, :periodo, sqls
    preencher_array_para_campo_com_auto_complete params, :servico, 'servico_id'

    case params["opcao_relatorio"]
    when "1"; @sqls << ['parcelas.situacao IN (?)']; @variaveis << [QUITADA]
    when "2"; @sqls << ['parcelas.situacao IN (?)'];
      @variaveis << [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA] if params["situacao"] == "Todas"
      @variaveis << [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA] if params["situacao"] == 'Todas - Exceto Jurídico'
      @variaveis << [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA] if params["situacao"] == 'Todas - Exceto Permutas'
      @variaveis << [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, PERMUTA, DESCONTO_EM_FOLHA] if params["situacao"] == 'Todas - Exceto Baixa no Conselho'
      @variaveis << [PENDENTE, QUITADA, RENEGOCIADA, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA] if params["situacao"] == 'Todas - Exceto Inativas'
      @variaveis << [CANCELADA] if params["situacao"] == 'Inativas'
      @variaveis << [JURIDICO] if params["situacao"] == 'Jurídico'
      @variaveis << [PERMUTA] if params["situacao"] == 'Permuta'
      @variaveis << [BAIXA_DO_CONSELHO] if params["situacao"] == 'Baixa no Conselho'
      @variaveis << [DESCONTO_EM_FOLHA] if params["situacao"] == 'Desconto em Folha'
      @variaveis << [PENDENTE, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA] if params["situacao"] == 'Pendentes'
      if params["situacao"] == 'Vincendas'
        @variaveis << [PENDENTE, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA]
        @sqls << ('parcelas.data_vencimento >= ?')
        @variaveis << Date.today
      end
      if params["situacao"] == 'Em Atraso'
        @variaveis << [PENDENTE, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA]
        @sqls << ('parcelas.data_vencimento < ?')
        @variaveis << Date.today
      end
    when "3"; @sqls << ['(parcelas.situacao = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_da_baixa > parcelas.data_vencimento)']
      @variaveis << [QUITADA]
    when "4"; @sqls << ['(parcelas.situacao = ?) AND (parcelas.data_vencimento < ?)']
      @variaveis << PENDENTE
      @variaveis << Date.today
    end
    ParcelaRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis , :include => [:conta => :servico], :order => 'servicos.descricao ASC')
  end

  def calcular_juros_e_multas!(data_base = nil, data_de_vencimento = nil)
    return if conta_type == 'PagamentoDeConta'
    return if data_da_baixa

    if !self.porcentagem_juros.blank?
      juros = self.porcentagem_juros
    else
      juros = self.conta.juros_por_atraso
    end

    if !self.porcentagem_multa.blank?
      multa = self.porcentagem_multa
    else
      multa = self.conta.multa_por_atraso
    end

    data_base ||= Date.today
    self.valor_dos_juros, self.valor_da_multa, valor_corrigido = Gefin.calcular_juros_e_multas :vencimento => data_de_vencimento ? data_de_vencimento.to_date : self.data_vencimento.to_date,
      :data_base => data_base, :valor => self.valor,
      :juros => juros, :multa => multa
    nil
  end
  
  def data_limite_para_baixa_valida?
    return true if data_da_baixa.blank? || unidade.blank?
    limite = conta_type == 'PagamentoDeConta' ? unidade.lancamentoscontaspagar : unidade.lancamentoscontasreceber
    if (data_da_baixa.to_date) >= (Date.today - limite)
      true
    else
      false
    end
  end

  def validar_data_inicio_entre_limites
    return true if self.data_da_baixa.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if self.data_da_baixa.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def validar_datas_para_estorno(data)
    return true if unidade.blank?
    limite = unidade.limitediasparaestornodeparcelas
    if (data.to_date >= (Date.today - limite))
      true
    else
      false
    end
  end
  
  def validar_datas_para_troca(data)
    return true if unidade.blank?
    limite = unidade.lancamentoscontasreceber
    if (data.to_date >= (Date.today - limite))
      true
    else
      false
    end
  end
  
  def validar_datas_entre_limites(data)
    return true if data.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if data.to_date.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def validar_datas_para_funcionalidades
    return true if unidade.blank?
    limite = self.conta_type == 'PagamentoDeConta' ? unidade.lancamentoscontaspagar : unidade.lancamentoscontasreceber
    if (Date.today) >= (Date.today - limite)
      true
    else
      false
    end
  end

  def validar_data_inicio_entre_limites_para_funcionalidades
    return true if self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_minima.blank?
      if Date.today.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def data_limite_para_lancar_imposto(data)
    return true if data.blank? || unidade.blank?
    if (data) >= (Date.today - unidade.lancamentoscontaspagar)
      true
    else
      false
    end
  end

  def data_para_lancar_imposto_entre_periodo(data)
    return true if data.blank? || self.unidade.blank?
    if !self.unidade.data_limite_minima.blank? && !self.unidade.data_limite_maxima.blank?
      if data.between?(self.unidade.data_limite_minima.to_date, self.unidade.data_limite_maxima.to_date)
        true
      else
        false
      end
    end
  end

  def cancelar(usuario_corrente, justificativa = '', followup = true, todas_as_parcelas = false)
    begin
			Parcela.transaction do
        if self.conta.is_a?(RecebimentoDeConta) && self.situacao != QUITADA
          if self.conta.provisao == RecebimentoDeConta::SIM
            if ([Parcela::PENDENTE, Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::DESCONTO_EM_FOLHA,
                  Parcela::JURIDICO, Parcela::BAIXA_DO_CONSELHO, Parcela::ENVIADO_AO_DR].include?(self.situacao))
              self.situacao = CANCELADA
              if self.save false
                #if todas_as_parcelas
                self.conta.cancelando_parcela = true
                self.conta.valor_do_documento -= self.valor
                self.conta.save false
                if self.parcela_original
                  self.parcela_original.situacao = CANCELADA
                  self.parcela_original.save false
                  self.parcela_original.conta.cancelando_parcela = true
                  self.parcela_original.conta.valor_do_documento -= self.parcela_original.valor
                  self.parcela_original.conta.save false
                elsif self.parcela_filha
                  self.parcela_filha.situacao = CANCELADA
                  self.parcela_filha.save false
                  self.parcela_filha.conta.cancelando_parcela = true
                  self.parcela_filha.conta.valor_do_documento -= self.parcela_filha.valor
                  self.parcela_filha.conta.save false
                end
                self.conta.cancelando_parcela = false
              end
              HistoricoOperacao.cria_follow_up("Parcela numero #{self.numero} cancelada - Vencimento: #{self.data_vencimento} - Valor: #{(self.valor/100.0).real.real_formatado}", usuario_corrente, self.conta, justificativa, nil, self.valor) if followup
              return [true, 'Parcela cancelada com sucesso']
            else
              return [false, self.errors.full_messages.collect{|item| "* #{item}"}.join("\n")]
            end
            #end
          else
            self.situacao = CANCELADA
            if self.save false
              self.conta.cancelando_parcela = true
              self.conta.valor_do_documento -= self.valor
              self.conta.save false
              if self.parcela_original
                self.parcela_original.situacao = CANCELADA
                self.parcela_original.save false
                self.parcela_original.conta.cancelando_parcela = true
                self.parcela_original.conta.valor_do_documento -= self.parcela_original.valor
                self.parcela_original.conta.save false
              elsif self.parcela_filha
                self.parcela_filha.situacao = CANCELADA
                self.parcela_filha.save false
                self.parcela_filha.conta.cancelando_parcela = true
                self.parcela_filha.conta.valor_do_documento -= self.parcela_filha.valor
                self.parcela_filha.conta.save false
              end
              self.conta.cancelando_parcela = false
              HistoricoOperacao.cria_follow_up("Parcela numero #{self.numero} cancelada - Vencimento: #{self.data_vencimento} - Valor: #{(self.valor/100.0).real.real_formatado}", usuario_corrente, self.conta, justificativa, nil, self.valor) if followup
              return [true, 'Parcela cancelada com sucesso']
            end
          end
        end
			end
		rescue Exception => e
			[false, e.message]
		end
  end

  def baixar_parcela(ano, usuario, params)
    begin
      Parcela.transaction do
        calcula_porcentagem_do_rateio
        if params[:baixa_pela_dr] == "1"
          params[:baixa_pela_dr] = true
          self.baixando = false
          self.baixar_dr = true
        else
          params[:baixa_pela_dr] = nil
          self.baixando = true
          self.baixar_dr = false
        end
        self.ano_contabil_atual = ano

        if self.update_attributes!(params)
          if self.parcela_original
            self.parcela_original.situacao = QUITADA
            if self.baixar_dr
              self.parcela_original.baixa_pela_dr = true
            end
            self.parcela_original.data_da_baixa = self.data_da_baixa.to_date
            self.parcela_original.forma_de_pagamento = self.forma_de_pagamento
            self.parcela_original.valor_liquido = self.valor_liquido
            self.parcela_original.save false


            #            if self.forma_de_pagamento == BANCO
            #              self.parcela_original.forma_de_pagamento = nil
            #              self.parcela_original.conta_corrente =
            #              self.parcela_original.data_do_pagamento = nil
            #              self.parcela_original.numero_do_comprovante = nil
            #            elsif self.forma_de_pagamento == CHEQUE
            #              self.parcela_original.cheques.build
            #            elsif self.forma_de_pagamento == CARTAO
            #              self.parcela_original.cartoes.build
            #            end


          elsif self.parcela_filha
            self.parcela_filha.situacao = QUITADA
            if self.baixar_dr
              self.parcela_filha.baixa_pela_dr = true
            end
            self.parcela_filha.data_da_baixa = self.data_da_baixa.to_date
            self.parcela_filha.forma_de_pagamento = self.forma_de_pagamento
            self.parcela_filha.valor_liquido = self.valor_liquido
            self.parcela_filha.save false
          end
          if self.baixar_dr
            historico = "Foi realizada uma Baixa DR na parcela numero #{self.numero} - Valor: #{(self.valor_liquido/100.0).real.real_formatado} - Forma de pagamento: #{self.forma_de_pagamento_verbose} - Data de Vencimento: #{self.data_vencimento} - Data de Pagamento: #{self.data_da_baixa}"
          else
            historico = "Parcela numero #{self.numero} baixada - Valor: #{(self.valor_liquido/100.0).real.real_formatado} - Forma de pagamento: #{self.forma_de_pagamento_verbose} - Data de Vencimento: #{self.data_vencimento} - Data de Pagamento: #{self.data_da_baixa}"
          end
          HistoricoOperacao.cria_follow_up(historico, usuario, self.conta, nil, nil, self.valor_liquido)
        else
          self.cheques.build if self.cheques.blank?
          self.cartoes.build if self.cartoes.blank?
        end
        [true, 'Baixa na parcela realizada com sucesso!']
      end
    rescue Exception => e
      [false, e.message]
    end
  end

  def baixar_parcela_valid?(ano, params)
    calcula_porcentagem_do_rateio
    params[:baixa_pela_dr] = nil
    self.baixando = true
    self.baixar_dr = false
    self.ano_contabil_atual = ano
    self.attributes = params
    self.valid?
  end

  def verifica_situacoes
    [nil, PENDENTE, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA, ENVIADO_AO_DR, DEVEDORES_DUVIDOSOS_ATIVOS].include?(self.situacao)
  end

  def mostra_menu?
    [nil, PENDENTE, JURIDICO, QUITADA, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA, ENVIADO_AO_DR, DEVEDORES_DUVIDOSOS_ATIVOS, ESTORNADA].include?(self.situacao)
  end

  def valores_novos_recebimentos
    self.conta_type == 'RecebimentoDeConta' ? self.honorarios + self.protesto + self.taxa_boleto : 0
  end

  def baixando_dr(usuario)
    self.baixando = false
    self.baixar_dr = true
    self.baixa_pela_dr = true
    self.data_da_baixa = Date.today.to_s_br
    if self.save
      HistoricoOperacao.cria_follow_up("Foi realizada uma Baixa DR na parcela #{self.numero}", usuario, self.conta, nil,nil, self.valor)
    end
  end

  def calcula_porcentagem_do_rateio
    resultado ||= {}
    indice_rateio = 0
    # {id_rateio => {'porcentagem' => X, 'unidade_organizacional' => X, 'centro' => X, 'conta_contabil' => X}}
    self.dados_do_rateio.each do |key, value|
      #valor_rateio = self.dados_do_rateio[key]['valor'].real.to_f * 100
      valor_rateio = value['valor'].real.to_f * 100
      porcentagem = valor_rateio / (self.valor.real.to_f / 100)
      resultado[indice_rateio] ||= {}
      resultado[indice_rateio]['unidade_organizacional'] = self.dados_do_rateio[key]['unidade_organizacional_id']
      resultado[indice_rateio]['centro'] = self.dados_do_rateio[key]['centro_id']
      resultado[indice_rateio]['conta_contabil'] = self.dados_do_rateio[key]['conta_contabil_id']
      resultado[indice_rateio]['porcentagem'] = porcentagem
      indice_rateio += 1
    end
    self.calcula_porcentagem = resultado
  end

  def retorna_parcelas_filhas
    retorno = Parcela.find(:all, :conditions => ['parcela_mae_id = ? AND conta_type = ?', self.id, 'RecebimentoDeConta'])
    retorno
  end
  
  def calcula_desconto_em_juros_e_multas!(data_base = Date.today)
    return if conta_type == 'PagamentoDeConta'
    return if data_da_baixa
    valor_juros_e_multas = Gefin.calcular_juros_e_multas(:vencimento => self.data_vencimento, :data_base => data_base,
      :multa => self.conta.multa_por_atraso, :juros => self.conta.juros_por_atraso,
      :valor => self.valor)
    auxiliar_de_desconto = self.percentual_de_desconto ? self.percentual_de_desconto : 0
    valor_total_do_desconto = 0
    valor_juros_e_multas[0..1].each_with_index do |elemento, index|
      juro_ou_multa_com_desconto = ((elemento * auxiliar_de_desconto) / 100).round
      valor_total_do_desconto += juro_ou_multa_com_desconto
      index == 0 ? self.valor_dos_juros = elemento - juro_ou_multa_com_desconto : self.valor_da_multa = elemento - juro_ou_multa_com_desconto
    end
    self.valor_do_desconto = valor_total_do_desconto
    nil
  end

  def self.aplicar_projecao(recebimento_de_conta_id, params, usuario_corrente)
    begin
      if self.validar_datas_para_funcionalidades || self.validar_data_inicio_entre_limites_para_funcionalidades
        Parcela.transaction do
          conta_da_parcela = RecebimentoDeConta.find_by_id(recebimento_de_conta_id)
          if conta_da_parcela.historico_projecoes.is_a?(Array)
            numero_da_renegociacao = conta_da_parcela.historico_projecoes.last.first + 1
            conta_da_parcela.historico_projecoes << [numero_da_renegociacao, []]
          else
            numero_da_renegociacao = 1
            conta_da_parcela.historico_projecoes = [[numero_da_renegociacao, []]]
          end
          numero_da_nova_parcela = conta_da_parcela.parcelas.collect(&:numero).sort.last

          # Verifica Desconto Percentual Universal
          desconto_percentual_universal = params[:desconto_percentual_universal].to_f

          params[:parcelas].sort.each do |parcela_id, campos|
            if campos[:selecionada] == '1'
              # Cancela a parcela antiga..
              parcela = Parcela.find_by_id_and_conta_id(parcela_id, recebimento_de_conta_id)

              # Verifica Desconto Percentual Universal
              campos[:desconto_em_porcentagem] = desconto_percentual_universal if desconto_percentual_universal > 0

              # Verifica datas de vencimento
              return [false, 'O vencimento da nova parcela deve ser igual ou superior ao vencimento da parcela antiga.'] if parcela.data_vencimento.to_date > campos[:data_vencimento].to_date

              parcela.situacao = RENEGOCIADA

              valor_da_parcela_que_foi_cancelada = parcela.valor
              rateios_da_parcela = parcela.calcula_porcentagem_do_rateio
              parcela.save!
              HistoricoOperacao.cria_follow_up("Parcela #{parcela.numero} cancelada", usuario_corrente, conta_da_parcela)
              # Cria a parcela nova..
              numero_da_nova_parcela = numero_da_nova_parcela.to_i + 1
              valor_com_desconto = (((campos[:valor_da_multa_em_reais].to_f * 100.0).to_i + (campos[:valor_dos_juros_em_reais].to_f * 100.0).to_i) * campos[:desconto_em_porcentagem].to_f) / 100.0
              valor_da_nova_parcela = (campos[:valor_liquido_em_reais].to_f * 100.0).to_i - valor_com_desconto.to_i

              nova_parcela = conta_da_parcela.parcelas.create! :data_vencimento => campos[:data_vencimento].to_date, :percentual_de_desconto => (campos[:desconto_em_porcentagem].to_f * 100.0).to_i,
                :valor => valor_da_nova_parcela, :situacao => Parcela::PENDENTE, :conta => conta_da_parcela, :numero => numero_da_nova_parcela
              # E os novos rateios..
              soma_dos_valores_do_rateio = 0; numero_de_elementos_do_hash = 0
              rateios_da_parcela.each_pair do |_, hash_com_dados|
                valor_calculado_do_rateio = (((hash_com_dados['porcentagem'] * (nova_parcela.valor / 100.0)) / 100.0).round(2) * 100).to_i
                soma_dos_valores_do_rateio += valor_calculado_do_rateio; numero_de_elementos_do_hash += 1
                if numero_de_elementos_do_hash == rateios_da_parcela.length
                  valor_de_correcao = nova_parcela.valor - soma_dos_valores_do_rateio
                  valor_calculado_do_rateio = valor_calculado_do_rateio + valor_de_correcao
                end
                Rateio.create! :parcela => nova_parcela, :unidade_organizacional_id => hash_com_dados['unidade_organizacional'], :centro_id => hash_com_dados['centro'],
                  :conta_contabil_id => hash_com_dados['conta_contabil'], :valor => valor_calculado_do_rateio
              end
              conta_da_parcela.historico_projecoes[RecebimentoDeConta.procura_o_indice(conta_da_parcela.historico_projecoes, numero_da_renegociacao)].last << nova_parcela.id
              HistoricoOperacao.cria_follow_up("Parcela #{nova_parcela.numero} foi gerada proveniente da projeção de contrato", usuario_corrente, conta_da_parcela)
              # No final, salva o contrato com o valor atualizado
              conta_da_parcela.valor_do_documento = (conta_da_parcela.valor_do_documento - valor_da_parcela_que_foi_cancelada) + valor_da_nova_parcela
              conta_da_parcela.projetando = true
              conta_da_parcela.save!
              HistoricoOperacao.cria_follow_up("Contrato atualizado após a aplicação de projeção", usuario_corrente, conta_da_parcela)
            end
          end
          [true, "Projeção aplicada com sucesso!"]
        end
      else
        return [false, "Não é possível aplicar a projeção com os limites retroativos estabelecidos."]
      end
    rescue Exception => e
      [false, "Não foi possível aplicar a projeção!"]
    end
  end

  def baixar_parcialmente(ano, usuario, params)
    hash_contabil ||= {}
    hash_contabil['debito'] ||= {}
    hash_contabil['credito'] ||= {}
    lancamento_debito = []
    lancamento_credito = []
    begin
      Parcela.transaction do
        parcela_mae = Parcela.find(params['parcela_id'])
        diferenca_juros_multas = (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round + (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round
        numero = "#{parcela_mae.numero.to_i}.#{parcela_mae.retorna_parcelas_filhas.length + 1}"
        valor_nova_parcela = (params['valor_liquido'].real.to_f * 100).round

        if diferenca_juros_multas > valor_nova_parcela
          raise 'Insira um valor maior, porque o valor dos juros e multas é maior que o valor da parcela!'
        else
          diferenca = valor_nova_parcela - diferenca_juros_multas
        end

        # SOMENTE SE EXISTIR RATEIO
        if parcela_mae.conta.rateio == 1 && !parcela_mae.rateios.blank?
          valor_rateio = []
          porcentagens_rateios = []
          porcentagens_rateios = calcula_porcentagem_do_rateio
          rateios = parcela_mae.rateios.sort_by(&:valor)

          # CALCULANDO O VALOR DOS RATEIOS PARA O LANÇAMENTO CONTABIL
          porcentagens_rateios.sort_by {|key, value| value['porcentagem']}.each do |key, value|
            valor_rateio << ((value['porcentagem'].round(2) * diferenca) / 100).to_i
          end
          acrescimo = diferenca - valor_rateio.sum
          if valor_rateio.sum != diferenca
            valor_rateio[valor_rateio.length-1] = valor_rateio.last + acrescimo
          end
          # ---------------------- #

          1.upto(rateios.length) do |i|
            if diferenca > 0
              atualiza_valor_rateio = parcela_mae.dados_do_rateio["#{i}"]['valor'].to_f
              atualiza_valor_rateio -= valor_rateio[i-1].to_f / 100.0
              parcela_mae.dados_do_rateio["#{i}"]['valor'] = atualiza_valor_rateio
              rateios[i-1]['valor'] -= valor_rateio[i-1]

              if(rateios[i-1]['valor'] <= 0)
                raise 'Para realizar a baixa total da parcela, favor ir até a tela de baixa!'
              end

              rateios[i-1].save || (raise rateios[i-1].errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
            end
          end
        end
        # ---------------------- #

        if diferenca != parcela_mae.valor
          numero_original = parcela_mae.numero
          valor_original_parcela = parcela_mae.valor
          parcela_mae.valor = valor_original_parcela - diferenca
          parcela_mae.numero = numero
          parcela_mae.save || (raise parcela_mae.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))

          nova_parcela = Parcela.new(:parcela_mae_id => params['parcela_id'], :valor => diferenca,
            :conta_id => params['recebimento_de_conta_id'], :conta_type => 'RecebimentoDeConta',
            :data_vencimento => params['data_vencimento'], :ano_contabil_atual => ano,
            :historico => params['historico'], :conta_corrente_id => params['parcela_conta_corrente_id'])
          nova_parcela.save || raise(nova_parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))

          nova_parcela.baixando = true
          nova_parcela.data_da_baixa = params['parcela_data_da_baixa']
          nova_parcela.forma_de_pagamento = params['parcela_forma_de_pagamento']
          nova_parcela.valor_liquido = diferenca
          nova_parcela.numero_parcela_filha = numero_original
          nova_parcela.situacao = QUITADA
          if (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round > 0
            nova_parcela.valor_da_multa = (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_multa_id = params['parcela']['conta_contabil_multa_id']
            nova_parcela.unidade_organizacional_multa_id = params['parcela']['unidade_organizacional_multa_id']
            nova_parcela.centro_multa_id = params['parcela']['centro_multa_id']
          end
          if (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round > 0
            nova_parcela.valor_dos_juros = (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_juros_id = params['parcela']['conta_contabil_juros_id']
            nova_parcela.unidade_organizacional_juros_id = params['parcela']['unidade_organizacional_juros_id']
            nova_parcela.centro_juros_id = params['parcela']['centro_juros_id']
          end

          # CRIA OS CHEQUES QUANDO OCORRE UMA BAIXA POR ESSE TIPO
          if nova_parcela.cheques.blank? && nova_parcela.forma_de_pagamento == CHEQUE
            nova_parcela.cheques.build(:nome_do_titular => params['parcela']['cheques_attributes']['0']['nome_do_titular'],
              :banco_id => params['parcela']['cheques_attributes']['0']['banco_id'], :agencia => params['parcela']['cheques_attributes']['0']['agencia'],
              :conta => params['parcela']['cheques_attributes']['0']['conta'], :data_para_deposito => params['parcela']['cheques_attributes']['0']['data_para_deposito'],
              :prazo => params['parcela']['cheques_attributes']['0']['prazo'], :numero => params['parcela']['cheques_attributes']['0']['numero'],
              :conta_contabil_transitoria_id => params['parcela']['cheques_attributes']['0']['conta_contabil_transitoria_id'])
          end
          # ---------------------- #

          # CRIA OS CARTÕES QUANDO OCORRE UMA BAIXA POR ESSE TIPO
          if nova_parcela.cartoes.blank? && nova_parcela.forma_de_pagamento == CARTAO
            nova_parcela.cartoes.build(:nome_do_titular => params['parcela']['cartoes_attributes']['1']['nome_do_titular'],
              :bandeira => params['parcela']['cartoes_attributes']['1']['bandeira'], :numero => params['parcela']['cartoes_attributes']['1']['numero'],
              :validade => params['parcela']['cartoes_attributes']['1']['validade'])
          end
          # ---------------------- #

          # EFETUA OS LANÇAMENTOS CONTÁBEIS CASO O CONTRATO TENHA RATEIO
          if nova_parcela.rateios.blank? && nova_parcela.conta.rateio == 1
            nova_parcela.baixando_parcialmente = true
            1.upto(rateios.length) do |i|
              nova_parcela.rateios.build(:unidade_organizacional_id => rateios[i-1]['unidade_organizacional_id'],
                :centro_id => rateios[i-1]['centro_id'], :conta_contabil_id => rateios[i-1]['conta_contabil_id'],
                :valor => valor_rateio[i-1])

              if self.conta.provisao == RecebimentoDeConta::SIM
                unless self.conta.unidade.blank?
                  raise 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).blank?
                end
                insere_no_hash(hash_contabil, "credito", {:tipo => "C",
                    :unidade_organizacional => UnidadeOrganizacional.find(rateios[i-1]['unidade_organizacional_id']),
                    :plano_de_conta => self.conta.unidade.parametro_conta_valor_cliente(ano_contabil_atual).conta_contabil,
                    :centro => Centro.find(rateios[i-1]['centro_id']), :valor => valor_rateio[i-1]})
              else
                insere_no_hash(hash_contabil, "credito", {:tipo => "C",
                    :unidade_organizacional => UnidadeOrganizacional.find(rateios[i-1]['unidade_organizacional_id']),
                    :plano_de_conta => PlanoDeConta.find(rateios[i-1]['conta_contabil_id']),
                    :centro => Centro.find(rateios[i-1]['centro_id']), :valor => valor_rateio[i-1]})
              end
            end
            if nova_parcela.valor_da_multa > 0
              insere_no_hash(hash_contabil, "credito", {:tipo => "C",
                  :unidade_organizacional => nova_parcela.unidade_organizacional_multa,
                  :plano_de_conta => nova_parcela.conta_contabil_multa,
                  :centro => nova_parcela.centro_multa,
                  :valor => nova_parcela.valor_da_multa})
            end
            if nova_parcela.valor_dos_juros > 0
              insere_no_hash(hash_contabil, "credito", {:tipo => "C",
                  :unidade_organizacional => nova_parcela.unidade_organizacional_juros,
                  :plano_de_conta => nova_parcela.conta_contabil_juros,
                  :centro => nova_parcela.centro_juros,
                  :valor => nova_parcela.valor_dos_juros})
            end
            conta_corrente = ContasCorrente.find_by_unidade_id_and_identificador(nova_parcela.conta.unidade_id, ContasCorrente::CAIXA)
            unless conta_corrente.blank?
              conta_contabil = conta_corrente.conta_contabil
            end
            if nova_parcela.forma_de_pagamento == BANCO
              conta_contabil = nova_parcela.conta_corrente.conta_contabil
            elsif nova_parcela.forma_de_pagamento == CHEQUE
              conta_contabil = nova_parcela.cheques.first.conta_contabil_transitoria
            elsif nova_parcela.forma_de_pagamento == CARTAO
              if nova_parcela.conta.unidade.parametro_conta_valor_cartoes(nova_parcela.ano_contabil_atual, nova_parcela.cartoes.first.bandeira).blank?
                raise "Deve ser parametrizada uma conta contábil para o Cartão escolhido - #{nova_parcela.cartoes.first.bandeira_verbose}."
              else
                conta_contabil = nova_parcela.conta.unidade.parametro_conta_valor_cartoes(nova_parcela.ano_contabil_atual, nova_parcela.cartoes.first.bandeira).conta_contabil
              end
            end
            insere_no_hash(hash_contabil, 'debito', {:tipo => 'D',
                :unidade_organizacional => nova_parcela.conta.unidade_organizacional,
                :plano_de_conta => conta_contabil,
                :centro => parcela_mae.conta.centro,
                :valor => valor_nova_parcela})
            hash_contabil['debito'].each do |chave, conteudo|
              lancamento_debito << conteudo
            end
            hash_contabil['credito'].each do |chave, conteudo|
              lancamento_credito << conteudo
            end
            Movimento.lanca_contabilidade(ano, [
                {:conta => nova_parcela.conta, :historico => nova_parcela.historico,
                  :numero_de_controle => nova_parcela.conta.numero_de_controle,
                  :data_lancamento => nova_parcela.data_da_baixa, :tipo_lancamento => 'S',
                  :tipo_documento => nova_parcela.conta.tipo_de_documento,
                  :provisao =>  Movimento::BAIXA, :pessoa_id => nova_parcela.conta.pessoa_id,
                  :numero_da_parcela => numero_original, :parcela_id => nova_parcela.id},
                lancamento_debito, lancamento_credito], nova_parcela.conta.unidade_id)
          end
          # ---------------------- #

          if nova_parcela.save
            #            if parcela_mae.parcela_original
            #              parcela_mae.parcela_original = parcela_mae.clone
            #              parcela_mae.parcela_original.save!
            #            elsif parcela_mae.parcela_filha
            #              parcela_mae.parcela_filha = parcela_mae.clone
            #              parcela_mae.parcela_filha.save!
            #              nova_parcela_dr = nova_parcela.clone
            #              nova_parcela_dr.conta = parcela_mae.parcela_filha
            #            end
            nova_parcela.baixando = false
            HistoricoOperacao.cria_follow_up("Parcela #{parcela_mae.numero.to_i} baixada parcialmente (#{nova_parcela.numero_parcela_filha})", usuario, parcela_mae.conta, nil , nil, nova_parcela.valor) if !nova_parcela.id.blank?
          else
            raise(nova_parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
          end
        else
          raise 'Para realizar a baixa total da parcela, favor ir até a tela de baixa!'
        end
      end
      [true, 'Baixa parcial realizada com sucesso!']
    rescue Exception => e
      #LANCAMENTOS_LOGGER.erro e.backtrace.join("\n")
      [false, e.message]
    end
  end

  def to_boleto(params_convenio)
    boleto = BancoBrasil.new
    if(params_convenio.blank?)
      p "oi1"
      return nil
    end
    convenio = Convenio.find_by_id(params_convenio)
    p "oi2"
    #boleto.cedente = self.unidade.nome
    boleto.cedente = self.unidade.nome_cedente.blank? ? 'Preencha o nome do Cedente no cadastro da Unidade' : self.unidade.nome_cedente
    boleto.documento_cedente = self.unidade.cnpj.numero.scan(/[(0-9)]/).join
    boleto.sacado = self.conta.pessoa.nome
    boleto.sacado_documento = self.conta.pessoa.fisica? ? self.conta.pessoa.cpf.numero.scan(/[(0-9)]/).join : self.conta.pessoa.cnpj.numero.scan(/[(0-9)]/).join
    boleto.valor = self.valor / 100
    boleto.aceite = 'N'
    boleto.agencia = convenio.contas_corrente.agencia.numero.scan(/[(0-9)]/).join if convenio.contas_corrente.agencia.numero
    boleto.conta_corrente = convenio.contas_corrente.numero_conta.scan(/[(0-9)]/).join #+ '' + convenio.contas_corrente.digito_verificador.scan(/[(0-9)]/).join
    boleto.carteira = convenio.numero_carteira unless convenio.numero_carteira.blank?

    # TODO: Verificar do que se trata este codigo_servico
    boleto.codigo_servico = true

    # BB
    # O que diferencia um tipo de boleto de outro, dentro do Banco do Brasil é a quantidade de dígitos do convênio.
    boleto.convenio = convenio.numero.scan(/[(0-9)]/).join

    size_numero_documento = case boleto.convenio.size
    when 8
      9
    when 7
      10
    when 6
      if boleto.codigo_servico == false
        1
      else
        7
      end
    when 4
      1
    else
      return nil
    end

    boleto.numero_documento = self.id.to_s.last(size_numero_documento).rjust(size_numero_documento, boleto.conta_corrente.to_s)
    #boleto.numero_documento = '5659'
    boleto.dias_vencimento = self.data_vencimento.to_date - Date.today
    boleto.data_documento = Date.today

    sacado = self.conta.pessoa
    dados = sacado.endereco.upcase + ', '
    dados += sacado.numero ? (sacado.numero.upcase) : ', '
    dados += sacado.bairro ? (sacado.bairro.upcase + ' - ') : ''
    dados += sacado.cep ? (sacado.cep.upcase + ' - ') : ''
    dados += sacado.localidade ? (sacado.localidade.nome.upcase + ' - ' ) : ''
    dados += sacado.localidade ? sacado.localidade.uf.upcase : ''
    boleto.sacado_endereco = dados

    boleto.instrucao1 = convenio.instrucoes[0] unless convenio.instrucoes[0].blank?
    boleto.instrucao2 = convenio.instrucoes[1] unless convenio.instrucoes[1].blank?
    boleto.instrucao3 = convenio.instrucoes[2] unless convenio.instrucoes[2].blank?
    boleto.instrucao4 = convenio.instrucoes[3] unless convenio.instrucoes[3].blank?
    boleto.instrucao5 = convenio.instrucoes[4] unless convenio.instrucoes[4].blank?
    boleto.instrucao6 = convenio.instrucoes[5] unless convenio.instrucoes[5].blank?

    return boleto
  end

  def add_arquivo_remessa(id)
    if self.arquivo_remessa_id.blank?
      self.arquivo_remessa_id = id
      self.save
    else
      false
    end
  end

  def remove_arquivo_remessa
    self.arquivo_remessa_id = nil
    self.save
  end

  def pode_add_ao_arquivo?(arquivo_id)
    if arquivo_id.blank?
      self.arquivo_remessa_id.blank? ? true : false
    else
      if self.arquivo_remessa_id.blank?
        true
      else
        self.arquivo_remessa_id == arquivo_id ? true : false
      end
    end
  end

  def vencida?
    self.situacao.verifica_situacoes && self.data_vencimento.to_date >= Date.today ? true : false
  end

  def dias_em_atraso
    if self.data_da_baixa.blank?
      (Date.today - self.data_vencimento.to_date).day.to_i / 86400
    else
      0
    end
  end

  def self.enviar_ao_dr(usuario, parcelas_id)
    begin
      RecebimentoDeConta.transaction do
        unless parcelas_id.blank?
          parcelas_id.each do |parcela_id|
            parcela_atual = Parcela.find_by_id(parcela_id)
            return [false, "A parcela com ID: #{parcela_id} não pôde ser enviada ao DR"] unless parcela_atual
            conta_atual = parcela_atual.conta
            return [false, 'A parcela deve pertencer à um Recebimento de Conta.'] unless conta_atual.is_a?(RecebimentoDeConta)
            return [false, 'Esta parcela é uma parcela espelho e não pode ser enviada ao DR.'] if conta_atual.recebimento_de_conta_mae
            #  conta_dr = conta_atual.recebimento_de_conta_mae_check ? conta_atual.recebimento_de_conta_filha : conta_atual.clone
            #  conta_dr.recebimento_de_conta_mae = conta_atual
            #  conta_dr.usuario_corrente = usuario
            #  conta_dr.unidade = conta_dr.recebimento_de_conta_mae.unidade.unidade_filha
            #  conta_dr.parcelas_geradas = true
            #  conta_dr.evadindo = true
            #  conta_dr.save false
            #  conta_dr.evadindo = false
            
            #  conta_atual.recebimento_de_conta_mae_check = true
            # conta_atual.recebimento_de_conta_filha = conta_dr
            conta_atual.evadindo = true
            conta_atual.save false
            conta_atual.evadindo = false
           
            # parcela_dr = parcela_atual.parcela_original_check ? parcela_atual.parcela_filha : parcela_atual.clone
            #  parcela_dr.parcela_original = parcela_atual
            #  parcela_dr.conta = conta_dr
            #  rateios = parcela_atual.rateios
            #  1.upto(rateios.length) do |i|
            #    parcela_dr.rateios.build(:unidade_organizacional_id => rateios[i-1]['unidade_organizacional_id'],
            #     :centro_id => rateios[i-1]['centro_id'], :conta_contabil_id => rateios[i-1]['conta_contabil_id'],
            #    :valor => rateios[i-1]['valor'])
            #end
            parcela_atual.parcela_original_check = true
            parcela_atual.situacao = ENVIADO_AO_DR
            parcela_atual.data_envio_ao_dr = Date.today
            parcela_atual.save false
             HistoricoOperacao.cria_follow_up("A parcela #{parcela_atual.numero} foi enviada ao DR", usuario, parcela_atual.conta, nil, nil, parcela_atual.valor)
            #parcela_dr = parcela_atual.parcela_filha
            #  parcela_dr.situacao = ENVIADO_AO_DR
            #  parcela_dr.save false
          end
        else
          return [false, 'Selecione pelo menos uma parcela para executar o envio ao DR!']
        end
        [true, 'Parcelas enviadas ao DR com sucesso']
      end
    rescue Exception => e
      p
      [false,  e.backtrace]
    end
  end

  def multa_original
    if self.ax_multa.blank?
      self.valor_da_multa
    else
      self.ax_multa
    end
  end

  def juros_original
    if self.ax_juros.blank?
      self.valor_dos_juros
    else
      self.ax_juros
    end
  end

  def esta_dentro_da_faixa_de_dias_permitido_para_atualizacao_de_parcelas?
    return true if self.data_vencimento.blank? || self.conta.unidade.blank?
    limite = self.conta_type == 'PagamentoDeConta' ? self.conta.unidade.lancamentoscontaspagar : self.conta.unidade.lancamentoscontasreceber
    if (self.data_vencimento.to_date) >= (Date.today - limite)
      true
    else
      false
    end
  end

  def self.situacoes_para_cabecalho(params_situacoes, params_baixa_dr)
    retorno = []
    retorno << 'Quitadas - Baixa DR' unless params_baixa_dr.blank?
    unless params_situacoes.blank?
      retorno << 'Atrasadas' if params_situacoes.include?('atrasada')
      retorno << 'Baixa do Conselho' if params_situacoes.include?(BAIXA_DO_CONSELHO.to_s)
      retorno << 'Canceladas' if params_situacoes.include?(CANCELADA.to_s)
      retorno << 'Desconto em Folha' if params_situacoes.include?(DESCONTO_EM_FOLHA.to_s)
      retorno << 'Enviadas ao DR' if params_situacoes.include?(ENVIADO_AO_DR.to_s)
      retorno << 'Evadidas' if params_situacoes.include?(EVADIDA.to_s)
      retorno << 'Juridíco' if params_situacoes.include?(JURIDICO.to_s)
      retorno << 'Perdas no Recebimento de Creditos - Clientes' if params_situacoes.include?(DEVEDORES_DUVIDOSOS_ATIVOS.to_s)
      retorno << 'Permuta' if params_situacoes.include?(PERMUTA.to_s)
      retorno << 'Quitadas' if params_situacoes.include?(QUITADA.to_s)
      retorno << 'Renegociadas' if params_situacoes.include?(RENEGOCIADA.to_s)
      retorno << 'Vincendas' if params_situacoes.include?('vincenda')
    end
    retorno
  end

  def efetuar_troca_de_pagamento(params, current_user, ano_sessao)
    begin
      Parcela.transaction do
        forma_de_pagamento = params['forma_de_pagamento']
        data_da_troca = params['data_troca']
        return [false, 'O campo Data da troca deve ser preenchido'] if data_da_troca.blank?
        return [false, 'O campo Forma de pagamento deve ser preenchido'] if forma_de_pagamento.blank?
        if validar_datas_entre_limites(data_da_troca) || validar_datas_para_troca(data_da_troca)
          forma_de_pagamento_antiga = self.forma_de_pagamento

          if forma_de_pagamento_antiga == CARTAO
            cartao_antigo = self.cartoes.first
          end
          if forma_de_pagamento_antiga == CHEQUE
            cheque_antigo = self.cheques.first
          end

          if self.forma_de_pagamento == CHEQUE
            self.cheques.each{|ch| ch.situacao = Cheque::TROCADO; ch.save!}
            self.cheques.reload
          elsif self.forma_de_pagamento == CARTAO
            self.cartoes.each{|cr| cr.situacao = Cartao::TROCADO; cr.save!}
            self.cartoes.reload
          end
          if forma_de_pagamento == '1' # => DINHEIRO
            #return [false, 'O campo Data de Vencimento deve ser preenchido'] if params['data_vencimento'].blank?
            self.forma_de_pagamento = DINHEIRO
            #self.data_vencimento = params['data_vencimento'].to_date
          elsif forma_de_pagamento == '2' # => BANCO
            return [false, 'O campo conta corrente deve ser preenchido'] if params['banco']['conta_corrente_id'].blank?
            conta_corrente = ContasCorrente.find_by_id(params['banco']['conta_corrente_id'])
            return [false, 'A conta corrente selecionada é inválida'] unless conta_corrente
            self.forma_de_pagamento = BANCO
            self.conta_corrente = conta_corrente
          elsif forma_de_pagamento == '3' # => CHEQUE
            cheque_except = []
            cheque_except << 'O campo Tipo de Cheque deve ser preenchido' if params['cheques']['prazo'].blank?
            cheque_except << 'O campo Data para Depósito deve ser preenchido' if params['cheques']['data_para_deposito'].blank?
            cheque_except << 'O campo Conta Contábil Transitória deve ser preenchido' if params['cheques']['conta_contabil_transitoria_nome'].blank? && params['cheques']['prazo'] == '2'
            cheque_except << 'O campo Banco deve ser preenchido' if params['cheques']['banco_id'].blank?
            cheque_except << 'O campo Nome do Titular deve ser preenchido' if params['cheques']['nome_do_titular'].blank?
            cheque_except << 'O campo Agência deve ser preenchido' if params['cheques']['agencia'].blank?
            cheque_except << 'O campo Conta do Cheque deve ser preenchido' if params['cheques']['conta'].blank?
            cheque_except << 'O campo Número do Cheque deve ser preenchido' if params['cheques']['numero'].blank?          
            unless cheque_except.blank?
              return [false, cheque_except.join("\n")]
            end
            if params['cheques']['prazo'] == '1'
              conta_contabil_cheque = ContasCorrente.find_by_unidade_id_and_identificador(self.unidade.id, ContasCorrente::CAIXA).conta_contabil_id
            else
              conta_contabil_cheque = params['cheques']['conta_contabil_transitoria_id']
            end
            if !self.cheques.blank?
              self.cheques.first.destroy
              self.cheques.reload
            end
            self.forma_de_pagamento = CHEQUE
            self.cheques.build(:nome_do_titular => params["cheques"]["nome_do_titular"],
              :banco_id => params["cheques"]["banco_id"], :agencia => params["cheques"]["agencia"],
              :conta => params["cheques"]["conta"], :data_para_deposito => params["cheques"]["data_para_deposito"],
              :prazo => params["cheques"]["prazo"], :numero => params["cheques"]["numero"],
              :conta_contabil_transitoria_id => conta_contabil_cheque)
          elsif forma_de_pagamento == '4' # => CARTÃO
            cartao_except = []
            cartao_except << 'O campo Nome do Titular deve ser preenchido' if params['cartoes']['nome_do_titular'].blank?
            cartao_except << 'O campo Bandeira deve ser preenchido' if params['cartoes']['bandeira'].blank?
            cartao_except << 'O campo Validade do Cartão deve ser preenchido' if params['cartoes']['validade'].blank?
            cartao_except << 'O campo Número do Cartão deve ser preenchido' if params['cartoes']['numero'].blank?
            unless cartao_except.blank?
              return [false, cartao_except.join("\n")]
            end
            if !self.cartoes.blank?
              self.cartoes.first.destroy
              self.cartoes.reload
            end
            self.forma_de_pagamento = CARTAO
            self.cartoes.build(:bandeira => params["cartoes"]["bandeira"], :numero => params["cartoes"]["numero"],
              :nome_do_titular => params["cartoes"]["nome_do_titular"], :validade => params["cartoes"]["validade"])
          end
          self.save!
          self.reload

          movimento = Movimento.find(:last, :conditions => ['parcela_id = ? AND provisao = ?', self.id, Movimento::BAIXA])
          novo_mov = movimento.clone
          novo_mov.historico = self.historico + ' (Troca de forma de pagamento)'
          novo_mov.tipo_lancamento = 'A'
          novo_mov.tipo_documento = self.conta.tipo_de_documento
          novo_mov.data_lancamento = data_da_troca.to_date
          novo_mov.provisao = Movimento::PROVISAO
          novo_mov.pessoa_id = self.conta.pessoa_id
          novo_mov.numero_da_parcela = self.numero
          novo_mov.valor_total = self.valor_liquido
          novo_mov.save!

          centro_empresa = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', ano_sessao, self.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
          unidade_organizacional_empresa = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', ano_sessao, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

          #CREDITO
          conta_corrente_credito = ContasCorrente.find_by_unidade_id_and_identificador(self.conta.unidade_id, ContasCorrente::CAIXA)
          unless conta_corrente_credito.blank?
            conta_contabil_credito = conta_corrente_credito.conta_contabil
          end
          if forma_de_pagamento_antiga == BANCO
            conta_contabil_credito = self.conta_corrente.conta_contabil
          elsif forma_de_pagamento_antiga == CHEQUE
            conta_contabil_credito = cheque_antigo.conta_contabil_transitoria
          elsif forma_de_pagamento_antiga == CARTAO
            if self.conta.unidade.parametro_conta_valor_cartoes(ano_sessao, cartao_antigo.bandeira).blank?
              raise "Deve ser parametrizada uma conta contábil para o Cartão escolhido - #{self.cartoes.first.bandeira_verbose}."
            else
              conta_contabil_credito = self.conta.unidade.parametro_conta_valor_cartoes(ano_sessao, cartao_antigo.bandeira).conta_contabil
            end
          end
          ItensMovimento.create!({:movimento_id => novo_mov.id, :tipo => 'C', :centro => centro_empresa,
              :unidade_organizacional => unidade_organizacional_empresa, :plano_de_conta => conta_contabil_credito, 
              :valor => self.valor_liquido})

          #DEBITO
          conta_corrente_debito = ContasCorrente.find_by_unidade_id_and_identificador(self.conta.unidade_id, ContasCorrente::CAIXA)
          unless conta_corrente_debito.blank?
            conta_contabil_debito = conta_corrente_debito.conta_contabil
          end
          if self.forma_de_pagamento == BANCO
            conta_contabil_debito = self.conta_corrente.conta_contabil
          elsif self.forma_de_pagamento == CHEQUE
            conta_contabil_debito = self.cheques.first.conta_contabil_transitoria
          elsif self.forma_de_pagamento == CARTAO
            if self.conta.unidade.parametro_conta_valor_cartoes(ano_sessao, self.cartoes.first.bandeira).blank?
              raise "Deve ser parametrizada uma conta contábil para o Cartão escolhido - #{self.cartoes.first.bandeira_verbose}."
            else
              conta_contabil_debito = self.conta.unidade.parametro_conta_valor_cartoes(ano_sessao, self.cartoes.first.bandeira).conta_contabil
            end
          end
          ItensMovimento.create!({:movimento_id => novo_mov.id, :tipo => 'D', :centro => centro_empresa,
              :unidade_organizacional => unidade_organizacional_empresa, :plano_de_conta => conta_contabil_debito,
              :valor => self.valor_liquido})

          HistoricoOperacao.cria_follow_up("A parcela #{self.numero} teve sua forma de pagamento trocada para #{self.forma_de_pagamento_verbose}", current_user, self.conta, nil, nil, self.valor)        
          return [true, 'Procedimento efetuado com sucesso']
        else
          return [false, 'A operação não pode ser efetuada pois excedeu o limite de dias permitido!']
        end
      end
    rescue Exception => e
      return [false, e.message]
    end
  end

  def cancelar_parcela_contrato_cancelado(params, current_user, ano_sessao)
    begin
      Parcela.transaction do
        return [false, 'O campo Justificativa deve ser preenchido'] if params['justificativa'].blank?
        self.cancelando_com_ctr_canc = true
        self.situacao = CANCELADA
        self.save!
        self.cancelando_com_ctr_canc = false
        
        lancamento_credito = []
        lancamento_debito = []
        unless self.unidade.blank?
          raise 'Deve ser parametrizada uma conta contábil do tipo Cliente.' if self.conta.unidade.parametro_conta_valor_cliente(ano_sessao).blank?
          raise 'Deve ser parametrizada uma conta contábil do tipo Faturamento.' if self.conta.unidade.parametro_conta_valor_faturamento(ano_sessao).blank?
        end
        conta_contabil_cliente = self.unidade.parametro_conta_valor_cliente(ano_sessao).conta_contabil
        conta_contabil_faturamento = self.unidade.parametro_conta_valor_faturamento(ano_sessao).conta_contabil
        centro_empresa = Centro.first(:conditions => ["(codigo_centro = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999999999', ano_sessao, self.unidade.entidade_id]) || raise("Não existe um Centro de Responsabilidade Empresa válido.")
        unidade_organizacional_empresa = UnidadeOrganizacional.first :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?) AND (entidade_id = ?)", '9999999999', ano_sessao, self.unidade.entidade_id] || (raise "Não existe uma Unidade Organizacional Empresa válido.")

        lancamento_debito << {:tipo => 'D', :unidade_organizacional => unidade_organizacional_empresa,
          :plano_de_conta => conta_contabil_faturamento, :centro => centro_empresa, :valor => self.valor}
        lancamento_credito << {:tipo => 'C', :unidade_organizacional => unidade_organizacional_empresa,
          :plano_de_conta => conta_contabil_cliente, :centro => centro_empresa, :valor => self.valor}

        Movimento.lanca_contabilidade(ano_sessao, [
            {:conta => self.conta, :parcela_id => self.id, :data_lancamento => Date.today,
              :numero_de_controle => self.conta.numero_de_controle, :tipo_lancamento => 'B',
              :tipo_documento => self.conta.tipo_de_documento, :provisao => Movimento::PROVISAO,
              :pessoa_id => self.conta.pessoa_id,
              :historico => "#{self.conta.historico} (Cancelamento de Parcela de Contrato Cancelado/Evadido no DR)"},
            lancamento_debito, lancamento_credito], self.conta.unidade_id)

        HistoricoOperacao.cria_follow_up("A parcela #{self.numero} foi cancelada", current_user, self.conta, params['justificativa'], nil, self.valor)
        return [true, 'Parcela cancelada com sucesso!']
      end
    rescue Exception => e
      return [false, e.message]
    end
  end

  def baixar_parcialmente_contas_a_pagar(ano, usuario, params)
    hash_contabil ||= {}
    hash_contabil['debito'] ||= {}
    hash_contabil['credito'] ||= {}
    lancamento_debito = []
    lancamento_credito = []
    begin
      Parcela.transaction do
        parcela_mae = Parcela.find(params['parcela_id'])
        lancamento_impostos = parcela_mae.lancamento_impostos.clone
        valor_dos_impostos = parcela_mae.lancamento_impostos.sum(:valor, :conditions => ['impostos.classificacao = ?', Imposto::RETEM], :include => :imposto)
        numero = "#{parcela_mae.numero.to_i}.#{parcela_mae.retorna_parcelas_filhas.length + 1}"
        valor_nova_parcela = (params['valor_liquido'].real.to_f * 100).round
        diferenca_juros_multas = (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round + (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round
        diferenca_irrf_outros_impostos = (params['parcela']['irrf_em_reais'].real.to_f * 100).round + (params['parcela']['outros_impostos_em_reais'].real.to_f * 100).round

        if (diferenca_juros_multas + diferenca_irrf_outros_impostos) > valor_nova_parcela
          raise 'Insira um valor maior, porque o valor dos juros e multas é maior que o valor da parcela!'
        else
          diferenca = valor_nova_parcela - diferenca_juros_multas
          diferenca_com_impostos = parcela_mae.valor - diferenca - diferenca_juros_multas - valor_dos_impostos
        end

        #SOMENTE SE EXISTIR RATEIO
        if parcela_mae.conta.rateio == 1 && !parcela_mae.rateios.blank?
          valor_rateio = []
          valor_rateio_nova_parc = []
          porcentagens_rateios = []
          porcentagens_rateios = calcula_porcentagem_do_rateio
          porcentagens_rateios_nova_parc = []
          porcentagens_rateios_nova_parc = calcula_porcentagem_do_rateio
          rateios = parcela_mae.rateios

          #RATEIOS DA PARCELA MÃE
          porcentagens_rateios.each do |_, value|
            valor_rateio << ((value['porcentagem'].round(2) * diferenca_com_impostos) / 100).to_i
          end
          acrescimo = diferenca_com_impostos - valor_rateio.sum
          if valor_rateio.sum != diferenca_com_impostos
            valor_rateio[valor_rateio.length-1] = valor_rateio.last + acrescimo
          end

          #RATEIOS DA NOVA PARCELA
          porcentagens_rateios_nova_parc.each do |_, value|
            valor_rateio_nova_parc << ((value['porcentagem'].round(2) * diferenca) / 100).to_i
          end
          acrescimo_nova_parc = diferenca - valor_rateio_nova_parc.sum
          if valor_rateio_nova_parc.sum != diferenca
            valor_rateio_nova_parc[valor_rateio_nova_parc.length-1] = valor_rateio_nova_parc.last + acrescimo_nova_parc
          end

          1.upto(rateios.length) do |i|
            if diferenca_com_impostos > 0
              valor_parcela_rateio = parcela_mae.dados_do_rateio["#{i}"]['valor'].to_f
              #atualiza_valor_rateio -= valor_rateio[i-1].to_f / 100.0
              atualiza_valor_rateio = (valor_rateio[i-1].to_f / 100.0).to_f
              parcela_mae.dados_do_rateio["#{i}"]['valor'] = atualiza_valor_rateio
              valor_ajustado = ((valor_parcela_rateio - atualiza_valor_rateio) *  100).round.to_i
              rateios[i-1]['valor'] -= valor_ajustado
              
              if(rateios[i-1]['valor'] <= 0)
                raise 'Para realizar a baixa total da parcela, favor ir até a tela de baixa!'
              end

              rateios[i-1].save || (raise rateios[i-1].errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
            end
          end
        end
        #----------------------#        
        
        if diferenca != parcela_mae.valor
          numero_original = parcela_mae.numero
          novo_valor_parcela_mae = parcela_mae.valor - diferenca - valor_dos_impostos
          parcela_mae.valor = novo_valor_parcela_mae
          parcela_mae.valor_liquido = novo_valor_parcela_mae
          parcela_mae.numero = numero
          parcela_mae.dados_do_imposto = {}
          parcela_mae.save || (raise parcela_mae.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))

          nova_parcela = Parcela.new(:parcela_mae_id => params['parcela_id'], :valor => diferenca,
            :conta_id => params['pagamento_de_conta_id'],
            :conta_type => 'PagamentoDeConta', :data_vencimento => params['data_vencimento'], :ano_contabil_atual => ano,
            :historico => params['historico'], :conta_corrente_id => params['parcela_conta_corrente_id'],
            :numero_parcela_filha => numero_original, :situacao => QUITADA)
          nova_parcela.save || raise(nova_parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
          nova_parcela.baixando = true
          nova_parcela.data_da_baixa = params['parcela_data_da_baixa']
          nova_parcela.forma_de_pagamento = params['parcela_forma_de_pagamento']
          nova_parcela.valor_liquido = diferenca

          lancamento_impostos.each do |lanc|
            lanc.parcela_id = nova_parcela.id
            lanc.save false
          end

          if (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round > 0
            nova_parcela.valor_da_multa = (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_multa_id = params['parcela']['conta_contabil_multa_id']
            nova_parcela.unidade_organizacional_multa_id = params['parcela']['unidade_organizacional_multa_id']
            nova_parcela.centro_multa_id = params['parcela']['centro_multa_id']
          end
          if (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round > 0
            nova_parcela.valor_dos_juros = (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_juros_id = params['parcela']['conta_contabil_juros_id']
            nova_parcela.unidade_organizacional_juros_id = params['parcela']['unidade_organizacional_juros_id']
            nova_parcela.centro_juros_id = params['parcela']['centro_juros_id']
          end
          if (params['parcela']['irrf_em_reais'].real.to_f * 100).round > 0
            nova_parcela.irrf = (params['parcela']['irrf_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_irrf_id = params['parcela']['conta_contabil_irrf_id']
            nova_parcela.unidade_organizacional_irrf_id = params['parcela']['unidade_organizacional_irrf_id']
            nova_parcela.centro_irrf_id = params['parcela']['centro_irrf_id']
          end
          if (params['parcela']['outros_impostos_em_reais'].real.to_f * 100).round > 0
            nova_parcela.outros_impostos = (params['parcela']['outros_impostos_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_outros_impostos_id = params['parcela']['conta_contabil_outros_impostos_id']
            nova_parcela.unidade_organizacional_outros_impostos_id = params['parcela']['unidade_organizacional_outros_impostos_id']
            nova_parcela.centro_outros_impostos_id = params['parcela']['centro_outros_impostos_id']
          end

          valor_da_parcela_para_lancamento_debito = nova_parcela.valor - (nova_parcela.valor_da_multa + nova_parcela.valor_dos_juros)
          #EFETUA OS LANÇAMENTOS CONTÁBEIS PARA CONTRATO COM RATEIO
          if nova_parcela.rateios.blank? && nova_parcela.conta.rateio == 1
            nova_parcela.baixando_parcialmente = true
            1.upto(rateios.length) do |i|
              nova_parcela.rateios.build(:unidade_organizacional_id => rateios[i-1]['unidade_organizacional_id'], :centro_id => rateios[i-1]['centro_id'],
                :conta_contabil_id => rateios[i-1]['conta_contabil_id'], :valor => valor_rateio_nova_parc[i-1])
            end
            if parcela_mae.conta.provisao == PagamentoDeConta::SIM
              insere_no_hash(hash_contabil, 'debito', {:tipo => 'D',
                  :unidade_organizacional => parcela_mae.conta.unidade_organizacional, :centro => parcela_mae.conta.centro,
                  :plano_de_conta => parcela_mae.conta.conta_contabil_pessoa, :valor => valor_da_parcela_para_lancamento_debito})
            else
              insere_no_hash(hash_contabil, 'debito', {:tipo => 'D',
                  :unidade_organizacional => parcela_mae.conta.unidade_organizacional, :centro => parcela_mae.conta.centro, 
                  :plano_de_conta => parcela_mae.conta.conta_contabil_despesa, :valor => valor_da_parcela_para_lancamento_debito})
            end

            if nova_parcela.valor_da_multa > 0
              insere_no_hash(hash_contabil, 'debito', {:tipo => 'D',
                  :unidade_organizacional => nova_parcela.unidade_organizacional_multa, :centro => nova_parcela.centro_multa,
                  :plano_de_conta => nova_parcela.conta_contabil_multa, :valor => nova_parcela.valor_da_multa})
            end
            if nova_parcela.valor_dos_juros > 0
              insere_no_hash(hash_contabil, 'debito', {:tipo => 'D',
                  :unidade_organizacional => nova_parcela.unidade_organizacional_juros, :centro => nova_parcela.centro_juros,
                  :plano_de_conta => nova_parcela.conta_contabil_juros, :valor => nova_parcela.valor_dos_juros})
            end
            if nova_parcela.irrf > 0
              insere_no_hash(hash_contabil, 'credito', {:tipo => 'C',
                  :unidade_organizacional => nova_parcela.unidade_organizacional_irrf, :centro => nova_parcela.centro_irrf,
                  :plano_de_conta => nova_parcela.conta_contabil_irrf, :valor => nova_parcela.irrf})
            end
            if nova_parcela.outros_impostos > 0
              insere_no_hash(hash_contabil, 'credito', {:tipo => 'C',
                  :unidade_organizacional => nova_parcela.unidade_organizacional_outros_impostos, :centro => nova_parcela.centro_outros_impostos,
                  :plano_de_conta => nova_parcela.conta_contabil_outros_impostos, :valor => nova_parcela.outros_impostos})
            end

            conta_corrente = ContasCorrente.find_by_unidade_id_and_identificador(nova_parcela.conta.unidade_id, ContasCorrente::CAIXA)
            unless conta_corrente.blank?
              conta_contabil = conta_corrente.conta_contabil
            end
            if params['parcela_forma_de_pagamento'].to_i == BANCO
              nova_parcela.numero_do_comprovante = params['numero_do_comprovante']
              conta_contabil = nova_parcela.conta_corrente.conta_contabil
            end

            valor_da_parcela_para_lancamento_credito = nova_parcela.valor - (nova_parcela.irrf + nova_parcela.outros_impostos)
            insere_no_hash(hash_contabil, 'credito', {:tipo => 'C',
                :unidade_organizacional => nova_parcela.conta.unidade_organizacional, :centro => parcela_mae.conta.centro,
                :plano_de_conta => conta_contabil, :valor => valor_da_parcela_para_lancamento_credito})

            hash_contabil['debito'].each do |chave, conteudo|
              lancamento_debito << conteudo
            end
            hash_contabil['credito'].each do |chave, conteudo|
              lancamento_credito << conteudo
            end

            Movimento.lanca_contabilidade(ano, [
                {:conta => nova_parcela.conta, :historico => nova_parcela.historico, :numero_de_controle => nova_parcela.conta.numero_de_controle,
                  :data_lancamento => nova_parcela.data_da_baixa, :tipo_lancamento => 'S', :tipo_documento => nova_parcela.conta.tipo_de_documento,
                  :provisao =>  Movimento::BAIXA, :pessoa_id => nova_parcela.conta.pessoa_id, :numero_da_parcela => numero_original,
                  :parcela_id => nova_parcela.id},
                lancamento_debito, lancamento_credito], nova_parcela.conta.unidade_id)
          end
          #----------------------#

          if nova_parcela.save
            nova_parcela.baixando = false
            HistoricoOperacao.cria_follow_up("Parcela #{parcela_mae.numero.to_i} baixada parcialmente (#{nova_parcela.numero_parcela_filha})", usuario, parcela_mae.conta, nil , nil, nova_parcela.valor) if !nova_parcela.id.blank?
          else
            raise(nova_parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
          end
        else
          raise 'Para realizar a baixa total da parcela, favor ir até a tela de baixa!'
        end
      end
      [true, 'Baixa parcial realizada com sucesso!']
    rescue Exception => e
      #p e.message
      #LANCAMENTOS_LOGGER.erro e.backtrace.join("\n")
      [false, e.message]
    end
  end
  
  def baixar_parcialmente_dr(ano, usuario, params)
    begin
      Parcela.transaction do
        parcela_mae = Parcela.find(params['parcela_id'])
        diferenca_juros_multas = (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round + (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round
        numero = "#{parcela_mae.numero.to_i}.#{parcela_mae.retorna_parcelas_filhas.length + 1}"
        valor_nova_parcela = (params['valor_liquido'].real.to_f * 100).round

        if diferenca_juros_multas > valor_nova_parcela
          raise 'Insira um valor maior, porque o valor dos juros e multas é maior que o valor da parcela!'
        else
          diferenca = valor_nova_parcela - diferenca_juros_multas
        end

        if parcela_mae.conta.rateio == 1 && !parcela_mae.rateios.blank?
          valor_rateio = []
          porcentagens_rateios = []
          porcentagens_rateios = calcula_porcentagem_do_rateio
          rateios = parcela_mae.rateios.sort_by(&:valor)

          porcentagens_rateios.sort_by {|key, value| value['porcentagem']}.each do |key, value|
            valor_rateio << ((value['porcentagem'].round(2) * diferenca) / 100).to_i
          end
          acrescimo = diferenca - valor_rateio.sum
          if valor_rateio.sum != diferenca
            valor_rateio[valor_rateio.length-1] = valor_rateio.last + acrescimo
          end

          1.upto(rateios.length) do |i|
            if diferenca > 0
              atualiza_valor_rateio = parcela_mae.dados_do_rateio["#{i}"]['valor'].to_f
              atualiza_valor_rateio -= valor_rateio[i-1].to_f / 100.0
              parcela_mae.dados_do_rateio["#{i}"]['valor'] = atualiza_valor_rateio
              rateios[i-1]['valor'] -= valor_rateio[i-1]
              if(rateios[i-1]['valor'] <= 0)
                raise 'Para realizar a baixa total da parcela, favor ir até a tela de baixa!'
              end
              rateios[i-1].save || (raise rateios[i-1].errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
            end
          end
        end

        if diferenca != parcela_mae.valor
          numero_original = parcela_mae.numero
          valor_original_parcela = parcela_mae.valor
          parcela_mae.valor = valor_original_parcela - diferenca
          parcela_mae.numero = numero
          parcela_mae.save || (raise parcela_mae.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))

          nova_parcela = Parcela.new(:parcela_mae_id => params['parcela_id'], :valor => diferenca,
            :conta_id => params['recebimento_de_conta_id'], :conta_type => 'RecebimentoDeConta',
            :data_vencimento => params['data_vencimento'], :ano_contabil_atual => ano,
            :historico => params['historico'], :conta_corrente_id => params['parcela_conta_corrente_id'],
            :baixa_pela_dr => true)
          nova_parcela.save || raise(nova_parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))

          nova_parcela.baixando = true
          nova_parcela.data_da_baixa = params['parcela_data_da_baixa']
          nova_parcela.forma_de_pagamento = params['parcela_forma_de_pagamento']
          nova_parcela.valor_liquido = diferenca
          nova_parcela.numero_parcela_filha = numero_original
          nova_parcela.situacao = QUITADA

          if (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round > 0
            nova_parcela.valor_da_multa = (params['parcela']['valor_da_multa_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_multa_id = params['parcela']['conta_contabil_multa_id']
            nova_parcela.unidade_organizacional_multa_id = params['parcela']['unidade_organizacional_multa_id']
            nova_parcela.centro_multa_id = params['parcela']['centro_multa_id']
          end
          if (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round > 0
            nova_parcela.valor_dos_juros = (params['parcela']['valor_dos_juros_em_reais'].real.to_f * 100).round
            nova_parcela.conta_contabil_juros_id = params['parcela']['conta_contabil_juros_id']
            nova_parcela.unidade_organizacional_juros_id = params['parcela']['unidade_organizacional_juros_id']
            nova_parcela.centro_juros_id = params['parcela']['centro_juros_id']
          end

          if nova_parcela.cheques.blank? && nova_parcela.forma_de_pagamento == CHEQUE
            nova_parcela.cheques.build(:nome_do_titular => params['parcela']['cheques_attributes']['0']['nome_do_titular'],
              :banco_id => params['parcela']['cheques_attributes']['0']['banco_id'], :agencia => params['parcela']['cheques_attributes']['0']['agencia'],
              :conta => params['parcela']['cheques_attributes']['0']['conta'], :data_para_deposito => params['parcela']['cheques_attributes']['0']['data_para_deposito'],
              :prazo => params['parcela']['cheques_attributes']['0']['prazo'], :numero => params['parcela']['cheques_attributes']['0']['numero'],
              :conta_contabil_transitoria_id => params['parcela']['cheques_attributes']['0']['conta_contabil_transitoria_id'])
          end

          if nova_parcela.cartoes.blank? && nova_parcela.forma_de_pagamento == CARTAO
            nova_parcela.cartoes.build(:nome_do_titular => params['parcela']['cartoes_attributes']['1']['nome_do_titular'],
              :bandeira => params['parcela']['cartoes_attributes']['1']['bandeira'], :numero => params['parcela']['cartoes_attributes']['1']['numero'],
              :validade => params['parcela']['cartoes_attributes']['1']['validade'])
          end

          if nova_parcela.rateios.blank? && nova_parcela.conta.rateio == 1
            nova_parcela.baixando_parcialmente = true
            1.upto(rateios.length) do |i|
              nova_parcela.rateios.build(:unidade_organizacional_id => rateios[i-1]['unidade_organizacional_id'],
                :centro_id => rateios[i-1]['centro_id'], :conta_contabil_id => rateios[i-1]['conta_contabil_id'],
                :valor => valor_rateio[i-1])
            end
          end

          if nova_parcela.save
            nova_parcela.baixando = false
            HistoricoOperacao.cria_follow_up("Parcela #{parcela_mae.numero.to_i} baixada parcialmente DR (#{nova_parcela.numero_parcela_filha})", usuario, parcela_mae.conta, nil , nil, nova_parcela.valor) if !nova_parcela.id.blank?
          else
            raise(nova_parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n"))
          end
        else
          raise 'Para realizar a baixa total da parcela, favor ir até a tela de baixa!'
        end
      end
      [true, 'Baixa parcial DR realizada com sucesso!']
    rescue Exception => e
      #LANCAMENTOS_LOGGER.erro e.backtrace.join("\n")
      [false, e.message]
    end
  end

  named_scope :que_estao_baixadas, :conditions => ['data_da_baixa IS NOT NULL']
end
