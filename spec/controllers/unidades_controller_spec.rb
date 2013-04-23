require File.dirname(__FILE__) + '/../spec_helper'

describe UnidadesController do
  
  integrate_views
  
  def valida_campos_do_form
    with_tag("input[name='unidade[nome]']")
    with_tag("input[name='unidade[ativa]']")
    with_tag("input[name='unidade[sigla]']")
    with_tag("input[name='unidade[endereco]']")
    with_tag("input[name='unidade[bairro]']")
    with_tag("input[name='unidade[cep]']")
    with_tag("input[name='unidade[localidade_id]']")
    with_tag("input[name='unidade[nome_localidade]']")
    with_tag("input[name='unidade[data_de_referencia]']")
    with_tag("input[name='unidade[nome_caixa_zeus]']")
    with_tag("input[name='unidade[nome]']")
    with_tag("input[name='unidade[telefone][]']")
    with_tag("input[name='unidade[cnpj]']")
    with_tag("input[name='unidade[email]']")
    with_tag("input[name='unidade[fax]']")
  end
  
  it "possui action new?" do
    login_as :quentin
    get :new
    response.should be_success
    response.should have_tag("form[action=?][method=post]",unidades_path) do
      valida_campos_do_form
    end
  end
  
  it 'deve criar um objeto válido' do
    login_as :juliano
    post :create, :unidade => {:entidade_id => entidades(:senai).id, :nome => 'Senai Varzea Grande', :sigla => 'SENAI',:endereco => 'Rua das Batatas', :bairro => 'Limoeiro',:cep => '86020-200',:localidade_id => localidades(:primeira).id,:ativa => true,:data_de_referencia => '01/04/2009',
      :telefone =>["33425712","88499627"], :nome_caixa_zeus => "1", :cnpj => '08916988000145', :complemento=>'3',
      :senha_baixa_dr => 'teste', :limitediasparaestornodeparcelas => 5000
      }
    response.should redirect_to(unidades_path)
  end
  
  it 'não deve criar um objeto válido' do
    login_as :juliano
    post :create, :unidade => {:entidade_id => entidades(:senai).id,:nome => '',:sigla => '',:endereco => '', :bairro => '',:cep => '',:localidade_id => localidades(:primeira).id,:ativa => true,:data_de_referencia => '',
      :telefone => ["33425712","88499627"],:nome_caixa_zeus => "1",:cnpj => '',:complemento=>''}
    response.should render_template('new')
  end
  
  it "possui a action edit?" do
    login_as :quentin
    unidade = unidades(:senaivarzeagrande)
    get :edit , :id => unidade.id
    response.should be_success
    assigns[:unidade].should == unidade
    response.should render_template('edit')
    response.should have_tag('form[action=?]', unidade_path(unidade.id)) do
    end
  end
  
  it 'deve atualizar um objeto válido' do
    login_as :quentin
    put :update, :id => unidades(:senaivarzeagrande).id, :unidade => { :nome => 'Teste' }
    assigns(:unidade).should == unidades(:senaivarzeagrande)
    response.should redirect_to(unidades_path)
  end
  
  it "GET /unidades should be successful" do
    login_as :quentin
    get :index
    response.should be_success
    response.should render_template('index')
    assigns[:unidades].should == [unidades(:senaivarzeagrande)]
  end

  
  it 'Não deve atualizar um objeto inválido' do
    login_as :quentin
    put :update, :id => unidades(:senaivarzeagrande).id, :unidade => { :nome => ''}
    assigns(:unidade).should == unidades(:senaivarzeagrande)
    response.should render_template('edit')
  end
  
  it "possui a action show?" do
    login_as :quentin
    unidade = unidades(:senaivarzeagrande)
    get :show, :id => unidade.id
    assigns[:unidade].should == unidade
    response.should be_success
    response.should render_template('show')
  end
  
  it "possui a action destroy?" do
    PagamentoDeConta.delete_all
    RecebimentoDeConta.delete_all
    login_as :quentin
    unidade = unidades(:senaivarzeagrande)
    lambda {
      delete :destroy, :id => unidade.id
    }.should change(Unidade, :count).by(-1)
    response.should redirect_to(unidades_path)
  end
  
  it "possui a action destroy?" do
    login_as :quentin
    unidade = unidades(:senaivarzeagrande)
    lambda {
      delete :destroy, :id => unidade.id
    }.should change(Unidade, :count).by(0)
    response.should redirect_to(unidades_path)
  end
  
  
  
  

  it "Verifica se esta redirecionando para o login quando o usuario nao tem permissao" do
    login_as :admin
    get :index   
    response.should redirect_to(login_path)
  end
   
  it "Verifica se esta redirecionando para o login quando o usuario nao tem permissao" do
    login_as :aaron
    get :index    
    response.should_not be_success
  end

  it "Verifica se esta acessando o model quando o usuario tem permissao" do
    login_as :quentin
    get :index
    response.should be_success
  end
     
     
  describe "with failed save" do
  
    it "should re-render 'new'" do
      login_as 'quentin'
      post :create, :unidade => {}
      response.should render_template('new')
    end
      
  end

  describe "Verifica se" do
    
    it "testa auto_complete de unidade" do
      login_as :quentin
      post :auto_complete_for_unidade , :argumento => 'a'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]",unidades(:senaivarzeagrande).id,'SENAI - Varzea Grande')
      end      
    end
    
    it "testa auto_complete de unidade com termina_em" do
      login_as :quentin
      post :auto_complete_for_unidade , :argumento => '*varzea'
      response.should be_success
      response.should have_tag("ul") do
        with_tag 'li', 0
      end
    end

    it "testa auto_complete de unidade passando 'senai' " do
      login_as :quentin
      post :auto_complete_for_unidade, :argumento => 'senai'
      response.should be_success
      response.should have_tag("ul") do
        with_tag("li[id=?]", unidades(:senaivarzeagrande).id,'SENAI - Varzea Grande')
      end      
    end
      
    it "deve criar nova unidade e gravar a entidade_id" do
      login_as 'quentin'
      post :create, :unidade => {:nome => 'Serviço Social da Indústria', :sigla => 'SESI', :entidade_id => usuarios(:quentin).unidade.entidade_id,
        :nome_caixa_zeus => "CX.00 SENAIVG", :senha_baixa_dr => 'teste', :limitediasparaestornodeparcelas => 5000}
      assert_equal usuarios(:quentin).unidade.entidade_id, assigns[:unidade].entidade_id
      response.should redirect_to(unidades_path)
    end
    
  end

  describe 'Filtra por entidade' do

    it 'a action index' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:unidades].should == [unidades(:sesivarzeagrande)]
    end

    it 'a action show' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :show, :id => unidades(:senaivarzeagrande).id
      response.should redirect_to(login_path)
    end

    it 'a action edit' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :edit, :id => unidades(:senaivarzeagrande).id
      response.should redirect_to(login_path)
    end

    it 'a action update' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      put :update, :id => unidades(:senaivarzeagrande).id
      response.should redirect_to(login_path)
    end

    it 'a action destroy' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :show, :id => unidades(:senaivarzeagrande).id
      response.should redirect_to(login_path)
    end

    it "a action auto_complete_for_unidade com o parametro 'a' pesquisando em unidade errada" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_unidade, :id => unidades(:sesivarzeagrande).id
      assigns[:itens].should == [unidades(:sesivarzeagrande)]
    end

  end

  describe "testes da importação para o Zeus" do

    it "teste do form" do
      login_as :quentin
      post :importar_zeus
      response.should be_success
      response.should have_tag('form[action=?][enctype=?]', importar_zeus_unidades_path, 'multipart/form-data') do
        with_tag 'input[name=?][value=?]', 'busca[tipo]', 'unidade'
        with_tag 'input[name=?][value=?]', 'busca[tipo]', 'centro'
        with_tag 'input[name=?][value=?]', 'busca[tipo]', 'unidade_centro'
        with_tag 'input[name=?][value=?]', 'busca[tipo]', 'planos'
        with_tag 'input[name=?][type=?]', 'busca[arquivo]', 'file'
      end
    end

    it "teste para verificação de permissão" do
      login_as :juvenal
      post :importar_zeus

      response.should redirect_to(login_path)
    end

    it "teste da importacao dos centros" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT + "/test/importacao/t_centro_2009.txt")
      params = {"tipo" => "centro", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Foram importados 100 Centros!"
    end

    it "teste da importacao das unidades organizacionais" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT+"/test/importacao/t_undorg_2009.txt")
      params = {"tipo" => "unidade", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Foram importadas 27 unidades organizacionais!"
    end

    it "teste da importacao dos planos de conta" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT + "/test/importacao/t_plcta_plano de conta 2009.txt")
      params = {"tipo" => "planos", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Foram importados 100 Planos de Conta!"
    end

    it "teste da importacao dos relacionamentos entre unidade org e centro" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT + "/test/importacao/t_Centro_undorg_2009.txt")
      params = {"tipo" => "unidade_centro", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Foram importados 942 Unidades Organizacionais x Centros!"
    end

    it "teste se rejeita um arquivo de contexto diferente, Unidade e Unidade Centro" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT + "/test/importacao/t_Centro_undorg_2009.txt")
      params = {"tipo" => "unidade", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Importação não realizada. Verifique o arquivo enviado!"
    end

    it "teste se rejeita um arquivo de contexto diferente, Unidade e Centro" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT + "/test/importacao/t_centro_2009.txt")
      params = {"tipo" => "unidade", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Importação não realizada. Verifique o arquivo enviado!"
    end

    it "teste se rejeita um arquivo de contexto diferente, Unidade e Plano De Conta" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT+"/test/importacao/t_plcta_plano de conta 2009.txt")
      params = {"tipo" => "unidade", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Importação não realizada. Verifique o arquivo enviado!"
    end

    it "teste se rejeita um arquivo de contexto diferente, Centro e Plano De Conta" do
      login_as :quentin
      arquivo = File.open(RAILS_ROOT + "/test/importacao/t_plcta_plano de conta 2009.txt")
      params = {"tipo" => "centro", "arquivo" => arquivo}
      post :importar_zeus, :busca => params

      response.should be_success
      response.flash.now[:notice].should == "Importação não realizada. Verifique o arquivo enviado!"
    end

  end
  
end
