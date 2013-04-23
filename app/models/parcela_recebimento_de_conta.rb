class ParcelaRecebimentoDeConta < Parcela
  extend BuscaExtendida

  acts_as_audited
  
  set_table_name 'parcelas'
  default_scope :conditions => "conta_type = 'RecebimentoDeConta'"
  belongs_to :conta, :foreign_key => 'conta_id', :class_name => 'RecebimentoDeConta'
 
  CARTA_1 = 1
  CARTA_2 = 2
  CARTA_3 = 3

  def self.pesquisar_parcelas_para_relatorio_a_receber_geral contar_ou_retornar, unidade_id, params
    @sqls = params.include?('tipo_pessoa') ?  [] : ['(parcelas.data_da_baixa IS NOT NULL)']
    opcoes = ['Inadimplência', 'Contas a Receber', 'Geral do Contas a Receber']
    situacao = ['Todas', 'Quitadas - Baixa DR']
    @sqls = ['(recebimento_de_contas.unidade_id = ?)']
    @variaveis = [unidade_id]
    @ordenacao = params['ordenacao']

    if !params['provisao'].blank?
      if params['provisao'] == 'SIM'
        @sqls << '(recebimento_de_contas.provisao = ?)'
        @variaveis << RecebimentoDeConta::SIM
      elsif params['provisao'] == 'NÃO'
        @sqls << '(recebimento_de_contas.provisao = ?)'
        @variaveis << RecebimentoDeConta::NAO
      end
    end

    # Verificar a linha abaixo, eu acho que está ferrada --->
   # @sqls << '(parcelas.data_da_baixa IS NOT NULL)' if (params['opcoes'] == 'Contas a Receber' && (params['situacao'] == 'Todas' || params['situacao'] == 'Todas - Exceto Jurídico')) || ((opcoes.include? params['opcoes']) && (!situacao.any?{|sit| params['situacao'].include?(sit)}))
    # <---

    if (params['opcoes'] == 'Geral do Contas a Receber') &&
        ['Todas', 'Permuta', 'Baixa do Conselho', 'Inativo', 'Todas - Exceto Permuta', 'Jurídico', 'Enviado ao DR', 'Perdas no Recebimento de Creditos - Clientes', 'Todas - Exceto Jurídico', 'Todas - Exceto Baixa do Conselho', 'Todas - Exceto Inativo', 'Quitadas - Baixa DR', 'Todas - Exceto Canceladas'
      ].include?(params['situacao'])
      if params['situacao'] == 'Todas'
       # @sqls << '(parcelas.situacao IN (?))'
       # @variaveis << [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA, ENVIADO_AO_DR, DEVEDORES_DUVIDOSOS_ATIVOS, EVADIDA, ESTORNADA]
      
  dados = [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA, ENVIADO_AO_DR, DEVEDORES_DUVIDOSOS_ATIVOS, EVADIDA, ESTORNADA]
        dados.each do |dado|
            @sqls_aux << "(parcelas.situacao = '#{dado}')"
        end

  @sqls << "(#{@sqls_aux.join(" OR ")})"

      end
      if params['situacao'] == 'Jurídico'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::JURIDICO
      end
      if params['situacao'] == 'Permuta'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::PERMUTA
      end
      if params['situacao'] == 'Baixa do Conselho'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::BAIXA_DO_CONSELHO
      end
      if params['situacao'] == 'Inativo'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::CANCELADA
      end
      if params['situacao'] == 'Todas - Exceto Jurídico'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::JURIDICO
      end
      if params['situacao'] == 'Todas - Exceto Permuta'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::PERMUTA
      end
      if params['situacao'] == 'Todas - Exceto Baixa do Conselho'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::BAIXA_DO_CONSELHO
      end
      if params['situacao'] == 'Todas - Exceto Inativo'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::CANCELADA
      end
      if params['situacao'] == 'Enviado ao DR'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::ENVIADO_AO_DR
      end
      if params['situacao'] == 'Perdas no Recebimento de Creditos - Clientes'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::DEVEDORES_DUVIDOSOS_ATIVOS
      end
      if params['situacao'] == 'Todas - Exceto Canceladas'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::CANCELADA
      end
      if params['situacao'] == 'Quitadas - Baixa DR'
        @sqls << '(parcelas.baixa_pela_dr = ?)'; @variaveis << true
      end
      if params['situacao'] == 'Em Atraso'
        if(params['periodo_min'].blank? && params['periodo_max'].blank?)
          @sqls << '(parcelas.data_vencimento < ?) AND (parcelas.situacao IN (?))'
          @variaveis << Date.today
        else
          @sqls << '(parcelas.situacao IN (?))'
        end
        @variaveis << [Parcela::PENDENTE, Parcela::ENVIADO_AO_DR]
      end
      if params['situacao'] == 'Vincendas'
        if(params['periodo_min'].blank? && params['periodo_max'].blank?)
          @sqls << '(parcelas.data_vencimento >= ?) AND (parcelas.situacao IN (?))'
          @variaveis << Date.today
        else
          @sqls << '(parcelas.situacao IN(?))'
        end
        @variaveis << [Parcela::PENDENTE]
      end
    end

    if params['opcoes'] == 'Contas a Receber'
      @sqls_aux = []
      #  @sqls << '(parcelas.situacao IN (?))'
      #  @variaveis << [Parcela::PENDENTE, Parcela::JURIDICO]
      if params['situacao'] == 'Todas'
        dados = [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA, ENVIADO_AO_DR, DEVEDORES_DUVIDOSOS_ATIVOS, EVADIDA, ESTORNADA]
       #dados = [QUITADA]
        dados.each do |dado|
            @sqls_aux << "(parcelas.situacao = '#{dado}')"
        end

        @sqls << "(#{@sqls_aux.join(" OR ")})"
        
       

       # @variaveis << [PENDENTE, QUITADA, CANCELADA, RENEGOCIADA, JURIDICO, PERMUTA, BAIXA_DO_CONSELHO, DESCONTO_EM_FOLHA, ENVIADO_AO_DR, DEVEDORES_DUVIDOSOS_ATIVOS, EVADIDA, ESTORNADA]
      end
      if params['situacao'] == 'Jurídico'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::JURIDICO
      end
      if params['situacao'] == 'Permuta'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::PERMUTA
      end
      if params['situacao'] == 'Baixa do Conselho'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::BAIXA_DO_CONSELHO
      end
      if params['situacao'] == 'Inativo'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::CANCELADA
      end
      if params['situacao'] == 'Todas - Exceto Jurídico'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::JURIDICO
      end
      if params['situacao'] == 'Todas - Exceto Permuta'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::PERMUTA
      end
      if params['situacao'] == 'Todas - Exceto Baixa do Conselho'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::BAIXA_DO_CONSELHO
      end
      if params['situacao'] == 'Todas - Exceto Inativo'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::CANCELADA
      end
      if params['situacao'] == 'Enviado ao DR'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::ENVIADO_AO_DR
      end
      if params['situacao'] == 'Perdas no Recebimento de Creditos - Clientes'
        @sqls << '(parcelas.situacao = ?)'; @variaveis << Parcela::DEVEDORES_DUVIDOSOS_ATIVOS
      end
      if params['situacao'] == 'Todas - Exceto Canceladas'
        @sqls << '(parcelas.situacao <> ?)'; @variaveis << Parcela::CANCELADA
      end
      if params['situacao'] == 'Quitadas - Baixa DR'
        @sqls << '(parcelas.baixa_pela_dr = ?)'; @variaveis << true
      end 
      if params['situacao'] == 'Em Atraso'
        if(params['periodo_min'].blank? && params['periodo_max'].blank?)
          @sqls << '(parcelas.data_vencimento < ?) AND (parcelas.situacao IN (?))'
          @variaveis << Date.today
        else
          @sqls << '(parcelas.situacao IN(?))'
        end
        @variaveis << [Parcela::PENDENTE, Parcela::ENVIADO_AO_DR]
      end
      if params['situacao'] == 'Vincendas'
        if(params['periodo_min'].blank? && params['periodo_max'].blank?)
          @sqls << '(parcelas.data_vencimento >= ?) AND (parcelas.situacao IN (?))'
          @variaveis << Date.today
        else
          @sqls << '(parcelas.situacao IN(?))'
        end
        @variaveis << [Parcela::PENDENTE]
      end
    end

    if params['opcoes'] == 'Inadimplência'
      @sqls << '(parcelas.situacao IN (?))'
      @variaveis << [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::ENVIADO_AO_DR]
      if(params['periodo_min'].blank? && params['periodo_max'].blank?)
        @sqls << '(parcelas.data_vencimento < ?) AND (parcelas.situacao = ?)'
        @variaveis << Date.today
      end
    end

    if params['opcoes'] == 'Vendas Realizadas'
      @sqls << '(recebimento_de_contas.data_venda IS NOT NULL)'
      
      data_inicial_venda = params['vendido_min'].blank? ? '' : params['vendido_min'].to_date
      data_final_venda = params['vendido_max'].blank? ? '' : params['vendido_max'].to_date
      if !data_inicial_venda.blank? && !data_final_venda.blank?
        @sqls << 'recebimento_de_contas.data_venda BETWEEN ? AND ?'
        @variaveis << data_inicial_venda
        @variaveis << data_final_venda
      end
      if !data_inicial_venda.blank? && data_final_venda.blank?
        @sqls << 'recebimento_de_contas.data_venda >= ?'
        @variaveis << data_inicial_venda
      end
      if data_inicial_venda.blank? && !data_final_venda.blank?
        @sqls << 'recebimento_de_contas.data_venda <= ?'
        @variaveis << data_final_venda
      end
    end

    #    if params['situacao'] == 'Vincendas'
    #      @sqls << '(parcelas.data_vencimento >= ?)'
    #      @variaveis << Date.today
    #    end

    preencher_array_para_campo_com_auto_complete params, :servico, 'recebimento_de_contas.servico_id'
    preencher_array_para_campo_com_auto_complete params, :cliente, 'recebimento_de_contas.pessoa_id'
    preencher_array_para_campo_com_auto_complete params, :vendedor, 'recebimento_de_contas.vendedor_id'

    sqls = params['periodo'] == 'recebimento' ? 'parcelas.data_da_baixa' : 'parcelas.data_vencimento'
    preencher_array_para_buscar_por_faixa_de_datas params, :periodo, sqls

    @sqls << '(parcelas.data_da_baixa IS NOT NULL)' if params['opcoes'] == 'Recebimentos' || params['opcoes'] == 'Recebimentos com Atraso'
    @sqls << '(parcelas.data_vencimento < parcelas.data_da_baixa)' if (params['opcoes'] == 'Recebimentos com Atraso')
    #    if (params['opcoes'] == 'Inadimplência' || params['situacao'] == 'Em Atraso') && (params['vencimento_min'].blank?) && (params['vencimento_max'].blank?) && (params['vendido_min'].blank?) && (params['vendido_max'].blank?)
    #      @sqls << "(parcelas.data_vencimento < ?)"
    #      @variaveis << Date.today
    #    end

    unless params['nome_modalidade'].blank?
      @sqls << '(recebimento_de_contas.servico_id IN (?))'
      @variaveis << Servico.all(:conditions => ['unidade_id = ? AND modalidade = ?', unidade_id, params['nome_modalidade']]).collect(&:id)
    end
    
    ParcelaRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => "#{@ordenacao}")
  end

  def self.pesquisa_contas_a_receber_clientes_visao_contabil(contar_ou_retornar, unidade_id, params)
    @variaveis = []
    @sqls = []

    @sqls << '(recebimento_de_contas.unidade_id = ?)'
    @variaveis << unidade_id

    case params['tipo_pessoa']
    when '1'; @sqls << '(pessoas.tipo_pessoa = ?)'; @variaveis << Pessoa::FISICA
    when '2'; @sqls << '(pessoas.tipo_pessoa = ?)'; @variaveis << Pessoa::JURIDICA
    end

    if !params['provisao'].blank?
      if params['provisao'].to_i == 1
        @sqls << '(recebimento_de_contas.provisao = ?)'
        @variaveis << RecebimentoDeConta::SIM
      elsif params['provisao'].to_i == 2
        @sqls << '(recebimento_de_contas.provisao = ?)'
        @variaveis << RecebimentoDeConta::NAO
      end
    end

    preencher_array_para_campo_com_auto_complete params, :cliente, 'recebimento_de_contas.pessoa_id'
    @sqls << '(recebimento_de_contas.data_inicio between ? AND ?)'
    @variaveis << params[:periodo_min].to_date
    @variaveis << params[:periodo_max].to_date

    @sqls << '(recebimento_de_contas.data_cancelamento IS NULL OR (recebimento_de_contas.data_cancelamento > ?))'
    @variaveis << params[:periodo_max].to_date

   @sqls << '(recebimento_de_contas.data_evasao IS NULL OR (recebimento_de_contas.data_evasao > ?))'
    @variaveis << params[:periodo_max].to_date



    retorno = ParcelaRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')#, :limit => 30)
    retorno
  end

  def self.pesquisa_contas_a_receber_historico_clientes(unidade_id, params)
    if !params.has_key?('situacao_das_parcelas') && !params.has_key?('situacao_baixa_dr')
      return []
    else
      @sqls = []
      sqls = []
      @sqls << "recebimento_de_contas.unidade_id = #{unidade_id} AND "

      unless params['nome_cliente'].blank?
        @sqls << "(recebimento_de_contas.pessoa_id = #{params['cliente_id']}) AND "
      end
      
      case params['provisao']
      when '1'; @sqls << "recebimento_de_contas.provisao = #{RecebimentoDeConta::SIM} AND "
      when '2'; @sqls << "recebimento_de_contas.provisao = #{RecebimentoDeConta::NAO} AND "
      end

      case params['tipo_pessoa']
      when '1'; @sqls << "pessoas.tipo_pessoa = #{Pessoa::FISICA} AND "
      when '2'; @sqls << "pessoas.tipo_pessoa = #{Pessoa::JURIDICA} AND "
      end

      data_inicial = params['periodo_min'].blank? ? '' : params['periodo_min'].to_date
      data_final = params['periodo_max'].blank? ? '' : params['periodo_max'].to_date
      if params.has_key?('situacao_das_parcelas')
        situacoes_ids = []
        params['situacao_das_parcelas'].each do |parc|
          if parc != 'atrasada' && parc != 'vincenda' && parc != Parcela::PENDENTE.to_s && parc != Parcela::QUITADA.to_s && parc != Parcela::CANCELADA.to_s && parc != Parcela::EVADIDA.to_s && parc != Parcela::ENVIADO_AO_DR.to_s
            situacoes_ids << parc
          end
        end
        sqls << "parcelas.situacao IN(#{situacoes_ids.join(',')})" unless situacoes_ids.blank?
     
        #ATRASADAS
        if params['situacao_das_parcelas'].include?('atrasada')
          if !data_inicial.blank? && !data_final.blank?
            datas = "parcelas.data_vencimento BETWEEN '#{data_inicial}' AND '#{data_final}')"
          end
          datas = "parcelas.data_vencimento >= '#{data_inicial}')" if !data_inicial.blank? && data_final.blank?
          datas = "parcelas.data_vencimento <= '#{data_final}')" if data_inicial.blank? && !data_final.blank?
          if datas.blank?
            sqls << "(parcelas.situacao = #{Parcela::PENDENTE} AND parcelas.data_vencimento < '#{Date.today}')" 
          else
            sqls << "(parcelas.situacao = #{Parcela::PENDENTE} AND parcelas.data_vencimento < '#{Date.today}' AND " + datas
          end
        end

        #PENDENTES (VINCENDAS)
        if params['situacao_das_parcelas'].include?('vincenda')
          if !data_inicial.blank? && !data_final.blank?
            datas = "parcelas.data_vencimento BETWEEN '#{data_inicial}' AND '#{data_final}')"
          end
          datas = "parcelas.data_vencimento >= '#{data_inicial}')" if !data_inicial.blank? && data_final.blank?
          datas = "parcelas.data_vencimento <= '#{data_final}')" if data_inicial.blank? && !data_final.blank?
          if datas.blank?
            sqls << "(parcelas.situacao = #{Parcela::PENDENTE} AND parcelas.data_vencimento >= '#{Date.today}')" 
          else
            sqls << "(parcelas.situacao = #{Parcela::PENDENTE} AND parcelas.data_vencimento >= '#{Date.today}' AND " + datas
          end
        end

        #QUITADAS
        if params['situacao_das_parcelas'].include?(Parcela::QUITADA.to_s)
          if !data_inicial.blank? && !data_final.blank?
            datas = "parcelas.data_da_baixa BETWEEN '#{data_inicial}' AND '#{data_final}')"
          end
          datas = "parcelas.data_da_baixa >= '#{data_inicial}')" if !data_inicial.blank? && data_final.blank?
          datas = "parcelas.data_da_baixa <= '#{data_final}')" if data_inicial.blank? && !data_final.blank?
          if datas.blank?
            sqls << "(parcelas.situacao = #{Parcela::QUITADA})"
          else
            sqls << "(parcelas.situacao = #{Parcela::QUITADA} AND " + datas
          end
        end

        #CANCELADAS
        if params['situacao_das_parcelas'].include?(Parcela::CANCELADA.to_s)         
          if !data_inicial.blank? && !data_final.blank?
            datas = "recebimento_de_contas.data_cancelamento BETWEEN '#{data_inicial}' AND '#{data_final}')"
          end
          datas = "recebimento_de_contas.data_cancelamento >= '#{data_inicial}')" if !data_inicial.blank? && data_final.blank?
          datas = "recebimento_de_contas.data_cancelamento <= '#{data_final}')" if data_inicial.blank? && !data_final.blank?
          if datas.blank?
            sqls << "(parcelas.situacao = #{Parcela::CANCELADA} AND " +
              "recebimento_de_contas.situacao_fiemt = #{RecebimentoDeConta::Cancelado})"
          else
            sqls << "(parcelas.situacao = #{Parcela::CANCELADA} AND " +
              "recebimento_de_contas.situacao_fiemt = #{RecebimentoDeConta::Cancelado} AND " + datas
          end
        end

        #EVADIDAS
        if params['situacao_das_parcelas'].include?(Parcela::EVADIDA.to_s)
          if !data_inicial.blank? && !data_final.blank?
            datas = "recebimento_de_contas.data_evasao BETWEEN '#{data_inicial}' AND '#{data_final}')"
          end
          datas = "recebimento_de_contas.data_evasao >= '#{data_inicial}')" if !data_inicial.blank? && data_final.blank?
          datas = "recebimento_de_contas.data_evasao <= '#{data_final}')" if data_inicial.blank? && !data_final.blank?
          if datas.blank?
            sqls << "(parcelas.situacao = #{Parcela::EVADIDA} AND " +
              "recebimento_de_contas.situacao_fiemt = #{RecebimentoDeConta::Evadido})"
          else
            sqls << "(parcelas.situacao = #{Parcela::EVADIDA} AND " +
              "recebimento_de_contas.situacao_fiemt = #{RecebimentoDeConta::Evadido} AND " + datas
          end
        end

        #ENVIADAS AO DR        
       
        if params['situacao_das_parcelas'].include?(Parcela::ENVIADO_AO_DR.to_s)
           
          if !data_inicial.blank? && !data_final.blank?
            datas = "(parcelas.data_vencimento BETWEEN '#{data_inicial}' AND '#{data_final}')"
          end 
          
          
          if !datas.blank?
            sqls << "(parcelas.situacao = #{Parcela::ENVIADO_AO_DR}) AND "+datas
          
          else
            sqls << "(parcelas.situacao = #{Parcela::ENVIADO_AO_DR})"
          end
        
          
          
          
        end
        
        
        
        
      end      
    end
    
    #BAIXA DR
    if params.has_key?('situacao_baixa_dr')
      if !data_inicial.blank? && !data_final.blank?
        datas = "parcelas.data_da_baixa BETWEEN '#{data_inicial}' AND '#{data_final}')"
      end
      datas = "parcelas.data_da_baixa >= '#{data_inicial}')" if !data_inicial.blank? && data_final.blank?
      datas = "parcelas.data_da_baixa <= '#{data_final}')" if data_inicial.blank? && !data_final.blank?
      if datas.blank?
        sqls << '(parcelas.baixa_pela_dr = 1)'
      else
        sqls << '(parcelas.baixa_pela_dr = 1 AND ' + datas
      end
    end

    condicao = @sqls.join + '(' + sqls.join(' OR ') + ')'
    p "**************************************"
    p condicao

    ParcelaRecebimentoDeConta.find(:all, :conditions => condicao, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def self.pesquisar_parcelas_de_clientes_ao_spc(contar_ou_retornar, unidade_id)
    @sqls = ['(recebimento_de_contas.unidade_id = ?)', '(parcelas.situacao = ?)',
      '(parcelas.data_vencimento < ?)', '(pessoas.spc = ?)']
    @variaveis = [unidade_id, Parcela::PENDENTE, Date.today, true]
    ParcelaRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def self.pesquisar_produtividade_dos_funcionarios contar_ou_retornar, unidade_id, params
    @sqls = ['(recebimento_de_contas.unidade_id = ?)']
    @variaveis = [unidade_id]
    @sqls << '(parcelas.data_da_baixa IS NOT NULL)' if params['opcoes'] == 'Produtividade do Funcionário' || params['opcoes'] == 'Ações Cobranças Efetuadas'
    @sqls << '(parcelas.situacao = 4)' if params['opcoes'] == 'Renegociações Efetuadas'
    params["periodo"] == 'recebimento' ? sqls = 'parcelas.data_da_baixa' : sqls = 'parcelas.data_vencimento'
    if params['opcoes'] == 'Produtividade do Funcionário' || params['opcoes'] == 'Renegociações Efetuadas'
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, sqls
    elsif params['opcoes'] == 'Ações Cobranças Efetuadas'
      preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'recebimento_de_contas.data_venda'
    end

    preencher_array_para_buscar_por_faixa_de_datas params, :recebimento, 'parcelas.data_da_baixa'
    preencher_array_para_campo_com_auto_complete params, :servico, 'recebimento_de_contas.servico_id'
    preencher_array_para_campo_com_auto_complete params, :cliente, 'recebimento_de_contas.pessoa_id'
    preencher_array_para_campo_com_auto_complete params, :funcionario, 'recebimento_de_contas.cobrador_id'

    unless params['nome_cliente'].blank?
      @sqls << '(pessoas.cliente = ?)'
      @variaveis << true
    end
    unless params['nome_funcionario'].blank?
      @sqls << '(pessoas.funcionario = ?)'
      @variaveis << true
    end

    ParcelaRecebimentoDeConta.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def self.pesquisa_clientes_evadidos(contar_ou_retornar, unidade_id, params)
    @variaveis = []
    @sqls = []

    @sqls << "(recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.data_evasao IS NOT NULL AND parcelas.situacao = ?)"
    @variaveis << unidade_id
    @variaveis << Parcela::EVADIDA

    preencher_array_para_campo_com_auto_complete params, :servico, 'recebimento_de_contas.servico_id'
    preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'recebimento_de_contas.data_evasao'

    self.send(contar_ou_retornar, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => {:conta => :pessoa}, :order => 'pessoas.nome ASC, pessoas.razao_social ASC')
  end

  def self.enviadas_para_dr(unidade_id,data_inicial,data_final)
    @sqls = []
    @variaveis = []

    @sqls << 'recebimento_de_contas.unidade_id = ?'
    @variaveis << unidade_id

    p "*******************************************"
   

   if !data_inicial.blank? 
      @sqls << ' (parcelas.data_envio_ao_dr IS NOT NULL)'
      @sqls << ' parcelas.data_envio_ao_dr >= ?'
      @variaveis << data_inicial.to_date
    #  @sqls << ' parcelas.data_envio_ao_dr <= ?'
   #   @variaveis << params["data_final"].to_date
    end

    if !data_final.blank?
      @sqls << ' parcelas.data_envio_ao_dr <= ?'
      @variaveis << data_final.to_date
    end

   @sqls << 'parcelas.situacao = ?'
   @variaveis << Parcela::ENVIADO_AO_DR


   p [@sqls.join(' AND ')] + @variaveis

   retorno = ParcelaRecebimentoDeConta.find(:all, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => :conta, :order => 'data_vencimento ASC')
  p retorno
  retorno

  end

  def self.pesquisa_para_envio_dr(unidade_id, params)
    @sqls = []
    @variaveis = []

    @sqls << 'recebimento_de_contas.unidade_id = ?'
    @variaveis << unidade_id

    8.times do
      @sqls << 'parcelas.situacao <> ?'
    end

    @variaveis << Parcela::QUITADA
    #@variaveis << Parcela::ENVIADO_AO_DR
    @variaveis << Parcela::RENEGOCIADA
    @variaveis << Parcela::CANCELADA
    @variaveis << Parcela::EVADIDA
    @variaveis << Parcela::JURIDICO
    @variaveis << Parcela::DESCONTO_EM_FOLHA
  #  @variaveis << Parcela::DEVEDORES_DUVIDOSOS_ATIVOS
    @variaveis << Parcela::ESTORNADA
    @variaveis << Parcela::PERMUTA
    

    if !params["data_inicial"].blank? && !params["data_final"].blank?
      @sqls << '(parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (parcelas.parcela_original_id IS NULL)'
      @variaveis << params["data_inicial"].to_date
      @variaveis << params["data_final"].to_date
    end

    ParcelaRecebimentoDeConta.find(:all, :conditions => [@sqls.join(' AND ')] + @variaveis, :include => :conta, :order => 'data_vencimento ASC')
  end

  def self.pesquisa_simples_para_situacoes(unidade_id, parametros, page = nil)
    @sqls = []
    @variaveis = []
    @sqls << '(recebimento_de_contas.unidade_id = ?)'
    @variaveis << unidade_id
    ordem = parametros['ordem']

    unless parametros['texto'].blank?
      if ordem == 'situacao'
        ordem = 'parcelas.situacao'
        @sqls << '(parcelas.situacao = ?)'
        @variaveis << parametros['texto'].to_i
      end
    end

    ordem = 'parcelas.situacao' unless ordem

    parcelas = ParcelaRecebimentoDeConta.find(:all, :conditions => ([@sqls.join(' AND ')] + @variaveis), :include => {:conta => :pessoa}, :order => ordem)
    recebimento_de_contas = parcelas.group_by{|parcela| parcela.conta}
    recebimento_de_contas = recebimento_de_contas.each{|grupo, parcs| parcs.reject!{|parc| parc}}.compact
    recebimento_de_contas.paginate :page => page, :per_page => 50
  end
  
  def self.pesquisa_para_cartas(unidade_id, params)
    @sqls = []
    @variaveis = []
    @sqls << '(recebimento_de_contas.unidade_id = ?)'
    @variaveis << unidade_id
    
    unless params['cartas'].blank?
      sql_para_cartas = []
      array_carta = []
      params['cartas'].each do |carta|
        array_carta << carta
      end
      if array_carta.include?('carta_1')
        sql_para_cartas << '(recebimento_de_contas.data_primeira_carta IS NOT NULL)'
      end
      if array_carta.include?('carta_2')
        sql_para_cartas << '(recebimento_de_contas.data_segunda_carta IS NOT NULL)'
      end
      if array_carta.include?('carta_3')
        sql_para_cartas << '(recebimento_de_contas.data_terceira_carta IS NOT NULL)'
      end
      @sqls << sql_para_cartas.join(' OR ')
    end

    data_vencimento_min = params['periodo_cartas_min'].blank? ? '' : params['periodo_cartas_min'].to_date
    data_vencimento_max = params['periodo_cartas_max'].blank? ? '' : params['periodo_cartas_max'].to_date
    if !data_vencimento_min.blank? && !data_vencimento_max.blank?
      @sqls << 'parcelas.data_vencimento BETWEEN ? AND ?'
      @variaveis << data_vencimento_min
      @variaveis << data_vencimento_max
    end
    if !data_vencimento_min.blank? && data_vencimento_max.blank?
      @sqls << 'parcelas.data_vencimento >= ?'
      @variaveis << data_vencimento_min
    end
    if data_vencimento_min.blank? && !data_vencimento_max.blank?
      @sqls << 'parcelas.data_vencimento <= ?'
      @variaveis << data_vencimento_max
    end
    
    preencher_array_para_campo_com_auto_complete params, :servico, 'recebimento_de_contas.servico_id'
    preencher_array_para_campo_com_auto_complete params, :cliente, 'recebimento_de_contas.pessoa_id'

    pesquisa = ParcelaRecebimentoDeConta.find(:all, :include => {:conta => [:pessoa, :servico, :dependente]}, :conditions => ([@sqls.join(' AND ')] + @variaveis), :order => 'pessoas.nome ASC, pessoas.razao_social ASC')

    case params['dias_de_atraso'].to_i
    when 0; dia_min = 0; dia_max = 36500
    when CARTA_1; dia_min = 20; dia_max = 45
    when CARTA_2; dia_min = 45; dia_max = 90
    when CARTA_3; dia_min = 90; dia_max = 36500
    end
    pesquisa.select do |parcela|
      if params['numero_dias_atraso'].blank?
        parcela.verifica_situacoes && (Date.today - parcela.data_vencimento.to_date).numerator.between?(dia_min, dia_max)
      else
        dias_em_atraso = ((Date.today.to_datetime) - ((parcela.data_vencimento).to_date).to_datetime)
        dias_em_atraso = dias_em_atraso.to_i < 0 ? 0 : dias_em_atraso.to_i
        parcela.verifica_situacoes && (dias_em_atraso >= params['numero_dias_atraso'].to_i)
      end
    end
  end

end
