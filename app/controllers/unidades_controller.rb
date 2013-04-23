class UnidadesController < ApplicationController  

#  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_unidade]

  before_filter :so_pode_alterar_unidades_desta_entidade

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasUnidades,
    'any' => Perfil::Unidades,
    ['importar_zeus'] => Perfil::RealizarImportacaoZeus
  }

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_unidade]
  
  def index
    @unidades = Unidade.find_all_by_entidade_id(@unidade_da_session.entidade_id, :order => 'nome ASC')
  end

  def show
  end

  def new
    @unidade = Unidade.new
  end

  def edit
  end

  def create
    @unidade = Unidade.new(params[:unidade])

    if @unidade.unidade_mae_check
      unidade_espelho = @unidade.clone
      unidade_espelho.nome = "#{unidade_espelho.nome} (Espelho)"
      unidade_espelho.unidade_mae = @unidade
      @unidade.unidade_filha = unidade_espelho
    end

    if @unidade.save
      flash[:notice] = 'Unidade criada com sucesso!'
      redirect_to(unidades_path)
    else
      render :action => "new"
    end
  end

  def update
    if @unidade.update_attributes(params[:unidade])
      flash[:notice] = 'Unidade atualizada com sucesso!'
      redirect_to(unidades_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @unidade = Unidade.find(params[:id])
    if @unidade.destroy
      flash[:notice] = 'Unidade excluída com sucesso!'
    else
      flash[:notice] = @unidade.mensagem_de_erro
    end
    redirect_to(unidades_path)
  end
  
  def auto_complete_for_unidade
    find_options = { 
      :conditions => [ "entidade_id = ? AND (LOWER(nome) LIKE ?)", @unidade_da_session.entidade_id,
        params['argumento'].formatar_para_like ],
      :order => "nome ASC" }

    @itens = Unidade.find(:all, find_options)
    render :text =>'<ul>' + @itens.collect{|c| "<li id=#{c.id}>#{c.nome_unidade}</li>"}.join + '</ul>'
  end

  def importar_zeus
    params[:busca] ||= {}
    if params[:busca].has_key?(:arquivo)
      case params[:busca][:tipo]
      when "unidade"
        @importacao = UnidadeOrganizacional.importar_unidades_organizacionais(params[:busca][:arquivo])       
        flash.now[:notice] = @importacao.last
      when "centro"
        @importacao = Centro.importar_centros(params[:busca][:arquivo])
        flash.now[:notice] = @importacao.last
      when "unidade_centro"
        @importacao = Centro.importar_relacionamentos_entre_centros_e_unidades_organizacionais(params[:busca][:arquivo])
        flash.now[:notice] = @importacao.last
      when "planos"
        @importacao = PlanoDeConta.importar_plano_de_contas(params[:busca][:arquivo])
        flash.now[:notice] = @importacao.last
      end
    end
  end

  private

  def so_pode_alterar_unidades_desta_entidade
    @unidade_da_session = Unidade.find session[:unidade_id]

    if params[:id]
      @unidade = Unidade.find params[:id]
      unless @unidade_da_session.entidade_id == @unidade.entidade_id
        flash[:notice] = "Essa Unidade pertence a outra entidade."
        redirect_to login_path
      end
    end
  end
  
end
