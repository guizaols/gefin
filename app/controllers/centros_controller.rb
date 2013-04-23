class CentrosController < ApplicationController

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_centro]

  def auto_complete_for_centro
    find_options = {
      :include => :unidade_organizacionais,
      :conditions => [ "((centros.entidade_id = ?) AND (centros.ano = ?) AND (unidade_organizacionais.id = ?)) AND ((LOWER(centros.nome) LIKE ?) or (centros.codigo_centro LIKE ?))", Unidade.find(session[:unidade_id]).entidade_id, session[:ano], params[:unidade_organizacional_id],params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "centros.codigo_centro ASC" }

    @items = Centro.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.codigo_centro} - #{ Iconv.conv('iso-8859-15','utf-8',c.nome)}</li>"}.join + '</ul>'
  end

  def auto_complete_for_centro_para_relatorio
    find_options = {
      :conditions => [ "((centros.entidade_id = ?) AND (centros.ano = ?)) AND ((LOWER(centros.nome) LIKE ?) or (centros.codigo_centro LIKE ?))", Unidade.find(session[:unidade_id]).entidade_id, session[:ano], params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "centros.codigo_centro ASC" }

    @items = Centro.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.codigo_centro} - #{c.nome}</li>"}.join + '</ul>'
  end

end
