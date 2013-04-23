require File.dirname(__FILE__) + '/../spec_helper'

describe BancosController do
  integrate_views
  
  def mock_banco
    mock_model(Banco,:descricao=>"Banco do Brasil",:ativo=>"true",:codigo_do_banco=>"800",:codigo_do_zeus=>"800",:digito_verificador=>"4")
  end
  
  it "teste action index" do
    login_as :quentin
    banco = bancos(:banco_caixa,:banco_do_brasil)
    get :index
    assigns[:bancos].should == banco
    
  end
  
  def valida_form
    with_tag("input[name='banco[descricao]']")
    with_tag("input[name='banco[ativo]']")
    with_tag("input[name='banco[codigo_do_banco]']")
  end
  
  
  it "possui action show" do
    login_as :quentin
    banco = bancos(:banco_caixa)
    get :show, :id => banco.id
    assigns[:banco].should == banco
  end
  
   
  it "possui action new?" do
    login_as :quentin
    banco = mock_banco
    Banco.should_receive(:new).and_return banco
    get :new
    response.should be_success
  end  
  
  it "testando a view new" do
    login_as :quentin
    get :new
    response.should be_success
    response.should have_tag("form[method=post][action=?]",bancos_path) do
      valida_form
    end
  end
  
  it "conseguiu gravar um banco?" do
    login_as :quentin
    banco = mock_banco
    Banco.should_receive(:new).with('descricao' => 'Banco do Brasil', 'ativo'=>'true','codigo_do_banco'=>'800','codigo_do_zeus'=>'800','digito_verificador'=>'4').and_return banco
    banco.should_receive(:save).and_return true
    post :create, {:banco => {:descricao => 'Banco do Brasil', 'ativo'=>'true', 'codigo_do_banco'=>'800','codigo_do_zeus'=>'800','digito_verificador'=>'4'}}
    response.should redirect_to(bancos_path)
  end
  
  it "não conseguiu gravar um banco?" do
    login_as :quentin
    banco = mock_banco
    Banco.should_receive(:new).with('descricao' => '', 'ativo'=>'true','codigo_do_banco'=>'800','codigo_do_zeus'=>'800','digito_verificador'=>'4').and_return banco
    banco.should_receive(:save).and_return false
    post :create, {:banco => {:descricao => '', 'ativo'=>'true', 'codigo_do_banco'=>'800','codigo_do_zeus'=>'800','digito_verificador'=>'4'}}
    response.should render_template('new')
  end
  
  
  it "possui a action edit?" do
    login_as :quentin
    banco = mock_banco
    Banco.stub!(:find).with(:all).and_return []
    Banco.should_receive(:find).with('1').and_return banco
    get :edit , :id => '1'
    assigns[:banco].should == banco
    # Teste da  view
    response.should have_tag("form[action=?][method=post]",banco_path(banco.id)) do
      with_tag("input[name='_method'][value='put']")
      valida_form
    end
  end
  
  it "conseguiu fazer update?" do
    login_as :quentin
    banco = mock_model(Banco)
    Banco.should_receive(:find).with('1').and_return banco
    banco.should_receive(:update_attributes).with('descricao' => 'Teste').and_return true
    put :update, {:banco => {:descricao => 'Teste'},:id => '1'}
    response.should redirect_to(bancos_path)
  end
 
  it "conseguiu deletar" do
    login_as :quentin
    banco = mock_banco
    Banco.should_receive(:find).with('1').and_return banco
    banco.should_receive(:destroy).and_return true
    delete :destroy, :id => 1
    response.should redirect_to(bancos_path)
  end
  
  it "não conseguiu deletar" do
    login_as :quentin
    banco = bancos(:banco_do_brasil)
    delete :destroy, :id=>banco.id
    flash[:notice].should == "Não foi possível excluir, pois #{banco.descricao} possui agências vinculadas."
  end
  
  it "Testa se chama a action Index sem estar logado" do
    get :index
    response.should redirect_to(new_sessao_path)
  end

  describe "Verifica se" do
    
    it "testa auto_complete de banco" do
      login_as :quentin
      post :auto_complete_for_banco, :argumento => 'b'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", bancos(:banco_caixa).id,'700 - Banco Caixa')
        with_tag("li[id=?]", bancos(:banco_do_brasil).id,'800 - Banco do Brasil')
      end      
    end
    
    it "testa auto_complete de bancos passando 'cai' " do
      login_as :quentin
      post :auto_complete_for_banco, :argumento => 'cai'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", bancos(:banco_caixa).id,'700 - Banco Caixa')
      end      
    end
    
    it "testa auto_complete de bancos com termina_em" do
      login_as :quentin
      post :auto_complete_for_banco, :argumento => '*cai'
      response.should be_success
      response.should have_tag("ul") do
        with_tag "li", 0
      end
    end

    it "testa auto_complete de bancos com termina_em passando NIL" do
      login_as :quentin
      post :auto_complete_for_banco
      response.should be_success
      response.should have_tag("ul") do
        with_tag "li", 2
      end
    end

    it "testa auto_complete de bancos passando '0' " do
      login_as :quentin
      post :auto_complete_for_banco, :argumento => '0'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", bancos(:banco_caixa).id,'700 - Banco Caixa')
        with_tag("li[id=?]", bancos(:banco_do_brasil).id,'800 - Banco do Brasil')
      end      
    end
    
    it "testa auto_complete de bancos passando '7' " do
      login_as :quentin
      post :auto_complete_for_banco, :argumento => '7'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", bancos(:banco_caixa).id,'700 - Banco Caixa')
      end      
    end
    
    it "esta bloqueando acoes nao permitidas do usuario juvenal com acesso restrito ao model Bancos action new" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
    
    it "esta bloqueando acoes nao permitidas do usuario juvenal com acesso restrito ao model Bancos action edit" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      banco = bancos(:banco_do_brasil)
      get :edit, :id => banco.id
      response.should redirect_to(login_path)
     end
     
    it "esta bloqueando acoes nao permitidas do usuario juvenal com acesso restrito ao model Bancos action destroy" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal
      banco = bancos(:banco_do_brasil)
      delete :destroy, :id => banco.id
      response.should redirect_to(login_path)
    end
    
    it "esta bloqueando acoes nao permitidas do usuario aaron com acesso restrito ao model Bancos action index" do
      login_as :aaron
      get :index
      response.should be_success 
    end
    
    it "esta bloqueando acoes nao permitidas do usuario aaron com acesso restrito ao model Bancos action show" do
      login_as :aaron
      banco = bancos(:banco_do_brasil)
      get :show, :id => banco.id
      response.should be_success
      response.should render_template('show')
      assigns[:banco].id.should == banco.id      
    end    
  end

end