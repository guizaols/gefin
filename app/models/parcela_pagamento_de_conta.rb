class ParcelaPagamentoDeConta < Parcela
  extend BuscaExtendida

  acts_as_audited

  set_table_name 'parcelas'  

  default_scope :conditions => "parcelas.conta_type = 'PagamentoDeConta'"

  belongs_to :conta, :foreign_key=> 'conta_id', :class_name => 'PagamentoDeConta'  

  def self.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral contar_ou_retornar, unidade_id, params
    @sqls = ['(pagamento_de_contas.unidade_id = ?)']
    @variaveis = [unidade_id]
    @ordenacao = params['ordenacao']
    
    preencher_array_para_campo_com_auto_complete params, :fornecedor, 'pagamento_de_contas.pessoa_id'
    preencher_array_para_campo_simples params, :tipo_de_documento, 'pagamento_de_contas.tipo_de_documento'
    
    sqls = params["periodo"] == 'pagamento' ? 'parcelas.data_da_baixa' : 'parcelas.data_vencimento'
    preencher_array_para_buscar_por_faixa_de_datas params, :periodo, sqls
    
    @sqls << "(parcelas.id IS NOT NULL)" if params['opcao_de_relatorio'] == ''
    @sqls << "(parcelas.data_da_baixa IS NOT NULL)" if params['opcao_de_relatorio'] == 'pagamentos'
    @sqls << "(parcelas.data_da_baixa IS NOT NULL) AND (data_vencimento < data_da_baixa)" if params['opcao_de_relatorio'] == 'pagamentos_com_atraso'
    
    if params['opcao_de_relatorio'] == 'inadimplencia'
      @sqls << "(parcelas.data_da_baixa IS NULL) AND (parcelas.data_vencimento < ?)"
      @variaveis << "#{params['periodo_max'].blank? ? Date.today : params['periodo_max'].to_date}"
    end
    
    if params['opcao_de_relatorio'] == 'contas_a_pagar'
      @sqls << "(parcelas.data_da_baixa IS NULL) AND (situacao = ?)"
      @variaveis << Parcela::PENDENTE
    end
    
    case params['situacao']
    when Parcela::QUITADA.to_s; @sqls << '(parcelas.situacao = ?) AND (parcelas.data_da_baixa IS NOT NULL)'; @variaveis << Parcela::QUITADA
    when Parcela::PENDENTE.to_s; @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::PENDENTE
    when 'atrasadas'; @sqls << '(parcelas.situacao = ? AND parcelas.data_vencimento < ?)'; @variaveis << Parcela::PENDENTE ; @variaveis << Date.today
    when 'vincendas'; @sqls << '(parcelas.situacao = ? AND parcelas.data_vencimento >= ?)'; @variaveis << Parcela::PENDENTE ; @variaveis << Date.today
    end
        
    ParcelaPagamentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => @ordenacao)
  end

  def self.pesquisar_parcelas(conta_ou_retornar, unidade_id, params, ids = nil)
    @sqls = []; @variaveis = []; @string = ''
    @sqls << '(parcelas.arquivo_remessa_id IS NULL)'
    @sqls << '(pagamento_de_contas.unidade_id = ?)'; @variaveis << unidade_id
    @sqls << '(parcelas.situacao NOT IN (?))'
    @variaveis << [Parcela::QUITADA, Parcela::ESTORNADA]

    unless params['tipo_documento'].blank?
      @sqls << '(pagamento_de_contas.tipo_de_documento = ?)'
      @variaveis << params['tipo_documento']
    end

    if !params['data_inicial'].blank? && !params['data_final'].blank?
      @sqls << '(parcelas.data_vencimento BETWEEN ? AND ?)'
      @variaveis << params['data_inicial'].to_date
      @variaveis << params['data_final'].to_date
    elsif !params['data_inicial'].blank? && params['data_final'].blank?
      @sqls << '(parcelas.data_vencimento >= ?)';
      @variaveis << params['data_inicial'].to_date
    elsif params['data_inicial'].blank? && !params['data_final'].blank?
      @sqls << '(parcelas.data_vencimento <= ?)';
      @variaveis << params['data_final'].to_date
    else
      @sqls << '(parcelas.data_vencimento <= ?)'
      @variaveis << Date.today + 30000
    end

    unless ids.blank?
      @string << " OR (parcelas.id IN (#{ids.join(",")}))"
    end
    parcelas = ParcelaPagamentoDeConta.send(conta_ou_retornar, :conditions => [ "("+ @sqls.join(' AND ') + ")" + @string] + @variaveis, :include => :conta, :order => 'pagamento_de_contas.numero_de_controle')
    parcelas.group_by(&:conta)
  end

  def self.visao_contabil(contar_ou_retornar, unidade_id, params)
    @sqls = []
    @variaveis = []
    @sqls << '(pagamento_de_contas.unidade_id = ?)'
    @variaveis << unidade_id

    unless params['provisao'].blank?
      @sqls << '(pagamento_de_contas.provisao = ?)'
      @variaveis << params['provisao'].to_i
    end

    @sqls << '(pagamento_de_contas.data_emissao <= ?)'
    @variaveis << params['data'].to_date

    @sqls << '((parcelas.data_da_baixa IS NOT NULL AND parcelas.data_da_baixa > ?) OR (parcelas.data_da_baixa IS NULL))'
    @variaveis << params['data'].to_date

    @sqls << '(movimentos.parcela_id IS NOT NULL)'

    @sqls << '(
               (parcelas.situacao IN (?) AND movimentos.data_lancamento > ?) OR 
               (parcelas.situacao NOT IN (?))
              )'
    @variaveis << Parcela::ESTORNADA
    @variaveis << params['data'].to_date
    @variaveis << Parcela::ESTORNADA
    
#    @sqls << '(movimentos.tipo_lancamento = ? AND movimentos.data_lancamento <= ?)'
#    @variaveis << params['data'].to_date

#    @sqls << '(parcelas.situacao NOT IN (?))'
#    @variaveis << Parcela::ESTORNADA
p [@sqls.join(' AND ')] + @variaveis
    ParcelaPagamentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [{:conta => :pessoa}, :movimentos], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
    
  end

end
