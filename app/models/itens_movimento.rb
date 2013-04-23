class ItensMovimento < ActiveRecord::Base
  extend BuscaExtendida

  acts_as_audited

  RELATORIO_EXTRATO_CONTAS = 1
  RELATORIO_DISPONIBILIDADE_EFETIVA = 2

  belongs_to :movimento
  belongs_to :centro
  belongs_to :unidade_organizacional
  belongs_to :plano_de_conta

  validates_presence_of :movimento, :centro, :plano_de_conta, :message => 'é inválido.'
  validates_presence_of :unidade_organizacional, :message => 'é inválida.'
  validates_inclusion_of :tipo, :in => ['D', 'C'], :message => 'é inválido.'
  validates_numericality_of :valor, :greater_than => 0, :message => 'deve ser maior do que zero.'
  verifica_se_centro_pertence_a_unidade_organizacional :centro, :unidade_organizacional

  HUMANIZED_ATTRIBUTES = { :movimento => 'Movimento', :plano_de_conta => 'Plano de Conta',
    :unidade_organizacional => 'Unidade Organizacional', :centro => 'Centro de Responsabilidade',
    :valor => 'O campo valor'}

  def tipo_verbose
    tipo == 'D' ? 'Débito' : 'Crédito'
  end

  def verifica_valor
    tipo == 'D' ? valor : (valor * -1)
  end

  def self.disponibilidade_efetiva contar_ou_retornar, params, unidade_id
    @sqls = []
    @variaveis = []
    if (params["conta_corrente_id"].blank? || params["nome_conta_corrente"].blank?) &&
        (params["tipo_de_relatorio"] == RELATORIO_EXTRATO_CONTAS)
      contar_ou_retornar == :count ? 0 : []
    else
      @sqls << "(movimentos.unidade_id = ?)"
      @variaveis << unidade_id

      preencher_array_para_buscar_por_faixa_de_datas params, 'data', 'movimentos.data_lancamento'
      preencher_array_para_campo_com_auto_complete params, :conta_corrente, 'contas_correntes.id'

      if params["tipo_de_relatorio"] == RELATORIO_DISPONIBILIDADE_EFETIVA
        @sqls << "(contas_correntes.id IN (?))"
        @variaveis << ContasCorrente.all.collect(&:id)
      end

      ItensMovimento.send(contar_ou_retornar, :include => [:movimento, {:plano_de_conta => :contas_corrente}], :conditions => [@sqls.join(' AND ')] + @variaveis, :order => 'movimentos.data_lancamento ASC')
    end
  end

  def self.exportacao_zeus contar_ou_retornar, unidade, params
    @sqls = ["(movimentos.unidade_id = ?)"]; @variaveis = [unidade]

    unless params["data"].blank?
      @sqls << 'movimentos.data_lancamento = ?'
      @variaveis << params["data"].to_date
    end

    pesquisa = ItensMovimento.send(contar_ou_retornar, :include => :movimento, :conditions => [@sqls.join(' AND ')] + @variaveis)

    if pesquisa.is_a?(Array)
      begin
        retorno_total = []
        pesquisa.collect do |item|
          retorno = []
          retorno << item.movimento.unidade.entidade.codigo_zeus.to_s.ljust(3)
          retorno << item.unidade_organizacional.codigo_da_unidade_organizacional.to_s.ljust(10) rescue raise('Código da unidade organizacional inválido')
          retorno << item.centro.codigo_centro.to_s.ljust(16) rescue raise('Código do centro inválido')
          retorno << item.plano_de_conta.codigo_contabil.to_s.ljust(16)
          retorno << item.tipo.to_s.ljust(1) rescue raise('Tipo do lançamento inválido')
          retorno << format("%.2f", (item.valor / 100.0)).ljust(16) rescue raise('Valor do lançamento inválido')
          retorno << item.movimento.data_lancamento.to_s rescue raise('Data do lançamento inválida')
          retorno << 1.to_s.ljust(3)
          retorno << 1000.to_s.ljust(3)
          retorno << item.movimento.unidade.nome_caixa_zeus.ljust(16) rescue raise('Nome do caixa Zeus é inválido')
          retorno << item.movimento.historico.ljust(255) rescue raise('Histório inválido')
          retorno_total << retorno.join("\t")
        end
        [true, retorno_total.join("\n")]
      rescue Exception => e
        [false, e.message]
      end
    else
      pesquisa
    end
  end

  def self.pesquisa_receitas_das_contas_contabeis(contar_ou_retornar, unidade_id, params)
    @sqls = []; @variaveis = []
    @sqls << "(movimentos.unidade_id = ?)"
    @variaveis << unidade_id
    @sqls << "(itens_movimentos.tipo = 'C')"

    if !params['conta_contabil_inicial_id'].blank? && !params['conta_contabil_final_id'].blank?
      conta_inicial = PlanoDeConta.find(params['conta_contabil_inicial_id'].split('_').last)
      conta_final = PlanoDeConta.find(params['conta_contabil_final_id'].split('_').last)
      @variaveis << conta_inicial.codigo_contabil
      @variaveis << conta_final.codigo_contabil
      @sqls << "(plano_de_contas.codigo_contabil BETWEEN ? AND ?)"
    elsif !params['conta_contabil_inicial_id'].blank? && params['conta_contabil_final_id'].blank?
      conta_inicial = PlanoDeConta.find(params['conta_contabil_inicial_id'].split('_').last)
      @variaveis << conta_inicial.codigo_contabil
      @sqls << "(plano_de_contas.codigo_contabil = ?)"
    elsif params['conta_contabil_inicial_id'].blank? && !params['conta_contabil_final_id'].blank?
      conta_final = PlanoDeConta.find(params['conta_contabil_final_id'].split('_').last)
      @variaveis << conta_final.codigo_contabil
      @sqls << "(plano_de_contas.codigo_contabil = ?)"
    end

    if !params['unidade_organizacional_inicial_id'].blank? && !params['unidade_organizacional_final_id'].blank?
      unidade_inicial = UnidadeOrganizacional.find(params['unidade_organizacional_inicial_id'])
      unidade_final = UnidadeOrganizacional.find(params['unidade_organizacional_final_id'])
      @variaveis << unidade_inicial.codigo_da_unidade_organizacional
      @variaveis << unidade_final.codigo_da_unidade_organizacional
      @sqls << "(unidade_organizacionais.codigo_da_unidade_organizacional BETWEEN ? AND ?)"
    elsif !params['unidade_organizacional_inicial_id'].blank? && params['unidade_organizacional_final_id'].blank?
      unidade_inicial = UnidadeOrganizacional.find(params['unidade_organizacional_inicial_id'])
      @variaveis << unidade_inicial.codigo_da_unidade_organizacional
      @sqls << "(unidade_organizacionais.codigo_da_unidade_organizacional = ?)"
    elsif params['unidade_organizacional_inicial_id'].blank? && !params['unidade_organizacional_final_id'].blank?
      unidade_final = UnidadeOrganizacional.find(params['unidade_organizacional_final_id'])
      @variaveis << unidade_final.codigo_da_unidade_organizacional
      @sqls << "(unidade_organizacionais.codigo_da_unidade_organizacional = ?)"
    end

    if !params['centro_inicial_id'].blank? && !params['centro_final_id'].blank?
      centro_inicial = Centro.find(params['centro_inicial_id'])
      centro_final = Centro.find(params['centro_final_id'])
      @variaveis << centro_inicial.codigo_centro
      @variaveis << centro_final.codigo_centro
      @sqls << "(centros.codigo_centro BETWEEN ? AND ?)"
    elsif !params['centro_inicial_id'].blank? && params['centro_final_id'].blank?
      centro_inicial = Centro.find(params['centro_inicial_id'])
      @variaveis << centro_inicial.codigo_centro
      @sqls << "(centros.codigo_centro = ?)"
    elsif params['centro_inicial_id'].blank? && !params['centro_final_id'].blank?
      centro_final = Centro.find(params['centro_final_id'])
      @variaveis << centro_final.codigo_centro
      @sqls << "(centros.codigo_centro = ?)"
    end

    periodo_min = (params['periodo_min'].to_date rescue nil)
    periodo_max = (params['periodo_max'].to_date rescue nil)
    if periodo_min
      @sqls << "(movimentos.data_lancamento >= ?)"; @variaveis << periodo_min
    end
    if periodo_max
      @sqls << "(movimentos.data_lancamento <= ?)"; @variaveis << periodo_max
    elsif periodo_min.nil?
      @sqls << "(movimentos.data_lancamento < ?)"; @variaveis << Date.today
    end
    ItensMovimento.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro])
  end

  def self.extrato_de_contas_beta(contar_ou_retornar, params, unidade_id)
    @sqls = []
    @variaveis = []
    if (params['conta_corrente_id'].blank? || params['nome_conta_corrente'].blank? || params['data_min'].blank? || params['data_max'].blank?)
      contar_ou_retornar == :count ? 0 : []
    else
      @sqls << '(movimentos.unidade_id = ?)'
      @variaveis << unidade_id

      preencher_array_para_buscar_por_faixa_de_datas params, 'data', 'movimentos.data_lancamento'
      #preencher_array_para_campo_com_auto_complete params, :conta_corrente, 'contas_correntes.id'

      anos = []
      ano_data_inicial = params['data_min'].to_date.year if !params['data_min'].blank?
      ano_data_final = params['data_max'].to_date.year if !params['data_max'].blank?
      intervalo = ano_data_inicial..ano_data_final
      (intervalo).collect do |ano|
        anos << ano
      end

      if !params['conta_corrente_id'].blank?
        conta_contabil_da_conta_corrente = ContasCorrente.find_by_id(params['conta_corrente_id']).conta_contabil.codigo_contabil
        entidade_id = Unidade.find_by_id(unidade_id).entidade_id
        ids = PlanoDeConta.find(:all, :conditions => ['entidade_id = ? AND codigo_contabil = ? AND ano IN (?)', entidade_id, conta_contabil_da_conta_corrente, anos]).collect(&:id)
        @sqls << '(itens_movimentos.plano_de_conta_id IN (?))'
        @variaveis << ids
      end

      ItensMovimento.send(contar_ou_retornar, :include => [:movimento, {:plano_de_conta => :contas_corrente}], :conditions => [@sqls.join(' AND ')] + @variaveis, :order => 'movimentos.data_lancamento ASC')
    end
  end
  
end
