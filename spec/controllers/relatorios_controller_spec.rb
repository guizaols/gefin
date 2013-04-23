require File.dirname(__FILE__) + '/../spec_helper'

describe RelatoriosController do

  integrate_views

  before(:each) do
    login_as 'quentin'
  end


  describe 'contas a receber cliente' do

    it "testa campos de pesquisa de ordem" do
      get :contas_a_receber_cliente
      response.should be_success

      response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", contas_a_receber_cliente_relatorios_path) do
        with_tag("select[name=?]", "busca[tipo_pessoa]")
        with_tag("input[name=?]", "busca[servico_id]")
        with_tag("input[name=?]", "busca[nome_servico]")
        with_tag("input[name=?]", "busca[cliente_id]")
        with_tag("input[name=?]", "busca[nome_cliente]")
        with_tag("input[name=?]", "busca[vendido_min]")
        with_tag("input[name=?]", "busca[vendido_max]")
        #        -> situações
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", 'VINCENDA')
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", 'ATRASADA')        
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::QUITADA)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::CANCELADA)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::PERMUTA)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::JURIDICO)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::RENEGOCIADA)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::CANCELADA)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::BAIXA_DO_CONSELHO)
        with_tag("input[name=?][value=?]", "busca[situacao_das_parcelas][]", Parcela::DESCONTO_EM_FOLHA)
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it "testa geração de pdf" do
      get :contas_a_receber_cliente, :format => 'pdf', :busca => {'tipo_pessoa' => '', 'nome_servico' => '', 'servico_id' => '', 'cliente_id' => '', 'nome_cliente' => '',
        'vendido_min' => '', 'vendido_max' => '', 'situacao_das_parcelas' => [], 'situacao_das_contas' => []}, :tipo=>'pdf'
      response.should be_success

      assigns[:titulo].should == "HISTÓRICO DO CLIENTE"
    end

    it "testa geração de Excel" do
      get :contas_a_receber_cliente, :format => 'js', :busca => {'tipo_pessoa' => '', 'nome_servico' => '', 'servico_id' => '', 'cliente_id' => '', 'nome_cliente' => '',
        'vendido_min' => '', 'vendido_max' => '', 'situacao_das_parcelas' => [], 'situacao_das_contas' => []}, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/contas_a_receber_cliente.xls')
      response.body.should_not include('alert')
    end

    it "testa chamada AJAX quando há pessoas" do
      get :contas_a_receber_cliente, :format => 'js', :busca => {'tipo_pessoa' => '', 'nome_servico' => '', 'servico_id' => '', 'cliente_id' => '', 'nome_cliente' => '',
        'vendido_min' => '', 'vendido_max' => '', 'situacao_das_parcelas' => [], 'situacao_das_contas' => []}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('window.open')
      response.body.should_not include('alert')
    end

    it "testa geração de Excel quando há pessoas" do
      get :contas_a_receber_cliente, :format => 'js', :busca => {'tipo_pessoa' => '', 'nome_servico' => '', 'servico_id' => '', 'cliente_id' => '', 'nome_cliente' => '',
        'vendido_min' => '', 'vendido_max' => '', 'situacao_das_parcelas' => [], 'situacao_das_contas' => []}, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open')
      response.body.should_not include('alert')
    end

    it "testa chamada AJAX quando não há pessoas" do
      RecebimentoDeConta.delete_all "pessoa_id=#{pessoas(:andre).id}"
      get :contas_a_receber_cliente, :format => 'js', :busca => {'tipo_pessoa' => '', 'nome_servico' => 'Curso de Ruby on Rails', 'servico_id' => servicos(:curso_de_tecnologia).id, 'cliente_id' => '', 'nome_cliente' => '',
        'vendido_min' => '', 'vendido_max' => '', 'situacao_das_parcelas' => [], 'situacao_das_contas' => []}, :tipo=>'xls'
      response.should be_success
      response.body.should include("Não foram encontrados registros com estes parâmetros.".to_json)
    end

    it "testa chamada Excel quando não há pessoas" do
      RecebimentoDeConta.delete_all "pessoa_id=#{pessoas(:andre).id}"
      get :contas_a_receber_cliente, :format => 'js', :busca => {'tipo_pessoa' => '', 'nome_servico' => 'Curso de Ruby on Rails', 'servico_id' => servicos(:curso_de_tecnologia).id, 'cliente_id' => '', 'nome_cliente' => '',
        'vendido_min' => '', 'vendido_max' => '', 'situacao_das_parcelas' => [], 'situacao_das_contas' => []}, :tipo=>'xls'
      response.should be_success
      response.body.should include("Não foram encontrados registros com estes parâmetros.".to_json)
    end


  end

  describe 'historico renegociacoes' do

    it "deve trazer as renegociacoes mesmo que não sejam passados outros parametros fora a unidade" do
      get :historico_renegociacoes, :format => 'js', :busca=>{"numero_de_controle"=>""},:tipo=>'pdf'
      response.should be_success
      response.body.should include("alert(\"N\\u00e3o foram encontrados registros com estes par\\u00e2metros.\");")

      recebimento_renegociado = recebimento_de_contas(:curso_de_design_do_paulo)
      recebimento_renegociado.numero_de_renegociacoes = 1
      recebimento_renegociado.save false

      get :historico_renegociacoes, :format => 'js', :busca=>{"numero_de_controle"=>""},:tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/historico_renegociacoes.pdf?busca')

      recebimento_renegociado = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      recebimento_renegociado.numero_de_renegociacoes = 1
      recebimento_renegociado.save false

      get :historico_renegociacoes, :format => 'js', :busca=>{"numero_de_controle"=>""},:tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/historico_renegociacoes.pdf?busca')
    end
    
    it "testa campos de pesquisa" do
      get :historico_renegociacoes
      response.should be_success

      response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", historico_renegociacoes_relatorios_path) do
        with_tag("input[name=?]", "busca[numero_de_controle]")
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end

      response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", pesquisa_historico_renegociacoes_relatorios_path) do
        with_tag("input[name=?]", "busca[texto]")
      end
    end

    it "testa geracao de relatório quando acha a conta" do
      recebimento_renegociado = recebimento_de_contas(:curso_de_design_do_paulo)
      recebimento_renegociado.numero_de_renegociacoes = 1
      recebimento_renegociado.save false

      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(numero_de_renegociacoes >= ?) AND (unidade_id = ?) AND (numero_de_controle = ?)', 1, unidades(:senaivarzeagrande).id, "SVG-CPMF09/09762444"]).and_return([recebimento_renegociado])
      get :historico_renegociacoes, :format => 'pdf', :busca => {"numero_de_controle" => "SVG-CPMF09/09762444"}, :tipo=>'pdf'
      response.should be_success

      assigns[:recebimentos_renegociados].should == [recebimento_renegociado]
      assigns[:titulo].should == "HISTÓRICO DE RENEGOCIAÇÕES"
    end

    it "testa geracao de relatório pdf quando acha a conta" do
      recebimento_renegociado = recebimento_de_contas(:curso_de_design_do_paulo)
      recebimento_renegociado.numero_de_renegociacoes = 1
      recebimento_renegociado.save false

      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(numero_de_renegociacoes >= ?) AND (unidade_id = ?) AND (numero_de_controle = ?)', 1, unidades(:senaivarzeagrande).id, "SVG-CPMF09/09762444"]).and_return([recebimento_renegociado])
      get :historico_renegociacoes, :format => 'js', :busca => {"numero_de_controle" => "SVG-CPMF09/09762444"}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('window.open("/relatorios/historico_renegociacoes.pdf?busca')
      response.body.should_not include('alert')

    end

    it "testa geracao de relatório xls quando acha a conta" do
      recebimento_renegociado = recebimento_de_contas(:curso_de_design_do_paulo)
      recebimento_renegociado.numero_de_renegociacoes = 1
      recebimento_renegociado.save false

      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(numero_de_renegociacoes >= ?) AND (unidade_id = ?) AND (numero_de_controle = ?)', 1, unidades(:senaivarzeagrande).id, "SVG-CPMF09/09762444"]).and_return([recebimento_renegociado])
      get :historico_renegociacoes, :format => 'js', :busca => {"numero_de_controle" => "SVG-CPMF09/09762444"}, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/historico_renegociacoes.xls?busca')
      response.body.should_not include('alert')
    end

    it 'testa pesquisa de históricos de renegociacao quando não há registros' do
      post :pesquisa_historico_renegociacoes, :format => 'js', :busca => {"texto" => "dasdasds"}
      response.should be_success
      
      response.body.should include("Não foram encontrados registros com estes parâmetros.".to_json)
    end

    it 'testa pesquisa de históricos de renegociacao quando há registros' do
      post :pesquisa_historico_renegociacoes, :busca => {"texto" => "a"}
      response.should be_success

      response.should have_rjs(:replace, 'resultados_pesquisa_ordem') do
        with_tag('table.listagem') do
          with_tag "tr" do
            with_tag "td", "SVG-CTR09/09000791"
            with_tag "td", "Paulo Vitor Zeferino"
            with_tag "td", "01/01/2009"
            with_tag "td", "Curso de Corel Draw"
            with_tag "td", "R$ 50,00"
            with_tag "td", "2"
            with_tag "td", "Normal"
          end
        end
      end
    end

  end

  describe 'relatório de contas a receber - geral' do
    it 'deve exibir form' do
      get :contas_a_receber_geral
      response.should be_success
      response.should have_tag('form[action=?]', contas_a_receber_geral_relatorios_path) do
        with_tag 'input[name=?][type=text][onfocus*=?]', 'busca[nome_servico]', "servico_explicacao_busca"
        with_tag 'input[name=?][type=hidden]', 'busca[servico_id]'
        with_tag 'input[type=submit]'
        with_tag 'div#servico_explicacao_busca'
        with_tag 'div#busca_nome_servico_auto_complete'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_servico.*/servicos/auto_complete_for_servico.*afterUpdateElement.*\$\('busca_servico_id'\).value = value.id.*'argumento=' \+ element.value.*}

        with_tag 'input[name=?][type=text]', 'busca[nome_cliente]'
        with_tag 'input[name=?][type=hidden]', 'busca[cliente_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_cliente.*/pessoas/auto_complete_for_cliente.*afterUpdateElement.*\$\('busca_cliente_id'\).value = value.id.*'argumento=' \+ element.value.*}

        with_tag 'input[name=?][type=text]', 'busca[nome_modalidade]'

        with_tag 'input[name=?]', 'busca[vendido_min]'
        with_tag 'input[name=?]', 'busca[vendido_max]'

        with_tag 'input[name=?][type=text]', 'busca[nome_vendedor]'
        with_tag 'input[name=?][type=hidden]', 'busca[vendedor_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_vendedor.*/pessoas/auto_complete_for_funcionario}

        with_tag("input[id=?][name=?][type=?]", "busca_periodo_recebimento","busca[periodo]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_vencimento","busca[periodo]", "radio")
        with_tag 'input[name=?]', 'busca[periodo_min]'
        with_tag 'input[name=?]', 'busca[periodo_max]'

        with_tag 'select[name=?]', 'busca[opcoes]' do
          with_tag 'option', 'Recebimentos'
          with_tag 'option', 'Inadimplência'
          with_tag 'option', 'Contas a Receber'
          with_tag 'option', 'Recebimentos com Atraso'
          with_tag 'option', 'Vendas Realizadas'
          with_tag 'option', 'Geral do Contas a Receber'
        end
        with_tag  'tr[id=?]', 'tipo_situacao' do
          with_tag 'select[name=?]', 'busca[situacao]' do
            with_tag 'option[selected=?][value=?]', 'selected',''
            with_tag 'option', 'Todas'
            with_tag 'option', 'Todas - Exceto Jurídico'
            with_tag 'option', 'Vincendas'
            with_tag 'option', 'Em Atraso'
            with_tag 'option', 'Jurídico'
            with_tag 'option', 'Pendentes'
          end
        end
        
        with_tag 'select[name=?]', 'busca[ordenacao]' do
          with_tag 'option[selected=?][value=?]', 'selected','pessoas.nome','Alfabética'
          with_tag 'option[value=?]', 'parcelas.data_da_baixa','Data de Recebimentos/Venda'
          with_tag 'option[value=?]', 'parcelas.data_vencimento','Data de Vencimento'   
        end
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it 'deve pesquisar por serviço' do
      #Pegar somente parcelas baixadas e agrupadas por serviço
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> 'Curso de Eletronica Digital', "servico_id"=>servicos(:curso_de_eletronica).id.to_s, "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral.pdf?busca')
      response.body.should_not include('alert')

      assigns(:parcelas).should == 2
    end

    it 'deve exibir alerta quando não encontrar nada' do
      #Pegar somente parcelas baixadas e agrupadas por serviço
      params = {"periodo" => "recebimento", "nome_modalidade"=>"", "modalidade_id"=>"", "periodo_min"=>"aaaaaaaaaa", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=> 'Curso de Eletronica Digital', "servico_id"=>servicos(:curso_de_eletronica).id.to_s, "nome_vendedor"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "periodo_max"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open')
      response.body.should include('alert')

      assigns(:parcelas).should == 0
    end

    it 'deve limpar o servico_id se o nome_servico estiver em branco, retornando TODAS as parcelas baixadas' do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> '', "servico_id"=>servicos(:curso_de_eletronica).id.to_s, "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral.pdf?busca')

      assigns(:parcelas).should == 8
    end

    it 'não deve retornar contas que não pertençam à unidade correta' do
      RecebimentoDeConta.update_all :unidade_id => 0
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca=>params
      response.should be_success
      response.body.should_not include('window.open("/relatorios/contas_a_receber_geral.pdf?busca')
      response.body.should include('alert')

      assigns(:parcelas).should == 0
    end

    it 'deve retornar pdf' do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> 'Curso de Eletronica Digital', "servico_id"=>servicos(:curso_de_eletronica).id.to_s, "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>""}
      post :contas_a_receber_geral, :format => 'pdf', :busca=>params, :tipo=>'pdf'
      response.should be_success
      assigns(:parcelas).collect{|k, _| k}.should == ['Curso de Eletronica Digital']
      assigns(:parcelas).collect{|_, v| v}.flatten.collect(&:id).should == parcelas(:primeira_parcela_recebida_cheque_a_vista, :primeira_parcela_recebida_cheque_a_prazo).collect(&:id)
    end
    
    it "deve retornar pdf com relatorios de Inadimplência" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Inadimplência", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral_inadimplencia.pdf?busca')
    end
    
    it "deve retornar pdf com relatorios de Contas a Receber" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>"Todas"}
      post :contas_a_receber_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral_inadimplencia.pdf?busca')
    end
    
    it "deve retornar pdf com relatorios de Recebimentos com Atraso" do
      parcela = parcelas(:primeira_parcela_recebimento)
      parcela.data_da_baixa = Date.today
      parcela.forma_de_pagamento = Parcela::DINHEIRO
      parcela.valor_liquido = 3000
      parcela.save!      
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos com Atraso", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral_recebimentos_com_atraso.pdf?busca')
    end
    
    it "deve retornar pdf com relatorio de vendas relizadas" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Vendas Realizadas", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca => params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral_vendas_realizadas.pdf?busca')
    end
    
    it "deve retornar pdf com relatorio Geral do Contas a Receber" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      post :contas_a_receber_geral, :format => 'js', :busca => params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/geral_do_contas_a_receber.pdf?busca')
    end

    it "deve retornar um xls com relatorio Geral do Contas a Receber" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      get :contas_a_receber_geral, :format => 'js',:busca => params ,:tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/geral_do_contas_a_receber.xls')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end

    it "deve retornar um xls com relatorio Contas a Receber Geral" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      get :contas_a_receber_geral, :format => 'js',:busca => params ,:tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral.xls')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end

    it "deve retornar um xls com relatorio Contas a Receber Geral - Inadimplência" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Inadimplência", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      get :contas_a_receber_geral, :format => 'js',:busca => params ,:tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral_inadimplencia.xls')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end

    it "deve retornar um xls com relatorio Contas a Receber Geral - Vendas Realizadas" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Vendas Realizadas", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      get :contas_a_receber_geral, :format => 'js',:busca => params ,:tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_receber_geral_vendas_realizadas.xls')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end

    it "deve retornar um xls com relatorio Contas a Receber Geral - Recebimentos com Atraso" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos com Atraso", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      get :contas_a_receber_geral, :format => 'js',:busca => params ,:tipo=>'xls'
      response.should be_success
      response.body.should include('alert')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end

    it "deve retornar um xls com relatorio Geral do Contas a Receber" do
      params = {"nome_modalidade"=>"", "modalidade_id"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=> "", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Geral do Conta a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "situacao"=>""}
      get :contas_a_receber_geral, :format => 'js',:busca => params ,:tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/geral_do_contas_a_receber.xls')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end
    
  end
  
  describe 'relatorio de contas a receber - Produtividade de Funcionários' do
    
    it "deve exibir o form de configuração do relatório" do
      get :produtividade_funcionario 
      response.should be_success
      response.should have_tag('form[action=?]',produtividade_funcionario_relatorios_path) do
        with_tag('input[name=?]','busca[servico_id]')
        with_tag('input[name=?]','busca[nome_servico]')
        with_tag 'div#servico_explicacao_busca'
        with_tag 'div#busca_nome_servico_auto_complete'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_servico.*/servicos/auto_complete_for_servico.*afterUpdateElement.*\$\('busca_servico_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag("input[name=?]", "busca[cliente_id]")
        with_tag("input[name=?]", "busca[nome_cliente]")
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_cliente.*/pessoas/auto_complete_for_cliente.*afterUpdateElement.*\$\('busca_cliente_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag("input[name=?]", "busca[funcionario_id]")
        with_tag("input[name=?]", "busca[nome_funcionario]")
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_funcionario.*/pessoas/auto_complete_for_funcionario.*afterUpdateElement.*\$\('busca_funcionario_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag("input[id=?][name=?][type=?]", "busca_opcoes_ações_cobranças_efetuadas","busca[opcoes]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_opcoes_produtividade_do_funcionário","busca[opcoes]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_opcoes_renegociações_efetuadas","busca[opcoes]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_recebimento","busca[periodo]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_vencimento","busca[periodo]", "radio")
        with_tag 'input[name=?]', 'busca[periodo_min]'
        with_tag 'input[name=?]', 'busca[periodo_max]'
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
        with_tag('input[type=submit]')
      end
    end
    
    it "deve retonar um pdf" do
      params = {"periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/08/2009", "periodo_min" => "01/01/2008", "opcoes" => "Produtividade do Funcionário"}
      post :produtividade_funcionario, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/produtividade_funcionario.pdf?busca')
      response.body.should_not include('alert')
    end
    
    it "Renegociações efetuadas devem retornar um pdf" do
      params = {"periodo_min"=>"", "nome_funcionario"=>"", "funcionario_id"=>"", "cliente_id"=>"", "servico_id"=>"", "nome_servico"=>"", "periodo"=>"recebimento", "opcoes"=>"Renegociações Efetuadas", "periodo_max"=>"", "nome_cliente"=>""}
      post :produtividade_funcionario, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/renegociacoes_efetuadas.pdf?busca')
      response.body.should include('alert')
    end
    
    it "Ações de Cobrança não deve retornar um pdf quando não possuir registros" do
      params = {"periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "01/01/1991", "periodo_min" => "01/01/1991", "opcoes" => "Ações Cobranças Efetuadas"}
      post :produtividade_funcionario, :format => 'js' , :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/acoes_de_cobranca.pdf?busca')
      response.body.should include('alert')
    end

    it "Deve exibir a mensagem de que não encontrou nada quando o relatorio de Ações de Cobrança não trouxer nada" do
      params = {"periodo"=>"vencimento", "nome_servico" => "Curso de Eletronica Digital", "servico_id" => servicos(:curso_de_eletronica).id.to_s, "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "aaaaaaaaaa", "periodo_min" => "aaaaaaaaaa", "opcoes" => "Ações Cobranças Efetuadas"}
      post :produtividade_funcionario, :format => 'js' , :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/acoes_de_cobranca.pdf?busca')
      response.body.should include('alert')
    end

    it "deve retonar um Excel" do
      params = {"periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/08/2009", "periodo_min" => "01/01/2008", "opcoes" => "Produtividade do Funcionário"}
      post :produtividade_funcionario, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/produtividade_funcionario.xls')
      response.body.should_not include('alert')
    end

    it "Não deve retonar um Excel quando não tem registros" do
      params = {"periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/01/2005", "periodo_min" => "01/01/2005", "opcoes" => "Produtividade do Funcionário"}
      post :produtividade_funcionario, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success

      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/produtividade_funcionario.xls')
    end

    it "Renegociações efetuadas não deve retornar um Excel quando não possui registros" do
      params = {"periodo_min"=>"", "nome_funcionario"=>"", "funcionario_id"=>"", "cliente_id"=>"", "servico_id"=>"", "nome_servico"=>"", "periodo"=>"recebimento", "opcoes"=>"Renegociações Efetuadas", "periodo_max"=>"", "nome_cliente"=>""}
      post :produtividade_funcionario, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/renegociacoes_efetuadas.xls')
      response.body.should include('alert')
    end

    it "Renegociações efetuadas devem retornar um Excel quando possui registros" do
      @recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @recebimento_de_conta.usuario_corrente = usuarios(:juliano)
      recebimento_de_conta_params = {"numero_de_parcelas"=>"1", "vigencia"=>"1", "data_inicio"=>"24/09/2009", "historico"=>"MyString", "valor_do_documento_em_reais"=>"11.00", "dia_do_vencimento"=>"1"}
      @recebimento_de_conta.renegociar(recebimento_de_conta_params)
      params = {"periodo_min"=>"", "nome_funcionario"=>"", "funcionario_id"=>"", "cliente_id"=>"", "servico_id"=>"", "nome_servico"=>"", "periodo"=>"recebimento", "opcoes"=>"Renegociações Efetuadas", "periodo_max"=>"", "nome_cliente"=>""}
      post :produtividade_funcionario, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/renegociacoes_efetuadas.xls')
      response.body.should_not include('alert')
    end


    it "Ações de Cobrança devem retornar um Excel quando possui registros" do
      params = {"periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Ações Cobranças Efetuadas"}
      post :produtividade_funcionario, :format => 'js' , :busca=>params, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/acoes_de_cobranca.xls')
      response.body.should_not include('alert')
    end

    it "Ações de Cobrança não deve retornar um Excel quando não possuir registros" do
      params = {"periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "2009-12-31", "periodo_min" => "2009-01-01", "opcoes" => "Ações Cobranças Efetuadas"}
      post :produtividade_funcionario, :format => 'js' , :busca=>params, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/acoes_de_cobranca.xls')
      response.body.should include('alert')
    end
   
  end
  
  describe 'relatório de contas a pagar - geral' do
    
    it "deve exibir o form de configuração do relatório" do
      get :contas_a_pagar_geral
      response.should be_success
      response.should have_tag('form[action=?]',contas_a_pagar_geral_relatorios_path) do
        with_tag('input[name=?][type=text]','busca[nome_fornecedor]')
        with_tag('input[name=?][type=hidden]','busca[fornecedor_id]')
        with_tag('script',%r{Ajax.Autocompleter.*busca_nome_fornecedor.*/pessoas/auto_complete_for_fornecedor.*afterUpdateElement.*\$\('busca_fornecedor_id'\).value = value.id.*'argumento=' \+ element.value.*})
        with_tag('select[name=?]','busca[tipo_de_documento]') do
          with_tag('option[value=?]','','')
          with_tag('option[value=?]','CPMF','CPMF')
          with_tag('option[value=?]','CTRSE','SERVIÇOS EDUCACIONAIS - CONTRATO RECEBIMENTO')
        end
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_pagamento","busca[periodo]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_vencimento","busca[periodo]", "radio")
        with_tag('input[name=?]','busca[periodo_min]')
        with_tag('input[name=?]','busca[periodo_max]')
        with_tag('select[name=?]','busca[opcao_de_relatorio]') do
          with_tag('option[selected=?][value=?]','selected','','Todas')
          with_tag('option[value=?]','pagamentos','Pagamentos')
          with_tag('option[value=?]','inadimplencia','Inadimplência')
        end
        with_tag('select[name=?]','busca[ordenacao]') do
          with_tag('option[selected=?][value=?]','selected','pessoas.nome','Ordem Alfabética')
          with_tag('option[value=?]','parcelas.data_do_pagamento','Data de Pagamento')
          with_tag('option[value=?]','parcelas.data_vencimento','Data de Vencimento')
        end
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
        with_tag('input[type=submit]')
      end      
    end
    
    it 'deve pesquisar por fornecedor e gerar o PDF' do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"FTG Tecnologia", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id.to_s, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_pagar_geral.pdf?busca')
      response.body.should_not include('alert')
    end

    it 'deve pesquisar por fornecedor' do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"FTG Tecnologia", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id.to_s, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/contas_a_pagar_geral.pdf?busca')
      response.body.should include('alert')
      assigns(:parcelas).should == 0
    end
    
    it 'não deve trazer as contas que não pertençam à unidade correta' do
      PagamentoDeConta.update_all :unidade_id => 0
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/contas_a_pagar_geral.pdf?busca')
      response.body.should include('alert')

      assigns(:parcelas).should == 0
    end
    
    it "deve exibir alerta quando não encontra parcela" do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"fffffffffffffff", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open')
      response.body.should include('alert')
      assigns(:parcelas).should == 0
    end
    
    it "deve limpar o fornecedor_id quando o nome_fornecedor estiver em branco" do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id.to_s, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/contas_a_pagar_geral.pdf?busca')
      assigns(:parcelas).should == 0
    end
    
    it 'deve retornar pdf' do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id.to_s, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'pdf', :busca=>params, :tipo=>'pdf'
      response.should be_success
    end

    it 'deve pesquisar por fornecedor e gerar o Excel' do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"FTG Tecnologia", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id.to_s, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"todos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_pagar_geral.xls?busca')
      response.body.should_not include('alert')
    end

    it 'deve pesquisar por fornecedor e nao gerar o Excel' do
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"FTG Tecnologia", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id.to_s, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/contas_a_pagar_geral.xls?busca')
      response.body.should include('alert')
    end

    it 'não deve trazer as contas que não pertençam à unidade correta ao tentar gerar Excel' do
      PagamentoDeConta.update_all :unidade_id => 0
      params = {"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""}
      post :contas_a_pagar_geral, :format => 'js', :busca=>params, :tipo=>'xls'
      response.should be_success
      response.body.should_not include('window.open("/relatorios/contas_a_pagar_geral.xls?busca')
      response.body.should include('alert')
    end
    
  end  

  it "testa pesquisa para ordem" do
    movimentos = {'SENAI-VG - DP4/20053200' => [movimentos(:lancamento_com_a_conta_pagamento_cheque)]}
    Movimento.should_receive(:procurar_movimentos).with({'numero_controle' => "", 'nome_fornecedor' => "", 'valor' => "", 'data_lancamento' => ""}, unidades(:senaivarzeagrande).id).and_return movimentos

    post :pesquisa_para_ordem, :conta => {'numero_controle' => "", 'nome_fornecedor' => "", 'valor' => "", 'data_lancamento' => ""}
    response.should be_success

    response.should have_rjs(:replace, 'resultados_pesquisa_ordem') do
      with_tag('table.listagem') do
        with_tag "tr" do
          with_tag "td", "SENAI-VG - DP4/20053200"
          with_tag "td", "31/03/2009"
          with_tag "td", ""
          with_tag "td", "Felipe Giotto"
          with_tag "td", "Pagamento Cheque"
          with_tag "td", "R$ 100,01"
        end
      end
    end
  end

  it "testa pesquisa quando não há ordem inserida" do
    get :contabilizacao_ordem, :movimento => {'data_inicial' => '', 'data_final' => '', 'ordem' => '', 'tipo' => '2'}, :format => 'js'
    response.should be_success
    response.body.should include("Não foram encontrados registros com estes parâmetros.".to_json)
  end

  it "testa contabilizacao de ordem" do
    Movimento.should_receive(:procurar_movimentos).with({'data_inicial' => '', 'data_final' => '', 'ordem' => 'Primeiro lançamento de entrada', 'tipo' => '2'}, session[:unidade_id], true).and_return [movimentos(:primeiro_lancamento_entrada)]
    get :contabilizacao_ordem, :movimento => {'data_inicial' => '', 'data_final' => '', 'ordem' => 'Primeiro lançamento de entrada', 'tipo' => '2'}, :format => 'pdf'
  end

  it "testa campos de pesquisa de ordem" do
    get :contabilizacao_ordem
    response.should be_success
    response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", contabilizacao_ordem_relatorios_path) do
      with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
      with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
    end
    response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", pesquisa_para_ordem_relatorios_path) do
      with_tag("input[name=?]","conta[nome_fornecedor]")
      with_tag("input[name=?]","conta[numero_controle]")
      with_tag("input[name=?]","conta[data_lancamento]")
      with_tag("input[name=?]","conta[valor]")
    end
  end

  it "testa geração de pdf" do
    get :contabilizacao_ordem, :movimento => {'data_inicial' => '', 'data_final' => '', 'ordem' => 'SENAI-VG - DP4/20053200', 'tipo' => '2'}, :format => 'pdf'
    response.should be_success
    
    assigns[:titulo].should == "MOVIMENTO DA CONTABILIZAÇÃO DO LANÇAMENTO"
  end

  it "testa chamada AJAX quando não há movimentos" do
    get :contabilizacao_ordem, :movimento => {'data_inicial' => '', 'data_final' => '', 'ordem' => 'SVRFEJ98763', 'tipo' => '2'}, :format => 'js'
    response.should be_success
    response.body.should include("Não foram encontrados registros com estes parâmetros.".to_json)
  end

  it "testa chamada AJAX quando há movimentos" do
    get :contabilizacao_ordem, :movimento => {'data_inicial' => '', 'data_final' => '', 'ordem' => 'SENAI-VG - DP4/20053200', 'tipo' => '2'}, :format => 'pdf'
    response.should be_success    
  end
  
  describe 'Descrição do relatorio de totalização' do
    
    it "relatório de totalização de contas a receber" do
      post :totalizacao
      response.should be_success
      response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", totalizacao_relatorios_path) do
        with_tag 'input[name=?][type=text][onfocus*=?]', 'busca[nome_servico]', "servico_explicacao_busca"
        with_tag 'input[name=?][type=hidden]', 'busca[servico_id]'
        with_tag 'div#servico_explicacao_busca'
        with_tag 'div#busca_nome_servico_auto_complete'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_servico.*/servicos/auto_complete_for_servico.*afterUpdateElement.*\$\('busca_servico_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag("input[name=?][value=?]", "busca[periodo]", "recebimento")
        with_tag("input[name=?][value=?]", "busca[periodo]", "vencimento")
        with_tag("input[name=?]", "busca[periodo_min]")
        with_tag("input[name=?]", "busca[periodo_max]")
        with_tag "select[name=?]", "busca[opcao_relatorio]" do
          with_tag 'option[value=?]',1,'Recebimentos'
          with_tag 'option[value=?]',2,'Contas a Receber'
          with_tag 'option[value=?]',3,'Recebimentos com Atraso'
          with_tag 'option[value=?]',4,'Inadimplência'
        end
      end
    end

    it "deve gerar de relatorio em pdf" do
      busca = {"busca" => {"periodo_min" => "", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id"=> servicos(:curso_de_tecnologia).id, "periodo_max" => "", "opcao_relatorio" => "1"}}
      get :totalizacao, :busca => busca, :format => 'pdf'
      response.should be_success

      assigns[:titulo].should == "TOTALIZAÇÃO"
    end

  end  
  
  describe 'Relatório de Cheques' do
    it "testa campos de pesquisa" do
      get :contabilizacao_de_cheques
      response.should be_success
      response.should have_tag("form[onsubmit*=?][method=post][action=?]", "Ajax.Request", contabilizacao_de_cheques_relatorios_path) do
        with_tag 'select[name=?]', 'busca[situacao]' do
          with_tag 'option[value=?]', Cheque::GERADO,"Pendente"
          with_tag 'option[value=?]', Cheque::BAIXADO,"Baixado"
        end  
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_recebimento","busca[periodo]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_vencimento","busca[periodo]", "radio")
        with_tag("input[id=?][name=?][type=?]", "busca_periodo_baixa","busca[periodo]", "radio")
        with_tag("input[name=?]", "busca[periodo_min]")
        with_tag("input[name=?]", "busca[periodo_max]")
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end
    
    it "verifica se exibe alert quando não encontra registros" do
      params= {"periodo_min"=>"14/07/2009", "filtro"=>"1", "situacao"=>"", "periodo_max"=>"14/07/2009"}
      post :contabilizacao_de_cheques, :busca => params, :format => 'js', :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open')
      response.body.should include('alert')
      assigns[:cheques].should == []
    end
    
    it "verifica se gera pdf com titulo de À VISTA" do
      params = {"periodo_min"=>"14/07/2009", "filtro"=>"1", "situacao"=>"1", "periodo_max"=>"14/07/2009"}
      get :contabilizacao_de_cheques, :busca => params, :format => 'pdf', :tipo=>'pdf'
      response.should be_success
      assigns[:titulo].should == "RELAÇÃO DE CHEQUES À VISTA"
    end

    it "verifica se gera pdf com titulo de PRÉ-DATADOS" do
      params = {"periodo_min"=>"14/07/2009", "filtro"=>"2", "situacao"=>"1", "periodo_max"=>"14/07/2009"}
      get :contabilizacao_de_cheques, :busca => params, :format => 'pdf'
      response.should be_success
      assigns[:titulo].should == "RELAÇÃO DE CHEQUES PRÉ-DATADOS"
    end

    it "verifica se gera pdf com titulo de DEVOLVIDOS" do
      params = {"periodo_min"=>"14/07/2009", "filtro"=>"3", "situacao"=>"1", "periodo_max"=>"14/07/2009"}
      get :contabilizacao_de_cheques, :busca => params, :format => 'pdf'
      response.should be_success
      assigns[:titulo].should == "RELAÇÃO DE CHEQUES DEVOLVIDOS"
    end

    it "verifica se gera pdf com titulo de BAIXADOS" do
      params = {"periodo_min"=>"14/07/2009", "filtro"=>"4", "situacao"=>"1", "periodo_max"=>"14/07/2009"}
      get :contabilizacao_de_cheques, :busca => params, :format => 'pdf'
      response.should be_success
      assigns[:titulo].should == "RELAÇÃO DE CHEQUES BAIXADOS"
    end
    
  end

  describe 'relatório de contas a pagar - retencao de impostos' do

    it 'deve exibir form' do
      get :contas_a_pagar_retencao_impostos
      response.should be_success
      response.should have_tag('form[action=?]', contas_a_pagar_retencao_impostos_relatorios_path) do
        with_tag 'select[name=?]', 'busca[impostos]' do
          with_tag 'option[value=?]', ''
          with_tag 'option[value=?]', impostos(:confins).id, impostos(:confins).descricao
          with_tag 'option[value=?]', impostos(:inss).id, impostos(:inss).descricao
          with_tag 'option[value=?]', impostos(:ipi).id, impostos(:ipi).descricao
          with_tag 'option[value=?]', impostos(:iss).id, impostos(:iss).descricao
        end
        with_tag 'input[name=?][type=text][onfocus*=?]', 'busca[nome_fornecedor]', "fornecedor_explicacao_busca"
        with_tag 'input[name=?][type=hidden]', 'busca[fornecedor_id]'
        with_tag 'input[type=submit]'
        with_tag 'div#busca_nome_fornecedor_auto_complete'
        with_tag 'input[name=?][type=text]', 'busca[nome_fornecedor]'
        with_tag 'input[name=?][type=hidden]', 'busca[fornecedor_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_fornecedor.*/pessoas/auto_complete_for_fornecedor.*afterUpdateElement.*\$\('busca_fornecedor_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag 'input[name=?]', 'busca[recolhimento_min]'
        with_tag 'input[name=?]', 'busca[recolhimento_max]'

        with_tag 'select[name=?]', 'busca[opcoes]' do
          with_tag 'option[value=?]', LancamentoImposto::ALFABETICA, 'Ordem Alfabética'
          with_tag 'option[value=?]', LancamentoImposto::VENCIMENTO, 'Data de Vencimento'
        end
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it "deve gerar de relatorio em pdf" do
      busca = {"busca"=>{"opcoes" => LancamentoImposto::ALFABETICA, "recolhimento_min"=>"", "nome_fornecedor"=>"", "fornecedor_id"=>"", "recolhimento_max"=>"", "impostos"=>""}}
      get :contas_a_pagar_retencao_impostos, :busca => busca, :format => 'pdf', :tipo=>'pdf'
      response.should be_success

      assigns[:titulo].should == "RETENÇÃO DE IMPOSTOS"
    end

    it 'deve exibir o alert quando não encontrar registros' do
      params = {"opcoes" => LancamentoImposto::ALFABETICA, "nome_fornecedor" => "", "recolhimento_min" => "", "fornecedor_id" => "", "recolhimento_max" => "02/07/2000", "impostos" => ""}

      post :contas_a_pagar_retencao_impostos, :busca => params, :format => 'js', :tipo=>'pdf'
      response.should be_success
      response.body.should_not include('window.open')
      response.body.should include('alert')
      assigns[:lancamentos].should == 0
    end

    it 'não deve exibir o alert quando encontrar registros' do
      params = {"opcoes" => LancamentoImposto::ALFABETICA, "nome_fornecedor" => "FTG Tecnologia", "recolhimento_min" => "", "fornecedor_id" => pessoas(:inovare).id.to_s, "recolhimento_max" => "", "impostos" => ""}
      lancamento = mock_model(LancamentoImposto, :data_de_recolhimento => "2009-10-10", :parcela_id => parcelas(:terceira_parcela).id, :valor => "5000", :imposto_id => impostos(:iss).id)
      LancamentoImposto.should_receive(:pesquisar_parcelas_para_relatorio_retencao_impostos).with(:count, unidades(:senaivarzeagrande).id, params).and_return lancamento
      post :contas_a_pagar_retencao_impostos, :busca => params, :format => 'js', :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/contas_a_pagar_retencao_impostos.pdf?busca')
      response.body.should_not include('alert')
      assigns[:lancamentos].should == lancamento
    end
  end

  describe 'relatório de conta corrente - disponibilidade efetiva' do

    it 'deve exibir form' do
      get :disponibilidade_efetiva
      response.should be_success
      response.should have_tag('form[action=?]', disponibilidade_efetiva_relatorios_path) do
        with_tag 'input[name=?][type=text][onfocus*=?]', 'busca[nome_conta_corrente]', "conta_corrente_explicacao_busca"
        with_tag 'input[name=?][type=hidden]', 'busca[conta_corrente_id]'
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
        with_tag 'input[type=submit]'

        with_tag 'div#busca_nome_conta_corrente_auto_complete'
        with_tag 'input[name=?][type=text]', 'busca[nome_conta_corrente]'
        with_tag 'input[name=?][type=hidden]', 'busca[conta_corrente_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_conta_corrente.*/contas_correntes/auto_complete_for_conta_corrente.*afterUpdateElement.*\$\('busca_conta_corrente_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag 'input[name=?]', 'busca[data_max]'
      end
    end

    it "deve gerar de relatorio em pdf" do
      params = {"conta_corrente_id"=> contas_correntes(:primeira_conta).id, "data_max"=>"", "nome_conta_corrente"=>"2345-3 - Conta do Senai Várzea Grande"}
      get :disponibilidade_efetiva, :busca => params, :format => 'pdf', :tipo=>'pdf'

      response.should be_success
      assigns[:titulo].should == "DISPONIBILIDADE EFETIVA"
    end

    it 'deve exibir o alert quando não encontrar registros' do
      params = {"conta_corrente_id"=> "3242345", "data_max"=>"", "nome_conta_corrente"=> "2666-3 - Conta que não existe"}
      post :disponibilidade_efetiva, :busca => params, :format => 'js' , :tipo=>'pdf'

      response.should be_success
      response.body.should_not include('window.open')
      response.body.should include('alert')
      assigns[:itens_movimentos].should == 0
    end

    it 'não deve exibir o alert quando encontrar registros' do
      params = {"conta_corrente_id"=> contas_correntes(:primeira_conta).id, "data_max"=>"", "nome_conta_corrente"=>"2345-3 - Conta do Senai Várzea Grande"}
      post :disponibilidade_efetiva, :busca => params, :format => 'js' , :tipo=>'pdf'

      response.should be_success
      response.body.should include('window.open("/relatorios/disponibilidade_efetiva.pdf?busca')
      response.body.should_not include('alert')
    end

  end

  describe 'relatório de conta corrente - extrato de contas' do

    it 'deve exibir form' do
      get :extrato_contas
      response.should be_success
      response.should have_tag('form[action=?]', extrato_contas_relatorios_path) do
        with_tag 'input[name=?][type=text][onfocus*=?]', 'busca[nome_conta_corrente]', "conta_corrente_explicacao_busca"
        with_tag 'input[name=?][type=hidden]', 'busca[conta_corrente_id]'
        with_tag 'input[type=submit]'

        with_tag 'div#busca_nome_conta_corrente_auto_complete'
        with_tag 'input[name=?][type=text]', 'busca[nome_conta_corrente]'
        with_tag 'input[name=?][type=hidden]', 'busca[conta_corrente_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_conta_corrente.*/contas_correntes/auto_complete_for_conta_corrente.*afterUpdateElement.*\$\('busca_conta_corrente_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag 'input[name=?]', 'busca[data_min]'
        with_tag 'input[name=?]', 'busca[data_max]'
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it "deve gerar de relatorio em pdf" do
      params = {"conta_corrente_id"=> contas_correntes(:primeira_conta).id, "data_min" => "", "data_max"=>"", "nome_conta_corrente"=>"2345-3 - Conta do Senai Várzea Grande"}
      get :extrato_contas, :busca => params, :format => 'pdf' , :tipo=>'pdf'

      response.should be_success
      assigns[:titulo].should == "EXTRATO DE CONTAS"
    end

    it 'deve exibir o alert quando não encontrar registros' do
      params = {"conta_corrente_id"=> "324200345", "data_min" => "", "data_max"=>"", "nome_conta_corrente"=> "2666-3 - Conta que não existe"}
      post :extrato_contas, :busca => params, :format => 'js' , :tipo=>'pdf'

      response.should be_success
      response.body.should_not include('window.open')
      response.body.should include('alert')
      assigns[:itens_movimentos].should == 0
    end

    it 'não deve exibir o alert quando encontrar registros' do
      params = {"conta_corrente_id"=> contas_correntes(:primeira_conta).id, "data_min" => "", "data_max"=>"", "nome_conta_corrente"=>"2345-3 - Conta do Senai Várzea Grande"}
      post :extrato_contas, :busca => params, :format => 'js' , :tipo=>'pdf'

      response.should be_success
      response.body.should include('window.open("/relatorios/extrato_contas.pdf?busca')
      response.body.should_not include('alert')
    end

  end

  describe 'testes do relatório de clientes ao SPC' do

    it 'testa link no html' do
      get :clientes_ao_spc
      response.should be_success

      response.should have_tag('p') do
        with_tag('a[onclick=?]', "new Ajax.Request('/relatorios/clientes_ao_spc', {asynchronous:true, evalScripts:true}); return false;")
      end
    end

    it 'testa chamada AJAX com itens' do
      get :clientes_ao_spc, :format => 'js'
      response.should be_success

      response.should be_success
      response.body.should include('window.open("/relatorios/clientes_ao_spc.xls')
      response.body.should_not include('alert')
    end

    it 'testa chamada AJAX sem itens' do
      RecebimentoDeConta.delete_all
      get :clientes_ao_spc, :format => 'js'
      response.should be_success
      
      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/clientes_ao_spc.xls')
    end

    it 'testa retorno quando é chamado um xls' do
      get :clientes_ao_spc, :format => 'xls'
      response.should be_success

      response.body.should include('<?xml version="1.0" encoding="UTF-8"?>')
      response.body.should_not include('<!DOCTYPE html PUBLIC')
    end

  end

  describe 'emissão de cartas de cobrança' do

    it 'testa a action de pesquisa para emissão de cartas' do
      RecebimentoDeConta.should_receive(:pesquisa_simples).with(unidades(:senaivarzeagrande).id, {"texto" => '62444', "emissao_cartas" => true}).and_return([recebimento_de_contas(:curso_de_design_do_paulo)])
      
      post :pesquisa_emissao_cartas, :busca => {"texto"=>'62444'}
      response.should be_success

      response.should have_rjs(:replace, 'resultado_da_busca') do
        with_tag('table.listagem') do
          with_tag "tr" do
            with_tag "td" do
              with_tag "input[value=?]", recebimento_de_contas(:curso_de_design_do_paulo).id
            end
            with_tag "td", "SVG-CPMF09/09762444"
            with_tag "td", "Paulo Vitor Zeferino"
          end
        end
        with_tag "div" do
          with_tag "label[for=?]", "recebimentos_tipo_cartas" do
            with_tag "input[id=?][onclick=?]", "recebimentos_tipo_cartas", "marcarCartas();"
          end
          with_tag "label[for=?]", "recebimentos_tipo_etiquetas" do
            with_tag "input[id=?][onclick=?]", "recebimentos_tipo_etiquetas", "marcarEtiquetas();"
          end
          with_tag "select[name=?]", "recebimentos[tipo_de_carta]"
        end
      end      
    end

    it 'testa a action de pesquisa para emissão de cartas quando não há recebimentos' do
      RecebimentoDeConta.should_receive(:pesquisa_simples).with(unidades(:senaivarzeagrande).id, {"texto" => 'ricardao', "emissao_cartas" => true}).and_return([])

      post :pesquisa_emissao_cartas, :busca => {"texto"=>'ricardao'}
      response.should be_success

      response.body.should include('alert')
      response.should have_rjs(:replace, 'resultado_da_busca')
    end
      
    it 'testa a view de emissao de cartas' do
      get :emissao_cartas
      response.should be_success

      response.should have_tag('form[onsubmit*=?]', "new Ajax.Request('/relatorios/pesquisa_emissao_cartas'") do
        with_tag('select[name=?]', 'busca[dias_de_atraso]')
        with_tag('input[name=?][value=?][type=?]', 'busca[cartas][]', 'carta_1', 'checkbox')
        with_tag('input[name=?][value=?][type=?]', 'busca[cartas][]', 'carta_2', 'checkbox')
        with_tag('input[name=?][value=?][type=?]', 'busca[cartas][]', 'carta_3', 'checkbox')
        with_tag('input[name=?]', 'busca[pesquisa]')
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_cliente.*busca_nome_cliente_auto_complete.*/pessoas/auto_complete_for_cliente}
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_servico.*busca_nome_servico_auto_complete.*/servicos/auto_complete_for_servico}
        with_tag('input[name=?]', 'busca[numero_dias_atraso]')
      end
    end

    it 'testa a view de emissao de cartas recebendo parametros inválidos' do
      get :emissao_cartas, :format => 'js', :recebimentos => {:tipo => {:cartas => :cartas}}
      response.should be_success

      response.body.should include('Selecione pelo menos um contrato!'.to_json)
    end

    it 'testa a view de emissão de cartas chamando pdf' do
      get :emissao_cartas, :format => 'js', :recebimentos => {:ids => [recebimento_de_contas(:curso_de_design_do_paulo).id], :tipo_de_carta => 1, :tipo => {:cartas => :cartas}}
      response.should be_success

      response.body.should include('/relatorios/emissao_cartas.pdf?recebimentos')
    end

    it 'testa a view de emissao de cartas sem selecionar Cartas ou Etiquetas' do
      get :emissao_cartas, :format => 'js', :recebimentos => {:ids => [recebimento_de_contas(:curso_de_design_do_paulo).id], :tipo_de_carta => 1}
      response.should be_success

      response.body.should include('Selecione uma das opções de geração!'.to_json)
    end

    it 'testa a view de emissao de cartas para gerar etiquetas' do
      get :emissao_cartas, :format => 'pdf', :recebimentos => {:ids => [recebimento_de_contas(:curso_de_design_do_paulo).id], :tipo_de_carta => 1, :tipo => {:etiquetas => :etiquetas}, :etiqueta => '6083'}
      response.should be_success
    end

    it 'testa a view de emissao de cartas' do
      get :emissao_cartas, :format => 'pdf', :recebimentos => {:ids => [recebimento_de_contas(:curso_de_design_do_paulo).id], :tipo_de_carta => 1, :tipo => {:cartas => :cartas}}
      response.should be_success

      assigns[:titulo].should == "EMISSÃO DE CARTA DE COBRANÇA"
      assigns[:unidade].should == unidades(:senaivarzeagrande)
    end

  end

  describe 'cartas emitidas' do
    
    it 'testa a view de cartas emitidas' do
      get :cartas_emitidas
      response.should be_success
      
      response.should have_tag('form[onsubmit*=?]', "new Ajax.Request('/relatorios/cartas_emitidas'") do
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_unidade.*busca_nome_unidade_auto_complete.*/unidades/auto_complete_for_unidade}
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_funcionario.*busca_nome_funcionario_auto_complete.*/pessoas/auto_complete_for_funcionario}
        with_tag "select[name=?]", "busca[tipo_de_carta]"
        with_tag "select[name=?]", "busca[agrupar]"
        with_tag "input[name=?]", "busca[emissao_min]"
        with_tag "input[name=?]", "busca[emissao_max]"
        with_tag "select[name=?]", "busca[ordenacao]"
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it 'testa a pesquisa quando não retorna parâmetros' do
      post :cartas_emitidas, :format => 'js', :busca => {"emissao_min"=>"", "funcionario_id"=>"1874184", "agrupar"=>"Unidade", "unidade_id"=>"", "tipo_de_carta"=>"", "ordenacao"=>"recebimento_de_contas.numero_de_controle",
        "nome_unidade"=>"", "emissao_max"=>"", "nome_funcionario"=>"Tião"}
      response.should be_success

      response.body.should include('alert')
    end

    it 'testa a pesquisa quando retorna parâmetros' do
      h = historico_operacoes(:historico_operacao_recebimento_lancado)
      h.numero_carta_cobranca = 1
      h.save

      post :cartas_emitidas, :format => 'js', :busca => {"emissao_min"=>"", "funcionario_id"=>"", "agrupar"=>"Unidade", "unidade_id"=>"", "tipo_de_carta"=>"", "ordenacao"=>"recebimento_de_contas.numero_de_controle",
        "nome_unidade"=>"", "emissao_max"=>"", "nome_funcionario"=>""}, :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('/relatorios/cartas_emitidas.pdf?busca')
    end

    it 'testa o pdf de cartas emitidas' do
      h = historico_operacoes(:historico_operacao_recebimento_lancado)
      h.numero_carta_cobranca = 1
      h.save

      get :cartas_emitidas, :format => 'pdf', :busca => {"emissao_min"=>"", "funcionario_id"=>"", "agrupar"=>"Unidade", "unidade_id"=>"", "tipo_de_carta"=>"", "ordenacao"=>"recebimento_de_contas.numero_de_controle",
        "nome_unidade"=>"", "emissao_max"=>"", "nome_funcionario"=>""}, :tipo=>'pdf'
      response.should be_success
      
      assigns[:titulo].should == "CARTAS EMITIDAS"
    end

  end

  describe "testes do relatorio de totalizacoes" do

    it 'deve exibir form' do
      get :totalizacao
      response.should be_success
      response.should have_tag('form[action=?]', totalizacao_relatorios_path) do
        with_tag 'input[name=?][type=text][onfocus*=?]', 'busca[nome_servico]', "servico_explicacao_busca"
        with_tag 'input[name=?][type=hidden]', 'busca[servico_id]'
        with_tag 'input[type=submit]'

        with_tag 'div#busca_nome_servico_auto_complete'
        with_tag 'input[name=?][type=text]', 'busca[nome_servico]'
        with_tag 'input[name=?][type=hidden]', 'busca[servico_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_servico.*/servicos/auto_complete_for_servico.*afterUpdateElement.*\$\('busca_servico_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag 'input[name=?]', 'busca[periodo_min]'
        with_tag 'input[name=?]', 'busca[periodo_max]'
      end
    end

    it "deve gerar de relatorio em pdf" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"Curso de Corel Draw", "periodo_recebimento"=>"on", "servico_id"=>servicos(:curso_de_corel).id.to_s, "situacao"=>"Todas", "periodo_max"=>"27/07/2010", "opcao_relatorio"=>"2"}
      get :totalizacao, :busca => params, :format => 'pdf'
      response.should be_success

      assigns[:titulo].should == "TOTALIZAÇÃO"
    end

    it 'deve exibir o alert quando não encontrar registros' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"Curso de Corel Draw", "periodo_recebimento"=>"on", "servico_id"=>servicos(:curso_de_corel).id.to_s, "situacao"=>"0", "periodo_max"=>"27/07/2010", "opcao_relatorio"=>"4"}
      post :totalizacao, :busca => params, :format => 'js'
      response.should be_success

      response.body.should_not include('window.open')
      response.body.should include('alert')
      assigns[:parcelas].should == 0
    end

    it 'não deve exibir o alert quando encontrar registros' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"Curso de Corel Draw", "periodo_recebimento"=>"on", "servico_id"=>servicos(:curso_de_corel).id.to_s, "situacao"=>"Todas", "periodo_max"=>"27/07/2010", "opcao_relatorio"=>"2", "arquivo" => "pdf"}
      post :totalizacao, :busca => params, :format => 'js'
      response.should be_success
      
      response.body.should include('window.open("/relatorios/totalizacao.pdf?busca')
      response.body.should_not include('alert')
    end

  end

  describe "Testes dos relatório de Controle de Cartões" do

    it "teste do form para busca" do
      post :controle_de_cartao
      response.should be_success
      response.should have_tag('form[action=?]', controle_de_cartao_relatorios_path) do
        with_tag('input[name=?]', 'busca[texto]')
        with_tag('select[name=?]', 'busca[situacao]')
        with_tag('select[name=?]', 'busca[bandeira]')
        with_tag('input[name=?]', 'busca[data_de_recebimento_min]')
        with_tag('input[name=?]', 'busca[data_de_recebimento_max]')
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it "deve exibir o alert quando não encontrar registros" do
      params = {"texto" => "", "data_do_deposito_max" => "", "data_de_recebimento_max" => "31/07/2008", "data_do_deposito_min" => "", "situacao" => "1", "bandeira" => "", "data_de_recebimento_min" => "31/07/2008"}
      post :controle_de_cartao, :busca => params, :format => 'js', :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('window.open')
      response.body.should include('Nenhum registro foi encontrado!'.to_json)
      assigns[:cartoes].should == []
    end

    it 'não deve exibir o alert quando encontrar registros' do
      params = {"texto" => "", "data_do_deposito_max" => "", "data_de_recebimento_max" => "31/07/2010", "data_do_deposito_min" => "", "situacao" => "1", "bandeira" => "", "data_de_recebimento_min" => "31/07/2008"}
      post :controle_de_cartao, :busca => params, :format => 'js', :tipo=>'pdf'
      response.should be_success

      response.body.should include('window.open("/relatorios/controle_de_cartao.pdf?busca')
      response.body.should_not include('alert')
    end

    it "deve gerar de relatorio em pdf" do
      params = {"texto" => "", "data_do_deposito_max" => "", "data_de_recebimento_max" => "31/07/2010", "data_do_deposito_min" => "", "situacao" => "1", "bandeira" => "", "data_de_recebimento_min" => "31/07/2008"}
      get :controle_de_cartao, :busca => params, :format => 'pdf', :tipo=>'pdf'
      response.should be_success

      assigns[:titulo].should == "CONTROLE DE CARTÕES DE CRÉDITO"
    end

  end

  describe "Testes do Relatório de Clientes Inadimplentes - Contas Receber" do

    it "Teste do form para relatório de inadimplência" do
      post :clientes_inadimplentes
      response.should be_success
      response.should  have_tag('form[action=?]', clientes_inadimplentes_relatorios_path) do
        with_tag 'input[name=?][type=text]', 'busca[nome_cliente]'
        with_tag 'input[name=?][type=hidden]', 'busca[cliente_id]'
        with_tag 'script', %r{Ajax.Autocompleter.*busca_nome_cliente.*/pessoas/auto_complete_for_cliente.*afterUpdateElement.*\$\('busca_cliente_id'\).value = value.id.*'argumento=' \+ element.value.*}
        with_tag 'input[name=?]', 'busca[periodo_min]'
        with_tag 'input[name=?]', 'busca[periodo_max]'
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
      end
    end

    it "testa chamada AJAX quando há clientes inadimplentes" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => '', 'nome_cliente' => '',
        'periodo_min' => '2004-02-02', 'periodo_max' => '2011-01-01'}, :tipo=>'pdf'
      response.should be_success
      response.body.should include('window.open("/relatorios/clientes_inadimplentes.pdf?busca')
      response.body.should_not include('alert')
    end

    it "testa chamada AJAX quando há clientes inadimplentes filtrando pelo cliente" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => pessoas(:paulo).id, 'nome_cliente' => '065.124.249-56 - Paulo Vitor Zeferino',
        'periodo_min' => '2004-02-02', 'periodo_max' => '2011-01-01'}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('window.open("/relatorios/clientes_inadimplentes.pdf?busca')
      response.body.should_not include('alert')
    end

    it "testa chamada AJAX quando há clientes inadimplentes e filtrado por período" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => '253499541', 'nome_cliente' => '065.124.249-56 - Paulo Vitor Zeferino',
        'periodo_min' => '01/11/2009', 'periodo_max' => '29/11/2009'}, :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/clientes_inadimplentes.pdf?busca')
      response.body.should include('alert')
    end

    it "testa chamada AJAX quando há clientes inadimplentes e tenta gerar Excel" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => '', 'nome_cliente' => '',
        'periodo_min' => '2004-02-02', 'periodo_max' => '2011-01-01'}, :tipo=>'xls'
      response.should be_success
      response.body.should include('window.open("/relatorios/clientes_inadimplentes.xls?busca')
      response.body.should_not include('alert')
    end

    it "testa chamada AJAX quando há clientes inadimplentes filtrando pelo cliente e tentando gerar Excel" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => pessoas(:paulo).id, 'nome_cliente' => '065.124.249-56 - Paulo Vitor Zeferino',
        'periodo_min' => '2004-02-02', 'periodo_max' => '2011-01-01'}, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/clientes_inadimplentes.xls?busca')
      response.body.should_not include('alert')
    end

    it "testa chamada AJAX quando há clientes inadimplentes e filtrado por período e tentando gerar Excel" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => '253499541', 'nome_cliente' => '065.124.249-56 - Paulo Vitor Zeferino',
        'periodo_min' => '01/11/2009', 'periodo_max' => '29/11/2009'}, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/clientes_inadimplentes.xls?busca')
      response.body.should include('alert')
    end

    it "testa chamada AJAX quando não há clientes inadimplentes e filtrado por período e tentando gerar Excel" do
      get :clientes_inadimplentes, :format => 'js', :busca => {'cliente_id' => '253499541', 'nome_cliente' => '065.124.249-56 - Paulo Vitor Zeferino',
        'periodo_min' => '2004-01-01', 'periodo_max' => '2004-12-31'}, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/clientes_inadimplentes.xls?busca')
      response.body.should include('alert')
    end
  end

  describe "Teste do Relatorio - Follow-up Cliente" do

    it "Teste do form para relatorio de follow-up por cliente" do
      get :follow_up_cliente
      response.should be_success
      response.should  have_tag('form[action=?]', follow_up_cliente_relatorios_path) do
        with_tag("input[name=?]", "busca[cliente_id]")
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
        with_tag('input[name=?][type=?][value=?]','commit','submit','Pesquisar')
      end
    end

    it "Verifica se está gerando o PDF do relatório de Follow-up por Cliente" do
      get :follow_up_cliente, :format => 'js', :busca =>{"cliente_id"=>"253499541", "nome_cliente"=>"065.124.249-56 - Paulo Vitor Zeferino"}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('window.open("/relatorios/follow_up_cliente.pdf?busca')
      response.body.should_not include('alert')
    end

    it "Verifica se não está gerando o PDF do relatório de Folloe-up por Cliente quando não seleciona um cliente" do
      get :follow_up_cliente, :format => 'js', :busca =>{"cliente_id"=>"", "nome_cliente"=>""}, :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/follow_up_cliente.pdf?busca')
      response.body.should include('alert')
    end

    it "Verifica se está gerando o XLS do relatório de Follow-up por Cliente" do
      get :follow_up_cliente, :format => 'js', :busca =>{"cliente_id"=>"253499541", "nome_cliente"=>"065.124.249-56 - Paulo Vitor Zeferino"}, :tipo=>'xls'
      response.should be_success

      response.body.should include('window.open("/relatorios/follow_up_cliente.xls?busca')
      response.body.should_not include('alert')
    end

    it "Verifica se não está gerando o xls do relatório de Folloe-up por Cliente quando não seleciona um cliente" do
      get :follow_up_cliente, :format => 'js', :busca =>{"cliente_id"=>"", "nome_cliente"=>""}, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('window.open("/relatorios/follow_up_cliente.xls?busca')
      response.body.should include('alert')
    end
  end

  describe "Teste do Relatorio - Agendamentos" do

    it "Teste do form para relatorio de agendamentos" do
      get :agendamentos
      response.should be_success
      response.should  have_tag('form[action=?]', agendamentos_relatorios_path) do
        with_tag 'input[name=?]', 'busca[periodo_min]'
        with_tag 'input[name=?]', 'busca[periodo_max]'
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
        with_tag('input[name=?][type=?][value=?]','commit','submit','Pesquisar')
      end
    end

    it "Verifica se não gera o alerta quando não possui agendamentos quando se tenta gerar PDF" do
      get :agendamentos, :format=>'js' , :busca => {'periodo_min'=>'2005-01-01','periodo_max'=>'2005-12-01'}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/agendamentos.pdf?busca')
    end

    it "Verifica se gera o PDF quando tiver registros" do
      get :agendamentos, :format=>'js' , :busca => {'periodo_min'=>'2005-01-01','periodo_max'=>'2009-12-01'}, :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('window.open("/relatorios/agendamentos.pdf?busca')
    end

    it "Verifica se gera o alerta quando não tiver registros no periodo escolhido tentando gerar um PDF" do
      get :agendamentos, :format=>'js' , :busca => {'periodo_min'=>'2002-01-01','periodo_max'=>'2003-12-01'}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/agendamentos.pdf?busca')
    end

    it "Verifica se gera o alerta quando não possui agendamentos quando se tenta gerar Excel" do
      get :agendamentos, :format=>'js' , :busca => {'periodo_min'=>'2005-01-01','periodo_max'=>'2005-12-01'}, :tipo=>'xls'
      response.should be_success

      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/agendamentos.xls?busca')
    end

    it "Verifica se gera o Excel quando tiver registros" do
      get :agendamentos, :format=>'js' , :busca => {'periodo_min'=>'2005-01-01','periodo_max'=>'2009-12-01'}, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('window.open("/relatorios/agendamentos.xls?busca')
    end

    it "Verifica se gera o alerta quando não tiver registros no periodo escolhido tentando gerar um Excel" do
      get :agendamentos, :format=>'js' , :busca => {'periodo_min'=>'2002-01-01','periodo_max'=>'2003-12-01'}, :tipo=>'xls'
      response.should be_success

      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/agendamentos.xls?busca')
    end
  end

  describe "Testes do Relatório - Receitas por Procedimento" do

    it "teste do form para relatorio de receitas por procedimento" do
      get :receitas_por_procedimento
      response.should be_success
      response.should  have_tag('form[action=?]', receitas_por_procedimento_relatorios_path) do
        with_tag('input[name=?]', 'busca[periodo_min]')
        with_tag('input[name=?]', 'busca[periodo_max]')
        with_tag('input[name=?]', 'busca[conta_contabil_inicial_id]')
        with_tag('input[name=?]', 'busca[conta_contabil_final_id]')
        with_tag('input[name=?]', 'busca[unidade_organizacional_inicial_id]')
        with_tag('input[name=?]', 'busca[unidade_organizacional_final_id]')
        with_tag('input[name=?]', 'busca[centro_inicial_id]')
        with_tag('input[name=?]', 'busca[centro_final_id]')
        with_tag("input[name=?][type=?][value=?]","tipo","radio","xls")
        with_tag("input[name=?][type=?][checked=?][value=?]","tipo","radio","checked","pdf")
        with_tag('input[name=?][type=?][value=?]','commit','submit','Pesquisar')
      end
    end

    it "Verifica se não gera o alerta quando não possui movimento das contas quando se tenta gerar PDF" do
      get :receitas_por_procedimento, :format=>'js' , :busca => {'periodo_min'=>'2005-01-01','periodo_max'=>'2005-12-01', "nome_unidade_organizacional_final"=>"", "centro_inicial_id"=>"", "nome_centro_inicial"=>"",
        "nome_conta_contabil_inicial"=>"", "unidade_organizacional_final_id"=>"", "nome_centro_final"=>"", "nome_conta_contabil_final"=>"", "unidade_organizacional_inicial_id"=>"", "nome_unidade_organizacional_inicial"=>"", "conta_contabil_final_id"=>"",
        "centro_final_id"=>"", "conta_contabil_inicial_id"=>""}, :tipo=>'pdf'
      response.should be_success

      response.body.should include('alert')
      response.body.should_not include('window.open("/relatorios/receitas_por_procedimento.pdf?busca')
    end

    it "Verifica se gera o relatório em PDF quando possui movimento das contas" do
      get :receitas_por_procedimento, :format=>'js' , :busca => {'periodo_min'=>'','periodo_max'=>'', "nome_unidade_organizacional_final"=>"", "centro_inicial_id"=>"", "nome_centro_inicial"=>"",
        "nome_conta_contabil_inicial"=>"", "unidade_organizacional_final_id"=>"", "nome_centro_final"=>"", "nome_conta_contabil_final"=>"", "unidade_organizacional_inicial_id"=>"", "nome_unidade_organizacional_inicial"=>"", "conta_contabil_final_id"=>"",
        "centro_final_id"=>"", "conta_contabil_inicial_id"=>""}, :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('window.open("/relatorios/receitas_por_procedimento.pdf?busca')
    end

    it "Verifica se gera o relatório em PDF quando possui movimento das contas num  periodo escolhido" do
      get :receitas_por_procedimento, :format=>'js' , :busca => {'periodo_min'=>'2008-01-01','periodo_max'=>'2010-03-01', "nome_unidade_organizacional_final"=>"", "centro_inicial_id"=>"", "nome_centro_inicial"=>"",
        "nome_conta_contabil_inicial"=>"", "unidade_organizacional_final_id"=>"", "nome_centro_final"=>"", "nome_conta_contabil_final"=>"", "unidade_organizacional_inicial_id"=>"", "nome_unidade_organizacional_inicial"=>"", "conta_contabil_final_id"=>"",
        "centro_final_id"=>"", "conta_contabil_inicial_id"=>""}, :tipo=>'pdf'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('window.open("/relatorios/receitas_por_procedimento.pdf?busca')
    end


    it "Verifica se gera o relatório em Excel quando possui movimento das contas" do
      get :receitas_por_procedimento, :format=>'js' , :busca => {'periodo_min'=>'','periodo_max'=>'', "nome_unidade_organizacional_final"=>"", "centro_inicial_id"=>"", "nome_centro_inicial"=>"",
        "nome_conta_contabil_inicial"=>"", "unidade_organizacional_final_id"=>"", "nome_centro_final"=>"", "nome_conta_contabil_final"=>"", "unidade_organizacional_inicial_id"=>"", "nome_unidade_organizacional_inicial"=>"", "conta_contabil_final_id"=>"",
        "centro_final_id"=>"", "conta_contabil_inicial_id"=>""}, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('window.open("/relatorios/receitas_por_procedimento.xls?busca')
    end

    it "Verifica se gera o relatório em Excel quando possui movimento das contas num  periodo escolhido" do
      get :receitas_por_procedimento, :format=>'js' , :busca => {'periodo_min'=>'2008-01-01','periodo_max'=>'2010-03-01', "nome_unidade_organizacional_final"=>"", "centro_inicial_id"=>"", "nome_centro_inicial"=>"",
        "nome_conta_contabil_inicial"=>"", "unidade_organizacional_final_id"=>"", "nome_centro_final"=>"", "nome_conta_contabil_final"=>"", "unidade_organizacional_inicial_id"=>"", "nome_unidade_organizacional_inicial"=>"", "conta_contabil_final_id"=>"",
        "centro_final_id"=>"", "conta_contabil_inicial_id"=>""}, :tipo=>'xls'
      response.should be_success

      response.body.should_not include('alert')
      response.body.should include('window.open("/relatorios/receitas_por_procedimento.xls?busca')
    end
  end

end
