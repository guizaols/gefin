class ConfiguracaoController < ApplicationController
  
  PERMISSOES = {
    'update' => Perfil::ManipularDadosDeConfiguracao,
    'any' => Perfil::Configuracao
  }
  
  def edit
    @unidade = Unidade.find(session[:unidade_id])
    @unidade.hora_execussao_calculos_pesados = @unidade.hora_execussao_calculos_pesados.to_s[0..3].rjust(4, '0').insert(2, ':') unless @unidade.hora_execussao_calculos_pesados.blank?
  end

  def update
    @unidade = Unidade.find(session[:unidade_id])
    
    params[:unidade][:hora_execussao_calculos_pesados].gsub! /\D/, ''
    if @unidade.update_attributes(params[:unidade])
      flash[:notice] = "Configurações atualizadas com sucesso!"
      redirect_to(edit_configuracao_path)
    else
      flash[:notice] = "Não foi possível atualizar as configurações. Favor verificar!"
      render :action => "edit"
    end
  end

end
