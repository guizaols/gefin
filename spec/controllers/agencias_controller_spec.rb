require File.dirname(__FILE__) + '/../spec_helper'

describe AgenciasController do  
  
  integrate_views

  it 'should get index' do
    login_as :quentin
    get :index
    response.should be_success
    response.should render_template('index')
    response.should have_tag('table.listagem')
  end

  it "should get show" do
    login_as :quentin
    agencia = agencias(:centro)
    get :show, :id => agencia.id
    response.should be_success
    response.should render_template('show')
    assigns[:agencia].id.should == agencia.id
  end

  it 'should get new' do
    login_as :quentin
    get :new
    response.should be_success
    response.should render_template('new')
    response.should have_tag('form[action=?][method=post]', agencias_path) do
      validar_campos_form
    end
  end
  
  it 'should get edit' do
    login_as :quentin
    agencia = agencias(:centro)
    get :edit, :id => agencia.id
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form[action=?][method=post]', agencia_path(agencia)) do
      with_tag 'input[name=_method][value=put]'
      validar_campos_form
    end
  end

  def validar_campos_form
    with_tag('input[name=?]', 'agencia[nome]')
    with_tag('input[name=?]', 'agencia[numero]')
    with_tag('input[name=?]', 'agencia[digito_verificador]')
    with_tag('input[name=?]', 'agencia[banco_id]')
    with_tag('input[name=?]', 'agencia[localidade_id]')
    with_tag('input[name=?]', 'agencia[endereco]')
    with_tag('input[name=?]', 'agencia[cep]')
    with_tag('input[name=?]', 'agencia[complemento]')
    with_tag('input[name=?]', 'agencia[telefone]')
    with_tag('input[name=?]', 'agencia[fax]')
    with_tag('input[name=?]', 'agencia[email]')
    with_tag('input[name=?]', 'agencia[nome_contato]')
    with_tag('input[name=?]', 'agencia[telefone_contato]')
    with_tag('input[name=?]', 'agencia[email_contato]')
  end

  it 'should create valid object' do
    login_as :quentin
    post :create, :agencia => {:nome => 'Teste', :numero => "2314", :digito_verificador => "9", :banco => bancos(:banco_caixa), :localidade => localidades(:primeira)}
    response.should redirect_to(agencias_path)
  end

  it 'should not create invalid object' do
    login_as :quentin
    post :create, :agencia => {:nome => '', :numero => '', :digito_verificador => ''}
    assigns(:agencia).entidade_id.should == entidades(:senai).id
    response.should render_template('new')
  end

  it 'should update valid object' do
    login_as :quentin
    agencia = agencias(:centro)
    put :update, :id => agencia.id, :agencia => {}
    assigns(:agencia).should == Agencia.find(agencia)
    response.should redirect_to(agencias_path)
  end

  it 'should not update invalid object' do
    login_as :quentin
    agencia = agencias(:centro)
    put :update, :id => agencia.id, :agencia => {:nome => '', :numero => '', :digito_verificador => ''}
    assigns(:agencia).should == Agencia.find(agencia)
    response.should render_template('edit')
  end

  it 'should delete object' do
    lambda {
      login_as :quentin
      agencia = agencias(:centro)
      delete :destroy, :id => agencia.id
    }.should change(Agencia, :count).by(-1)
    response.should redirect_to(agencias_url)
  end
  
  describe "Verifica se" do
    
    it "testa auto_complete de agencia" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      
      post :auto_complete_for_agencia, :argumento => 'a'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", agencias(:prainha).id,'2345 - Prainha')
      end      
    end

    it "testa auto_complete de agencia com termina_em" do
      login_as :quentin
      post :auto_complete_for_agencia, :argumento => '*Prain'
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 0
      end
    end

    it "testa auto_complete de agencias passando 'cen' " do
      login_as :quentin
      post :auto_complete_for_agencia, :argumento => 'cen'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", agencias(:centro).id,'2445 - Centro')
      end      
    end
    
    it "testa auto_complete de agencias passando '23' " do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      
      post :auto_complete_for_agencia, :argumento => '23'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", agencias(:prainha).id,'2345 - Prainha')
      end      
    end
    
    it "testa auto_complete de agencias passando '2' " do
      login_as :quentin
      post :auto_complete_for_agencia, :argumento => '2'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", agencias(:centro).id,'2445 - Centro')
      end      
    end
    
    it "esta bloqueando acoes nao permitidas do usuario juvenal com acesso restrito ao model Agencia action new" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      
      get :new
      response.should redirect_to(login_path)
    end
    
    it "esta bloqueando acoes nao permitidas do usuario admin com acesso restrito ao model Agencia action edit" do
      login_as :admin
      agencia = agencias(:centro)
      get :edit, :id => agencia.id
      response.should redirect_to(login_path)
    end
     
    it "esta bloqueando acoes nao permitidas do usuario com acesso restrito ao model Agencia action destroy" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      
      agencia = agencias(:prainha)
      delete :destroy, :id => agencia.id
      response.should redirect_to(login_path)
    end
    
    it "esta bloqueando acoes nao permitidas do usuario aaron com acesso restrito ao model Agencia action index" do
      login_as :aaron
      get :index
      response.should be_success 
    end
    
    it "esta bloqueando acoes nao permitidas do usuario aaron com acesso restrito ao model Agencia action show" do
      login_as :aaron
      agencia = agencias(:centro)
      get :show, :id => agencia.id
      response.should be_success
      response.should render_template('show')
      assigns[:agencia].id.should == agencia.id     
    end    
    
  end

  describe 'Filtra por entidade' do

    it 'a action index' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    
      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:agencias].should == [agencias(:prainha)]
    end

    it 'a action edit' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :edit, :id => agencias(:centro).id
      response.should redirect_to(login_path)
    end

    it 'a action show' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :show, :id => agencias(:centro).id
      response.should redirect_to(login_path)
    end

    it 'a action destroy' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      delete :destroy, :id => agencias(:centro).id
      response.should redirect_to(login_path)
    end

    it 'a action update' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      put :update, :id => agencias(:centro).id
      response.should redirect_to(login_path)
    end

    it "auto complete de agencias passando '2' pesquisando na unidade incorreta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_agencia, :argumento => '2'
      response.should be_success
      assigns[:items].should == [agencias(:prainha)]
    end
    
    
    it "teste de auto complete para carregar as agencias do banco" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      post :auto_complete_for_agencias_do_banco,:banco_id=>bancos(:banco_caixa).id,:argumento=>"a"
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 1
        with_tag("li[id=?]", agencias(:prainha).id, "2345 - Prainha")
      end
      assigns[:itens].should == [agencias(:prainha)]
    end

    it "teste de auto complete para carregar as agencias do banco passando o número" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      post :auto_complete_for_agencias_do_banco, :banco_id => bancos(:banco_caixa).id, :argumento => "4"
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 1
        with_tag("li[id=?]", agencias(:prainha).id, "2345 - Prainha")
      end
      assigns[:itens].should == [agencias(:prainha)]
    end

    it "teste de auto complete para não carregar as agencias do banco passando o nome" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      post :auto_complete_for_agencias_do_banco, :banco_id => bancos(:banco_caixa).id, :argumento => "zas"
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 0
      end
      assigns[:itens].should == []
    end

    it "teste de auto complete para não carregar as agencias do banco passando o número" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      post :auto_complete_for_agencias_do_banco, :banco_id => bancos(:banco_caixa).id, :argumento => "9231"
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 0
      end
      assigns[:itens].should == []
    end
  
  end

end