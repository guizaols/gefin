class CartoesController < ApplicationController

  PERMISSOES = {
    ['index'] => Perfil::ControleDeCartoes,
    ['baixar', 'estornar'] => Perfil::ManipularControleDeCartoes
  }
  
  def index
    params[:busca] ||= {}
    @cartoes = Cartao.pesquisar_cartoes(params[:busca], session[:unidade_id])
  end

  def baixar
    params[:cartoes] ||= {}

    render :update do |page|
      if params.has_key?(:conta_corrente_nome) && params[:conta_corrente_nome].blank?
        params[:cartoes][:conta_contabil_id] = ''
        page << "$('cartoes_conta_contabil_nome').value = ''; $('cartoes_conta_contabil_id').value = ''; Element.hide('tr_de_conta_contabil_da_conta_corrente');"
      end
      baixa = Cartao.baixar(session[:ano], params[:cartoes], session[:unidade_id])
      page.alert baixa.last
      page.redirect_to cartoes_path if baixa.first
    end
  end

  def estornar
    params[:cartoes] ||= {}
    render :update do |page|
      estorno = Cartao.estornar(params[:cartoes], session[:unidade_id], params[:data_estorno], params[:justificativa])
      page.alert estorno.last
      if !params[:commit].blank?
        page.redirect_to cartoes_path if estorno.first
      else
        page.reload
      end
    end
  end
  
end
