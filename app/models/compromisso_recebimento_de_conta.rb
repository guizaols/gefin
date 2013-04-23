class CompromissoRecebimentoDeConta < Compromisso
  extend BuscaExtendida

  acts_as_audited

  set_table_name 'compromissos'

  default_scope :conditions => "conta_type = 'RecebimentoDeConta'"

  belongs_to :conta, :foreign_key => 'conta_id', :class_name => 'RecebimentoDeConta'

  def self.pesquisa_agendamentos(contar_ou_retornar,unidade_id,params)
    @sqls = []; @variaveis = []
    @sqls << "(compromissos.unidade_id = ?)"; @variaveis << unidade_id
    @sqls << '(pessoas.cliente = ?)' ; @variaveis << true

    preencher_array_para_campo_com_auto_complete params, :cliente, 'recebimento_de_contas.pessoa_id'

    unless params['periodo_min'].blank? && params['periodo_max'].blank?
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'compromissos.data_agendada'
    end
    CompromissoRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

end
