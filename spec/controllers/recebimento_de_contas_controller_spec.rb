require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecebimentoDeContasController do
  
  integrate_views

  before :each do
    login_as :quentin
  end

  describe "GET index" do
    it "assigns all recebimento_de_contas as @recebimento_de_contas" do
      get :index
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      assigns[:recebimento_de_contas].should == RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, {})

      response.should have_tag('table.listagem') do
        with_tag('a[href=?]',new_recebimento_de_conta_path)
        with_tag('a[href=?]',edit_recebimento_de_conta_path(recebimento_de_contas(:curso_de_tecnologia_do_paulo).id))
        with_tag('a[href=?]',recebimento_de_conta_path(recebimento_de_contas(:curso_de_tecnologia_do_paulo).id))
      end
    end

    describe "GET show" do
      it "assigns the requested recebimento_de_conta as @recebimento_de_conta" do
        recebimento_de_contas(:curso_de_design_do_paulo)
        get :show, :id => recebimento_de_contas(:curso_de_design_do_paulo).id
        assigns[:recebimento_de_conta].should == recebimento_de_contas(:curso_de_design_do_paulo)
        response.should_not have_tag("a[href=?][target=?]",listar_recibos_recebimento_de_conta_parcelas_path(recebimento_de_contas(:curso_de_design_do_paulo).id),'_blank')
      end
      
      it "verifica se existe a actiuon show e se esta exibindo o link do recibo quando existem parcelas baixadas" do
        parcelas(:primeira_parcela_recebimento).data_da_baixa = "01/06/2009"
        parcelas(:primeira_parcela_recebimento).save false
        parcelas(:segunda_parcela_recebimento).data_da_baixa = "02/06/2009"
        parcelas(:segunda_parcela_recebimento).save false
        recebimento_de_contas(:curso_de_design_do_paulo).reload
        get :show, :id => recebimento_de_contas(:curso_de_design_do_paulo).id
        assigns[:recebimento_de_conta].should == recebimento_de_contas(:curso_de_design_do_paulo)
        response.should have_tag("a[href=?][target=?]",listar_recibos_recebimento_de_conta_parcelas_path(recebimento_de_contas(:curso_de_design_do_paulo).id),'_blank')
      end
    end
    
    
    it 'should update valid object' do
      request.session[:ano] = "2009"
      recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      put :update,:id=>recebimento_de_conta.id, :pagamento_de_conta => {:numero_nota_fiscal => '2342343', :usuario_corrente => usuarios(:quentin)}
      response.should redirect_to(recebimento_de_conta_path(recebimento_de_conta.id))
    end

    it 'should not update invalid object' do
      recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      recebimento_de_conta.servico_iniciado = false
      recebimento_de_conta.save false
      put :update,:id=>recebimento_de_conta.id, :recebimento_de_conta => {:tipo_de_documento => '',:numero_de_parcelas=>'0', :usuario_corrente => usuarios(:quentin)}
      response.should render_template('edit')
    end
    
    it "GET new assigns a new recebimento_de_conta as @recebimento_de_conta" do
      get :new
      response.should have_tag('form[action=?]', recebimento_de_contas_path) do
        validar_campos_form
      end
    end
    
    it 'should delete object' do
      lambda {
        recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
        delete :destroy, :id => recebimento_de_conta.id
      }.should change(RecebimentoDeConta, :count).by(-1)
      response.should redirect_to(recebimento_de_contas_url)
    end

    it 'should not delete object' do
      lambda {
        recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
        recebimento_de_conta.usuario_corrente = Usuario.first
        recebimento_de_conta.gerar_parcelas(2009)
        recebimento_de_conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1;parcela.valor_liquido=parcela.valor;parcela.save!}
        delete :destroy, :id => recebimento_de_conta.id
      }.should change(RecebimentoDeConta, :count).by(0)
      response.should redirect_to(recebimento_de_contas_url)
    end

    it "GET edit assigns the requested recebimento_de_conta as @recebimento_de_conta" do
      recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      recebimento_de_conta.servico_iniciado = false
      recebimento_de_conta.save false
      get :edit, :id => recebimento_de_conta.id
      assigns[:recebimento_de_conta].should == recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      response.should have_tag('form[action=?]', recebimento_de_conta_path(recebimento_de_contas(:curso_de_tecnologia_do_paulo).id)) do
        validar_campos_form
      end
    end

    def validar_campos_form
      with_tag 'select[name=?]', 'recebimento_de_conta[tipo_de_documento]' do
        with_tag 'option', ''
        with_tag 'option[value=CTRSE]', 'SERVIÇOS EDUCACIONAIS - CONTRATO RECEBIMENTO'
      end
      with_tag("select[name='recebimento_de_conta[rateio]']")
      with_tag("input[name='recebimento_de_conta[valor_do_documento_em_reais]']")
      with_tag("input[name='recebimento_de_conta[numero_de_parcelas]']")
      with_tag("input[name='recebimento_de_conta[numero_nota_fiscal]']")

      with_tag("input[name='recebimento_de_conta[nome_centro]']")
      with_tag("input[name='recebimento_de_conta[centro_id]']")

      with_tag("input[name='recebimento_de_conta[nome_unidade_organizacional]']")
      with_tag("input[name='recebimento_de_conta[unidade_organizacional_id]']")

      with_tag("input[name='recebimento_de_conta[pessoa_id]']")
      with_tag("input[name='recebimento_de_conta[nome_pessoa]']")

      with_tag("input[name='recebimento_de_conta[vendedor_id]']")
      with_tag("input[name='recebimento_de_conta[nome_vendedor]']")

      with_tag("input[name='recebimento_de_conta[cobrador_id]']")
      with_tag("input[name='recebimento_de_conta[nome_cobrador]']")

      with_tag("input[name='recebimento_de_conta[conta_contabil_receita_id]']")
      with_tag("input[name='recebimento_de_conta[nome_conta_contabil_receita]']")

      with_tag("input[name='recebimento_de_conta[juros_por_atraso]']")
      with_tag("input[name='recebimento_de_conta[multa_por_atraso]']")

      with_tag("input[name='recebimento_de_conta[nome_servico]']")
      with_tag("input[name='recebimento_de_conta[servico_id]']")
      with_tag("select[name='recebimento_de_conta[dia_do_vencimento]']") do
        with_tag 'option', ''
        with_tag 'option', '1'
        with_tag 'option', '31'
      end
      with_tag("textarea[name='recebimento_de_conta[historico]']")

      with_tag("select[name='recebimento_de_conta[origem]']") do
        with_tag 'option', ''
        with_tag 'option[value=0]', 'Interna'
        with_tag 'option[value=1]', 'Externa'
      end
      with_tag('script',%r{'recebimento_de_conta_data_inicio'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
      with_tag('script',%r{'recebimento_de_conta_data_final'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
      with_tag('script',%r{'recebimento_de_conta_data_venda'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
    end

    it 'deve retornar calculo da data final' do
      post :calcula_data_final, :data_inicio => '31/01/2009', :vigencia => '1'
      response.should be_success
      response.body.should include('$("recebimento_de_conta_data_final").value = "28/02/2009"')
    end

    it 'deve retornar calculo da data final com dados errados' do
      post :calcula_data_final, :data_inicio => 'AAAA', :vigencia=> 'AAAA'
      response.should be_success
      response.body.should include('$("recebimento_de_conta_data_final").value = null')
    end
    
        
    it "deve incluir o cliente no spc quando usuario possui acesso" do
      login_as :quentin
      recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      post :situacao_spc , :id => recebimento_de_conta.id
      response.should be_success
      response.should have_tag("span[id=?]",'situacao_spc') do
        with_tag("input[onclick*=?][value=?]","situacao_spc","Incluir no SPC")
      end
    end
    
    it "deve excluir o cliente no spc quando o usuario possui acesso" do
      login_as :quentin
      pessoas(:paulo).spc = false
      pessoas(:paulo).save
      recebimento_de_contas(:curso_de_tecnologia_do_paulo).reload
      post :situacao_spc , :id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id
      response.should be_success
      response.should have_tag("span[id=?][style=?]",'situacao_spc','color:red;','Cliente no SPC') do
        with_tag("input[onclick*=?][value=?]","situacao_spc","Excluir do SPC")
      end
    end
    
    it "não deve exibir o botao excluir cliente do spc quando o usuario não possui acesso" do
      login_as :admin
      pessoas(:paulo).spc = false
      pessoas(:paulo).save
      recebimento_de_contas(:curso_de_tecnologia_do_paulo).reload
      post :situacao_spc , :id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id
      response.should redirect_to(login_path)
    end

    describe "POST create" do
    
      describe "with valid params" do
        it "assigns a newly created recebimento_de_conta as @recebimento_de_conta" do
          RecebimentoDeConta.delete_all
          request.session[:ano] = "2009"
          request.session[:unidade_id] = unidades(:senaivarzeagrande).id
          post :create, :recebimento_de_conta => {
            :tipo_de_documento => "CPMF",
            :numero_nota_fiscal => "999888777",
            :pessoa_id => pessoas(:paulo).id,
            :dependente_id => dependentes(:dependente_paulo_primeiro).id,
            :servico_id => servicos(:curso_de_tecnologia).id,
            :data_inicio => Time.now,
            :data_final => Time.now,
            :data_inicio_servico => Time.now,
            :data_final_servico => Time.now,
            :dia_do_vencimento => 1,
            :valor_do_documento_em_reais => '10,00',
            :numero_de_parcelas => 1,
            :rateio => 1,
            :vigencia=>1,
            :historico => "value for historico",
            :conta_contabil_receita_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
            :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional).id,
            :centro_id => centros(:centro_forum_economico).id,
            :data_venda => Time.now,
            :origem => 1,
            :vendedor_id => 1,
            :cobrador_id => 1,
            :parcelas_geradas => false,
            :situacao => 1,
            :usuario_corrente => usuarios(:quentin),
            :data_inicio_servico => Date.today,
            :data_final_servico => Date.today
          }
          response.should redirect_to(recebimento_de_conta_url(RecebimentoDeConta.last.id))
        end
      end
    
      
      
      it "with invalid params assigns a newly created but unsaved recebimento_de_conta as @recebimento_de_conta" do
        post :create, :recebimento_de_conta => {}
        response.should render_template('new')
      end
    end

  
    #  describe "PUT update" do
    #
    #    describe "with valid params" do
    #      it "updates the requested recebimento_de_conta" do
    #        put :update, :id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id, :recebimento_de_conta => {}
    #        response.should redirect_to(recebimento_de_conta_url(recebimento_de_contas(:curso_de_tecnologia_do_paulo)))
    #      end
    #    end
    #
    #    describe "with invalid params" do
    #      it "updates the requested recebimento_de_conta" do
    #        put :update, :id => "37", :recebimento_de_conta => {:tipo_de_documento => nil}
    #        response.should render_template('edit')
    #      end
    #    end
    #
    #  end

    #  describe "DELETE destroy" do
    #    it "destroys the requested recebimento_de_conta" do
    #      RecebimentoDeConta.should_receive(:find).with("37").and_return(mock_recebimento_de_conta)
    #      mock_recebimento_de_conta.should_receive(:destroy)
    #      delete :destroy, :id => "37"
    #    end
    #
    #    it "redirects to the recebimento_de_contas list" do
    #      RecebimentoDeConta.stub!(:find).and_return(mock_recebimento_de_conta(:destroy => true))
    #      delete :destroy, :id => "1"
    #      response.should redirect_to(recebimento_de_contas_url)
    #    end
    #  end

  end

  it "call action renegociar" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    post :renegociar, :id=> conta_a_receber.id
    response.should be_success
    response.should have_rjs(:replace_html,"formulario_de_renegociacao") do
      with_tag("input[name='recebimento_de_conta[valor_do_documento_em_reais]']")
      with_tag("input[name='recebimento_de_conta[numero_de_parcelas]']")
      with_tag("input[name='recebimento_de_conta[data_inicio]']")
      with_tag("input[name='recebimento_de_conta[data_final]']")
    end
    assigns[:recebimento_de_conta].should == conta_a_receber
  end
    
  it "call action efetuar_renegociacao e faz update " do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    hash_recebimento = {"numero_de_parcelas"=>"5", "vigencia"=>"5", "historico"=>"Pagamento Cartão  - 20053200 - Paulo Vitor Zeferino - Curso de Ruby on Rails", "dia_do_vencimento"=>"5", "data_inicio"=>"19/06/2009", "valor_do_documento_em_reais"=>"1000.00"}
    post :efetuar_renegociacao, :id=> conta_a_receber.id, :recebimento_de_conta=>hash_recebimento
    response.should be_success
    response.body.should include('Modalbox.hide()')
  end
  
  it "call action efetuar_renegociacao e não faz update " do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    hash_recebimento = {"numero_de_parcelas"=>"", "vigencia"=>"", "historico"=>"Pagamento Cartão  - 20053200 - Paulo Vitor Zeferino - Curso de Ruby on Rails", "dia_do_vencimento"=>"5", "data_inicio"=>"19/06/2009", "valor_do_documento_em_reais"=>""}
    post :efetuar_renegociacao, :id=> conta_a_receber.id, :recebimento_de_conta=>hash_recebimento
    response.should be_success
    response.body.should_not include('Modalbox.hide()')
  end
  
  it "call action carregar_modal_parcela" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    post :carregar_modal_parcela, :id=>conta_a_receber.id
    response.should be_success
    response.should have_rjs(:replace_html,"formulario_de_nova_parcela") do
      with_tag("input[name='parcela[data_vencimento]']")
      with_tag("input[name='parcela[valor]']")
    end
    assigns[:recebimento_de_conta].should == conta_a_receber
  end
  
  
  it "call action inserindo_nova_parcela" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    post :inserindo_nova_parcela, :id=>conta_a_receber.id, :parcela=>{:valor=>"100.00",:data_vencimento=>"19/06/2009"}
    response.should be_success
    response.body.should include('Modalbox.hide()')
    assigns[:recebimento_de_conta].should == conta_a_receber
  end
    
  it "call action inserindo_nova_parcela não consegue inserir" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    post :atualiza_valores_das_parcelas,:id=>conta_a_receber.id, :parcela=>{conta_a_receber.parcelas.first.id.to_s=>{"valor"=>"30.00","data_vencimento"=>"31/10/2009"},conta_a_receber.parcelas.last.id.to_s=>{"valor"=>"","data_vencimento"=>"31/11/2009"}}
    response.should be_success
    response.should render_template('carrega_parcelas')
    assigns[:recebimento_de_conta].should == conta_a_receber
  end
    
  it "call action inserindo_nova_parcela não consegue inserir" do
    request.session[:ano] = 2009
    conta_a_receber = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    conta_a_receber.rateio = 0
    conta_a_receber.usuario_corrente = Usuario.first
    conta_a_receber.save!
    conta_a_receber.gerar_parcelas(2009)
    post :atualiza_valores_das_parcelas,:id=>conta_a_receber.id, :parcela=>{conta_a_receber.parcelas.first.id.to_s=>{"data_vencimento"=>"31/10/2009","valor"=>"10,00"}}
    response.should redirect_to(recebimento_de_conta_url(conta_a_receber.id))
    assigns[:recebimento_de_conta].should == conta_a_receber
  end
  
  
  it "call action inserindo_nova_parcela não consegue inserir" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    post :inserindo_nova_parcela, :id=>conta_a_receber.id, :parcela=>{:valor=>"",:data_vencimento=>""}
    response.should be_success
    response.body.should_not include('Modalbox.hide()')
    assigns[:recebimento_de_conta].should == conta_a_receber
  end
  
  it "testa action carrega_parcelas" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)

    # Atribuindo renegociada para testar readonly
    ultima_parcela = conta_a_receber.parcelas.last
    ultima_parcela.situacao = Parcela::RENEGOCIADA
    ultima_parcela.save

    get :carrega_parcelas, :id => conta_a_receber.id
    response.should be_success    
    assigns[:recebimento_de_conta].should == conta_a_receber

    # Testando a view
    response.should have_tag('form[action=?]', atualiza_valores_das_parcelas_recebimento_de_conta_path(conta_a_receber.id)) do
      with_tag("table")    do
        with_tag("tr") do
          with_tag("input[id=?]","parcela_#{conta_a_receber.parcelas.first.id}_data_vencimento")
          with_tag("input[id=?]","parcela_#{conta_a_receber.parcelas.first.id}_valor")
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

  it "testa action de resumo: format js" do
    get :resumo, :id => recebimento_de_contas(:curso_de_design_do_paulo).id, :format => 'js'
    response.should be_success

    assigns[:recebimento_de_conta].should == recebimento_de_contas(:curso_de_design_do_paulo)
    response.body.should include("window.open")
  end

  it "testa action de resumo: format pdf" do
    get :resumo, :id => recebimento_de_contas(:curso_de_design_do_paulo).id, :format => 'pdf'
    response.should be_success

    assigns[:titulo].should == 'CONTRATO DE SERVIÇO'
  end  
  
  describe 'deve exibir links somente com permissão para' do

    it 'quentin' do
      login_as :quentin
      get :show, :id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id
      response.should be_success

      response.should have_tag('a[href=?]', recebimento_de_conta_projecao_path(recebimento_de_contas(:curso_de_tecnologia_do_paulo).id))
    end

    #    Colocar as permissões quando estiverem bem definidas
    #    it 'juvenal' do
    #      login_as :juvenal
    #      get :show, :id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id
    #      response.should be_success
    #
    #      response.should_not have_tag('a[href=?]', recebimento_de_conta_projecoes_path(recebimento_de_contas(:curso_de_tecnologia_do_paulo).id))
    #    end
  end

  describe "se o contrato estiver cancelado" do

    before do
      login_as 'quentin'
      @recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @recebimento_de_conta.situacao = RecebimentoDeConta::Cancelado
      @recebimento_de_conta.save
    end

    after do
      assigns[:recebimento_de_conta].should == @recebimento_de_conta
      response.should redirect_to(login_path)
    end

    [:gerar_parcelas, :situacao_spc, :renegociar, :efetuar_renegociacao].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @recebimento_de_conta
      end
    end
  end

  it 'verificar os campos no modal box de abdicação do contrato' do
    login_as :quentin
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    post :abdicar, :id => conta_a_receber.id
    response.should be_success
    response.should have_rjs(:replace_html, "formulario_de_abdicacao") do
      with_tag("input[name=?]", "data_abdicacao")
      with_tag("textarea[name=?]", "justificativa")
    end
    assigns[:recebimento_de_conta].should == conta_a_receber
  end

  describe "mensagem das parcelas show de recebimento de contas" do
    before do
      login_as 'quentin'
      @recebimento_de_conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      @recebimento_de_conta.situacao = RecebimentoDeConta::Cancelado
      @recebimento_de_conta.save
      @recebimento_de_conta.pode_gerar_parcelas
    end

    after do
      assigns[:recebimento_de_conta].should == @recebimento_de_conta
    end

    it "deve mostrar a mensagem de que o contrato está cancelado" do
      get :show, :id => @recebimento_de_conta
      with_tag("p") do
        with_tag("b", "Este contrato está cancelado. Não existem parcelas para ele.")
      end
    end
  end

  describe "link para gerar parcelas show de recebimento de contas" do
    before do
      login_as 'quentin'
      @recebimento_de_conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      @recebimento_de_conta.pode_gerar_parcelas
    end

    after do
      assigns[:recebimento_de_conta].should == @recebimento_de_conta
    end

    it "deve mostrar a o link para gerar novas parcelas" do
      get :show, :id => @recebimento_de_conta
      with_tag("p") do
        with_tag("b", "Não existem parcelas cadastradas para esta conta. Clique em")
        with_tag("a", "Gerar Parcelas") do
          with_tag("[onclick*=?][href*=?]", "O valor do documento do fornecedor Paulo Vitor Zeferino é de R$ 90,00 e a quantidade de parcelas é 3. Confirma estes dados?');", "/gerar_parcelas")
        end
        with_tag("b", "para gerá-las.")
      end
    end

  end

  describe 'Filtra por unidade' do

    it 'a action index SESI' do
      login_as :quentin
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id

      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:recebimento_de_contas].should == []
    end

    it 'a action index SENAI' do
      login_as :quentin
      pesquisa_index = RecebimentoDeConta.all :conditions=>["unidade_id = ? ",unidades(:senaivarzeagrande).id], :order=>'situacao'
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      get :index
      response.should be_success
      response.should render_template('index')
      assigns[:recebimento_de_contas].should == pesquisa_index
      
    end
  end

  describe "Teste de bloqueio das actions caso o recebimento de conta não seja da Unidade logada" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:sesivarzeagrande).id
      @recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    end

    after do
      assigns[:recebimento_de_conta].should == @recebimento_de_conta
      response.should redirect_to(login_path)
    end

    [:show, :edit, :gerar_parcelas, :atualiza_valores_das_parcelas, :situacao_spc,
      :renegociar, :efetuar_renegociacao, :inserindo_nova_parcela, :abdicar, :efetuar_abdicacao].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @recebimento_de_conta
      end
    end

  end

  describe "Testa atualização do campo situacao FIEMT" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      @recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    end

    it "a action altera_situacao_fiemt" do
      post :altera_situacao_fiemt, :id => @recebimento_de_conta.id, :argumento => 5
      response.body.should include('Situação FIEMT atualizado para inativo!'.to_json)
      response.body.should include('window.location.reload()')
    end

    it "a action altera_situacao_fiemt, não funciona" do
      post :altera_situacao_fiemt, :id => @recebimento_de_conta.id, :argumento => 25
      response.body.should include('A situação FIEMT não pode ser modificada!'.to_json)
    end

    it "a action altera_situacao_fiemt, se for situação 3" do
      post :altera_situacao_fiemt, :id => @recebimento_de_conta.id, :argumento => 3
      response.body.should include('Situação FIEMT atualizado para jurídico!'.to_json)
    end

  end

  describe "Testa a action de cancelamento de contrato e o filter de contrato inativo" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      @recebimento_de_conta = recebimento_de_contas(:curso_de_design_do_paulo)
    end

    it "testa a action cancelar_contrato" do
      @recebimento_de_conta.servico_iniciado = false
      @recebimento_de_conta.save false
      post :efetua_cancelamento, :id => @recebimento_de_conta.id, :data_cancelamento => "27/09/2010", :justificativa => "asdasd"
      response.body.should include("alert(\"O contrato #{@recebimento_de_conta.numero_de_controle} foi cancelado!\");\nwindow.location.reload();")
    end

    it "testa o filtro de contrato inativo" do
      @recebimento_de_conta.cancelar_contrato(usuarios(:quentin))
      get :edit, :id => @recebimento_de_conta.id
      response.should redirect_to(recebimento_de_conta_path(@recebimento_de_conta.id))
    end
    
  end

  describe "Testa a action de estorno de contrato e o filter de contrato inativo" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      @recebimento_de_conta = recebimento_de_contas(:curso_de_design_do_paulo)
    end

    it "testa a action estornar_contrato" do
      # Primeiro, cancelando o contrato
      @recebimento_de_conta.cancelar_contrato(usuarios(:quentin))

      post :estornar_contrato, :id => @recebimento_de_conta.id
      response.body.should include("alert(\"O contrato foi estornado com sucesso!\");\nwindow.location.reload();")
    end

  end

  describe "Testa envio a DR/Terceirizada" do

    it 'quando requer a view de pesquisa' do
      get :pesquisa_para_envio
      response.should be_success
      assigns[:recebimento_de_contas].should == nil
    end

    it 'quando faço uma pesquisa por datas' do
      get :pesquisa_para_envio, :format => 'js', :busca => {:data_inicial => '01/01/2000', :data_final => '01/01/2010'}
      response.should be_success
      assigns[:recebimento_de_contas].should == [recebimento_de_contas(:curso_de_design_do_paulo)]
      response.body.should match(%r{^Element.replace})
    end

    it 'quando faço uma pesquisa por datas sem sucesso' do
      get :pesquisa_para_envio, :format => 'js', :busca => {:data_inicial => '01/01/2000', :data_final => '01/01/2001'}
      response.should be_success
      assigns[:recebimento_de_contas].should == []
      response.body.should include("Element.replace(\"resultado_pesquisa_envio\"")
    end

    it 'envia para o dr/terceirizada sem nenhum id selecionado' do
      get :envio_ao_dr_terceirizada, :format => 'js', :recebimento_de_contas => {:ids => [], :dr_ou_terceirizada => RecebimentoDeConta::DR}
      response.should be_success
      response.body.should include('window.location.reload()')
    end

    it 'envia para o dr/terceirizada com ids' do
      get :envio_ao_dr_terceirizada, :format => 'js', :recebimento_de_contas => {:ids => [recebimento_de_contas(:curso_de_tecnologia_do_andre).id], :dr_ou_terceirizada => RecebimentoDeConta::DR}
      response.should be_success
      response.body.should include('window.open')
    end

    it 'envia para o dr/terceirizada xls' do
      get :envio_ao_dr_terceirizada, :format => 'xls', :recebimento_de_contas => {:ids => [recebimento_de_contas(:curso_de_tecnologia_do_andre).id, recebimento_de_contas(:curso_de_design_do_paulo).id], :dr_ou_terceirizada => RecebimentoDeConta::DR}
      response.should be_success
      response.body.should include("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
    end
  end
  
  describe "form de baixa parcial" do

    it "teste da action que carrega a baixa parcial e sua view" do
      login_as :quentin
      parcela = parcelas(:primeira_parcela_recebimento)
      get :carrega_baixa_parcial, :id => parcela.conta_id, :parcela_id => parcela.id
      assigns[:parcela].should == parcela
      response.should be_success

      response.should have_tag("form[onsubmit=?]", %r{new Ajax.Request.*\/recebimento_de_contas.*\/#{parcela.conta_id}.*\/parcelas.*\/#{parcela.conta_id}.*\/baixa_parcial.*\/?parcela_id=#{parcela.id}.*}) do
        with_tag("table") do
          with_tag("input[id=?]", "data_vencimento")
          with_tag("input[id=?][onchange=?]", "parcela_data_da_baixa", %r{new Ajax.Request.*\/recebimento_de_contas.*\/atualiza_valor_baixa_parcial.*})
          with_tag("input[id=?]", "valor_liquido")
          with_tag("input[id=?]", "historico")
          with_tag("select[id=?]", "parcela_forma_de_pagamento") do
            with_tag("option[value=?]", '1', 'Dinheiro')
            with_tag("option[value=?]", '2', 'Banco')
            with_tag("option[value=?]", '3', 'Cheque')
            with_tag("option[value=?]", '4', 'Cartão')
          end
          with_tag("input[id=?]", "parcela_conta_corrente_id")
          with_tag("input[id=?][size=30]","parcela_conta_corrente_nome")
          with_tag("td[id=?]", "td_de_conta_contabil_da_conta_corrente")
          with_tag("select[id=?]", "parcela_cheques_attributes_0_prazo") do
            with_tag("option[value=?]", Cheque::VISTA, 'À Vista')
            with_tag("option[value=?]", Cheque::PRAZO, 'A Prazo')
          end
          with_tag("input[id=?]", "parcela_cheques_attributes_0_data_para_deposito")
          with_tag("input[id=?]", "parcela_cheques_attributes_0_conta_contabil_transitoria_id")
          with_tag("input[id=?][size=30]","parcela_cheques_attributes_0_conta_contabil_transitoria_nome")
          with_tag("select[id=?]", "parcela_cheques_attributes_0_banco_id") do
            with_tag('option[value=?]', bancos(:banco_caixa).id, 'Banco Caixa')
            with_tag('option[value=?]', bancos(:banco_do_brasil).id, 'Banco do Brasil')
          end
          with_tag("input[id=?]", "parcela_cheques_attributes_0_nome_do_titular")
          with_tag("input[id=?]", "parcela_cheques_attributes_0_agencia")
          with_tag("input[id=?]", "parcela_cheques_attributes_0_conta")
          with_tag("input[id=?]", "parcela_cheques_attributes_0_numero")
          with_tag("select[id=?]", "parcela_cartoes_attributes_1_bandeira") do
            with_tag('option[value=?]', '', '')
            with_tag('option[value=?]', '1', 'Visa Crédito')
            with_tag('option[value=?]', '2', 'Redecard')
            with_tag('option[value=?]', '3', 'Mastercard')
            with_tag('option[value=?]', '4', 'Diners')
            with_tag('option[value=?]', '5', 'American Express')
            with_tag('option[value=?]', '6', 'Maestro')
            with_tag('option[value=?]', '7', 'Credicard')
            with_tag('option[value=?]', '8', 'Ourocard')
            with_tag('option[value=?]', '9', 'Visa Débito')
          end
          with_tag("input[id=?]", "parcela_cartoes_attributes_1_numero")
          with_tag("input[id=?]", "parcela_cartoes_attributes_1_codigo_de_seguranca")
          with_tag("input[id=?]", "parcela_cartoes_attributes_1_validade")
          with_tag("input[id=?]", "parcela_cartoes_attributes_1_nome_do_titular")
        end
      end
      with_tag("input[type=?][value=?]", 'submit', "Salvar")
      with_tag("input[type=?][onclick*=?][value=?]", 'button', 'form_para_baixa_parcial', "Cancelar")
    end
  end

  describe "Action atualiza valor da baixa parcial" do

    it 'chamando action atualiza valor da baixa parcial' do
      @parcela = parcelas(:segunda_parcela_recebimento)
      # VENCIMENTO EM 05/08/2009
      post :atualiza_valor_baixa_parcial, :data => '05/09/2009', :id => @parcela.conta_id, :parcela_id => @parcela.id , :tipo_de_data => 'data_da_baixa'
      response.should be_success
      response.body.should include('$("valor_liquido").value = 30.91')
    end

    it 'chamando action atualiza valor da baixa parcial sem que ocorram alterações' do
      @parcela = parcelas(:segunda_parcela_recebimento)
      # VENCIMENTO EM 05/08/2009
      post :atualiza_valor_baixa_parcial, :data => '05/08/2009', :id => @parcela.conta_id, :parcela_id => @parcela.id , :tipo_de_data => 'data_da_baixa'
      response.should be_success
      response.body.should include('$("valor_liquido").value = 30.0')
    end
  end

  it 'action libera_recebimento_de_conta_fora_do_prazo' do
    login_as :quentin
    post :libera_recebimento_de_conta_fora_do_prazo, :id => recebimento_de_contas(:curso_de_design_do_paulo).id

    response.flash[:notice].should == 'Conta liberada pelo DR.'
    response.should redirect_to(recebimento_de_contas_path)
  end

  it 'action libera_recebimento_de_conta_fora_do_prazo sem permissão' do
    login_as :aaron
    post :libera_recebimento_de_conta_fora_do_prazo, :id => recebimento_de_contas(:curso_de_design_do_paulo).id

    response.should redirect_to(login_path)
  end

  it 'action libera_recebimento_de_conta_fora_do_prazo sem permissão na unidade' do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 1
    unidade.lancamentoscontasreceber = 1
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save
    login_as :quentin
    post :libera_recebimento_de_conta_fora_do_prazo, :id => recebimento_de_contas(:curso_de_design_do_paulo).id

    response.flash[:notice].should == 'Conta liberada pelo DR.'
    response.should redirect_to(recebimento_de_contas_path)
  end

end