class EntidadesController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasEntidades,
    'any' => Perfil::Entidades
  }
   
  def index
    @entidades = Entidade.find(:all, :order => 'nome ASC')
  end

  def show
    @entidade = Entidade.find(params[:id])
  end

end
