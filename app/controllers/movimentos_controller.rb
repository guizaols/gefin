class MovimentosController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDosMovimentos,
    'any' => Perfil::Movimentos,
    ['exportar_para_zeus'] => Perfil::RealizarExportacaoZeus,
    ['libera_movimento_fora_do_prazo'] => Perfil::LiberarContratoPeloDrMovimento,
    ['lancar_estornos_de_movimentos'] => Perfil::LancarEstornoMovimentos
  }
  
  before_filter :so_pode_alterar_movimentos_desta_unidade, :except => [:show]

  def index
    conditions = ["data_lancamento = ?", params['data_lancamento'].to_date.strftime("%Y-%m-%d")] unless params['data_lancamento'].blank? rescue nil
    @movimentos = (Movimento.find_all_by_provisao_and_unidade_id Movimento::SIMPLES, session[:unidade_id], :conditions => conditions, :order => 'data_lancamento DESC').paginate :page=>params[:page], :per_page=>50
  end

  def show
    @movimento = Movimento.find_by_id_and_unidade_id(params[:id], session[:unidade_id]) 
    redirect_to(movimentos_path) unless @movimento
  end

  def new
    @movimento = Movimento.new
  end

  def create
    @movimento = Movimento.new(params[:movimento])
    if Movimento.lanca_contabilidade(session[:ano], @movimento.prepara_lancamento_simples, session[:unidade_id])
      HistoricoOperacao.cria_follow_up("Criação de Movimento", current_usuario, nil, nil, nil, @movimento.valor_total, @movimento)
      flash[:notice] = 'Movimento criado com sucesso.'
      redirect_to movimentos_path
    else
      render :action => 'new'
    end
  end

  def edit
    @movimento = Movimento.find(params[:id])
  end

  def update
    @movimento = Movimento.find(params[:id])
    if @movimento.faz_update_de_movimento(session[:ano], params[:movimento], session[:unidade_id])
      HistoricoOperacao.cria_follow_up("Edição de Movimento", current_usuario, nil, nil, nil, @movimento.valor_total, @movimento)
      flash[:notice] = 'Movimento alterado com sucesso.'
      redirect_to movimentos_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @movimento = Movimento.find(params[:id])
    if @movimento.destroy
      flash[:notice] = 'Movimento excluído com sucesso.'
    else
      flash[:notice] = @movimento.errors.full_messages.collect{|item| "* #{item}"}.join("\n")
    end
    redirect_to(movimentos_url)
  end

  def exportar_para_zeus
    params[:busca] ||= {:data => Date.today.to_s_br}
    tipo = "text/plain"
    extensao = "txt"
    respond_to do |format|
      format.html do
        if params[:redirecionamento] == 'ARQ'
          @movimentos = ItensMovimento.exportacao_zeus(:all, session[:unidade_id], params[:busca])
          if @movimentos.first
            unidade = Unidade.find(session[:unidade_id]).sigla
            data = params[:busca][:data].gsub!("/", "")
            send_data(@movimentos.last, :type => tipo, :filename => "#{unidade}#{data}.#{extensao}")
          else
            flash.now[:notice] = @movimentos.last
          end
        end
      end
      format.js do
        @movimentos = ItensMovimento.exportacao_zeus(:count, session[:unidade_id], params[:busca])
        render :update do |page|
          if @movimentos == 0
            page.alert("Não foram encontrados registros com estes parâmetros.")
          else
            page.new_window_to :format => 'html', :busca => params[:busca], :redirecionamento => 'ARQ'
          end
        end
      end
    end
  end

  # RF12
  def libera_movimento_fora_do_prazo
    @movimento = Movimento.find(params[:id])
    @movimento.liberacao_dr_faixa_de_dias_permitido = true
    if @movimento.save
      flash[:notice] = "Movimento liberado pelo DR."
    else
      flash[:notice] = "Não foi possível liberar este movimento."
    end
    redirect_to movimentos_path
  end

  def lancar_estornos_de_movimentos
    params[:busca] ||= {}
    unless params[:busca].blank?
      unless params[:busca][:controle].blank?
        @movimentos = Movimento.procurar_movimentos_para_estorno(params[:busca][:controle])
        render :update do |page|
          if @movimentos.blank?
            page.replace_html 'resultados_pesquisa_estorno', :text => "<div id=\"resultados_pesquisa_estorno\"></div>"
            page.alert "Não foram encontrados registros com estes parâmetros."
          else
            page.replace_html 'resultados_pesquisa_estorno', :partial => 'resultados_pesquisa_estorno', :object => @movimentos
          end
        end
      else
        render :update do |page|
          mensagem = 'Insira um Número de Controle para a pesquisa' if params[:busca][:controle].blank?
          page.alert mensagem
        end
      end
    end
  end
  
  def gravar_lancamento_de_estorno
    retorno = Movimento.gravar_lancamento_de_estorno(current_usuario, params[:movimento_id], session[:unidade_id], params[:data_estorno], params[:justificativa], params[:historico])
    render :update do |page|
      if retorno.first
        page.alert retorno.last
        page.reload
      else
        page.alert retorno.last
      end
    end
  end
  
  private

  def so_pode_alterar_movimentos_desta_unidade
    if params[:id]
      @movimento = Movimento.find params[:id]
      unless @movimento.unidade_id == session[:unidade_id].to_i
        flash[:notice] = 'Esse movimento pertence a outra unidade.'
        redirect_to login_path
      end
    end
  end

end
