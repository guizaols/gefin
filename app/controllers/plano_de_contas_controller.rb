class PlanoDeContasController < ApplicationController

  #  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_conta_contabil]

  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_conta_contabil,:auto_complete_for_conta_contabil_ano_anterior]

  def auto_complete_for_conta_contabil
    find_options = {
      :conditions => ['((entidade_id = ?) AND (ano = ?)) AND ((LOWER(nome) LIKE ?) or (codigo_contabil LIKE ?))', Unidade.find(session[:unidade_id]).entidade_id, session[:ano], params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "codigo_contabil ASC",
      :limit => 200,
      :select => 'id, tipo_da_conta, codigo_contabil, nome'
    }

    @items = PlanoDeConta.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.tipo_da_conta}_#{c.id}>#{c.codigo_contabil} - #{ Iconv.conv('iso-8859-15','utf-8',c.nome)}</li>"}.join + '</ul>'
  end

  def auto_complete_for_conta_contabil_ano_anterior
    find_options = {
      :conditions => ['((entidade_id = ?) AND (ano = ?)) AND ((LOWER(nome) LIKE ?) or (codigo_contabil LIKE ?))', Unidade.find(session[:unidade_id]).entidade_id, (session[:ano] - 1), params['argumento'].formatar_para_like, params['argumento'].formatar_para_like],
      :order => "codigo_contabil ASC",
      :limit => 200,
      :select => 'id, tipo_da_conta, codigo_contabil, nome'
    }

    @items = PlanoDeConta.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.tipo_da_conta}_#{c.id}>#{c.codigo_contabil} - #{c.nome}</li>"}.join + '</ul>'
  end

end
