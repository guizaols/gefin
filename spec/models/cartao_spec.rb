require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cartao do
 
  fixtures :all
    
  it "verifica os relacionamentos" do
    cartoes(:cartao_do_manuel_primeira_parcela).parcela.should == parcelas(:primeira_parcela_recebida_em_cartao)
    cartoes(:cartao_do_manuel_primeira_parcela).parcela_recebimento_de_conta.should == ParcelaRecebimentoDeConta.find(parcelas(:primeira_parcela_recebida_em_cartao).id)
    cartao = cartoes(:cartao_do_manuel_primeira_parcela)
    cartao.situacao = Cartao::BAIXADO
    cartao.data_do_deposito = '15/06/2009'
    cartao.historico = 'Novo histórico'
    cartao.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    cartao.save!.should == true
  end
  
  it "verifica a obrigatoriedade dos campos" do
    @cartao = Cartao.new
    @cartao.valid?    
    @cartao.errors.on(:parcela).should_not be_nil
    @cartao.errors.on(:bandeira).should_not be_nil
    @cartao.errors.on(:numero).should_not be_nil
    @cartao.errors.on(:codigo_de_seguranca).should_not be_nil
    @cartao.errors.on(:validade).should_not be_nil
    @cartao.errors.on(:nome_do_titular).should_not be_nil
    @cartao.errors.on(:situacao).should be_nil
    @cartao.situacao.should == Cartao::GERADO
    @cartao.parcela = parcelas(:primeira_parcela_recebida_em_cartao)
    @cartao.bandeira = 1
    @cartao.numero = '8494302559190206'
    @cartao.codigo_de_seguranca = '376'
    @cartao.validade = '11/12'
    @cartao.nome_do_titular = 'Manuel Cerqueira Lima'
    @cartao.valid?
    @cartao.errors.on(:parcela).should be_nil
    @cartao.errors.on(:bandeira).should be_nil
    @cartao.errors.on(:numero).should be_nil
    @cartao.errors.on(:codigo_de_seguranca).should be_nil
    @cartao.errors.on(:validade).should be_nil
    @cartao.errors.on(:nome_do_titular).should be_nil
    @cartao.situacao = Cartao::BAIXADO
    @cartao.valid?
    @cartao.errors.on(:data_do_deposito).should_not be_nil
    @cartao.errors.on(:conta_contabil).should_not be_nil
    @cartao.errors.on(:historico).should_not be_nil
    @cartao.data_do_deposito = '20/01/2009'
    @cartao.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @cartao.historico = "Nenhuma"
    @cartao.valid?
    @cartao.errors.on(:data_do_deposito).should be_nil
    @cartao.errors.on(:conta_contabil).should be_nil
    @cartao.errors.on(:historico).should be_nil
  end

  it "verifica data_br_field" do
    @cartao = Cartao.new
    @cartao.data_do_deposito = '2009-08-02'
    @cartao.data_do_deposito.should == '02/08/2009'
  end

  it "verifica se a data_de_deposito esta no formato date" do
    @cartao = Cartao.new
    @cartao.data_do_deposito = '2009-08-02 00:00:00'
    @cartao.data_do_deposito.should == '02/08/2009'
  end

  it "verifica se valida mês" do
    @cartao = Cartao.new :validade => '11/12'
    @cartao.valid?
    @cartao.errors.on(:validade).should be_nil
    @cartao.validade = '15-30'
    @cartao.valid?
    @cartao.errors.on(:validade).should_not be_nil
    @cartao.errors.on(:validade).should == 'Mês inválido ou formato inválido, a validade deve estar no padrão MM/AAAA.'
    @cartao.validade = '1530'
    @cartao.valid?
    @cartao.errors.on(:validade).should_not be_nil
    @cartao.errors.on(:validade).should == ["Mês inválido ou formato inválido, a validade deve estar no padrão MM/AAAA.", "está com a validade vencida."]
  end  
  
  it "testa se grava data de recebimento igual a data de baixa da parcela" do
    @parcela = Parcela.new :data_vencimento => '06/04/2009', :conta => pagamento_de_contas(:pagamento_cheque), :valor => 5000
    @parcela.save!
    @parcela.data_da_baixa = "29/05/2010"
    @parcela.numero = 1
    @parcela.baixando = true
    @parcela.historico = "teste" 
    @parcela.forma_de_pagamento = Parcela::CARTAO
    @parcela.cheques << Cheque.first
    @cartao = @parcela.cartoes.build
    @cartao.validade = "03/12"
    @cartao.bandeira = 1
    @cartao.numero = 2098348923
    @cartao.codigo_de_seguranca = 234
    @cartao.nome_do_titular = "Paulo"
    assert_difference 'Cartao.count', 1 do
      @parcela.save
    end
    @parcela.cheques.should == []
  end

  it "verifica se testa o bandeira verbose" do
    @cartao = Cartao.new :bandeira => 1
    @cartao.bandeira_verbose.should == 'Visa Crédito'
    @cartao = Cartao.new :bandeira => 2
    @cartao.bandeira_verbose.should == 'Redecard'
    @cartao = Cartao.new :bandeira => 3
    @cartao.bandeira_verbose.should == 'Mastercard'
    @cartao = Cartao.new :bandeira => 4
    @cartao.bandeira_verbose.should == 'Diners'
    @cartao = Cartao.new :bandeira => 5
    @cartao.bandeira_verbose.should == 'American Express'
    @cartao = Cartao.new :bandeira => 6
    @cartao.bandeira_verbose.should == 'Maestro'
    @cartao = Cartao.new :bandeira => 7
    @cartao.bandeira_verbose.should == 'Credicard'
    @cartao = Cartao.new :bandeira => 8
    @cartao.bandeira_verbose.should == 'Ourocard'
    @cartao = Cartao.new :bandeira => 9
    @cartao.bandeira_verbose.should == 'Visa Débito'
  end
  
  it "teste de validade do cartao" do
    @cartao = Cartao.new :parcela => parcelas(:primeira_parcela), :validade => "12/01",
      :bandeira => 1, :numero => 2098348923, :codigo_de_seguranca => 234, :nome_do_titular => "Paulo"
    @cartao.should_not be_valid
    @cartao.errors.on(:validade).should_not be_nil
    @cartao.validade = "03/09"
    @cartao.should_not be_valid
    @cartao.errors.on(:validade).should_not be_nil
    @cartao.validade = Date.tomorrow.strftime("%m/%y")
    @cartao.should be_valid
    @cartao.errors.on(:validade).should be_nil
  end

  it "testando o verbose para situacao" do
    c = Cartao.new
    c.situacao_verbose.should == 'Pendente'
    c.situacao = Cartao::BAIXADO
    c.situacao_verbose.should == 'Baixado'
  end

  it "testa funcao valor liquido" do
    cartoes(:cartao_do_manuel_primeira_parcela).valor_liquido.should == "25.00"
    cartoes(:cartao_do_manuel_segunda_parcela).valor_liquido.should == "25.00"
  end

  it "verifica se está fazendo a pesquisa de cartao" do
    cartoes(:cartao_do_andre_primeira_parcela).destroy
    cartoes(:cartao_do_andre_segunda_parcela).destroy
    [
      #0
      [{"texto" => "Paulo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => "1"}, [Cartao.first]],
      #1
      [{"texto" => "Man", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => "1"}, [Cartao.first]],
      #2
      [{"texto" => "Jo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => "2"}, [Cartao.last]],
      #3
      [{"texto" => "Cerqueira", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #4
      [{"texto" => "", "situacao" => "2", "data_do_deposito_min" => "01/01/2001", "data_do_deposito_max" => "01/01/2020",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, []],
      #5
      [{"texto" => "Cerqueira", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => "3"}, []],
      #6
      [{"texto" => "Paulo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #7
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, []],
      #8
      [{"texto" => "Paulo", "situacao" => "1",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #9
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "30/12/2008", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #10
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "30/12/2008", "data_de_recebimento_max" => "06/06/2009", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #11
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "06/06/2009", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #12
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "30/12/2008", "data_de_recebimento_max" => "30/12/2008", "bandeira" => ""}, []],
      #13
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "05/06/2009", "bandeira" => ""}, [Cartao.first, Cartao.last]],
      #14
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "06/09/2009", "data_de_recebimento_max" => "", "bandeira" => ""}, []]
    ].each_with_index do |consulta, index|
      #            puts index
      Cartao.pesquisar_cartoes(consulta.first, unidades(:senaivarzeagrande).id).collect(&:id).sort.should == consulta.last.collect(&:id).sort
    end

    [
      #0
      [{"texto" => "Cerqueira", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, []]
    ].each_with_index do |consulta, index|
      #      puts index
      Cartao.pesquisar_cartoes(consulta.first, unidades(:sesivarzeagrande).id).should == consulta.last
    end

    #     Busca com baixa!
    Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id], 'data_do_deposito' => Date.today.to_s_br,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [true, 'Dados baixados com sucesso!']
    
    [
      #0
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first]],
      #1
      [{"texto" => "Man", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first]],
      #2
      [{"texto" => "Paulo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.last]],
      #3
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => (Date.today - 1).to_s_br, "data_do_deposito_max" => (Date.today + 2).to_s_br,
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first]],
      #4
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => Date.today.to_s_br, "data_do_deposito_max" => "",
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first]],
      #5
      [{"texto" => "Man", "situacao" => "2", "data_do_deposito_min" => '', "data_do_deposito_max" => Date.today.to_s_br,
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, [Cartao.first]],
      #6
      [{"texto" => "Man", "situacao" => "2", "data_do_deposito_min" => (Date.today + 2).to_s_br, "data_do_deposito_max" => (Date.today + 3).to_s_br,
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, []],
      #7
      [{"texto" => "Man", "situacao" => "2", "data_do_deposito_min" => (Date.today + 6).to_s_br, "data_do_deposito_max" => (Date.today + 3).to_s_br,
          "data_de_recebimento_min" => "", "data_de_recebimento_max" => "", "bandeira" => ""}, []],
      [{}, []]
    ].each_with_index do |consulta, index|
      #      puts index
      Cartao.pesquisar_cartoes(consulta.first, unidades(:senaivarzeagrande).id).should == consulta.last
    end

    describe 'testes de baixa' do

      it "não pode deixar baixar um cartao já baixado" do
        parcelas(:primeira_parcela_recebida_em_cartao).situacao = 3
        parcelas(:primeira_parcela_recebida_em_cartao).save!
        @cartao = Cartao.new :parcela => parcelas(:primeira_parcela_recebida_em_cartao), :bandeira => 1, :nome_do_titular => 'Manuel Cerqueira Antunes',
          :numero => '8494302559190206', :codigo_de_seguranca => '376', :validade => '11/12'
        # Save de criação
        @cartao.save

        @cartao.situacao = Cartao::BAIXADO
        @cartao.data_do_deposito = '20/01/2009'
        @cartao.historico = 'Novo histórico'
        @cartao.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
        # Save de baixa
        @cartao.save

        @cartao.data_do_deposito = '21/01/2009'
        @cartao.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
        @cartao.historico = 'Novo histórico'
        # Nova tentativa de save
        @cartao.valid?
        @cartao.errors.on(:base).should == 'O dado já foi baixado.'
      end

      it "garante proteção dos atributos data_do_deposito e plano_de_conta_id" do
        @cartao = Cartao.new :data_do_deposito => '15/06/2009', :plano_de_conta_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
        @cartao.data_do_deposito.should == nil
        @cartao.plano_de_conta_id.should == nil
        @cartao.data_do_deposito = '15/06/2009'
        @cartao.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
        @cartao.data_do_deposito.should == '15/06/2009'
        @cartao.plano_de_conta_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      end

      it "verifica se está baixando cartoes com tudo certo" do
        assert_difference 'Movimento.count', 2 do
          assert_difference 'ItensMovimento.count', 4 do
            Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '15/06/2009',
                'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [true, "Dados baixados com sucesso!"]

            c = Cartao.first
            c.data_do_deposito.should == '15/06/2009'
            c.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
            c.situacao.should == Cartao::BAIXADO
            c.historico.should == 'Nova baixa'

            c_dois = Cartao.last
            c_dois.data_do_deposito.should == '15/06/2009'
            c_dois.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
            c_dois.situacao.should == Cartao::BAIXADO
            c_dois.historico.should == 'Nova baixa'
          end
        end
      end

      it "verifica se está baixando cartoes e gerando lancamentos contábeis" do
        assert_difference 'Movimento.count', 1 do
          assert_difference 'ItensMovimento.count', 2 do
            Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id], 'data_do_deposito' => '15/06/2009',
                'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Verificando se está gerando um lançamento'}, unidades(:senaivarzeagrande).id).should == [true, "Dados baixados com sucesso!"]

            cartao = cartoes(:cartao_do_manuel_primeira_parcela)

            m = Movimento.last
            m.historico.should == 'Verificando se está gerando um lançamento'
            m.data_lancamento.should == '15/06/2009'
            m.conta.should == cartao.parcela.conta
            m.numero_de_controle.should == 'SVG-CTR09/09000791'
            m.tipo_lancamento.should == 'E'
            m.tipo_documento.should == 'CTR'
            m.numero_da_parcela.should == 1
            m.pessoa.should == cartao.parcela.conta.pessoa
            m.provisao.should == Movimento::BAIXA
            m.valor_total.should == 2500

            primeiro_item = m.itens_movimentos.first
            primeiro_item.tipo.should == "D"
            primeiro_item.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
            primeiro_item.centro.should == cartao.parcela.conta.centro
            primeiro_item.unidade_organizacional.should == cartao.parcela.conta.unidade_organizacional
           
            segundo_item = m.itens_movimentos.last
            segundo_item.tipo.should == "C"
            segundo_item.plano_de_conta.should == cartao.parcela.conta.conta_contabil_receita
            segundo_item.centro.should == cartao.parcela.conta.centro
            segundo_item.unidade_organizacional.should == cartao.parcela.conta.unidade_organizacional
          end
        end
      end
      
      it "gerando lancamentos contábeis com rateio" do
        # Vincula uma parcela com rateio a um recebimento de conta
        parcela = parcelas(:primeira_parcela)
        parcela.conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
        parcela.save false
        # Vincula o cartao a uma parcela com rateio
        cartao_a_baixar = cartoes(:cartao_do_manuel_primeira_parcela)
        cartao_a_baixar.parcela_id = parcelas(:primeira_parcela).id
        cartao_a_baixar.situacao = Cartao::BAIXADO
        cartao_a_baixar.historico = 'Verificando se está gerando um lançamento'
        cartao_a_baixar.data_do_deposito = '15/06/2009'
        cartao_a_baixar.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
        cartao_a_baixar.save

        assert_difference 'Movimento.count', 1 do
          assert_difference 'ItensMovimento.count', 7 do
            cartao_a_baixar.efetua_lancamento_contabil_de_cartao(2009)
          end
        end
        
        Movimento.last.itens_movimentos.select {|i| i.tipo == 'D' }.length.should == 2
        Movimento.last.itens_movimentos.select {|i| i.tipo == 'C' }.length.should == 5
      end

      it "gerando lancamentos contábeis com rateio, descontos, multa, acrescimo e juros" do
        # Vincula uma parcela com rateio a um recebimento de conta
        parcela = parcelas(:primeira_parcela)
        parcela.conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
        parcela.save false
        # Vincula o cartao a uma parcela com rateio, descontos, multa, acrescimo e juros
        cartao_a_baixar = cartoes(:cartao_do_manuel_primeira_parcela)
        cartao_a_baixar.parcela_id = parcelas(:primeira_parcela).id
        cartao_a_baixar.situacao = Cartao::BAIXADO
        cartao_a_baixar.historico = 'Verificando se está gerando um lançamento'
        cartao_a_baixar.data_do_deposito = '15/06/2009'
        cartao_a_baixar.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
        cartao_a_baixar.save

        assert_difference 'Movimento.count', 1 do
          assert_difference 'ItensMovimento.count', 7 do
            cartao_a_baixar.efetua_lancamento_contabil_de_cartao(2009)
          end
        end

        Movimento.last.itens_movimentos.select {|i| i.tipo == 'D' }.length.should == 2
        Movimento.last.itens_movimentos.select {|i| i.tipo == 'C' }.length.should == 5
      end

      it "verifica se não está baixando cartoes, quando não há ids!" do
        Cartao.baixar(2009, {'data_do_deposito' => '15/06/2009',
            'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [false, 'Selecione pelo menos um dado para executar a baixa!']
      end

      it "verifica se não está baixando cartoes, pois foi passado um id errado" do
        Cartao.baixar(2009, {'ids' => [''], 'data_do_deposito' => '15/06/2009',
            'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [false, "Você selecionou dados que já foram baixados!"]

        c = Cartao.first
        c.data_do_deposito.should == nil
        c.conta_contabil.should == nil
        c.situacao.should == Cartao::GERADO
        c.historico.should == nil
      end

      it "verifica se não está baixando cartoes, pois foi passada um data de deposito inválida" do
        Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '',
            'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [false, "Não foi possível baixar os dados!\n\nO campo data do depósito deve ser preenchido."]

        c = Cartao.first
        c.data_do_deposito.should == nil
        c.conta_contabil.should == nil
        c.situacao.should == Cartao::GERADO
        c.historico.should == nil

        c_dois = Cartao.last
        c_dois.data_do_deposito.should == nil
        c_dois.conta_contabil.should == nil
        c_dois.situacao.should == Cartao::GERADO
        c_dois.historico.should == nil
      end
      
      it "verifica se não está baixando cartoes, pois foi passada uma conta contabil inválida" do
        Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '15/06/2009',
            'conta_contabil_id' => '', 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [false, 'Selecione uma conta válida!']

        c = Cartao.first
        c.data_do_deposito.should == nil
        c.conta_contabil.should == nil
        c.situacao.should == Cartao::GERADO
        c.historico.should == nil

        c_dois = Cartao.last
        c_dois.data_do_deposito.should == nil
        c_dois.conta_contabil.should == nil
        c_dois.situacao.should == Cartao::GERADO
        c_dois.historico.should == nil
      end
      
      it "verifica se esta retornando exceção quando a entidade da unidade da sessao nao e a mesma da conta selecionada" do
        Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '15/06/2009',
            'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [false, 'Selecione uma conta válida!']
      end
      
      it "verifica se não baixa duas vezes os mesmos cartoes" do
        assert_difference 'Movimento.count', 2 do
          assert_difference 'ItensMovimento.count', 4 do
            Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '15/06/2009',
                'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [true, "Dados baixados com sucesso!"]
          end
        end

        assert_no_difference 'Movimento.count' do
          assert_no_difference 'ItensMovimento.count' do
            Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '16/06/2009',
                'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova tentativa de baixa'}, unidades(:senaivarzeagrande).id).should == [false, "Você selecionou dados que já foram baixados!"]
          end
        end

        assert_no_difference 'Movimento.count' do
          assert_no_difference 'ItensMovimento.count' do
            Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '16/06/2009',
                'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova tentativa de baixa'}, unidades(:senaivarzeagrande).id).should == [false, "Você selecionou dados que já foram baixados!"]
          end
        end
      end

      
      it "verifica se não baixa com unidade incorreta!" do
        Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_manuel_primeira_parcela).id, cartoes(:cartao_do_manuel_segunda_parcela).id], 'data_do_deposito' => '15/06/2009',
            'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, 'ERRO').should == [false, "Unidade inválida!"]
      end
    end
  end

  describe 'estorno de cartoes' do
    it 'gerando baixas' do
      lambda do
        lambda do
          @cartoes = [cartoes(:cartao_do_andre_primeira_parcela),cartoes(:cartao_do_andre_segunda_parcela)]
          @cartoes.collect(&:situacao).should == [Cartao::GERADO,Cartao::GERADO]
          gerar_cartoes_baixados
          @cartoes.collect(&:reload)
          @cartoes.collect(&:situacao).should == [Cartao::BAIXADO,Cartao::BAIXADO]
        end.should change(ItensMovimento,:count).by(4)
      end.should change(Movimento,:count).by(2)
    end

    it 'com tudo correto' do
      @cartoes = [cartoes(:cartao_do_andre_primeira_parcela),cartoes(:cartao_do_andre_segunda_parcela)]
      gerar_cartoes_baixados
      @cartoes.collect(&:reload)
      @cartoes.collect(&:situacao).should == [Cartao::BAIXADO,Cartao::BAIXADO]
      lambda do
        lambda do
          lambda do
            Cartao.estornar({'ids' => [cartoes(:cartao_do_andre_primeira_parcela).id, cartoes(:cartao_do_andre_segunda_parcela).id]},
              unidades(:senaivarzeagrande).id).should == [true, "Cartões estornados com sucesso!"]
            @cartoes.collect(&:reload)
            @cartoes.collect(&:situacao).should == [Cartao::GERADO,Cartao::GERADO]
          end.should_not change(Cartao,:count)
        end.should change(ItensMovimento,:count).by(-4)
      end.should change(Movimento,:count).by(-2)
    end

    it 'sem cartoes' do
      @cartoes = [cartoes(:cartao_do_andre_primeira_parcela),cartoes(:cartao_do_andre_segunda_parcela)]
      gerar_cartoes_baixados
      @cartoes.collect(&:reload)
      @cartoes.collect(&:situacao).should == [Cartao::BAIXADO,Cartao::BAIXADO]
      lambda do
        lambda do
          lambda do
            Cartao.estornar({'ids' => []},
              unidades(:senaivarzeagrande).id).should == [false, "Selecione pelo menos um cartão para estornar!"]
            @cartoes.collect(&:reload)
            @cartoes.collect(&:situacao).should == [Cartao::BAIXADO,Cartao::BAIXADO]
          end.should_not change(Cartao,:count)
        end.should_not change(ItensMovimento,:count)
      end.should_not change(Movimento,:count)
    end

    it 'sem unidades' do
      @cartoes = [cartoes(:cartao_do_andre_primeira_parcela),cartoes(:cartao_do_andre_segunda_parcela)]
      gerar_cartoes_baixados
      @cartoes.collect(&:reload)
      @cartoes.collect(&:situacao).should == [Cartao::BAIXADO,Cartao::BAIXADO]
      lambda do
        lambda do
          lambda do
            Cartao.estornar({'ids' => [cartoes(:cartao_do_andre_primeira_parcela).id, cartoes(:cartao_do_andre_segunda_parcela).id]},nil).should == [false, "Unidade inválida!"]
            @cartoes.collect(&:reload)
            @cartoes.collect(&:situacao).should == [Cartao::BAIXADO,Cartao::BAIXADO]
          end.should_not change(Cartao,:count)
        end.should_not change(ItensMovimento,:count)
      end.should_not change(Movimento,:count)
    end

    def gerar_cartoes_baixados
      Cartao.baixar(2009, {'ids' => [cartoes(:cartao_do_andre_primeira_parcela).id, cartoes(:cartao_do_andre_segunda_parcela).id], 'data_do_deposito' => '16/06/2009',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa'}, unidades(:senaivarzeagrande).id).should == [true, "Dados baixados com sucesso!"]
    end
  end
  
end
