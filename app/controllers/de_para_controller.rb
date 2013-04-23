class DeParaController < ApplicationController

  before_filter :carregar_unidade, :carrega_centro_ou_unidade_organizacional
  
  PERMISSOES = {
    ['show', 'alterar'] => Perfil::DeParaEntreAnosDoOrcamento
  }

  def show
    @objetos_deste_ano = @model.find_all_by_entidade_id_and_ano(@unidade.entidade_id, session[:ano], :order => @ordenacao)
    @objetos_do_ano_passado = @model.find_all_by_entidade_id_and_ano(@unidade.entidade_id, session[:ano].to_i - 1, :order => @ordenacao)
  end

  def alterar
    render :update do |page|
      if params[:commit] == 'Confirmar'
        novo_id = params[:objeto_deste_ano_id]
        mensagem = "Os objetos selecionados foram associados!"
      else
        novo_id = nil
        mensagem = "A associação entre os objetos foi cancelada!"
      end
      @model.find_by_id_and_entidade_id(params[:objeto_do_ano_passado_id], @unidade.entidade_id).update_attributes! :objeto_do_proximo_ano_id => novo_id
      page.alert mensagem
      page.reload
    end
  end
  
  private
  
  def carrega_centro_ou_unidade_organizacional
    @model = (params[:id] == 'centros' ? Centro : UnidadeOrganizacional)
    @ordenacao = (params[:id] == 'centros' ? 'codigo_centro':' codigo_da_unidade_organizacional')
  end
  
end
