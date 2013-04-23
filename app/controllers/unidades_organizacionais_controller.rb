class UnidadesOrganizacionaisController < ApplicationController

#  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_unidade_organizacional]

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_unidade_organizacional]

  def auto_complete_for_unidade_organizacional
    find_options = {
      :conditions => [ "((entidade_id = ?) AND (ano = ?)) AND ((LOWER(nome) LIKE ?) or (codigo_da_unidade_organizacional LIKE ?))", Unidade.find(session[:unidade_id]).entidade_id, session[:ano], params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => 'codigo_da_unidade_organizacional ASC' }
    
    @items = UnidadeOrganizacional.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.codigo_da_unidade_organizacional} - #{ Iconv.conv('iso-8859-15','utf-8',c.nome)}</li>"}.join + '</ul>'
  end

end
