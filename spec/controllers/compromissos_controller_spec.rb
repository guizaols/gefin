require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CompromissosController do

  fixtures :all

  integrate_views  

  it "verifica se existe a action index e verifica se a action index lista somente os compromissos do dia" do
    login_as :quentin
    Date.stub!(:today).and_return Date.new 2009,2,10     
    get :index ,:unidade_id => unidades(:senaivarzeagrande).id
    assigns[:compromissos].should == [compromissos(:ligar_para_o_cliente)]
    response.should be_success
  end

  it "verifica se existe a action new e cria o compromisso com sucesso" do
    login_as :quentin
    get :new, :conta_id => recebimento_de_contas(:curso_de_corel_do_paulo).id
    response.should be_success
    response.should have_tag("input[name=?][type=?][value=?]",'compromisso[conta_id]','hidden',recebimento_de_contas(:curso_de_corel_do_paulo).id)
    response.should have_tag("input[name=?]",'compromisso[data_agendada]')
    response.should have_tag("select[name=?]",'compromisso[descricao]')
    response.should have_tag("input[type=?]",'submit')
  end

  it "verifica se existe a action new e cria o compromisso sem sucesso" do
    login_as :quentin
    get :new, :conta_id => ""
    response.should render_template('new')
  end
  
  it "veirifica se existe a action create e se esta salvando os dados com sucesso" do
    login_as :quentin
    lambda do
      post :create, :compromisso => {:conta_id => recebimento_de_contas(:curso_de_corel_do_paulo).id, :data_agendada => '01/02/2009', :descricao =>'Ligar para o cliente'}
    end.should change(Compromisso, :count).by(1)
    response.should redirect_to(recebimento_de_conta_path(recebimento_de_contas(:curso_de_corel_do_paulo).id))
  end
  
  it "vertifica se existe a action create e se não está salvando os dados com sucesso" do
    login_as :quentin
    lambda do
      post :create, :compromisso => {:conta_id => recebimento_de_contas(:curso_de_corel_do_paulo).id, :data_agendada => '', :descricao => 'Ligara para o cliente'}   
    end.should_not change(Compromisso, :count)
    response.should render_template('new')
  end
  
  describe "Verifica se consegue acessar a" do
    it "action index quando o usuário não possui acesso" do
      login_as :juvenal
      get :index, :conta_id => ""
      response.should redirect_to(login_path)
    end
    
    it "action new quando o usuário não possui acesso" do
      login_as :juvenal
      get :new, :conta_id => ""
      response.should redirect_to(login_path)
    end
    
    it "action baixar_abandonar_resolver quando o usuário não possui acesso" do
      login_as :juvenal
      post :create, :compromisso => {:conta_id => recebimento_de_contas(:curso_de_corel_do_paulo).id, :data_agendada => '', :descricao => 'Ligara para o cliente'}   
      response.should redirect_to(login_path)
    end
  end












































  describe '' do
    before :each do
      Date.stub!(:today).and_return Date.new 2009,2,18
    end

    describe 'index aparece integra' do
      it 'para quentin' do
        login_as :quentin
        get :index
        response.should be_success
        response.should render_template('index')
        response.should have_tag('h1','Compromissos do dia')
        response.should have_tag('form[action=?][method=?][onsubmit=?]','/compromissos/update_tabela_compromissos','post',%r{new Ajax.Request\('\/compromissos\/update_tabela_compromissos'.*}) do
          with_tag 'tr' do
            with_tag 'td','Pesquisa Por Contrato:'
            with_tag 'td' do
              with_tag 'input[id=?][type=hidden][name=?]','compromisso_conta_id','compromisso[conta_id]'
              with_tag 'input[id=?][type=text]','compromisso_nome_conta'
            end
          end
          with_tag 'tr' do
            with_tag 'td','Data Agendada:'
            with_tag 'td' do
              with_tag 'input[type=text][value=?][name=?][id=?]',Date.today.to_s_br,'busca[data_min]','busca_data_min'
              with_tag 'input[type=text][value=?][name=?][id=?]',Date.today.to_s_br,'busca[data_max]','busca_data_max'
            end
          end
          with_tag 'tr' do
            with_tag 'td'
            with_tag 'td' do
              with_tag 'input[type=?][name=?]','submit','commit'
            end
          end
        end
        with_tag 'div[id=?]','tabela_lista_de_compromissos' do
          with_tag 'table' do
            with_tag 'thead' do
              with_tag 'tr'
              with_tag 'tr' do
                with_tag 'th','Contrato'
                with_tag 'th','Cliente'
                with_tag 'th','Descrição'
                with_tag 'th' do
                  with_tag 'a[href=?]','/compromissos/new?tipo=1'
                end
              end
            end
            with_tag 'tr[class=?]','impar' do
              with_tag 'td' do
                with_tag 'a[href=?]','/recebimento_de_contas/428773600','SVG-CTR09/09000788'
              end
              with_tag 'td' do
                with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
              end
              with_tag 'td','Retornar Ligação'
              with_tag 'td' do
                with_tag 'a[href=?]','/compromissos/1015241196/edit'
                with_tag 'a[onclick=?][href=?]', %r{.*'Confirma a exclusão\?'.*POST.*}, '/compromissos/1015241196'
              end
            end
          end
        end
      end
      it 'para juvenal' do
        login_as :juvenal
        get :index
        response.should redirect_to(login_path)
      end
    end

    describe 'a form aparece integra para new a partir de contas a receber' do
      it 'para quentin' do
        login_as :quentin
        get :new,:conta_id=>52315426
        response.should be_success
        response.should render_template('new')
        response.should have_tag 'h1','Novo Agendamento'
        response.should have_tag 'form[action=?]','/compromissos' do
          with_tag 'input[type=hidden][value=?][name=?][id=?]','52315426','compromisso[conta_id]','compromisso_conta_id'
          with_tag 'table' do
            with_tag 'tr' do
              with_tag 'th','Data'
              with_tag 'td' do
                with_tag 'input[type=text][value=?][name=?][id=?]',Date.today.to_s_br,'compromisso[data_agendada]','compromisso_data_agendada'
              end
              with_tag 'th','Descrição'
              with_tag 'td' do
                with_tag 'select[id=?][name=?]','compromisso_descricao','compromisso[descricao]' do
                  with_tag 'option[value=?]',''
                  with_tag 'option[value=?]','Enviar Carta Jurídica','Enviar Carta Jurídica'
                end
              end
            end
            with_tag 'tr' do
              with_tag 'td' do
                with_tag 'input[type=submit]'
                with_tag 'a[href=?]','/recebimento_de_contas/52315426','Voltar'
              end
            end
          end
        end
      end
      it 'para juvenal' do
        login_as :juvenal
        get :new
        response.should redirect_to(login_path)
      end
    end

    describe 'a form aparece integra para new a partir de agendamentos' do
      it 'para quentin' do
        login_as :quentin
        get :new,:tipo=>1
        response.should be_success
        teste_new
      end
      it 'para juvenal' do
        login_as :juvenal
        get :new
        response.should redirect_to(login_path)
      end
    end

    def teste_new
      response.should render_template('new')
      response.should have_tag 'h1','Novo Agendamento'
      response.should have_tag 'form[action=?]','/compromissos' do
        with_tag 'table' do
          with_tag 'tr' do
            with_tag 'th','Data'
            with_tag 'td' do
              with_tag 'input[type=text][value=?][name=?][id=?]',Date.today.to_s_br,'compromisso[data_agendada]','compromisso_data_agendada'
            end
            with_tag 'th','Descrição'
            with_tag 'td' do
              with_tag 'select[id=?][name=?]','compromisso_descricao','compromisso[descricao]' do
                with_tag 'option[value=?]',''
                with_tag 'option[value=?]','Enviar Carta Jurídica','Enviar Carta Jurídica'
              end
            end
          end
          with_tag 'tr' do
            with_tag 'td' do
              with_tag 'input[type=text][name=?][id=?]','busca[texto]','busca_texto'
              with_tag 'select' do
                # with_tag 'option[value=?]','pessoas.nome','Cliente'
                with_tag 'option[value=?]','situacao','Pesquisar por - Situação'
              end
              with_tag 'input[type=submit][value=?]','Pesquisar'
            end
          end
        end
        with_tag 'table' do
          with_tag 'tr[class=?]','impar' do
            with_tag 'td' do
              with_tag 'input[type=radio][value=?][name=?][checked=?]','992150789','contas[ids][]','checked'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/recebimento_de_contas/992150789','SVG-CPMF09/09111555'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
            end
            with_tag 'td','Curso de Flex'
            with_tag 'td','31/12/2009'
            with_tag 'td','90,00'
            with_tag 'td','3'
            with_tag 'td','Normal'
          end
          with_tag 'tr[class=?]','par'
          with_tag 'tr[class=?]','impar'
          with_tag 'tr[class=?]','par'
          with_tag 'tr[class=?]','impar'
          with_tag 'tr[class=?]','par' do
            with_tag 'td' do
              with_tag 'input[type=radio][value=?][name=?]','706236413','contas[ids][]'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/recebimento_de_contas/706236413','SVG-CTR09/09000777'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
            end
            with_tag 'td','Curso de Ruby on Rails'
            with_tag 'td','30/04/2009'
            with_tag 'td','90,00'
            with_tag 'td','2'
            with_tag 'td','Normal'
          end
          with_tag 'tr[class=?]','impar'
          with_tag 'tr[class=?]','par'
        end
        with_tag 'input[type=submit][value=?]','Salvar'
        with_tag 'a[href=?]','/compromissos','Voltar'
      end
    end

    it 'a new deve redirecionar caso esse novo compromisso não tiver vindo dos agendamentos ou de contas a receber' do
      login_as :quentin
      get :new
      response.should redirect_to compromissos_path
    end

    describe 'a form aparece integra para edit' do
      it 'para quentin' do
        login_as :quentin
        get :edit,:id=>compromissos(:ligar_para_o_cliente).id
        teste_edit
      end
      it 'para juvenal' do
        login_as :juvenal
        get :new
        response.should redirect_to(login_path)
      end
    end

    def teste_edit
      comp = compromissos(:ligar_para_o_cliente)
      response.should be_success
      response.should render_template('edit')
      response.should have_tag 'h1','Alterar Agendamento'
      response.should have_tag 'form[action=?]','/compromissos/867906719' do
        with_tag 'input[type=hidden][value=?][name=?][id=?]','1','tipo','tipo'
        with_tag 'input[type=hidden][value=?][name=?][id=?]',comp.conta_id,'compromisso[conta_id]','compromisso_conta_id'
        with_tag 'table' do
          with_tag 'tr' do
            with_tag 'th','Data'
            with_tag 'td' do
              with_tag 'input[type=text][value=?][name=?][id=?]',comp.data_agendada,'compromisso[data_agendada]','compromisso_data_agendada'
            end
            with_tag 'th','Descrição'
            with_tag 'td' do
              with_tag 'select[id=?][name=?]','compromisso_descricao','compromisso[descricao]' do
                with_tag 'option[value=?]',''
                with_tag 'option[value=?]','Enviar Carta Jurídica','Enviar Carta Jurídica'
                with_tag 'option[value=?][selected=selected]','Ligar para o Cliente','Ligar para o Cliente'
              end
            end
          end
          with_tag 'tr' do
            with_tag 'td' do
              with_tag 'input[type=text][name=?][id=?]','busca[texto]','busca_texto'
              with_tag 'select' do
                # with_tag 'option[value=?]','pessoas.nome','Cliente'
                with_tag 'option[value=?]','situacao','Pesquisar por - Situação'
              end
              with_tag 'input[type=submit][value=?]','Pesquisar'
            end
          end
        end
        with_tag 'table' do
          with_tag 'tr[class=?]','impar' do
            with_tag 'td' do
              without_tag 'input[type=radio][value=?][name=?][checked=?]','992150789','contas[ids][]','checked'
              with_tag 'input[type=radio][value=?][name=?]','992150789','contas[ids][]'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/recebimento_de_contas/992150789','SVG-CPMF09/09111555'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
            end
            with_tag 'td','Curso de Flex'
            with_tag 'td','31/12/2009'
            with_tag 'td','90,00'
            with_tag 'td','3'
            with_tag 'td','Normal'
          end
          with_tag 'tr[class=?]','par'
          with_tag 'tr[class=?]','impar'
          with_tag 'tr[class=?]','par' do
            with_tag 'td' do
              with_tag 'input[type=radio][value=?][name=?][id=?][checked=?]','52315426','contas[ids][]','rb_52315426','checked'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/recebimento_de_contas/52315426','SVG-CTR09/09000791'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
            end
            with_tag 'td','Curso de Ruby on Rails'
            with_tag 'td','01/01/2009'
            with_tag 'td','90,00'
            with_tag 'td','2'
            with_tag 'td','Normal'
          end
          with_tag 'tr[class=?]','impar'
          with_tag 'tr[class=?]','par' do
            with_tag 'td' do
              without_tag 'input[type=radio][value=?][name=?][checked=?]','428773600','contas[ids][]','checked'
              with_tag 'input[type=radio][value=?][name=?]','428773600','contas[ids][]'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/recebimento_de_contas/428773600','SVG-CTR09/09000788'
            end
            with_tag 'td' do
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
            end
            with_tag 'td','Curso de Eletronica Digital'
            with_tag 'td','01/01/2009'
            with_tag 'td','100,00'
            with_tag 'td','2'
            with_tag 'td','Normal'
          end
          with_tag 'tr[class=?]','impar'
          with_tag 'tr[class=?]','par'
        end
        with_tag 'input[type=submit][value=?]','Salvar'
        with_tag 'a[href=?]','/compromissos','Voltar'
      end
    end

    describe 'o agendamento de compromissos acontece como o esperado' do
      it 'com o quentin para pesquisa vazia' do
        login_as :quentin
        post :create, :commit => 'Pesquisar', :busca => ""
        response.should be_success
        teste_new
      end

      it 'com o juvenal para pesquisa vazia' do
        login_as :juvenal
        post :create, :commit => 'Pesquisar'
        response.should redirect_to(login_path)
      end

      it 'com o quentin para pesquisa por cliente' do
        login_as :quentin
        post :create, :commit => 'Pesquisar', :busca => { :ordem => "pessoas.nome", :texto => "Paul" }
        response.should be_success
        response.should render_template('new')
        response.should have_tag 'h1','Novo Agendamento'
        response.should have_tag 'form[action=?]','/compromissos' do
          with_tag 'table' do
            with_tag 'tr' do
              with_tag 'th','Data'
              with_tag 'td' do
                with_tag 'input[type=text][value=?][name=?][id=?]',Date.today.to_s_br,'compromisso[data_agendada]','compromisso_data_agendada'
              end
              with_tag 'th','Descrição'
              with_tag 'td' do
                with_tag 'select[id=?][name=?]','compromisso_descricao','compromisso[descricao]' do
                  with_tag 'option[value=?]',''
                  with_tag 'option[value=?]','Enviar Carta Jurídica','Enviar Carta Jurídica'
                end
              end
            end
            with_tag 'tr' do
              with_tag 'td' do
                with_tag 'input[type=text][name=?][id=?]','busca[texto]','busca_texto'
                with_tag 'select' do
                  # with_tag 'option[value=?]','pessoas.nome','Cliente'
                  with_tag 'option[value=?]','situacao','Pesquisar por - Situação'
                end
                with_tag 'input[type=submit][value=?]','Pesquisar'
              end
            end
          end
          with_tag 'table' do
            with_tag 'tr[class=?]','impar' do
              with_tag 'input[type=radio][value=?][name=?][id=?][checked=checked]','52315426','contas[ids][]','rb_52315426'
              with_tag 'a[href=?]','/recebimento_de_contas/52315426','SVG-CTR09/09000791'
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
              with_tag 'td','Curso de Ruby on Rails'
              with_tag 'td','01/01/2009'
              with_tag 'td','50,00'
              with_tag 'td','2'
              with_tag 'td','Normal'
            end
            with_tag 'tr[class=?]','par' do
              without_tag 'input[type=radio][checked=checked]'
              with_tag 'input[type=radio][value=?][name=?][id=?]','428773600','contas[ids][]','rb_428773600'
              with_tag 'a[href=?]','/recebimento_de_contas/428773600','SVG-CTR09/09000788'
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
              with_tag 'td','Curso de Eletronica Digital'
              with_tag 'td','01/01/2009'
              with_tag 'td','100,00'
              with_tag 'td','2'
              with_tag 'td','Normal'
            end
          end
          with_tag 'input[type=submit][value=?]','Salvar'
          with_tag 'a[href=?]','/compromissos','Voltar'
        end
      end

      it 'com o juvenal para pesquisa por cliente' do
        login_as :juvenal
        post :create,:commit=>'Pesquisar',:busca=>{:ordem=>"pessoas.nome", :"texto"=>"Paul"}
        response.should redirect_to(login_path)
      end

      it 'com o quentin e um compromisso criado atraves da tela de agendamento com tudo certo' do
        login_as :quentin
        post :create, :tipo=>'1', :contas=>{"ids"=>[RecebimentoDeConta.last.id]}, :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC"}
        response.should redirect_to compromissos_path
      end

      it 'com o juvenal e um compromisso criado atraves da tela de agendamento com tudo certo' do
        login_as :juvenal
        post :create, :tipo=>'1', :contas=>{"ids"=>[RecebimentoDeConta.last.id]}, :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC"}
        response.should redirect_to(login_path)
      end

      it 'com o quentin e um compromisso criado atraves da tela de contas a receber com tudo certo' do
        login_as :quentin
        post :create, :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC", :conta_id=>RecebimentoDeConta.last.id}
        response.should redirect_to recebimento_de_conta_path(RecebimentoDeConta.last.id)
      end

      it 'com o juvenal e um compromisso criado atraves da tela de contas a receber com tudo certo' do
        login_as :juvenal
        post :create, :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC", :conta_id=>RecebimentoDeConta.last.id}
        response.should redirect_to(login_path)
      end

      it 'com o quentin e um compromissos inválidos através da tela de agendamento' do
        login_as :quentin
        teste_create = lambda do |params|
          post :create, params
          response.should be_success
          response.should render_template('new')
        end
        teste_create.call :tipo=>'1', :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC"}
        teste_create.call :tipo=>'1', :contas=>{"ids"=>[RecebimentoDeConta.last.id]}, :compromisso=>{:descricao=>"Cliente Negativado no SPC"}
        teste_create.call :tipo=>'1', :contas=>{"ids"=>[RecebimentoDeConta.last.id]}, :compromisso=>{:data_agendada=>"19/02/2010"}
        teste_create.call :conta_id=>RecebimentoDeConta.last.id, :compromisso=>{:data_agendada=>"19/02/2010"}
        teste_create.call :conta_id=>RecebimentoDeConta.last.id, :compromisso=>{:descricao=>"Cliente Negativado no SPC"}
      end

      it 'com o juvenal e um compromissos inválidos através da tela de agendamento' do
        login_as :juvenal
        teste_create = lambda do |params|
          post :create, params
          response.should redirect_to(login_path)
        end
        teste_create.call :tipo=>'1', :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC"}
        teste_create.call :tipo=>'1', :contas=>{"ids"=>[RecebimentoDeConta.last.id]}, :compromisso=>{:descricao=>"Cliente Negativado no SPC"}
        teste_create.call :tipo=>'1', :contas=>{"ids"=>[RecebimentoDeConta.last.id]}, :compromisso=>{:data_agendada=>"19/02/2010"}
        teste_create.call :conta_id=>RecebimentoDeConta.last.id, :compromisso=>{:data_agendada=>"19/02/2010"}
        teste_create.call :conta_id=>RecebimentoDeConta.last.id, :compromisso=>{:descricao=>"Cliente Negativado no SPC"}
      end
    end

    describe 'a alteracao de compromisso deve acontecer como previsto' do
      it 'com o quentin para pesquisa vazia' do
        login_as :quentin
        put :update,:id=>compromissos(:ligar_para_o_cliente).id,:commit=>'Pesquisar'
        teste_edit
      end

      it 'com o juvenal para pesquisa vazia' do
        login_as :juvenal
        put :update,:id=>compromissos(:ligar_para_o_cliente).id,:commit=>'Pesquisar'
        response.should redirect_to(login_path)
      end

      it 'com o quentin para pesquisa por cliente' do
        comp = compromissos(:ligar_para_o_cliente)
        login_as :quentin
        put :update,:id=>comp.id,:commit=>'Pesquisar',:busca=>{:ordem=>"pessoas.nome", :"texto"=>"Paul"}
        response.should be_success
        response.should render_template('edit')
        response.should have_tag 'h1','Alterar Agendamento'
        response.should have_tag 'form[action=?]','/compromissos/867906719' do
          with_tag 'input[type=hidden][value=?][name=?][id=?]','1','tipo','tipo'
          with_tag 'input[type=hidden][value=?][name=?][id=?]',comp.conta_id,'compromisso[conta_id]','compromisso_conta_id'
          with_tag 'table' do
            with_tag 'tr' do
              with_tag 'th','Data'
              with_tag 'td' do
                with_tag 'input[type=text][value=?][name=?][id=?]',comp.data_agendada,'compromisso[data_agendada]','compromisso_data_agendada'
              end
              with_tag 'th','Descrição'
              with_tag 'td' do
                with_tag 'select[id=?][name=?]','compromisso_descricao','compromisso[descricao]' do
                  with_tag 'option[value=?]',''
                  with_tag 'option[value=?]','Enviar Carta Jurídica','Enviar Carta Jurídica'
                  with_tag 'option[value=?][selected=selected]','Ligar para o Cliente','Ligar para o Cliente'
                end
              end
            end
            with_tag 'tr' do
              with_tag 'td' do
                with_tag 'input[type=text][name=?][id=?]','busca[texto]','busca_texto'
                with_tag 'select' do
                  # with_tag 'option[value=?]','pessoas.nome','Cliente'
                  with_tag 'option[value=?]','situacao','Pesquisar por - Situação'
                end
                with_tag 'input[type=submit][value=?]','Pesquisar'
              end
            end
          end
          with_tag 'table' do
            with_tag 'tr[class=?]','impar' do
              with_tag 'input[type=radio][value=?][name=?][id=?][checked=checked]','52315426','contas[ids][]','rb_52315426'
              with_tag 'a[href=?]','/recebimento_de_contas/52315426','SVG-CTR09/09000791'
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
              with_tag 'td','Curso de Ruby on Rails'
              with_tag 'td','01/01/2009'
              with_tag 'td','50,00'
              with_tag 'td','1'
              with_tag 'td','Normal'
            end
            with_tag 'tr[class=?]','par' do
              without_tag 'input[type=radio][checked=checked]'
              with_tag 'a[href=?]','/recebimento_de_contas/428773600','SVG-CTR09/09000788'
              with_tag 'a[href=?]','/pessoas/253499541','Paulo Vitor Zeferino'
              with_tag 'td','Curso de Ruby on Rails'
              with_tag 'td','01/01/2009'
              with_tag 'td','90,00'
              with_tag 'td','2'
              with_tag 'td','Normal'
            end
          end
          with_tag 'input[type=submit][value=?]','Salvar'
          with_tag 'a[href=?]','/compromissos','Voltar'
        end
      end

      it 'com o juvenal para pesquisa por cliente' do
        login_as :juvenal
        put :update,:id=>compromissos(:ligar_para_o_cliente).id,:commit=>'Pesquisar',:busca=>{:ordem=>"pessoas.nome", :"texto"=>"Paul"}
        response.should redirect_to(login_path)
      end

      it 'com o quentin e um compromisso criado atraves da tela de agendamento com tudo certo' do
        login_as :quentin
        put :update, :id=>Compromisso.last.id, :contas=>{"ids"=>[Compromisso.last.conta.id]}, :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC"}
        response.should redirect_to compromissos_path
      end

      it 'com o juvenal e um compromisso criado atraves da tela de agendamento com tudo certo' do
        login_as :juvenal
        put :update, :id=>Compromisso.last.id, :contas=>{"ids"=>[Compromisso.last.conta.id]}, :compromisso=>{:data_agendada=>"19/02/2010", :descricao=>"Cliente Negativado no SPC"}
        response.should redirect_to(login_path)
      end

    end

    it 'quentin testa a destruicao do compromisso' do
      login_as :quentin
      lambda do
        delete :destroy, :id=>compromissos(:ligar_para_o_cliente).id
      end.should change(Compromisso,:count).by(-1)
      response.should redirect_to compromissos_path
    end

    it 'juvenal testa a destruicao do compromisso' do
      login_as :juvenal
      lambda do
        delete :destroy, :id=>compromissos(:ligar_para_o_cliente).id
      end.should change(Compromisso,:count).by(0)
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do auto_complete_for_contas_a_receber com argumento' do
      login_as :quentin
      post :auto_complete_for_contas_a_receber, :argumento=>'5'
      response.should be_success
      response.body.should == '<ul><li id=652221520>SVG-CTR09/09888555</li><li id=992150789>SVG-CPMF09/09111555</li></ul>'
    end

    it 'juvenal testa o funcionamento do auto_complete_for_contas_a_receber com argumento' do
      login_as :juvenal
      post :auto_complete_for_contas_a_receber, :argumento=>'5'
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do auto_complete_for_contas_a_receber sem argumento' do
      login_as :quentin
      post :auto_complete_for_contas_a_receber
      response.should be_success
      response.body.should == '<ul><li id=52315426>SVG-CTR09/09000791</li><li id=55791335>SVG-CTR09/09000798</li><li id=428773600>SVG-CTR09/09000788</li><li id=652221520>SVG-CTR09/09888555</li><li id=706236413>SVG-CTR09/09000777</li><li id=978756512>SVG-CPMF09/09762444</li><li id=992150789>SVG-CPMF09/09111555</li><li id=1053731170>SVG-CTR09/09000987</li></ul>'
    end

    it 'juvenal testa o funcionamento do auto_complete_for_contas_a_receber sem argumento' do
      login_as :juvenal
      post :auto_complete_for_contas_a_receber
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do auto_complete_for_contas_a_receber com argumento sem correspondente' do
      login_as :quentin
      post :auto_complete_for_contas_a_receber, :argumento=>'asdasdasdasd'
      response.should be_success
      response.body.should == '<ul></ul>'
    end

    it 'juvenal testa o funcionamento do auto_complete_for_contas_a_receber com argumento sem correspondente' do
      login_as :juvenal
      post :auto_complete_for_contas_a_receber, :argumento=>'asdasdasdasd'
      response.should redirect_to login_path
    end

    def deve_retornar_dois_compromissos(params=nil)
      login_as :quentin
      post :update_tabela_compromissos,params
      response.should be_success
      response.body.should match %r{.*SVG-CTR09\/09000788.*Paulo Vitor Zeferino.*Retornar Liga.*}
      response.body.size.should == 1405
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos sem parametros' do
      deve_retornar_dois_compromissos
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos sem parametros' do
      login_as :juvenal
      post :update_tabela_compromissos
      response.should redirect_to login_path
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por data mínima' do
      login_as :juvenal
      post :update_tabela_compromissos,:busca=>{:data_min=>'02/02/2002'}
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos com busca por data mínima inválida' do
      deve_retornar_dois_compromissos :busca=>{:data_min=>'asdasd'}
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por data mínima inválida' do
      login_as :juvenal
      post :update_tabela_compromissos,:busca=>{:data_min=>'asdasd'}
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos com busca por data máxima' do
      deve_retornar_dois_compromissos :busca=>{:data_max=>'12/12/2012'}
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por data máxima' do
      login_as :juvenal
      post :update_tabela_compromissos,:busca=>{:data_max=>'12/12/2012'}
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos com busca por data máxima inválida' do
      deve_retornar_dois_compromissos :busca=>{:data_max=>'asdasd'}
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por data máxima inválida' do
      login_as :juvenal
      post :update_tabela_compromissos,:busca=>{:data_max=>'asdasd'}
      response.should redirect_to login_path
    end

    def deve_retornar_o_ligar_para_cliente(params)
      login_as :quentin
      post :update_tabela_compromissos, params
      response.should be_success
      response.body.should match %r{Element.update\("tabela_lista_de_compromissos", "<table.*SVG-CTR09\/09000791.*}
      response.body.size.should == 1396
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por contrato' do
      login_as :juvenal
      conta = compromissos(:ligar_para_o_cliente).conta
      post :update_tabela_compromissos,:compromisso=>{:nome_conta=>conta.numero_de_controle, :conta_id=>conta.id}
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos com busca por contrato sem nome' do
      deve_retornar_dois_compromissos :compromisso=>{:conta_id=>compromissos(:ligar_para_o_cliente).conta.id}
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por contrato sem nome' do
      login_as :juvenal
      post :update_tabela_compromissos,:compromisso=>{:conta_id=>compromissos(:ligar_para_o_cliente).conta.id}
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos com busca por contrato sem id' do
      deve_retornar_dois_compromissos :compromisso=>{:nome_conta=>compromissos(:ligar_para_o_cliente).conta.numero_de_controle}
    end

    it 'juvenal testa o funcionamento do update_tabela_compromissos com busca por contrato sem id' do
      login_as :juvenal
      post :update_tabela_compromissos,:compromisso=>{:nome_conta=>compromissos(:ligar_para_o_cliente).conta.numero_de_controle}
      response.should redirect_to login_path
    end

    it 'quentin testa o funcionamento do update_tabela_compromissos com busca por contrato e data mínima e data máxima' do
      conta = compromissos(:ligar_para_o_cliente).conta
      deve_retornar_o_ligar_para_cliente :compromisso=>{:nome_conta=>conta.numero_de_controle, :conta_id=>conta.id},:busca=>{:data_min=>'02/02/2002',:data_max=>'12/12/2012'}
    end
  end
end
