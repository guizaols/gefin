require File.dirname(__FILE__) + '/../spec_helper'

describe MovimentosController do
  
  integrate_views
  
  before do
    login_as 'quentin'
  end
  
  it 'should get index' do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id

    get :index
    response.should be_success
    response.should render_template('index')

    response.should have_tag('input[name=?]', 'data_lancamento')

    response.should have_tag('table.listagem') do
      with_tag('td', '31/03/2009')
      with_tag('td', 'Primeiro lançamento de entrada outra unidade')
      with_tag('td', 'Entrada')
    end
  end

  it 'should get index com data_lancamento preenchida' do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id

    get :index, :data_lancamento => "01/03/2009"
    response.should be_success
    response.should render_template('index')
    assigns[:movimentos].should == [movimentos(:primeiro_lancamento_entrada)]
  end

  it "should get show" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id

    get :show, :id => movimentos(:primeiro_lancamento_entrada).id
    response.should be_success
    response.should render_template('show')
    assigns[:movimento].id.should == movimentos(:primeiro_lancamento_entrada).id
  end

  it "deve redirecionar para a index de movimento se mudou de unidade dentro de uma show" do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id

    get :show, :id => movimentos(:primeiro_lancamento_entrada).id
    response.should_not be_success
    response.should redirect_to(movimentos_path)
  end

  it 'should get new' do
    get :new
    response.should be_success
    response.should render_template('new')
    response.should have_tag('form[action=?]', movimentos_path) do
      validar_campos_form
    end
  end

  def validar_campos_form
    response.should have_tag('input[name=?]', 'movimento[historico]')
    response.should have_tag('input[name=?]', 'movimento[data_lancamento]')
    response.should have_tag('select[name=?]', 'movimento[tipo_documento]')
    response.should have_tag('select[name=?]', 'movimento[tipo_lancamento]')
    response.should have_tag('input[name=?]', 'movimento[nome_pessoa]')
    response.should have_tag('input[name=?]', 'movimento[lancamento_simples][conta_contabil_id]')
    response.should have_tag('input[name=?]', 'movimento[lancamento_simples][conta_corrente_id]')
    response.should have_tag('input[name=?]', 'movimento[lancamento_simples][centro_id]')
    response.should have_tag('input[name=?]', 'movimento[lancamento_simples][unidade_organizacional_id]')
    response.should have_tag('input[name=?]', 'movimento[valor_do_documento_em_reais]')
    response.should have_tag('script',%r{'movimento_data_lancamento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
  end

  it 'should get edit' do
    get :edit, :id => movimentos(:primeiro_lancamento_entrada).id
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form[action=?]', movimento_path(movimentos(:primeiro_lancamento_entrada).id)) do
      validar_campos_form
    end
  end

  it 'should update valid object' do
    request.session[:ano] = 2009
    post :update, "id" => movimentos(:primeiro_lancamento_entrada).id, "movimento" => {"nome_pessoa" => "Juan Vitor Zeferino", "data_lancamento" => "21/08/2009", "historico" => "Primeiro lançamento de entrada mudado",
      "tipo_lancamento" => "E", "pessoa_id" => pessoas(:juan).id, "valor_do_documento_em_reais" => "100.00", "tipo_documento" => "CTREV",
      "lancamento_simples" => {"centro_nome"=> "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
        "conta_corrente_nome" => "34445-1 - Conta Caixa - SENAI-VG", "centro_id" => centros(:centro_forum_economico).id, "conta_contabil_nome" => "2101123456 - Impostos a Pagar",
        "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id, "conta_corrente_id" => contas_correntes(:conta_vazia).id,
        "conta_contabil_id" => plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}}
    response.should redirect_to(movimentos_path)
  end
  
  it 'should not update invalid object' do
    post :update, "id" => movimentos(:primeiro_lancamento_entrada).id, "movimento" => {"nome_pessoa" => "Juan Vitor Zeferino", "data_lancamento" => "21/08/2009", "historico" => "Primeiro lançamento de entrada mudado",
      "tipo_lancamento" => "E", "pessoa_id" => "", "valor_do_documento_em_reais" => "100.00", "tipo_documento" => "CTREV",
      "lancamento_simples" => {"centro_nome"=> "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
        "conta_corrente_nome" => "34445-1 - Conta Caixa - SENAI-VG", "centro_id" => centros(:centro_forum_economico).id, "conta_contabil_nome" => "2101123456 - Impostos a Pagar",
        "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id, "conta_corrente_id" => contas_correntes(:conta_vazia).id,
        "conta_contabil_id" => plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}}
    
    response.should render_template('edit')
  end

  it 'should create valid object' do
    movimento = mock_model(Movimento, :tipo_documento => 'CTREV', :tipo_lancamento => 'E', :data_lancamento => "8/04/2008", :historico => "Lançamento de 4 de abril", :valor_do_documento_em_reais => "100.00",
      :nome_pessoa => "0622512424956 - Juan Vitor Zeferino", :pessoa_id => pessoas(:juan).id, :lancamento_simples => { :unidade_organizacional_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
        :centro_id => centros(:centro_forum_social).id, :conta_contabil_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        :conta_corrente_id => contas_correntes(:segunda_conta).id, :conta_corrente_nome => "Conta Corrente",
        :conta_contabil_nome => "Conta Contabil", :unidade_organizacional_nome => "Unidade", :centro_nome => "Centro" })

    Movimento.should_receive(:new).with('tipo_documento' => 'CTREV', 'tipo_lancamento' => 'E', 'data_lancamento' => "8/04/2008", 'historico' => "Lançamento de 4 de abril", 'valor_do_documento_em_reais' => "100.00",
      'nome_pessoa' => "0622512424956 - Juan Vitor Zeferino", 'pessoa_id' => pessoas(:juan).id, 'lancamento_simples' => { 'unidade_organizacional_id' => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
        'centro_id' => centros(:centro_forum_social).id, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        'conta_corrente_id' => contas_correntes(:segunda_conta).id, 'conta_corrente_nome' => "Conta Corrente",
        'conta_contabil_nome' => "Conta Contabil", 'unidade_organizacional_nome' => "Unidade", 'centro_nome' => "Centro" }).and_return movimento

    # Funções testadas no model, caso ocorra alguma mudança mudar aqui também
    movimento.should_receive(:prepara_lancamento_simples)
    Movimento.should_receive(:lanca_contabilidade).and_return true
    
    post :create, :movimento => {:tipo_documento => 'CTREV', :tipo_lancamento => 'E', 
      :data_lancamento => "8/04/2008", :historico => "Lançamento de 4 de abril", :valor_do_documento_em_reais => "100.00", :nome_pessoa => "0622512424956 - Juan Vitor Zeferino", :pessoa_id => pessoas(:juan).id,
      :lancamento_simples => { :unidade_organizacional_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
        :centro_id => centros(:centro_forum_social).id, :conta_contabil_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        :conta_corrente_id => contas_correntes(:segunda_conta).id, :conta_corrente_nome => "Conta Corrente", 
        :conta_contabil_nome => "Conta Contabil", :unidade_organizacional_nome => "Unidade", :centro_nome => "Centro" } }
    response.should redirect_to(movimentos_path)
  end
  
  it 'should not create invalid object' do
    post :create, :movimento => {:valor_do_documento_em_reais => "", :lancamento_simples => {}}
    response.should render_template('new')
  end

  it 'valida que os campos não retornem em branco quando há erros de cadastro' do
    request.session[:ano] = 2009
    post :create, :movimento => {:tipo_documento => 'CTREV', :tipo_lancamento => 'E',
      :data_lancamento => "8/04/2008", :historico => "", :valor_do_documento_em_reais => "100.00", :nome_pessoa => "0622512424956 - Juan Vitor Zeferino", :pessoa_id => pessoas(:juan).id,
      :lancamento_simples => { :unidade_organizacional_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id, :unidade_organizacional_nome => "Unidade",
        :centro_id => centros(:centro_forum_social).id, :centro_nome => "Centro", :conta_contabil_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, :conta_contabil_nome => "Conta Contabil",
        :conta_corrente_id => contas_correntes(:segunda_conta).id, :conta_corrente_nome => ""  } }
    response.should render_template('new')

    response.should have_tag("form[method=post][action=?]", movimentos_path) do
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][conta_contabil_id]', plano_de_contas(:plano_de_contas_ativo_contribuicoes).id)
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][conta_corrente_id]', '')
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][centro_id]', centros(:centro_forum_social).id)
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][unidade_organizacional_id]', unidade_organizacionais(:sesi_colider_unidade_organizacional).id)
    
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][conta_contabil_nome]', 'Conta Contabil')
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][conta_corrente_nome]', '')
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][centro_nome]', 'Centro')
      with_tag('input[name=?][value=?]', 'movimento[lancamento_simples][unidade_organizacional_nome]', 'Unidade')
    end
  end

  it 'should delete object' do
    lambda {
      delete :destroy, :id => movimentos(:primeiro_lancamento_entrada).id
    }.should change(Movimento, :count).by(-1)
    response.should redirect_to(movimentos_url)
  end

  it 'should not delete object' do
    lambda {
      unidade = unidades(:senaivarzeagrande)
      unidade.lancamentosmovimentofinanceiro = 1
      unidade.save    
      delete :destroy, :id => movimentos(:primeiro_lancamento_entrada).id
    }.should change(Movimento, :count).by(0)
    response.should redirect_to(movimentos_url)
  end
  
  describe "Verifica se" do
    
    it "bloqueia usuario admin sem permissao que tenta modificar os dados no model Movimentos action new" do
      login_as :admin
      get :new
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin sem permissao que tenta modificar os dados no model Movimentos action edit" do
      login_as :admin
      movimento = movimentos(:primeiro_lancamento_entrada)
      get :edit, :id => movimento.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin sem permissao que tenta modificar os dados no model Movimentos action destroy" do
      login_as :admin
      movimento = movimentos(:primeiro_lancamento_entrada)
      delete :destroy, :id => movimento.id
      response.should redirect_to(login_path)
    end
  end

  it "teste da se está relacionando centro com a unidade organizacional" do
    login_as :quentin
    get :new
    response.should be_success
    response.should render_template('new')
    response.should have_tag("form[method=?][action=?]", "post", movimentos_path) do
      with_tag("script", %r{Ajax.Autocompleter.*movimento_lancamento_simples_centro_nome.*\/centros\/auto_complete_for_centro.*movimento_lancamento_simples_unidade_organizacional_id})
    end
  end

  describe 'filtra por unidade' do

    it 'a action index SESI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:movimentos].should == [movimentos(:primeiro_lancamento_entrada_outra_unidade)]
    end

    it 'a action index SENAI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id

      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:movimentos].should == movimentos(:segundo_lancamento_saida, :primeiro_lancamento_entrada)
    end

    it 'a action show SENAI para index SESI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :show, :id => movimentos(:primeiro_lancamento_entrada).id
      response.should redirect_to(movimentos_path)
    end

    it 'a action show SESI para index SENAI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id

      get :show, :id => movimentos(:primeiro_lancamento_entrada_outra_unidade).id
      response.should redirect_to(movimentos_path)
    end

    it 'a action destroy' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      delete :destroy, :id => movimentos(:primeiro_lancamento_entrada).id
      response.should redirect_to(login_path)
    end

  end

  describe "testes para a Exportação para o Zeus" do

    it 'deve exibir form' do
      login_as :quentin
      get :exportar_para_zeus
      response.should be_success
      response.should have_tag('form[action=?]', exportar_para_zeus_movimentos_path) do
        with_tag('input[name=?][value=?]', 'busca[data]', Date.today.to_s_br)
        with_tag('input[name=?][value=?][type=?]', 'commit', 'Exportar', 'submit')
      end
    end

    it "testar a geração dos arquivos TXT" do
      params = {"data" => "31/03/2009"}
      login_as :quentin
      post :exportar_para_zeus, :busca => params, :format => 'js'
      response.should be_success

      response.body.should include('window.open("/movimentos/exportar_para_zeus.html?busca')
      response.body.should_not include('alert')
      assigns[:movimentos].should == 2
    end

    it "testar quando não tem a geração dos arquivos TXT" do
      params = {"data" => "23/09/2020"}
      login_as :quentin
      post :exportar_para_zeus, :busca => params, :format => 'js'
      response.should be_success

      response.body.should_not include('window.open("/movimentos/exportar_para_zeus.html?busca')
      response.body.should include('alert')
      assigns[:movimentos].should == 0
    end

    it "teste de permissao, quando o usuário não tem" do
      login_as :juvenal
      params = {"data" => "23/09/2020"}
      post :exportar_para_zeus, :busca => params, :format => 'js'
      
      response.should redirect_to(login_path)
    end

    it "teste para verificar as exceções" do
      unidade = unidades(:senaivarzeagrande)
      unidade.nome_caixa_zeus = nil
      unidade.save false
      params = {"data" => "31/03/2009"}
      get :exportar_para_zeus, :busca => params, :redirecionamento => 'ARQ'

      response.body.should include('alert')
    end

    it "teste para não gerar alert de exceção" do
      params = {"data" => "31/03/2009"}
      get :exportar_para_zeus, :busca => params, :redirecionamento => 'ARQ'

      response.body.should_not include('alert')
    end

  end
  
  describe "Verifica se consegue acessar a" do
    it "action index quando o usuário não possui acesso" do
      login_as :juvenal
      get :index
      response.should redirect_to(login_path)
    end
    
    it "action new quando o usuário não possui acesso" do
      login_as :juvenal
      get :new
      response.should redirect_to(login_path)
    end
    
    it "action baixar_abandonar_resolver quando o usuário não possui acesso" do
      login_as :juvenal
      post :create, :movimento => {:tipo_documento => 'CTREV', :tipo_lancamento => 'E',
        :data_lancamento => "8/04/2008", :historico => "", :valor_do_documento_em_reais => "100.00", :nome_pessoa => "0622512424956 - Juan Vitor Zeferino", :pessoa_id => pessoas(:juan).id,
        :lancamento_simples => { :unidade_organizacional_id => unidade_organizacionais(:sesi_colider_unidade_organizacional).id, :unidade_organizacional_nome => "Unidade",
          :centro_id => centros(:centro_forum_social).id, :centro_nome => "Centro", :conta_contabil_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, :conta_contabil_nome => "Conta Contabil",
          :conta_corrente_id => contas_correntes(:segunda_conta).id, :conta_corrente_nome => ""  } }
      response.should redirect_to(login_path)
    end
    
    it "action show quando o usuário não tiver acesso" do
      login_as :juvenal
      get :show, :id => movimentos(:primeiro_lancamento_entrada_outra_unidade).id
      response.should redirect_to(login_path)
    end
    
    it "action edit quando o usuário não tiver acesso" do
      login_as :juvenal
      movimento = movimentos(:primeiro_lancamento_entrada)
      get :edit, :id => movimento.id
      response.should redirect_to(login_path)
    end
    
    it "action update quando o usuário não possui acesso" do
      login_as :juvenal
      post :update, "id" => movimentos(:primeiro_lancamento_entrada).id, "movimento" => {"nome_pessoa" => "Juan Vitor Zeferino", "data_lancamento" => "21/08/2009", "historico" => "Primeiro lançamento de entrada mudado",
        "tipo_lancamento" => "E", "pessoa_id" => pessoas(:juan).id, "valor_do_documento_em_reais" => "100.00", "tipo_documento" => "CTREV",
        "lancamento_simples" => {"centro_nome"=> "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
          "conta_corrente_nome" => "34445-1 - Conta Caixa - SENAI-VG", "centro_id" => centros(:centro_forum_economico).id, "conta_contabil_nome" => "2101123456 - Impostos a Pagar",
          "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id, "conta_corrente_id" => contas_correntes(:conta_vazia).id,
          "conta_contabil_id" => plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}}
      response.should redirect_to(login_path)
    end
    
  end

  it 'action libera_movimento_fora_do_prazo' do
    login_as :quentin
    post :libera_movimento_fora_do_prazo, :id => movimentos(:primeiro_lancamento_entrada).id

    response.should redirect_to(movimentos_path)
  end

  it 'action libera_movimento_fora_do_prazo sem permissão' do
    login_as :aaron
    post :libera_movimento_fora_do_prazo, :id => movimentos(:primeiro_lancamento_entrada).id

    response.should redirect_to(login_path)
  end

  it 'action libera_movimento_fora_do_prazo sem permissão na unidade' do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 1
    unidade.lancamentoscontasreceber = 1
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save
    login_as :quentin
    post :libera_movimento_fora_do_prazo, :id => movimentos(:primeiro_lancamento_entrada).id

    response.should redirect_to(movimentos_path)
  end

end