class ServicosController < ApplicationController

  #  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_servico, :auto_complete_for_modalidade]

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDeServicos,
    'any' => Perfil::Servicos,
    ['prorrogar', 'gravar_dados_de_prorrogacao_de_contrato'] => Perfil::ProrrogarContrato
  }

  before_filter :so_pode_alterar_servicos_desta_unidade

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_servico, :auto_complete_for_modalidade]

  def index
    @servicos = Servico.find_all_by_unidade_id(session[:unidade_id], :order => 'descricao ASC')
  end

  def show
  end

  def new
    @servico = Servico.new
  end

  def edit
  end

  def create
    @servico = Servico.new(params[:servico])
    @servico.unidade_id = session[:unidade_id]
    
    if @servico.save
      flash[:notice] = 'Serviço criado com sucesso!'
      redirect_to servicos_path
    else
      render :action => "new"
    end
  end

  def update
    if @servico.update_attributes(params[:servico])
      flash[:notice] = 'Serviço atualizado com sucesso!'
      redirect_to servicos_path
    else
      render :action => "edit"
    end
  end

  def destroy
    if @servico.destroy
      flash[:notice] = 'Serviço excluído com sucesso!'
    else
      flash[:notice] = @servico.mensagem_de_erro
    end
    redirect_to(servicos_url)
  end

  def auto_complete_for_servico
    @servicos = Servico.all :conditions => ['(descricao LIKE ?) AND (unidade_id = ?)', params[:argumento].formatar_para_like, session[:unidade_id]]
    render :text =>'<ul>' + @servicos.collect{|s| "<li id=\"#{s.id}\">#{s.descricao}</li>"}.join + '</ul>'
  end
  
  def auto_complete_for_modalidade
    @modalidades = Servico.all(:conditions => ['(modalidade LIKE ?) AND (unidade_id = ?)', params[:argumento].formatar_para_like, session[:unidade_id]]).collect(&:modalidade).uniq
    render :text =>'<ul>' + @modalidades.collect{|s| "<li>#{s}</li>"}.join + '</ul>'
  end

  def prorrogar
    params[:busca] ||= {}
    unless params[:busca].blank?
      unless params[:busca][:nome_servico].blank? || params[:busca][:datas].blank?
        @recebimentos = RecebimentoDeConta.procurar_contratos_para_prorrogacao(params[:busca], session[:unidade_id])
        render :update do |page|
          if @recebimentos.blank?
            page.replace_html 'resultados_pesquisa_prorrogacao', :text => "<div id=\"resultados_pesquisa_prorrogacao\"></div>"
            page.alert "Não foram encontrados registros com estes parâmetros."
          else
            page.replace_html 'resultados_pesquisa_prorrogacao', :partial => 'resultado_pesquisa_prorrogacao', :object => @recebimentos
          end
        end
      else
        render :update do |page|
          mensagens = []
          mensagens << '* Insira um serviço para a pesquisa' if params[:busca][:nome_servico].blank?
          mensagens << '* Insira um período de datas válido' if params[:busca][:datas].blank?
          page.alert mensagens.join("\n")
        end
      end
    end
  end

  def gravar_dados_de_prorrogacao_de_contrato
    retorno = RecebimentoDeConta.prorroga_todos_contratos(current_usuario, params[:ids], params[:busca], session[:ano])
    render :update do |page|
      if retorno.first
        page.alert retorno.last
        page << "$('busca_servico_id').value = ''; $('busca_data_min').value = ''; $('busca_data_max').value = ''; $('busca_datas').value = '';"
        page.reload
      else
        page.alert retorno.last
        render :action => 'prorrogar'
      end
    end
  end

  private
 
  def so_pode_alterar_servicos_desta_unidade
    if params[:id]
      @servico = Servico.find params[:id]
      unless @servico.unidade_id == session[:unidade_id].to_i
        flash[:notice] = 'Esse serviço pertence a outra unidade.'
        redirect_to login_path
      end
    end
  end
  
end
