require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Cheque do

  it "verifica os relacionamentos" do
    cheques(:vista).parcela.should == parcelas(:primeira_parcela_recebida_cheque_a_vista)
    cheques(:vista).parcela_recebimento_de_conta.should == ParcelaRecebimentoDeConta.find(parcelas(:primeira_parcela_recebida_cheque_a_vista).id)
    cheque_a_vista = cheques(:vista)
    cheque_a_vista.banco.should == bancos(:banco_do_brasil)
    cheque_a_vista.conta_contabil_transitoria.should == plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque_a_vista.conta_contabil_devolucao.should == plano_de_contas(:plano_de_contas_devolucao)
    cheque_a_vista.situacao = Cheque::BAIXADO
    cheque_a_vista.data_do_deposito = '15/06/2009'
    cheque_a_vista.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    cheque_a_vista.save.should == true
    cheque_a_vista.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
  end

  it "testa a regra de negocio no campo conta_contabil_transitoria_id" do
    @cheque = cheques(:vista)
    @cheque.conta_contabil_transitoria = nil
    @cheque.should_not be_valid
    @cheque.errors.on(:conta_contabil_transitoria).should_not be_nil
    @novo_cheque = cheques(:vista)
    @novo_cheque.conta_contabil_transitoria = nil
    @novo_cheque.situacao = 2
    @novo_cheque.should_not be_valid
    @novo_cheque.errors.on(:conta_contabil_transitoria).should be_nil
  end

  it "verifica a obrigatoriedade dos campos" do
    @cheque = Cheque.new
    @cheque.should_not be_valid
    @cheque.errors.on(:parcela).should_not be_nil
    @cheque.errors.on(:banco).should_not be_nil
    @cheque.errors.on(:agencia).should_not be_nil
    @cheque.errors.on(:conta).should_not be_nil
    @cheque.errors.on(:numero).should_not be_nil
    @cheque.errors.on(:data_para_deposito).should_not be_nil
    @cheque.errors.on(:nome_do_titular).should_not be_nil
    @cheque.errors.on(:situacao).should be_nil
    @cheque.errors.on(:data_do_pagamento).should be_nil
    @cheque.errors.on(:conta_contabil).should be_nil
    @cheque.parcela = parcelas(:primeira_parcela_recebida_cheque_a_vista)
    @cheque.banco = bancos(:banco_do_brasil)
    @cheque.agencia = '0108-5'
    @cheque.conta = '2716801-5'
    @cheque.numero = '010203'
    @cheque.data_para_deposito = '2009-01-20 00:00:00'
    @cheque.nome_do_titular = 'Alvaro Cortes'
   
    @cheque.situacao.should == Cheque::GERADO
    @cheque.valid?
    @cheque.errors.on(:parcela).should be_nil
    @cheque.errors.on(:banco).should be_nil
    @cheque.errors.on(:agencia).should be_nil
    @cheque.errors.on(:conta).should be_nil
    @cheque.errors.on(:numero).should be_nil
    @cheque.errors.on(:data_para_deposito).should be_nil
    @cheque.errors.on(:nome_do_titular).should be_nil

    @cheque.situacao = Cheque::BAIXADO
    @cheque.valid?
    @cheque.errors.on(:data_do_deposito).should_not be_nil
    @cheque.errors.on(:conta_contabil).should_not be_nil
    @cheque.data_do_deposito = '20/01/2009'
    @cheque.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @cheque.valid?
    @cheque.errors.on(:data_do_deposito).should be_nil
    @cheque.errors.on(:conta_contabil).should be_nil
  end

  it "teste da inclusao ser apenas VISTA ou PRAZO" do
    @cheque = cheques(:vista)
    @cheque.prazo = 3
    @cheque.valid?
    @cheque.errors.on(:prazo).should == "deve ser preenchido."
    @cheque.prazo = 2
    @cheque.valid?
    @cheque.errors.on(:prazo).should be_nil
  end

  it "verifica os filtros de cheques a vista e a prazo" do
    Cheque.a_vista.should == [cheques(:cheque_do_andre_primeira_parcela),cheques(:vista),cheques(:cheque_do_andre_segunda_parcela)]
    Cheque.a_prazo.should == [cheques(:prazo)]
  end

  it "verifica se as datas estão no formato date" do
    @cheque = Cheque.new :data_para_deposito => '2009-07-01 00:00:00'
    @cheque.data_do_deposito = '2009-08-02 00:00:00'
    @cheque.data_de_recebimento = '2010-07-21 11:25:32'
    @cheque.data_devolucao = '2009-10-05 12:20:23'
    @cheque.data_abandono = '2009-11-17 09:05:55'
    @cheque.data_para_deposito.should == '01/07/2009'
    @cheque.data_do_deposito.should == '02/08/2009'
    @cheque.data_de_recebimento.should == '21/07/2010'
    @cheque.data_devolucao.should == '05/10/2009'
    @cheque.data_abandono.should == '17/11/2009'
  end

  it "verifica data_br_field" do
    @cheque = Cheque.new
    @cheque.data_do_deposito = '02/08/2009'
    @cheque.data_do_deposito.should == '02/08/2009'
    @cheque.data_de_recebimento = '02/08/2009'
    @cheque.data_de_recebimento.should == '02/08/2009'
  end

  it "testa funcao valor liquido" do
    cheques(:vista).valor_liquido.should == "50.00"
    cheques(:prazo).valor_liquido.should == "50.00"
  end




  it "fazendo pesquisa para relatorio" do
    cheques(:cheque_do_andre_primeira_parcela).destroy
    cheques(:cheque_do_andre_segunda_parcela).destroy
    [
      #Filtro ['À vista',1],['Pré-datados',2], ['Devolvidos', 3],['Cheques Baixados',4]
      # Situacao ['Pendente', Cheque::GERADO], ['Baixado', Cheque::BAIXADO]
      #0
      [{"filtro"=>"","situacao"=>"","periodo" => ""}, []],
      #1
      [{"filtro"=>"1","situacao"=>"1","periodo"=>"recebimento","periodo_min"=>"20/01/2009","periodo_max"=>""}, [cheques(:vista)]],
      #2
      [{"filtro"=>"2","situacao"=>"1","periodo"=>"recebimento","periodo_min"=>"19/02/2009","periodo_max"=>"20/02/2009"}, [cheques(:prazo)]],
      #3
      [{"filtro"=>"1","situacao"=>"1","periodo" => "vencimento","periodo_min"=>"19/01/2009","periodo_max"=>"20/01/2009"}, [cheques(:vista)]],
      #4
      [{"filtro"=>"2","situacao"=>"1","periodo"=>"vencimento","periodo_min"=>"19/02/2009","periodo_max"=>"20/02/2009"}, [cheques(:prazo)]]

    ].each_with_index do |consulta, _|
      Cheque.retorna_cheques_para_relatorio(consulta.first, unidades(:senaivarzeagrande).id).should == consulta.last
    end
    #Efetuando a baixa no cheque
    Cheque.baixar(2009, {'ids' => [cheques(:vista).id], 'data_do_deposito' => Date.today.to_s_br,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
        'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id)

    [
      #Filtro ['À vista',1],['Pré-datados',2], ['Devolvidos', 3],['Cheques Baixados',4]
      # Situacao ['Pendente', Cheque::GERADO], ['Baixado', Cheque::BAIXADO]
      #0
      [{"filtro" => "1", "situacao" => "1", "periodo" => "baixa", "periodo_min"=> Date.today.to_s_br, "periodo_max" => ""}, []],
      #1
      [{"filtro" => "1", "situacao"=>"", "periodo" => "baixa", "periodo_min" => Date.today.to_s_br, "periodo_max" => Date.today.to_s_br}, [cheques(:vista)]],
      #2
      [{"filtro" => "1", "situacao" => "2", "periodo"=>"baixa", "periodo_min" => Date.today.to_s_br, "periodo_max" => ""}, [cheques(:vista)]]

    ].each_with_index do |consulta, _|
      Cheque.retorna_cheques_para_relatorio(consulta.first, unidades(:senaivarzeagrande).id).should == consulta.last
    end

  end


  it "verifica se está fazendo a pesquisa de cheque" do
    cheques(:cheque_do_andre_primeira_parcela).destroy
    cheques(:cheque_do_andre_segunda_parcela).destroy
    [
      #0
      [{"texto" => "Paulo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first, Cheque.last]],
      #1
      [{"texto" => "Jo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first]],
      #2
      [{"texto" => "Ma", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.last]],
      #3
      [{"texto" => "Silva", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first, Cheque.last]],
      #4
      [{"texto" => "", "situacao" => "2", "data_do_deposito_min" => "01/01/2001", "data_do_deposito_max" => "01/01/2002"}, []],
      #5
      [{"texto" => "Joao", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, []],
      #6
      [{"texto" => "Silva", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first, Cheque.last]],
      #7
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, []],
      #8
      [{"texto" => "Paulo", "situacao" => "1"}, [Cheque.first, Cheque.last]],
      #9
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "22/03/2008", "data_do_deposito_max" => "23/03/2008"}, [Cheque.first, Cheque.last]],
      #10
      [{"texto" => "", "situacao" => "2", "data_do_deposito_min" => "22/03/2008", "data_do_deposito_max" => "23/03/2008"}, []],
      #11
      [{"texto" => "010", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first, Cheque.last]],
      #12
      [{"texto" => "010203", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first]],
      #13
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "","pre_datado"=>"true"}, [Cheque.last]],
      #14
      [{"texto" => "", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => "","vista"=>"true"}, [Cheque.first]],
    ].each_with_index do |consulta, _|
      #      puts index
      Cheque.pesquisar_cheques(consulta.first, unidades(:senaivarzeagrande).id).should == consulta.last
    end
    [
      #0
      [{"texto" => "Silva", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, []]
    ].each_with_index do |consulta, _|
      #      puts index
      Cheque.pesquisar_cheques(consulta.first, unidades(:sesivarzeagrande).id).should == consulta.last
    end

    Cheque.baixar(2009, {'ids' => [cheques(:vista).id], 'data_do_deposito' => Date.today.to_s_br,
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
        'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id)

    [
      #0
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first]],
      #1
      [{"texto" => "Jo", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.first]],
      #2
      [{"texto" => "Paulo", "situacao" => "1", "data_do_deposito_min" => "", "data_do_deposito_max" => ""}, [Cheque.last]],
      #3
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => (Date.today - 1).to_s_br, "data_do_deposito_max" => (Date.today + 2).to_s_br}, [Cheque.first]],
      #4
      [{"texto" => "Paulo", "situacao" => "2", "data_do_deposito_min" => Date.today.to_s_br, "data_do_deposito_max" => ""}, [Cheque.first]],
      #5
      [{"texto" => "Jo", "situacao" => "2", "data_do_deposito_min" => "", "data_do_deposito_max" => Date.today.to_s_br}, [Cheque.first]],
      #6
      [{"texto" => "Jo", "situacao" => "2", "data_do_deposito_min" => (Date.today + 2).to_s_br, "data_do_deposito_max" => (Date.today + 3).to_s_br}, []],
      #7
      [{"texto" => "Jo", "situacao" => "2", "data_do_deposito_min" => (Date.today + 6).to_s_br, "data_do_deposito_max" => (Date.today + 3).to_s_br}, []],
      [{}, []]
    ].each_with_index do |consulta, index|
      #            puts index
      Cheque.pesquisar_cheques(consulta.first, unidades(:senaivarzeagrande).id).should == consulta.last
    end
  end

  describe 'testes de baixa' do

    it "não pode deixar baixar um cheque já baixado" do
      parcelas(:primeira_parcela_recebida_cheque_a_vista).situacao = Parcela::CANCELADA
      parcelas(:primeira_parcela_recebida_cheque_a_vista).save!
      @cheque = Cheque.new :parcela => parcelas(:primeira_parcela_recebida_cheque_a_vista), :banco => bancos(:banco_do_brasil),
        :agencia => '0108-5', :conta => '2716801-5', :numero => '010203', :data_para_deposito => '2009-01-20 00:00:00', :nome_do_titular => 'Alvaro Cortes',
        :prazo => Cheque::VISTA
      # Save de criação
      @cheque.save

      @cheque.situacao = Cheque::BAIXADO
      @cheque.data_do_deposito = '20/01/2009'
      @cheque.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      # Save de baixa
      @cheque.save

      @cheque.data_do_deposito = '21/01/2009'
      @cheque.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      # Nova tentativa de save
      @cheque.valid?
      @cheque.errors.on(:base).should_not be_nil
    end

    it "garante proteção dos atributos data_do_deposito e plano_de_conta_id" do
      @cheque = Cheque.new :data_do_deposito => '15/06/2009', :plano_de_conta_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      @cheque.data_do_deposito.should == nil
      @cheque.plano_de_conta_id.should == nil
      @cheque.data_do_deposito = '15/06/2009'
      @cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      @cheque.data_do_deposito.should == '15/06/2009'
      @cheque.plano_de_conta_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    end

    it "verifica se está baixando cheques com tudo certo" do
      cheques(:cheque_do_andre_primeira_parcela).destroy
      cheques(:cheque_do_andre_segunda_parcela).destroy
      Cheque.baixar(2009, {'ids' => [cheques(:vista).id, cheques(:prazo).id],
          'data_do_deposito' => '15/06/2009', 'historico' => 'Nova baixa',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
          'conta_corrente_id' => contas_correntes(:primeira_conta).id},
        unidades(:senaivarzeagrande).id).should == [true, "Cheque baixado com sucesso!"]
      c = Cheque.first
      c.data_do_deposito.should == '15/06/2009'
      c.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      c.situacao.should == Cheque::BAIXADO
      c.historico.should == 'Nova baixa'

      c_dois = Cheque.last
      c_dois.data_do_deposito.should == '15/06/2009'
      c_dois.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      c_dois.situacao.should == Cheque::BAIXADO
      c_dois.historico.should == 'Nova baixa'
    end

    it "verifica se não está baixando cheques, pois foi passado um id errado" do
      Cheque.baixar(2009, {'ids' => [''], 'data_do_deposito' => '15/06/2009', 'historico' => 'Teste',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id).should == [false, "Você não pode baixar os cheques selecionados!"]

      c = Cheque.first
      c.data_do_deposito.should == nil
      c.conta_contabil.should == nil
      c.situacao.should == Cheque::GERADO
      c.historico.should == nil
    end

    it "verifica se não está baixando cheques, pois foi passada um data de deposito inválida" do
      Cheque.baixar(2009, {'ids' => [cheques(:vista).id, cheques(:prazo).id], 'data_do_deposito' => '',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id).should == [false, "* O campo data do depósito deve ser preenchido"]

      c = Cheque.first
      c.data_do_deposito.should == nil
      c.conta_contabil.should == nil
      c.situacao.should == Cheque::GERADO
      c.historico.should == nil

      c_dois = Cheque.last
      c_dois.data_do_deposito.should == nil
      c_dois.conta_contabil.should == nil
      c_dois.situacao.should == Cheque::GERADO
      c_dois.historico.should == nil
    end

    it "verifica se não está baixando cheques, pois foi passada uma conta contabil inválida" do
      Cheque.baixar(2009, {'ids' => [cheques(:vista).id, cheques(:prazo).id], 'data_do_deposito' => '15/06/2009',
          'conta_contabil_id' => '', 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id).should == [false, '* Selecione uma conta contábil válida']

      c = Cheque.first
      c.data_do_deposito.should == nil
      c.conta_contabil.should == nil
      c.situacao.should == Cheque::GERADO
      c.historico.should == nil

      c_dois = Cheque.last
      c_dois.data_do_deposito.should == nil
      c_dois.conta_contabil.should == nil
      c_dois.situacao.should == Cheque::GERADO
      c_dois.historico.should == nil
    end

    it "conseguiu fazer baixa do cheque, testando o lançamento para cheque A VISTA" do
      cheque = cheques(:vista)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      hash_cheques = {'ids' => [cheque.id.to_s], 'data_do_deposito' => Date.today.to_s_br, 'historico' => 'Nova baixa',
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        'conta_corrente_id' => contas_correntes(:primeira_conta).id}
      unidade = unidades(:senaivarzeagrande)
      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 2 do
          Cheque.baixar(2009, hash_cheques, unidade.id.to_s)
        end
      end
      cheque.reload
      cheque.data_do_deposito.should == Date.today.to_s_br
      conta_caixa = ContasCorrente.find_by_unidade_id_and_identificador(cheque.parcela.conta.unidade_id, ContasCorrente::CAIXA).conta_contabil
      movimento = Movimento.last
      movimento.conta.should == cheque.parcela.conta
      movimento.historico.should == hash_cheques["historico"]
      movimento.data_lancamento.should == hash_cheques["data_do_deposito"]
      debito = movimento.itens_movimentos.first
      credito = movimento.itens_movimentos.last
      credito.tipo.should == "C"
      credito.plano_de_conta.should == conta_caixa
      credito.valor.should == cheque.parcela.valor
      credito.centro.should == cheque.parcela.conta.centro

      debito.tipo.should == "D"
      debito.plano_de_conta_id.should == hash_cheques["conta_contabil_id"]
      debito.valor.should == cheque.parcela.valor
      debito.centro.should == cheque.parcela.conta.centro
      debito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      credito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
    end

    it "conseguiu fazer baixa do cheque, testando o lançamento para cheque A PRAZO" do
      cheque = cheques(:prazo)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      hash_cheques = {'ids' => [cheque.id.to_s], 'data_do_deposito' => Date.today.to_s_br, 'historico' => 'Nova baixa',
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
        'conta_corrente_id' => contas_correntes(:primeira_conta).id}
      unidade = unidades(:senaivarzeagrande)
      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 2 do
          Cheque.baixar(2009, hash_cheques, unidade.id.to_s)
        end
      end
      movimento = Movimento.last
      movimento.conta.should == cheque.parcela.conta
      movimento.historico.should == hash_cheques["historico"]
      movimento.data_lancamento.should == hash_cheques["data_do_deposito"]
      debito = movimento.itens_movimentos.first
      credito = movimento.itens_movimentos.last
      credito.tipo.should == "C"
      credito.plano_de_conta.should == cheque.conta_contabil_transitoria
      credito.valor.should == cheque.parcela.valor
      credito.centro.should == cheque.parcela.conta.centro

      debito.tipo.should == "D"
      debito.plano_de_conta_id.should == hash_cheques["conta_contabil_id"]
      debito.valor.should == cheque.parcela.valor
      debito.centro.should == cheque.parcela.conta.centro
      debito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      credito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
    end

    it "verifica se esta retornando exceção quando a entidade da unidade da sessao nao e a mesma da conta selecionada" do
      Cheque.baixar(2009, {'ids' => [cheques(:vista).id, cheques(:prazo).id], 'data_do_deposito' => '15/06/2009',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id, 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id).should == [false, 'Selecione uma conta válida!']
    end

    it "verifica se não baixa com unidade incorreta!" do
      Cheque.baixar(2009, {'ids' => [cheques(:vista).id, cheques(:prazo).id], 'data_do_deposito' => '15/06/2009',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, 'ERRO').should == [false, "Unidade inválida!"]
    end

    it "verifica se não está baixando cheques, quando não há ids!" do
      Cheque.baixar(2009, {'ids' => [],'data_do_deposito' => '15/06/2009',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id).should == [false, '* Selecione pelo menos um cheque para executar a baixa']
    end

    it "teste atributo virtual nome_banco" do
      @cheque = Cheque.new
      @cheque.nome_banco.should == nil
      @cheque.nome_banco = "teste"
      @cheque.nome_banco.should == nil
    end

    it "testa a funcao que converte datetime para date" do
      @cheque = Cheque.new
      @cheque.data_de_recebimento = Time.now
      @cheque.data_de_recebimento.should == Date.today.to_s_br
    end

    it "testando o verbose para situacao" do
      c = Cheque.new :situacao => Cheque::GERADO
      c.situacao_verbose.should == 'Pendente'
      c.situacao = Cheque::BAIXADO
      c.situacao_verbose.should == 'Baixado'
      c.situacao = Cheque::DEVOLVIDO
      c.situacao_verbose.should == 'Devolvido'
      c.situacao = Cheque::ABANDONADO
      c.situacao_verbose.should == 'Abandonado'
    end

    it "verifica se está reapresentando cheques com tudo certo" do
      cheque = cheques(:vista)
      cheque.situacao = Cheque::DEVOLVIDO
      cheque.save!
      
      hash = {'ids' => [cheque.id.to_s], 'data_do_deposito' => '15/06/2009',
        'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,
        'historico' => 'Nova baixa', "alinea" => nil, "conta_corrente_id" => contas_correntes(:primeira_conta).id.to_s,
        "conta_corrente_nome" => "2345-3 - Conta do Senai Várzea Grande"}

      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 2 do
          assert_difference 'OcorrenciaCheque.count', 1 do
            Cheque.baixar(2009, hash, unidades(:senaivarzeagrande).id).should == [true, "Cheque baixado com sucesso!"]
          end
        end
      end
      cheque.reload
      cheque.situacao.should == Cheque::REAPRESENTADO
      cheque.data_do_deposito.should == '15/06/2009'
      cheque.data_devolucao.should == nil
      cheque.data_abandono.should == nil
      movimento = Movimento.last
      movimento.conta.should == cheque.parcela.conta
      movimento.historico.should == hash["historico"]
      movimento.data_lancamento.should == hash["data_do_deposito"]
      credito = movimento.itens_movimentos.first
      debito = movimento.itens_movimentos.last
      credito.valor.should == cheque.parcela.valor
      credito.centro.should == cheque.parcela.conta.centro
      debito.valor.should == cheque.parcela.valor
      debito.centro.should == cheque.parcela.conta.centro
      debito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      credito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      ocorrencia = OcorrenciaCheque.last
      ocorrencia.cheque.should == cheque
      ocorrencia.data_do_evento.should == hash["data_do_deposito"]
      ocorrencia.tipo_da_ocorrencia.should == Cheque::DEVOLUCAO
      ocorrencia.tipo_da_ocorrencia_verbose.should == 'Reapresentação de Cheque'
      ocorrencia.alinea.should == nil
      ocorrencia.historico.should == hash["historico"]
    end

  end

  describe 'Teste Abandono do cheque' do

    it "verifica se estão foi gerada a exceção de historico" do
      cheque = cheques(:prazo)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      cheque.situacao = 3
      cheque.save!
      hash_cheques =  {"nome_conta_contabil_debito"=>conta_debito.nome.to_s,
        "conta_contabil_debito_id"=>conta_debito.id.to_s,
        "ids"=>[cheque.id.to_s],
        "historico"=>"",
        "nome_conta_contabil_credito"=>conta_credito.nome.to_s,
        "conta_contabil_credito_id"=>conta_credito.id.to_s, "data_abandono"=>"30/06/2009", "tipo_abandono"=>"1"}
      unidade = unidades(:senaivarzeagrande)
      retorno = Cheque.abandonar(2009, hash_cheques,unidade.id.to_s)
      retorno.first.should == false
      retorno.last.should =="* O campo histórico deve ser preenchido"
    end

    it "verifica se as exceções foram geradas" do
      cheque = cheques(:prazo)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      cheque.situacao = 3
      cheque.save!
      hash_cheques =  {"nome_conta_contabil_debito"=>"",
        "conta_contabil_debito_id"=>"",
        "ids"=>[],
        "historico"=>"",
        "nome_conta_contabil_credito"=>"",
        "conta_contabil_credito_id"=>"", "data_abandono"=>"", "tipo_abandono"=>""}
      unidade = unidades(:senaivarzeagrande)
      retorno = Cheque.abandonar(2009, hash_cheques,unidade.id.to_s)
      retorno.first.should == false
      retorno.last.should == "* Selecione uma Conta Contábil Débito válida\n* Selecione uma Conta Contábil Crédito válida\n* O campo histórico deve ser preenchido\n* O campo data do abandono deve ser preenchido\n* Selecione pelo menos um cheque para executar o abandono"
    end

    it "verifica se a exceção de unidade foi lancada" do
      cheque = cheques(:prazo)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      cheque.situacao = 3
      cheque.save!
      hash_cheques =  {"nome_conta_contabil_debito"=>conta_debito.nome.to_s,
        "conta_contabil_debito_id"=>conta_debito.id.to_s,
        "ids"=>[cheque.id.to_s],
        "historico"=>"Pagamento Cheque",
        "nome_conta_contabil_credito"=>conta_credito.nome.to_s,
        "conta_contabil_credito_id"=>conta_credito.id.to_s, "data_abandono"=>"30/06/2009", "tipo_abandono"=>"1"}
      unidade = nil
      retorno = Cheque.abandonar(2009, hash_cheques,unidade)
      retorno.first.should == false
      retorno.last.should =="Unidade inválida!"
    end

    it "verifica se a exceção do cheque foi lancada" do
      cheque = cheques(:prazo)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      cheque.situacao = 1
      cheque.save!
      hash_cheques =  {"nome_conta_contabil_debito"=>conta_debito.nome.to_s,
        "conta_contabil_debito_id"=>conta_debito.id.to_s,
        "ids"=>[cheque.id.to_s],
        "historico"=>"Pagamento Cheque",
        "nome_conta_contabil_credito"=>conta_credito.nome.to_s,
        "conta_contabil_credito_id"=>conta_credito.id.to_s, "data_abandono"=>"30/06/2009", "tipo_abandono"=>"1"}
      unidade = unidades(:senaivarzeagrande)
      retorno = Cheque.abandonar(2009, hash_cheques,unidade)
      retorno.first.should == false
      retorno.last.should =="Você selecionou cheques que já foram baixados!"
    end

    it "verifica se o cheque é predatado" do
      cheque = cheques(:prazo)
      cheque.prazo.should == Cheque::PRAZO
      cheque.pre_datado?.should == true
      cheque.prazo = Cheque::VISTA
      cheque.data_para_deposito = "20/01/2009"
      cheque.prazo.should == Cheque::VISTA
      cheque.pre_datado?.should == false
    end

    it "conseguiu fazer abandono do cheque " do
      cheque = cheques(:prazo)
      conta_debito = plano_de_contas(:plano_de_contas_ativo_caixa)
      conta_credito = plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      cheque.situacao = 3
      cheque.save!
      hash_cheques = {"nome_conta_contabil_debito"=>conta_debito.nome.to_s,
        "conta_contabil_debito_id"=>conta_debito.id.to_s,
        "ids"=>[cheque.id.to_s],
        "historico"=>"Pagamento de Cheque",
        "nome_conta_contabil_credito"=>conta_credito.nome.to_s,
        "conta_contabil_credito_id"=>conta_credito.id.to_s, "data_abandono"=>"30/06/2009", "tipo_abandono"=>"1"}
      unidade = unidades(:senaivarzeagrande)
      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 2 do
          Cheque.abandonar(2009, hash_cheques, unidade.id.to_s)
        end
      end
      cheque.reload
      cheque.situacao.should == Cheque::ABANDONADO
      cheque.data_do_deposito.should == nil
      cheque.data_abandono.should == '30/06/2009'
      movimento = Movimento.last
      movimento.conta.should == cheque.parcela.conta
      movimento.historico.should == hash_cheques["historico"]
      movimento.data_lancamento.should == hash_cheques["data_abandono"]
      credito = movimento.itens_movimentos.first
      debito = movimento.itens_movimentos.last
      credito.valor.should == cheque.parcela.valor
      credito.centro.should == centros(:centro_empresa)
      #      credito.centro.should == cheque.parcela.conta.centro
      debito.valor.should == cheque.parcela.valor
      debito.centro.should == centros(:centro_empresa)
      #      debito.centro.should == cheque.parcela.conta.centro
      debito.unidade_organizacional.should == unidade_organizacionais(:unidade_organizacional_empresa)
      #      debito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      credito.unidade_organizacional.should == unidade_organizacionais(:unidade_organizacional_empresa)
      #      credito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
    end
  end

  describe 'Teste devolução do cheque' do

    it "verifica se estão foi gerada a exceção de historico" do
      cheque = cheques(:prazo)
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      cheque.situacao = Cheque::DEVOLVIDO
      cheque.save!
      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "",
        "data_do_evento" => "30/06/2009", "tipo_da_ocorrencia" => 1, "alinea" => 11}
      unidade = unidades(:senaivarzeagrande)
      retorno = Cheque.devolver(2009, hash_cheques, unidade.id.to_s)
      retorno.first.should == false
      retorno.last.should =="* O campo histórico deve ser preenchido"
    end

    it "verifica se as exceções foram geradas" do
      cheque = cheques(:prazo)
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      cheque.situacao = Cheque::BAIXADO
      cheque.data_do_deposito = Date.today
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save!
      hash_cheques = {"nome_conta_contabil_devolucao" => "",
        "conta_contabil_devolucao_id" => "",
        "ids" => [], "historico" => "",
        "data_do_evento" => "", "tipo_da_ocorrencia" => "", "alinea" => ""}
      unidade = unidades(:senaivarzeagrande)
      retorno = Cheque.devolver(2009, hash_cheques, unidade.id.to_s)
      retorno.first.should == false
      retorno.last.should == "* Selecione uma Conta Contábil válida\n* Selecione uma alínea válida\n* O campo histórico deve ser preenchido\n* O campo de data deve ser preenchido\n* Selecione pelo menos um cheque para executar a devolução"
    end

    it "verifica se a exceção de unidade foi lancada" do
      cheque = cheques(:prazo)
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      cheque.situacao = Cheque::BAIXADO
      cheque.data_do_deposito = Date.today
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save!
      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento Cheque",
        "data_do_evento" => "30/06/2009", "tipo_da_ocorrencia" => 1, "alinea" => 11}
      unidade = nil
      retorno = Cheque.devolver(2009, hash_cheques, unidade)
      retorno.first.should == false
      retorno.last.should =="Unidade inválida!"
    end

    it "verifica se a exceção de cheque selecionado foi lancada" do
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      cheque = cheques(:prazo)
      cheque.situacao = Cheque::ABANDONADO
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save!

      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento Cheque",
        "data_do_evento" => "30/06/2009", "tipo_da_ocorrencia" => 1, "alinea" => 11}

      unidade = unidades(:senaivarzeagrande)
      retorno = Cheque.devolver(2009, hash_cheques, unidade)
      retorno.first.should == false
      retorno.last.should == "O cheque selecionado não pode ser devolvido!"
    end

    it "conseguiu fazer devoluçao do cheque " do
      cheque = cheques(:prazo)
      conta_devolucao = plano_de_contas(:plano_de_contas_devolucao)
      cheque.situacao = Cheque::BAIXADO
      cheque.data_do_deposito = Date.today
      cheque.plano_de_conta_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
      cheque.save!
      hash_cheques = {"nome_conta_contabil_devolucao" => conta_devolucao.nome.to_s,
        "conta_contabil_devolucao_id" => conta_devolucao.id.to_s,
        "ids" => [cheque.id.to_s], "historico" => "Pagamento Cheque",
        "data_do_evento" => "30/06/2009", "tipo_da_ocorrencia" => 1, "alinea" => 11}
      unidade = unidades(:senaivarzeagrande)
      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 2 do
          assert_difference 'OcorrenciaCheque.count', 1 do
            Cheque.devolver(2009, hash_cheques, unidade.id.to_s)
          end
        end
      end
      cheque.reload
      cheque.situacao.should == Cheque::DEVOLVIDO
      cheque.data_do_deposito.should == nil
      cheque.data_devolucao.should == '30/06/2009'
      movimento = Movimento.last
      movimento.conta.should == cheque.parcela.conta
      movimento.historico.should == hash_cheques["historico"]
      movimento.data_lancamento.should == hash_cheques["data_do_evento"]
      credito = movimento.itens_movimentos.first
      debito = movimento.itens_movimentos.last
      credito.valor.should == cheque.parcela.valor
      credito.centro.should == cheque.parcela.conta.centro
      debito.valor.should == cheque.parcela.valor
      debito.centro.should == cheque.parcela.conta.centro
      debito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      credito.unidade_organizacional.should == cheque.parcela.conta.unidade_organizacional
      ocorrencia = OcorrenciaCheque.last
      ocorrencia.cheque.should == cheque
      ocorrencia.data_do_evento.should == hash_cheques["data_do_evento"]
      ocorrencia.tipo_da_ocorrencia.should == hash_cheques["tipo_da_ocorrencia"]
      ocorrencia.tipo_da_ocorrencia_verbose.should == 'Baixa de transferência para o DR'
      ocorrencia.alinea.should == hash_cheques["alinea"]
      ocorrencia.historico.should == hash_cheques["historico"]
    end
  end
  describe 'estorno de cheques' do
    it 'gerando baixas' do
      lambda do
        lambda do
          @cheques = [cheques(:cheque_do_andre_primeira_parcela),cheques(:cheque_do_andre_segunda_parcela)]
          @cheques.collect(&:situacao).should == [Cheque::GERADO,Cheque::GERADO]
          gerar_cheques_baixados
          @cheques.collect(&:reload)
          @cheques.collect(&:situacao).should == [Cheque::BAIXADO,Cheque::BAIXADO]
        end.should change(ItensMovimento,:count).by(4)
      end.should change(Movimento,:count).by(2)
    end

    it 'com tudo certo' do
      @cheques = [cheques(:cheque_do_andre_primeira_parcela),cheques(:cheque_do_andre_segunda_parcela)]
      gerar_cheques_baixados
      @cheques.collect(&:reload)
      @cheques.collect(&:situacao).should == [Cheque::BAIXADO,Cheque::BAIXADO]
      lambda do
        lambda do
          lambda do
            Cheque.estornar(2009, {'ids' => [cheques(:cheque_do_andre_primeira_parcela).id,cheques(:cheque_do_andre_segunda_parcela).id]},
              unidades(:senaivarzeagrande).id).should == [true, "Cheque estornado com sucesso!"]
            @cheques.collect(&:reload)
            @cheques.collect(&:situacao).should == [Cheque::GERADO,Cheque::GERADO]
          end.should_not change(Cheque,:count)
        end.should change(ItensMovimento,:count).by(-4)
      end.should change(Movimento,:count).by(-2)
    end

    it 'sem cheques' do
      @cheques = [cheques(:cheque_do_andre_primeira_parcela),cheques(:cheque_do_andre_segunda_parcela)]
      gerar_cheques_baixados
      @cheques.collect(&:reload)
      @cheques.collect(&:situacao).should == [Cheque::BAIXADO,Cheque::BAIXADO]
      lambda do
        lambda do
          lambda do
            Cheque.estornar(2009, {'ids' => []},
              unidades(:senaivarzeagrande).id).should == [false, 'Selecione pelo menos um cheque para estornar!']
          end.should_not change(Cheque,:count)
          @cheques.collect(&:reload)
          @cheques.collect(&:situacao).should == [Cheque::BAIXADO,Cheque::BAIXADO]
        end.should_not change(ItensMovimento,:count)
      end.should_not change(Movimento,:count)
    end

    it 'sem unidades' do
      @cheques = [cheques(:cheque_do_andre_primeira_parcela),cheques(:cheque_do_andre_segunda_parcela)]
      gerar_cheques_baixados
      @cheques.collect(&:reload)
      @cheques.collect(&:situacao).should == [Cheque::BAIXADO,Cheque::BAIXADO]
      lambda do
        lambda do
          lambda do
            Cheque.estornar(2009, {'ids' => [cheques(:cheque_do_andre_primeira_parcela).id,cheques(:cheque_do_andre_segunda_parcela).id]},
              nil).should == [false, 'Unidade inválida!']
            @cheques.collect(&:reload)
            @cheques.collect(&:situacao).should == [Cheque::BAIXADO,Cheque::BAIXADO]
          end.should_not change(Cheque,:count)
        end.should_not change(ItensMovimento,:count)
      end.should_not change(Movimento,:count)
    end

    it 'reapresentados' do
      @cheque = cheques(:cheque_do_andre_primeira_parcela)
      gerar_cheques_baixados
      @cheque.reload
      @cheque.situacao.should == Cheque::BAIXADO
      @cheque.situacao = Cheque::REAPRESENTADO
      @cheque.save false
      lambda do
        lambda do
          lambda do
            Cheque.estornar(2009, {'ids' => [@cheque.id]},
              unidades(:senaivarzeagrande).id).should == [true, "Cheque estornado com sucesso!"]
            @cheque.reload
            @cheque.situacao.should == Cheque::REAPRESENTADO
          end.should_not change(Cheque,:count)
        end.should_not change(ItensMovimento,:count)
      end.should_not change(Movimento,:count)
    end

    def gerar_cheques_baixados
      Cheque.baixar(2009, {'ids' => [cheques(:cheque_do_andre_primeira_parcela).id,cheques(:cheque_do_andre_segunda_parcela).id], 'data_do_deposito' => Date.today.to_s_br,
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'Nova baixa',
          'conta_corrente_id' => contas_correntes(:primeira_conta).id}, unidades(:senaivarzeagrande).id)
    end
  end
end
