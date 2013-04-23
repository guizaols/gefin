require File.dirname(__FILE__) + '/../spec_helper'

describe PagamentoDeContasController do

  integrate_views

  before do
    login_as 'quentin'
  end
  
  def mock_contas_a_pagar
    mock_model(PagamentoDeConta,:unidade_id=>unidades(:senaivarzeagrande).id,:ano=>"2009",:parcelas_geradas=>false,:nome_unidade_organizacional=>"",:valor_do_documento_em_reais=>"",:numero_de_controle=>"",:tipo_de_documento=>"x",:provisao=>"0",:rateio=>"1",:pessoa_id=>"1",:data_lancamento=>"31/10/2009",:data_emissao=>"31/10/2009",:valor_do_documento=>"1.5",:numero_de_parcelas=>"1",:numero_nota_fiscal=>"1",:primeiro_vencimento=>"31/10/1987",:historico=>"teste",:conta_contabil_despesa_id=>"1",:unidade_organizacional_id=>"1",:centro_id=>centros(:centro_forum_social).id,:nome_centro=>"",:nome_pessoa=>"",:sigla_unidade=>"",:nome_conta_contabil_despesa=>"",:nome_conta_contabil_pessoa =>"#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - #{plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome}",:conta_contabil_pessoa=>plano_de_contas(:plano_de_contas_ativo_contribuicoes))
  end

  describe 'index' do

    it 'should get index' do
      get :index
      response.should be_success
      response.should render_template('index')
      response.should have_tag('table.listagem')
      assigns[:pagamento_de_contas].should == pagamento_de_contas(:pagamento_cheque, :pagamento_dinheiro)
    end

    it 'should get index e fazer pesquisa' do
      get :index, :busca => {:texto => '2005320011', :ordem => 'valor_do_documento'}
      response.should be_success
      response.should render_template('index')
      response.should have_tag('table.listagem')
      assigns[:pagamento_de_contas].should == [pagamento_de_contas(:pagamento_dinheiro)]

      response.should have_tag('form[action=?][method=get]', pagamento_de_contas_path) do
        with_tag('input[name=?][value=?]', 'busca[texto]', '2005320011')
        with_tag('select[name=?]', 'busca[ordem]') do
          with_tag 'option[value=primeiro_vencimento]', 'Data de Vencimento'
          with_tag 'option[value=pessoas.nome]', 'Fornecedor'
          with_tag 'option[value=valor_do_documento][selected]', 'Valor'
        end
        with_tag('input[type=submit]')
      end
    end
    
  end

  it 'deve exibir link para fechar o errorExplanation, isto é uma modificação do Rails dentro do active_record_helper.rb' do
    post :create, :pagamento_de_conta => {:tipo_de_documento => ''}
    response.should render_template('new')
    response.should have_tag('div#errorExplanation') do
      with_tag 'a[onclick]', 'x'
    end
  end

  it "testa action de resumo" do
    get :resumo, :id => pagamento_de_contas(:pagamento_cheque).id, :format => 'pdf'
    response.should be_success

    assigns[:titulo].should == 'RESUMO DE CONTA A PAGAR'
  end

  it "should get show" do
    pagamento_de_conta = pagamento_de_contas(:pagamento_cheque_outra_unidade)
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    get :show, :id => pagamento_de_conta.id
    response.should be_success
    response.should render_template('show')
    assigns[:pagamento_de_conta].id.should == pagamento_de_conta.id
    with_tag("tr[id=?]", "parcela_388778763")
    with_tag("tr[id=?]","parcela_616549630")
    with_tag("tr[id=?]","parcela_1039623140")
  end


  it "não acessa conta de outra unidade" do
    login_as :admin
    pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
    get :show,:id=>pagamento_de_conta.id
    response.should redirect_to("/login")
  end


  it "testando action e view new" do
    get :new
    response.should be_success
    response.should have_tag("form[method=post][action=?]",pagamento_de_contas_path) do
      validar_campos_form
    end
  end
  
  it 'should get edit' do
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    get :edit, :id=>conta_a_pagar.id
    assigns[:pagamento_de_conta].should == conta_a_pagar
    response.should be_success
    response.should render_template('edit')
    response.should have_tag('form') do
      with_tag 'input[name=_method][value=put]'
      validar_campos_form
    end

  end

  def validar_campos_form
    with_tag("select[name='pagamento_de_conta[tipo_de_documento]']")
    with_tag("select[name='pagamento_de_conta[rateio]']")
    with_tag("select[name='pagamento_de_conta[provisao]']")
    with_tag("input[name='pagamento_de_conta[nome_pessoa]']")
    with_tag("input[name='pagamento_de_conta[data_lancamento]']")
    with_tag("input[name='pagamento_de_conta[data_emissao]']")
    with_tag("input[name='pagamento_de_conta[valor_do_documento_em_reais]']")
    with_tag("input[name='pagamento_de_conta[numero_de_parcelas]']")
    with_tag("input[name='pagamento_de_conta[numero_nota_fiscal]']")
    with_tag("input[name='pagamento_de_conta[primeiro_vencimento]']")
    with_tag("input[name='pagamento_de_conta[nome_centro]']")
    with_tag("input[name='pagamento_de_conta[unidade_organizacional_id]']")
    with_tag("script",%r{'pagamento_de_conta_primeiro_vencimento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
    with_tag("script",%r{'pagamento_de_conta_data_emissao'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
    with_tag("script",%r{'pagamento_de_conta_data_lancamento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
  end


  it 'should create valid object' do
    request.session[:ano] = "2009"
    conta_a_pagar = mock_contas_a_pagar
    PagamentoDeConta.should_receive(:new).with("nome_centro"=>"Forum Serviço Social", "numero_de_parcelas"=>"4", "numero_nota_fiscal"=>"3002009", "nome_pessoa"=>"Felipe Giotto", "centro_id"=>"1", "primeiro_vencimento"=>"09/04/2009", "data_lancamento"=>"09/04/2009", "nome_conta_contabil_pessoa"=>"", "historico"=>"Pagamento Cartão  - Felipe Giotto", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "nome_conta_contabil_despesa"=>" 41010101008 - Contribuicoes Regul. oriundas do SENAI", "unidade_organizacional_id"=>"50958416", "conta_contabil_despesa_id"=>"937187129", "data_emissao"=>"09/04/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"89364216", "valor_do_documento_em_reais"=>"1", "nome_unidade_organizacional"=>"SESI COLIDER", "rateio"=>"0","ano"=>"2009").and_return conta_a_pagar
    conta_a_pagar.should_receive(:unidade_id=).with(unidades(:senaivarzeagrande).id)
    conta_a_pagar.should_receive(:ano=).with("2009")
    conta_a_pagar.should_receive(:usuario_corrente=).with(usuarios(:quentin))
    conta_a_pagar.should_receive(:verifica_contratos).with("09/04/2009", "89364216")
    conta_a_pagar.should_receive(:save).and_return true
    post :create, :pagamento_de_conta=>{"nome_centro"=>"Forum Serviço Social","numero_de_parcelas"=>"4", "numero_nota_fiscal"=>"3002009", "nome_pessoa"=>"Felipe Giotto", "centro_id"=>"1", "primeiro_vencimento"=>"09/04/2009", "data_lancamento"=>"09/04/2009", "nome_conta_contabil_pessoa"=>"", "historico"=>"Pagamento Cartão  - Felipe Giotto", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "nome_conta_contabil_despesa"=>" 41010101008 - Contribuicoes Regul. oriundas do SENAI", "unidade_organizacional_id"=>"50958416", "conta_contabil_despesa_id"=>"937187129", "data_emissao"=>"09/04/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"89364216", "valor_do_documento_em_reais"=>"1", "nome_unidade_organizacional"=>"SESI COLIDER", "rateio"=>"0","ano"=>"2009"}
    response.should redirect_to(pagamento_de_conta_path(conta_a_pagar.id))
  end

  it 'should show the alert' do
    @conta = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
      :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
      :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
      :provisao => PagamentoDeConta::NAO, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
      :valor_do_documento => 1000, :numero_de_parcelas => 1, :rateio => 1,
      :historico => "Teste", :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :ano => 2009
    @conta.save.should be_true
    flash[:notices] = ["O cliente deste contrato está com os seguintes contratos vigentes neste mês:\n\n\nUNIDADE\t\t\t\t  Nº CONTROLE\n1º VENCIMENTO  VALOR   SITUAÇÃO  EMISSÃO\n\nSesi Clube Varzea Grand...\t2005320011                     \n30/11/2009\t\t   120.0  Atrasada    31/10/2009\n\nSENAI - Varzea Grande...\t2005320011                     \n30/11/2009\t\t   120.0  Pendente    31/10/2009\n"]
    get :show, :id=>@conta.id
    response.should be_success
    response.body.should match(%r{alert\("O cliente deste contrato est\\u00e1 com os seguintes contratos vigentes neste m\\u00eas:\\n\\n\\nUNIDADE\\t\\t\\t\\t  N\\u00ba CONTROLE\\n1\\u00ba VENCIMENTO  VALOR   SITUA\\u00c7\\u00c3O  EMISS\\u00c3O\\n\\nSesi Clube Varzea Grand\.\.\.\\t2005320011})
  end

  it 'should not create invalid object' do
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    PagamentoDeConta.should_receive(:new).with('tipo_de_documento' => '').and_return conta_a_pagar
    conta_a_pagar.should_receive(:unidade_id=).with(unidades(:senaivarzeagrande).id)
    conta_a_pagar.should_receive(:save).and_return false
    post :create, :pagamento_de_conta => {:tipo_de_documento => ''}
    response.should render_template('new')
  end

  it 'should update valid object' do
    request.session[:ano] = "2009"
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    put :update,:id=>conta_a_pagar.id, :pagamento_de_conta => {:numero_de_parcelas => '3', :usuario_corrente => usuarios(:quentin)}
    response.should redirect_to(pagamento_de_conta_path(conta_a_pagar.id))
  end

  it 'should not update invalid object' do
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    put :update,:id=>conta_a_pagar.id, :pagamento_de_conta => {:tipo_de_documento => '',:numero_de_parcelas=>'0', :usuario_corrente => usuarios(:quentin)}
    response.should render_template('edit')
  end

  it 'should delete object' do
    lambda {
      pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
      delete :destroy, :id => pagamento_de_conta.id
    }.should change(PagamentoDeConta, :count).by(-1)
    response.should redirect_to(pagamento_de_contas_url)
  end


  it 'should not delete object' do
    lambda {
      pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
      pagamento_de_conta.usuario_corrente = Usuario.first
      pagamento_de_conta.gerar_parcelas(2009)
      pagamento_de_conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1;parcela.valor_liquido=parcela.valor;parcela.save!}
      delete :destroy, :id => pagamento_de_conta.id
    }.should change(PagamentoDeConta, :count).by(0)
    response.should redirect_to(pagamento_de_contas_url)
  end

  it "testa action de resumo: format js" do
    get :resumo, :id => pagamento_de_contas(:pagamento_cheque).id, :format => 'js'
    response.should be_success

    assigns[:pagamento_de_conta].should == pagamento_de_contas(:pagamento_cheque)
    response.body.should include("window.open")
  end

  it "testa action de resumo: format pdf" do
    get :resumo, :id => pagamento_de_contas(:pagamento_cheque).id, :format => 'pdf'
    response.should be_success

    assigns[:titulo].should == 'RESUMO DE CONTA A PAGAR'
  end  
  
  describe "Verifica se" do
  
    it "bloqueia usuario admin sem permissao que quer modificar dados no model Pagamento de Contas action new" do
      login_as :admin
      get :new
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin sem permissao que quer modificar dados no model Pagamento de Contas action edit" do
      login_as :admin
      pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
      get :edit, :id=> pagamento_de_conta.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin sem permissao que quer modificar dados no model Pagamento de Contas action destroy" do
      login_as :admin
      pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
      delete :destroy, :id=> pagamento_de_conta.id
      response.should redirect_to(login_path)
    end
    
    it "bloqueia usuario admin sem permissao que quer modificar dados no model Pagamento de Contas action gerar_parcelas" do
      login_as :admin
      parcelas = parcelas(:primeira_parcela)
      post :gerar_parcelas, :id=> parcelas.id
      response.should redirect_to(login_path)
    end
  end

  describe "Teste de bloqueio das actions caso o pagamento de conta não seja da Unidade logada" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      @pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
    end

    after do
      assigns[:pagamento_de_conta].should == @pagamento_de_conta
      response.should redirect_to(login_path)
    end

    [:show, :edit, :gerar_parcelas, :destroy, :update].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @pagamento_de_conta
      end
    end

  end

  it "call action atualiza valores" do
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    post :atualiza_valores_das_parcelas, :id => conta_a_pagar.id, :parcela => {conta_a_pagar.parcelas.first.id.to_s => {"valor"=>"30.00","data_vencimento"=>"31/10/2009"}, conta_a_pagar.parcelas.last.id.to_s => {"valor"=>"","data_vencimento"=>"31/11/2009"}}
    response.should be_success
    response.should render_template('carrega_parcelas')
    assigns[:pagamento_de_conta].should == conta_a_pagar
  end

  it "call action atualiza valores, não atualizando" do
    request.session[:ano] = 2009
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    conta_a_pagar.usuario_corrente = usuarios(:quentin)
    conta_a_pagar.gerar_parcelas(2009)
    parcela_1 = conta_a_pagar.parcelas[0]
    parcela_2 = conta_a_pagar.parcelas[1]
    parcela_3 = conta_a_pagar.parcelas[2]
    post :atualiza_valores_das_parcelas, :id => conta_a_pagar.id, :parcela => {parcela_1.id.to_s => {"data_vencimento" => "31/01/2009", "valor" => "10.00"}, parcela_2.id.to_s => {"data_vencimento" => "31/01/2009", "valor" => "10.00"}, parcela_3.id.to_s => {"data_vencimento" => "31/01/2009", "valor" => "10.00"}}
    response.should render_template('carrega_parcelas')
    assigns[:pagamento_de_conta].should == conta_a_pagar
  end

  it "testa action carrega parcelas" do
    conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    conta_a_pagar.usuario_corrente = usuarios(:quentin)
    conta_a_pagar.gerar_parcelas(2009)

    # Atribuindo renegociada para testar readonly
    ultima_parcela = conta_a_pagar.parcelas.last
    ultima_parcela.situacao = Parcela::RENEGOCIADA
    ultima_parcela.save

    get :carrega_parcelas, :id => conta_a_pagar.id
    response.should be_success
    assigns[:pagamento_de_conta].should == conta_a_pagar

    # Testando a view
    response.should have_tag('form[action=?]', atualiza_valores_das_parcelas_pagamento_de_conta_path(conta_a_pagar.id)) do
      with_tag("table")    do
        with_tag("tr") do
          with_tag("input[id=?]","parcela_#{conta_a_pagar.parcelas.first.id}_data_vencimento")
          with_tag("input[id=?]","parcela_#{conta_a_pagar.parcelas.first.id}_valor")
          with_tag("label")
        end
        # Não pode mostrar a renegociada
        with_tag("tr") do
          without_tag("input[id=?][readonly=?]","parcela_#{ultima_parcela.id}_data_vencimento", "readonly")
          without_tag("input[id=?][readonly=?]","parcela_#{ultima_parcela.id}_valor", "readonly")
          with_tag("label")
        end
      end
    end
  end

  it 'action libera_pagamento_de_conta_fora_do_prazo' do
    login_as :quentin
    post :libera_pagamento_de_conta_fora_do_prazo, :id => pagamento_de_contas(:pagamento_dinheiro).id

    response.flash[:notice].should == 'Conta liberada pelo DR.'
    response.should redirect_to(pagamento_de_contas_path)
  end

  it 'action libera_pagamento_de_conta_fora_do_prazo sem permissão' do
    login_as :aaron
    post :libera_pagamento_de_conta_fora_do_prazo, :id => pagamento_de_contas(:pagamento_dinheiro).id

    response.should redirect_to(login_path)
  end

  it 'action libera_pagamento_de_conta_fora_do_prazo sem permissão na unidade' do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 1
    unidade.lancamentoscontasreceber = 1
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save
    login_as :quentin
    post :libera_pagamento_de_conta_fora_do_prazo, :id => pagamento_de_contas(:pagamento_dinheiro).id

    response.flash[:notice].should == "Conta liberada pelo DR."
    response.should redirect_to(pagamento_de_contas_path)
  end

end