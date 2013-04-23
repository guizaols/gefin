class AuditsController < ApplicationController

#  PERMISSOES = {
#    'index' => Perfil::Auditoria
#  }

  def index
    params[:busca] ||= {}
    @auditorias = Audit.procurar_auditorias(session[:unidade_id], params[:busca], params[:tabela], params[:page])
  end
  

end
