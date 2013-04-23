class LancamentoImposto < ActiveRecord::Base
  extend BuscaExtendida

  acts_as_audited

  #CONSTANTES
  ALFABETICA = 1
  VENCIMENTO = 2
  
  #VALIDAÇÕES
  validates_presence_of :parcela_id, :message => 'deve ser preenchido.'
  validates_presence_of :imposto_id, :message => 'deve ser preenchido.'
  validates_presence_of :data_de_recolhimento, :valor, :message => 'deve ser preenchido.'
  
  #RELACIONAMENTOS
  belongs_to :parcela
  belongs_to :parcela_pagamento_de_conta, :class_name => 'ParcelaPagamentoDeConta', :foreign_key => 'parcela_id'
  belongs_to :imposto

  #FORMATAÇÃO E ATRIBUTOS VIRTUAIS
  data_br_field :data_de_recolhimento
  attr_protected :parcela_id
  converte_para_data_para_formato_date :data_de_recolhimento
  cria_readers_para_valores_em_dinheiro :valor
  validates_numericality_of :valor, :greater_than => 0, :message =>"deve ser maior do que zero."
  attr_accessor :raise_exception
  
  HUMANIZED_ATTRIBUTES = {
    :parcela_id => "O campo parcela",
    :imposto_id => "O campo imposto",
    :data_de_recolhimento => "O campo data de recolhimento",
  }

  def before_validation
    self.valor = @valor_em_reais unless @valor_em_reais.blank?
  end

  def self.pesquisar_parcelas_para_relatorio_retencao_impostos contar_ou_retornar, unidade_id, params
    return [] if params.blank?

    @sqls = ["(pagamento_de_contas.unidade_id = ?)"]
    @variaveis = [unidade_id]

    preencher_array_para_campo_com_auto_complete params, :fornecedor, 'pagamento_de_contas.pessoa_id'
    preencher_array_para_buscar_por_faixa_de_datas params, :recolhimento, 'lancamento_impostos.data_de_recolhimento'

#    unless params['impostos'].blank?
#      @sqls << '(lancamento_impostos.imposto_id = ?)'
#      @variaveis << params['impostos']
#    end

    if params['pessoa'].to_i == Pessoa::FISICA
      @sqls << '(pessoas.tipo_pessoa = ?)'
      @variaveis << Pessoa::FISICA
      ordem = 'pessoas.nome ASC'
    elsif params['pessoa'].to_i == Pessoa::JURIDICA
      @sqls << '(pessoas.tipo_pessoa = ?)'
      @variaveis << Pessoa::JURIDICA
      ordem = 'pessoas.razao_social ASC'
    end

    LancamentoImposto.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem)
  end

end
