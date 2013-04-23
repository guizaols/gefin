class RecebimentoDeContasController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDeRecebimentoDeContas,
    'any' => Perfil::RecebimentoDeContas,
    ['gerar_parcelas', 'atualiza_valores_das_parcelas', 'situacao_spc', 'renegociar','destroy',
      'carregar_modal_parcela', 'inserindo_nova_parcela', 'efetuar_renegociacao', 'abdicar',
      'efetuar_abdicacao', 'altera_situacao_fiemt', 'estornar_contrato', 'iniciar_servico',
      'cancelamento_contrato', 'efetua_cancelamento','enviadas_para_dr'
    ] => Perfil::ManipularDadosDeRecebimentoDeContas,
    ['parar_servico'] => Perfil::PararServico,
    ['desbloquear_inadimplente'] => Perfil::LiberarNovoContratoParaInadimplente,
    ['libera_recebimento_de_conta_fora_do_prazo'] => Perfil::LiberarContratoPeloDrRecebimentoDeConta,
    ['analise_contratos', 'calcular_proporcao','listagem_agendamentos_contabilizacao'] => Perfil::AnaliseContratos,
    ['listagem_agendamentos_contabilizacao','cancelar_contabilizacao']=>Perfil::CancelarAgendamento
  }

  before_filter :nao_pode_alterar_se_situacao_fiemt_esta_inativo, :except => [:index, :show, :estornar_contrato]
  before_filter :so_pode_alterar_contas_desta_unidade
  before_filter :verificando_situacao_contrato, :only => [:gerar_parcelas, :situacao_spc]

  def index
    params[:busca] ||= {}
    @combo_para_situacao = Parcela::OPCOES_SITUACAO_PARA_COMBO
    if params[:busca][:ordem] != 'situacao'
      @recebimento_de_contas = RecebimentoDeConta.pesquisa_simples(session[:unidade_id], params[:busca], params[:page])
    else
      @recebimento_de_contas = ParcelaRecebimentoDeConta.pesquisa_simples_para_situacoes(session[:unidade_id], params[:busca], params[:page])
    end
  end
  
  def listagem_agendamentos_contabilizacao
    # @agendamentos = AgendamentoCalculoContabilizacaoReceitas.find(:all, :conditions => ["status = ? AND unidade_id  = ?", AgendamentoCalculoContabilizacaoReceitas::ACTIVE,session[:unidade_id]])
    @agendamentos = AgendamentoCalculoContabilizacaoReceitas.find(:all, :conditions => ["unidade_id  = ?",session[:unidade_id]])
  end
  
  def cancelar_contabilizacao
    @agendamento = AgendamentoCalculoContabilizacaoReceitas.find_by_id params[:agendamento_id]
    if @agendamento.status == AgendamentoCalculoContabilizacaoReceitas::ACTIVE
      @agendamento.destroy
    end
    redirect_to listagem_agendamentos_contabilizacao_recebimento_de_contas_path
    
  end

  def show
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @mostrar_todas = true if params[:todas] == 'true'
  end

  def new
    @recebimento_de_conta = RecebimentoDeConta.new
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    @recebimento_de_conta.unidade_id = session[:unidade_id]
    @recebimento_de_conta.unidade_organizacional_id = Unidade.find_by_id(session[:unidade_id]).unidade_organizacional.id rescue nil
  end

  def edit
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    if @recebimento_de_conta.servico_iniciado?
      flash[:notice] = 'Não é permitido alterar o contrato após início do serviço.'
      redirect_to recebimento_de_conta_path(@recebimento_de_conta.id)
    end
  end

  def create
    @recebimento_de_conta = RecebimentoDeConta.new(params[:recebimento_de_conta])
    @recebimento_de_conta.unidade_id = session[:unidade_id]
    @recebimento_de_conta.ano = session[:ano]
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    @recebimento_de_conta.usuario_corrente = current_usuario
    #@recebimento_de_conta.unidade_organizacional_id = @recebimento_de_conta.unidade.unidade_organizacional.id unless @recebimento_de_conta.unidade.unidade_organizacional.id.blank?
    @recebimento_de_conta.lancando_inicialmente = true if @recebimento_de_conta.provisao == RecebimentoDeConta::SIM
    
    if @recebimento_de_conta.save
      @recebimento_de_conta.valor_original = @recebimento_de_conta.valor_do_documento
      @recebimento_de_conta.save
      
      #@recebimento_de_conta.gerar_parcelas(session[:ano])
      
      retorno_parcelas = false
      while !retorno_parcelas
        retorno_parcelas = @recebimento_de_conta.gerar_parcelas(session[:ano]).first
      end
      
      
      
      @recebimento_de_conta.efetua_lancamento! if @recebimento_de_conta.provisao == RecebimentoDeConta::SIM
      @recebimento_de_conta.lancando_inicialmente = false if @recebimento_de_conta.provisao == RecebimentoDeConta::SIM
      flash[:notice] = 'Conta a receber lançada com sucesso!'
      redirect_to recebimento_de_conta_path(@recebimento_de_conta.id)
    else
      #@recebimento_de_conta.unidade_organizacional_id = Unidade.find_by_id(session[:unidade_id]).unidade_organizacional.id rescue nil
      render :action => "new"
    end
  end

  def update
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    if @recebimento_de_conta.servico_iniciado?
      flash[:notice] = 'Não é permitido alterar o contrato após início do serviço.'
      redirect_to recebimento_de_conta_path(@recebimento_de_conta.id)
    else
      recebimento_original = RecebimentoDeConta.find(params[:id])
      @recebimento_de_conta.unidade_id = session[:unidade_id]
      @recebimento_de_conta.ano = session[:ano]
      @recebimento_de_conta.ano_contabil_atual = session[:ano]
      @recebimento_de_conta.usuario_corrente = current_usuario
      @recebimento_de_conta.lancando_inicialmente = true if @recebimento_de_conta.provisao == RecebimentoDeConta::SIM

      if @recebimento_de_conta.update_attributes(params[:recebimento_de_conta])
        @recebimento_de_conta.criar_follow_up_update(recebimento_original, current_usuario)
        if @recebimento_de_conta.provisao == RecebimentoDeConta::SIM
          @recebimento_de_conta.destroy_lancamento!
          @recebimento_de_conta.efetua_lancamento!
          @recebimento_de_conta.lancando_inicialmente = false
        end
        flash[:notice] = 'Conta a receber atualizada com sucesso!'
        redirect_to recebimento_de_conta_path(@recebimento_de_conta.id)
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    if @recebimento_de_conta.destroy_contrato
      flash[:notice] = 'Conta a receber excluída com sucesso!'
      redirect_to(recebimento_de_contas_url)
    else
      flash[:notice] = 'Não foi possível excluir o contrato!'
      redirect_to(recebimento_de_contas_url)
    end
  end

  def calcula_data_final
    @recebimento_de_conta = RecebimentoDeConta.new :data_inicio => params[:data_inicio], :vigencia => params[:vigencia]
    @recebimento_de_conta.calcula_data_final
    render :update do |page|
      page[:recebimento_de_conta_data_final].value = @recebimento_de_conta.data_final
    end
  end
  
  def situacao_spc
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    if @recebimento_de_conta.pessoa.spc == true
      @recebimento_de_conta.pessoa.update_attributes(:spc => false)
    else
      @recebimento_de_conta.pessoa.update_attributes(:spc => true)
    end
    render :update do |page|
      page.replace('situacao_spc', :partial => 'situacao_spc', :object => @recebimento_de_contas)
    end
  end

  def gerar_parcelas
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    retorno = @recebimento_de_conta.gerar_parcelas(session[:ano])
    flash[:notice] = retorno.last
    redirect_to recebimento_de_conta_path(@recebimento_de_conta.id)
  end
  
  def carrega_parcelas
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
  end
  
  def atualiza_valores_das_parcelas
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    resultado_operacao = @recebimento_de_conta.atualizar_valor_das_parcelas(session[:ano], params[:parcela], current_usuario)
    if resultado_operacao == true
      flash[:notice] = "Dados alterados com sucesso!"
      redirect_to recebimento_de_conta_path(@recebimento_de_conta.id)
    else
      flash.now[:notice] = resultado_operacao if resultado_operacao.is_a?String
      render :action=>"carrega_parcelas"
    end
  end
  
  def carregar_modal_parcela
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|    
      page << "Modalbox.show($('formulario_de_nova_parcela'), {title: 'Inserir nova parcela', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_nova_parcela', :partial => 'parcelas/new'}} });"
    end
  end

  def ordena_parcelas
    @conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      if params[:ordem] == "numero"
        page << "$('ordem_numero').removeClassName('desativado');"
        page << "$('ordem_vencimento').removeClassName('ativado');"
        page << "$('ordem_numero').addClassName('ativado');"
        page << "$('ordem_vencimento').addClassName('desativado');"
        page.replace_html('tabela_parcela', :partial => 'parcelas/tabela_index', :locals => {:parcelas => @conta.parcelas_ordenadas_numero, :conta => @conta})
      else
        page << "$('ordem_numero').removeClassName('ativado');"
        page << "$('ordem_vencimento').removeClassName('desativado');"
        page << "$('ordem_numero').addClassName('desativado');"
        page << "$('ordem_vencimento').addClassName('ativado');"
        page.replace_html('tabela_parcela', :partial => 'parcelas/tabela_index', :locals => {:parcelas => @conta.parcelas_ordenadas_vencimento, :conta => @conta})
      end
    end
  end

  def mostrar_form_para_insercao_de_justificativa
    @conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      if @conta.provisao == RecebimentoDeConta::SIM
        if [Parcela::PENDENTE, Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::DESCONTO_EM_FOLHA,
            Parcela::JURIDICO, Parcela::BAIXA_DO_CONSELHO, Parcela::ENVIADO_AO_DR].include?(@parcela.situacao)
          page.replace_html('form_para_inserir_justificativa', :partial => "form_justificativa")
          page << "Modalbox.show($('form_para_inserir_justificativa'), {title: 'Cancelamento de Parcela', width:500})"
        else
          page.alert('A parcela não pôde ser cancelada')
        end
      else
        page.replace_html('form_para_inserir_justificativa', :partial => "form_justificativa")
        page << "Modalbox.show($('form_para_inserir_justificativa'), {title: 'Cancelamento de Parcela', width:500})"
      end
    end
  end

  def inserindo_nova_parcela
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    retorno = @recebimento_de_conta.inserir_nova_parcela(params[:parcela])
    render :update do |page|
      if retorno.first
        page.alert retorno.last
        page << 'Modalbox.hide()'
        page << 'window.location.reload()'
      else
        page.alert retorno.last
      end
    end
  end

  def abdicar
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      #if @recebimento_de_conta.servico_nao_iniciado?
      #  page.alert 'Não é permitido cancelar este contrato, pois o serviço não foi iniciado.'
      #else
      page << "Modalbox.show($('formulario_de_abdicacao'), {title: 'Cancelar Contrato', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_abdicacao', :partial => 'abdicacao'}} });"
      #end
    end
  end

  def efetuar_abdicacao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      #if @recebimento_de_conta.servico_nao_iniciado?
      #  page.alert 'Não é permitido cancelar este contrato, pois o serviço não foi iniciado.'
      #else
      if @recebimento_de_conta.situacao == RecebimentoDeConta::Normal
        retorno = @recebimento_de_conta.abdicar_contrato(params[:data_abdicacao], @recebimento_de_conta.usuario_corrente, params[:justificativa])
        if retorno == true
          page.alert 'O contrato ' "#{@recebimento_de_conta.numero_de_controle}" ' foi cancelado!'
          page << 'Modalbox.hide()'
          page << 'window.location.reload()'
        else
          page.alert retorno
        end
      else
        page.alert 'A situação do contrato não está Normal.'
        page << 'Modalbox.hide()'
      end
    end
    #end
  end

  def evadir
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      if @recebimento_de_conta.servico_nao_iniciado?
        page.alert 'Não é permitido evadir este contrato, pois o serviço não foi iniciado.'
      elsif !@recebimento_de_conta.contrato_evadido?
        page << "Modalbox.show($('formulario_de_evasao'), {title: 'Evadir Contrato', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_evasao', :partial => 'evasao'}} });"
      else
        page.alert 'Este contrato já foi evadido.'
      end
    end
  end

  def efetuar_evasao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      if @recebimento_de_conta.servico_nao_iniciado?
        page.alert 'Não é permitido evadir este contrato, pois o serviço não foi iniciado.'
      elsif !@recebimento_de_conta.contrato_evadido?
        if [RecebimentoDeConta::Normal, RecebimentoDeConta::Juridico, RecebimentoDeConta::Renegociado, RecebimentoDeConta::Permuta, RecebimentoDeConta::Baixa_do_conselho, RecebimentoDeConta::Desconto_em_folha, RecebimentoDeConta::Enviado_ao_DR, RecebimentoDeConta::Devedores_Duvidosos_Ativos].include?(@recebimento_de_conta.situacao)
          retorno = @recebimento_de_conta.evadir_contrato(params[:data_evasao], @recebimento_de_conta.usuario_corrente, params[:justificativa])
          if retorno == true
            page.alert 'O contrato ' "#{@recebimento_de_conta.numero_de_controle}" ' foi evadido!'
            page << 'Modalbox.hide()'
            page << 'window.location.reload()'
          else
            page.alert retorno
          end
        else
          page.alert 'A situação do contrato não está Normal.'
          page << 'Modalbox.hide()'
        end
      else
        page.alert 'Este contrato já foi evadido.'
      end
    end
  end

  def resumo
    @recebimento_de_conta = RecebimentoDeConta.find params[:id]
    respond_to do |format|
      format.js do
        render :update do |page|
          page.new_window_to :url => resumo_recebimento_de_conta_path, :id => params[:id], :format => 'pdf'
        end
      end
      format.pdf do
        render :layout => 'relatorio_horizontal_a3'
        @titulo = 'CONTRATO DE SERVIÇO'
      end
    end
  end

  def altera_situacao_fiemt
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      if @recebimento_de_conta.servico_nao_iniciado?
        page.alert 'Não é permitido alterar a situação deste contrato, pois o serviço não foi iniciado.'
        page.reload
        #      elsif params[:argumento].to_i == RecebimentoDeConta::Inativo
        #        if @recebimento_de_conta.cancelar_contrato(current_usuario)
        #          page.replace_html 'situacao', :text => "<span id=\"situacao\">#{@recebimento_de_conta.situacoes}</span>"
        #          page.alert "Situação FIEMT atualizado para #{@recebimento_de_conta.situacao_fiemt_verbose.downcase}!"
        #          page.reload
        #        end
      else
        @recebimento_de_conta.situacao_fiemt = params[:argumento]
				if @recebimento_de_conta.save
          @recebimento_de_conta.atribui_situacao_parcela(params[:argumento].to_i)
          page.alert "Situação FIEMT atualizado para #{@recebimento_de_conta.situacao_fiemt_verbose.downcase}!"
          page.reload
        else
          page[:select_situacao].hide; page[:submit_situacao].show
          page.alert "A situação FIEMT não pode ser modificada!"
        end
      end
    end
  end

  #  def pesquisa_para_envio
  #    respond_to do |format|
  #      format.html
  #      format.js do
  #        @recebimento_de_contas = RecebimentoDeConta.pesquisa_por_datas_e_parcelas_atrasadas(session[:unidade_id].to_i, params[:busca])
  #        render :update do |page|
  #          page.replace 'resultado_pesquisa_envio', :partial => 'resultado_pesquisa_envio', :object => @recebimento_de_contas
  #        end
  #      end
  #    end
  #  end

  #  def envio_ao_dr_terceirizada
  #    respond_to do |format|
  #      format.js do
  #        render :update do |page|
  #          page << 'window.location.reload()'
  #          page.new_window_to :url => envio_ao_dr_terceirizada_recebimento_de_contas_path, :format => 'xls', :recebimento_de_contas => params[:recebimento_de_contas]
  #        end
  #      end
  #      format.xls do
  #        @recebimento_de_contas = RecebimentoDeConta.carrega_recebimentos_para_envio(current_usuario, session[:unidade_id].to_i, params[:recebimento_de_contas])
  #        if @recebimento_de_contas.length > 0
  #          render :layout => 'relatorio_horizontal'
  #        else
  #          flash[:notice] = 'Não existem contratos para serem enviados!'
  #          redirect_to pesquisa_para_envio_recebimento_de_contas_path
  #        end
  #      end
  #    end
  #  end

  #  def cancelar_contrato
  #    render :update do |page|
  #      if @recebimento_de_conta.servico_nao_iniciado?
  #        page.alert 'Não é permitido inativar este contrato, pois o serviço não foi iniciado.'
  #      else
  #        if @recebimento_de_conta.cancelar_contrato(current_usuario)
  #          page.alert "O contrato foi inativado com sucesso!"
  #        else
  #          page.alert "Não foi possível inativar este contrato!"
  #        end
  #        page.reload
  #      end
  #    end
  #  end

  def estornar_contrato
    render :update do |page|
      if @recebimento_de_conta.estornar_contrato(current_usuario)
        page.alert "O contrato foi estornado com sucesso!"
      else
        page.alert "Não foi possível estornar este contrato!"
      end
      page.reload
    end
  end

  def atualiza_valor_baixa_parcial
    @conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      @parcela.calcular_juros_e_multas!(params[:data])
      # page[:valor_liquido].value = @parcela.calcula_valor_total_da_parcela.to_f / 100
      page[:parcela_valor_da_multa_em_reais].value = (@parcela.valor_da_multa.to_f / 100).real.to_s
      page[:parcela_valor_dos_juros_em_reais].value = (@parcela.valor_dos_juros.to_f / 100).real.to_s
      page.call :valor_total
    end
  end

  def carrega_baixa_parcial
    @conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      page.show 'form_para_baixa_parcial'
      page.replace_html('form_para_baixa_parcial', :partial => "form_baixa_parcial", :locals => {:parcela => @parcela})
      page.visual_effect :highlight, 'form_para_baixa_parcial'
    end
  end

  # RF12
  def libera_recebimento_de_conta_fora_do_prazo
    @conta = RecebimentoDeConta.find(params[:id])
    @conta.liberacao_dr_faixa_de_dias_permitido = true
    @conta.ano_contabil_atual = session[:ano]
    if @conta.save
      HistoricoOperacao.cria_follow_up("Conta liberada para recebimento fora do prazo pelo DR.", current_usuario, @conta)
      flash[:notice] = 'Conta liberada pelo DR'
    else
      flash[:notice] = 'Não foi possível liberar a conta'
    end
    redirect_to recebimento_de_contas_path
  end

  def consulta_inadimplencia
    params[:busca] ||= { :data_min => Date.today.to_s_br, :data_max => Date.today.to_s_br }
  end

  def update_tabela_inadimplentes
    @inadimplentes = RecebimentoDeConta.pesquisa_clientes_inadimplentes :all, session[:unidade_id], params[:busca]
    render :update do |page|
      page.replace_html('tabela_lista_de_inadimplentes', :partial => 'lista_de_inadimplentes')
    end
  end

  def auto_complete_for_clientes
    find_options = {
      :conditions => [ "(unidade_id = ?)", session[:unidade_id]], :limit => 20 }
    @pessoas = Pessoa.find(:all, find_options)
    render :text =>'<ul>' + @pessoas.collect{|pessoa| "<li id=#{pessoa.id}>#{pessoa.nome}</li>"}.join + '</ul>'
  end

  def iniciar_servico
    @recebimento_de_conta = RecebimentoDeConta.find params[:id]
    render :update do |page|
      unless @recebimento_de_conta.servico_iniciado
        @recebimento_de_conta.servico_iniciado = true
        @recebimento_de_conta.servico_alguma_vez_iniciado = true
        @recebimento_de_conta.iniciando_servicos = true
        @recebimento_de_conta.ano_contabil_atual = session[:ano]
        if @recebimento_de_conta.save
          @recebimento_de_conta.iniciando_servicos = false
          page.alert("Serviço Iniciado!")
          HistoricoOperacao.cria_follow_up('O Serviço foi iniciado.', current_usuario, @recebimento_de_conta)
        else
          page.alert("Serviço não pode ser Iniciado! \n #{@recebimento_de_conta.errors.full_messages.collect{|item| "* #{item}"}.join("\n")}")
        end
        if params[:busca].blank?
          page.reload
        else
          page.redirect_to analise_contratos_recebimento_de_contas_path(:busca => params[:busca], :mostrar => true)
        end
      else
        page.alert("O Serviço já foi Iniciado!")
      end
    end
  end

  def parar_servico
    @recebimento_de_conta = RecebimentoDeConta.find params[:id]
    render :update do |page|
      if @recebimento_de_conta.servico_iniciado
        if @recebimento_de_conta.provisao == RecebimentoDeConta::NAO || (@recebimento_de_conta.provisao == RecebimentoDeConta::SIM && !@recebimento_de_conta.contrato_ja_contabilizado?)
          @recebimento_de_conta.servico_iniciado = false
          @recebimento_de_conta.parando_servico = true
          @recebimento_de_conta.iniciando_servicos = true
          @recebimento_de_conta.ano_contabil_atual = session[:ano]
          if @recebimento_de_conta.save
            @recebimento_de_conta.iniciando_servicos = false
            page.alert('Serviço Parado!')
            HistoricoOperacao.cria_follow_up('O Serviço foi parado.', current_usuario, @recebimento_de_conta)
          else
            page.alert("Serviço não pode ser Parado! \n #{@recebimento_de_conta.errors.full_messages.collect{|item| "* #{item}"}.join("\n")}")
          end
        else
          page.alert('O Serviço não pode ser parado pois este contrato já teve receitas contabilizadas!')
        end
        page.reload
      else
        page.alert('O Serviço está Parado!')
      end
    end
  end

  def cancelamento_contrato
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      if @recebimento_de_conta.servico_iniciado? || !@recebimento_de_conta.servico_nunca_iniciado?
        page.alert 'Não é permitido cancelar este contrato, pois o serviço foi iniciado.'
      else
        page << "Modalbox.show($('formulario_de_cancelamento'), {title: '', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_cancelamento', :partial => 'cancelar_contrato'}} });"
      end
    end
  end

  def efetua_cancelamento
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      if @recebimento_de_conta.servico_iniciado? || !@recebimento_de_conta.servico_nunca_iniciado?
        page.alert 'Não é permitido cancelar este contrato, pois o serviço foi iniciado.'
      else
        if [RecebimentoDeConta::Normal, RecebimentoDeConta::Juridico, RecebimentoDeConta::Renegociado, RecebimentoDeConta::Permuta, RecebimentoDeConta::Baixa_do_conselho, RecebimentoDeConta::Desconto_em_folha, RecebimentoDeConta::Enviado_ao_DR, RecebimentoDeConta::Devedores_Duvidosos_Ativos].include?(@recebimento_de_conta.situacao)
          retorno = @recebimento_de_conta.realiza_cancelamento_de_contrato(params, @recebimento_de_conta.usuario_corrente)
          if retorno.first
            page.alert retorno.last
            page.reload
          else
            page.alert retorno.last
          end
        else
          page.alert "A atual situação (#{@recebimento_de_conta.situacao_verbose.upcase}) do contrato não permite que ele seja cancelado."
          page << 'Modalbox.hide()'
        end
      end
    end
  end

  def parcelas_operacoes
    params["data_inicial"] ||= Date.today
    params["data_final"] ||= Date.today
  end

  def enviadas_para_dr
    
    respond_to do |format|
      format.js do
        render :update do |page|
          if !params["data_inicial"].blank? && !params["data_final"].blank?
            page.new_window_to(:url => enviadas_para_dr_recebimento_de_contas_path, :format => 'xls', :data_inicial=> params[:data_inicial],:data_final=>params[:data_final])
          else
            page.alert "Favor preencher os campos Data Inicial e Data Final!"
          end
        end
      end
      format.html do 
        params["data_inicial"] ||= Date.today
        params["data_final"] ||= Date.today
      end
      format.xls do
        @parcelas_para_excel = []
         params[:data_inicial]
        ParcelaRecebimentoDeConta.enviadas_para_dr(session[:unidade_id],params[:data_inicial],params[:data_final]).each do |p|
          @parcelas_para_excel << p
        end
        render :layout => 'relatorio_horizontal'
      end
    end
  end

  def efetua_parcelas_operacoes
    begin
      params["data_inicial"] = params["data_inicial"]
      params["data_final"] = params["data_final"]
      @parcelas_para_excel = []

      if params[:operacao].to_i == 1
        parcelas = params[:parcelas] || []
        #        parcelas.each do |parcela|
        #          parcela = Parcela.find_by_id(parcela)
        retorno = Parcela.enviar_ao_dr(current_usuario, parcelas)
        #        end

        pesquisa = ParcelaRecebimentoDeConta.pesquisa_para_envio_dr(session[:unidade_id], params)
        @parcelas = pesquisa.collect{|parc| parc if parc.dias_em_atraso > 15}.compact
        @parcelas = @parcelas.group_by{|parcela| parcela.conta}

        respond_to do |format|
          format.js do
            render :update do |page|
              if retorno.first
                page.alert retorno.last
                page.new_window_to(:url => efetua_parcelas_operacoes_recebimento_de_contas_path, :format => 'xls', :parcelas_para_excel => parcelas, :id => Parcela.find(parcelas.first).conta.id, :operacao => 1)
                page.replace 'pesquisa_para_envio_parcelas_dr', :partial => 'pesquisa_para_envio_parcelas_dr', :object => @parcelas
              else
                page.alert retorno.last
              end
            end
          end
          format.html
          format.xls do
            params[:parcelas_para_excel].each do |parc_id|
              obj_parcela = Parcela.find_by_id(parc_id)
              @parcelas_para_excel << obj_parcela
            end
            render :layout => 'relatorio_horizontal'
          end
        end
      elsif params[:operacao].to_i == 2
        pesquisa = ParcelaRecebimentoDeConta.pesquisa_para_envio_dr(session[:unidade_id], params)
        @parcelas = pesquisa.collect{|parc| parc if parc.dias_em_atraso > 15}.compact
        parcelas_ids = @parcelas.collect(&:id)
        @parcelas = @parcelas.group_by{|parcela| parcela.conta}

        errors = {}
        parcelas = params[:parcelas] || []
        parcelas.each_with_index do |parcela, index|
          parcela = Parcela.find_by_id(parcela)
          if parcela
            parcela.situacao = Parcela::DEVEDORES_DUVIDOSOS_ATIVOS
            parcela.save
            errors[parcelas_ids.index(parcela.id)] = parcela.errors.full_messages unless parcela.errors.full_messages.blank?
          end
        end

        render :update do |page|
          if parcelas.length > 0
            if errors.length > 0
              page.alert "Não foi possível alterar as seguintes parcelas: #{errors.collect{|key, value| "Parcela #{key + 1}: #{value}" }.join("\n")}"
              page.replace 'pesquisa_para_envio_parcelas_dr', :partial => 'pesquisa_para_envio_parcelas_dr', :object => @parcelas
            else
              page.alert "Situação alterada com sucesso."
              page.replace 'pesquisa_para_envio_parcelas_dr', :partial => 'pesquisa_para_envio_parcelas_dr', :object => @parcelas
            end
          else
            page.alert "Selecione ao menos uma parcela para alterar a situação."
          end
        end
      else
        render :update do |page|
          page.alert 'Operação inválida'
        end
      end
    rescue Exception => e
      render :update do |page|
        page.alert e.message
        page.alert 'Dados inválidos'
      end
    end
  end

  def pesquisa_para_parcelas_operacoes
    begin
      params["data_inicial"] = params["data_inicial"]
      params["data_final"] = params["data_final"]

      pesquisa = ParcelaRecebimentoDeConta.pesquisa_para_envio_dr(session[:unidade_id], params)
      @parcelas = pesquisa.collect{|parc| parc if parc.dias_em_atraso > 15}.compact
      @parcelas = @parcelas.group_by{|parcela| parcela.conta}

      render :update do |page|
        if params["data_inicial"].blank? || params["data_final"].blank?
          page.alert 'Insira um período de datas para a pesquisa.'
        else
          page.replace 'pesquisa_para_envio_parcelas_dr', :partial => 'pesquisa_para_envio_parcelas_dr', :object => @parcelas
          page << "$('data_inicial').value = '#{params["data_inicial"]}';"
          page << "$('data_final').value = '#{params["data_final"]}';"
        end
      end
    rescue Exception => e
      render :update do |page|
        #page.alert e.message
        page.alert 'Dados inválidos'
      end
    end
  end

  def analise_contratos
    unless params[:busca].blank?
      @recebimento_de_contas = RecebimentoDeConta.pesquisa_para_analise_de_contrato(session[:unidade_id], params[:busca])
      if @recebimento_de_contas.blank?
        flash.now[:notice] = "Nenhum registro encontrado."
        @mostrar_form = [false]
      else
        @mostrar_form = [true]
        @recebimento_de_contas.each { |r| @mostrar_form = [false] unless r.servico_iniciado?}
      end
    else
      @recebimento_de_contas = []
      params[:busca] = {:data_min => Date.today.to_s_br, :data_max => Date.today.to_s_br, :ano => session[:ano]}
    end
    respond_to do |format|
      format.html
      format.print do
        @titulo = "Contratos não iniciados para Contabilização de Receitas"
        @recebimento_de_contas = RecebimentoDeConta.pesquisa_para_analise_de_contrato(session[:unidade_id], params[:busca], false)
      end
    end
  end
  
  def calcular_proporcao
    current_unidade = Unidade.find(session[:unidade_id])
    if current_unidade.contabilizacao_agendada == Unidade::SIM
      agendamento = AgendamentoCalculoContabilizacaoReceitas.new({
          :ano => params[:busca][:ano],
          :mes => params[:busca][:mes],
          :historico => params[:historico],
          :unidade_id => session[:unidade_id],
          :usuario_id => current_usuario.id
        })
      if agendamento.save
        flash.now[:notice] = 'O cálculo foi agendado com sucesso'
        AgendamentoCalculoContabilizacaoReceitas.thread_start
      else
        flash.now[:notice] = 'O cálculo não pôde ser agendado'
      end
      @recebimento_de_contas = RecebimentoDeConta.pesquisa_para_analise_de_contrato(session[:unidade_id], params[:busca], true)
    else
      @recebimento_de_contas = RecebimentoDeConta.pesquisa_para_analise_de_contrato(session[:unidade_id], params[:busca], true)
      @recebimento_de_contas_com_reajuste = RecebimentoDeConta.pesquisa_para_analise_de_contrato(session[:unidade_id], params[:busca], true)
      n_contratos = @recebimento_de_contas.length
      if n_contratos > 0
        retorno = RecebimentoDeConta.calcular_proporcao(@recebimento_de_contas, params[:historico], params[:busca])
        RecebimentoDeConta.contabilizacao_reajuste(@recebimento_de_contas_com_reajuste, params[:historico], params[:busca])
        if retorno.first
          contrato = retorno[2] > 1 ? 'contratos' : 'contrato'
          #parcela = retorno[1] > 1 ? 'parcelas' : 'parcela'
          flash.now[:notice] = "Contabilização de Receitas calculada com sucesso em #{retorno[2]} #{contrato}"
        else
          flash.now[:notice] = retorno.last
        end
      else
        flash.now[:notice] = 'Nenhum contrato encontrado.'
      end
    end
    #RecebimentoDeConta.calcular_proporcao(@recebimento_de_contas, params[:historico], params[:busca])
    @mostrar_form = [false, true]
    params[:mostrar] = true
    render :action => 'analise_contratos'
  end

  def pesquisar_servicos_para_inicio_em_lote
    params[:busca] ||= {}
    if params[:busca].blank?
      @inicio = true
      @contratos = []
    else
      numero_mes = Date::MONTHNAMES.collect{|monthname| (Date::MONTHNAMES.index(monthname)).to_s}
      if numero_mes.include?(params[:busca][:mes])
        @inicio = false
        @contratos = RecebimentoDeConta.pesquisar_contratos_para_inicio_em_lote(params[:busca], session[:unidade_id], session[:ano])
      else
        @contratos = []
        flash.now[:notice] = 'Insira um mês válido para a busca'
      end
    end
  end

  def iniciar_servicos_em_lote
    params[:contratos] ||= {}
    render :update do |page|
      retorno = RecebimentoDeConta.iniciar_servicos_em_lote(params[:contratos], session[:unidade_id], session[:ano])
      if retorno.first
        page.redirect_to pesquisar_servicos_para_inicio_em_lote_recebimento_de_contas_path
        page.alert retorno.last
      else
        page.alert retorno.last
      end
    end
  end

  def muda_situacao_para_perdas_do_recebimento_do_cliente
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    parcela_antiga = @parcela.situacao_verbose
    render :update do |page|
			if @parcela.situacao != Parcela::DEVEDORES_DUVIDOSOS_ATIVOS
				@parcela.situacao = Parcela::DEVEDORES_DUVIDOSOS_ATIVOS
			else
				if @parcela.data_da_baixa.blank?
					@parcela.situacao = Parcela::PENDENTE
				else
					@parcela.situacao = Parcela::QUITADA
				end
			end
			if @parcela.save
				#Perdas no Recebimento de Créditos - Clientes
				HistoricoOperacao.cria_follow_up("A situação da parcela #{@parcela.numero} foi alterada de #{parcela_antiga} para #{@parcela.situacao_verbose}", current_usuario, @recebimento_de_conta, nil, nil, nil)
        page.alert("A situação da parcela foi alterada para #{@parcela.situacao_verbose}")
				page << 'window.location.reload()'
			else
				page.alert("A parcela não pode ter sua situação alterada: \n #{@parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n")}")
				page << 'window.location.reload()'
			end
		end
  end

  def muda_situacao_para_baixa_do_conselho
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    parcela_antiga = @parcela.situacao_verbose
    render :update do |page|
			if @parcela.situacao != Parcela::BAIXA_DO_CONSELHO
				@parcela.situacao = Parcela::BAIXA_DO_CONSELHO
			else
				if @parcela.data_da_baixa.blank?
					@parcela.situacao = Parcela::PENDENTE
				else
					@parcela.situacao = Parcela::QUITADA
				end
			end
			if @parcela.save
				#Perdas no Recebimento de Créditos - Clientes
				HistoricoOperacao.cria_follow_up("A situação da parcela #{@parcela.numero} foi alterada de #{parcela_antiga} para #{@parcela.situacao_verbose}", current_usuario, @recebimento_de_conta, nil, nil, nil)
        page.alert("A situação da parcela foi alterada para #{@parcela.situacao_verbose}")
				page << 'window.location.reload()'
			else
				page.alert("A parcela não pode ter sua situação alterada: \n #{@parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n")}")
				page << 'window.location.reload()'
			end
		end
  end

  def reajustar
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      if @recebimento_de_conta.servico_nao_iniciado?
        page.alert 'Não é permitido reajustar este contrato, pois o serviço não foi iniciado.'
      else
        page << "Modalbox.show($('formulario_de_reajuste'), {title: 'Reajustar Contrato', width:500, afterLoad: function(){#{page.replace_html 'formulario_de_reajuste', :partial => 'reajustes/form'}} });"
      end
    end
  end

  def lancar_reajuste
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      if @recebimento_de_conta.servico_nao_iniciado?
        page.alert 'Não é permitido reajustar este contrato, pois o serviço não foi iniciado.'
      else
        excecoes = []
        excecoes << '* O campo valor do reajuste deve ser preenchido' if params[:valor_reajuste].blank?
        excecoes << '* O campo data do reajuste deve ser preenchido' if params[:data_reajuste].blank?
        unless excecoes.blank?
          page.alert excecoes.join("\n")
        else
          retorno = @recebimento_de_conta.reajustar_contrato(params)
          if retorno.first == true
            page.alert 'O contrato ' "#{@recebimento_de_conta.numero_de_controle}" ' foi reajustado com sucesso!'
            page << 'Modalbox.hide()'
            page << 'window.location.reload()'
          else
            page.alert retorno.last
          end
        end
      end
    end
  end

  def calcula_valor_reajuste
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    excecoes = []
    render :update do |page|
      excecoes << '* Preencha o valor da porcentagem' if params[:porcentagem].blank?
      excecoes << '* Preencha o campo data do reajuste' if params[:data_reajuste].blank?
      unless excecoes.blank?
        page.alert excecoes.join("\n")
      else
        parcelas = @recebimento_de_conta.parcelas.collect{|parcela| parcela.valor if parcela.situacao == Parcela::PENDENTE && parcela.data_vencimento.to_date >= Date.today && parcela.data_vencimento.to_date.between?(params[:data_reajuste].to_date, @recebimento_de_conta.data_final.to_date)}.compact.sum
        porcentagem = params[:porcentagem].real.to_f
        valor_reajuste = ((parcelas * porcentagem) / 100.0).round
        page[:valor_reajuste].value = format('%.2f', (valor_reajuste / 100.0)).real.to_s
      end
    end
  end

  def reverter_cancelamentos
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      page << "Modalbox.show($('formulario_de_reversao'), {title: 'Reversão de Cancelamento', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_reversao', :partial => 'reversao'}}});"
    end
  end

  def efetuar_reversao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      if @recebimento_de_conta.situacao_fiemt == RecebimentoDeConta::Cancelado
        retorno = @recebimento_de_conta.reverter_cancelamentos(@recebimento_de_conta.usuario_corrente, params[:justificativa], params[:data_reversao])
        if retorno.first
          page.alert 'O contrato ' "#{@recebimento_de_conta.numero_de_controle}" ' teve seu cancelamento revertido!'
          page << 'Modalbox.hide()'
          page << 'window.location.reload()'
        else
          page.alert retorno.last
        end
      else
        page.alert 'A situação do contrato não está Cancelada.'
        page << 'Modalbox.hide()'
      end
    end
  end

  def reverter_evasao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      page << "Modalbox.show($('formulario_de_reversao_evasao'), {title: 'Reversão de Evasão', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_reversao_evasao', :partial => 'reversao_evasao'}}});"
    end
  end

  def efetuar_reversao_evasao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      if @recebimento_de_conta.situacao_fiemt == RecebimentoDeConta::Evadido
        retorno = @recebimento_de_conta.reverter_evasao(@recebimento_de_conta.usuario_corrente, params[:justificativa], params[:data_reversao])
        if retorno.first
          page.alert 'O contrato ' "#{@recebimento_de_conta.numero_de_controle}" ' teve sua evasão revertida!'
          page << 'Modalbox.hide()'
          page << 'window.location.reload()'
        else
          page.alert retorno.last
        end
      else
        page.alert 'A situação do contrato não está Evadida.'
        page << 'Modalbox.hide()'
      end
    end
  end

  def form_para_justificativa_ctr_cancelado
    @conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      if ![RecebimentoDeConta::Cancelado, RecebimentoDeConta::Evadido].include?(@conta.situacao_verbose) &&
          ![Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(@parcela.situacao)
        page.replace_html('form_para_justificativa_ctr_canc', :partial => 'form_justificativa_ctr_canc')
        page << "Modalbox.show($('form_para_justificativa_ctr_canc'), {title: 'Cancelamento de Parcela de Contrato Cancelado/Evadido', width:500})"
      else
        page.alert('A parcela não pôde ser cancelada')
      end
    end
  end

  def importacao_de_contratos_via_xml
    if(params.has_key?(:arquivo))
      retorno = RecebimentoDeConta.importar_arquivo_xml(params[:arquivo], session[:unidade_id], current_usuario, session[:ano])
      flash.now[:notice] = retorno.last
    end
    render :action => 'importacao_de_contratos_via_xml'
  end

  def estornar_renegociacao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    render :update do |page|
      page << "Modalbox.show($('formulario_de_estorno_renegociacao'), {title: 'Estornar Renegociação Contrato', width:700, afterLoad: function(){#{page.replace_html 'formulario_de_estorno_renegociacao', :partial => 'estorno_renegociacao'}}});"
    end
  end

  def efetuar_estorno_renegociacao
    @recebimento_de_conta = RecebimentoDeConta.find(params[:id])
    @recebimento_de_conta.usuario_corrente = current_usuario
    @recebimento_de_conta.ano_contabil_atual = session[:ano]
    render :update do |page|
      retorno = @recebimento_de_conta.estornar_renegociacao(params[:data_estorno], @recebimento_de_conta.usuario_corrente, params[:justificativa])
      if retorno.first
        page.alert retorno.last
        page << 'Modalbox.hide()'
        page << 'window.location.reload()'
      else
        page.alert retorno.last
      end
    end
  end

  def carrega_baixa_parcial_dr
    @conta = RecebimentoDeConta.find(params[:id])
    @parcela = Parcela.find(params[:parcela_id])
    render :update do |page|
      page.show 'form_para_baixa_parcial_dr'
      page.replace_html('form_para_baixa_parcial_dr', :partial => 'form_baixa_parcial_dr', :locals => {:parcela => @parcela})
      page.visual_effect :highlight, 'form_para_baixa_parcial_dr'
    end
  end
  
  def download_layout
    send_file(RAILS_ROOT + '/public/arquivos/contratos.xml', :type => 'text/xml')
  end
  
  private

  def so_pode_alterar_contas_desta_unidade
    if params[:id]
      @recebimento_de_conta = RecebimentoDeConta.find params[:id]
      unless @recebimento_de_conta.unidade_id == session[:unidade_id].to_i
        flash[:notice] = 'Esse Recebimento de Conta pertence a outra unidade.'
        redirect_to login_path
      end
    end
  end

  def verificando_situacao_contrato
    verifica_se_contrato_esta_cancelado(params[:id])
  end

  def nao_pode_alterar_se_situacao_fiemt_esta_inativo
    if params[:id]
      @recebimento_de_conta = RecebimentoDeConta.find params[:id]
      if @recebimento_de_conta.situacao_fiemt == RecebimentoDeConta::Inativo &&
          @recebimento_de_conta.situacao == RecebimentoDeConta::Cancelado
        flash[:notice] = "Não é possível alterar dados de um contrato inativo."
        redirect_to recebimento_de_conta_path(params[:id])
      end
    end
  end


end

