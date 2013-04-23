require File.dirname(__FILE__) + '/../spec_helper'

describe ParametroContaValoresController do
  
  integrate_views
  
  before(:each) do
    login_as :quentin
  end

  it 'should get index' do
    request.session[:ano] = "2009"
    get :index
    response.should be_success
    response.should render_template('index')
    response.should have_tag('table.listagem') do
        response.should_not have_tag("td",'Cheques Pré-Datado')
        response.should_not have_tag("td",'Taxa de Boleto')
        with_tag("td",'41010101008 - Contribuicoes Regul. oriundas do SENAI')
        with_tag("td",'Fornecedor')
    end
  end
  
  it 'should get new' do
    get :new
    response.should be_success
    response.should render_template('new')
    response.should have_tag('form[action=?]', parametro_conta_valores_path) do
      validar_campos_form
    end
  end
  
  it 'should get edit' do
    get :edit, :id => parametro_conta_valores(:one).id
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form[action=?]', parametro_conta_valor_path(parametro_conta_valores(:one).id)) do
      with_tag 'input[name=_method][value=put]'
      validar_campos_form
    end
  end

  def validar_campos_form
    with_tag('select[name=?]','parametro_conta_valor[tipo]') do
      with_tag("option[value=?]",0,'Juros/Multa')
      with_tag("option[value=?]",1,'Taxa de Boleto')
      with_tag("option[value=?]",2,'Desconto PF')
      with_tag("option[value=?]",3,'Desconto PJ')
      with_tag("option[value=?]",4,'Outros (Débito)')
      with_tag("option[value=?]",5,'Outros (Crédito)')
      with_tag("option[value=?]",6,'Fornecedor')
      with_tag("option[value=?]",7,'Cheque Pré-Datado')
    end
  end

  it 'should create valid object' do
    post :create, :parametro_conta_valor => {:unidade_id => 1,:nome_conta_contabil => 41010101008,:conta_contabil_id=> plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, :tipo => 1}
    response.should redirect_to(parametro_conta_valores_path)
  end
 
  it 'should not create invalid object' do
    post :create, :parametro_conta_valor => {:unidade_id => 1,:nome_conta_contabil => 41010101008,:conta_contabil_id=> plano_de_contas(:plano_de_contas_ativo).id, :tipo => 1, :ano => 2005}
    response.should render_template('new')
  end

  it 'should update valid object' do
    put :update, :id => parametro_conta_valores(:one).id, :parametro_conta_valor => {}
    assigns(:parametro_conta_valor).should == ParametroContaValor.find(parametro_conta_valores(:one).id)
    response.should redirect_to(parametro_conta_valores_path)
  end

  it 'should not update invalid object' do
    put :update, :id => parametro_conta_valores(:one).id, :parametro_conta_valor => {:unidade_id => 1, :conta_contabil_id =>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, :conta_contabil => plano_de_contas(:plano_de_contas_ativo_contribuicoes) , :tipo => '', :ano=> 2001}
    assigns(:parametro_conta_valor).should == ParametroContaValor.find(parametro_conta_valores(:one).id)
    response.should render_template('edit')
  end

  it 'should delete object' do
    lambda {
      delete :destroy, :id => parametro_conta_valores(:one).id
    }.should change(ParametroContaValor, :count).by(-1)
    response.should redirect_to(parametro_conta_valores_url)
  end

  describe "Verifica se" do
  
    integrate_views
  
    it "esta atualizando os parametros de unidade diferente" do
      login_as :admin
      put :update, :parametro_conta_valor => {:ano => 2009}, :id => parametro_conta_valores(:one).id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuário juvenal sem permissão que tenta modificar dados do model ParametroContaValores action new" do
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
   
    it "bloqueia usuário juvenal sem permissão que tenta modificar dados do model ParametroContaValores action edit" do
      login_as :juvenal
      parametro = parametro_conta_valores(:one)
      get :edit, :id=>parametro.id
      response.should redirect_to(login_path)
    end
  
    it "bloqueia usuário juvenal sem permissão que tenta modificar dados do model ParametroContaValores action destroy" do
      login_as :juvenal
      parametro = parametro_conta_valores(:one)
      delete :destroy, :id=>parametro.id
      response.should redirect_to(login_path)
    end
   
  end

end
