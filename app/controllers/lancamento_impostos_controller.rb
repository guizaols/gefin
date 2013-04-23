class LancamentoImpostosController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDeLancamentoImpostos,
    'any' => Perfil::LancamentoImpostos
  }
  
  before_filter :carrega_parcela
 
  def index
    @lancamento_impostos = LancamentoImposto.find_all_by_parcela_id(params[:parcela_id], :order => 'data_de_recolhimento DESC')
  end

  def show
    @lancamento_imposto = LancamentoImposto.find_by_id_and_parcela_id(params[:id],params[:parcela_id])
  end

  def new
    @lancamento_imposto = LancamentoImposto.new
  end

  def edit
    @lancamento_imposto = LancamentoImposto.find_by_id_and_parcela_id(params[:id],params[:parcela_id])
  end

  def create    
    @lancamento_imposto = LancamentoImposto.new(params[:lancamento_imposto])
    @lancamento_imposto.parcela_id = params[:parcela_id]
    if @lancamento_imposto.save
      flash[:notice] = 'Lancamento do imposto criado com sucesso!'
      redirect_to(pagamento_de_conta_parcela_lancamento_impostos_path(@parcela.conta_id,@parcela.id))
    else
      render :action => "new"
    end
  end

  def update
    @lancamento_imposto = LancamentoImposto.find(params[:id])
    if @lancamento_imposto.update_attributes(params[:lancamento_imposto])
      flash[:notice] = 'Lancamento do imposto atualizado com sucesso!'
      redirect_to(pagamento_de_conta_parcela_lancamento_impostos_path(@parcela.conta_id,@parcela.id))
    else
      render :action => "edit"
    end
  end

  def destroy
    @lancamento_imposto = LancamentoImposto.find_by_id_and_parcela_id(params[:id],params[:parcela_id])
    @lancamento_imposto.destroy
    flash[:notice] = 'Lancamento do imposto excluído com sucesso!'
    redirect_to(pagamento_de_conta_parcela_lancamento_impostos_path(@parcela.conta_id,@parcela.id))
  end
  
  private
  
  def carrega_parcela
    @parcela = Parcela.find_by_id(params[:parcela_id])
  end
end
