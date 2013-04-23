require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CartoesController do

  describe "Testa a" do

    fixtures :all
    integrate_views

    before(:each) do
      login_as :quentin
    end

    def validar_campos_form_de_busca
      with_tag('input[name=?]', 'busca[texto]')
      with_tag('select[name=?]', 'busca[situacao]')
      with_tag('select[name=?]', 'busca[bandeira]')
      with_tag('input[name=?]', 'busca[data_de_recebimento_min]')
      with_tag('input[name=?]', 'busca[data_de_recebimento_max]')
    end

    def validar_campos_form_de_baixa
      with_tag('input[name=?][value=?]', 'cartoes[data_do_pagamento]', Date.today.to_s_br)
      with_tag('input[name=?]', 'conta_corrente_id')
      with_tag('input[name=?]', 'conta_corrente_nome')
      with_tag('input[name=?]', 'cartoes[conta_contabil_id]')
      with_tag('input[name=?]', 'cartoes[conta_contabil_nome]')
      with_tag('input[name=?][value=?]', 'cartoes[historico]', "VLR REF RECEBTO FATURA DE CARTÃO DATA #{Date.today.to_s_br}")
    end

    it 'a action index' do
      get :index
      response.should be_success
    end

    it 'a action index com os campos do formulario de busca' do
      get :index
      response.should be_success

      response.should have_tag('form[action=?][method=?]', cartoes_path, 'get') do
        validar_campos_form_de_busca
      end
    end

    it 'a action index com a tabela com a listagem dos cartoes' do
      get :index, :busca => {:situacao => '1', :data_do_deposito_min => '',
        :data_do_deposito_min => '', :texto => 'Man'}
      response.should be_success

      response.should have_tag('tr[id=?][style=?]', 'tr_datas', 'display:none')
      response.should have_tag('table.listagem') do
        with_tag('td', %r{Manuel Cerqueira Lima})
        with_tag('td', %r{Visa Crédito})
        with_tag('td', %r{R\$ 25,00})
        with_tag 'td' do
          with_tag("input[onchange*=?][lang=?]", "somaValor", '25.00')
        end
      end
    end

    it 'mostra datas de depósito se pesquisa for por baixadas' do
      get :index, :busca => {:situacao => '2', :data_do_deposito_min => '',
        :data_do_deposito_min => '', :texto => 'Man'}
      response.should be_success

      response.should have_tag('tr[id=?][style=?]', 'tr_datas', '')
    end

    it 'o params[:busca] da action index' do
      get :index
      response.should be_success

      params['busca'].should == {}
    end

    it 'a action index com params[:cartoes]' do
      post :baixar, :conta_corrente_nome => 'Teste', :cartoes => {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
      response.should be_success

      params['cartoes'].should == {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
    end
    
    it 'a action index com params[:cartoes] anulando conta_contabil_id e conta_contabil_nome' do
      post :baixar, :conta_corrente_nome => '', :cartoes => {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
      response.should be_success

      params['cartoes'].should == {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => ''}
    end
    
    it 'a action baixar' do
      post :baixar
      response.should be_success
    end
    
    it 'a resposta AJAX para a action baixar se ocorrer com sucesso' do
      request.session[:ano] = 2009
      post :baixar, 'cartoes' => {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
      response.should be_success

      response.body.should == "alert(\"Dados baixados com sucesso!\");\nwindow.location.href = \"/cartoes\";"
    end
    
    it 'a resposta AJAX para a action baixar se ocorrer erro' do
      request.session[:ano] = 2009
      post :baixar, 'cartoes' => {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, ''], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
      response.should be_success

      response.body.should == "alert(#{"Você selecionou dados que já foram baixados!".to_json});"
    end

  end
  
  describe "Verifica se consegue acessar a" do
    it "action index quando usuário não possuir acesso" do
      login_as :juvenal
      get :index
      response.should redirect_to(login_path)
    end
    
    it "action baixar_abandonar_resolver quando usuário não possui acesso" do
      login_as :juvenal
      post :baixar, 'cartoes' => {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, ''], 'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
        'conta_contabil_nome' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}
      response.should redirect_to(login_path)
    end
  end

   describe 'Verifica Estorno' do
    before :each do
      login_as :quentin
      gerar_cartoes_baixados
    end

    it 'com um certo' do
      post :estornar, :cartoes=>{:ids=>[cartoes(:cartao_do_andre_primeira_parcela).id]}, :controller=>"cartoes"
      response.body.should match %r{alert\("Cart\\u00f5es estornados com sucesso!\"\);}
      response.should be_success
    end

    it 'com dois certos' do
      post :estornar, :cartoes=>{:ids=>[cartoes(:cartao_do_andre_primeira_parcela).id,cartoes(:cartao_do_andre_segunda_parcela).id]}, :controller=>"cartoes"
      response.body.should match %r{alert\("Cart\\u00f5es estornados com sucesso!\"\);}
      response.should be_success
    end

    it 'sem id' do
      post :estornar, :cartoes=>{:ids=>[]}, :controller=>"cartoes"
      response.body.should match %r{alert\("Selecione pelo menos um cart\\u00e3o para estornar!\"\);}
      response.should be_success
    end

    it 'com um cartao invalido' do
      post :estornar, :cartoes=>{:ids=>[214213412]}, :controller=>"cartoes"
      response.body.should include "alert(\"Voc\\u00ea selecionou cart\\u00f5es n\\u00e3o baixados!\");"
      response.should be_success
    end

    it 'com um cartao não baixado' do
      post :estornar, :cartoes=>{:ids=>[cartoes(:cartao_do_manuel_segunda_parcela)]}, :controller=>"cartoes"
      response.body.should include "alert(\"Voc\\u00ea selecionou cart\\u00f5es n\\u00e3o baixados!\");"
      response.should be_success
    end

    def gerar_cartoes_baixados
      Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_andre_primeira_parcela).id, cartoes(:cartao_do_andre_segunda_parcela).id], 'data_do_deposito' => '16/06/2009',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [true, "Dados baixados com sucesso!"]
    end
  end

end
