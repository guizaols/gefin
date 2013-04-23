require File.dirname(__FILE__) + '/../spec_helper'

describe PagamentoDeConta do
  
  it "test_retornar_a_data_do_dia_quando_a_mesma_for_vazia e parcelas geradas igual a false" do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.primeiro_vencimento.should == Date.today.strftime("%d/%m/%Y")
    @conta_a_pagar.data_lancamento.should == Date.today.strftime("%d/%m/%Y")
    @conta_a_pagar.data_emissao.should == Date.today.strftime("%d/%m/%Y")
    @conta_a_pagar.parcelas_geradas.should == false
  end
  
  it "teste para o metodo alguma_parcela_baixada" do
    Parcela.delete_all
    @conta = pagamento_de_contas(:pagamento_dinheiro)
    @conta.usuario_corrente = usuarios(:quentin)
    @conta.gerar_parcelas(2009)
    @conta.alguma_parcela_baixada?.should == false
    @conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1;parcela.valor_liquido=parcela.valor;parcela.save!}
    @conta.alguma_parcela_baixada?.should == true
  end

  it "teste do metodo gerar_parcelas para ver se ele troca o valor das parcelas quando nenhuma delas foi baixada" do
    Parcela.delete_all
    Rateio.delete_all
    Movimento.delete_all
    ItensMovimento.delete_all
    vencimento = "01/01/2009".to_date
    @conta_a_pagar = pagamento_de_contas(:pagamento_dinheiro)
    @conta_a_pagar.primeiro_vencimento = "01/01/2009".to_date
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    assert_difference 'Parcela.count',3 do
      assert_difference 'Movimento.count',3 do
        @conta_a_pagar.gerar_parcelas(2009)
      end
    end
    @conta_a_pagar.numero_de_parcelas = 8
    @conta_a_pagar.valor_do_documento_em_reais = "800,00"
    @conta_a_pagar.ano_contabil_atual = 2009
    @conta_a_pagar.save
    Parcela.count.should == 8
    Movimento.count.should == 8
    parcelas = Parcela.all
    parcelas.each do |parcela|
      parcela.valor.should == 10000
      parcela.data_vencimento.to_date.should == vencimento
      vencimento = vencimento.to_date + 1.month
    end
    movimentos = Movimento.all
    movimentos.each do |movimento|
      movimento.data_lancamento.should == @conta_a_pagar.data_emissao 
      movimento.itens_movimentos.length.should == 2
      movimento.itens_movimentos.first.plano_de_conta.should == @conta_a_pagar.conta_contabil_despesa
      movimento.itens_movimentos.first.plano_de_conta.should == @conta_a_pagar.conta_contabil_pessoa
    end
  end
  
  
  it "teste para valor do campo quando passado uma string" do
    @conta_a_pagar = PagamentoDeConta.new :valor_do_documento_em_reais =>"0,00",:data_lancamento => "31/03/2009",:unidade=>unidades(:senaivarzeagrande)
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.valor_do_documento.should == 0
    
    @conta_a_pagar = PagamentoDeConta.new :valor_do_documento_em_reais =>"100,01",:data_lancamento => "31/03/2009",:unidade=>unidades(:senaivarzeagrande)
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.valor_do_documento.should == 10001

    @conta_a_pagar.valor_do_documento_em_reais = '0,00'
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.valor_do_documento.should == 0
  end
  
  it "não permite salvar numeros de controle para mesma unidade" do
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.save
    @nova_conta = pagamento_de_contas(:pagamento_dinheiro)
    @nova_conta.numero_de_controle = @conta.numero_de_controle
    @nova_conta.should_not be_valid
    @nova_conta.errors.on(:numero_de_controle).should_not be_nil
  end
  
  it "quando excluir uma conta deve excluir suas parcelas" do
    Movimento.delete_all
    Parcela.delete_all
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.usuario_corrente = Usuario.first
    @conta.provisao = 1
    @conta.gerar_parcelas(2009)
    movimentos = Movimento.count
    assert_difference 'PagamentoDeConta.count', -1 do
      assert_difference 'Parcela.count', -3 do
        assert_difference 'Movimento.count', -3 do
          @conta.destroy
        end
      end
    end
  end
  
  it "não excluir uma conta que teve parcelas baixadas" do
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.usuario_corrente = Usuario.first
    @conta.gerar_parcelas(2009)
    @conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1}    
    assert_no_difference 'PagamentoDeConta.count' do
      assert_no_difference 'Parcela.count' do
        @conta.destroy
      end
    end
  end
  
  it "Ao atualizar uma conta a pagar gerar as novas parcelas" do
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.usuario_corrente = Usuario.first
    @conta.save!
    @conta.gerar_parcelas(2009)
    @conta.parcelas.length.should == 3
    @nova_conta = PagamentoDeConta.last
    @nova_conta.pessoa = pessoas(:inovare)
    @nova_conta.usuario_corrente = Usuario.last
    @nova_conta.numero_de_parcelas = 1
    @nova_conta.ano_contabil_atual = 2009
    @nova_conta.save!
  end
  
  it "Verifica as mensagens geradas no follow-up" do
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.usuario_corrente = Usuario.first
    @conta.save!
    @conta.gerar_parcelas(2009)
    @conta.parcelas.length.should == 3
    @conta.historico_operacoes.last.descricao.should == "Geradas 3 parcelas"
    @conta.numero_de_parcelas = 4
    @conta.ano_contabil_atual = 2009
    @conta.save!
    @conta.historico_operacoes.last.descricao.should == "Geradas 4 parcelas"
  end

  it "verifica se todas as parcelas estão baixadas" do
    Parcela.delete_all
    @conta = pagamento_de_contas(:pagamento_dinheiro)
    @conta.usuario_corrente = usuarios(:quentin)
    @conta.todas_baixadas?.should == false
    @conta.gerar_parcelas(2009)
    @conta.todas_baixadas?.should == false
    @conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1}
    @conta.todas_baixadas?.should == true
  end
  
  it "teste de campos obrigatorios" do
    @conta_a_pagar = PagamentoDeConta.new 
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:data_lancamento).should be_nil
    @conta_a_pagar.errors.on(:tipo_de_documento).should_not be_nil
    @conta_a_pagar.errors.on(:provisao).should_not be_nil
    @conta_a_pagar.errors.on(:rateio).should_not be_nil
    @conta_a_pagar.errors.on(:valor_do_documento).should_not be_nil
    @conta_a_pagar.errors.on(:valor_do_documento_em_reais).should_not be_nil
    @conta_a_pagar.errors.on(:historico).should_not be_nil
    @conta_a_pagar.errors.on(:numero_de_parcelas).should_not be_nil
    @conta_a_pagar.errors.on(:pessoa).should_not be_nil
    @conta_a_pagar.errors.on(:centro).should_not be_nil
    @conta_a_pagar.errors.on(:conta_contabil_despesa).should_not be_nil
    @conta_a_pagar.errors.on(:unidade_organizacional).should_not be_nil
    @conta_a_pagar.errors.on(:ano).should_not be_nil
    @conta_a_pagar.errors.on(:primeiro_vencimento).should be_nil
    @conta_a_pagar.errors.on(:unidade).should_not be_nil
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.tipo_de_documento="Paulo"
    @conta_a_pagar.rateio=2
    @conta_a_pagar.provisao=2
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:tipo_de_documento).should_not be_nil
    @conta_a_pagar.errors.on(:rateio).should_not be_nil
    @conta_a_pagar.errors.on(:provisao).should_not be_nil
    @conta_a_pagar = PagamentoDeConta.new 
    @conta_a_pagar.tipo_de_documento ="NTS"
    @conta_a_pagar.rateio=1
    @conta_a_pagar.provisao=1
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:tipo_de_documento).should be_nil
    @conta_a_pagar.errors.on(:rateio).should be_nil
    @conta_a_pagar.errors.on(:provisao).should be_nil
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.provisao=1
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:conta_contabil_pessoa).should_not be_nil
  end
  
  it "teste de relacionamentos" do
    pagamento_de_contas(:pagamento_cheque).centro.should == centros(:centro_forum_economico)
    pagamento_de_contas(:pagamento_cheque).pessoa.should == pessoas(:inovare)
    pagamento_de_contas(:pagamento_cheque).movimentos.should == [movimentos(:lancamento_com_a_conta_pagamento_cheque)]
    pagamento_de_contas(:pagamento_cheque_outra_unidade).parcelas.should == parcelas(:primeira_parcela, :segunda_parcela,:terceira_parcela)
    pagamento_de_contas(:pagamento_cheque).conta_contabil_despesa.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    pagamento_de_contas(:pagamento_cheque).conta_contabil_pessoa.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    pagamento_de_contas(:pagamento_cheque).unidade_organizacional.should == unidade_organizacionais(:senai_unidade_organizacional)
    pagamento_de_contas(:pagamento_cheque).unidade.should == unidades(:senaivarzeagrande)
    pagamento_de_contas(:pagamento_cheque).historico_operacoes.should == [historico_operacoes(:historico_operacao_pagamento_cheque)]
  end
  
  it "teste do campo virtual nome_centro" do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.nome_centro.should == nil
    @contas_a_pagar = PagamentoDeConta.new :centro => centros(:centro_forum_social)
    @contas_a_pagar.nome_centro.should ==  "310010405 - Forum Serviço Social"
  end
  
  it "teste do campo virtual  nome_pessoa" do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.nome_pessoa.should == nil
    @contas_a_pagar = PagamentoDeConta.new :pessoa =>pessoas(:felipe)
    @contas_a_pagar.nome_pessoa.should == "Felipe Giotto"
  end
  
  it "teste do campo virtual conta_contabil_despesa"  do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.nome_conta_contabil_despesa.should == nil
    @conta_a_pagar = PagamentoDeConta.new :conta_contabil_despesa=>plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @conta_a_pagar.nome_conta_contabil_despesa.should == '41010101008 - Contribuicoes Regul. oriundas do SENAI'
  end
  
  it "arranca conta contabil quando a provisao é zero" do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.provisao = 0
    @conta_a_pagar.conta_contabil_pessoa_id = 1
    @conta_a_pagar.save
    @conta_a_pagar.conta_contabil_pessoa_id = nil
  end
  
  it "testa a montagem do metodo monta_numero_de_controle" do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.should be_valid
    @conta_a_pagar.numero_de_controle.should == "SENAI-VG - DP4/20053200"
    @conta_a_pagar.numero_de_parcelas = 3
    @conta_a_pagar.save
    @conta_a_pagar.numero_de_controle.should == "SENAI-VG - DP4/20053200"
    #Não há mais a funcionalidade de gerar novamente quando trocar
    # a nota fiscal, pois agora não gera mais com base na nota.
    #@conta_a_pagar.numero_nota_fiscal = 3005
    #@conta_a_pagar.ano = "2009"
    #@conta_a_pagar.should be_valid
    #@conta_a_pagar.numero_de_controle.should == "SENAI-VG-DP#{DateTime.now.strftime("%m")}/3005"
  end
  
  it "teste de campo virtual" do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.sigla_unidade.should == nil
    @conta_a_pagar.valor_do_documento_em_reais.should == nil
  end
  
  it "teste do campos virtual nome_unidade_organizacional" do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.nome_unidade_organizacional.should == nil
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @conta_a_pagar.nome_unidade_organizacional.should == "1303010803 - SESI COLIDER"
  end
  
  it "teste de campo virtual usuario corrente" do
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.usuario_corrente.should == nil
  end
  
  it "testa criaçao de um historico_operacao quando cria-se uma nova instancia de pagamento_de_conta" do
    registro = pagamento_de_contas(:pagamento_cheque)
    conta_a_pagar = PagamentoDeConta.new registro.attributes
    conta_a_pagar.ano = 2009
    conta_a_pagar.unidade = unidades(:senaivarzeagrande)
    conta_a_pagar.conta_contabil_pessoa = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    conta_a_pagar.usuario_corrente = usuarios(:quentin)
    conta_a_pagar.numero_de_controle = nil
  
    assert_difference 'PagamentoDeConta.count',  1 do
      assert_difference 'HistoricoOperacao.count', 1 do
        conta_a_pagar.save!
  
        historico_operacao = conta_a_pagar.historico_operacoes.last
        historico_operacao.descricao.should == "Conta a pagar criada"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = conta_a_pagar
      end
    end
  end
  
  it "teste do metodo gerar_parcelas valor : 100,01" do
    Movimento.delete_all
    Parcela.delete_all
    ItensMovimento.delete_all
  
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.conta_contabil_despesa = plano_de_contas(:plano_de_contas_ativo_despesas)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
  
    assert_difference 'Parcela.count', 3 do
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta_a_pagar.gerar_parcelas(2009)
        historico_operacao = @conta_a_pagar.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 3 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta_a_pagar
      end
    end
  
    parcelas = Parcela.all
    @primeira_parcela = parcelas[0]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "31/03/2009"
    @primeira_parcela.numero.should == 1.to_s
    @primeira_parcela.valor.should == 3334
    @segunda_parcela = parcelas[1]
    @segunda_parcela.data_vencimento.to_date.to_s_br.should == "30/04/2009"
    @segunda_parcela.valor.should == 3334
    @segunda_parcela.numero.should == 2.to_s
    @terceira_parcela = parcelas[2]
    @terceira_parcela.data_vencimento.to_date.to_s_br.should == "30/05/2009"
    @terceira_parcela.numero.should == 3.to_s
    @terceira_parcela.valor.should == 3333
  
    movimentos= Movimento.all
    movimentos.length.should == 3
    ItensMovimento.count.should == 6
  
    @primeiro_movimento = movimentos[0]
    @primeiro_movimento.provisao.should == 1
    @primeiro_movimento.pessoa.should == @conta_a_pagar.pessoa
    @primeiro_movimento.unidade.should == @conta_a_pagar.unidade
    @primeiro_movimento.tipo_documento.should == @conta_a_pagar.tipo_de_documento
    @primeiro_movimento.historico.should == @conta_a_pagar.historico
    @primeiro_movimento.itens_movimentos.first.valor.should == 3334
    @primeiro_movimento.itens_movimentos.first.tipo.should == "D"
    @primeiro_movimento.itens_movimentos.first.plano_de_conta == plano_de_contas(:plano_de_contas_ativo_despesas)
    @primeiro_movimento.itens_movimentos.last.tipo.should == "C"
    @primeiro_movimento.itens_movimentos.last.valor.should == 3334
    @primeiro_movimento.itens_movimentos.last.plano_de_conta == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
  
    @segundo_movimento = movimentos[1]
    @segundo_movimento.tipo_documento.should == @conta_a_pagar.tipo_de_documento
    @segundo_movimento.historico.should == @conta_a_pagar.historico
    @segundo_movimento.provisao.should == 1
    @segundo_movimento.pessoa.should == @conta_a_pagar.pessoa
    @segundo_movimento.unidade.should == @conta_a_pagar.unidade
    @segundo_movimento.itens_movimentos.first.valor.should == 3334
    @segundo_movimento.itens_movimentos.first.tipo.should == "D"
    @segundo_movimento.itens_movimentos.first.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_despesas)
    @segundo_movimento.itens_movimentos.last.tipo.should == "C"
    @segundo_movimento.itens_movimentos.last.valor.should == 3334
    @segundo_movimento.itens_movimentos.last.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
  end
  
  it "teste do metodo gerar_parcelas valor : 60" do
    Parcela.delete_all
    Rateio.delete_all
    @conta_a_pagar = pagamento_de_contas(:pagamento_dinheiro)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.save!
    assert_difference 'Parcela.count',3 do
      @conta_a_pagar.gerar_parcelas(2009)
    end
    
    parcelas = Parcela.all
    @primeira_parcela = parcelas[0]
    @primeira_parcela.data_vencimento.should == "30/11/2009"
    @primeira_parcela.numero.should == 1.to_s
    @primeira_parcela.rateios.length.should ==1
    @rateio=@primeira_parcela.rateios.first
    @rateio.valor.should == @primeira_parcela.valor
    @rateio.parcela.should == @primeira_parcela
    @rateio.unidade_organizacional.should == @primeira_parcela.conta.unidade_organizacional
    @rateio.centro.should == @primeira_parcela.conta.centro
    @segunda_parcela = parcelas[1]
    @segunda_parcela.data_vencimento.should == "30/12/2009"
    @segunda_parcela.numero.should == 2.to_s
    @segunda_parcela.rateios.length.should == 1
    @segundo_rateio = @segunda_parcela.rateios.first
    @segundo_rateio.valor.should == @segunda_parcela.valor
    @terceira_parcela = parcelas[2]
    @terceira_parcela.data_vencimento.should == "30/01/2010"
    @terceira_parcela.numero.should == 3.to_s
    @conta_a_pagar.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1;parcela.valor_liquido=parcela.valor;parcela.save!}
    @conta_a_pagar.numero_de_parcelas = 8
    @conta_a_pagar.valor_do_documento_em_reais = "99,00"
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:base).should == ["O campo número de parcelas não pode ser alterado após uma parcela ter sido baixada.", "O campo valor do documento não pode ser alterado após uma parcela ter sido baixada."]
  end
  
  it "teste de validação para insercao do tipo de conta,parcelas e valor do documento" do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.conta_contabil_pessoa_id =670295086
    @conta_a_pagar.conta_contabil_despesa_id =670295086
    @conta_a_pagar.conta_contabil_pessoa.tipo_da_conta =0
    @conta_a_pagar.valor_do_documento = -22
    @conta_a_pagar.numero_de_parcelas = -55
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:base).should == ["Conta Contábil do Fornecedor inválida, está conta já está parametrizada", "Conta Contábil do Fornecedor inválida, selecione uma conta sintética", "Conta Contábil de Despesa inválida, selecione uma conta sintética"]
    @conta_a_pagar.errors.on(:valor_do_documento).should ==  "deve ser maior do que zero."
    @conta_a_pagar.errors.on(:numero_de_parcelas).should ==  "deve ser maior do que zero."
  end
  
  it 'deve gravar conta parametrizada automaticamene' do
    c = PagamentoDeConta.new :ano => 2009, :unidade_id => unidades(:senaivarzeagrande).id
    c.conta_contabil_pessoa.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)

    ParametroContaValor.delete_all

    c = PagamentoDeConta.new :ano => 2009, :unidade_id => unidades(:senaivarzeagrande).id
    c.conta_contabil_pessoa.should == nil
  end

  it "teste de salvar valor" do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.tipo_de_documento = 'CTR'
    @conta_a_pagar.valor_do_documento_em_reais = "100,01"
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.should be_valid
    @conta_a_pagar.valor_do_documento.should == 10001
    @conta_a_pagar.numero_de_controle = "teste"
    @conta_a_pagar.save
    @conta_a_pagar.valor_do_documento_em_reais.should == "100,01"
  end
  
  it "test_proteger_unidade" do
    @conta_a_pagar = PagamentoDeConta.new :unidade_id => "8000"
    @conta_a_pagar.unidade_id.should == nil
    @conta_a_pagar.unidade_id = unidades(:senaivarzeagrande).id
    @conta_a_pagar.unidade_id.should == unidades(:senaivarzeagrande).id
  end
  
  it "teste proteger ano" do
    @conta_a_pagar = PagamentoDeConta.new :ano => "2009"
    @conta_a_pagar.ano.should == nil
    @conta_a_pagar.ano = 2009
    @conta_a_pagar.ano.should == 2009
  end
  
  it "testa o método conta_contabil_pessoa_id_parametrizada" do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.conta_contabil_pessoa_id_parametrizada.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    @conta_a_pagar.ano = "2008"
    @conta_a_pagar.conta_contabil_pessoa_id_parametrizada.should == nil

    c = PagamentoDeConta.new :ano => 2009, :unidade_id => unidades(:senaivarzeagrande).id
    c.conta_contabil_pessoa_id_parametrizada.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    c.conta_contabil_pessoa_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
  end

  it "testa se insere outra conta em um campo que a conta encontra-se parametrizada" do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.conta_contabil_pessoa = plano_de_contas(:plano_de_contas_ativo_despesas)
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.conta_contabil_pessoa_id_parametrizada
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:base).should == "Conta Contábil do Fornecedor inválida, está conta já está parametrizada"
    @conta_a_pagar.conta_contabil_pessoa = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @conta_a_pagar.should be_valid
    @conta_a_pagar.errors.on(:base).should == nil
  end
  
  it "testa se nao grava com anos diferentes" do
    id = pagamento_de_contas(:pagamento_cheque).id
    @conta_a_pagar = PagamentoDeConta.find id
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2008"
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2008"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar.ano = "2008"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar.ano = "2007"
    @conta_a_pagar.unidade_organizacional.ano = "2008"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.nome_unidade_organizacional = ''
    @conta_a_pagar.nome_centro = ''
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar = PagamentoDeConta.find id
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.nome_unidade_organizacional = ''
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar = PagamentoDeConta.find id
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.nome_centro = ''
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar = PagamentoDeConta.find id
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.unidade = unidades(:sesivarzeagrande)
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar = PagamentoDeConta.find id
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.unidade.entidade = entidades(:sesi)
    @conta_a_pagar.should_not be_valid

    @conta_a_pagar = PagamentoDeConta.find id
    @conta_a_pagar.ano = "2009"
    @conta_a_pagar.unidade_organizacional.ano = "2009"
    @conta_a_pagar.centro.ano = "2009"
    @conta_a_pagar.should be_valid
  end
  
  it "testa se limpa o campo com id nos campos de auto_complete" do
    PagamentoDeConta.delete_all
    @conta_a_pagar = PagamentoDeConta.new
    @conta_a_pagar.tipo_de_documento = 'CPMF'
    @conta_a_pagar.provisao = 1
    @conta_a_pagar.rateio = 1
    @conta_a_pagar.pessoa = pessoas(:inovare)
    @conta_a_pagar.conta_contabil_pessoa = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @conta_a_pagar.valor_do_documento = 10001
    @conta_a_pagar.numero_de_parcelas = 3
    @conta_a_pagar.numero_nota_fiscal = 1
    @conta_a_pagar.historico = "Pagamento Cheque"
    @conta_a_pagar.conta_contabil_despesa = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @conta_a_pagar.numero_de_controle = "SENAI-VG - DP4/20053200"
    @conta_a_pagar.parcelas_geradas =true
    @conta_a_pagar.centro = centros(:centro_forum_economico)
    @conta_a_pagar.ano = 2009
    @conta_a_pagar.unidade = unidades(:senaivarzeagrande)
    @conta_a_pagar.usuario_corrente = usuarios(:quentin)
    @conta_a_pagar.save!
    
    conta_a_pagar = PagamentoDeConta.last
    conta_a_pagar.nome_pessoa = ''
    conta_a_pagar.nome_unidade_organizacional = ''
    conta_a_pagar.nome_centro = ''
    conta_a_pagar.nome_conta_contabil_despesa = ''
    conta_a_pagar.should_not be_valid
    conta_a_pagar.errors.on(:pessoa).should_not be_nil
    conta_a_pagar.errors.on(:unidade_organizacional).should_not be_nil
    conta_a_pagar.errors.on(:centro).should_not be_nil
    conta_a_pagar.errors.on(:conta_contabil_despesa).should_not be_nil
  end

  describe 'deve pesquiar registros' do

    def valida_resultados_de_busca_para(fixture_unidade, parametros, expected)
      PagamentoDeConta.pesquisa_simples(unidades(fixture_unidade).id, parametros).collect(&:numero_de_controle).should == expected.collect(&:numero_de_controle)
    end

    it 'deve retornar todas as contas de uma unidade' do
      valida_resultados_de_busca_para :senaivarzeagrande, {}, PagamentoDeConta.find_all_by_unidade_id(unidades(:senaivarzeagrande).id, :order => 'primeiro_vencimento')
    end

    it 'deve retornar as contas do felipe' do
      contas_do_felipe = PagamentoDeConta.all(:conditions => ["unidade_id = ? AND pessoa_id = ?", unidades(:senaivarzeagrande).id, pessoas(:felipe).id], :order => 'primeiro_vencimento')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'felipe'}, contas_do_felipe
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => '031.464'}, contas_do_felipe
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'john nobody'}, []
    end

    it 'deve retornar ordenando por situacao' do
      contas_do_felipe = PagamentoDeConta.all(:conditions => ["unidade_id = ? AND pessoa_id = ?", unidades(:senaivarzeagrande).id, pessoas(:felipe).id], :order => 'primeiro_vencimento')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'felipe', 'ordem' => 'situacao'}, contas_do_felipe
    end

    it 'deve ordenar as contas' do
      contas = PagamentoDeConta.all(:conditions => ["unidade_id = ?", unidades(:senaivarzeagrande).id], :include => :pessoa, :order => 'primeiro_vencimento')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => ''}, contas

      p = pagamento_de_contas(:pagamento_cheque)
      p.valor_do_documento = 99999999
      p.usuario_corrente = Usuario.first
      p.ano_contabil_atual = 2009
      p.save false
      
      contas = PagamentoDeConta.all(:conditions => ["unidade_id = ?", unidades(:senaivarzeagrande).id], :include => :pessoa, :order => 'valor_do_documento')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => '', 'ordem' => 'valor_do_documento'}, contas
    end

    it 'deve retornar as contas de uma PJ' do
      p = pagamento_de_contas(:pagamento_cheque)
      p.pessoa = pessoas(:inovare)
      p.save false

      contas_da_inovare = PagamentoDeConta.all(:conditions => ["unidade_id = ? AND pessoa_id = ?", unidades(:senaivarzeagrande).id, pessoas(:inovare).id], :order => 'primeiro_vencimento')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'ftg'}, contas_da_inovare
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => '916.988'}, contas_da_inovare
    end

    it 'deve retornar por numero de controle e separar por unidade' do
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => '20093299'}, []
      valida_resultados_de_busca_para :sesivarzeagrande, {'texto' => '20093299'}, [pagamento_de_contas(:pagamento_cheque_outra_unidade)]
    end
  end

  it "testa se valida a data de lancamento" do
    unidades(:senaivarzeagrande).lancamentoscontaspagar = 5
    unidades(:senaivarzeagrande).save
    pagamento_de_contas(:pagamento_cheque).reload
    pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
    pagamento_de_conta.esta_dentro_da_faixa_de_dias_permitido?.should == false
    unidades(:senaivarzeagrande).lancamentoscontaspagar = 5000
    unidades(:senaivarzeagrande).save
    pagamento_de_contas(:pagamento_cheque).reload
    pagamento_de_conta = pagamento_de_contas(:pagamento_cheque)
    pagamento_de_conta.esta_dentro_da_faixa_de_dias_permitido?.should == true
  end

  it 'deve validar unidade organizacional e centro' do
    @conta_a_pagar = pagamento_de_contas(:pagamento_cheque)
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @conta_a_pagar.centro = centros(:centro_forum_social)
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:centro).sort.should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."].sort

    @conta_a_pagar.reload
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional_nova)
    @conta_a_pagar.centro = centros(:centro_forum_economico)
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:centro).should == "pertence a outra Unidade Organizacional."

    @conta_a_pagar.reload
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @conta_a_pagar.centro = centros(:centro_forum_economico)
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:centro).should == "pertence a outra Unidade Organizacional."

    @conta_a_pagar.reload
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @conta_a_pagar.centro = centros(:centro_forum_financeiro)
    @conta_a_pagar.should_not be_valid
    @conta_a_pagar.errors.on(:centro).should == "pertence a outra Unidade Organizacional."

    @conta_a_pagar.reload
    @conta_a_pagar.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @conta_a_pagar.centro = centros(:centro_forum_economico)
    @conta_a_pagar.should be_valid
  end

  it 'deve retornar situacao' do
    pagamento_de_contas(:pagamento_cheque).situacao_parcelas.should == 'Em atraso'
    pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano).situacao_parcelas.should == 'Em atraso'
    pagamento_de_contas(:pagamento_dinheiro).situacao_parcelas.should == 'Pendente'
    pagamento_de_contas(:pagamento_dinheiro_outra_unidade_outro_ano).situacao_parcelas.should == 'Pendente'
    pagamento_de_contas(:pagamento_banco_outra_unidade).situacao_parcelas.should == 'Quitada'
    pagamento_de_contas(:pagamento_cheque_outra_unidade).situacao_parcelas.should == 'Em atraso'

    @pagamento = pagamento_de_contas(:pagamento_banco_outra_unidade)
    @pagamento.parcelas.each do |p|
      p.data_da_baixa = Date.today
      p.save false
    end
    @pagamento.reload
    @pagamento.situacao_parcelas.should == 'Quitada'
    
    # A partir daqui

    @pagamento_um = pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano)
    @pagamento_um.parcelas.each do |p|
      p.data_vencimento = Date.today - 10
      p.save false
    end
    @pagamento_um.reload
    @pagamento_um.situacao_parcelas.should == 'Em atraso'

    @pagamento_tres = pagamento_de_contas(:pagamento_dinheiro_outra_unidade_mesmo_ano)
    @pagamento_tres.parcelas.each do |p|
      p.data_vencimento = Date.today + 10
      p.save false
    end
    @pagamento_tres.reload
    @pagamento_tres.situacao_parcelas.should == 'Pendente'
  end
  
  it 'não permite atualizar os campos rateio,numero_de_parcelas,valor' do
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.usuario_corrente = Usuario.first
    @conta.save!
    @conta.gerar_parcelas(2009)
    @conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1}    
    @conta.numero_de_parcelas = 2
    @conta.should_not be_valid
    @conta.errors.on(:numero_de_parcelas).should_not be_nil
    @conta.rateio = 0
    @conta.should_not be_valid
    @conta.errors.on(:rateio).should_not be_nil
    @conta.valor_do_documento = 2
    @conta.should_not be_valid
    @conta.errors.on(:valor_do_documento).should_not be_nil
    @conta.provisao = 0
    @conta.should_not be_valid
    @conta.errors.on(:provisao).should_not be_nil
  end

  it "Teste da validação se está inserindo um fornecedor no pagamento" do
    @conta = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
      :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
      :numero_nota_fiscal => "54321", :pessoa => pessoas(:rafael),
      :provisao => 1, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
      :valor_do_documento => 1000, :numero_de_parcelas => 1, :rateio => 1,
      :historico => "Teste", :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :ano => 2009
    @conta.save
    @conta.should_not be_valid
    @conta.errors.on(:pessoa).should == "deve conter uma pessoa do tipo fornecedor"
    @conta.pessoa = pessoas(:inovare)
    @conta.save!
    @conta.should be_valid
    @conta.errors.on(:pessoa).should_not == "deve conter uma pessoa do tipo fornecedor"
  end

  # Agora pode alterar provisionado com parcelas geradas
  it "Teste da validação de não ser possível alterar a provisão do contrato depois de gerar as parcelas quando TEM PROVISÃO" do
    @conta = pagamento_de_contas(:pagamento_cheque)
    @conta.provisao.should == PagamentoDeConta::SIM
    @conta.usuario_corrente = usuarios(:quentin)
    @conta.gerar_parcelas(2009)
    @conta.provisao = PagamentoDeConta::NAO
    @conta.save
    # @conta.errors.on(:base).should == "Não é possível alterar a provisão deste contrato. Suas parcelas já foram geradas."
    @conta.errors.on(:base).should == nil
  end

  it "Deixa alterar provisão do contrato mesmo com parcelas geradas, situação de provisionado para não provisionado" do
    @conta = pagamento_de_contas(:pagamento_dinheiro)
    @conta.parcelas.count.should == 0
    @conta.numero_de_parcelas.should == 3
    @conta.provisao.should == PagamentoDeConta::SIM
    @conta.usuario_corrente = usuarios(:quentin)
    @conta.ano_contabil_atual = 2009
    assert_difference 'Movimento.count', 3 do
      @conta.gerar_parcelas(2009)
    end
    @conta.reload
    @conta.provisao = PagamentoDeConta::NAO
    @conta.ano_contabil_atual = 2009
    assert_difference 'Movimento.count', -3 do
      @conta.save
    end    
    @conta.errors.on(:base).should == nil
  end

  it "Deixa alterar provisão do contrato mesmo com parcelas geradas, situação de não provisionado para provisionado" do
    @conta = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
      :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
      :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
      :provisao => PagamentoDeConta::NAO, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
      :valor_do_documento => 1000, :numero_de_parcelas => 3, :rateio => 1,
      :historico => "Teste", :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :ano => 2009
    @conta.save
    @conta.reload

    @conta.parcelas.count.should == 0
    @conta.numero_de_parcelas.should == 3
    @conta.provisao.should == PagamentoDeConta::NAO
    @conta.usuario_corrente = usuarios(:quentin)
    @conta.ano_contabil_atual = 2009
    assert_no_difference 'Movimento.count' do
      @conta.gerar_parcelas(2009)
    end
    ids_antigos = []
    @conta.parcelas.each do |parcela_antes|
      ids_antigos << parcela_antes.id
    end
    @conta.reload

    @conta.conta_contabil_pessoa = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @conta.ano_contabil_atual = 2009
    @conta.provisao = PagamentoDeConta::SIM
    @conta.save
    @conta.parcelas.each do |parcela_depois|
      ids_antigos.include?(parcela_depois.id).should == false
    end
    @conta.errors.on(:base).should == nil
  end


  #"O cliente deste contrato está com os seguintes contratos vigentes neste mês:\n\n\nUNIDADE                          Nº CONTROLE\n1º VENCIMENTO  VALOR   SITUAÇÃO  EMISSÃO\n\nSesi Clube Varzea Gr    2005320011                     \n30/11/2009\t     120,00   Em atraso   31/10/2009\n\nSENAI - Varzea Grand     2005320011                     \n30/11/2009\t     120,00   Pendente    31/10/2009\n"],
  #"O cliente deste contrato está com os seguintes contratos vigentes neste mês:\n\n\nUNIDADE                          Nº CONTROLE\n1º VENCIMENTO  VALOR   SITUAÇÃO  EMISSÃO\n\nSesi Clube Varzea Gr    2005320011                     \n30/11/2009\t     120,00   Em atraso   31/10/2009\n"]

  # Agora pode alterar provisionado com parcelas geradas
  it "Teste da validação de não ser possível alterar a provisão do contrato depois de gerar as parcelas quando NÃO TEM PROVISÃO" do
    @conta = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
      :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
      :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
      :provisao => PagamentoDeConta::NAO, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
      :valor_do_documento => 1000, :numero_de_parcelas => 1, :rateio => 1,
      :historico => "Teste", :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :ano => 2009
    @conta.save!
    @conta.verifica_contratos('12/11/2009', @conta.pessoa).should == ["O cliente deste contrato está com os seguintes contratos vigentes neste mês:\n\n\nUNIDADE                          Nº CONTROLE\n1º VENCIMENTO  VALOR   SITUAÇÃO  EMISSÃO\n\nSesi Clube Varzea Gr    2005320011                     \n30/11/2009\t     120,00   Em atraso   31/10/2009\n"]
    @conta.gerar_parcelas(2009)
    @conta.provisao = PagamentoDeConta::SIM
    @conta.ano_contabil_atual = 2009
    @conta.save
    # @conta.errors.on(:base).should == "Não é possível alterar a provisão deste contrato. Suas parcelas já foram geradas."
    @conta.errors.on(:base).should == nil
  end

  # Agora pode alterar provisionado com parcelas geradas
  it "Teste da validação de não ser possível alterar a provisão do contrato depois de gerar as parcelas, porem antes PODE" do
    @conta = pagamento_de_contas(:pagamento_dinheiro)
    @conta.provisao.should == PagamentoDeConta::SIM
    @conta.usuario_corrente = usuarios(:quentin)
    @conta.provisao = PagamentoDeConta::NAO
    @conta.save!
    @conta.provisao.should == PagamentoDeConta::NAO
    @conta.provisao = PagamentoDeConta::SIM
    @conta.save!
    @conta.provisao.should == PagamentoDeConta::SIM
    @conta.provisao = PagamentoDeConta::NAO
    @conta.gerar_parcelas(2009)
    @conta.save
    # @conta.errors.on(:base).should == "Não é possível alterar a provisão deste contrato. Suas parcelas já foram geradas."
    @conta.errors.on(:base).should == nil
  end

  describe 'deve alterar o valor das parcelas' do

    it "conseguiu alterar valor das parcelas conta SEM rateio" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>"30/11/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"100,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      conta.reload

      # ATUALIZOU OS DADOS
      conta.parcelas[0].valor.should == 70000
      conta.parcelas[0].data_vencimento.should == "30/11/2009"
      conta.parcelas[1].valor.should == 10000
      conta.parcelas[1].data_vencimento.should == "22/01/2010"
      conta.parcelas[2].valor.should == 20000
      conta.parcelas[2].data_vencimento.should == "19/02/2010"
    end

    it "conseguiu alterar valor das parcelas de uma conta SEM rateio, COM parcelas baixadas" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      params = {"valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"1", "centro_outros_id"=>"", "centro_juros_id"=>"",  "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"Pagamento Cartão  - 123 - Juan Vitor Zeferino - Curso de Corel Draw", "observacoes"=>"", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"",
        "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"03/12/2009", "valor"=>"33333"}

      conta.parcelas[0].baixar_parcela(2009, conta.usuario_corrente, params).should == [true, 'Baixa na parcela realizada com sucesso!']
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>"30/11/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"100,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      #      conta.reload
      #
      #      # MANTEVE OS DADOS ANTIGOS
      #      conta.parcelas[0].valor.should == 33333
      #      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      #      conta.parcelas[1].valor.should == 33334
      #      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      #      conta.parcelas[2].valor.should == 33333
      #      conta.parcelas[2].data_vencimento.should == "20/01/2010"
    end

    it "conseguiu alterar valor das parcelas de uma conta SEM rateio e COM impostos lançados" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"

      imposto = impostos(:fgts)
      imposto_dois = impostos(:iss)
      conta.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"21-11-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"100.00", "aliquota"=>"8.0"},
        "2"=>{"data_de_recolhimento"=>"21-11-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#8.0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"}}
      conta.parcelas[0].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      conta.parcelas[2].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"23-12-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#5.0", "valor_imposto"=>"100.00", "aliquota"=>"5.0"},
        "2"=>{"data_de_recolhimento"=>"23-12-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#5.0", "valor_imposto"=>"50.00", "aliquota"=>"5.0"}}
      conta.parcelas[2].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]

      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>"30/11/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"100,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      conta.reload

      # ATUALIZOU OS DADOS
      conta.parcelas[0].valor.should == 70000
      conta.parcelas[0].data_vencimento.should == "30/11/2009"
      conta.parcelas[1].valor.should == 10000
      conta.parcelas[1].data_vencimento.should == "22/01/2010"
      conta.parcelas[2].valor.should == 20000
      conta.parcelas[2].data_vencimento.should == "19/02/2010"
    end

    it "não conseguiu alterar valor das parcelas de uma conta SEM rateio e COM impostos lançados, porque o valor dos impostos é maior que o valor da parcela" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"

      imposto = impostos(:fgts)
      imposto_dois = impostos(:iss)
      conta.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"21-11-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"100.00", "aliquota"=>"8.0"},
        "2"=>{"data_de_recolhimento"=>"21-11-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#8.0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"}}
      conta.parcelas[0].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      conta.parcelas[2].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"23-12-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#5.0", "valor_imposto"=>"100.00", "aliquota"=>"5.0"},
        "2"=>{"data_de_recolhimento"=>"23-12-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#5.0", "valor_imposto"=>"50.00", "aliquota"=>"5.0"}}
      conta.parcelas[2].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]

      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"800,00","data_vencimento"=>"30/11/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"150,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"50,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "Valor dos impostos maior que o valor da parcela. Impossível salvar por favor verifique."
      conta.reload

      # MANTEVE OS DADOS ANTIGOS
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
    end

    it "conseguiu alterar valor das parcelas conta COM rateio" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 1, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].rateios.first.valor.should == 33333
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].rateios.first.valor == 33334
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].rateios.first.valor == 33333
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>"30/11/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"100,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      conta.reload

      # ATUALIZOU OS DADOS
      conta.parcelas[0].rateios.first.valor.should == 70000
      conta.parcelas[0].valor.should == 70000
      conta.parcelas[0].data_vencimento.should == "30/11/2009"
      conta.parcelas[1].rateios.first.valor.should == 10000
      conta.parcelas[1].valor.should == 10000
      conta.parcelas[1].data_vencimento.should == "22/01/2010"
      conta.parcelas[2].rateios.first.valor.should == 20000
      conta.parcelas[2].valor.should == 20000
      conta.parcelas[2].data_vencimento.should == "19/02/2010"
    end

    it "não conseguiu alterar valor das parcelas conta COM rateio e COM lançamento de impostos, mas lança exceção agora" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 1, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].rateios.first.valor.should == 33333
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].rateios.first.valor == 33334
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].rateios.first.valor == 33333
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"

      imposto = impostos(:fgts)
      imposto_dois = impostos(:iss)
      conta.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"21-11-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"100.00", "aliquota"=>"8.0"},
        "2"=>{"data_de_recolhimento"=>"21-11-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#8.0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"}}
      conta.parcelas[0].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      conta.parcelas[2].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"23-12-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#5.0", "valor_imposto"=>"100.00", "aliquota"=>"5.0"},
        "2"=>{"data_de_recolhimento"=>"23-12-2009", "imposto_id"=>"#{imposto_dois.id.to_s}#5.0", "valor_imposto"=>"50.00", "aliquota"=>"5.0"}}
      conta.parcelas[2].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]

      ids_das_parcelas = conta.parcelas.collect(&:id)

      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>"30/11/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"250,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"50,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == 'Valor dos impostos maior ou igual ao valor da parcela. Impossível salvar por favor verifique.'
      conta.reload

      # MANTEVE OS DADOS ANTIGOS
      conta.parcelas[0].rateios.first.valor.should == 33333
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].rateios.first.valor.should == 33334
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].rateios.first.valor.should == 33333
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
    end

    it "conseguiu alterar valor das parcelas conta SEM a data de vencimento" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>""},
        ids_das_parcelas[1].to_s => {"valor"=>"100,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "A data de vencimento deve ser preenchida."
      conta.reload

      # MANTEVE OS DADOS ANTIGOS
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
    end

    it "conseguiu alterar valor das parcelas conta SEM o valor" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"","data_vencimento"=>"22/12/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"800,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "O valor deve ser preenchido."
      conta.reload

      # MANTEVE OS DADOS ANTIGOS
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
    end

    it "conseguiu alterar valor das parcelas conta com data de vencimento menor que a data de primeiro vencimento" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 3, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas[0].to_s => {"valor"=>"700,00","data_vencimento"=>"22/01/2009"},
        ids_das_parcelas[1].to_s => {"valor"=>"100,00","data_vencimento"=>"22/01/2010"},
        ids_das_parcelas[2].to_s => {"valor"=>"200,00","data_vencimento"=>"19/02/2010"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "A parcela com data de vencimento 22/01/2009 é inválida, pois o primeiro vencimento do contrato é em 20/11/2009"
      conta.reload

      # MANTEVE OS DADOS ANTIGOS
      conta.parcelas[0].valor.should == 33333
      conta.parcelas[0].data_vencimento.should == "20/11/2009"
      conta.parcelas[1].valor.should == 33334
      conta.parcelas[1].data_vencimento.should == "20/12/2009"
      conta.parcelas[2].valor.should == 33333
      conta.parcelas[2].data_vencimento.should == "20/01/2010"
    end


    it "verifica se a soma do valor das parcelas é igual ao valor do documento" do
      conta = PagamentoDeConta.new :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 0, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 100000, :numero_de_parcelas => 2, :rateio => 0, :historico => "Teste",
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :primeiro_vencimento => "20/11/2009", :data_lancamento => "15/11/2009"
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano = 2009
      conta.save!
      conta.gerar_parcelas(2009)

      ids_das_parcelas = conta.parcelas.collect(&:id)
      # Valores são iguais
      atributos = {ids_das_parcelas.first.to_s => {"valor"=>"500,00","data_vencimento"=>"22/01/2009"},
        ids_das_parcelas.last.to_s=>{"valor"=>"500,00","data_vencimento"=>"22/12/2009"}}
      conta.valores_das_parcelas_sao_diferentes?(atributos).should == false

      # Valor são diferentes
      atributos = {ids_das_parcelas.first.to_s => {"valor"=>"600,00","data_vencimento"=>"22/11/2009"},
        ids_das_parcelas.last.to_s => {"valor"=>"500,00","data_vencimento"=>"22/12/2009"}}
      conta.valores_das_parcelas_sao_diferentes?(atributos).should == true
    end
  end

  it 'testa liberação pelo DR do pagamento de conta' do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 1
    unidade.lancamentoscontasreceber = 1
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save

    r = pagamento_de_contas(:pagamento_dinheiro)
    r.esta_dentro_da_faixa_de_dias_permitido?.should == false
    r.valid?.should == false

    r.numero_nota_fiscal = 99999999
    r.liberacao_dr_faixa_de_dias_permitido = true
    r.save.should == true
    r.reload

    r.liberacao_dr_faixa_de_dias_permitido.should == false
  end

end
