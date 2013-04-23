require File.dirname(__FILE__) + '/../spec_helper'

describe HistoricoOperacoesController do

  describe "testando a" do   

    integrate_views

    before(:each) do
      login_as :quentin
    end

    it "action index" do
      get :index, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_cheque).id

      response.should be_success
      response.should render_template('index')

      assigns[:conta].should == pagamento_de_contas(:pagamento_cheque)
      assigns[:historico_operacoes].should == [historico_operacoes(:historico_operacao_pagamento_cheque)]
      response.should have_tag('table.listagem') do
        with_tag('tr[class=?]','impar') do
          with_tag('td', historico_operacoes(:historico_operacao_pagamento_cheque).created_at.to_s_br)
          with_tag('td', 'Carta de cobrança de 30 dias')
          with_tag('td') do
            with_tag('a[href=?][onclick*=?]','#','Element.show')
            with_tag('div[id=?][style=?]',"justificativa_#{historico_operacoes(:historico_operacao_pagamento_cheque).id}",'display:none;')
          end
          with_tag('td', 'quentin')
        end
      end
      response.should have_tag("form[method=post][action=?]", pagamento_de_conta_historico_operacoes_path(pagamento_de_contas(:pagamento_cheque).id)) do
        with_tag("input[name='historico_operacao[descricao]']")
      end
    end

    it "action create com dados completos" do
      historico_operacao = mock_model(HistoricoOperacao, :descricao => "Novo histórico operação", :usuario => usuarios(:quentin), :conta_id => pagamento_de_contas(:pagamento_cheque).id, :conta_type => "PagamentoDeConta", :justificativa=>'Pagamento em cheque referente a parcela em aberto.')
      HistoricoOperacao.should_receive(:new).with("descricao" => "Novo histórico operação").and_return historico_operacao
      historico_operacao.should_receive(:conta=).with(pagamento_de_contas(:pagamento_cheque))
      historico_operacao.should_receive(:usuario=).with(usuarios(:quentin))
      historico_operacao.should_receive(:save).and_return true

      post :create, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_cheque).id, :historico_operacao => {:descricao => "Novo histórico operação"}
      response.should redirect_to(pagamento_de_conta_historico_operacoes_path(pagamento_de_contas(:pagamento_cheque).id))
    end

    it "action create com dados incompletos" do
      historico_operacao = mock_model(HistoricoOperacao, :descricao => "", :usuario => usuarios(:quentin), :conta_id => pagamento_de_contas(:pagamento_cheque).id, :conta_type => "PagamentoDeConta", :justificativa=>'Pagamento em cheque referente a parcela em aberto.')
      HistoricoOperacao.should_receive(:new).with("descricao" => "").and_return historico_operacao
      historico_operacao.should_receive(:conta=).with(pagamento_de_contas(:pagamento_cheque))
      historico_operacao.should_receive(:usuario=).with(usuarios(:quentin))
      historico_operacao.should_receive(:save).and_return false

      post :create, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_cheque).id, :historico_operacao => {:descricao => ""}
      response.should render_template('index')
    end

  end

  describe "verifica se" do

    it "bloqueia usuario juvenal sem permissao que quer modificar dados do historico de operações, action index" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal

      get :index, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano).id
      response.should redirect_to(login_path)
    end

    it "bloqueia usuario admin sem permissao que quer modificar dados do historico de operações, action create" do
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      login_as :juvenal

      get :index, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano).id, :historico_operacao => {:descricao => "Novo histórico operação", :justificativa=>'Pagamento em dinheiro referente a parcela em aberto.'}
      response.should redirect_to(login_path)
    end

    it "bloqueia usuario com permissao que quer modificar dados de follow-up de outra unidade para a action index" do
      login_as :quentin

      get :index, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano).id
      response.should redirect_to(login_path)
    end

    it "bloqueia usuario com permissao que quer modificar dados de follow-up de outra unidade para a action create" do
      login_as :quentin

      post :create, :pagamento_de_conta_id => pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano).id, :historico_operacao => {:descricao => "Novo histórico operação", :justificativa=>'Pagamento em dinheiro referente a parcela em aberto.'}
      response.should redirect_to(login_path)
    end
  
  end

  describe "testa filtro para contas inativas" do

    before(:each) do
      login_as :quentin
      @recebimento_de_conta = recebimento_de_contas(:curso_de_design_do_paulo)
      @recebimento_de_conta.cancelar_contrato(usuarios(:quentin))
    end

    it "nao faz cria um novo follow-up" do
      post :create, :recebimento_de_conta_id => @recebimento_de_conta.id, :historico_operacao => {:justificativa => "Tentando criar um novo follow-up", :descricao => "Lalalalala!"}
      response.should redirect_to(recebimento_de_conta_path(@recebimento_de_conta.id))
    end

    it "não bloca a index de follow-up" do
      get :index, :recebimento_de_conta_id => @recebimento_de_conta.id
      response.should be_success
      response.should render_template('index')
    end

  end

end
