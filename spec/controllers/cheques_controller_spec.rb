require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ChequesController do

  describe "Testa a" do

    fixtures :all
    integrate_views

    before(:each) do
      login_as :quentin
    end

    def validar_campos_form_de_busca
      with_tag('input[name=?]', 'busca[texto]')
      with_tag('select[name=?]', 'busca[situacao]')
      with_tag('input[name=?]', 'busca[data_do_deposito_min]')
      with_tag('input[name=?]', 'busca[data_do_deposito_max]')
    end

    def validar_campos_form_de_baixa
      with_tag('input[name=?]', 'cheques[data_do_pagamento]')
      with_tag('input[name=?]', 'conta_corrente_id')
      with_tag('input[name=?]', 'conta_corrente_nome')
      with_tag('input[name=?]', 'cheques[conta_contabil_id]')
      with_tag('input[name=?]', 'cheques[conta_contabil_nome]')
      with_tag('input[name=?]', 'cheques[historico]')
    end

    it 'a action index' do
      get :index
      response.should be_success
    end

    it 'a action index com os campos do formulario de busca' do
      get :index
      response.should be_success

      response.should have_tag('form[action=?][method=?]', cheques_path, 'get') do
        validar_campos_form_de_busca
      end
    end

    it 'a action index com a tabela com a listagem dos cheques' do
      get :index, :busca => {:situacao => '1', :data_do_deposito_min => '', :data_do_deposito_min => '', :texto => 'Paulo'}
      response.should be_success

      response.should have_tag('table.listagem') do
        with_tag('td', %r{010203})
        with_tag('td', %r{Paulo Vitor Zeferino})
        with_tag('td', %r{05/06/2009})
        with_tag('td', %r{R\$ 50,00})
        with_tag 'td' do
          with_tag("input[type=?]", "radio")
        end
      end
    end

    it 'o params[:busca] da action index' do
      get :index
      response.should be_success
      
      params['busca'].should == {}
    end

    it 'a action show com params[:cheques]' do
      hash_cheques = {'ids' => [cheques(:vista).id],
        'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
      post :baixar_abandonar_devolver_estornar, :conta_corrente_nome => 'Teste', :cheques => hash_cheques, :tipo => 'baixar'
      response.should be_success
      
      params['cheques'].should == {'ids' => [cheques(:vista).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
    end

    it 'a action index com params[:cheques] anulando conta_contabil_id e conta_contabil_nome' do
      hash_cheques = {'ids' => [cheques(:vista).id],
        'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        'conta_corrente_nome' => '' }
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques, :tipo => 'baixar'
      response.should be_success
      
      params['cheques'].should == {'ids' => [cheques(:vista).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => '',
        'conta_corrente_id' => '', 'conta_corrente_nome' => '' }
    end

    it 'a action index com a tabela com a listagem dos cartoes' do
      get :index, :busca => {:situacao => '1', :data_do_deposito_min => '',
        :data_do_deposito_min => '', :texto => 'Man'}
      response.should be_success

      response.should have_tag('tr[id=?][style=?]', 'tr_datas', 'display:none')
    end

    it 'a action baixar' do
      post :baixar_abandonar_devolver_estornar, :tipo => 'baixar'
      response.should be_success
    end

    it 'a resposta AJAX para a action baixar se ocorrer com sucesso' do
      hash_cheques = {'ids' => [cheques(:vista).id, cheques(:prazo).id],
        'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        'conta_corrente_id' => contas_correntes(:primeira_conta).id}
      request.session[:ano] = 2009
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques, :tipo => 'baixar'
      response.should be_success
      response.body.should == "alert(\"Cheque baixado com sucesso!\");\nwindow.location.reload();"
    end

    it 'a resposta AJAX para a action baixar se ocorrer erro' do
      hash_cheques = {'ids' => [cheques(:vista).id, ''],
        'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        'conta_corrente_id' => contas_correntes(:primeira_conta).id }
      request.session[:ano] = 2009
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques, :tipo => 'baixar'
      response.should be_success
      response.body.should == "alert(#{"Você não pode baixar os cheques selecionados!".to_json});"
    end

    it 'Conseguiu fazer abandono de cheques' do
      cheque = cheques(:prazo)
      cheque.situacao = Cheque::DEVOLVIDO
      cheque.save
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      hash_cheques =  {"nome_conta_contabil_debito"=>conta_debito.nome.to_s,
        "conta_contabil_debito_id" => conta_debito.id.to_s,
        "ids" => [cheque.id.to_s],
        "historico" => "Pagamento de Cheque",
        "nome_conta_contabil_credito" => conta_credito.nome.to_s,
        "conta_contabil_credito_id" => conta_credito.id.to_s, "data_abandono" => "30/06/2009", "tipo_abandono"=>"1"}
      request.session[:ano] = 2009
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques, :tipo => 'abandonar'
      response.body.should == "alert(\"Cheque abandonado com sucesso!\");\nwindow.location.reload();"
    end

    it 'não conseguiu fazer abandono de cheques' do
      cheque = cheques(:prazo)
      cheque.situacao = Cheque::DEVOLVIDO
      cheque.save
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      hash_cheques =  {"nome_conta_contabil_debito" => conta_debito.nome.to_s,
        "conta_contabil_debito_id" => conta_debito.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento",
        "nome_conta_contabil_credito" => conta_credito.nome.to_s,
        "conta_contabil_credito_id" => conta_credito.id.to_s, "data_abandono" => "",
        "tipo_abandono"=>"1"}
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques, :tipo => 'abandonar'
      response.body.should ==  "alert(\"* O campo data do abandono deve ser preenchido\");"
    end

    it 'Conseguiu fazer devolução de cheques' do
      cheque = cheques(:prazo)
      cheque.situacao = Cheque::BAIXADO
      cheque.data_do_deposito = Date.today
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento Cheque",
        "data_do_evento" => "30/06/2009", "tipo_da_ocorrencia" => 1, "alinea" => 11}
      request.session[:ano] = 2009
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques
      response.body.should == "alert(\"Cheque devolvido com sucesso!\");\nwindow.location.reload();"
    end

    it 'não conseguiu fazer devolução de cheques' do
      cheque = cheques(:prazo)
      cheque.situacao = Cheque::BAIXADO
      cheque.data_do_deposito = Date.today
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento Cheque",
        "data_do_evento" => "", "tipo_da_ocorrencia" => 1, "alinea" => 11}
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques
      response.body.should ==  "alert(\"* O campo de data deve ser preenchido\");"
    end

  end
  
  describe "Verifica se consegue acessar a" do
    it "action index quando usuário não possuir acesso" do
      login_as :juvenal
      get :index
      response.should redirect_to(login_path)
    end
    
    it "action baixar_abandonar_resolver_estornar quando usuário não possui acesso" do
      login_as :juvenal
      cheque = cheques(:prazo)
      cheque.situacao = Cheque::BAIXADO
      cheque.data_do_deposito = Date.today
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento Cheque",
        "data_do_evento" => "30/06/2009", "tipo_da_ocorrencia" => 1, "alinea" => 11}
      post :baixar_abandonar_devolver_estornar, :cheques => hash_cheques
      response.should redirect_to(login_path)
    end
  end

  describe 'Verifica estorno' do
    before :each do
      login_as :quentin
      gerar_cheques_baixados
    end

    it 'com tudo certo' do
      post :baixar_abandonar_devolver_estornar, :cheques=>{:ids=>[cheques(:cheque_do_andre_primeira_parcela).id]}, :controller=>"cheques", :tipo => 'estornar'
      response.body.should match %r{alert\("Cheque estornado com sucesso!"\);}
      response.should be_success
    end

    it 'sem id' do
      post :baixar_abandonar_devolver_estornar, :controller=>"cheques", :tipo => 'estornar'
      response.body.should match %r{alert\("Selecione pelo menos um cheque para estornar!"\);}
      response.should be_success
    end

    it 'com um cheque invalido' do
      post :baixar_abandonar_devolver_estornar, :cheques=>{:ids=>[11516215]}, :controller=>"cheques", :tipo => 'estornar'
      response.body.should match %r{alert\("Voc\\u00ea n\\u00e3o pode baixar os cheques selecionados!"\);}
      response.should be_success
    end

    it 'com um cheque não baixado' do
      cheque = Cheque.first :conditions=>"situacao=#{Cheque::BAIXADO}"
      cheque.situacao = Cheque::GERADO
      cheque.save false
      post :baixar_abandonar_devolver_estornar, :cheques=>{:ids=>[cheque.id]}, :controller=>"cheques", :tipo => 'estornar'
      response.body.should match %r{alert\("Cheque estornado com sucesso!"\);}
      response.should be_success
    end

    it 'com um cheque reapresentado' do
      cheque = Cheque.first :conditions=>"situacao=#{Cheque::BAIXADO}"
      cheque.situacao=Cheque::REAPRESENTADO
      cheque.save false
      post :baixar_abandonar_devolver_estornar, :cheques=>{:ids=>[cheque.id]}, :controller=>"cheques", :tipo => 'estornar'
      response.body.should match %r{alert\("Cheque estornado com sucesso!"\);}
      response.should be_success
    end

    def gerar_cheques_baixados
      Cheque.baixar(2009, {'ids' => [cheques(:cheque_do_andre_primeira_parcela).id,cheques(:cheque_do_andre_segunda_parcela).id], 'data_do_deposito' => Date.today.to_s_br,
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id)
    end
  end

end
