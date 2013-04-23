require File.dirname(__FILE__) + '/../spec_helper'

describe LancamentoImpostosController do
  
  integrate_views

  it 'should get index' do
    login_as :juliano
    parcela = parcelas(:primeira_parcela)
    get :index , :pagamento_de_conta_id => parcela.conta_id, :parcela_id => parcela.id 
    response.should be_success
    response.should render_template('index')
    response.should have_tag('table.listagem')
  end

  it "should get show" do
    login_as :juliano
    lancamento_imposto = lancamento_impostos(:primeira)  
    get :show, :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :id => lancamento_imposto.id   
    response.should be_success
    response.should render_template('show')
    assigns[:lancamento_imposto].id.should == lancamento_imposto.id 
  end

  it 'should get new' do
    login_as :juliano
    parcela = parcelas(:primeira_parcela)
    get :new , :pagamento_de_conta_id => parcela.conta_id, :parcela_id => parcela.id 
    response.should be_success
    response.should render_template('new')
    response.should have_tag('form[action=?]', pagamento_de_conta_parcela_lancamento_impostos_path(parcela.conta_id,parcela.id)) do
      validar_campos_form
    end
  end
  
  it 'should get edit' do
    login_as :quentin
    lancamento_imposto = lancamento_impostos(:primeira) 
    get :edit, :pagamento_de_conta_id =>lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :id => lancamento_imposto.id
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form[action=?]', pagamento_de_conta_parcela_lancamento_imposto_path(lancamento_imposto.parcela.conta_id,lancamento_imposto.parcela_id,lancamento_imposto.id)) do
      validar_campos_form
    end
  end

  def validar_campos_form

  end

  it 'should create valid object' do
    login_as :juliano
    lancamento_imposto = lancamento_impostos(:primeira)
    post :create, :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :lancamento_imposto => {:parcela => parcelas(:primeira_parcela), :imposto => impostos(:iss), :data_de_recolhimento => '21-04-2009', :valor => 500}
    response.should redirect_to(pagamento_de_conta_parcela_lancamento_impostos_path(lancamento_impostos(:primeira).parcela.conta_id,lancamento_impostos(:primeira).parcela_id))
  end
  
  it 'should not create invalid object' do
    login_as :quentin
    lancamento_imposto = lancamento_impostos(:primeira)
    post :create, :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :lancamento_imposto => {}
    response.should render_template('new')
  end

  it 'should update valid object' do
    login_as :juliano    
    lancamento_imposto = lancamento_impostos(:primeira)
    put :update, :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :id => lancamento_imposto.id, :lancamento_imposto => {}
    assigns(:lancamento_imposto).should == LancamentoImposto.find(lancamento_imposto.id)
    response.should redirect_to(pagamento_de_conta_parcela_lancamento_impostos_path(lancamento_imposto.parcela.conta_id,lancamento_imposto.parcela_id))
  end

  it 'should not update invalid object' do
    login_as :juliano    
    lancamento_imposto = lancamento_impostos(:primeira)
    put :update, :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :id => lancamento_imposto.id, :lancamento_imposto => {:data_de_recolhimento => ''}
    assigns(:lancamento_imposto).should == LancamentoImposto.find(lancamento_imposto.id)
    response.should render_template('edit')
  end

  it 'should delete object' do
    login_as :juliano    
    lambda {
      delete :destroy,:pagamento_de_conta_id =>lancamento_impostos(:primeira).parcela.conta_id,:parcela_id=>lancamento_impostos(:primeira).parcela_id, :id => lancamento_impostos(:primeira).id
    }.should change(LancamentoImposto, :count).by(-1)
    response.should redirect_to(pagamento_de_conta_parcela_lancamento_impostos_path(lancamento_impostos(:primeira).parcela.conta_id,lancamento_impostos(:primeira).parcela_id))
  end
  
  it "Bloqueia o usuario juvenal que não possui acesso ao model lancamento_imposto action new" do
    login_as :juvenal
    parcela = parcelas(:primeira_parcela)
    get :new , :pagamento_de_conta_id => parcela.conta_id, :parcela_id => parcela.id 
    response.should redirect_to(login_path)
  end
  
  it "Bloqueia o usuario juvenal que não possui acesso ao model lancamento_imposto action edit" do
    login_as :juvenal
    lancamento_imposto = lancamento_impostos(:primeira)
    get :edit , :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :id=>lancamento_imposto.id
    response.should redirect_to(login_path)
  end
  
  it "Bloqueia o usuario juvenal que não possui acesso ao model lancamento_imposto action destroy" do
    login_as :juvenal
    lancamento_imposto = lancamento_impostos(:primeira)
    delete :destroy , :pagamento_de_conta_id => lancamento_imposto.parcela.conta_id, :parcela_id => lancamento_imposto.parcela_id, :id=>lancamento_imposto.id
    response.should redirect_to(login_path)
  end

end