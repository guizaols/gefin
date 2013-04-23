class BancosController < ApplicationController

  #  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_banco]

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDosBancos,
    'any' => Perfil::Bancos
  }

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_banco]

  def index
    @bancos = Banco.find(:all, :order => 'descricao ASC')
  end

  def show
    @banco = Banco.find(params[:id])
  end

  def new
    @banco = Banco.new
  end

  def edit
    @banco = Banco.find(params[:id])
  end

  def create
    @banco = Banco.new(params[:banco])
    if @banco.save
      flash[:notice] = 'Banco criado com sucesso!'
      redirect_to bancos_path
    else
      render :action => "new"
    end
  end

  def update
    @banco = Banco.find(params[:id])

    if @banco.update_attributes(params[:banco])
      flash[:notice] = 'Banco atualizado com sucesso!'
      redirect_to bancos_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @banco = Banco.find(params[:id])
    if @banco.destroy
      flash[:notice] = 'Banco excluído com sucesso!'
    else
      flash[:notice] = @banco.mensagem_de_erro
    end
    
    redirect_to(bancos_url)
  end
  
  def auto_complete_for_banco
    find_options = { 
      :conditions => [ "((LOWER(descricao) LIKE ?) or (LOWER(codigo_do_banco) LIKE ?))", params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "descricao ASC" }

    @items = Banco.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.nome_banco}</li>"}.join + '</ul>'
  end
  
end
