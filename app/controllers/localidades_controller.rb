class LocalidadesController < ApplicationController

#  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_localidade]

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasLocalidades,
    'any' => Perfil::Localidades
  }

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_localidade]
  
  def index
    params[:busca] ||= {}
    @localidades = Localidade.paginate :all, :conditions => (params[:busca].blank? ? [] : ['nome LIKE ?', params[:busca].formatar_para_like]), :order => "nome ASC",:page => params[:page], :per_page => 50
  end

  def new
    @localidade = Localidade.new
  end

  def edit
    @localidade = Localidade.find(params[:id])
  end

  def create
    @localidade = Localidade.new(params[:localidade])
    if @localidade.save
      flash[:notice] = 'Localidade cadastrada com sucesso.'
      redirect_to localidades_path
    else
      render :action => "new"
    end
  end

  def update
    @localidade = Localidade.find(params[:id])
    if @localidade.update_attributes(params[:localidade])
      flash[:notice] = 'Localidade editada com sucesso.'
      redirect_to localidades_path
    else
      render :action => "edit" 
    end
  end

  def destroy
    @localidade = Localidade.find(params[:id])
    if @localidade.destroy
      flash[:notice] = "Localidade excluída com sucesso!"
    else
      flash[:notice] = @localidade.mensagem_de_erro.join("\n")
    end
    redirect_to(localidades_url)
  end

  def auto_complete_for_localidade
    find_options = { 
      :conditions => [ "(LOWER(nome) LIKE ?)", params['argumento'].formatar_para_like ],
      :order => "nome ASC",
      :limit => 50 }

    @items = Localidade.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.nome_localidade}</li>"}.join + '</ul>'
  end
  
end
