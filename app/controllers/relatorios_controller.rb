class RelatoriosController < ApplicationController

  PERMISSOES = {
    ['contas_a_pagar_geral', 'contas_a_pagar_retencao_impostos',
      'contas_a_pagar_visao_contabil'] => Perfil::ConsultarRelatoriosContasAPagar,
    ['contas_a_receber_cliente', 'historico_renegociacoes', 'pesquisa_historico_renegociacoes',
      'contas_a_receber_geral', 'contas_a_receber_geral_inadimplencia',
      'contas_a_receber_geral_recebimentos_com_atraso', 'contas_a_receber_geral_vendas_realizadas',
      'geral_do_contas_a_receber', 'produtividade_funcionario', 'renegociacoes_efetuadas',
      'acoes_de_cobranca', 'clientes_ao_spc', 'recuperacao_credito', 'totalizacao', 'pesquisa_emissao_cartas',
      'emissao_cartas', 'cartas_emitidas', 'controle_de_cartao', 'clientes_inadimplentes',
      'agendamentos', 'receitas_por_procedimento', 'evasao', 'contabilizacao_receitas',
      'faturamento','cancelados_evadidos','contratos_vendidos'] => Perfil::ConsultarRelatoriosContasAReceber,
    ['follow_up_cliente'] => Perfil::ConsultaDeTransacoes,
    ['contabilizacao_de_cheques'] => Perfil::ConsultarRelatoriosCheque,
    ['pesquisa_para_ordem', 'contabilizacao_ordem'] => Perfil::ConsultarRelatoriosContabilizacao,
    ['disponibilidade_efetiva', 'extrato_contas'] => Perfil::ConsultarRelatoriosContasCorrentes
  }

  # ---------------------  before Filter para testar metodo gera_filtros_dos_relatorios ---------------------
  #    before_filter :p_filtros
  #
  #    def p_filtros
  #       if !params[:busca].blank? || !params[:movimento].blank?
  #        render :update do |page|
  #          page.alert(gera_filtros_dos_relatorios(params[:busca] || params[:movimento], params[:action]))
  #        end
  #      end
  #    end

  def contas_a_receber_cliente_historico
    params[:busca] ||= {:periodo_min => Date.today.to_s_br, :periodo_max => Date.today.to_s_br}
    @parcelas = ParcelaRecebimentoDeConta.pesquisa_contas_a_receber_historico_clientes(session[:unidade_id], params[:busca])
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          excecao = '* Selecione ao menos uma situação de parcela' if !params[:busca].has_key?(:situacao_das_parcelas) && !params[:busca].has_key?(:situacao_baixa_dr)
          unless excecao.blank?
            page.alert excecao
          else
            if @parcelas.length == 0
              page.alert('Não foram encontrados registros com estes parâmetros.')
            else
              page.new_window_to contas_a_receber_cliente_historico_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
      format.print do
        @titulo = 'HISTÓRICO DE CLIENTES'
        @situacoes = Parcela.situacoes_para_cabecalho(params[:busca][:situacao_das_parcelas], params[:busca][:situacao_baixa_dr])
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        @titulo = 'HISTÓRICO DE CLIENTES'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def contas_a_receber_cliente_visao_contabil
    params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisa_contas_a_receber_clientes_visao_contabil(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :count
        render :update do |page|
          excecao = '*Defina o período para a pesquisa' if params[:busca][:periodo_min].blank? ||  params[:busca][:periodo_max].blank?
          if !excecao.blank?
            page.alert excecao
          else
            if @parcelas == 0
              page.alert("Não foram encontrados registros com estes parâmetros.")
            else
              page.new_window_to contas_a_receber_cliente_visao_contabil_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
      format.print do
        carregar_contratos.call :all
        #        if params[:busca][:relatorio] == 'detalhado'
        @parcelas = @parcelas.group_by{|parcela| parcela.conta}
        #        end
        @titulo = 'CLIENTES - VISÃO CONTÁBIL'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_contratos.call :all
        #        if params[:busca][:relatorio] == 'detalhado'
        @parcelas = @parcelas.group_by{|parcela| parcela.conta}
        #        end
        @titulo = 'CLIENTES - VISÃO CONTÁBIL'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def historico_renegociacoes
    params[:busca] ||= {}
    if params[:busca][:numero_de_controle].blank?
      @recebimentos_renegociados = RecebimentoDeConta.find(:all, :conditions => ['(numero_de_renegociacoes >= ?) AND (unidade_id = ?)', 1, session[:unidade_id]])
    else
      @recebimentos_renegociados = RecebimentoDeConta.find(:all, :conditions => ['(numero_de_renegociacoes >= ?) AND (unidade_id = ?) AND (numero_de_controle = ?)', 1, session[:unidade_id], params[:busca][:numero_de_controle]])
    end
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          if @recebimentos_renegociados.blank?
            page.alert("Não foram encontrados registros com estes parâmetros.")
          else
            page.new_window_to :url => historico_renegociacoes_relatorios_path, :format => params[:tipo], :busca => params[:busca]
          end
        end
      end
      format.pdf do
        @titulo = "HISTÓRICO DE RENEGOCIAÇÕES"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        @titulo = "HISTÓRICO DE RENEGOCIAÇÕES"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def pesquisa_historico_renegociacoes
    params[:busca] ||= {}
    params[:busca][:numero_de_renegocicoes] = 1
    @recebimentos = RecebimentoDeConta.pesquisa_simples(session[:unidade_id], params[:busca])
    render :update do |page|
      if @recebimentos.blank?
        page.replace 'resultados_pesquisa_ordem', :text => "<div id=\"resultados_pesquisa_ordem\"></div>"
        page.alert "Não foram encontrados registros com estes parâmetros."
      else
        page.replace 'resultados_pesquisa_ordem', :partial => 'resultado_pesquisa_historico_renegociacoes', :object => @recebimentos
      end
    end
  end

  def pesquisa_para_ordem
    @movimentos_contabilizados = Movimento.procurar_movimentos(params['conta'], session[:unidade_id])
    render :update do |page|
      if @movimentos_contabilizados.blank?
        page.replace 'resultados_pesquisa_ordem', :text => "<div id=\"resultados_pesquisa_ordem\"></div>"
        page.alert "Não foram encontrados registros com estes parâmetros."
      else
        page.replace 'resultados_pesquisa_ordem', :partial => 'resultado_pesquisa_ordem', :object => @movimentos_contabilizados
      end
    end
  end

  def contabilizacao_ordem
    @movimentos = Movimento.procurar_movimentos(params['movimento'], session[:unidade_id], true) if params['movimento']
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          if @movimentos && !@movimentos.empty?
            page.new_window_to :url => contabilizacao_ordem_relatorios_path, :format => params[:tipo], :movimento => params['movimento']
          else
            page.alert("Não foram encontrados registros com estes parâmetros.")
          end
        end
      end
      format.print do
        @titulo = "MOVIMENTO DA CONTABILIZAÇÃO DA ORDEM"
        params[:busca] = params['movimento']
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        @titulo = "MOVIMENTO DA CONTABILIZAÇÃO DO LANÇAMENTO"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def contas_a_receber_geral
    params[:busca] ||= {:recebimento_min => Date.today.to_s_br, :recebimento_max => Date.today.to_s_br}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_parcelas.call :count
        render :update do |page|
          if @parcelas == 0
            page.alert 'Nenhum registro foi encontrado!'
          elsif params[:busca][:opcoes] == 'Recebimentos'
            page.new_window_to contas_a_receber_geral_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          elsif params[:busca][:opcoes] == 'Inadimplência' || params[:busca][:opcoes] == 'Contas a Receber'
            page.new_window_to contas_a_receber_geral_inadimplencia_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          elsif params[:busca][:opcoes] == 'Vendas Realizadas'
            page.new_window_to contas_a_receber_geral_vendas_realizadas_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          elsif params[:busca][:opcoes] == 'Recebimentos com Atraso'  
            page.new_window_to contas_a_receber_geral_recebimentos_com_atraso_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          else
            page.new_window_to geral_do_contas_a_receber_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.print do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico}
        @titulo = 'ADIMPLÊNCIA'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        #render :layout => 'relatorio_horizontal_a3'
      end
      format.xls do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico}
        @titulo = 'ADIMPLÊNCIA'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
 
  def contas_a_receber_geral_inadimplencia
    params[:busca] ||= {}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.print do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico}
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        #render :layout => 'relatorio_horizontal'
      end
      format.xls do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico}
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end  
  end
  
  def contas_a_receber_geral_recebimentos_com_atraso
    params[:busca] ||= {}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral contar_ou_retornar, session[:unidade_id], params[:busca]
    end
    respond_to do |format|
      format.html
      format.print do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico }
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico }
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end  
  end
  
  def contas_a_receber_geral_vendas_realizadas
    params[:busca] ||= {}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral contar_ou_retornar, session[:unidade_id], params[:busca]
    end
    respond_to do |format|
      format.html
      format.print do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico }
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico }
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def geral_do_contas_a_receber
    params[:busca] ||= {}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral contar_ou_retornar, session[:unidade_id], params[:busca]
    end
    respond_to do |format|
      format.html
      format.print do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico }
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        #render :layout => 'relatorio_horizontal_a3'
      end
      format.xls do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.nome_servico }
        @titulo = params[:busca][:opcoes].blank? ? '' : params[:busca][:opcoes].upcase
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def produtividade_funcionario
    params[:busca] ||= {}
    carregar_contas = lambda do |contar_ou_retornar|
      case params[:busca][:opcoes]
      when 'Produtividade do Funcionário'; @parcelas = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios(contar_ou_retornar, session[:unidade_id], params[:busca])
      when 'Renegociações Efetuadas'; @contas = RecebimentoDeConta.pesquisa_renegociacoes(contar_ou_retornar, session[:unidade_id], params[:busca])
      when 'Ações Cobranças Efetuadas'; @historicos = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario(contar_ou_retornar, session[:unidade_id], params[:busca])
      end
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contas.call :count
        render :update do |page|
          case params[:busca][:opcoes]
          when 'Produtividade do Funcionário'; tipo = :produtividade_funcionario_relatorios_path
          when 'Renegociações Efetuadas'; tipo = :renegociacoes_efetuadas_relatorios_path
          when 'Ações Cobranças Efetuadas'; tipo = :acoes_de_cobranca_relatorios_path
          end
          if (@parcelas || @contas || @historicos) == 0
            page.alert 'Nenhum registro foi encontrado!'
          else 
            page.new_window_to send(tipo, :format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.pdf do
        carregar_contas.call :all
        @parcelas = @parcelas.group_by{|parcela| !parcela.conta.cobrador.blank? ? parcela.conta.cobrador.nome : 'Sem cobrador cadastrado'}
        @titulo = params[:busca][:opcoes].upcase if params[:busca][:opcoes]
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        carregar_contas.call :all
        @parcelas = @parcelas.group_by{|parcela| !parcela.conta.cobrador.blank? ? parcela.conta.cobrador.nome : 'Sem cobrador cadastrado'}
        @titulo = params[:busca][:opcoes].upcase if params[:busca][:opcoes]
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def renegociacoes_efetuadas
    params[:busca] ||= {}
    carregar_contas = lambda do |contar_ou_retornar|
      @contas = RecebimentoDeConta.pesquisa_renegociacoes(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.pdf do
        carregar_contas.call :all
        @contas = @contas.group_by{|conta| conta.cobrador.nil? ? "Sem cobrador" : conta.cobrador.nome}
        @titulo = params[:busca][:opcoes].upcase if params[:busca][:opcoes]
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        carregar_contas.call :all
        @contas = @contas.group_by{|conta| conta.cobrador.nil? ? "Sem cobrador" : conta.cobrador.nome}
        @titulo = params[:busca][:opcoes].upcase if params[:busca][:opcoes]
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def acoes_de_cobranca
    params[:busca] ||= {}
    carregar_contas = lambda do |contar_ou_retornar|
      @historicos = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.pdf do
        carregar_contas.call :all
        @historicos = @historicos.group_by{|historico| !historico.conta.cobrador.blank? ? historico.conta.cobrador.nome : 'Sem Cobrador cadastrado'}
        @titulo = params[:busca][:opcoes].upcase if params[:busca][:opcoes]
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        carregar_contas.call :all
        @historicos = @historicos.group_by{|historico| !historico.conta.cobrador.blank? ? historico.conta.cobrador.nome : 'Sem Cobrador cadastrado'}
        @titulo = params[:busca][:opcoes].upcase if params[:busca][:opcoes]
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def contas_a_pagar_geral
    params[:busca] ||= {:periodo_min => Date.today.to_s_br, :periodo_max => Date.today.to_s_br}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_parcelas.call :count
        render :update do |page|
          if @parcelas == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to contas_a_pagar_geral_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      #      format.pdf do
      #        carregar_parcelas.call :all
      #        @parcelas = @parcelas.group_by{|parcela| parcela.conta.pessoa.nome}
      #        @titulo =
      #          case params[:busca][:opcao_de_relatorio]
      #        when ''; 'CONTAS A PAGAR GERAL'
      #        when 'pagamentos'; 'PAGAMENTOS'
      #        when 'inadimplencia'; 'INADIMPLÊNCIA'
      #        when 'contas_a_pagar'; 'CONTAS À PAGAR'
      #        when 'pagamentos_com_atraso'; 'PAGAMENTOS COM ATRASO'
      #        end
      #        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      #        render :layout => 'relatorio_horizontal_a3'
      #      end
      format.print do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.pessoa.nome}
        @titulo =
          case params[:busca][:opcao_de_relatorio]
        when ''; 'CONTAS A PAGAR GERAL'
        when 'pagamentos'; 'PAGAMENTOS'
        when 'inadimplencia'; 'INADIMPLÊNCIA'
        when 'contas_a_pagar'; 'CONTAS À PAGAR'
        when 'pagamentos_com_atraso'; 'PAGAMENTOS COM ATRASO'
        end
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_parcelas.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.pessoa.nome}
        @titulo =
          case params[:busca][:opcao_de_relatorio]
        when ''; 'CONTAS A PAGAR GERAL'
        when 'pagamentos'; 'PAGAMENTOS'
        when 'inadimplencia'; 'INADIMPLÊNCIA'
        when 'contas_a_pagar'; 'CONTAS À PAGAR'
        when 'pagamentos_com_atraso'; 'PAGAMENTOS COM ATRASO'
        end
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def contas_a_pagar_retencao_impostos
    params[:busca] ||= {:recolhimento_min => Date.today.to_s_br, :recolhimento_max => Date.today.to_s_br}
    carregar_lancamentos = lambda do |contar_ou_retornar|
      @lancamentos = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_lancamentos.call :count
        render :update do |page|
          if @lancamentos == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to contas_a_pagar_retencao_impostos_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.print do
        carregar_lancamentos.call :all
        @lancamentos = @lancamentos.group_by{|lancamento| lancamento.parcela.conta}
        @titulo = 'RETENÇÃO DE IMPOSTOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_lancamentos.call :all
        @lancamentos = @lancamentos.group_by{|lancamento| lancamento.parcela.conta}
        @titulo = 'RETENÇÃO DE IMPOSTOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end  
  end

  def disponibilidade_efetiva
    params[:busca] ||= {:data_max => Date.today.to_s_br}
    params[:busca][:data_max] = Date.today.to_s_br if params[:busca][:data_max].blank?
    params[:busca][:tipo_de_relatorio] = ItensMovimento::RELATORIO_DISPONIBILIDADE_EFETIVA

    carregar_movimentos = lambda do |contar_ou_retornar|
      @itens_movimentos = ItensMovimento.disponibilidade_efetiva(contar_ou_retornar, params[:busca], session[:unidade_id])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_movimentos.call :count
        render :update do |page|
          if @itens_movimentos == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to disponibilidade_efetiva_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.pdf do
        carregar_movimentos.call :all
        @titulo = 'DISPONIBILIDADE EFETIVA'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_movimentos.call :all
        @titulo = 'DISPONIBILIDADE EFETIVA'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def extrato_contas
    params[:busca] ||= {:data_min => Date.today.to_s_br, :data_max => Date.today.to_s_br}
    params[:busca][:tipo_de_relatorio] = ItensMovimento::RELATORIO_EXTRATO_CONTAS

    carregar_movimentos = lambda do |contar_ou_retornar|
      @itens_movimentos = ItensMovimento.disponibilidade_efetiva(contar_ou_retornar, params[:busca], session[:unidade_id])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_movimentos.call :count
        render :update do |page|
          if @itens_movimentos == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to extrato_contas_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.print do
        carregar_movimentos.call :all
        @titulo = 'EXTRATO DE CONTAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_movimentos.call :all
        @titulo = 'EXTRATO DE CONTAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def extrato_contas_beta
    params[:busca] ||= {:data_min => Date.today.to_s_br, :data_max => Date.today.to_s_br}
    carregar_movimentos = lambda do |contar_ou_retornar|
      @itens_movimentos = ItensMovimento.extrato_de_contas_beta(contar_ou_retornar, params[:busca], session[:unidade_id])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_movimentos.call :count
        render :update do |page|
          if @itens_movimentos == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to extrato_contas_beta_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.print do
        carregar_movimentos.call :all
        @titulo = 'EXTRATO DE CONTAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_movimentos.call :all
        @titulo = 'EXTRATO DE CONTAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def clientes_ao_spc
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_de_clientes_ao_spc(:count, session[:unidade_id])
          if @parcelas == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to clientes_ao_spc_relatorios_path(:format => 'xls')
          end
        end
      end
      format.xls do
        @parcelas = ParcelaRecebimentoDeConta.pesquisar_parcelas_de_clientes_ao_spc(:all, session[:unidade_id])
        Audit.criar_audit(current_usuario, 'Clientes ao SPC', session[:unidade_id], params[:busca])
        render :layout => false
      end
    end
  end

  def recuperacao_credito
    params[:busca] ||= {}
    @contas = Parcela.recuperacao_de_creditos(session[:unidade_id], params[:busca]) unless params[:busca].blank?
    params[:busca][:mes_inicial] ||= 1
    params[:busca][:mes_final] ||= 12
    mes_inicial = Date::MONTHNAMES[params[:busca][:mes_inicial].to_i] || Date::MONTHNAMES[1]
    mes_final = Date::MONTHNAMES[params[:busca][:mes_final].to_i] || Date::MONTHNAMES[12]
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          if @contas.blank?
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to recuperacao_credito_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.print do
        @titulo = 'DEMONSTRATIVO DE COBRANÇA - RECUPERAÇÃO DE CRÉDITOS'
        @titulo += " - #{mes_inicial.upcase} A #{mes_final.upcase}"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        #render :layout => 'relatorio_horizontal_a3'
      end
      format.xls do
        @titulo = 'DEMONSTRATIVO DE COBRANÇA - RECUPERAÇÃO DE CRÉDITOS'
        @titulo += " - #{mes_inicial.upcase} A #{mes_final.upcase}"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def contabilizacao_de_cheques
    params[:busca] ||= {"periodo_min"=>Date.today.to_s_br,"periodo_max"=>Date.today.to_s_br}
    @cheques = Cheque.retorna_cheques_para_relatorio(params[:busca], session[:unidade_id])
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          if @cheques.blank?
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to contabilizacao_de_cheques_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.pdf do
        case params[:busca][:filtro]
        when '1'; complemento = 'À VISTA'
        when '2'; complemento = 'PRÉ-DATADOS'
        when '3'; complemento = 'DEVOLVIDOS'
        when '4'; complemento = 'BAIXADOS'
        end
        @titulo = "RELAÇÃO DE CHEQUES #{complemento}"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        case params[:busca][:filtro]
        when '1'; complemento = 'À VISTA'
        when '2'; complemento = 'PRÉ-DATADOS'
        when '3'; complemento = 'DEVOLVIDOS'
        when '4'; complemento = 'BAIXADOS'
        end
        @titulo = "RELAÇÃO DE CHEQUES #{complemento}"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def totalizacao
    params[:busca] ||= {:periodo_min => Date.today.to_s_br, :periodo_max => Date.today.to_s_br}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = Parcela.relatorio_para_totalizacao(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_parcelas.call :count
        render :update do |page|
          if @parcelas == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            if params[:busca][:tipo] == "pdf"
              page.new_window_to totalizacao_relatorios_path(:format => 'pdf', :busca => params[:busca])
            elsif params[:busca][:tipo] == "xls"
              page.new_window_to totalizacao_relatorios_path(:format => 'xls', :busca => params[:busca])
            end
          end
        end
      end
      format.pdf do
        carregar_parcelas.call :all
        @titulo = 'TOTALIZAÇÃO'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        carregar_parcelas.call :all
        @titulo = 'TOTALIZAÇÃO'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => false
      end
    end
  end

  def emissao_cartas
    params[:busca] ||= {}
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          if !params[:recebimentos][:etiqueta].blank? && !['A4263', '6080', '6081', '6082', '6083'].include?(params[:recebimentos][:etiqueta])
            page.alert 'Selecione uma das opções de etiquetas válida!'
          else
            unless params[:recebimentos].has_key?(:tipo)
              page.alert 'Selecione uma das opções de geração!'
            else
              if params[:recebimentos].has_key?(:ids)
                params[:recebimentos][:usuario] = current_usuario
                @recebimento_de_contas = RecebimentoDeConta.vincular_carta(params[:recebimentos])
                if @recebimento_de_contas.is_a?(Array)
                  page.new_window_to :format => 'pdf', :recebimentos => params[:recebimentos]
                else
                  page.alert @recebimento_de_contas
                end
              else
                page.alert 'Selecione pelo menos um contrato!'
              end
            end
          end
        end
      end
      format.pdf do
        if params[:recebimentos][:tipo][:cartas]
          @unidade = Unidade.find(session[:unidade_id])
          @titulo = "EMISSÃO DE CARTA DE COBRANÇA"
          Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
          render :layout => 'carta_cobranca'

        elsif params[:recebimentos][:tipo][:etiquetas]
          @unidade = Unidade.find(session[:unidade_id])
          recebimentos = []
          recebimentos_temp = []
          params[:recebimentos][:ids].each_with_index do |identificador, index|
            recebimento = RecebimentoDeConta.find(identificador)
            #recebimentos_temp << "#{recebimento.pessoa.nome.upcase} \n #{recebimento.pessoa.endereco.upcase}, #{recebimento.pessoa.numero.upcase if recebimento.pessoa.numero}, #{recebimento.pessoa.bairro.upcase if recebimento.pessoa.bairro} - #{recebimento.pessoa.complemento} \n #{recebimento.pessoa.localidade.nome.upcase if recebimento.pessoa.localidade} - #{recebimento.pessoa.localidade.uf.upcase if recebimento.pessoa.localidade} #{recebimento.pessoa.cep.upcase if recebimento.pessoa.cep}"
            dados = recebimento.pessoa.nome.upcase + "\n"
            dados += recebimento.pessoa.endereco.upcase + ', '
            dados += recebimento.pessoa.numero ? (recebimento.pessoa.numero.upcase + "\n") : ''
            dados += recebimento.pessoa.complemento ? (recebimento.pessoa.complemento + ' - ') : ''
            dados += recebimento.pessoa.bairro ? (recebimento.pessoa.bairro.upcase + "\n") : ''
            dados += recebimento.pessoa.cep ? (recebimento.pessoa.cep.upcase + ' - ') : ''
            dados += recebimento.pessoa.localidade ? (recebimento.pessoa.localidade.nome.upcase + ' - ' ) : ''
            dados += recebimento.pessoa.localidade ? recebimento.pessoa.localidade.uf.upcase : ''

            recebimentos_temp << dados
          end

          tlinha = RecebimentoDeConta::ETIQUETAS[params[:recebimentos][:etiqueta]][:linha]
          tcoluna = RecebimentoDeConta::ETIQUETAS[params[:recebimentos][:etiqueta]][:coluna]

          linha = params[:recebimentos][:linha].to_i-1
          coluna = params[:recebimentos][:coluna].to_i-1

          begin
            0.upto(tlinha) do |i|
              0.upto(tcoluna) do |j|
                if(i == linha && j >= coluna) || (i > linha)
                  raise("sair")
                end
                recebimentos << ""
              end
            end
          rescue Exception => e
            #p "sair"
          end
          
          recebimentos_temp.each do |auxiliar|
            recebimentos << auxiliar
          end

          if params[:recebimentos][:etiqueta] == 'A4263'
            etiqueta_file_name = "A4263_etiquetas.pdf"
            document = Prawn::Labels.generate(etiqueta_file_name, recebimentos, :type => 'A4263') do |pdf, recebimento|
              pdf.font_size(9)
              pdf.text recebimento
            end
          elsif params[:recebimentos][:etiqueta] == '6080'
            etiqueta_file_name = "6080_etiquetas.pdf"
            document = Prawn::Labels.generate(etiqueta_file_name, recebimentos, :type => 'E6080') do |pdf, recebimento|
              pdf.font_size(9)
              pdf.text recebimento
            end
          elsif params[:recebimentos][:etiqueta] == '6081'
            etiqueta_file_name = "6081_etiquetas.pdf"
            document = Prawn::Labels.generate(etiqueta_file_name, recebimentos, :type => 'E6081') do |pdf, recebimento|
              pdf.font_size(9)
              pdf.text recebimento
            end
          elsif params[:recebimentos][:etiqueta] == '6082'
            etiqueta_file_name = "6082_etiquetas.pdf"
            document = Prawn::Labels.generate(etiqueta_file_name, recebimentos, :type => 'E6082') do |pdf, recebimento|
              pdf.font_size(9)
              pdf.text recebimento
            end
          elsif params[:recebimentos][:etiqueta] == '6083'
            etiqueta_file_name = "6083_etiquetas.pdf"
            document = Prawn::Labels.generate(etiqueta_file_name, recebimentos, :type => 'E6083') do |pdf, recebimento|
              pdf.font_size(9)
              pdf.text recebimento
            end
          end
          send_data document, :filename => etiqueta_file_name, :type => 'application/pdf', :disposition => 'inline'
          Audit.criar_audit(current_usuario, "Etiquetas #{params[:recebimentos][:etiquetas]}", session[:unidade_id], 'pdf')
        end
      end
    end
  end

  def pesquisa_emissao_cartas
    params[:busca][:emissao_cartas] = true
    #@recebimento_de_contas = RecebimentoDeConta.pesquisa_simples(session[:unidade_id], params[:busca])
    @recebimento_de_contas = ParcelaRecebimentoDeConta.pesquisa_para_cartas(session[:unidade_id], params[:busca])
    render :update do |page|
      if @recebimento_de_contas.length == 0
        page.alert('Não foram encontrados recebimentos com estes parâmetros!')
        page.replace :resultado_da_busca, :text => "<div id=\"resultado_da_busca\"></div>"
      else
        @recebimento_de_contas = @recebimento_de_contas.group_by{|parcela| parcela.conta}
        page.replace :resultado_da_busca, :partial => 'resultado_pesquisa_emissao_cartas'
      end
    end
  end

  def cartas_emitidas
    params[:busca] ||= {}
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          @historico_operacoes = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes(:count, params[:busca])
          if @historico_operacoes == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to :format => params[:tipo], :url => cartas_emitidas_relatorios_path, :busca => params[:busca]
          end
        end
      end
      format.print do
        @historico_operacoes = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes(:all, params[:busca])
        @titulo = "CARTAS EMITIDAS"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        @historico_operacoes = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes(:all, params[:busca])
        @titulo = "CARTAS EMITIDAS"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horinzontal'
      end
    end
  end

  def controle_de_cartao
    params[:busca] ||= {:data_de_recebimento_min => Date.today.to_s_br, :data_de_recebimento_max => Date.today.to_s_br}
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          @cartoes = Cartao.pesquisar_cartoes(params[:busca], session[:unidade_id])
          if @cartoes.blank?
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to :format => params[:tipo], :url => controle_de_cartao_relatorios_path, :busca => params[:busca]
          end
        end
      end
      format.print do
        @titulo = "CONTROLE DE CARTÕES DE CRÉDITO"
        @cartoes = Cartao.pesquisar_cartoes(params[:busca], session[:unidade_id])
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        @titulo = "CONTROLE DE CARTÕES DE CRÉDITO"
        @cartoes = Cartao.pesquisar_cartoes(params[:busca], session[:unidade_id])
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horinzontal'
      end
    end
  end

  def clientes_inadimplentes
    params[:busca] ||= {}
    params[:busca][:cliente_id] = '' if params[:busca][:nome_cliente].blank?
    carregar_lancamentos = lambda do |contar_ou_retornar|
      @contas_receber = RecebimentoDeConta.pesquisa_clientes_inadimplentes(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_lancamentos.call :count
        render :update do |page|
          if @contas_receber == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to :format => params[:tipo], :url => clientes_inadimplentes_relatorios_path, :busca => params[:busca]
          end
        end
      end
      format.print do
        carregar_lancamentos.call :all
        @contas_receber = @contas_receber.group_by{|conta| conta.pessoa}
        @titulo = "RELAÇÃO DE CLIENTES INADIMPLENTES"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_lancamentos.call :all
        @contas_receber = @contas_receber.group_by{|conta| conta.pessoa}
        @titulo = "RELAÇÃO DE CLIENTES INADIMPLENTES"
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horinzontal'
      end
    end
  end

  def follow_up_cliente
    params[:busca] ||= {}
    carregar_lancamentos = lambda do |contar_ou_retornar|
      @historico_operacoes = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_cliente(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_lancamentos.call :count
        render :update do |page|
          if @historico_operacoes == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to follow_up_cliente_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.pdf do
        carregar_lancamentos.call :all
        @titulo = 'FOLLOW-UP POR CLIENTE'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_lancamentos.call :all
        @titulo = 'FOLLOW-UP POR CLIENTE'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def agendamentos
    params[:busca] ||= {}
    carregar_lancamentos = lambda do |contar_ou_retornar|
      @compromissos = CompromissoRecebimentoDeConta.pesquisa_agendamentos(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_lancamentos.call :count
        render :update do |page|
          if @compromissos == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to agendamentos_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.print do
        carregar_lancamentos.call :all
        @compromissos = @compromissos.group_by{|compromisso| compromisso.conta.pessoa.nome}
        @titulo = 'AGENDAMENTOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_lancamentos.call :all
        @compromissos = @compromissos.group_by{|compromisso| compromisso.conta.pessoa.nome}
        @titulo = 'AGENDAMENTOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def receitas_por_procedimento
    params[:busca] ||= {}
    carregar_lancamentos = lambda do |contar_ou_retornar|
      @lancamentos = ItensMovimento.pesquisa_receitas_das_contas_contabeis(contar_ou_retornar, session[:unidade_id],params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_lancamentos.call :count
        render :update do |page|
          if @lancamentos == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to receitas_por_procedimento_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.pdf do
        carregar_lancamentos.call :all
        @lancamentos = @lancamentos.group_by{|lancamento| lancamento.unidade_organizacional.nome}
        @titulo = 'RECEITAS POR PROCEDIMENTO'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
      format.xls do
        carregar_lancamentos.call :all
        @lancamentos = @lancamentos.group_by{|lancamento| lancamento.unidade_organizacional.nome}
        @titulo = 'RECEITAS POR PROCEDIMENTO'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def evasao
    params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @parcelas = ParcelaRecebimentoDeConta.pesquisa_clientes_evadidos(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :count
        render :update do |page|
          if @parcelas == 0
            page.alert 'Nenhum registro foi encontrado!'
          else
            page.new_window_to evasao_relatorios_path(:format => params[:tipo], :busca => params[:busca])
          end
        end
      end
      format.pdf do
        carregar_contratos.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.pessoa.nome}
        @titulo = 'RELATÓRIO EVASÃO ESCOLAR'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal_a3'
      end
      format.xls do
        carregar_contratos.call :all
        @parcelas = @parcelas.group_by{|parcela| parcela.conta.pessoa.nome}
        @titulo = 'RELATÓRIO EVASÃO ESCOLAR'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def alteracao_contas
    params[:busca] ||={}
    carregar_contratos = lambda do |contar_ou_retornar|
      @contratos = RecebimentoDeConta.pesquisa_contratos_contabilizados(contar_ou_retornar,session[:unidade_id],params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :all
        render :update do |page|
          if params[:busca][:ano].blank? || params[:busca][:mes].blank? || params[:busca][:conta_contabil_id].blank?
            page.alert 'Todos os parâmetros de pesquisa devem ser preenchidos!'
          else
						
            if @contratos.length == 0
              page.alert 'Nenhum registro foi encontrado!'
            else
              page.replace_html('resultado_pesquisa',:partial => 'alteracao_contratos_encontrados',:locals=>{:contratos=>@contratos})
            end
          end
        end
      end
    end
  end

  def efetuar_alteracao_contas
    params[:contratos] ||= []
    params[:busca] ||={}
    msg = ""
		contas_antigas = []
		respond_to do |format|
			format.js do
				render :update do |page|
					if params[:contratos].length == 0
						msg = "Selecione ao menos um contrato; \n"
					end
					if params[:busca][:nova_conta_contabil_id].blank?
						msg += "Selecione o campo nova conta contábil \n"
					end

					if msg.blank?
						params[:contratos].each do |contrato_id|
							contrato = RecebimentoDeConta.find contrato_id
							contas_antigas << (contrato.conta_contabil_receita rescue nil)
							contrato.conta_contabil_receita_id = params[:busca][:nova_conta_contabil_id].split("_").last
              novo_centro = contrato.centro.pesquisar_correspondente_no_ano_de(session[:ano].to_i) rescue nil
							contrato.centro = novo_centro unless novo_centro.blank?
							nova_unidade_organizacional = contrato.unidade_organizacional.pesquisar_correspondente_no_ano_de(session[:ano].to_i) rescue nil
							contrato.unidade_organizacional = nova_unidade_organizacional unless nova_unidade_organizacional.blank?
							contrato.save false
              contrato.reload
              #p ["CONTRATO", contrato.unidade_organizacional_id, contrato.centro_id, contrato.conta_contabil_receita_id]

							HistoricoOperacao.cria_follow_up("Conta Contábil de Receita do Contrato foi alterada", current_usuario, contrato)
							contrato.parcelas.each do |parcela|
								parcela.rateios.each do |rateio|
                  if rateio.conta_contabil_id == contas_antigas.first.id
                    rateio.conta_contabil_id = params[:busca][:nova_conta_contabil_id].split("_").last
                  end
                  rateio.centro_id = novo_centro.id
                  rateio.unidade_organizacional_id = nova_unidade_organizacional.id
                  #p ["RATEIO", rateio.unidade_organizacional_id, rateio.centro_id, rateio.conta_contabil_id]
                  rateio.save false
								end
								HistoricoOperacao.cria_follow_up("Alteração conta contábil para o rateio", current_usuario, parcela)
							end
						end
            page.alert 'Os contratos foram processados com sucesso!'
            page << "window.location.href='#{alteracao_efetuada_relatorios_path(:contratos=>params[:contratos],:contas_antigas => contas_antigas,:format=>"print")}'"
					else
						page.alert msg
					end
				end
				format.print do
				end
			end
		end
  end

	def alteracao_efetuada
		@contratos = []
		@contas_antigas = params[:contas_antigas]
		@titulo = 'Contratos Alterados'
		params[:contratos].each do |contrato_id|
			@contratos << RecebimentoDeConta.find(contrato_id)
		end
	end

  def contabilizacao_receitas
    params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @recebimentos = RecebimentoDeConta.pesquisa_contabilizacao_receitas(contar_ou_retornar, session[:unidade_id], params[:busca], session[:ano])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :count
        render :update do |page|
          numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
          if !numero_mes.include?(params[:busca][:mes])
            page.alert 'Insira um mês válido para a busca'
          else
            if @recebimentos == 0
              page.alert 'Nenhum registro foi encontrado!'
            else
              page.new_window_to contabilizacao_receitas_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
      format.print do
        carregar_contratos.call :all
        @recebimentos = @recebimentos.group_by{|conta| conta.servico.descricao}
        @titulo = 'RELATÓRIO DE CONTABILIZAÇÃO DAS RECEITAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_contratos.call :all
        @recebimentos = @recebimentos.group_by{|conta| conta.servico.descricao}
        @titulo = 'RELATÓRIO DE CONTABILIZAÇÃO DAS RECEITAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def cancelados_evadidos
     params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @recebimentos = RecebimentoDeConta.contratos_cancelados(contar_ou_retornar, session[:unidade_id], params[:busca], session[:ano])
    end
    respond_to do |format|
      format.html
      format.js do
         carregar_contratos.call :count
        render :update do |page|
         # numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
          if (params[:busca][:periodo_min].blank? || params[:busca][:periodo_max].blank?)
            page.alert 'Preencha um período válido!'
          else
            if @recebimentos == 0
              page.alert 'Nenhum registro foi encontrado!'
            else
              page.new_window_to cancelados_evadidos_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
       format.print do
         @data = params[:busca][:periodo_min].to_date
         @data_final = params[:busca][:periodo_max].to_date
        carregar_contratos.call :all
        @recebimentos = @recebimentos.group_by{|conta| conta.servico.descricao}
        @titulo = 'RELATÓRIO DE CONTRATOS EVADIDOS/CANCELADOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
       format.xls do
          @data = params[:busca][:periodo_min].to_date
         @data_final = params[:busca][:periodo_max].to_date
        carregar_contratos.call :all
        @recebimentos = @recebimentos.group_by{|conta| conta.servico.descricao}
        @titulo = 'RELATÓRIO DE CONTRATOS EVADIDOS/CANCELADOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def faturamento
    params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @recebimentos = RecebimentoDeConta.faturamento_clientes(contar_ou_retornar, session[:unidade_id], params[:busca], session[:ano])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :count
        render :update do |page|
          numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname) + 1).to_s}
          if !numero_mes.include?(params[:busca][:mes])
            page.alert 'Insira um mês válido para a busca'
          else
            if @recebimentos == 0
              page.alert 'Nenhum registro foi encontrado!'
            else
              page.new_window_to faturamento_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
      format.print do
        carregar_contratos.call :all
        @recebimentos = @recebimentos.group_by{|conta| conta.servico.descricao}
        @titulo = 'RELATÓRIO DE FATURAMENTO'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_contratos.call :all
        @recebimentos = @recebimentos.group_by{|conta| conta.servico.descricao}
        @titulo = 'RELATÓRIO DE FATURAMENTO'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def contas_a_pagar_visao_contabil
    params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @parcelas = ParcelaPagamentoDeConta.visao_contabil(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :count
        render :update do |page|
          excecao = '* Insira a data para a pesquisa' if params[:busca][:data].blank?
          if !excecao.blank?
            page.alert excecao
          else
            if @parcelas == 0
              page.alert 'Nenhum registro foi encontrado!'
            else
              page.new_window_to contas_a_pagar_visao_contabil_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
      format.print do
        carregar_contratos.call :all
        @titulo = 'RELATÓRIO CONTAS A PAGAR - FORNECEDORES'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_contratos.call :all
        @titulo = 'RELATÓRIO CONTAS A PAGAR - FORNECEDORES'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end
  
  def clientes_inadimplentes_liberados
    @pessoas = Pessoa.pesquisa_clientes_liberados(session[:unidade_id])
    respond_to do |format|
      format.js do
        render :update do |page|
          if @pessoas.length == 0
            page.alert('Não foram encontrados registros com estes parâmetros.')
          else
            page.new_window_to clientes_inadimplentes_liberados_relatorios_path(:format => 'print')
          end
        end
      end
      format.print do
        @titulo = 'CLIENTES INADIMPLENTES LIBERADOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        @titulo = 'CLIENTES INADIMPLENTES LIBERADOS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def contratos_vendidos

 params[:busca] ||= {}
    carregar_contratos = lambda do |contar_ou_retornar|
      @recebimentos = RecebimentoDeConta.pesquisa_contratos_vendidos(contar_ou_retornar, session[:unidade_id], params[:busca])
    end
    respond_to do |format|
      format.html
      format.js do
        carregar_contratos.call :count
        render :update do |page|
          excecao = '* Preencha o período' if params[:busca][:periodo_min].blank? || params[:busca][:periodo_max].blank?
          if !excecao.blank?
            page.alert excecao
          else
            if @parcelas == 0
              page.alert 'Nenhum registro foi encontrado!'
            else
              page.new_window_to contratos_vendidos_relatorios_path(:format => params[:tipo], :busca => params[:busca])
            end
          end
        end
      end
      format.print do
        carregar_contratos.call :all
        @titulo = 'RELATÓRIO VENDAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
      end
      format.xls do
        carregar_contratos.call :all
        @titulo = 'RELATÓRIO VENDAS'
        Audit.criar_audit(current_usuario, @titulo, session[:unidade_id], params[:format])
        render :layout => 'relatorio_horizontal'
      end
    end

























  end

end
