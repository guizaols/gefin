class CompromissosController < ApplicationController

  PERMISSOES = {
    ['index'] => Perfil::ControleDeCompromissos,
    CUD => Perfil::ManipularControleDeCompromissos
  }

  def index
    params[:busca] ||= { :data_min => Date.today.to_s_br, :data_max => Date.today.to_s_br }
    @compromissos = Compromisso.find_all_by_unidade_id_and_data_agendada(session[:unidade_id],Date.today, :order => 'data_agendada DESC')
    @compromisso_para_busca = Compromisso.new
  end

  def new
    if params[:tipo]=='1'
      params[:busca] ||= {}
      params[:compromisso] ||= {}
      @compromisso = Compromisso.new :data_agendada => params[:compromisso][:data_agendada] ||= Date.today, :descricao => params[:compromisso][:descricao]
      @combo_para_situacao = RecebimentoDeConta::OPCOES_SITUACAO_PARA_COMBO
      @contratos = RecebimentoDeConta.pesquisa_simples session[:unidade_id], params[:busca]
    else
      if params[:conta_id]
        @compromisso = Compromisso.new :data_agendada => Date.today, :conta_id => params[:conta_id]
      else
        redirect_to compromissos_path
      end
    end
  end

  def create
    if params[:commit]=='Pesquisar'
      params[:tipo] = '1'
      if params[:compromisso]
        descricao = params[:compromisso][:descricao] if params[:compromisso]
        data_agendada = params[:compromisso][:data_agendada]
      else
        descricao = ""
        data_agendada = Date.today
      end
      @compromisso = Compromisso.new :data_agendada => data_agendada, :descricao => descricao, :current_usuario => current_usuario
      if params[:tipo]=='1'
        @combo_para_situacao = RecebimentoDeConta::OPCOES_SITUACAO_PARA_COMBO
        @contratos = RecebimentoDeConta.pesquisa_simples session[:unidade_id], params[:busca]
        @tipo = 1
      end
      render :action => 'new'
    else
      params[:compromisso][:conta_id] ||= {}
      params[:compromisso][:current_usuario] = current_usuario
      @compromisso = Compromisso.new(params[:compromisso])
      unless params[:contas].blank?
        @compromisso.conta_id = params[:contas][:ids].first
      end
      @compromisso.unidade_id = session[:unidade_id]
      @compromisso.conta_type = 'RecebimentoDeConta'
      if @compromisso.save
        flash[:notice] = 'Compromisso agendado com sucesso!'
        if params[:contas]
          redirect_to(compromissos_path)
        else
          redirect_to(recebimento_de_conta_path(@compromisso.conta_id))
        end
      else
        flash.now[:notice] = 'Não foi possível salvar o compromisso!'
        if params[:tipo]=='1'
          @combo_para_situacao = RecebimentoDeConta::OPCOES_SITUACAO_PARA_COMBO
          params[:busca] ||= {}
          if params[:busca].has_key?(:nome_cliente) && params[:busca][:nome_cliente].empty?
            params[:busca][:cliente_id] = ''
          end
          @contratos = RecebimentoDeConta.pesquisa_simples session[:unidade_id], params[:busca]
          @tipo = 1
        end
        render :action => 'new'
      end
    end
  end

  def edit
    params[:busca] ||= {}
    params[:tipo] = '1'
    @compromisso = Compromisso.find params[:id]
    @combo_para_situacao = RecebimentoDeConta::OPCOES_SITUACAO_PARA_COMBO
    @contratos = RecebimentoDeConta.pesquisa_simples session[:unidade_id], params[:busca]
  end

  def update
    if params[:commit]=='Pesquisar'
      edit
      render :action => 'edit'
    else
      params[:compromisso][:conta_id] ||= {}
      unless params[:contas].blank?
        params[:compromisso][:conta_id] = params[:contas][:ids].first
      end
      @compromisso = Compromisso.find params[:id]
      if @compromisso.update_attributes(params[:compromisso])
        flash[:notice] = 'Compromisso agendado com sucesso!'
        if params[:contas]
          redirect_to(compromissos_path)
        else
          redirect_to(recebimento_de_conta_path(@compromisso.conta_id))
        end
      else
        flash.now[:notice] = 'Não foi possível salvar o compromisso!'
        if params[:tipo]=='1'
          @combo_para_situacao = RecebimentoDeConta::OPCOES_SITUACAO_PARA_COMBO
          params[:busca] ||= {}
          @contratos = RecebimentoDeConta.pesquisa_simples session[:unidade_id], params[:busca]
          @tipo = 1
        end
        render :action => 'edit'
      end
    end
  end

  def destroy
    @compromisso = Compromisso.find params[:id]
    @compromisso.destroy
    redirect_to(compromissos_path)
  end

  def auto_complete_for_contas_a_receber
    find_options = {
      :conditions => [ "(unidade_id = ? AND LOWER(numero_de_controle) LIKE ?)", session[:unidade_id], params[:argumento].formatar_para_like],
      :limit => 20, :select => 'id, numero_de_controle' }
    @items = RecebimentoDeConta.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.numero_de_controle}</li>"}.join + '</ul>'
  end

  def update_tabela_compromissos
    params[:busca] ||= {}
    params[:busca][:data_min] = Date.today.to_s_br unless (params[:busca][:data_min].to_date rescue false)
    params[:busca][:data_max] = Date.today.to_s_br unless (params[:busca][:data_max].to_date rescue false)
    params[:compromisso] ||= {}
    params[:compromisso][:conta_id] = '' if params[:compromisso][:nome_conta].blank?
    #@compromissos = Compromisso.find_all_by_unidade_id_and_data_agendada(session[:unidade_id],Date.today, :order => 'conta_id DESC')
    if params[:compromisso][:conta_id].blank?
      condicoes = ["unidade_id=? AND data_agendada>=? AND data_agendada<=?",session[:unidade_id],params[:busca][:data_min].to_date,params[:busca][:data_max].to_date]
    else
      condicoes = ["unidade_id=? AND data_agendada>=? AND data_agendada<=? AND conta_id=?",session[:unidade_id],params[:busca][:data_min].to_date,params[:busca][:data_max].to_date,params[:compromisso][:conta_id]]
    end
    @compromissos = Compromisso.find :all, :conditions => condicoes
    case params[:ordem].to_i
    when 0
        @compromissos = @compromissos.sort_by { |compromisso| compromisso.conta.pessoa.nome }
    when 1
        @compromissos = @compromissos.sort_by { |compromisso| compromisso.data_agendada }
    end
    render :update do |page|
      page.replace_html('tabela_lista_de_compromissos',:partial => 'lista_de_compromissos')
    end
  end
end
