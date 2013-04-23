class HistoricosController < ApplicationController

#  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_historico]

  before_filter :so_pode_alterar_historicos_desta_entidade

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDosHistoricos,
    'any' => Perfil::Historicos
  }

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_historico]

  def index
    @historicos = Historico.find_all_by_entidade_id(@unidade.entidade_id, :order => 'descricao ASC')
  end

  def new
    @historico = Historico.new
  end

  def edit
  end

  def create
    @historico = Historico.new(params[:historico])
    @historico.entidade_id = @unidade.entidade_id
    if @historico.save
      flash[:notice] = 'Histórico Padrão gravado com sucesso.'
      redirect_to historicos_path
    else
      render :action => "new" 
    end
  end

  def update
    if @historico.update_attributes(params[:historico])
      flash[:notice] = 'Histórico Padrão atualizado com sucesso.'
      redirect_to historicos_path
    else
      render :action => "edit" 
    end
  end

  def destroy
    @historico.destroy
    redirect_to(historicos_path) 
  end

  def auto_complete_for_historico
    @items = Historico.all :conditions => ["entidade_id = ? AND descricao LIKE ?", @unidade.entidade_id, params['argumento'].formatar_para_like]
    render :text => '<ul>' + @items.collect{|s| "<li id=\"#{s.id}\">#{s.descricao} </li>" }.join + '</ul>'
  end
  
  private

  def so_pode_alterar_historicos_desta_entidade
    @unidade = Unidade.find session[:unidade_id]

    if params[:id]
      @historico = Historico.find params[:id]
      unless @historico.entidade_id == @unidade.entidade_id
        flash[:notice] = 'Esse Histórico pertence a outra entidade.'
        redirect_to login_path
      end
    end
  end
  
end
