require File.dirname(__FILE__) + '/../spec_helper'

include AuthenticatedTestHelper

describe UsuariosController do
  
  integrate_views
 
  before do
    login_as :quentin
  end

  it 'should get index' do
    get :index 

    response.should be_success
    response.should render_template('index')
    response.should have_tag("table[class = ?]","listagem") do
    response.should_not have_tag("a[href = ?]",new_usuario_path) # NÃO PODE EXISTIR O LINK NO INDEX DE USUÁRIOS, POIS O USUÁRIO E CADASTRADO PELO SHOW DE PESSOAS 
      with_tag("tr[class = ?]",'impar') do
        with_tag("td") do
          with_tag("a[href = ?]",'/usuarios/1','quentin')
        end
        with_tag("td",'quentin')
        with_tag("td",'Felipe Giotto')
        with_tag("td[class = ?]",'ultima_coluna') do
          with_tag("a[href = ?]",'/usuarios/1/edit')
        end
      end
      with_tag("tr[class = ?]",'par') do
        with_tag("td") do
          with_tag("a[href = ?]",'/usuarios/2','aaron')
        end
        with_tag("td",'aaron')
        with_tag("td",'Juan Vitor Zeferino')
        with_tag("td[class = ?]",'ultima_coluna') do
          with_tag("a[href = ?]",'/usuarios/2/edit')
        end
      end
    end
  end
  
       
  it 'allows signup' do
    lambda do
      create_usuario
      response.should be_redirect
    end.should change(Usuario, :count).by(1)
  end

  it 'requires login on signup' do
    lambda do
      create_usuario(:login => nil)
      assigns[:usuario].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(Usuario, :count)
  end
  
  it 'requires password on signup' do
    lambda do
      create_usuario(:password => nil)
      assigns[:usuario].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(Usuario, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_usuario(:password_confirmation => nil)
      assigns[:usuario].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(Usuario, :count)
  end
   
  def create_usuario(options = {})
    funcionario = Pessoa.new :nome => "Carlos", :cpf => "723.455.906-02", :funcionario => true,
    :endereco => "Av. das Torres", :bairro => "Jardim das Américas", :tipo_pessoa => Pessoa::FISICA,
    :telefone => ["3090-9090"], :entidade_id => entidades(:senai).id, :unidade_id => unidades(:senaivarzeagrande).id
    funcionario.save!
    post :create, :usuario => { :login => 'quire', :password => 'quire69',
      :password_confirmation => 'quire69', :perfil_id => perfis(:master_main).id,
      :unidade_id => unidades(:senaivarzeagrande).id, :funcionario_id => funcionario.id}.merge(options)
  end
  
  describe "verifica se" do
     
    integrate_views
    
    it "esta filtrando somente usuarios da mesma unidade" do

      login_as :quentin

      get :index

      response.should be_success
      response.should render_template('index')
      response.should have_tag("table[class = ?]","listagem") do
      response.should_not have_tag("a[href = ?]",new_usuario_path)  # NÃO PODE EXISTIR O LINK NO INDEX DE USUÁRIOS, POIS O USUÁRIO E CADASTRADO PELO SHOW DE PESSOAS
        with_tag("tr[class = ?]",'impar') do
          with_tag("td") do
            with_tag("a[href = ?]",'/usuarios/1','quentin')
          end
          with_tag("td",'quentin')
          with_tag("td",'Felipe Giotto')
          with_tag("td[class = ?]",'ultima_coluna') do
            response.should_not have_tag("a[href = ?]",'/usuarios/3/edit')
            response.should_not have_tag("a[href = ?][onclick*=?]",'/usuarios/3','exclusão')
          end
        end
        with_tag("tr[class = ?]",'par') do
          with_tag("td") do
            with_tag("a[href = ?]",'/usuarios/2','aaron')
          end
          with_tag("td",'aaron')
          with_tag("td",'Juan Vitor Zeferino')
          with_tag("td[class = ?]",'ultima_coluna') do
            response.should_not have_tag("a[href = ?]",'/usuarios/4/edit')
            response.should_not have_tag("a[href = ?][onclick*=?]",'/usuarios/4','exclusão')
          end
        end
        with_tag("tr[class = ?]",'impar') do
          with_tag("td") do
            with_tag("a[href = ?]",'/usuarios/5','juvenal')
          end
          with_tag("td",'juvenal')
          with_tag("td",'Rafael Koch')
          with_tag("td[class = ?]",'ultima_coluna') do
            response.should_not have_tag("a[href = ?]",'/usuarios/4/edit')
            response.should_not have_tag("a[href = ?][onclick*=?]",'/usuarios/4','exclusão')
          end
        end
      end
    end

    it "se esta atualizando o usuario de unidade diferente" do
      login_as :admin
      put :update, :usuario => {:login => 'teste'}, :id => 1
      response.should redirect_to(login_path)
    end 
    
    it "Verifica se usuario possui permissao para acessar o model Usuario" do
      login_as :quentin
      id = pessoas(:felipe).id
      get :new, :usuario => {:funcionario_id => id}
      response.should be_success
      response.should have_tag("tr") do
        with_tag("input[id=?][type=?][value=?][name=?]","usuario_funcionario_id", "hidden", id, "usuario[funcionario_id]")
      end
      response.should have_tag("tr") do
        with_tag("td") do
          with_tag("select[name=?]","usuario[perfil_id]")do
            with_tag("option[value=?]",1,"Master")
            with_tag("option[value=?]",2,"Gerente")
            with_tag("option[value=?]",3,"Operador Financeiro")
            with_tag("option[value=?]",4,"Operador CR")
            with_tag("option[value=?]",5,"Operador CP")
            with_tag("option[value=?]",6,"Consulta")
            with_tag("option[value=?]",7,"Contador")
          end
        end
      end      
    end
    
    it "Verifica se usuario juvenal não possui permissao para acessar o model Usuario" do
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
    
    it "o usuario admin não possui permissao para acessar o model Usuario" do
      login_as :admin
      usuario = usuarios(:admin)
      get :edit, :id => usuario.id
      response.should redirect_to(login_path)
    end

    it "o funcionario vem preenchido corretamente" do
      login_as :quentin
      usuario = usuarios(:quentin)
      get :edit, :id => usuario.id, :usuario => {:funcionario_id => usuario.funcionario_id}
      response.should be_success
      response.should have_tag("tr") do
        with_tag("input[id=?][type=?][name=?][value=?]","usuario_funcionario_id", "hidden", "usuario[funcionario_id]", usuario.funcionario_id)
      end
    end

    it "o funcionario não vem preenchido" do
      login_as :quentin
      usuario = usuarios(:quentin)
      usuario.funcionario_id = nil
      put :update, :id => usuario.id, :usuario => {:funcionario_id => usuario.funcionario_id}
      response.should render_template('edit')
      response.should have_tag("ul") do
        with_tag("li", "Funcionario deve ser preenchido.")
      end
      response.should have_tag("tr") do
        with_tag("input[id=?][type=?][name=?]","usuario_funcionario_id", "hidden", "usuario[funcionario_id]")
      end
    end

    it "alteracao foi feita com sucesso" do
      login_as :quentin
      usuario = usuarios(:quentin)
      put :update, :id => usuario.id, :usuario => {:funcionario_id => usuario.funcionario_id}
      response.should be_redirect
      response.should redirect_to(usuarios_path)
    end

  end

  it 'logado como quentin porem grava a unidade senai' do
    login_as :quentin
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id

    funcionario = Pessoa.new :nome => "Carlos", :cpf => "723.455.906-02", :funcionario => true,
    :endereco => "Av. das Torres", :bairro => "Jardim das Américas", :tipo_pessoa => Pessoa::FISICA,
    :telefone => ["3090-9090"], :entidade_id => entidades(:senai).id, :unidade_id => unidades(:senaivarzeagrande).id
    funcionario.save!

    post :create, :usuario => { :login => 'quire', :password => 'quire69',
      :password_confirmation => 'quire69', :perfil_id => perfis(:master_main).id,
      :unidade_id => unidades(:senaivarzeagrande).id, :funcionario_id => funcionario.id}

    assigns[:usuario].unidade_id.should == unidades(:sesivarzeagrande).id
  end

  it 'testa alterar_senha correto' do
    login_as :quentin
    usuario_em_questao = usuarios(:quentin)

    post :alterar_senha, :id => usuario_em_questao.id.to_s, :usuario => {:antiga_senha => 'monkey', :password => 'legalal', :password_confirmation => 'legalal'}
    response.should be_redirect

    request.session[:flash][:notice].should == "Senha alterada com sucesso!"
  end

  it 'testa alterar_senha com password confirmation diferente' do
    login_as :quentin
    usuario_em_questao = usuarios(:quentin)

    post :alterar_senha, :id => usuario_em_questao.id.to_s, :usuario => {:antiga_senha => 'monkey', :password => 'legalal', :password_confirmation => 'ruimuim'}
    response.should render_template('carrega_form_alterar_senha')

    request.session[:flash][:notice].should == "O campo senha e confirmação de senha devem ser iguais e não nulos!"
  end

  it 'testa alterar_senha com password confirmation com antiga_senha diferente' do
    login_as :quentin
    usuario_em_questao = usuarios(:quentin)

    post :alterar_senha, :id => usuario_em_questao.id.to_s, :usuario => {:antiga_senha => 'monkeyoi', :password => 'legalal', :password_confirmation => 'legalal'}
    response.should render_template('carrega_form_alterar_senha')

    request.session[:flash][:notice].should == 'O campo senha atual está incorreto!'
  end

  it 'testa alterar_senha com password confirmation com id diferente' do
    login_as :quentin
    usuario_em_questao = usuarios(:quentin)

    post :alterar_senha, :id => usuarios(:juvenal).id, :usuario => {:antiga_senha => 'monkey', :password => 'legalal', :password_confirmation => 'legalal'}
    response.should be_redirect

    request.session[:flash][:notice].should == "Não foi possível alterar!"
  end

  it 'testa carrega_form_alterar_senha' do
    login_as :quentin

    get :carrega_form_alterar_senha, :id => usuarios(:quentin).id.to_s
    response.should be_success

    assigns[:usuario].id.should == usuarios(:quentin).id
  end

  it 'testa carrega_form_alterar_senha passando um id diferente do da sessão' do
    login_as :quentin

    get :carrega_form_alterar_senha, :id => usuarios(:juvenal).id.to_s
    response.should be_redirect
  end

end
