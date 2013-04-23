require File.dirname(__FILE__) + '/../spec_helper'

describe PessoasController do
  integrate_views

  before do
    login_as 'quentin'
  end
  
  def mock_pessoa
    mock_model(Pessoa,:novo_banco => 'Bradesco',:complemento=>'casa',:spc=>'false',:matricula=>'xxx',:cargo=>'x',:novo_cargo=>'x',:funcionario_ativo=>'true', :nome => 'Inovare', :cliente => 'true', :fornecedor => 'true', :funcionario =>'true',:razao_social =>'Inovare',:contato => 'Roberval', :tipo_pessoa => '1', :endereco => 'Marechal Floriano', :localidade_id=> 1 ,:nome_localidade=>"CUIABA - MT" ,:email => ['pv_cmt@hotmail.com'], :telefone => ['33425712'], :cpf=> '06512424956',:label_do_campo_cpf_cnpj =>'CPF',:label_do_campo_rg_ie =>'RG',:label_nome_ou_nome_fantasia=>'Inovare' ,:rg_ie => '73499887', :agencia => '123',:bairro =>'Agua Verde',:cidade =>'Curitiba',:cep => '80', :banco =>'BB',:conta=>'123', :tipo_pessoa=>'1', :cpf_cnpj=>'123456', :observacoes => 'legal')
  end

  it "realiza busca de pessoas" do
    get :index, :busca => {:conteudo => 'a', :filtro => {:cliente => 'cliente'}}
  end
  
  it "possui action index" do
    get :index 
    response.should be_success
  end

  def valida_campos_do_form
    with_tag("input[name='pessoa[cliente]']")
    with_tag("input[name='pessoa[funcionario]']")
    with_tag("input[name='pessoa[fornecedor]']")
    with_tag("select[name='pessoa[banco_id]']")
    with_tag("select[name='pessoa[cargo]']")
    with_tag("input[name='pessoa[novo_cargo]']")
    with_tag("input[name='pessoa[email][]']")
    with_tag("input[name='pessoa[complemento]']")
    with_tag("input[name='pessoa[nome]']")
    with_tag("div[id='pessoa_nome_localidade_auto_complete']")
    with_tag("input[name='pessoa[telefone][]']")
    with_tag("select[name='pessoa[industriario]']") do
      with_tag 'option[value=false]', 'NÃO'
      with_tag 'option[value=true]', 'SIM'
    end
  end

  it "action index carregando dados do banco de dados" do
    get :index
    response.should be_success 
    response.should have_tag("form[action=?][method=get]",pessoas_path) do
      with_tag("input[name=?][onfocus=?][onblur=?]","busca[conteudo]","exibir_explicacao_para_busca('exibir','Você pode fazer uma busca digitando campos como CPF, CNPJ, razão social, nome ou contato. A digitação dos mesmos pode ser parcial, pois a busca retornará os resultados de acordo com os dados digitados.')" ,"exibir_explicacao_para_busca('ocultar','')")
      with_tag("input[name=?]","busca[filtro][cliente]")
      with_tag("input[name=?]","busca[filtro][fornecedor]")
      with_tag("input[name=?]","busca[tipo][pessoa_fisica]")
      with_tag("input[name=?]","busca[tipo][pessoa_juridica]")
      with_tag("input[type = submit]")
      with_tag("div[class=?]","div_explicativa") do
        with_tag("div[class=?]","explicacao_busca") do
          with_tag("div[id=?]","explicacao_texto")
        end
      end
    end
    with_tag("table[class=?]","listagem") do
      with_tag("tr[class=?]","impar")
      with_tag("tr[class=?]","par")
      with_tag("tr[class=?]","fundo_vermelho")
    end
  end

  it "possui action show" do
    get :show, :id => pessoas(:paulo).id
    assigns[:pessoa].should == pessoas(:paulo)
    assigns[:dependentes].should == pessoas(:paulo).dependentes
    response.should_not have_tag("a[href=?]", usuario_path(usuarios(:aaron).id))
    response.should have_tag("table[class=?]","listagem")    
  end

  it "teste da view show" do
    get :show, :id => pessoas(:inovare).id
    assigns[:pessoa].should == pessoas(:inovare)
    assigns[:dependentes].should == []
    response.should_not have_tag("table[class=?]","listagem")
  end

  it "teste da view show com link de usuarios" do
    get :show, :id => pessoas(:felipe).id
    assigns[:pessoa].should == pessoas(:felipe)
    assigns[:dependentes].should == []
    response.should have_tag("a[href=?]", usuario_path(usuarios(:quentin).id))
    response.should_not have_tag("table[class=?]","listagem")
  end

  it "possui action new?" do
    pessoa = Pessoa.new
    Pessoa.should_receive(:new).and_return pessoa
    get :new
    response.should be_success
  end  
  
  
  it "conseguiu deletar" do
    login_as :quentin
    PagamentoDeConta.delete_all
    RecebimentoDeConta.delete_all
    pessoa = pessoas(:paulo)
    delete :destroy, :id => pessoa.id
    response.should redirect_to(pessoas_path)
  end
  
  it "não conseguiu deletar" do
    login_as :quentin
    pessoa = pessoas(:paulo)
    delete :destroy, :id => pessoa.id
    flash[:notice].should  ==  "Não foi possível excluir a pessoa #{pessoa.nome}, pois esta possui contas/lançamentos simples vinculadas."
    response.should redirect_to(pessoas_path)
  end
  

  it "testando a view new" do
    get :new
    response.should be_success
    
    
    response.should have_tag("form[method=post][action=?]",pessoas_path) do
      valida_campos_do_form
      with_tag("input[name='pessoa[data_nascimento]']")
      with_tag("input[id=?][onchange=?]","pessoa_cpf",%r{new Ajax.Request.*\/pessoas.*\/verifica_se_existe.*})
    end
  end
  
  it "conseguiu gravar uma pessoa?" do
    pessoa = mock_model(Pessoa, :nome => 'Inovare', :tipo_pessoa=>'2', :cnpj=>'08916988000145')
    Pessoa.should_receive(:new).with('nome' => 'Inovare', 'tipo_pessoa'=>'2','cnpj'=>'08916988000145').and_return pessoa
    pessoa.should_receive(:entidade_id=).and_return(entidades(:senai).id)
    pessoa.should_receive(:unidade_id=).and_return(unidades(:senaivarzeagrande).id)
    pessoa.should_receive(:save).and_return true
    post :create, {:pessoa => {:nome => 'Inovare', :tipo_pessoa=>'2', :cnpj=>'08916988000145'}}
    response.should redirect_to(pessoa_path(pessoa.id))
  end
  
  it "nao conseguiu gravar uma pessoa?" do
    post :create, :pessoa => {}
    assigns[:pessoa].entidade_id = entidades(:senai).id
    response.should render_template('new') 
  end
   
  it "possui a action edit?" do
    pessoa = pessoas(:paulo)
    get :edit , :id => pessoa.id
    assigns[:pessoa].should == pessoa
    #Testando a view
    response.should have_tag("form[action=?][method=post]",pessoa_path(pessoa)) do
      with_tag("input[name='_method'][value='put']")
      valida_campos_do_form
      with_tag("input[name='pessoa[data_nascimento]'][value=?]", pessoa.data_nascimento)
    end
  end


  describe "Action verifica_se_existe_cpf_cnpj" do
  
    it "call action verifica_se_existe_cpf_cnpj" do
      post :verifica_se_existe_cpf_cnpj,:documento=>"06512424956",:id=>"",:tipo_de_documento=>"cpf"
      response.should be_success
      assigns[:pessoas].should == [pessoas(:paulo)]
      response.body.should include("confirm")
      response.body.should include("/pessoas/#{pessoas(:paulo).id}/edit")
    end
    
    it "call action verifica_se_existe_cpf_cnpj passando cpf com mascara" do
      post :verifica_se_existe_cpf_cnpj,:documento=>"065.124.249-56",:id=>"",:tipo_de_documento=>"cpf"
      response.should be_success
      assigns[:pessoas].should == [pessoas(:paulo)]
      response.body.should include("confirm")
      response.body.should include("/pessoas/#{pessoas(:paulo).id}/edit")
    end
  
    it "call action verifica_se_existe_cpf_cnpj e não pode retornar nada" do
      post :verifica_se_existe_cpf_cnpj,:documento=>"06512424956",:id=>pessoas(:paulo).id,:tipo_de_documento=>"cpf"
      response.should be_success
      assigns[:pessoas].should == []
      response.body.should_not include("confirm")
    end
  
    it "call action verifica_se_existe_cpf_cnpj e não pode retornar nada" do
      post :verifica_se_existe_cpf_cnpj,:documento=>"065.124.249-56",:id=>pessoas(:paulo).id,:tipo_de_documento=>"cpf"
      response.should be_success
      assigns[:pessoas].should == []
      response.body.should_not include("confirm")
    end
  
  end

  it 'deve ter auto_complete para funcionario' do
    login_as :quentin
    post :auto_complete_for_funcionario, :argumento => 'felipe'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li[id=?]', pessoas(:felipe).id, 'Felipe Giotto'
    end
  end

  it 'deve ter auto_complete para funcionario com temina_em' do
    login_as :quentin
    post :auto_complete_for_funcionario, :argumento => '*felipe'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it 'deve ter auto_complete para funcionario nao deve retornar quem nao seja funcionario' do
    login_as :quentin
    post :auto_complete_for_funcionario, :argumento => 'paulo'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it 'deve ter auto_complete para cliente' do
    login_as :quentin
    post :auto_complete_for_cliente, :argumento => 'paulo'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li', "065.124.249-56 - Paulo Vitor Zeferino"
    end
  end

  it 'deve ter auto_complete para cliente com termina_em' do
    login_as :quentin
    post :auto_complete_for_cliente, :argumento => '*paulo'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it 'deve somente retornar clientes' do
    login_as :quentin
    post :auto_complete_for_cliente, :argumento => 'felipe'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end
  
  it "deve ter auto_complete para fornecedor passando INOVARE" do
    login_as :quentin
    post :auto_complete_for_fornecedor, :argumento => 'inovare'
    response.should be_success
    
    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li', "FTG Tecnologia"
    end
  end

  it 'deve ter auto_complete para fornecedor passando INOVARE' do
    login_as :quentin
    post :auto_complete_for_fornecedor, :argumento => 'inovare'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li', "FTG Tecnologia"
    end
  end

  it 'deve ter auto_complete para fornecedor passando FTG' do
    login_as :quentin
    post :auto_complete_for_fornecedor, :argumento => 'ftg'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li', "FTG Tecnologia"
    end
  end
  
  it 'deve ter auto_complete para fornecedor com termina_em' do
    login_as :quentin
    post :auto_complete_for_fornecedor, :argumento => '*felipe'
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it 'deve ter auto_complete para dependente' do
    login_as :quentin
    post :auto_complete_for_dependente, :argumento => 'joao', :cliente_id => pessoas(:paulo).id
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 1
      with_tag 'li[id=?]', dependentes(:dependente_paulo_primeiro).id, 'Joao'
    end
  end

  it 'deve ter auto_complete para dependente com termina_em' do
    login_as :quentin
    post :auto_complete_for_dependente, :argumento => '*joa', :cliente_id => pessoas(:paulo).id
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it 'deve ter auto_complete para dependente' do
    login_as :quentin
    post :auto_complete_for_dependente, :argumento => 'joao', :cliente_id => pessoas(:felipe).id
    response.should be_success

    response.should have_tag('ul') do
      with_tag 'li', 0
    end
  end

  it "testa auto_complete de pessoa passando 'pau' " do
    post :auto_complete_for_pessoa , :argumento=>'pau'
    response.should be_success
    response.should have_tag("ul") do
      with_tag("li[id=?]", pessoas(:paulo).id,"065.124.249-56 - Paulo Vitor Zeferino")
    end
  end

  it "testa auto_complete de pessoa com termina_em " do
    post :auto_complete_for_pessoa , :argumento=>'*paul'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 0
    end
  end

  it "testa auto_complete de pessoa passando 'p' " do
    post :auto_complete_for_pessoa , :argumento=>'p'
    response.should be_success
    response.should have_tag("ul") do
      with_tag("li[id=?]", pessoas(:paulo).id,"065.124.249-56 - Paulo Vitor Zeferino")
      with_tag("li[id=?]", pessoas(:felipe).id,"031.464.089-45 - Felipe Giotto")
    end
  end


  it "testa auto_complete de pessoa passando '06512424956' " do
    post :auto_complete_for_pessoa , :argumento=>'065.124.249-56'
    response.should be_success
    response.should have_tag("ul") do
      with_tag("li[id=?]", pessoas(:paulo).id,"065.124.249-56 - Paulo Vitor Zeferino")
    end
  end

  it "testa auto_complete de pessoa passando 'ftg' " do
    post :auto_complete_for_pessoa , :argumento=>'ftg'
    response.should be_success
    response.should have_tag("ul") do
      with_tag("li[id=?]", pessoas(:inovare).id,"08.916.988/0001-45 - FTG Tecnologia")
    end
  end

  it "testa auto_complete de pessoa passando '069' " do
    post :auto_complete_for_pessoa , :argumento=>'069'
    response.should be_success
    response.should have_tag("ul") do
      with_tag("li[id=?]", pessoas(:juan).id,"069.868.929-18 - Juan Vitor Zeferino")
    end
  end

  describe "Verifica se" do
    
    it "bloqueia o usuario juvenal tentando acessar o model Pessoas action new" do
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
    
    it "bloqueia o usuario juvenal tentando acessar o model Pessoas action edit" do
      login_as :juvenal
      pessoa = pessoas(:paulo)
      get :edit, :id => pessoa.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia o usuario juvenal tentando acessar o model Pessoas action destroy" do
      login_as :juvenal
      pessoa = pessoas(:paulo)
      delete :destroy, :id => pessoa.id
      response.should redirect_to(login_path)
    end
    
  end

  it "teste da view show com link de usuarios logado como quentin" do
    login_as :quentin
    get :show, :id => pessoas(:jansen).id
    assigns[:pessoa].should == pessoas(:jansen)
    response.should have_tag("a[href=?]", new_usuario_path(:usuario => {:funcionario_id => pessoas(:jansen).id}))
  end

  it "teste da view show com link de usuarios logado com usuario sem permissao para criar usuario" do
    login_as :old_password_holder
    get :show, :id => pessoas(:jansen).id
    assigns[:pessoa].should == pessoas(:jansen)
    response.should_not have_tag("a[href=?]", new_usuario_path(:usuario => {:funcionario_id => pessoas(:jansen).id}))
  end

  describe 'Filtrar por entidade' do

    it 'a action index de pessoas do SESI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:pessoas].should == [pessoas(:andre, :fornecedor, :fabio, :inovare, :guilherme, :jansen, :juan, :julio, :paulo, :rafael), true]

    end

    it 'a action index de pessoas do SENAI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id

      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:pessoas].should == [pessoas(:andre, :fornecedor, :fabio, :inovare, :guilherme, :jansen, :juan, :julio, :paulo, :rafael), true]
    end

    it 'a action edit' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :edit, :id => pessoas(:felipe).id
      response.should redirect_to(login_path)
    end

    it 'a action show' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :show, :id => pessoas(:felipe).id
      response.should redirect_to(login_path)
    end

    it 'a action destroy' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      delete :destroy, :id => pessoas(:felipe).id
      response.should redirect_to(login_path)
    end

    it 'a action update' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      put :update, :id => pessoas(:felipe).id
      response.should redirect_to(login_path)
    end

    it "auto complete de pessoas passando 'p' pesquisando na unidade incorreta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_pessoa, :argumento => 'p'
      response.should be_success
      assigns[:items].should == [pessoas(:felipe), pessoas(:paulo), pessoas(:julio)]
    end

    it "auto complete de clientes passando 'p' pesquisando na unidade incorreta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_cliente, :argumento => 'p'
      response.should be_success
      assigns[:pessoas].should == [pessoas(:paulo), pessoas(:julio)]
    end

    it "auto complete de funcionario passando 'p' pesquisando na unidade incorreta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_funcionario, :argumento => 'p'
      response.should be_success
      assigns[:pessoas].should == []
    end

    it "auto complete de dependente passando 'p' pesquisando na unidade incorreta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_dependente, :argumento => 'j', :cliente_id => pessoas(:paulo).id
      response.should be_success
      assigns[:pessoas].should == [dependentes(:dependente_paulo_primeiro)]
    end

    it "auto complete de fornecedores passando 'i' pesquisando na unidade incorreta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      post :auto_complete_for_fornecedor, :argumento => 'i'
      response.should be_success
      assigns[:pessoas].should == [pessoas(:inovare), pessoas(:fornecedor)]
    end

    it "auto complete de fornecedores passando 'i' pesquisando na unidade correta" do
      login_as :quentin
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id

      post :auto_complete_for_fornecedor, :argumento => 'i'
      response.should be_success
      assigns[:pessoas].should == [pessoas(:inovare), pessoas(:fornecedor)]
    end

  end

  describe 'acesso a action update_liberado_pelo_dr' do
    it 'como quentin' do
      pessoa = pessoas(:jansen)
      Pessoa.find(pessoa.id).liberado_pelo_dr.should be_false
      post :update_liberado_pelo_dr, :id=>pessoa.id
      response.should be_success
      response.body.should match(%r{^Element.update\("situacao_dr", "<a href=\\"#\\" onclick=\\"new Ajax.Request\('\/pessoas\/update_liberado_pelo_dr\/\d+',.*parameters:'id=\d+'.*>Clique aqui para Restringir esse Cliente<\/a>"\);$})
      Pessoa.find(pessoa.id).liberado_pelo_dr.should be_true
      post :update_liberado_pelo_dr, :id=>pessoa.id
      response.should be_success
      response.body.should match(%r{^Element.update\("situacao_dr", "<a href=\\"#\\" onclick=\\"new Ajax.Request\('\/pessoas\/update_liberado_pelo_dr\/\d+',.*parameters:'id=\d+'.*>Clique aqui para Liberar esse Cliente<\/a>"\);$})
      Pessoa.find(pessoa.id).liberado_pelo_dr.should be_false
    end

    it 'como aaron' do
      login_as :aaron
      pessoa = pessoas(:jansen)
      Pessoa.find(pessoa.id).liberado_pelo_dr.should be_false
      post :update_liberado_pelo_dr, :id=>pessoa.id
      response.should redirect_to(login_path)
      Pessoa.find(pessoa.id).liberado_pelo_dr.should be_false
    end
  end

  describe 'vendo o link de mudanca de situacao' do
    it 'como quentin' do
      pessoa_id = pessoas(:jansen).id
      get :show, :id => pessoa_id
      response.should be_success
      response.body.should match(%r{<a href="#" onclick="new Ajax\.Request\('\/pessoas\/update_liberado_pelo_dr',.*parameters:'id=\d+'\}\).*>Clique aqui para Liberar esse Cliente<\/a>})
      post :update_liberado_pelo_dr, :id=>pessoa_id
      get :show, :id => pessoa_id
      response.should be_success
      response.body.should match(%r{<a href="#" onclick="new Ajax\.Request\('\/pessoas\/update_liberado_pelo_dr',.*parameters:'id=\d+'\}\).*>Clique aqui para Restringir esse Cliente<\/a>})
    end

    it 'como aaron' do
      login_as :aaron
      get :show, :id => pessoas(:jansen).id
      response.should be_success
      response.body.should_not match(%r{<a href="#" onclick="new Ajax\.Request\('\/pessoas\/update_liberado_pelo_dr',.*paramete})
    end
  end

end