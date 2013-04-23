require File.dirname(__FILE__) + '/../spec_helper'

describe ServicosController do
  
  integrate_views
  
  def mock_servico
    mock_model(Servico,:descricao=>"teste",:ativo=>"true",:modalidade=>"x", :unidade_id => unidades(:senaivarzeagrande).id,:novo_modalidade=>'x',:codigo_do_servico_sigat=>"800")
  end
  
  def valida_form

    with_tag("input[name='servico[descricao]']")
    with_tag("input[name='servico[ativo]']")
    with_tag("input[name='servico[codigo_do_servico_sigat]']")
  end

  it "teste action index" do
    login_as :quentin
    servicos = servicos(:curso_de_corel, :curso_de_eletronica, :curso_de_design, :curso_de_tecnologia)
    get :index
    assigns[:servicos].should == servicos
    response.should have_tag("table.listagem") do
      with_tag("tr[class=?]",'impar') do
        with_tag("td") do
          with_tag("a[href=?]",'/servicos/7491444','Curso de Corel Draw')
        end
        with_tag("td",'Ensino')
        with_tag("td[class=?]",'ultima_coluna') do
          with_tag("a[href=?]",'/servicos/7491444/edit')
        end
      end  
      with_tag("tr[class=?]",'par') do
        with_tag("td") do
          with_tag("a[href=?]",'/servicos/28468706','Curso de Ruby on Rails')
        end
        with_tag("td",'Ensino')
        with_tag("td[class=?]",'ultima_coluna') do
          with_tag("a[href=?]",'/servicos/28468706/edit')
        end
      end
      with_tag("tr[class=?]",'impar') do
        with_tag("td") do
          with_tag("a[href=?]",'/servicos/684790155','Curso de Flex')
        end
        with_tag("td",'Ensino')
        with_tag("td[class=?]",'ultima_coluna') do
          with_tag("a[href=?]",'/servicos/684790155/edit')
        end
      end
      with_tag("tr[class=?]",'par') do
        with_tag("td") do
          with_tag("a[href=?]",'/servicos/194750728','Curso de Eletronica Digital')
        end
        with_tag("td",'Ensino')
        with_tag("td[class=?]",'ultima_coluna') do
          with_tag("a[href=?]",'/servicos/194750728/edit')
        end
      end
    end
  end

  
  it "possui action show" do
    login_as :quentin
    servico = servicos(:curso_de_tecnologia)
    get :show, :id => servico.id
    assigns[:servico].should == servico
  end
    
  it "possui action new?" do
    login_as :quentin
    servico = mock_servico
    Servico.should_receive(:new).and_return servico
    get :new
    response.should be_success
  end 
  
  it "testando a view new" do
    login_as :quentin
    get :new
    response.should be_success
    #Testando a view new
    response.should have_tag("form[method=post][action=?]",servicos_path) do
      valida_form
    end

  end
  
  it "conseguiu gravar um banco?" do
    login_as :quentin
    servico = mock_servico
    Servico.should_receive(:new).with('descricao'=>"teste",'ativo'=>"true",'modalidade'=>"x",'novo_modalidade'=>'x','codigo_do_servico_sigat'=>"800").and_return servico
    servico.should_receive(:unidade_id=).with(unidades(:senaivarzeagrande).id)
    servico.should_receive(:save).and_return true
    post :create, {:servico => {'descricao'=>"teste",'ativo'=>"true",'modalidade'=>"x",'novo_modalidade'=>'x','codigo_do_servico_sigat'=>"800"}}
    response.should redirect_to(servicos_path)
  end  
 
  it "nao conseguiu gravar um banco!" do
    login_as :quentin
    servico = mock_servico
    Servico.should_receive(:new).with('descricao'=>"",'ativo'=>"true",'modalidade'=>"x",'novo_modalidade'=>'x','codigo_do_servico_sigat'=>"800").and_return servico
    servico.should_receive(:unidade_id=).with(unidades(:senaivarzeagrande).id)
    servico.should_receive(:save).and_return false
    post :create, {:servico => {'descricao'=>"",'ativo'=>"true",'modalidade'=>"x",'novo_modalidade'=>'x','codigo_do_servico_sigat'=>"800"}}
    response.should render_template("new")
  end    
  
  it "possui a action edit?" do
    login_as :quentin
    servico = servicos(:curso_de_tecnologia)
    get :edit , :id => servico
    # Teste da  view
    response.should have_tag("form[action=?][method=post]",servico_path(servico.id)) do
      with_tag("input[name='_method'][value='put']")
      valida_form
    end
  end
  
  it "conseguiu fazer update?" do
    login_as :quentin
    put :update, :servico => {:descricao => 'Teste'}, :id => servicos(:curso_de_tecnologia).id
    assigns(:servico).should == Servico.find(servicos(:curso_de_tecnologia).id)
    response.should redirect_to(servicos_path)
  end
 
  it "conseguiu deletar" do
    login_as :quentin
    servico = mock_servico
    Servico.should_receive(:find).with('1').and_return servico
    servico.should_receive(:destroy).and_return true
    delete :destroy, :id => 1
    response.should redirect_to(servicos_path)
  end
  
  it "Testa se chama a action Index sem estar logado" do
    get :index
    response.should redirect_to(new_sessao_path)
  end
  
  it "se esta atualizando o servico de unidade diferente" do
    login_as :admin
    put :update, :servico => {:descricao => 'teste'}, :id => servicos(:curso_de_tecnologia).id
    response.should redirect_to("/login")
  end

  it 'deve ter auto_complete para servico' do
    login_as :quentin
    post :auto_complete_for_servico, :argumento => 'flex'
    response.should be_success
    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li[id=?]', servicos(:curso_de_design).id, 'Curso de Flex'
    end
  end

  it 'deve ter auto_complete para servico com termina_em' do
    login_as :quentin
    post :auto_complete_for_servico, :argumento => '*curso'
    response.should be_success
    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it 'deve ter auto_complete para servico filtrando por unidade' do
    usuarios(:quentin).unidade_id = unidades(:sesivarzeagrande).id
    usuarios(:quentin).save!
    login_as :quentin
    post :auto_complete_for_servico, :argumento => 'flex'
    response.should be_success
    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end
  
  it 'deve ter auto_complete para modalidade' do
    login_as :quentin
    post :auto_complete_for_modalidade, :argumento => 'ensino'
    response.should be_success
    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li', 'Ensino'
    end
  end

  it 'deve ter auto_complete para modalidade' do
    login_as :quentin
    post :auto_complete_for_modalidade, :argumento => 'invalido'
    response.should be_success
    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it "deve prorrogar um contrato depois de atualizar data de inicio de vigência do contrato" do
    login_as :quentin
    get :prorrogar
    response.should render_template('prorrogar')
    #TESTE DA VIEW
    response.should have_tag('form[action=?]',prorrogar_servicos_path) do
      with_tag('input[name=?]','busca[nome_servico]')
      with_tag('input[name=?]','busca[servico_id]')
      with_tag('script',%r{Ajax.Autocompleter.*busca_nome_servico.*\/servicos\/auto_complete_for_servico.*})
      with_tag('input[name=?]','busca[data_max]')
      with_tag('input[name=?]','busca[data_min]')
      with_tag("input[name=?][type=?][value=?]","commit","submit","Pesquisar")
    end
  end
     
  it "não deve prorrogar um contrato se usuario não possuir permissão" do
    login_as :juvenal
    get :prorrogar
    response.should redirect_to(login_path)
  end

  it "deve gravar os dados de prorrogação de contrato que pertencem a uma mesma unidade e ao mesmo ano quando o usuario possui acesso" do
    login_as :quentin
    request.session[:ano] = "2009"
    post :gravar_dados_de_prorrogacao_de_contrato, :recebimento_de_conta=>{:vigencia=>12, :nome_servico=>"Curso de Corel Draw", :servico_id=> servicos(:curso_de_corel).id, :data_inicio=>"18/06/2009"}, :justificativa => "Pedido prorrogado por solicitação da diretoria.", :ids => [recebimento_de_contas(:curso_de_corel_do_paulo)]
    response.should be_success
  end

  it "não deve gravar os dados de prorrogação de contrato que pertencem a uma mesma unidade e ao mesmo ano quando o usuario não possuir permissão" do
    login_as :juvenal
    post :gravar_dados_de_prorrogacao_de_contrato, :recebimento_de_conta=>{:vigencia=>12, :nome_servico=>"Curso de Corel Draw", :servico_id=> servicos(:curso_de_corel).id, :data_inicio=>"18/06/2009"}, :justificativa => "Pedido prorrogado por solicitação da diretoria."
    response.should redirect_to(login_path)
  end

  it "não deve gravar os dados de prorrogação de contrato que pertencem a uma mesma unidade e ao mesmo ano" do
    login_as :quentin
    post :gravar_dados_de_prorrogacao_de_contrato, :recebimento_de_conta=>{:vigencia=>'', :nome_servico=>"Curso de Corel Draw", :servico_id=> servicos(:curso_de_corel).id, :data_inicio=>"18/06/2009"}, :justificativa => "Pedido prorrogado por solicitação da diretoria.", :ids => [recebimento_de_contas(:curso_de_corel_do_paulo)]
    response.should be_success
  end
    
  describe "Verifica se" do
  
    it "bloqueia usuario juvenal que não possui acesso ao model Servico action new" do
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin que nao possui acesso ao model Servico action edit" do
      login_as :admin
      servico = servicos(:curso_de_tecnologia)
      get :edit, :id=>servico.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin que não possui acesso ao model Servico action destroy" do
      login_as :admin
      servico = servicos(:curso_de_tecnologia)
      delete :destroy, :id=>servico.id
      response.should redirect_to(login_path)
    end
    
  end

  describe "Teste de bloqueio das actions caso o serviço não seja da Unidade logada" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      @servico = servicos(:curso_de_tecnologia)
    end

    after do
      assigns[:servico].should == @servico
      response.should redirect_to(login_path)
    end

    [:destroy, :update].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @servico
      end
    end

  end
  
end
