class ChequesController < ApplicationController
  
  PERMISSOES = {
    ['index'] => Perfil::ControleDeCheques,
    ['baixar_abandonar_devolver_estornar'] => Perfil::ManipularControleDeCheques
  }
  
  def index
    params[:busca] ||= {}
    @cheques = Cheque.pesquisar_cheques(params[:busca], session[:unidade_id])
  end

  def baixar_abandonar_devolver_estornar
    params[:cheques] ||= {}
    retorno = nil
    render :update do |page|
      if params[:tipo] == 'estornar'
        params[:cheques][:conta_corrente_id] = ''
        params[:cheques][:conta_contabil_id] = ''
        retorno = Cheque.estornar(session[:ano], params[:cheques], session[:unidade_id], params[:data_estorno], params[:justificativa], current_usuario)
      elsif params[:cheques].has_key?(:tipo_abandono) && params[:tipo] == 'abandonar'
        params[:data_estorno] = ''
        params[:justificativa] = ''
        if params[:cheques].has_key?(:conta_contabil_debito_nome) && params[:conta_contabil_debito_nome].blank?
          page << "$('cheques_conta_contabil_debito_nome').value = ''; $('cheques_conta_contabil_debito_id').value = '';"
          params[:cheques][:conta_contabil_debito_id] = nil
          params[:cheques][:conta_contabil_debito_nome] = nil
        end
        if params[:cheques].has_key?(:conta_contabil_credito_nome) && params[:conta_contabil_credito_nome].blank?
          page << "$('cheques_conta_contabil_credito_nome').value = ''; $('cheques_conta_contabil_credito_id').value = '';"
          params[:cheques][:conta_contabil_credito_id] = nil
          params[:cheques][:conta_contabil_credito_nome] = nil
        end
        retorno = Cheque.abandonar(session[:ano], params[:cheques], session[:unidade_id], current_usuario)
      elsif params[:cheques].has_key?(:tipo_da_ocorrencia)
        params[:data_estorno] = ''
        params[:justificativa] = ''
        if params[:cheques].has_key?(:conta_contabil_devolucao_nome) && params[:conta_contabil_devolucao_nome].blank?
          params[:cheques][:conta_contabil_devolucao_id] = nil
          params[:cheques][:conta_contabil_devolucao_nome] = nil
          page << "$('cheques_conta_contabil_devolucao_nome').value = ''; $('cheques_conta_contabil_devolucao_id').value = '';"
        end
        retorno = Cheque.devolver(session[:ano], params[:cheques], session[:unidade_id], current_usuario)
      elsif params[:tipo] == 'baixar'
        params[:data_estorno] = ''
        params[:justificativa] = ''
        if params[:cheques].has_key?(:conta_corrente_nome) && params[:cheques][:conta_corrente_nome].blank?
          params[:cheques][:conta_corrente_id] = ''
          params[:cheques][:conta_contabil_id] = ''
          page << "$('cheques_conta_corrente_nome').value = ''; $('cheques_conta_corrente_id').value = '';
                  $('cheques_conta_contabil_nome').value = ''; $('cheques_conta_contabil_id').value = ''; Element.hide('tr_de_conta_contabil_da_conta_corrente');"
        end
        retorno = Cheque.baixar(session[:ano], params[:cheques], session[:unidade_id], current_usuario)
      end
      page.alert retorno.last
      page.reload if retorno.first
    end
  end

end
