class HistoricoOperacaoRecebimentoDeConta < ActiveRecord::Base
  extend BuscaExtendida

  acts_as_audited

  set_table_name 'historico_operacoes'

  default_scope :conditions => "conta_type = 'RecebimentoDeConta'"

  belongs_to :conta, :foreign_key => 'conta_id', :class_name => 'RecebimentoDeConta'
  belongs_to :usuario

  def self.pesquisar_historicos_operacoes contar_ou_retornar, parametros
    @sqls = []; @variaveis = []

    unless parametros['tipo_de_carta'].blank?
      @sqls << "(historico_operacoes.numero_carta_cobranca = ?)"; @variaveis << parametros['tipo_de_carta'].to_i
    else
      @sqls << "(historico_operacoes.numero_carta_cobranca IS NOT NULL)"
    end

    unless parametros['unidade_id'].blank?
      @sqls << "(recebimento_de_contas.unidade_id = ?)"; @variaveis << parametros['unidade_id'].to_i
    end

    unless parametros['funcionario_id'].blank?
      @sqls << "(usuarios.funcionario_id = ?)"; @variaveis << parametros['funcionario_id'].to_i
    end

    preencher_array_para_buscar_por_faixa_de_datas parametros, :emissao, 'historico_operacoes.created_at'

    HistoricoOperacaoRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [{:conta => :pessoa}, :usuario], :order => parametros['ordenacao'])
  end

  def self.pesquisa_follow_up_por_funcionario contar_ou_retornar, unidade_id, params
    @sqls = []; @variaveis = []
    @sqls << "(recebimento_de_contas.unidade_id = ?)"; @variaveis << unidade_id
    unless params['servico_id'].blank?
      @sqls << '(recebimento_de_contas.servico_id = ?)'
      @variaveis << params['servico_id'].to_i
    end
    unless params['cliente_id'].blank?
      @sqls << '(pessoas.id = ?) AND (pessoas.cliente = ?)'
      @variaveis << params['cliente_id'].to_i
      @variaveis << true
    end
    unless params['funcionario_id'].blank?
      @sqls << '(usuarios.funcionario_id = ?)'
      @variaveis << params['funcionario_id'].to_i
    end
    unless params['periodo_min'].blank? && params['periodo_max'].blank?
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'historico_operacoes.created_at'
    end
    HistoricoOperacaoRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => [{:conta => :pessoa},:usuario], :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def retorna_agrupamento_para_pesquisa agrupamento
    case agrupamento
    when 'Entidade'; self.conta.unidade.entidade
    when 'Unidade'; self.conta.unidade
    when 'Funcionário'; self.usuario
    end
  end

  def self.pesquisa_follow_up_por_cliente(contar_ou_retornar, unidade_id, params)
    @sqls = []; @variaveis = []
    @sqls << "(recebimento_de_contas.unidade_id = ?) AND (pessoas.cliente = ?)"
    @variaveis << unidade_id
    @variaveis << true

    @sqls << '(pessoas.id = ?)'
    if !params['nome_cliente'].blank?
      @variaveis << params['cliente_id'].to_i
    else
      @variaveis << params['nome_cliente']
    end

    unless params['periodo_min'].blank? && params['periodo_max'].blank?
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'historico_operacoes.created_at'
    end
    HistoricoOperacaoRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end
  
end
