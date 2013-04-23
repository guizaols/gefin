require File.dirname(__FILE__) + '/../spec_helper'

describe Parcela do  

  before(:each) do
    @parcela = Parcela.new
  end

  it 'deve calcular valor a partir do indice de reajuste' do
    p = parcelas(:primeira_parcela_recebimento)
    p.calcula_valor_total_da_parcela.should == 3006
    p.indice = 11
    p.calcula_valor_total_da_parcela.should == 3006
    p.retorna_valor_de_correcao_pelo_indice.should == 330

    p.indice = '10.0'
    p.calcula_valor_total_da_parcela.should == 3006
    p.retorna_valor_de_correcao_pelo_indice.should == 300
  end

  describe 'deve calcular juros e multas corretamente e' do

    it 'deixar os juros zerados quando estiver a vencer' do
      Date.stub!(:today).and_return Date.new 2009, 1, 1
      @parcela = parcelas(:primeira_parcela_recebimento)
      @parcela.valor = 100000 #R$ 1.000,00
      @parcela.data_vencimento = Date.new 2009, 1, 2
      @parcela.calcular_juros_e_multas!
      @parcela.valor_da_multa.should == 0
      @parcela.valor_dos_juros.should == 0
    end

    it 'preencher juros e multas quando estiver com um dia de atraso' do
      Date.stub!(:today).and_return Date.new 2009, 1, 2
      @parcela = parcelas(:primeira_parcela_recebimento)
      @parcela.valor_da_multa.should == 0
      @parcela.valor_dos_juros.should == 0
      @parcela.valor = 100000 #R$ 1.000,00
      @parcela.data_vencimento = Date.new 2009, 1, 1
      @parcela.calcular_juros_e_multas!
      @parcela.valor_da_multa.should == 2000
      @parcela.valor_dos_juros.should == 33
    end

    it 'preencher juros e multas passando outra data como base' do
      @parcela = parcelas(:primeira_parcela_recebimento)
      @parcela.valor_da_multa.should == 0
      @parcela.valor_dos_juros.should == 0
      @parcela.valor = 100000 #R$ 1.000,00
      @parcela.data_vencimento = Date.new 2009, 1, 1
      @parcela.calcular_juros_e_multas!('02/01/2009')
      @parcela.valor_da_multa.should == 2000
      @parcela.valor_dos_juros.should == 33
    end

    it 'não deve preencher juros e multas quando estiver baixado' do
      Date.stub!(:today).and_return Date.new 2012, 1, 1
      @parcela = parcelas(:primeira_parcela_recebimento)
      @parcela.data_vencimento = Date.new(2011, 1, 1)
      @parcela.data_da_baixa = Date.today
      @parcela.save false
      @parcela.reload

      @parcela.valor_da_multa.should == 0
      @parcela.valor_dos_juros.should == 0
      @parcela.calcular_juros_e_multas!
      @parcela.valor_da_multa.should == 0
      @parcela.valor_dos_juros.should == 0
    end
    
    it 'não deve calcular juros para contas a pagar' do
      Date.stub!(:today).and_return Date.new 2009, 1, 2
      @parcela = parcelas(:segunda_parcela)
      @parcela.valor = 100000 #R$ 1.000,00
      @parcela.data_vencimento = Date.new 2009, 1, 1
      @parcela.calcular_juros_e_multas!
      @parcela.valor_da_multa.should == 0
      @parcela.valor_dos_juros.should == 0
    end
  end
  #
  it "teste de campos obrigatórios" do
    @parcela = Parcela.new
    @parcela.should_not be_valid
    @parcela.errors.on(:valor).should_not be_nil
    @parcela.errors.on(:data_vencimento).should_not be_nil
  end
  #
  it "teste campo valor da parcela deve ser maior do que zero" do
    @parcela = Parcela.new
    @parcela.should_not be_valid
    @parcela.valor = 0
    @parcela.errors.on(:valor).should_not be_nil
  end
  
  it "atributo virtual baixando" do
    @parcela = Parcela.new
    @parcela.baixando.should == nil
  end

  
  it "atributo virtual estornando" do
    @parcela = Parcela.new
    @parcela.estornando.should == nil
  end
  
  it "atributo virtual dados_da_baixa" do
    @parcela = Parcela.new
    @parcela.dados_da_baixa.should == nil
  end

  it "atributo virtual replicar_rateio" do
    @parcela = Parcela.new
    @parcela.replicar.should == nil
  end
  
  it "teste do método initialize" do
    @parcela = Parcela.new
    @parcela.valor_liquido.should == 0
    @parcela.valor_da_multa.should == 0
    @parcela.data_da_baixa.should == nil
    @parcela.outros_acrescimos.should == 0
  end
  
  it "verifica se monta os dados da baixa" do
    @parcela = parcelas(:segunda_parcela_sesi)
    @parcela.dados_da_baixa.should == 'Pagamento efetuado em dinheiro.'
    @parcela = parcelas(:primeira_parcela_recebida_cheque_a_vista)
    @parcela.dados_da_baixa.should == 'Pagamento efetuado com cheque à vista do Banco do Brasil, Número: 010203, Agência: 0108-6, Conta Corrente: 2716801-5.'
    @parcela = parcelas(:primeira_parcela_recebida_cheque_a_prazo)
    @parcela.dados_da_baixa.should == 'Pagamento efetuado com cheque pré-datado do Banco do Brasil, Número: 010508, Agência: 0107-3, Conta Corrente: 2718904-4, Bom para: 10/06/2009.'
    @parcela = parcelas(:primeira_parcela_recebida_em_cartao)
    @parcela.dados_da_baixa.should == 'Pagamento efetuado com cartão Visa Crédito, Número: 8494302559190206, Validade: 11/12.'
    @parcela = parcelas(:primeira_parcela_pagamento_banco)
    @parcela.dados_da_baixa.should == 'Pagamento efetuado via depósito bancário no dia 13/10/2009, depósito efetuado no Banco do Brasil, Agência: Centro, Número da agência: 2445-6, Conta Corrente: 2345-3.'
  end

  it "testa se o campo data do pagamento esta correto com data_br_field" do
    @parcela = Parcela.new :data_do_pagamento => "01/01/2009", :data_vencimento => "02/02/2009", :data_da_baixa => "03/03/2009"
    @parcela.data_do_pagamento = "01/01/2009"
    @parcela.data_do_pagamento.should == "01/01/2009"
    @parcela.data_vencimento.should == "02/02/2009"
    @parcela.data_da_baixa.should == "03/03/2009"
  end

  it "teste dos campos obrigatórios de baixa banco em um pagamento de conta" do
    @parcela = Parcela.new :forma_de_pagamento => Parcela::BANCO, :conta => pagamento_de_contas(:pagamento_cheque_outra_unidade)
    @parcela.should_not be_valid
    @parcela.errors.on(:data_do_pagamento).should_not be_nil
    @parcela.errors.on(:numero_do_comprovante).should_not be_nil
    @parcela.errors.on(:conta_corrente).should_not be_nil
  end

  it "teste dos campos obrigatórios de baixa banco em um recebimento de conta" do
    @parcela = Parcela.new :forma_de_pagamento => Parcela::BANCO, :conta => recebimento_de_contas(:curso_de_design_do_paulo)
    @parcela.should_not be_valid
    @parcela.errors.on(:data_do_pagamento).should be_nil
    @parcela.errors.on(:numero_do_comprovante).should be_nil
    @parcela.errors.on(:conta_corrente).should_not be_nil
  end

  it "teste dos campos obrigatórios de baixa em banco" do
    @parcela = parcelas(:primeira_parcela_recebimento)
    @parcela.forma_de_pagamento = Parcela::DINHEIRO
    @parcela.data_do_pagamento = Date.today.to_s_br
    @parcela.numero_do_comprovante = "12345"
    @parcela.data_da_baixa = Date.today.to_s_br
    @parcela.historico = "Baixa"
    @parcela.baixando = true
    @parcela.ano_contabil_atual = 2009
    @parcela.save!
    @parcela.data_do_pagamento.should == nil
    @parcela.numero_do_comprovante.should == nil

    cartao = Cartao.new :nome_do_titular => "Guizao", :validade => "10/12",
      :bandeira => Cartao::VISACREDITO, :codigo_de_seguranca => "123", :numero => "555"
    @parcela_dois = parcelas(:terceira_parcela)
    @parcela_dois.forma_de_pagamento = Parcela::CARTAO
    @parcela_dois.cartoes = [cartao]
    @parcela_dois.data_do_pagamento = "10/10/2009"
    @parcela_dois.numero_do_comprovante = "12345"
    @parcela_dois.data_da_baixa = "10/10/2009"
    @parcela_dois.historico = "Baixa"
    @parcela_dois.ano_contabil_atual = 2009
    @parcela_dois.baixando = true
    @parcela_dois.save!
    @parcela_dois.data_do_pagamento.should == nil
    @parcela_dois.numero_do_comprovante.should == nil

    @parcela_pagar = parcelas(:segunda_parcela)
    @parcela_pagar.forma_de_pagamento = Parcela::BANCO
    @parcela_pagar.conta_corrente = contas_correntes(:primeira_conta)
    @parcela_pagar.data_do_pagamento = Date.today.to_s_br
    @parcela_pagar.numero_do_comprovante = "12345"
    @parcela_pagar.data_da_baixa = Date.today.to_s_br
    @parcela_pagar.historico = "Baixa"
    @parcela_pagar.baixando = true
    @parcela_pagar.ano_contabil_atual = 2009
    @parcela_pagar.save!
    @parcela_pagar.data_do_pagamento.should == Date.today.to_s_br
    @parcela_pagar.numero_do_comprovante.should == "12345"
  end

  it "teste dos campos obrigatórios de baixa banco em um recebimento de conta" do
    @parcela = parcelas(:primeira_parcela_recebimento)
    @parcela.forma_de_pagamento = Parcela::BANCO
    @parcela.conta_corrente = contas_correntes(:primeira_conta)
    @parcela.data_do_pagamento = Date.today.to_s_br
    @parcela.numero_do_comprovante = "12345"
    @parcela.data_da_baixa = Date.today.to_s_br
    @parcela.historico = "Baixa"
    @parcela.baixando = true
    @parcela.ano_contabil_atual = 2009
    @parcela.save!
    @parcela.data_do_pagamento.should == nil
    @parcela.numero_do_comprovante.should == nil
  end
  
  it "valida inclusão de forma_de_pagamento em BANCO ou DINHEIRO" do
    @outra_parcela = parcelas(:primeira_parcela_pagamento_banco)
    @outra_parcela.forma_de_pagamento = nil
    @outra_parcela.should_not be_valid
    @outra_parcela.errors.on(:forma_de_pagamento).should_not be_nil

    @outra_parcela.forma_de_pagamento = Parcela::DINHEIRO
    @outra_parcela.should be_valid

    @outra_parcela.forma_de_pagamento = Parcela::BANCO
    @outra_parcela.should be_valid
    
    @outra_parcela.forma_de_pagamento = Parcela::CHEQUE
    @outra_parcela.cheques = [Cheque.first]
    @outra_parcela.should be_valid
    
    @outra_parcela.forma_de_pagamento = Parcela::CARTAO
    @outra_parcela.cartoes = [Cartao.first]
    @outra_parcela.should be_valid

    @outra_parcela.forma_de_pagamento = 5
    @outra_parcela.should_not be_valid
  end
  #
  it "atributo virtual para auto_complete nome_conta_corrente" do
    @parcela = Parcela.new
    @parcela.nome_conta_corrente.should == nil
  end
  #
  it "testa forma_de_pagamento_verbose" do
    parcelas(:primeira_parcela_pagamento_banco).forma_de_pagamento_verbose.should == "Banco"
    parcelas(:primeira_parcela).forma_de_pagamento_verbose == "Dinheiro"
    parcelas(:primeira_parcela_recebida_cheque_a_vista).forma_de_pagamento_verbose.should == "Cheque"
  end
  #
  it "testa o reader de nome_conta_corrente" do
    parcelas(:primeira_parcela).nome_conta_corrente.should == nil
    parcelas(:primeira_parcela_pagamento_banco).nome_conta_corrente.should == "2345-3 - Conta do Senai Várzea Grande"
  end
  #  
  it "testa o filtro de parcelas baixadas" do
    parcelas(:primeira_parcela_recebimento).data_da_baixa = "01/06/2009"
    parcelas(:primeira_parcela_recebimento).save false
    parcelas(:segunda_parcela_recebimento).data_da_baixa = "02/06/2009"
    parcelas(:segunda_parcela_recebimento).save false
    recebimento_de_contas(:curso_de_design_do_paulo).reload
    recebimento_de_contas(:curso_de_design_do_paulo).parcelas.que_estao_baixadas.should == parcelas(:primeira_parcela_recebimento,:segunda_parcela_recebimento)
  end
  
  describe 'teste de relacionamentos' do
    
    it "teste de relacionamentos" do
      parcelas(:primeira_parcela).conta.should == pagamento_de_contas(:pagamento_cheque_outra_unidade)
      parcelas(:primeira_parcela).rateios.should == rateios(:segundo_rateio_primeira_parcela,:rateio_primeira_parcela)
      parcelas(:primeira_parcela).unidade_organizacional_desconto.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
      parcelas(:primeira_parcela).unidade_organizacional_juros.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
      parcelas(:primeira_parcela).unidade_organizacional_outros.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
      parcelas(:primeira_parcela).unidade_organizacional_multa.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
      parcelas(:primeira_parcela).conta_contabil_juros.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
      parcelas(:primeira_parcela).conta_contabil_desconto.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
      parcelas(:primeira_parcela).conta_contabil_multa.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
      parcelas(:primeira_parcela).conta_contabil_outros.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
      parcelas(:primeira_parcela).centro_desconto.should == centros(:centro_forum_social)
      parcelas(:primeira_parcela_recebimento).unidade_organizacional_honorarios.should == unidade_organizacionais(:senai_unidade_organizacional)
      parcelas(:primeira_parcela_recebimento).unidade_organizacional_protesto.should == unidade_organizacionais(:senai_unidade_organizacional)
      parcelas(:primeira_parcela_recebimento).unidade_organizacional_taxa_boleto.should == unidade_organizacionais(:senai_unidade_organizacional)
      parcelas(:primeira_parcela_recebimento).centro_honorarios.should == centros(:centro_forum_economico)
      parcelas(:primeira_parcela_recebimento).centro_protesto.should == centros(:centro_forum_economico)
      parcelas(:primeira_parcela_recebimento).centro_taxa_boleto.should == centros(:centro_forum_economico)
      parcelas(:primeira_parcela_recebimento).conta_contabil_honorarios.should == plano_de_contas(:plano_de_contas_ativo_despesas_senai)
      parcelas(:primeira_parcela_recebimento).conta_contabil_protesto.should == plano_de_contas(:plano_de_contas_ativo_despesas_senai)
      parcelas(:primeira_parcela_recebimento).conta_contabil_taxa_boleto.should == plano_de_contas(:plano_de_contas_ativo_despesas_senai)
      parcelas(:primeira_parcela_pagamento_banco).conta_corrente.should == contas_correntes(:primeira_conta)
      parcelas(:parcela_pagamento_cheque_para_movimento).movimentos.should == [movimentos(:lancamento_com_a_conta_pagamento_cheque)]
    end
    
    it "testa relacionamento polimórfico" do
      parcela = Parcela.new :conta => pagamento_de_contas(:pagamento_cheque)
      parcela.conta.should == pagamento_de_contas(:pagamento_cheque)
      parcela.conta_id.should == pagamento_de_contas(:pagamento_cheque).id
      parcela.conta_type.should == 'PagamentoDeConta'
    end
    
  end
  
  describe 'teste envolvendo DADOS DO RATEIO' do
    it "teste de atributo virtual dados_do_rateio" do
      @parcela = Parcela.new
      @parcela.dados_do_rateio.should == {}
    end
    
    it "teste do aatr_procted para dados_do_rateio" do
      @parcela = Parcela.new :dados_do_rateio => "SQL INJECTION"
      @parcela.dados_do_rateio.should == {}
    end
    
    it "teste se a validação que verifica se o valor dos itens do rateio são iguais ao valor da parcela está adequada" do
      @parcela = Parcela.new  :conta=> pagamento_de_contas(:pagamento_cheque),:valor=> 5000
      @parcela.dados_do_rateio = {"1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI","valor"=>"100.00","centro_nome"=>"a","unidade_organizacional_nome"=>"x","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id}}
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should == "A soma do valor dos itens do rateio não é igual ao valor da parcela."
    end
    
    it "teste se a validação que verifica se as unidade organizacionais e centro que estão sendo inseridos são válidas" do
      @parcela = Parcela.new  :conta=> pagamento_de_contas(:pagamento_cheque),:valor=> 5000
      @parcela.dados_do_rateio = {"1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI","conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI","valor"=>"100.00","centro_nome"=>"y","unidade_organizacional_nome"=>"x","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id},"2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI","valor"=>"100.00","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id,"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"}}
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should ==  [ "A soma do valor dos itens do rateio não é igual ao valor da parcela.","Não é permitido vincular a mesma unidade organizacional,centro de responsabilidade e conta contábil para outro rateio da mesma parcela."]
    end
    
    it "não permitir fazer novo rateio apos a parcela ter sido baixada" do
      @parcela = parcelas(:segunda_parcela)
      @parcela.historico = "TEste"
      @parcela.data_da_baixa = Date.today.to_s_br
      @parcela.baixando = true
      #@parcela.save
      @parcela.dados_do_rateio = {"1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI","valor"=>"100.00","centro_nome"=>"y","unidade_organizacional_nome"=>"x","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id},"2"=>{"valor"=>"100.00","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id}}
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should_not be_nil
    end
    
    it "teste se retira o id dos centros e unidades quando não tem nada no centro_nome ne centro_unidade_organizacional" do
      Rateio.delete_all
      Parcela.delete_all
      @parcela = Parcela.new  :conta=> pagamento_de_contas(:pagamento_cheque),:valor=> 5000,:data_vencimento=>"22/02/2009"
      @parcela.dados_do_rateio = {"1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"","valor"=>"50.00","centro_nome"=>"","unidade_organizacional_nome"=>"","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id}}
      @parcela.grava_itens_do_rateio(2009, @parcela.conta.usuario_corrente).should == [false, "* O campo unidade organizacional deve ser preenchido\n* O campo parcela deve ser preenchido.\n* O campo centro deve ser preenchido.\n* O campo conta contábil deve ser preenchido"]
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should == ["O campo unidade organizacional deve ser preenchido", "O campo parcela deve ser preenchido.", "O campo centro deve ser preenchido.", "O campo conta contábil deve ser preenchido"]
    end
    
    it "limpa itens em branco do hash" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.dados_do_rateio = {"1"=>{"valor"=>"","centro_nome"=>"","unidade_organizacional_nome"=>"","centro_id"=>"","unidade_organizacional_id"=>""}}
      @parcela.limpa_hash_itens_do_rateio.should == {}
    end
    
    it "verifica se está replicando o dados do rateio corretamente para uma parcela de no valor 33,34" do
      Parcela.delete_all
      Rateio.delete_all
      @conta = pagamento_de_contas(:pagamento_cheque)
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.save!
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.gerar_parcelas(2009)
      @primeira_parcela = Parcela.first
      @primeira_parcela.dados_do_rateio = {"1"=>{"centro_nome"=>"4567456344 - Forum Serviço Economico", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_economico).id.to_s, "valor"=>"23,34", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2"=>{"centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"10,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"}
      }
      @primeira_parcela.replicar = "1"
      @primeira_parcela.grava_itens_do_rateio(2009, @conta.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      Rateio.count.should == 6
      @segunda_parcela = Parcela.all[1]
      @segunda_parcela.dados_do_rateio["1"]["valor"].should == "23.34"
      @segunda_parcela.dados_do_rateio["2"]["valor"].should == "10.00"
      @terceira_parcela = Parcela.last
      @terceira_parcela.dados_do_rateio["1"]["valor"].should == "23.33"
      @terceira_parcela.dados_do_rateio["2"]["valor"].should == "10.00"
    end
    
    it "verifica se deleta rateios apos excluir uma parcela" do
      Parcela.delete_all
      Rateio.delete_all
      @conta = pagamento_de_contas(:pagamento_cheque)
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.save!
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.gerar_parcelas(2009)
      @primeira_parcela = Parcela.first
      @primeira_parcela.dados_do_rateio = {"1"=>{"centro_nome"=>"4567456344 - Forum Serviço Economico", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_economico).id.to_s, "valor"=>"23,34", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2"=>{"centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"10,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"}
      }
      @primeira_parcela.replicar = "1"
      @primeira_parcela.grava_itens_do_rateio(2009, @conta.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
    end
    
    it "verifica se está deletando os rateios quando eu deleto uma parcela" do
      Parcela.delete_all
      Rateio.delete_all
      @conta = pagamento_de_contas(:pagamento_cheque)
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.save!
      @conta.usuario_corrente = usuarios(:quentin)
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta.gerar_parcelas(2009)
        historico_operacao = @conta.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 3 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta
      end
      @primeira_parcela = Parcela.last
      @primeira_parcela.dados_do_rateio = { "1" => {"centro_nome" => "34567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Sesi Matriz", "centro_id" => centros(:centro_forum_economico).id.to_s, "valor"=>"23.33", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2"=>{"centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"10.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"}
      }
      @primeira_parcela.grava_itens_do_rateio(2009, @conta.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      Rateio.count.should == 4
      assert_difference 'Rateio.count',-2 do
        @primeira_parcela.destroy
      end
    end
    
    it "verifica se está replicando o dados do rateio corretamente para uma parcela de no valor 10,00 e para um recebimento de conta" do
      Parcela.delete_all
      Rateio.delete_all
      
      @conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.save!

      assert_difference 'Parcela.count', 1 do
        assert_difference 'HistoricoOperacao.count', 1 do
          @conta.gerar_parcelas(2009)
          historico_operacao = @conta.historico_operacoes.last
          historico_operacao.descricao.should == "Geradas 1 parcelas"
          historico_operacao.usuario = usuarios(:quentin)
          historico_operacao.conta = @conta
        end
      end

      @primeira_parcela = Parcela.first
      @primeira_parcela.dados_do_rateio = 
        {"1" => {"centro_nome" => "34567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Sesi Matriz",
          "centro_id" => centros(:centro_forum_economico).id.to_s, "valor" => "3,34", "unidade_organizacional_id" =>unidade_organizacionais(:senai_unidade_organizacional).id,
          "conta_contabil_id" => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome" => "41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2" => {"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI",
          "centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id" => centros(:centro_forum_financeiro).id.to_s,
          "valor" => "6,66", "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id.to_s}}
      
      @primeira_parcela.grava_itens_do_rateio(2009, @conta.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      Rateio.count.should == 2
      
      @primeira_parcela.dados_do_rateio["1"]["valor"].should == "3,34"
      @primeira_parcela.dados_do_rateio["2"]["valor"].should == "6,66"
    end
  end
  
  describe 'Regras de Negócio' do
    it "validação da regra de negocio quando há data_da_baixa" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009', :conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000
      @parcela.should be_valid
      @parcela.save
      @parcela.data_da_baixa = '08/04/2009'
      @parcela.baixando = true
      @parcela.save
      @parcela.should_not be_valid
      @parcela.errors.on(:historico).should_not be_nil
      @parcela.outros_acrescimos = 3
      @parcela.should_not be_valid
      @parcela.errors.on(:justificativa_para_outros).should_not be_nil
      @parcela.outros_acrescimos = -2
      @parcela.should_not be_valid
      @parcela.errors.on(:outros_acrescimos).should_not be_nil
      @parcela.outros_acrescimos = 0
      @parcela.valor_do_desconto = -3
      @parcela.should_not be_valid
      @parcela.errors.on(:valor_do_desconto).should_not be_nil
      @parcela.valor_do_desconto = 0
      @parcela.valor_dos_juros = -4
      @parcela.should_not be_valid
      @parcela.errors.on(:valor_dos_juros).should_not be_nil
      @parcela.valor_dos_juros = 0
      @parcela.valor_da_multa = -2
      @parcela.should_not be_valid
      @parcela.errors.on(:valor_da_multa).should_not be_nil
      @parcela.valor_da_multa = 0
      @parcela.unidade.lancamentoscontaspagar = 5
      @parcela.unidade.save!
      @parcela.data_da_baixa = '01/03/2009'
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should == "A data limite para baixa não está de acordo com as datas permitidas conforme as configurações."
    end
    
    it "regra do negocio para data_da_baixa" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.data_da_baixa = nil
      @parcela.baixando = true
      @parcela.should_not be_valid
      @parcela.errors.on(:data_da_baixa).should == "deve ser preenchido."
    end

    it "regra dos limites das configurações quando não baixa parcela tanto a pagar, quanto receber" do
      @parcela = parcelas(:segunda_parcela)
      @parcela.unidade.lancamentoscontaspagar = 5
      @parcela.unidade.save!
      @parcela.data_da_baixa = Date.today - 10
      @parcela.historico = "Baixa"
      @parcela.forma_de_pagamento = Parcela::DINHEIRO
      @parcela.baixando = true
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should == "A data limite para baixa não está de acordo com as datas permitidas conforme as configurações."
      @parcela.data_da_baixa = Date.today - 4
      @parcela.should be_valid
      @parcela.errors.on(:base).should_not == be_nil

      @parcela_dois = parcelas(:primeira_parcela_recebimento)
      @parcela_dois.unidade.lancamentoscontasreceber = 5
      @parcela_dois.unidade.save!
      @parcela_dois.data_da_baixa = Date.today - 10
      @parcela_dois.historico = "Baixa"
      @parcela_dois.forma_de_pagamento = Parcela::DINHEIRO
      @parcela_dois.baixando = true
      @parcela_dois.should_not be_valid
      @parcela_dois.errors.on(:base).should == "A data limite para baixa não está de acordo com as datas permitidas conforme as configurações."
      @parcela_dois.data_da_baixa = Date.today - 5
      @parcela_dois.should be_valid
      @parcela_dois.errors.on(:base).should_not == be_nil
    end

    it "não permitir baixar a parcela duas vezes" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.save
      @parcela.baixando = true
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should_not be_nil
    end
    
    it "regra de negócio em valor_da_multa" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque), :valor => 5000
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando = true
      @parcela.data_da_baixa = '08/04/2009'
      @parcela.valor_da_multa_em_reais = "12,00"
      @parcela.should_not be_valid
      @parcela.valor_da_multa.should == 1200
      @parcela.situacao.should == Parcela::QUITADA
      @parcela.situacao_verbose.should == 'Quitada'
      @parcela.errors.on(:centro_multa).should_not be_nil
      @parcela.errors.on(:unidade_organizacional_multa).should_not be_nil
      @parcela.errors.on(:conta_contabil_multa).should_not be_nil
    end
    
    it "regra de negócio para quando há baixa em cheque porém os atributos não são preenchidos" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000      
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando = true
      @parcela.historico = "teste"
      @parcela.data_da_baixa = '08/04/2010'
      @parcela.forma_de_pagamento = Parcela::CHEQUE
      @cheque=@parcela.cheques.build
      @parcela.should_not be_valid
      @cheque.errors.on(:banco).should_not be_nil
      @cheque.errors.on(:agencia).should_not be_nil
      @cheque.errors.on(:conta).should_not be_nil
      @cheque.errors.on(:numero).should_not be_nil 
      @cheque.errors.on(:data_para_deposito).should_not be_nil
      @cheque.errors.on(:nome_do_titular).should_not be_nil
    end
    
    it "regra de négocio cria um objeto cheque quando uma baixa é feita em cheque" do
      usuario = usuarios(:quentin)
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000      
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando = true
      @parcela.historico = "teste"
      @parcela.cartoes << Cartao.first
      @parcela.data_da_baixa = '08/04/2010'
      @parcela.forma_de_pagamento = Parcela::CHEQUE
      @cheque=@parcela.cheques.build
      @parcela.should_not be_valid
      @cheque.banco = Banco.first
      @cheque.agencia = "teste"
      @cheque.conta = "teste"
      @cheque.numero = "teste"
      @cheque.data_para_deposito = '08/05/2010'
      @cheque.nome_do_titular = "teste"
      @cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
      @cheque.prazo = Cheque::VISTA
      @parcela.ano_contabil_atual = 2009
      assert_difference 'Cheque.count',1 do
        @parcela.save
      end
      @parcela.cartoes.should == []
      cheque = Cheque.last
      cheque.banco_id = Banco.first.id
      cheque.agencia.should == "teste"
      cheque.conta.should == "teste"
      cheque.numero.should == "teste"
      cheque.nome_do_titular.should == "teste"
    end
    
    it "não permite vincular mais de um cheque para a mesma parcela" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000      
      @parcela.should be_valid
      @parcela.save
      @parcela.cheques << Cheque.first
      @parcela.save
      @parcela.cheques << Cheque.last
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should_not be_nil
    end
    
    it "não permite vincular mais de um cartão para a mesma parcela" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000      
      @parcela.should be_valid
      @parcela.save
      @parcela.cartoes<< Cartao.first
      @parcela.save
      @parcela.cartoes << Cartao.last
      @parcela.should_not be_valid
      @parcela.errors.on(:base).should_not be_nil
    end
    
    it "regra de negócio em valor_do_desconto" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando=true
      @parcela.data_da_baixa = '08/04/2009'
      @parcela.valor_do_desconto_em_reais = "12,00"
      @parcela.should_not be_valid
      @parcela.valor_do_desconto.should == 1200
      @parcela.situacao.should == Parcela::QUITADA
      @parcela.situacao_verbose.should == 'Quitada'
      @parcela.errors.on(:centro_desconto).should_not be_nil
      @parcela.errors.on(:unidade_organizacional_desconto).should_not be_nil
      @parcela.errors.on(:conta_contabil_desconto).should_not be_nil
    end
    
    it "regra de negócio em valor_dos_juros" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando=true
      @parcela.data_da_baixa = '08/04/2009'
      @parcela.valor_dos_juros_em_reais = "12,00"
      @parcela.should_not be_valid
      @parcela.valor_dos_juros.should == 1200
      @parcela.situacao.should == Parcela::QUITADA
      @parcela.situacao_verbose.should == 'Quitada'
      @parcela.errors.on(:centro_juros).should_not be_nil
      @parcela.errors.on(:unidade_organizacional_juros).should_not be_nil
      @parcela.errors.on(:conta_contabil_juros).should_not be_nil
    end
    
    it "regra de negócio em outros_acrescimos" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando=true
      @parcela.data_da_baixa = '08/04/2009'
      @parcela.outros_acrescimos_em_reais = "12,00"
      @parcela.should_not be_valid
      @parcela.outros_acrescimos.should == 1200
      @parcela.situacao.should == Parcela::QUITADA
      @parcela.situacao_verbose.should == 'Quitada'
      @parcela.errors.on(:centro_outros).should_not be_nil
      @parcela.errors.on(:unidade_organizacional_outros).should_not be_nil
      @parcela.errors.on(:conta_contabil_outros).should_not be_nil
    end
    
    it "regra de negócio em valor_liquido sem retencao" do
      @parcela = Parcela.new :data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000
      @parcela.should be_valid
      @parcela.save
      @parcela.baixando=true
      @parcela.data_da_baixa = '08/04/2009'
      @parcela.outros_acrescimos_em_reais = "12,00"
      @parcela.valor_dos_juros_em_reais = "12,00"
      @parcela.valor_do_desconto_em_reais = "12,00"
      @parcela.valor_da_multa_em_reais = "12,00"
      @parcela.should_not be_valid
      @parcela.valor_liquido.should == 7400
      @parcela.situacao.should == Parcela::QUITADA
      @parcela.situacao_verbose.should == 'Quitada'
    end
    
    it "regra de negócio que o valor do desconto não pode ser maior que o valor da parcela" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.baixando = true
      @parcela.valor_do_desconto = 10000000000
      @parcela.retencao
      @parcela.should_not be_valid
      @parcela.errors.on(:valor_do_desconto).should_not be_nil
    end
    
    it "regra de negócio nao permite baixar quando não há conta caixa" do
      ContasCorrente.delete_all
      @parcela = parcelas(:primeira_parcela)
      @parcela.baixando = true
      @parcela.should_not be_valid
      @parcela.errors.on(:forma_de_pagamento).should_not be_nil
    end
    
    it "teste para verificar situacao QUITADA da parcela" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.baixando = true
      @parcela.situacao.should == Parcela::QUITADA
      @parcela.situacao_verbose.should == 'Quitada'
      @parcela.save
      @parcela.should_not be_valid
    end
    
    it "teste para verificar situacao ATRASADA da parcela" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.situacao = 1
      @parcela.save
      @parcela.baixando = true
      @parcela.situacao.should == Parcela::PENDENTE
      @parcela.situacao_verbose.should == 'Em atraso'
      @parcela.should_not be_valid
    end
    
    it "teste para verificar se a situacao_was da parcela nao permite gravar após situacao cancelada" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.situacao = 3
      @parcela.should be_valid
      @parcela.save!
      @parcela.data_da_baixa = ""
      @parcela.save
      @parcela.should_not be_valid
      @parcela.errors.on(:situacao).should == "da parcela é cancelada."
    end

    it "deve permitir recuperar a parcela cancelada se cancelado_pelo_contrato for true" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.cancelado_pelo_contrato = true
      @parcela.situacao = Parcela::CANCELADA
      @parcela.save false      
      @parcela.situacao = Parcela::PENDENTE
      @parcela.save
      @parcela.should be_valid
      @parcela.errors.on(:situacao).should == nil
    end

    it "deve permitir alterar parcela se situacao for igual a CANCELADA e cancelado_pelo_contrato for igual a true" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.cancelado_pelo_contrato = true
      @parcela.situacao = Parcela::CANCELADA
      @parcela.should be_valid
      @parcela.errors.on(:situacao).should == nil
    end

    it "nao deve permir alterar parcela se situacao for igual a CANCELADA e cancelado_pelo_contrato for igual a false" do
      @parcela = parcelas(:primeira_parcela)
      @parcela.cancelado_pelo_contrato = false
      @parcela.situacao = Parcela::CANCELADA
      @parcela.save.should == true
      @parcela.should_not be_valid
      @parcela.errors.on(:situacao).should == "da parcela é cancelada."
    end
    
  end
  
  describe 'Teste de atributos virtuais do plugin   cria_atributos_virtuais_para_auto_complete' do
    
    it "testa o atributo virtual unidade_organizacional_desconto" do
      @parcela = Parcela.new
      @parcela.nome_unidade_organizacional_desconto.should == nil
      @parcela.unidade_organizacional_desconto = unidade_organizacionais(:sesi_colider_unidade_organizacional)
      @parcela.nome_unidade_organizacional_desconto.should == "#{unidade_organizacionais(:sesi_colider_unidade_organizacional).codigo_da_unidade_organizacional} - #{unidade_organizacionais(:sesi_colider_unidade_organizacional).nome}"
    end
    
    it "testa o atributo virtual baixada" do
      @parcela = Parcela.new
      @parcela.baixada.should == false
    end
    
    it "testa o atributo virtual unidade_organizacional_multa" do
      @parcela = Parcela.new
      @parcela.nome_unidade_organizacional_multa.should == nil
      @parcela.unidade_organizacional_multa = unidade_organizacionais(:sesi_colider_unidade_organizacional)
      @parcela.nome_unidade_organizacional_multa.should == "#{unidade_organizacionais(:sesi_colider_unidade_organizacional).codigo_da_unidade_organizacional} - #{unidade_organizacionais(:sesi_colider_unidade_organizacional).nome}"
    end
    
    it "testa o atributo virtual unidade_organizacional_juros" do
      @parcela = Parcela.new
      @parcela.nome_unidade_organizacional_juros.should == nil
      @parcela.unidade_organizacional_juros = unidade_organizacionais(:sesi_colider_unidade_organizacional)
      @parcela.nome_unidade_organizacional_juros.should == "#{unidade_organizacionais(:sesi_colider_unidade_organizacional).codigo_da_unidade_organizacional} - #{unidade_organizacionais(:sesi_colider_unidade_organizacional).nome}"
    end
    
    it "testa o atributo virtual unidade_organizacional_outros" do
      @parcela = Parcela.new
      @parcela.nome_unidade_organizacional_outros.should == nil
      @parcela.unidade_organizacional_outros = unidade_organizacionais(:sesi_colider_unidade_organizacional)
      @parcela.nome_unidade_organizacional_outros.should == "#{unidade_organizacionais(:sesi_colider_unidade_organizacional).codigo_da_unidade_organizacional} - #{unidade_organizacionais(:sesi_colider_unidade_organizacional).nome}"
    end
    
    it "testa o atributo virtual centro_multa" do
      @parcela = Parcela.new
      @parcela.nome_centro_multa.should == nil
      @parcela.centro_multa = centros(:centro_forum_social)
      @parcela.nome_centro_multa.should == "#{centros(:centro_forum_social).codigo_centro} - #{centros(:centro_forum_social).nome}"
    end
    
    it "testa o atributo virtual centro_outros" do
      @parcela = Parcela.new
      @parcela.nome_centro_outros.should == nil
      @parcela.centro_outros = centros(:centro_forum_social)
      @parcela.nome_centro_outros.should == "#{centros(:centro_forum_social).codigo_centro} - #{centros(:centro_forum_social).nome}"
    end
    
    it "testa o atributo virtual centro_juros" do
      @parcela = Parcela.new
      @parcela.nome_centro_juros.should == nil
      @parcela.centro_juros = centros(:centro_forum_social)
      @parcela.nome_centro_juros.should == "#{centros(:centro_forum_social).codigo_centro} - #{centros(:centro_forum_social).nome}"
    end
    
    it "testa o atributo virtual conta_contabil_multa" do
      @parcela = Parcela.new
      @parcela.nome_conta_contabil_multa.should == nil
      @parcela.conta_contabil_multa = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      @parcela.nome_conta_contabil_multa.should == "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - #{plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome}"
    end
    
    it "testa o atributo virtual conta_contabil_juros" do
      @parcela = Parcela.new
      @parcela.nome_conta_contabil_juros.should == nil
      @parcela.conta_contabil_juros = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      @parcela.nome_conta_contabil_juros.should == "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - #{plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome}"
    end
    
    it "testa o atributo virtual conta_contabil_desconto" do
      @parcela = Parcela.new
      @parcela.nome_conta_contabil_desconto.should == nil
      @parcela.conta_contabil_desconto = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      @parcela.nome_conta_contabil_desconto.should == "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - #{plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome}"
    end
    
    it "testa o atributo virtual conta_contabil_outros" do
      @parcela = Parcela.new
      @parcela.nome_conta_contabil_outros.should == nil
      @parcela.conta_contabil_outros = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      @parcela.nome_conta_contabil_outros.should == "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - #{plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome}"
    end
  end
  
  describe "teste da função cria_readers_para_valores_em_dinheiro" do
    
    it "teste do atributo virtual valor_dos_juros_em_reais" do
      @parcela = Parcela.new
      @parcela.valor_dos_juros_em_reais.should == "0,00"
      @parcela.valor_dos_juros = 1200
      @parcela.valor_dos_juros_em_reais.should == "12,00"
    end
    
    it "teste do atributo virtual valor_dos_desconto_em_reais" do
      @parcela = Parcela.new
      @parcela.valor_do_desconto_em_reais.should == "0,00"
      @parcela.valor_do_desconto = 12001
      @parcela.valor_do_desconto_em_reais.should == "120,01"
    end
    
    it "teste do atributo virtual outros_acrescimos_em_reais" do
      @parcela = Parcela.new
      @parcela.outros_acrescimos_em_reais.should == "0,00"
      @parcela.outros_acrescimos = 1
      @parcela.outros_acrescimos_em_reais.should == "0,01"
    end
    
    it "teste do atributo virtual valor_da_multa_em_reais" do
      @parcela = Parcela.new
      @parcela.valor_da_multa_em_reais.should == "0,00"
      @parcela.valor_da_multa = 100
      @parcela.valor_da_multa_em_reais.should == "1,00"
    end
    
    it "teste do atributo virtual retencao" do
      @parcela = Parcela.new
      @parcela.retencao.should == nil
      @parcela.retencao = 100
      @parcela.retencao.should == 100
    end
    
  end
  
  describe 'Testes referentes a baixa na parcela' do
    
    it "verifica se limpa os campos de um determinado item da baixa quando o valor permanece zero" do
      @parcela = Parcela.new :baixando=>true,:data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000,:centro_multa_id=>centros(:centro_forum_social),:centro_desconto_id=>centros(:centro_forum_social),
        :centro_juros_id=>centros(:centro_forum_social),:unidade_organizacional_multa_id=>unidade_organizacionais(:sesi_colider_unidade_organizacional)
      
      @parcela.valid?
      @parcela.centro_multa_id.should == nil
      @parcela.centro_desconto_id.should == nil
      @parcela.centro_juros_id.should == nil
      @parcela.unidade_organizacional_multa_id.should == nil
    end
    
    it "verifica se limpa conta corrente se nome_conta_corrente estiver em branco" do
      @parcela = Parcela.new :baixando=>true,:data_vencimento => '06/04/2009',:conta =>pagamento_de_contas(:pagamento_cheque),:valor => 5000,:centro_multa_id=>centros(:centro_forum_social),:centro_desconto_id=>centros(:centro_forum_social),
        :centro_juros_id=>centros(:centro_forum_social),:unidade_organizacional_multa_id=>unidade_organizacionais(:sesi_colider_unidade_organizacional), :nome_conta_corrente => "", :conta_corrente_id => contas_correntes(:primeira_conta).id, :forma_de_pagamento => Parcela::BANCO
      
      @parcela.valid?
      @parcela.conta_corrente_id.should == nil
    end
    it 'tenta cancelar a parcela' do
      parcela = parcelas(:primeira_parcela_recebimento)
      quentin = usuarios(:quentin)
      lambda do
        lambda do
          parcela.cancelar(quentin,"Justificativa Teste")
        end.should change(parcela,:situacao).from(Parcela::PENDENTE).to(Parcela::CANCELADA)
      end.should change(parcela.conta,:valor_do_documento)
      HistoricoOperacao.last(:conditions=>{:usuario_id=>quentin}).descricao.should == "Parcela numero 1 cancelada - Vencimento: #{parcela.data_vencimento} - Valor: #{(parcela.valor/100.0).real.real_formatado}"
      HistoricoOperacao.last(:conditions=>{:usuario_id=>quentin}).justificativa.should == 'Justificativa Teste'
    end
  end
  
  it "teste se a situacao esta sendo gerada corretamente" do
    @parcela = parcelas(:primeira_parcela)
    @parcela.data_da_baixa = ""
    @parcela.situacao = 1
    @parcela.data_vencimento = Date.today
    @parcela.situacao.should == Parcela::PENDENTE
    @parcela.situacao_verbose.should == 'Vincenda'
    
    @parcela.reload
    @parcela = parcelas(:primeira_parcela)
    @parcela.data_da_baixa = ""
    @parcela.situacao = 1
    @parcela.data_vencimento = Date.today - 1
    @parcela.situacao.should == Parcela::PENDENTE
    @parcela.situacao_verbose.should == 'Em atraso'
    
    @parcela.reload
    @parcela = parcelas(:primeira_parcela)
    @parcela.data_vencimento = Date.today
    @parcela.data_da_baixa = Date.today - 1
    @parcela.situacao = 2
    @parcela.situacao.should == Parcela::QUITADA
    @parcela.situacao_verbose.should == 'Quitada'
    
    @parcela.reload
    @parcela = parcelas(:primeira_parcela)
    @parcela.data_vencimento = Date.today
    @parcela.data_da_baixa = Date.today + 10
    @parcela.situacao = 2
    @parcela.situacao.should == Parcela::QUITADA
    @parcela.situacao_verbose.should == 'Quitada'
    
    @parcela.reload
    @parcela = parcelas(:primeira_parcela)
    @parcela.situacao.should == Parcela::QUITADA
    @parcela.situacao_verbose.should == 'Quitada'
    
    @parcela.reload
    @parcela = parcelas(:segunda_parcela)
    @parcela.situacao.should == Parcela::PENDENTE
    @parcela.situacao_verbose.should == 'Em atraso'
    
    @parcela.reload
    @parcela = parcelas(:terceira_parcela)
    @parcela.situacao.should == Parcela::PENDENTE
    @parcela.situacao_verbose.should == 'Vincenda'
    @parcela.data_da_baixa = Date.today + 20
    @parcela.situacao = 2
    @parcela.situacao.should == Parcela::QUITADA
    @parcela.situacao_verbose.should == 'Quitada'

    @parcela.reload
    @parcela = parcelas(:primeira_parcela)
    @parcela.situacao = 3
    @parcela.save
    @parcela.situacao.should == Parcela::CANCELADA
    @parcela.situacao_verbose.should == 'Cancelada'
    @parcela.save
    @parcela.errors.on(:situacao).should == "da parcela é cancelada."
    
    @parcela.reload
    @parcela = parcelas(:primeira_parcela)
    @parcela.situacao = 2
    @parcela.situacao.should == Parcela::QUITADA
    @parcela.situacao_verbose.should == 'Quitada'
    @parcela.data_da_baixa = ""
    @parcela.situacao = 1
    @parcela.data_vencimento = Date.today - 1
    @parcela.situacao.should == Parcela::PENDENTE
    @parcela.situacao_verbose.should == 'Em atraso'
  end
  
  it "testa se o metodo retorna selecao esta retornando o valor correto" do
    lancamento_imposto = lancamento_impostos(:primeira)
    Parcela.retorna_selecao(lancamento_imposto.imposto_id).should == "#{lancamento_imposto.imposto_id}#5.0##{Imposto::RETEM}"
    Parcela.retorna_selecao(nil).should == ""
    imposto_id = "123456#1.5##{Imposto::INCIDE}"
    Parcela.retorna_selecao(imposto_id).should == "123456#1.5##{Imposto::INCIDE}"
  end
  
  it "testa se o metodo retorna data esta retornando o data correta" do
    lancamento_imposto = lancamento_impostos(:primeira)
    Parcela.retorna_data(lancamento_imposto.data_de_recolhimento).should == "04/04/2009"
    Parcela.retorna_data(nil).should == Date.today.to_s_br
  end
  
  
  it "Verifica se monta o hash corretamente" do
    imposto_id = impostos(:iss).id
    parcela = parcelas(:primeira_parcela)
    parcela.dados_do_imposto.should == {"1"=>{"data_de_recolhimento"=>"04/04/2009","valor_imposto"=>5.0, "aliquota"=>5.0, "imposto_id"=>imposto_id}}
  end
  
  it "Verifica se grava dados do imposto na parcela" do
    LancamentoImposto.delete_all
    lambda do
      imposto= impostos(:inss)
      conta = pagamento_de_contas(:pagamento_cheque)
      conta.valor_do_documento = 5001
      conta.numero_de_parcelas = 1
      conta.parcelas_geradas=false
      conta.numero_de_controle=nil
      conta.usuario_corrente = usuarios(:quentin)
      conta.ano_contabil_atual = 2009
      conta.save!
      conta.gerar_parcelas(2009)
      parcela = Parcela.last
      parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"10,80", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3.6"}}
      parcela.grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
    end.should change(LancamentoImposto, :count).by(1)
    LancamentoImposto.last.valor.should == 1080
  end
  
  it "Verifica se grava dados do imposto na parcela com hash vazio" do
    LancamentoImposto.delete_all
    lambda do
      imposto= impostos(:iss)
      parcela = Parcela.new  :data_vencimento=>'04-06-2009', :conta=> pagamento_de_contas(:pagamento_cheque), :valor=> 5001
      parcela.save!
      parcela.dados_do_imposto = {}
      parcela.grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
    end.should_not change(LancamentoImposto, :count)
  end
  
  
  it "Verifica se não grava dados do imposto na parcela" do
    LancamentoImposto.delete_all
    lambda do
      imposto = impostos(:iss)
      parcela = Parcela.new  :data_vencimento=>'04-06-2009', :conta=> pagamento_de_contas(:pagamento_cheque), :valor=> 5001
      parcela.save!
      parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"", "imposto_id"=>imposto.id.to_s, "valor_imposto"=>''},
        "2"=>{"data_de_recolhimento"=>"", "imposto_id"=>imposto.id.to_s, "valor_imposto"=>''}}
      parcela.grava_dados_do_imposto_na_parcela(2009).should == [false, ""]
    end.should_not change(LancamentoImposto, :count)
  end
  
  
  it "Verifica se não grava dados do imposto na parcela se a parcela estiver baixada" do
    LancamentoImposto.delete_all
    lambda do
      imposto = impostos(:iss)
      parcela = Parcela.new  :data_vencimento=>'04-06-2009', :conta=> pagamento_de_contas(:pagamento_cheque),:data_da_baixa=>'01-04-2009',:valor=> 5001, :valor_liquido=>5001, :forma_de_pagamento => 1
      parcela.save!
      parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"01-04-2009", "imposto_id"=>imposto.id.to_s},
        "2"=>{"data_de_recolhimento"=>"01-04-2009", "imposto_id"=>imposto.id.to_s}}
      parcela.grava_dados_do_imposto_na_parcela(2009).should == false
    end.should_not change(LancamentoImposto, :count)
  end

  it "Verifica se grava dados do imposto na parcela de uma conta com provisão e sem rateio" do
    imposto = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"2", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"100.00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    pagamento.gerar_parcelas(2009)
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 4 do
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"10.00", "aliquota"=>"5.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"5.00", "aliquota"=>"5.0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end
    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    credito_imposto = movimento.itens_movimentos[1]
    credito_imposto_2 = movimento.itens_movimentos[2]
    credito_fornecedor = movimento.itens_movimentos[3]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    credito_imposto.plano_de_conta.should == Imposto.find_by_id(imposto.id).conta_credito
    credito_imposto_2.plano_de_conta.should == Imposto.find_by_id(imposto.id).conta_credito
    credito_fornecedor.plano_de_conta.should == pagamento.conta_contabil_pessoa
  end

  it "Verifica se grava dados do imposto na parcela de uma conta com provisão e com rateio" do
    imposto = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"2", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"100.00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    pagamento.gerar_parcelas(2009)
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 4 do
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"10,00", "aliquota"=>"5,00"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"5,00", "aliquota"=>"5,00"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      end
    end
  end

  it "teste de atributo protegido dados_do_imposto" do
    @parcela = Parcela.new
    @parcela.dados_do_imposto.should == {}
    @nova_parcela = Parcela.new :dados_do_imposto=>"teste"
    @nova_parcela.dados_do_imposto.should == {}
    @nova_parcela.dados_do_imposto = "teste"
    @nova_parcela.dados_do_imposto.should == "teste"
  end
  
  it "teste que verifica se soma os impostos da parcela" do
    parcela = parcelas(:primeira_parcela)
    parcela.soma_impostos_da_parcela.should == 500
    parcela.calcula_valor_liquido_da_parcela.should == 2833
  end
  
  it "verifica se o sistuação verbose retorna as situações corretas" do
    parcela = parcelas(:primeira_parcela)
    parcela.situacao_verbose.should == 'Quitada'
    parcela = parcelas(:segunda_parcela)
    parcela.situacao_verbose.should == 'Em atraso'
    parcela = parcelas(:terceira_parcela)
    parcela.situacao_verbose.should == 'Vincenda'
  end

  it "consegue estornar, mesmo com o cheque já baixado" do
    imposto= impostos(:inss)
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    Movimento.delete_all
    ItensMovimento.delete_all
    assert_difference 'Movimento.count',1 do
      assert_difference 'ItensMovimento.count',2 do
        conta.gerar_parcelas(2009)
      end
    end
    parcela = Parcela.last
    parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"10,80", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3.6"}}
    assert_difference 'ItensMovimento.count', 1 do
      parcela.grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      parcela.reload
    end
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = 3
    parcela.ano_contabil_atual = 2009
    cheque=parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/06/2010'
    cheque.nome_do_titular = "teste"
    cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque.prazo = Cheque::VISTA
    assert_difference 'Movimento.count',1 do
      parcela.save!
    end
    cheque.situacao = 4
    cheque.save!
    nova_parcela = Parcela.find_by_id(parcela.id)
    nova_parcela.estorna_parcela(usuario,"teste").should == [true, "Parcela estornada com sucesso!"]
  end
  
  it "Verifica se estorna parcela grava registro no follow-up" do
    imposto= impostos(:inss)
    usuario = usuarios(:quentin)
    conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas = false
    conta.numero_de_controle = nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    conta.gerar_parcelas(2009)

    Movimento.delete_all
    ItensMovimento.delete_all
    parcela = Parcela.last

    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = Parcela::CHEQUE
    parcela.ano_contabil_atual = 2009
    cheque = parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/06/2010'
    cheque.nome_do_titular = "teste"
    cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque.prazo = Cheque::VISTA
    assert_difference 'Movimento.count',1 do
      parcela.save!
    end
    
    nova_parcela = Parcela.find_by_id(parcela.id)
    
    assert_difference 'Movimento.count',-1 do
      assert_difference 'Cheque.count', -1 do
        assert_difference 'HistoricoOperacao.count', 1 do
          nova_parcela.estorna_parcela(usuario,"teste")
          historico_operacao = conta.historico_operacoes.last
          historico_operacao.descricao.should == "Parcela 1 estornada"
          historico_operacao.usuario = usuarios(:quentin)
          historico_operacao.conta = conta
        end
      end
    end

    nova_parcela.data_da_baixa.should == nil
    nova_parcela.valor_liquido.should == 0
    nova_parcela.historico == nil
  end
  
  it "Verifica se estorna parcela pagamento cartao" do
    imposto= impostos(:inss)
    usuario = usuarios(:quentin)
    conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    conta.gerar_parcelas(2009)

    Movimento.delete_all
    ItensMovimento.delete_all
    parcela = Parcela.last

    parcela.baixar_dr = false
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = Parcela::CARTAO
    cartao= parcela.cartoes.build
    cartao.validade = "03/12"
    cartao.bandeira = 1
    cartao.numero = 2098348923
    cartao.codigo_de_seguranca = 234
    cartao.nome_do_titular = "Paulo"
    
    assert_difference 'Movimento.count', 0 do
      parcela.save!
    end
    
    nova_parcela = Parcela.find_by_id(parcela.id)
    assert_difference 'Movimento.count', 0 do
      assert_difference 'Cartao.count', -1 do
        nova_parcela.estorna_parcela(usuario,"teste")
      end
    end
    
    nova_parcela.data_da_baixa.should == nil
    nova_parcela.valor_liquido.should == 0
    nova_parcela.historico == nil
    nova_parcela.situacao.should == Parcela::PENDENTE
    nova_parcela.situacao_verbose.should == 'Em atraso'
    
  end
  
  it "Verifica se estorna parcela grava com forma de pagamento em banco e limpa esses campos" do
    imposto= impostos(:inss)
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    assert_difference 'Movimento.count',1 do
      assert_difference 'ItensMovimento.count',2 do
        conta.gerar_parcelas(2009)
      end
    end
    Movimento.delete_all
    ItensMovimento.delete_all
    parcela = Parcela.last
    parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"10,80", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3.6"}}
    assert_difference 'ItensMovimento.count', 3 do
      parcela.grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
    end
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = 1
    parcela.ano_contabil_atual = 2009
    assert_difference 'Movimento.count',1 do
      parcela.save!
    end
    parcela = Parcela.last
    parcela.forma_de_pagamento =2
    assert_difference 'Movimento.count',-1 do
      parcela.estorna_parcela(usuario,justificativa)
    end
    parcela.data_da_baixa.should == nil
    parcela.valor_liquido.should == 0
    parcela.historico == nil
    parcela.conta_corrente.should == nil
    parcela.data_do_pagamento.should == nil
    parcela.numero_do_comprovante.should == nil
    parcela.observacoes.should == nil
    parcela.situacao.should == Parcela::PENDENTE
    parcela.situacao_verbose.should == 'Em atraso'
  end
  
  
  
  it "Varifica se não estorna a parcela caso o usuario tente estornar uma parcela que não esteja baixada" do
    lambda do
      parcela = parcelas(:segunda_parcela)
      usuario = usuarios(:quentin)
      justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
      parcela.estorna_parcela(usuario,justificativa).should == [false, ""]
      parcela.data_da_baixa.should == nil
      parcela.valor_liquido.should == nil
      parcela.historico == nil
      parcela.situacao.should == Parcela::PENDENTE
      parcela.situacao_verbose.should == 'Em atraso'
    end.should_not change(HistoricoOperacao ,:count)
  end
  
  def test_data_br_field
    assert_equal '06/04/2009', parcelas(:primeira_parcela).data_vencimento
  end
  
  
  describe "testes referente a baixa na parcela" do
    it "testa o método lancamento_contabil_de_baixa_da_parcela quando não há lancamentos de multa,descontos entre outros" do
      ItensMovimento.delete_all
      old_count_itens_movimento = ItensMovimento.count
      @parcela = parcelas(:segunda_parcela)
      @parcela.dados_do_imposto=nil
      @parcela.lancamento_impostos =[]
      @parcela.retencao =0
      @parcela.save
      @parcela.data_da_baixa = "25/07/2009"
      @parcela.historico = "teste"
      @parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count', 1 do
        @parcela.lancamento_contabil_de_baixa_da_parcela
      end
      @movimento = Movimento.last
      @movimento.historico.should == "teste"
      @movimento.numero_da_parcela.should == @parcela.numero.to_i
      @movimento.provisao.should == 0
      @movimento.data_lancamento.should == @parcela.data_da_baixa
      ItensMovimento.count.should == old_count_itens_movimento + 2
      itens = ItensMovimento.all
      itens.each do |item|
        item.valor.should == @parcela.valor
        item.unidade_organizacional.should == @parcela.conta.unidade_organizacional
        item.centro.should == @parcela.conta.centro
      end
      itens.first.tipo.should == "D"
      itens.first.valor.should == @parcela.valor
      itens.first.plano_de_conta.should == @parcela.conta.conta_contabil_pessoa
      itens.last.tipo.should == "C"
      itens.last.valor.should == @parcela.valor
    end
    
    it "testa o método lancamento_contabil_de_baixa_da_parcela quando não há lancamentos de multa,descontos entre outros BAIXA EM BANCO" do
      ItensMovimento.delete_all
      old_count_itens_movimento = ItensMovimento.count
      conta_corrente = contas_correntes(:segunda_conta)
      @parcela = parcelas(:segunda_parcela)
      @parcela.dados_do_imposto=nil
      @parcela.lancamento_impostos =[]
      @parcela.retencao =0
      @parcela.save!
      @parcela.data_da_baixa = "25/07/2009"
      @parcela.historico = "teste"
      @parcela.forma_de_pagamento = 2
      @parcela.conta_corrente = conta_corrente
      @parcela.data_do_pagamento = Date.today
      @parcela.observacoes= "teste"
      @parcela.numero_do_comprovante = "23456767886542213457"
      @parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count', 1 do
        @parcela.lancamento_contabil_de_baixa_da_parcela
      end
      @movimento = Movimento.last
      @movimento.historico.should == "teste"
      @movimento.numero_da_parcela.should == @parcela.numero.to_i
      @movimento.provisao.should == 0
      @movimento.data_lancamento.should == @parcela.data_da_baixa
      ItensMovimento.count.should == old_count_itens_movimento + 2
      itens = ItensMovimento.all
      itens.each do |item|
        item.valor.should == @parcela.valor
        item.unidade_organizacional.should == @parcela.conta.unidade_organizacional
        item.centro.should == @parcela.conta.centro
      end
      itens.first.tipo.should == "D"
      itens.first.valor.should == @parcela.valor
      itens.first.plano_de_conta.should == @parcela.conta.conta_contabil_pessoa
      itens.last.tipo.should == "C"
      itens.last.plano_de_conta.should == conta_corrente.conta_contabil
      itens.last.valor.should == @parcela.valor
    end
    
    it "testa o método lancamento_contabil_de_baixa_da_parcela quando há lancamentos de multa,descontos entre outros" do
      ItensMovimento.delete_all
      @parcela = parcelas(:primeira_parcela)
      @parcela.historico = "teste"
      @parcela.dados_do_imposto=nil
      @parcela.lancamento_impostos =[]
      @parcela.baixando = true
      @parcela.save
      @parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 6 do          
          @parcela.lancamento_contabil_de_baixa_da_parcela
        end
      end
      itens = ItensMovimento.all
      itens.first.tipo.should == "D"
      itens.first.valor.should == @parcela.valor_da_multa
      itens.first.centro.should == @parcela.centro_multa
      itens.first.unidade_organizacional.should == @parcela.unidade_organizacional_multa
      itens.first.plano_de_conta.should == @parcela.conta_contabil_multa
      itens[1].tipo.should == "D"
      itens[1].valor.should == @parcela.valor_dos_juros
      itens[1].centro.should == @parcela.centro_juros
      itens[1].unidade_organizacional.should == @parcela.unidade_organizacional_juros
      itens[1].plano_de_conta.should == @parcela.conta_contabil_juros
      itens[2].tipo.should == "D"
      itens[2].valor.should == @parcela.outros_acrescimos
      itens[2].centro.should == @parcela.centro_outros
      itens[2].unidade_organizacional.should == @parcela.unidade_organizacional_outros
      itens[2].plano_de_conta.should == @parcela.conta_contabil_outros
      itens[4].tipo.should == "C"
      itens[4].valor.should == @parcela.valor_do_desconto
      itens[4].centro.should == @parcela.centro_desconto
      itens[4].unidade_organizacional.should == @parcela.unidade_organizacional_desconto
      itens[4].plano_de_conta.should == @parcela.conta_contabil_desconto
      itens[5].tipo.should == "C"
      soma = @parcela.valor + @parcela.valor_da_multa + @parcela.outros_acrescimos+ @parcela.valor_dos_juros - @parcela.valor_do_desconto
      itens[5].valor.should == soma
      itens[5].centro.should == @parcela.conta.centro
      itens[5].unidade_organizacional.should == @parcela.conta.unidade_organizacional
      itens[5].plano_de_conta.should ==  contas_correntes(:segunda_conta).conta_contabil
    end
    
    it "faz teste de baixa quando existe retencao e teste de lancamento de impostos calculados automaticamente" do
      imposto= impostos(:inss)
      usuario = usuarios(:quentin)
      conta = pagamento_de_contas(:pagamento_cheque)
      conta.valor_do_documento = 3327
      conta.numero_de_parcelas = 1
      conta.parcelas_geradas=false
      conta.numero_de_controle=nil
      conta.usuario_corrente = usuario
      conta.ano_contabil_atual = 2009
      conta.save!
      assert_difference 'Movimento.count',1 do
        assert_difference 'ItensMovimento.count',2 do
          conta.gerar_parcelas(2009)
        end
      end
      Movimento.delete_all
      ItensMovimento.delete_all
      parcela = Parcela.last
      parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"1,20", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3.6"}}
      assert_difference 'ItensMovimento.count', 3 do
        parcela.grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      end
      
      movimento_imposto = Movimento.last
      itens_movimento_imposto = movimento_imposto.itens_movimentos
      itens_movimento_imposto[0].tipo.should == "D"
      itens_movimento_imposto[0].valor.should == 3327
      itens_movimento_imposto[0].plano_de_conta.should == conta.conta_contabil_pessoa
      itens_movimento_imposto[1].tipo.should == "C"
      
      itens_movimento_imposto[1].plano_de_conta.should == imposto.conta_credito
      itens_movimento_imposto[1].valor.should == 120
      itens_movimento_imposto[2].tipo.should == "C"
      itens_movimento_imposto[2].plano_de_conta.should == conta.conta_contabil_pessoa
      itens_movimento_imposto[2].valor.should == 3207
      
      parcela.data_da_baixa = '05/05/2010'
      parcela.baixando = true
      parcela.historico = parcela.conta.historico
      parcela.forma_de_pagamento = 1
      parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count',1 do
        parcela.save!
      end
      movimento = Movimento.last
      itens_movimento = movimento.itens_movimentos
      itens_movimento[0].tipo.should == "D"
      itens_movimento[0].valor.should == 3207
      itens_movimento[0].plano_de_conta.should == conta.conta_contabil_pessoa
      itens_movimento[1].tipo.should == "C"
      itens_movimento[1].valor.should == 3207
      conta=ContasCorrente.find_by_unidade_id_and_identificador(conta.unidade_id,0)
      itens_movimento[1].plano_de_conta.should == conta.conta_contabil
    end
    
    it "faz teste de baixa quando existe retencao e teste de lancamento de impostos calculados manualmente" do
      imposto= impostos(:inss)
      usuario = usuarios(:quentin)
      conta = pagamento_de_contas(:pagamento_cheque)
      conta.valor_do_documento = 3327
      conta.numero_de_parcelas = 1
      conta.parcelas_geradas=false
      conta.numero_de_controle=nil
      conta.usuario_corrente = usuario
      conta.ano_contabil_atual = 2009
      conta.save!
      
      assert_difference 'Movimento.count', 1 do
        assert_difference 'ItensMovimento.count', 2 do
          conta.gerar_parcelas(2009)
        end
      end

      Movimento.delete_all
      ItensMovimento.delete_all
      parcela = Parcela.last
      parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"10,80", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3.6"}}
      assert_difference 'ItensMovimento.count', 3 do
        parcela.grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
      end

      movimento_imposto = Movimento.last
      itens_movimento_imposto = movimento_imposto.itens_movimentos
      itens_movimento_imposto[0].tipo.should == "D"
      itens_movimento_imposto[0].valor.should == 3327
      itens_movimento_imposto[0].plano_de_conta.should == conta.conta_contabil_pessoa
      itens_movimento_imposto[1].tipo.should == "C"
      
      itens_movimento_imposto[1].plano_de_conta.should == imposto.conta_credito
      itens_movimento_imposto[1].valor.should == 1080
      itens_movimento_imposto[2].tipo.should == "C"
      itens_movimento_imposto[2].plano_de_conta.should == conta.conta_contabil_pessoa
      itens_movimento_imposto[2].valor.should == 2247
      
      parcela.data_da_baixa = '05/05/2010'
      parcela.baixando = true
      parcela.historico = parcela.conta.historico
      parcela.forma_de_pagamento = 1
      parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count',1 do
        parcela.save!
      end
      movimento = Movimento.last
      itens_movimento = movimento.itens_movimentos
      itens_movimento[0].tipo.should == "D"
      itens_movimento[0].valor.should == 2247
      itens_movimento[0].plano_de_conta.should == conta.conta_contabil_pessoa
      itens_movimento[1].tipo.should == "C"
      itens_movimento[1].valor.should == 2247
      conta=ContasCorrente.find_by_unidade_id_and_identificador(conta.unidade_id,0)
      itens_movimento[1].plano_de_conta.should == conta.conta_contabil
    end
    
    it "teste de lançamento contábil para rateio e impostos" do
      Parcela.delete_all
      Rateio.delete_all
      imposto = impostos(:inss)
      @conta = pagamento_de_contas(:pagamento_cheque)
      @conta.usuario_corrente = usuarios(:quentin)
      @conta.parcelas_geradas = false
      @conta.ano_contabil_atual = 2009
      @conta.save!

      assert_difference 'Movimento.count',3 do
        assert_difference 'ItensMovimento.count',6 do
          @conta.gerar_parcelas(2009)
        end
      end
      
      @primeira_parcela = Parcela.first
      @primeira_parcela.dados_do_rateio = {"1"=>{"centro_nome"=>"4567456344 - Forum Serviço Economico", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_economico).id.to_s, "valor"=>"23.34", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id,"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI","centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"10.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id.to_s}
      }
      assert_difference 'ItensMovimento.count',1 do
        @primeira_parcela.grava_itens_do_rateio(2009, @conta.usuario_corrente)
      end

      movimento = @primeira_parcela.movimentos.first
      itens_movimento = movimento.itens_movimentos
      itens_movimento[0].valor.should == 2334
      itens_movimento[0].tipo.should == "D"
      itens_movimento[0].centro.should == centros(:centro_forum_economico)
      itens_movimento[0].unidade_organizacional.should == unidade_organizacionais(:senai_unidade_organizacional)
      itens_movimento[0].plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      
      itens_movimento[1].valor.should == 1000
      itens_movimento[1].tipo.should == "D"
      itens_movimento[1].centro.should == centros(:centro_forum_financeiro)
      itens_movimento[1].unidade_organizacional.should == unidade_organizacionais(:senai_unidade_organizacional)
      itens_movimento[1].plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
      
      itens_movimento[2].valor.should == 3334
      itens_movimento[2].tipo.should == "C"
      itens_movimento[2].centro.should == @conta.centro
      itens_movimento[2].unidade_organizacional.should == @conta.unidade_organizacional
      itens_movimento[2].plano_de_conta.should == @conta.conta_contabil_despesa
    end
    
    it "testa lancamento_contabil quando não existe conta contabil vinculado ao imposto" do
      imposto = impostos(:inss)
      imposto.conta_credito = nil
      imposto.save false
      usuario = usuarios(:quentin)
      conta = pagamento_de_contas(:pagamento_cheque)
      conta.valor_do_documento = 3327
      conta.numero_de_parcelas = 1
      conta.parcelas_geradas = false
      conta.numero_de_controle = nil
      conta.usuario_corrente = usuario
      conta.ano_contabil_atual = 2009
      conta.rateio = PagamentoDeConta::NAO
      conta.save!
      assert_difference 'Movimento.count',1 do
        assert_difference 'ItensMovimento.count',2 do
          assert_difference 'HistoricoOperacao.count', 1 do
            conta.gerar_parcelas(2009)
            historico_operacao = conta.historico_operacoes.last
            historico_operacao.descricao.should == "Geradas 1 parcelas"
            historico_operacao.usuario = usuarios(:quentin)
            historico_operacao.conta = conta
          end
        end
      end
      parcela = Parcela.last
      parcela.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"10,80", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3,60"}}
      parcela.grava_dados_do_imposto_na_parcela(2009).first.should == false
    end

    it "testa lancamento_contabil para recebimento de contas simples sem rateio" do
      Parcela.delete_all
      Rateio.delete_all
      @conta_a_receber = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @conta_a_receber.usuario_corrente = usuarios(:quentin)
      @conta_a_receber.save!
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta_a_receber.gerar_parcelas(2009)
        historico_operacao = @conta_a_receber.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 1 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta_a_receber
      end
      @parcela = Parcela.last
      @parcela.data_da_baixa = '05/05/2010'
      @parcela.baixando = true
      @parcela.historico = @parcela.conta.historico
      @parcela.forma_de_pagamento = 1
      @parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count',1 do
        assert_difference 'ItensMovimento.count',2 do
          @parcela.save!
        end
      end
      movimento = Movimento.last
      itens = movimento.itens_movimentos
      itens[0].tipo.should == "D"
      itens[0].valor.should == 1000
      itens[0].plano_de_conta.should == contas_correntes(:conta_caixa).conta_contabil
      itens[1].tipo.should == "C"
      itens[1].valor.should == 1000
      itens[1].plano_de_conta.should == @conta_a_receber.conta_contabil_receita
    end
    
    it "testa lancamento_contabil para recebimento de contas com rateio" do
      Parcela.delete_all
      Rateio.delete_all
      
      @conta_a_receber = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @conta_a_receber.usuario_corrente = usuarios(:quentin)
      @conta_a_receber.save!
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta_a_receber.gerar_parcelas(2009)
        historico_operacao = @conta_a_receber.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 1 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta_a_receber
      end
      @parcela = Parcela.last
      
      @parcela.dados_do_rateio= { "1" => {"centro_nome" => "34567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Sesi Matriz", "centro_id" => centros(:centro_forum_economico).id.to_s, "valor"=>"6,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2"=>{"centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"4,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_passivo_a_pagar).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"}}
      @parcela.grava_itens_do_rateio(2009, @conta_a_receber.usuario_corrente)
      @parcela.data_da_baixa = '05/05/2010'
      @parcela.baixando = true
      @parcela.historico = @parcela.conta.historico
      @parcela.valor_dos_juros = 100
      @parcela.conta_contabil_juros = plano_de_contas(:plano_de_contas_ativo_despesas_senai)
      @parcela.unidade_organizacional_juros = @conta_a_receber.unidade_organizacional
      @parcela.centro_juros = @conta_a_receber.centro
      @parcela.forma_de_pagamento = 1
      @parcela.ano_contabil_atual = 2009
      assert_difference 'Movimento.count',1 do
        assert_difference 'ItensMovimento.count',4 do
          @parcela.save!
        end
      end
      movimento = Movimento.last
      itens_movimento = movimento.itens_movimentos
      itens_movimento[0].tipo.should == "D"
      itens_movimento[0].valor.should == 1100
      
      itens_movimento[1].tipo.should == "C"
      itens_movimento[1].valor.should == 100
      itens_movimento[1].plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_despesas_senai)
      
      itens_movimento[2].tipo.should == "C"
      itens_movimento[2].valor.should == 600
      itens_movimento[2].plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_conta_bancaria)
      
      itens_movimento[3].tipo.should == "C"
      itens_movimento[3].valor.should == 400
      itens_movimento[3].plano_de_conta.should == plano_de_contas(:plano_de_contas_passivo_a_pagar)
    end
  end
  
  it 'deve validar unidade organizacional e centro' do
    @parcela = parcelas(:primeira_parcela)
    @parcela.unidade_organizacional_desconto = unidade_organizacionais(:senai_unidade_organizacional)
    @parcela.centro_desconto = centros(:centro_forum_social)
    @parcela.should_not be_valid
    @parcela.errors.on(:centro_desconto).should == "pertence a outra Unidade Organizacional."
    
    @parcela.reload
    @parcela.unidade_organizacional_juros = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_juros = centros(:centro_forum_economico)
    @parcela.should_not be_valid
    @parcela.errors.on(:centro_juros).should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."]
    
    @parcela.reload
    @parcela.unidade_organizacional_desconto = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_desconto = centros(:centro_forum_financeiro)
    @parcela.unidade_organizacional_juros = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_juros = centros(:centro_forum_economico)
    @parcela.unidade_organizacional_multa = unidade_organizacionais(:senai_unidade_organizacional)
    @parcela.centro_multa = centros(:centro_forum_social)
    @parcela.unidade_organizacional_outros = unidade_organizacionais(:senai_unidade_organizacional)
    @parcela.centro_outros = centros(:centro_forum_social)
    @parcela.should_not be_valid
    @parcela.errors.on(:centro_desconto).should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."]
    @parcela.errors.on(:centro_juros).should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."]
    @parcela.errors.on(:centro_multa).should == "pertence a outra Unidade Organizacional."
    @parcela.errors.on(:centro_outros).should == "pertence a outra Unidade Organizacional."
    
    @parcela.reload
    @parcela.unidade_organizacional_desconto = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_desconto = centros(:centro_forum_social)
    @parcela.unidade_organizacional_juros = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_juros = centros(:centro_forum_social)
    @parcela.unidade_organizacional_multa = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_multa = centros(:centro_forum_social)
    @parcela.unidade_organizacional_outros = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @parcela.centro_outros = centros(:centro_forum_social)
    @parcela.should be_valid
  end
  
  
  it "teste do método pode_estornar_parcela?" do
    parcela = parcelas(:segunda_parcela)
    parcela.pode_estornar_parcela?.should == false
    parcela.data_da_baixa = '22/09/2009'
    parcela.historico="teste"
    parcela.forma_de_pagamento = Parcela::DINHEIRO
    parcela.valor_liquido=parcela.valor
    parcela.save!
    parcela.pode_estornar_parcela?.should == true
    parcela.data_da_baixa = '22/09/2009'
    parcela.historico="teste"
    parcela.forma_de_pagamento = Parcela::CHEQUE
    parcela.valor_liquido=parcela.valor
    cheque=parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/06/2010'
    cheque.nome_do_titular = "teste"
    cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque.prazo = Cheque::VISTA
    parcela.save!
    parcela.pode_estornar_parcela?.should == true
    cheque.situacao = Cheque::ABANDONADO
    parcela.save!
    parcela.pode_estornar_parcela?.should == true
  end

  it "pode estornar parcela para parcelas CANCELADAS" do
    parcela = parcelas(:primeira_parcela)
    parcela.pode_estornar_parcela?.should == true
    parcela.situacao = Parcela::CANCELADA
    parcela.save false
    parcela.reload

    parcela.pode_estornar_parcela?.should == false
  end

  it "pode estornar parcela para parcelas RENEGOCIADAS" do
    parcela = parcelas(:primeira_parcela)
    parcela.pode_estornar_parcela?.should == true
    parcela.situacao = Parcela::RENEGOCIADA
    parcela.save false
    parcela.reload

    parcela.pode_estornar_parcela?.should == false
  end

  it "pode baixar parcela renegociada" do
    parcela = parcelas(:segunda_parcela)
    parcela.situacao = Parcela::RENEGOCIADA
    parcela.save false

    parcela.data_da_baixa = Date.today.strftime("%d/%m/%Y")
    parcela.baixando = true
    parcela.historico = "Baixando..."
    parcela.save.should == false
    parcela.reload
    parcela.errors.full_messages.should == ["Situacao da parcela é renegociada."]
    parcela.situacao.should == Parcela::RENEGOCIADA
  end
  
  it "Verifica se valida os dados antes de salvar" do
    imposto = impostos(:ipi).id.to_s
    @parcela = Parcela.new :data_vencimento=>'04-06-2009', :conta => pagamento_de_contas(:pagamento_cheque), :valor=> 5001
    @parcela.save
    @parcela.dados_do_imposto = {"1"=>{"imposto_id"=>imposto,"valor_imposto"=>"20.00", "aliquota"=>"50","data_de_recolhimento"=>"01/01/2009"},
      "2"=>{"imposto_id"=>imposto,"valor_imposto"=>"20.00", "aliquota"=>"50","data_de_recolhimento"=>"01/02/2009"},
      "3"=>{"imposto_id"=>imposto,"valor_imposto"=>"20.00", "aliquota"=>"50","data_de_recolhimento"=>"01/03/2009"}}
    @parcela.grava_dados_do_imposto_na_parcela(2009)
    @parcela.errors.on(:base).should == "Valor dos impostos maior que o valor da parcela. Impossível salvar por favor verifique."
  end
  
  it "Verifica se lanca excessão antes de salvar impostos caso haja impostos menores que 1" do
    imposto = impostos(:iss).id.to_s
    @parcela = Parcela.new :data_vencimento=>'04-06-2009', :conta => pagamento_de_contas(:pagamento_cheque), :valor=> 5001
    @parcela.save
    @parcela.dados_do_imposto = {"1"=>{"imposto_id"=>imposto,"valor_imposto"=>"5.00", "aliquota"=>"5","data_de_recolhimento"=>"01/01/2009"},
      "2"=>{"imposto_id"=>imposto,"valor_imposto"=>"-5.00", "aliquota"=>"5","data_de_recolhimento"=>"01/02/2009"},
      "3"=>{"imposto_id"=>imposto,"valor_imposto"=>"5.00", "aliquota"=>"5","data_de_recolhimento"=>"01/03/2009"}}
    @parcela.grava_dados_do_imposto_na_parcela(2009)
    @parcela.errors.on(:base).should == "Valor deve ser maior do que zero."
  end
  
  it "Verifica se lanca excessão antes de salvar impostos caso a soma dos impostos seja igual ao valor da parcela" do
    imposto = impostos(:ipi).id.to_s
    @parcela = Parcela.new :data_vencimento=>'04-06-2009', :conta => pagamento_de_contas(:pagamento_cheque), :valor=> 5001
    @parcela.save
    @parcela.dados_do_imposto = {"1"=>{"imposto_id"=>imposto, "valor_imposto"=>"25.00", "aliquota"=>"50", "data_de_recolhimento"=>"01/01/2009"},
      "2"=>{"imposto_id"=>imposto, "valor_imposto"=>"25.01", "aliquota"=>"50", "data_de_recolhimento"=>"01/02/2009"}}
    @parcela.grava_dados_do_imposto_na_parcela(2009)
    @parcela.errors.on(:base).should == "O valor da soma dos impostos deve ser menor que o valor da parcela. Por favor verifique."
  end

  
  it "não permite fazer baixa de cheque a vista se não houver conta caixa cadastrada" do
    ContasCorrente.delete_all
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    parcela = Parcela.last
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = 3
    parcela.ano_contabil_atual = 2009
    cheque=parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/05/2010'
    cheque.nome_do_titular = "teste"
    parcela.should_not be_valid
    parcela.errors.on(:base).should ==  "É preciso cadastrar um conta caixa para efetuar a baixa de cheques à vista."
  end
  
  
  it "não permite fazer baixa de cheque a pre-datado se a data para depósito for menor que a data da baixa" do
    ContasCorrente.delete_all
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    parcela = Parcela.last
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = 3
    cheque=parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/04/2010'
    cheque.nome_do_titular = "teste"
    parcela.should_not be_valid
    parcela.errors.on(:base).should ==  "A data para depósito do cheque deve ser maior ou igual a data da baixa"
  end
  
  it "teste de lancamento contabil para cheques pre-datados" do
    # Regra de Negócio: Cheques pré devem ser lançados na hora da baixa na conta que é escolhida
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    parcela = Parcela.last
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = 3
    parcela.ano_contabil_atual = 2009
    cheque=parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta_contabil_transitoria = plano_de_contas(:plano_de_contas_ativo_despesas)
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/08/2010'
    cheque.nome_do_titular = "teste"
    cheque.prazo = Cheque::VISTA
    assert_difference 'Movimento.count',1 do
      parcela.save!
    end
    movimento = Movimento.last
    itens = movimento.itens_movimentos
    itens.last.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_despesas)
    itens.last.tipo.should == "C"
  end
  it "teste de lançamento contábil à vista" do
    # Regra de Negócio: Deve ser lancado direto no caixa
    
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    caixa= ContasCorrente.find_by_unidade_id_and_identificador(conta.unidade.id,0).conta_contabil
    
    justificativa = 'Ocorreu um engano. e foi baixada a parcela errada!'
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas=false
    conta.numero_de_controle=nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    parcela = Parcela.last
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = parcela.conta.historico
    parcela.forma_de_pagamento = 3
    parcela.ano_contabil_atual = 2009
    cheque=parcela.cheques.build
    cheque.banco = Banco.first
    cheque.agencia = "teste"
    cheque.conta_contabil_transitoria = caixa
    cheque.conta = "teste"
    cheque.numero = "teste"
    cheque.data_para_deposito = '05/05/2010'
    cheque.nome_do_titular = "teste"
    cheque.prazo = Cheque::VISTA
    assert_difference 'Movimento.count',1 do
      parcela.save!
    end
    movimento = Movimento.last
    itens = movimento.itens_movimentos
    itens.last.plano_de_conta.should == caixa
    itens.last.tipo.should == "C"
  end
  
  describe 'Relatório para totalização' do
    it "testa o método relatorio_para_totalizacao de recebimentos" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"1", "periodo" => "vencimento"}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::QUITADA]], :include => [:conta => :servico]).and_return(
        parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebida_em_cartao, :primeira_parcela_recebida_cheque_a_vista, :primeira_parcela_recebida_em_cartao, :primeira_parcela_recebida_cheque_a_prazo, :segunda_parcela_recebimento))
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebida_em_cartao, :primeira_parcela_recebida_cheque_a_vista, :primeira_parcela_recebida_em_cartao, :primeira_parcela_recebida_cheque_a_prazo, :segunda_parcela_recebimento)
    end

    it 'contar todos os recebimentos' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"1", "periodo" => "vencimento"}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::QUITADA]], :include => [:conta => :servico]).and_return(6)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 6
    end

    it "testa o método relatorio_para_totalizacao a receber com situacao TODAS" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => "Todas"}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::PENDENTE, Parcela::QUITADA, Parcela::CANCELADA, Parcela::RENEGOCIADA, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA]], :include => [:conta => :servico]).and_return(parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebimento))
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebimento)
    end

    it 'contar todos os recebimentos a receber com situação TODAS' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => "Todas"}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::PENDENTE, Parcela::QUITADA, Parcela::CANCELADA, Parcela::RENEGOCIADA, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA]], :include => [:conta => :servico]).and_return(2)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 2
    end

    it "testa o método relatorio_para_totalizacao a receber com situacao NORMAL" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => 'Todas - Exceto Jurídico'}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::PENDENTE, Parcela::QUITADA, Parcela::CANCELADA, Parcela::RENEGOCIADA, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA]], :include => [:conta => :servico]).and_return(
        parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebida_em_cartao, :primeira_parcela_recebida_cheque_a_vista, :primeira_parcela_recebida_em_cartao,
          :primeira_parcela_recebida_cheque_a_prazo, :segunda_parcela_recebimento))
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebida_em_cartao, :primeira_parcela_recebida_cheque_a_vista, :primeira_parcela_recebida_em_cartao,
        :primeira_parcela_recebida_cheque_a_prazo, :segunda_parcela_recebimento)
    end

    it 'contar todos os recebimentos a receber com situação NORMAL' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => 'Em Atraso'}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?) AND parcelas.data_vencimento < ?',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA], Date.today], :include => [:conta => :servico]).and_return(6)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 6
    end

    it "testa o método relatorio_para_totalizacao a receber com situacao CANCELADA" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => 'Permuta'}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::PERMUTA]], :include => [:conta => :servico]).and_return([])
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == []
    end

    it 'contar todos os recebimentos a receber com situação CANCELADA' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => 'Baixa no Conselho'}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::BAIXA_DO_CONSELHO]], :include => [:conta => :servico]).and_return(0)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 0
    end

    it "testa o método relatorio_para_totalizacao a receber com situacao RENEGOCIADA" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => 'Jurídico'}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::JURIDICO]], :include => [:conta => :servico]).and_return([])
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == []
    end

    it 'contar todos os recebimentos a receber com situação RENEGOCIADA' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"2", "periodo" => "vencimento", "situacao" => 'Desconto em Folha'}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::DESCONTO_EM_FOLHA]], :include => [:conta => :servico]).and_return(0)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 0
    end

    it "testa o método relatorio_para_totalizacao com atraso" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"3", "periodo" => "vencimento"}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND (parcelas.situacao = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_da_baixa > parcelas.data_vencimento)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::QUITADA]], :include => [:conta => :servico]).and_return([])
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == []
    end

    it 'contar todos os recebimentos com atraso' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"3", "periodo" => "vencimento"}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND (parcelas.situacao = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_da_baixa > parcelas.data_vencimento)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), [Parcela::QUITADA]], :include => [:conta => :servico]).and_return(0)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 0
    end

    it "testa o método relatorio_para_totalizacao com inadimplencia" do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"4", "periodo" => "vencimento"}
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND (parcelas.situacao = ?) AND (parcelas.data_vencimento < ?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), Parcela::PENDENTE, Date.today], :include => [:conta => :servico]).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = Parcela.relatorio_para_totalizacao(:all, unidades(:senaivarzeagrande).id, params)
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end

    it 'contar todos os recebimentos com inadimplencia' do
      params = {"periodo_min"=>"27/07/2000", "nome_servico"=>"", "servico_id"=>"", "periodo_max"=>"17/07/2010", "opcao_relatorio"=>"4", "periodo" => "vencimento"}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND (parcelas.situacao = ?) AND (parcelas.data_vencimento < ?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), Parcela::PENDENTE, Date.today], :include => [:conta => :servico]).and_return(1)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 1
    end

    it 'contar todos os recebimentos a receber passando o serviço Corel Draw' do
      params = {"periodo_min" => "27/07/2000", "nome_servico" => "Curso de Corel Draw", "periodo" => "vencimento", "servico_id" => "7491444", "periodo_max" => "17/07/2010", "opcao_relatorio" => "2", "situacao" => 'Todas'}
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (data_vencimento >= ?) AND (data_vencimento <= ?) AND (servico_id = ?) AND parcelas.situacao IN (?)',
          unidades(:senaivarzeagrande).id, Date.new(2000,07,27), Date.new(2010,07,17), servicos(:curso_de_corel).id.to_s, [Parcela::PENDENTE, Parcela::QUITADA, Parcela::CANCELADA, Parcela::RENEGOCIADA, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA]], :include => [:conta => :servico]).and_return(2)
      @actual = Parcela.relatorio_para_totalizacao(:count, unidades(:senaivarzeagrande).id, params)
      @actual.should == 2
    end
    
  end

  
  describe 'Recuperação de Crédito' do
    
    it "Gera dados para relatorio resumido " do
      params={"ano"=>"2009","tipo_do_relatorio"=>"0","nome_modalidade"=>""}
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande).id, params).should ==
        {5=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        "anos_anteriores"=>{"inadimplencia"=>0, "geral"=>0, "recebido"=>0, "a_receber"=>0},
        6=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        1=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        7=>{"inadimplencia"=>100.0, "geral"=>3000, "recebido"=>0, "a_receber"=>3000},
        2=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        8=>{"inadimplencia"=>100.0, "geral"=>3000, "recebido"=>0, "a_receber"=>3000}}
    end
    
    it "Gera dados para relatorio resumido alterando dados em fixtures " do
      params={"ano"=>"2009","tipo_do_relatorio"=>"0","nome_modalidade"=>""}
      @parcela = parcelas(:primeira_parcela_recebimento)
      @parcela.situacao = Parcela::QUITADA
      @parcela.save!
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande),params).should ==
        {5=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        "anos_anteriores"=>{"inadimplencia"=>0, "geral"=>0, "recebido"=>0, "a_receber"=>0},
        6=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        1=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        7=>{"inadimplencia"=>0.0, "geral"=>3000, "recebido"=>3000, "a_receber"=>0},
        2=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        8=>{"inadimplencia"=>100.0, "geral"=>3000, "recebido"=>0, "a_receber"=>3000}}
    end
    
    it "Gera dados para relatorio resumido alterando dados de duas fixtures" do
      params={"ano"=>"2009","tipo_do_relatorio"=>"0","nome_modalidade"=>""}
      conta=recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos= {ids_das_parcelas.first.to_s=>{"valor"=>"40,00","data_vencimento"=>"22/08/2009"},
        ids_das_parcelas.last.to_s=>{"valor"=>"20,00","data_vencimento"=>"22/07/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande), params).should ==
        {5=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        "anos_anteriores"=>{"inadimplencia"=>0, "geral"=>0, "recebido"=>0, "a_receber"=>0},
        6=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        1=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        7=>{"inadimplencia"=>100.0, "geral"=>2000, "recebido"=>0, "a_receber"=>2000},
        2=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        8=>{"inadimplencia"=>100.0, "geral"=>4000, "recebido"=>0, "a_receber"=>4000}}
    end
    
    it "Gera dados para relatorio resumido alterando dados de fixtures altera inadimplencia" do
      params={"ano"=>"2009","tipo_do_relatorio"=>"0","nome_modalidade"=>""}
      @parcela = parcelas(:primeira_parcela_recebida_cheque_a_vista)
      @parcela.situacao = Parcela::PENDENTE
      @parcela.save!
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande),params ).should ==
        {5=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        "anos_anteriores"=>{"inadimplencia"=>0, "geral"=>0, "recebido"=>0, "a_receber"=>0},
        6=>{"inadimplencia"=>0.0, "geral"=>5000, "recebido"=>5000, "a_receber"=>0},
        1=>{"inadimplencia"=>66.67, "geral"=>7500, "recebido"=>2500, "a_receber"=>5000},
        7=>{"inadimplencia"=>100.0, "geral"=>3000, "recebido"=>0, "a_receber"=>3000},
        2=>{"inadimplencia"=>0.0, "geral"=>7500, "recebido"=>7500, "a_receber"=>0},
        8=>{"inadimplencia"=>100.0, "geral"=>3000, "recebido"=>0, "a_receber"=>3000}}
    end
    
    it "Gera dados para relatorio detalhado" do
      params={"ano"=>"2009","tipo_do_relatorio"=>"1","nome_modalidade"=>""}
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande), params).sort.should ==
        {"receber"=> {
          "Curso de Flex"=>{"anos_anteriores"=>0, 7=>3000, 8=>3000},
          "Curso de Eletronica Digital"=>{"anos_anteriores"=>0, 1=>0, 2=>0},
          "Curso de Ruby on Rails"=>{5=>0, 6=>0, "anos_anteriores"=>0},
          "Curso de Corel Draw"=>{"anos_anteriores"=>0, 1=>0, 2=>0}},
        "recebido" => {
          "Curso de Flex"=>{"anos_anteriores"=>0, 7=>0, 8=>0},
          "Curso de Eletronica Digital"=>{"anos_anteriores"=>0, 1=>5000, 2=>5000},
          "Curso de Ruby on Rails"=>{5=>5000, 6=>5000, "anos_anteriores"=>0},
          "Curso de Corel Draw"=>{"anos_anteriores"=>0, 1=>2500, 2=>2500}
        }}.sort
    end
    
    it "Altera dados em fixtures para alterar recebido de um curso" do
      params={"ano"=>"2009","tipo_do_relatorio"=>"1","nome_modalidade"=>""}
      @conta = recebimento_de_contas(:curso_de_corel_do_paulo)
      @conta.servico = servicos(:curso_de_eletronica)
      @conta.save!
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande), params).sort.should ==
        {"receber" => {
          "Curso de Flex"=>{"anos_anteriores"=>0, 7=>3000, 8=>3000},
          "Curso de Eletronica Digital"=>{"anos_anteriores"=>0, 1=>0, 2=>0},
          "Curso de Ruby on Rails"=>{5=>0, 6=>0, "anos_anteriores"=>0}
        }, "recebido" => {
          "Curso de Flex"=>{"anos_anteriores"=>0, 7=>0, 8=>0},
          "Curso de Eletronica Digital"=>{"anos_anteriores"=>0, 1=>7500, 2=>7500},
          "Curso de Ruby on Rails"=>{5=>5000, 6=>5000, "anos_anteriores"=>0}
        }}.sort

    end
    
    it "Enviando modalidades " do
      s = Servico.first
      s.modalidade = "Aprendizado"
      s.save!
      params={"ano"=>"2009","tipo_do_relatorio"=>"1","nome_modalidade"=>"Ensino"}
      Parcela.recuperacao_de_creditos(unidades(:senaivarzeagrande),params).sort.should ==
        {"receber" => {
          "Curso de Flex"=>{"anos_anteriores"=>0, 7=>3000, 8=>3000},
          "Curso de Eletronica Digital"=>{"anos_anteriores"=>0, 1=>0, 2=>0},
          "Curso de Ruby on Rails"=>{5=>0, 6=>0, "anos_anteriores"=>0}
        }, "recebido" => {
          "Curso de Flex"=>{"anos_anteriores"=>0, 7=>0, 8=>0},
          "Curso de Eletronica Digital"=>{"anos_anteriores"=>0, 1=>5000, 2=>5000},
          "Curso de Ruby on Rails"=>{5=>5000, 6=>5000, "anos_anteriores"=>0}
        }}.sort
    end
  end

  it 'verifica se a parcela é renegociada' do
    parcela = Parcela.new
    parcela.situacao = Parcela::RENEGOCIADA
    parcela.renegociada.should == true
  end

  it 'verifica se cancelou a parcela' do
    parcela = parcelas(:segunda_parcela_recebimento)
    assert_difference 'HistoricoOperacao.count', 1 do
      parcela.cancelar(usuarios(:quentin)).should == true      
    end
    parcela.reload
    
    parcela.situacao.should == Parcela::CANCELADA
  end

  it 'verifica se não cancelou parcela quitada' do
    parcela_quitada = parcelas(:primeira_parcela_recebida_cheque_a_vista)
    assert_no_difference 'HistoricoOperacao.count', 1 do
      parcela_quitada.cancelar(usuarios(:quentin)).should == false
    end
    parcela_quitada.reload

    parcela_quitada.situacao.should == Parcela::QUITADA
  end

  it 'verifica se não cancelou a parcela para pagamento de contas' do
    parcela = parcelas(:primeira_parcela)
    assert_no_difference 'HistoricoOperacao.count', 1 do
      parcela.cancelar(usuarios(:quentin)).should == false
    end
    parcela.reload

    parcela.situacao.should == Parcela::QUITADA
  end

  describe "teste da funcao de baixar parcela" do
    
    it "conseguiu fazer a baixa" do
      params = {"valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"1", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"Pagamento Cartão  - 123 - Juan Vitor Zeferino - Curso de Corel Draw", "observacoes"=>"", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"03/09/2009"}
      parcela = parcelas(:primeira_parcela_recebimento)
      usuario = usuarios(:quentin)
      parcela.situacao.should == Parcela::PENDENTE
      
      assert_difference 'HistoricoOperacao.count', 1 do
        parcela.baixar_parcela(2009, usuario, params).should == [true, "Baixa na parcela realizada com sucesso!"]
      end

      historico_operacao = HistoricoOperacao.last
      historico_operacao.descricao.should == "Parcela numero #{parcela.numero} baixada - Valor: #{(parcela.valor_liquido/100.0).real.real_formatado} - Forma de pagamento: #{parcela.forma_de_pagamento_verbose} - Data de Vencimento: #{parcela.data_vencimento} - Data de Pagamento: #{parcela.data_da_baixa}"
      historico_operacao.usuario.should == usuario
      historico_operacao.justificativa.should == nil

      parcela.situacao.should == Parcela::QUITADA
      parcela.ano_contabil_atual.should == 2009
      parcela.baixando.should == true
    end

    it "testa a função baixar parcela lançando a exceção" do
      params = {"valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"1", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"Pagamento Cartão  - 123 - Juan Vitor Zeferino - Curso de Corel Draw", "observacoes"=>"", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"03/09/2009"}
      parcela = parcelas(:primeira_parcela)
      usuario = usuarios(:quentin)
      parcela.estorna_parcela(usuario, "Teste")
      parcela.situacao.should == Parcela::PENDENTE

      assert_difference 'HistoricoOperacao.count', 0 do
        parcela.baixar_parcela(2011, usuario, params).first.should == false
      end
    end
    
    it "testa a função baixar parcela lançando outra exceção" do
      params = {"valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"1", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"Pagamento Cartão  - 123 - Juan Vitor Zeferino - Curso de Corel Draw", "observacoes"=>"", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"03/09/2009"}
      parcela = parcelas(:segunda_parcela)
      usuario = usuarios(:quentin)
      parcela.situacao.should == Parcela::PENDENTE

      assert_difference 'HistoricoOperacao.count', 0 do
        parcela.baixar_parcela(2008, usuario, params).should == [false, "Não é possível realizar um lançamento com data anterior à sua criação\nNão é possível realizar um lançamento com data anterior à sua criação"]
      end
    end

  end

  it "Verifica o lancamento de um imposto quando é do tipo RETEM" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    imposto = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 8 do # 6 itens na geração de parcelas e 2 itens nos impostos
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"100,00", "aliquota"=>"5.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"50,00", "aliquota"=>"5.0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end
    imposto.conta_debito.should == nil
    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    credito = movimento.itens_movimentos[3]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    debito.valor.should == 100000
    credito_imposto_1 = movimento.itens_movimentos[1]
    credito_imposto_2 = movimento.itens_movimentos[2]
    credito.plano_de_conta.should == pagamento.conta_contabil_pessoa
    credito.valor.should == 85000
    credito_imposto_1.plano_de_conta.should == imposto.conta_credito
    credito_imposto_1.valor.should == 10000
    credito_imposto_2.plano_de_conta.should == imposto.conta_credito
    credito_imposto_2.valor.should == 5000
  end

  it "Verifica o lancamento de um imposto quando é do tipo INCIDE" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    imposto = impostos(:fgts)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 10 do # 6 itens na geração de parcelas e 4 itens nos impostos
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"100,00", "aliquota"=>"8.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"50,00", "aliquota"=>"8.0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end
    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    debito_imposto_1 = movimento.itens_movimentos[1]
    debito_imposto_2 = movimento.itens_movimentos[2]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    debito.valor.should == 100000
    debito_imposto_1.plano_de_conta.should == imposto.conta_debito
    debito_imposto_1.valor.should == 10000
    debito_imposto_2.plano_de_conta.should == imposto.conta_debito
    debito_imposto_2.valor.should == 5000
    credito = movimento.itens_movimentos[5]
    credito_imposto_1 = movimento.itens_movimentos[3]
    credito_imposto_2 = movimento.itens_movimentos[4]
    credito.plano_de_conta.should == pagamento.conta_contabil_pessoa
    credito.valor.should == 100000
    credito_imposto_1.plano_de_conta.should == imposto.conta_credito
    credito_imposto_1.valor.should == 10000
    credito_imposto_2.plano_de_conta.should == imposto.conta_credito
    credito_imposto_2.valor.should == 5000
  end

  it "Verifica quando o lancamento de impostos é dos tipos INCIDE e RETEM" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    incide = impostos(:fgts)
    retem = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 9 do # 6 itens na geração de parcelas e 3 itens nos impostos
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0", "valor_imposto"=>"50.00", "aliquota"=>"5.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{incide.id.to_s}#8.0", "valor_imposto"=>"100.00", "aliquota"=>"8.0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end
    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    debito_imposto = movimento.itens_movimentos[1]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    debito.valor.should == 100000
    debito_imposto.plano_de_conta.should == incide.conta_debito
    debito_imposto.valor.should == 10000
    credito = movimento.itens_movimentos[4]
    credito_imposto_1 = movimento.itens_movimentos[2]
    credito_imposto_2 = movimento.itens_movimentos[3]
    credito.plano_de_conta.should == pagamento.conta_contabil_pessoa
    credito.valor.should == 95000
    credito_imposto_1.plano_de_conta.should == retem.conta_credito
    credito_imposto_1.valor.should == 5000
    credito_imposto_2.plano_de_conta.should == incide.conta_credito
    credito_imposto_2.valor.should == 10000
  end

  it "Verifica quando o lancamento de impostos é do tipo RETEM e NÃO TEM PROVISÃO e NÃO TEM RATEIO" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    imposto = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 0 do
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"100,00", "aliquota"=>"5,0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"50,00", "aliquota"=>"5,0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end

    params = {'forma_de_pagamento' => Parcela::DINHEIRO, 'data_da_baixa' => '21/08/2009', 'historico' => 'Baixando sem provisão'}
    assert_difference 'ItensMovimento.count', 4 do
      pagamento.parcelas[0].baixar_parcela(2009, usuarios(:quentin), params).should == [true, "Baixa na parcela realizada com sucesso!"]
    end

    imposto.conta_debito.should == nil
    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    credito = movimento.itens_movimentos[1]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    debito.valor.should == 100000
    credito_imposto_1 = movimento.itens_movimentos[2]
    credito_imposto_2 = movimento.itens_movimentos[3]
    credito.plano_de_conta.should == ContasCorrente.find_by_unidade_id_and_identificador(pagamento.unidade.id, ContasCorrente::CAIXA).conta_contabil
    credito.valor.should == 85000
    credito_imposto_1.plano_de_conta.should == imposto.conta_credito
    credito_imposto_1.valor.should == 10000
    credito_imposto_2.plano_de_conta.should == imposto.conta_credito
    credito_imposto_2.valor.should == 5000
  end

  it "Verifica quando o lancamento de impostos é do tipo INCIDE e NÃO TEM PROVISÃO e NÃO TEM RATEIO" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    imposto = impostos(:fgts)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 0 do
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"100.00", "aliquota"=>"8.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{imposto.id.to_s}#8.0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end

    params = {'forma_de_pagamento' => Parcela::DINHEIRO, 'data_da_baixa' => '21/08/2009', 'historico' => 'Baixando sem provisão'}
    assert_difference 'ItensMovimento.count', 6 do
      pagamento.parcelas[0].baixar_parcela(2009, usuarios(:quentin), params).should == [true, "Baixa na parcela realizada com sucesso!"]
    end

    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    debito_imposto_1 = movimento.itens_movimentos[1]
    debito_imposto_2 = movimento.itens_movimentos[2]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    debito.valor.should == 100000
    debito_imposto_1.plano_de_conta.should == imposto.conta_debito
    debito_imposto_1.valor.should == 10000
    debito_imposto_2.plano_de_conta.should == imposto.conta_debito
    debito_imposto_2.valor.should == 5000
    credito = movimento.itens_movimentos[3]
    credito_imposto_1 = movimento.itens_movimentos[4]
    credito_imposto_2 = movimento.itens_movimentos[5]
    credito.plano_de_conta.should == ContasCorrente.find_by_unidade_id_and_identificador(pagamento.unidade.id, ContasCorrente::CAIXA).conta_contabil
    credito.valor.should == 100000
    credito_imposto_1.plano_de_conta.should == imposto.conta_credito
    credito_imposto_1.valor.should == 10000
    credito_imposto_2.plano_de_conta.should == imposto.conta_credito
    credito_imposto_2.valor.should == 5000
  end

  it "Verifica quando o lancamento de impostos é dos tipos INCIDE e RETEM e NÃO TEM PROVISÃO e NÃO TEM RATEIO" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    incide = impostos(:fgts)
    retem = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 2 do
      assert_difference 'ItensMovimento.count', 0 do
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{incide.id.to_s}#8.0", "valor_imposto"=>"100,00", "aliquota"=>"8.0"}}
        pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
      end
    end

    params = {'forma_de_pagamento' => Parcela::DINHEIRO, 'data_da_baixa' => '21/08/2009', 'historico' => 'Baixando sem provisão'}
    assert_difference 'ItensMovimento.count', 5 do
      pagamento.parcelas[0].baixar_parcela(2009, usuarios(:quentin), params).should == [true, "Baixa na parcela realizada com sucesso!"]
    end

    movimento = Movimento.last
    debito = movimento.itens_movimentos[0]
    debito_imposto = movimento.itens_movimentos[1]
    debito.plano_de_conta.should == pagamento.conta_contabil_despesa
    debito.valor.should == 100000
    debito_imposto.plano_de_conta.should == incide.conta_debito
    debito_imposto.valor.should == 10000
    credito = movimento.itens_movimentos[2]
    credito_imposto_1 = movimento.itens_movimentos[4]
    credito_imposto_2 = movimento.itens_movimentos[3]
    credito.plano_de_conta.should == ContasCorrente.find_by_unidade_id_and_identificador(pagamento.unidade.id, ContasCorrente::CAIXA).conta_contabil
    credito.valor.should == 95000
    credito_imposto_1.plano_de_conta.should == pagamento.conta_contabil_pessoa
    credito_imposto_1.valor.should == 10000
    credito_imposto_2.plano_de_conta.should == retem.conta_credito
    credito_imposto_2.valor.should == 5000
  end

  it "Verifica se lança vários impostos e apenas contabiliza os que RETEM" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    incide = impostos(:fgts)
    retem = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 7 do
      pagamento.gerar_parcelas(2009)
      pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
        "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"1000,00", "aliquota"=>"8.0"},
        "3"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
        "4"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
        "5"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"1000,00", "aliquota"=>"8.0"},
        "6"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"1000,00", "aliquota"=>"8.0"},
        "7"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"}
      }
      pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
    end
    pagamento.parcelas[0].valor.should == 100000
    pagamento.parcelas[0].soma_impostos_da_parcela.should == 20000
    pagamento.parcelas[0].calcula_valor_liquido_da_parcela.should == 80000
  end

  it "Verifica se lança vários impostos e apenas contabiliza os que RETEM, mas os valores são MAIORES que o da Parcela" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    incide = impostos(:fgts)
    retem = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"1", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"1000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 0 do
      assert_difference 'ItensMovimento.count', 0 do
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas.first.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"},
          "3"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"},
          "4"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"},
          "5"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"},
          "6"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"},
          "7"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"255.00", "aliquota"=>"5.0"}
        }
        pagamento.parcelas.first.grava_dados_do_imposto_na_parcela(2009).first.should == false
        pagamento.parcelas.first.errors.on(:base).should == "Valor dos impostos maior que o valor da parcela. Impossível salvar por favor verifique."
      end
    end
    pagamento.parcelas.first.valor.should == 100000
    pagamento.parcelas.first.soma_impostos_da_parcela.should == 0
    pagamento.parcelas.first.calcula_valor_liquido_da_parcela.should == 100000
  end

  it "Verifica se lança vários impostos e apenas contabiliza os que RETEM, mas os valores são IGUAIS ao da Parcela" do
    LancamentoImposto.delete_all
    ItensMovimento.delete_all
    incide = impostos(:fgts)
    retem = impostos(:iss)
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"1", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"1000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    assert_difference 'LancamentoImposto.count', 0 do
      assert_difference 'ItensMovimento.count', 0 do
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas.first.dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"},
          "2"=>{"data_de_recolhimento"=>"21-08-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"50.00", "aliquota"=>"8.0"},
          "3"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"},
          "4"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"},
          "5"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"50.00", "aliquota"=>"5.0"},
          "6"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"50.00", "aliquota"=>"5.0"},
          "7"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"250.00", "aliquota"=>"5.0"}
        }
        pagamento.parcelas.first.grava_dados_do_imposto_na_parcela(2009).first.should == false
        pagamento.parcelas.first.errors.on(:base).should == "O valor da soma dos impostos deve ser menor que o valor da parcela. Por favor verifique."
      end
    end
    pagamento.parcelas.first.valor.should == 100000
    pagamento.parcelas.first.soma_impostos_da_parcela.should == 0
    pagamento.parcelas.first.calcula_valor_liquido_da_parcela.should == 100000
  end

  it 'Verifica se apaga todos os movimentos quando estorna uma parcela' do
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"1", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"1000,00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    params = {"cartoes_attributes"=>{"1"=>{"nome_do_titular"=>"", "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}}, "valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"3", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "cheques_attributes"=>{"0"=>{"banco_id"=>"940885155", "prazo"=>"1", "agencia"=>"1563", "nome_do_titular"=>"Joao", "conta_contabil_transitoria_id"=>"852685046", "conta"=>"5896", "data_para_deposito"=>"23/10/2009", "numero"=>"7453"}}, "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"MyString", "observacoes"=>"Testando", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"23/10/2009"}
    assert_difference 'Movimento.count', 1 do
      assert_difference 'ItensMovimento.count', 2 do
        pagamento.gerar_parcelas(2009)
        pagamento.parcelas.first.baixar_parcela(2009, usuarios(:quentin), params)
      end
    end

    Cartao.delete_all
    Cartao.create! :parcela => pagamento.parcelas.first, :bandeira => Cartao::VISACREDITO, :nome_do_titular => 'João',
      :numero => '12345', :validade => '12/12', :codigo_de_seguranca => '123'
    pagamento.parcelas.reload
    
    params_cartoes = {"conta_contabil_id"=>"991678971", "ids"=>[Cartao.first.id], "historico"=>"VLR REF RECEBTO FATURA DE CARTÃO DATA 23/10/2009", "conta_contabil_nome"=>"Fornecedores a Pagar", "data_do_deposito"=>"23/10/2009"}
    assert_difference 'Cartao.count', 0 do
      pagamento.parcelas.first.cartoes.baixar(2009, params_cartoes, unidades(:senaivarzeagrande))
    end

    assert_difference 'Movimento.count', -1 do
      assert_difference 'ItensMovimento.count', -2 do
        pagamento.parcelas.first.estorna_parcela(usuarios(:quentin), 'Testando estorno').should == [true, "Parcela estornada com sucesso!"]
      end
    end

  end

  it "testa se não estorna com limites inválidos" do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 5
    unidade.lancamentoscontasreceber = 5
    unidade.save!

    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"1", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"1000.00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!

    pagamento.gerar_parcelas(2009)
    params = {"cartoes_attributes"=>{"1"=>{"nome_do_titular"=>"", "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}}, "valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"3", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "cheques_attributes"=>{"0"=>{"banco_id"=>"940885155", "prazo"=>"1", "agencia"=>"1563", "nome_do_titular"=>"Joao", "conta_contabil_transitoria_id"=>"852685046", "conta"=>"5896", "data_para_deposito"=>"23/10/2009", "numero"=>"7453"}}, "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"MyString", "observacoes"=>"Testando", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"23/10/2009"}
    pagamento.parcelas.first.baixar_parcela(2009, usuarios(:quentin), params)

    Cartao.create! :parcela => pagamento.parcelas.first, :bandeira => Cartao::VISACREDITO, :nome_do_titular => 'João',
      :numero => '12345', :validade => '12/12', :codigo_de_seguranca => '123'
    pagamento.parcelas.reload

    params_cartoes = {"conta_contabil_id"=>"991678971", "ids"=>[Cartao.last.id], "historico"=>"VLR REF RECEBTO FATURA DE CARTÃO DATA 23/10/2009", "conta_contabil_nome"=>"Fornecedores a Pagar", "data_do_deposito"=>"23/10/2009"}
    pagamento.parcelas.first.cartoes.baixar(2009, params_cartoes, unidade)
    
    Date.stub!(:today).and_return Date.new 2009, 10, 29
    pagamento.parcelas.first.estorna_parcela(usuarios(:quentin), 'Testando estorno').first.should == false
  end

  it 'quando excluir uma conta deve excluir tudo que está envolvido com ela' do
    PagamentoDeConta.delete_all; Parcela.delete_all; Movimento.delete_all; ItensMovimento.delete_all;
    LancamentoImposto.delete_all; Rateio.delete_all

    incide = impostos(:fgts)
    retem = impostos(:iss)

    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico",
        "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa",
        "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009",
        "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF",
        "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009",
        "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"1.000,00",
        "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    HistoricoOperacao.delete_all

    PagamentoDeConta.count.should == 1

    assert_difference 'Parcela.count', 3 do
      assert_difference 'Movimento.count', 3 do
        assert_difference 'ItensMovimento.count', 16 do
          assert_difference 'Rateio.count', 3 do
            assert_difference 'LancamentoImposto.count', 7 do
              assert_difference 'HistoricoOperacao.count', 1 do
                pagamento.gerar_parcelas(2009)
                pagamento.parcelas[0].dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
                  "2"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"1.000,00", "aliquota"=>"8.0"},
                  "3"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
                  "4"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"},
                  "5"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"1000,00", "aliquota"=>"8.0"},
                  "6"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{incide.id.to_s}#8.0#0", "valor_imposto"=>"1000,00", "aliquota"=>"8.0"},
                  "7"=>{"data_de_recolhimento"=>"15-10-2009", "imposto_id"=>"#{retem.id.to_s}#5.0#1", "valor_imposto"=>"50,00", "aliquota"=>"5.0"}
                }
                pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009).should == [true, "Dados do imposto na parcela salvos com sucesso!"]
              end
            end
          end
        end
      end
    end

    assert_difference 'PagamentoDeConta.count', -1 do
      assert_difference 'Parcela.count', -3 do
        assert_difference 'Movimento.count', -3 do
          assert_difference 'ItensMovimento.count', -16 do
            assert_difference 'Rateio.count', -3 do
              assert_difference 'LancamentoImposto.count', -7 do
                assert_difference 'HistoricoOperacao.count', -1 do
                  pagamento.destroy
                end
              end
            end
          end
        end
      end
    end

    PagamentoDeConta.count.should == 0
  end

  it 'Verifica se grava o ID da parcela no movimento quando se gera as parcelas e tem provisão' do
    Movimento.delete_all; ItensMovimento.delete_all; Parcela.delete_all
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000.00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    pagamento.gerar_parcelas(2009)
    movimento = Movimento.last
    movimento.parcela.should == Parcela.last
  end

  it 'Verifica se grava o ID da parcela no movimento quando se baixa uma parcela' do
    Movimento.delete_all; ItensMovimento.delete_all; Parcela.delete_all
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"3", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000.00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    pagamento.gerar_parcelas(2009)
    params = {"cartoes_attributes"=>{"1"=>{"nome_do_titular"=>"", "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}}, "valor_da_multa_em_reais"=>"0.00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"1", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "cheques_attributes"=>{"0"=>{"banco_id"=>"", "prazo"=>"", "agencia"=>"", "nome_do_titular"=>"", "conta_contabil_transitoria_id"=>"", "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}, "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"MyString", "observacoes"=>"Testando", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"23/10/2009"}
    pagamento.parcelas.first.baixar_parcela(2009, usuarios(:quentin), params)
    movimento = Movimento.first
    movimento.parcela.should == Parcela.first
  end

  it "testa o método Verifica Situações" do
    pagamento = PagamentoDeConta.new({"nome_centro"=>"4567456344 - Forum Serviço Economico", "numero_de_parcelas"=>"1", "numero_nota_fiscal"=>"12344", "nome_conta_contabil_despesa"=>"11010101001 - Caixa", "nome_pessoa"=>"FTG Tecnologia", "centro_id"=>"54652781", "primeiro_vencimento"=>"21/08/2009", "data_lancamento"=>"21/08/2009", "historico"=>"Pagamento Cartão - 12344 - FTG Tecnologia", "provisao"=>"1", "tipo_de_documento"=>"CPMF", "unidade_organizacional_id"=>"677077046", "conta_contabil_despesa_id"=>"360692661", "data_emissao"=>"21/08/2009", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>"131520042", "valor_do_documento_em_reais"=>"3000.00", "nome_unidade_organizacional"=>"134234239039 - Senai Matriz", "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande)})
    pagamento.ano = 2009
    pagamento.usuario_corrente = usuarios(:quentin)
    pagamento.save!
    pagamento.gerar_parcelas(2009)
    pagamento.parcelas.first.verifica_situacoes.should == true
    pagamento.parcelas.first.situacao = Parcela::JURIDICO
    pagamento.parcelas.first.save!
    pagamento.parcelas.first.verifica_situacoes.should == true
    pagamento.parcelas.first.situacao = Parcela::BAIXA_DO_CONSELHO
    pagamento.parcelas.first.save!
    pagamento.parcelas.first.verifica_situacoes.should == true
    pagamento.parcelas.first.situacao = Parcela::PERMUTA
    pagamento.parcelas.first.save!
    pagamento.parcelas.first.verifica_situacoes.should == true
    pagamento.parcelas.first.situacao = Parcela::DESCONTO_EM_FOLHA
    pagamento.parcelas.first.save!
    pagamento.parcelas.first.verifica_situacoes.should == true
    pagamento.parcelas.first.situacao = nil
    pagamento.parcelas.first.save!
    pagamento.parcelas.first.verifica_situacoes.should == true
    pagamento.parcelas.first.situacao = Parcela::CANCELADA
    pagamento.parcelas.first.save!
    pagamento.parcelas.first.verifica_situacoes.should == false
    pagamento.parcelas.first.situacao = Parcela::RENEGOCIADA
    pagamento.parcelas.first.save false
    pagamento.parcelas.first.verifica_situacoes.should == false
    pagamento.parcelas.first.situacao = Parcela::QUITADA
    pagamento.parcelas.first.save false
    pagamento.parcelas.first.verifica_situacoes.should == false
  end

  it "testa o método lancamento_contabil_de_baixa_da_parcela quando há lancamentos de honorarios, protesto e taxa de boleto" do
    #    Date.stub!(:today).and_return Date.new 2009, 1, 1
    ItensMovimento.delete_all
    @parcela = parcelas(:primeira_parcela_recebimento)
    @parcela.unidade.lancamentoscontasreceber = 100000
    @parcela.unidade.lancamentoscontaspagar = 100000
    @parcela.unidade.lancamentosmovimentofinanceiro = 100000
    @parcela.unidade.save!
    @parcela.unidade.reload
    @parcela.data_da_baixa = "10/04/2010"
    @parcela.historico = "teste"
    @parcela.dados_do_imposto = nil
    @parcela.lancamento_impostos =[]
    @parcela.baixando = true
    @parcela.save
    @parcela.ano_contabil_atual = 2009
    assert_difference 'Movimento.count', 1 do
      assert_difference 'ItensMovimento.count', 5 do
        @parcela.lancamento_contabil_de_baixa_da_parcela
      end
    end
    itens = ItensMovimento.all
    soma = @parcela.valor + @parcela.valor_da_multa + @parcela.outros_acrescimos + @parcela.valor_dos_juros + @parcela.valores_novos_recebimentos - @parcela.valor_do_desconto
    itens.first.tipo.should == "D"
    itens.first.valor.should == soma
    itens.first.centro.should == @parcela.conta.centro
    itens.first.unidade_organizacional.should == @parcela.conta.unidade_organizacional
    itens.first.plano_de_conta.should == contas_correntes(:conta_caixa).conta_contabil
    itens[1].tipo.should == "C"
    itens[1].valor.should == @parcela.honorarios
    itens[1].centro.should == @parcela.centro_honorarios
    itens[1].unidade_organizacional.should == @parcela.unidade_organizacional_honorarios
    itens[1].plano_de_conta.should == @parcela.conta_contabil_honorarios
    itens[2].tipo.should == "C"
    itens[2].valor.should == @parcela.protesto
    itens[2].centro.should == @parcela.centro_protesto
    itens[2].unidade_organizacional.should == @parcela.unidade_organizacional_protesto
    itens[2].plano_de_conta.should == @parcela.conta_contabil_protesto
    itens[3].tipo.should == "C"
    itens[3].valor.should == @parcela.taxa_boleto
    itens[3].centro.should == @parcela.centro_taxa_boleto
    itens[3].unidade_organizacional.should == @parcela.unidade_organizacional_taxa_boleto
    itens[3].plano_de_conta.should == @parcela.conta_contabil_taxa_boleto
    itens[4].tipo.should == "C"
    itens[4].valor.should == @parcela.valor
    itens[4].centro.should == @parcela.conta.centro
    itens[4].unidade_organizacional.should == @parcela.conta.unidade_organizacional
    itens[4].plano_de_conta.should == contas_correntes(:conta_caixa).conta_contabil
  end

  describe 'Testes da nova funcionalidade de rateio de impostos' do

    it "o lancamento de impostos é do tipo RETEM e TEM RATEIO" do
      LancamentoImposto.delete_all
      ItensMovimento.delete_all
      Movimento.delete_all
      imposto = impostos(:iss)
      pagamento = PagamentoDeConta.new({"numero_de_parcelas"=>"1", "centro_id"=>centros(:centro_forum_financeiro).id, "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_conta_contabil_despesa"=>"22343456 - Devolucoes do SENAI", "numero_nota_fiscal"=>"9999", "primeiro_vencimento"=>"12/03/2010", "nome_pessoa"=>"FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"TRE", "data_lancamento"=>"12/03/2010", "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_unidade_organizacional"=>"131344278639 - Senai Novo", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_despesa_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "data_emissao"=>"12/03/2010", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>pessoas(:inovare).id, "valor_do_documento_em_reais"=>"120,00", "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande)})
      pagamento.ano = 2009
      pagamento.usuario_corrente = usuarios(:quentin)
      pagamento.save!

      assert_difference 'Rateio.count', 3 do
        assert_difference 'LancamentoImposto.count', 3 do
          assert_difference 'ItensMovimento.count', 0 do
            pagamento.gerar_parcelas(2009)
            pagamento.parcelas[0].dados_do_rateio ={
              "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
              "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40,00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
              "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
            pagamento.parcelas[0].grava_itens_do_rateio(2009, pagamento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]

            pagamento.parcelas[0].dados_do_imposto = {
              "1"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"70,00", "aliquota"=>"5,00"},
              "2"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"5,00", "aliquota"=>"5,00"},
              "3"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"10,00", "aliquota"=>"5,00"}}
            pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
          end
        end
      end

      params = {'forma_de_pagamento' => Parcela::DINHEIRO, 'data_da_baixa' => '21/08/2009', 'historico' => 'Baixando sem provisão'}
      assert_difference 'ItensMovimento.count', 7 do
        pagamento.parcelas[0].baixar_parcela(2009, usuarios(:quentin), params).should == [true, "Baixa na parcela realizada com sucesso!"]
      end

      movimento = Movimento.first

      # DEBITOS
      debito1 = movimento.itens_movimentos[0]
      debito1.valor.should == 5000
      debito1.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["conta_contabil_id"]
      debito1.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito1.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito2 = movimento.itens_movimentos[1]
      debito2.valor.should == 4000
      debito2.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["conta_contabil_id"]
      debito2.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito2.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      debito3 = movimento.itens_movimentos[2]
      debito3.valor.should == 3000
      debito3.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["conta_contabil_id"]
      debito3.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito3.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      # CREDITOS
      credito1 = movimento.itens_movimentos[3]
      credito1.valor.should == 3500
      credito1.plano_de_conta.id.should == ContasCorrente.find_by_unidade_id_and_identificador(pagamento.unidade.id, ContasCorrente::CAIXA).conta_contabil.id
      credito1.unidade_organizacional.id.should == pagamento.unidade_organizacional.id
      credito1.centro.id.should == pagamento.centro.id

      credito2 = movimento.itens_movimentos[4]
      credito2.valor.should == 7000
      credito2.plano_de_conta.id.should == imposto.conta_credito.id
      credito2.unidade_organizacional.id.should == pagamento.unidade_organizacional.id
      credito2.centro.id.should == pagamento.centro.id

      credito3 = movimento.itens_movimentos[5]
      credito3.valor.should == 500
      credito3.plano_de_conta.id.should == imposto.conta_credito.id
      credito3.unidade_organizacional.id.should == pagamento.unidade_organizacional.id
      credito3.centro.id.should == pagamento.centro.id

      credito4 = movimento.itens_movimentos[6]
      credito4.valor.should == 1000
      credito4.plano_de_conta.id.should == imposto.conta_credito.id
      credito4.unidade_organizacional.id.should == pagamento.unidade_organizacional.id
      credito4.centro.id.should == pagamento.centro.id
    end

    it "o lancamento de impostos é do tipo INCIDE e TEM RATEIO" do
      LancamentoImposto.delete_all
      ItensMovimento.delete_all
      Movimento.delete_all
      imposto = impostos(:fgts)
      pagamento = PagamentoDeConta.new({"numero_de_parcelas"=>"1", "centro_id"=>centros(:centro_forum_financeiro).id, "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_conta_contabil_despesa"=>"22343456 - Devolucoes do SENAI", "numero_nota_fiscal"=>"9999", "primeiro_vencimento"=>"12/03/2010", "nome_pessoa"=>"FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"TRE", "data_lancamento"=>"12/03/2010", "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_unidade_organizacional"=>"131344278639 - Senai Novo", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_despesa_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "data_emissao"=>"12/03/2010", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>pessoas(:inovare).id, "valor_do_documento_em_reais"=>"120.00", "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande)})
      pagamento.ano = 2009
      pagamento.usuario_corrente = usuarios(:quentin)
      pagamento.save!

      assert_difference 'Rateio.count', 3 do
        assert_difference 'LancamentoImposto.count', 3 do
          assert_difference 'ItensMovimento.count', 0 do
            pagamento.gerar_parcelas(2009)
            pagamento.parcelas[0].dados_do_rateio = {
              "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
              "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40,00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
              "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
            pagamento.parcelas[0].grava_itens_do_rateio(2009, pagamento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]

            pagamento.parcelas[0].dados_do_imposto = {
              "1"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"85,00", "aliquota"=>"5,00"},
              "2"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"5,00", "aliquota"=>"5,00"},
              "3"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{imposto.id.to_s}#5.0", "valor_imposto"=>"10,00", "aliquota"=>"5,00"}}
            pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
          end
        end
      end

      params = {'forma_de_pagamento' => Parcela::DINHEIRO, 'data_da_baixa' => '21/08/2009', 'historico' => 'Baixando sem provisão'}
      assert_difference 'ItensMovimento.count', 16 do
        pagamento.parcelas[0].baixar_parcela(2009, usuarios(:quentin), params).should == [true, "Baixa na parcela realizada com sucesso!"]
      end

      movimento = Movimento.first

      # DEBITOS
      debito1 = movimento.itens_movimentos[0]
      debito1.valor.should == 333
      debito1.plano_de_conta.id.should == imposto.conta_debito.id
      debito1.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito1.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      debito2 = movimento.itens_movimentos[1]
      debito2.valor.should == 2126
      debito2.plano_de_conta.id.should == imposto.conta_debito.id
      debito2.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito2.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      debito3 = movimento.itens_movimentos[2]
      debito3.valor.should == 251
      debito3.plano_de_conta.id.should == imposto.conta_debito.id
      debito3.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito3.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      debito4 = movimento.itens_movimentos[3]
      debito4.valor.should == 208
      debito4.plano_de_conta.id.should == imposto.conta_debito.id
      debito4.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito4.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito5 = movimento.itens_movimentos[4]
      debito5.valor.should == 166
      debito5.plano_de_conta.id.should == imposto.conta_debito.id
      debito5.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito5.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      debito6 = movimento.itens_movimentos[5]
      debito6.valor.should == 126
      debito6.plano_de_conta.id.should == imposto.conta_debito.id
      debito6.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito6.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      debito7 = movimento.itens_movimentos[6]
      debito7.valor.should == 5000
      debito7.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["conta_contabil_id"]
      debito7.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito7.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito8 = movimento.itens_movimentos[7]
      debito8.valor.should == 4000
      debito8.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["conta_contabil_id"]
      debito8.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito8.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      debito9 = movimento.itens_movimentos[8]
      debito9.valor.should == 3000
      debito9.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["conta_contabil_id"]
      debito9.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito9.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      debito10 = movimento.itens_movimentos[9]
      debito10.valor.should == 416
      debito10.plano_de_conta.id.should == imposto.conta_debito.id
      debito10.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito10.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito11 = movimento.itens_movimentos[10]
      debito11.valor.should == 3541
      debito11.plano_de_conta.id.should == imposto.conta_debito.id
      debito11.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito11.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito12 = movimento.itens_movimentos[11]
      debito12.valor.should == 2833
      debito12.plano_de_conta.id.should == imposto.conta_debito.id
      debito12.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito12.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      # CREDITOS
      credito1 = movimento.itens_movimentos[12]
      credito1.valor.should == 12000
      credito1.plano_de_conta.id.should == ContasCorrente.find_by_unidade_id_and_identificador(pagamento.unidade.id, ContasCorrente::CAIXA).conta_contabil.id
      credito1.unidade_organizacional.should == pagamento.unidade_organizacional
      credito1.centro.should == pagamento.centro

      credito2 = movimento.itens_movimentos[13]
      credito2.valor.should == 8500
      credito2.plano_de_conta.should == Imposto.find(pagamento.parcelas[0].dados_do_imposto["1"]["imposto_id"]).conta_credito
      credito2.unidade_organizacional.should == pagamento.unidade_organizacional
      credito2.centro.should == pagamento.centro

      credito3 = movimento.itens_movimentos[14]
      credito3.valor.should == 500
      credito3.plano_de_conta.should == Imposto.find(pagamento.parcelas[0].dados_do_imposto["2"]["imposto_id"]).conta_credito
      credito3.unidade_organizacional.should == pagamento.unidade_organizacional
      credito3.centro.should == pagamento.centro

      credito4 = movimento.itens_movimentos[15]
      credito4.valor.should == 1000
      credito4.plano_de_conta.should == Imposto.find(pagamento.parcelas[0].dados_do_imposto["3"]["imposto_id"]).conta_credito
      credito4.unidade_organizacional.should == pagamento.unidade_organizacional
      credito4.centro.should == pagamento.centro
    end

    it "o lancamento de impostos é dos tipos INCIDE e RETEM e TEM RATEIO" do
      LancamentoImposto.delete_all
      ItensMovimento.delete_all
      Movimento.delete_all
      retem = impostos(:iss)
      incide = impostos(:fgts)
      pagamento = PagamentoDeConta.new({"numero_de_parcelas"=>"1", "centro_id"=>centros(:centro_forum_financeiro).id, "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_conta_contabil_despesa"=>"22343456 - Devolucoes do SENAI", "numero_nota_fiscal"=>"9999", "primeiro_vencimento"=>"12/03/2010", "nome_pessoa"=>"FTG Tecnologia", "provisao"=>"0", "tipo_de_documento"=>"TRE", "data_lancamento"=>"12/03/2010", "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_unidade_organizacional"=>"131344278639 - Senai Novo", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_despesa_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "data_emissao"=>"12/03/2010", "conta_contabil_pessoa_id"=>"937187129", "pessoa_id"=>pessoas(:inovare).id, "valor_do_documento_em_reais"=>"120.00", "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande)})
      pagamento.ano = 2009
      pagamento.usuario_corrente = usuarios(:quentin)
      pagamento.save!

      assert_difference 'Rateio.count', 3 do
        assert_difference 'LancamentoImposto.count', 3 do
          assert_difference 'ItensMovimento.count', 0 do
            pagamento.gerar_parcelas(2009)
            pagamento.parcelas[0].dados_do_rateio = {
              "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
              "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40,00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
              "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30,00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
            pagamento.parcelas[0].grava_itens_do_rateio(2009, pagamento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]

            pagamento.parcelas[0].dados_do_imposto = {
              "1"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{incide.id.to_s}#8.0", "valor_imposto"=>"500,00", "aliquota"=>"8,00"},
              "2"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{retem.id.to_s}#5.0", "valor_imposto"=>"70,00", "aliquota"=>"5,00"},
              "3"=>{"data_de_recolhimento"=>"12-03-2010", "imposto_id"=>"#{retem.id.to_s}#5.0", "valor_imposto"=>"15,00", "aliquota"=>"5,00"}}
            pagamento.parcelas[0].grava_dados_do_imposto_na_parcela(2009)
          end
        end
      end

      params = {'forma_de_pagamento' => Parcela::DINHEIRO, 'data_da_baixa' => '21/08/2009', 'historico' => 'Baixando sem provisão'}
      assert_difference 'ItensMovimento.count', 10 do
        pagamento.parcelas[0].baixar_parcela(2009, usuarios(:quentin), params).should == [true, "Baixa na parcela realizada com sucesso!"]
      end

      movimento = Movimento.first

      # DEBITOS
      debito1 = movimento.itens_movimentos[0]
      debito1.valor.should == 12500
      debito1.plano_de_conta.id.should == incide.conta_debito.id
      debito1.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito1.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      debito2 = movimento.itens_movimentos[1]
      debito2.valor.should == 5000
      debito2.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["conta_contabil_id"]
      debito2.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito2.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito3 = movimento.itens_movimentos[2]
      debito3.valor.should == 4000
      debito3.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["conta_contabil_id"]
      debito3.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito3.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      debito4 = movimento.itens_movimentos[3]
      debito4.valor.should == 3000
      debito4.plano_de_conta.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["conta_contabil_id"]
      debito4.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["unidade_organizacional_id"]
      debito4.centro.id.should == pagamento.parcelas[0].dados_do_rateio["3"]["centro_id"]

      debito5 = movimento.itens_movimentos[4]
      debito5.valor.should == 20835
      debito5.plano_de_conta.id.should == incide.conta_debito.id
      debito5.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["unidade_organizacional_id"]
      debito5.centro.id.should == pagamento.parcelas[0].dados_do_rateio["1"]["centro_id"]

      debito6 = movimento.itens_movimentos[5]
      debito6.valor.should == 16665
      debito6.plano_de_conta.id.should == incide.conta_debito.id
      debito6.unidade_organizacional.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["unidade_organizacional_id"]
      debito6.centro.id.should == pagamento.parcelas[0].dados_do_rateio["2"]["centro_id"]

      # CREDITOS
      credito1 = movimento.itens_movimentos[6]
      credito1.valor.should == 3500
      credito1.plano_de_conta.id.should == ContasCorrente.find_by_unidade_id_and_identificador(pagamento.unidade.id, ContasCorrente::CAIXA).conta_contabil.id
      credito1.unidade_organizacional.should == pagamento.unidade_organizacional
      credito1.centro.should == pagamento.centro

      credito2 = movimento.itens_movimentos[7]
      credito2.valor.should == 50000
      credito2.plano_de_conta.should == Imposto.find(pagamento.parcelas[0].dados_do_imposto["1"]["imposto_id"]).conta_credito
      credito2.unidade_organizacional.should == pagamento.unidade_organizacional
      credito2.centro.should == pagamento.centro

      credito3 = movimento.itens_movimentos[8]
      credito3.valor.should == 7000
      credito3.plano_de_conta.id.should == retem.conta_credito.id
      credito3.unidade_organizacional.id.should == pagamento.unidade_organizacional.id
      credito3.centro.id.should == pagamento.centro.id

      credito4 = movimento.itens_movimentos[9]
      credito4.valor.should == 1500
      credito4.plano_de_conta.id.should == retem.conta_credito.id
      credito4.unidade_organizacional.id.should == pagamento.unidade_organizacional.id
      credito4.centro.id.should == pagamento.centro.id
    end

  end

  describe "Testes da baixa parcial de parcela" do

    it "verifica se baixa parcialmente por Dinheiro e depois estornar" do
      Date.stub!(:today).and_return Date.new 2010, 02, 17
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all; Movimento.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"2", "dependente_id"=>"", "vigencia"=>"2",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"28/06/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"28/06/2009",
          "valor_do_documento_em_reais"=>"200,00", "dia_do_vencimento"=>"17",
          "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first

      params = {"parcela_data_da_baixa"=>"18/03/2010", "data_vencimento"=>"17/02/2010", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"",
              "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>"243949021", "prazo"=>"", "agencia"=>"",
              "conta_contabil_transitoria_nome"=>"", "nome_do_titular"=>"", "conta_contabil_transitoria_id"=>"",
              "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}},
        "id"=>recebimento.id, "valor_liquido"=>"10,00", "historico"=>"Teste de baixa com DINHEIRO",
        "parcela_conta_corrente_id"=>"", "parcela_conta_corrente_nome"=>"", "parcela_forma_de_pagamento"=>"1"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Movimento.count', 1 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            recebimento.parcelas.first.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
          end
        end
      end

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero}"
      nova_parcela.situacao.should == Parcela::QUITADA
      nova_parcela.valor.should == 700
      nova_parcela.movimentos.first.should == Movimento.last
      parcela_mae.reload
      parcela_mae.valor.should == 9300

      assert_difference 'Movimento.count', -1 do
        assert_difference 'Parcela.count', -1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Dinheiro").should == [true, "Parcela estornada com sucesso!"]
          end
        end
      end
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Banco e depois estornar" do
      Date.stub!(:today).and_return Date.new 2010, 02, 17
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"2", "dependente_id"=>"", "vigencia"=>"2",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"28/06/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"28/06/2009",
          "valor_do_documento_em_reais"=>"200,00", "dia_do_vencimento"=>"17",
          "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first

      params = {"parcela_data_da_baixa"=>"18/03/2010", "data_vencimento"=>"17/02/2010", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"", "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>"243949021", "prazo"=>"", "agencia"=>"",
              "conta_contabil_transitoria_nome"=>"", "nome_do_titular"=>"", "conta_contabil_transitoria_id"=>"",
              "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}},
        "id"=>recebimento.id, "valor_liquido"=>"10,00", "historico"=>"Teste de baixa com Cheque", "parcela_conta_corrente_id"=>contas_correntes(:primeira_conta).id,
        "parcela_conta_corrente_nome"=>"Conta Corrente do Senai Varzea Grande", "parcela_forma_de_pagamento"=>"2"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Movimento.count', 1 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            recebimento.parcelas.first.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
          end
        end
      end

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.valor.should == 700
      nova_parcela.conta_corrente.should == contas_correntes(:primeira_conta)
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero}"
      parcela_mae.reload
      parcela_mae.valor.should == 9300

      assert_difference 'Parcela.count', -1 do
        assert_difference 'HistoricoOperacao.count', 1 do
          nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Banco").should == [true, "Parcela estornada com sucesso!"]
        end
      end
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Cheque e depois estornar" do
      Date.stub!(:today).and_return Date.new 2010, 02, 17
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all; Movimento.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"2", "dependente_id"=>"", "vigencia"=>"2",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"28/06/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"28/06/2009",
          "valor_do_documento_em_reais"=>"200,00", "dia_do_vencimento"=>"17",
          "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first
      parcela_mae.cheques.blank?.should == true
      parcela_mae.cartoes.blank?.should == true
      params = {"parcela_data_da_baixa"=>"18/03/2010", "data_vencimento"=>"17/02/2010", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"", "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>bancos(:banco_caixa).id, "prazo"=>Cheque::VISTA, "agencia"=>"2933", "nome_do_titular"=>"Carlos Fernando", "conta_contabil_transitoria_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "conta"=>"222", "data_para_deposito"=>"25/03/2010", "numero"=>"111"}}},
        "id"=>recebimento.id, "valor_liquido"=>"10.00", "historico"=>"Teste de baixa com Cheque", "parcela_conta_corrente_id"=>"",
        "parcela_conta_corrente_nome"=>"", "parcela_forma_de_pagamento"=>"3"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Movimento.count', 1 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'Cheque.count', 1 do
            assert_difference 'HistoricoOperacao.count', 1 do
              recebimento.parcelas.first.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
            end
          end
        end
      end

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.valor.should == 700
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero}"
      parcela_mae.reload
      parcela_mae.valor.should == 9300
      nova_parcela.cheques.blank?.should == false
      nova_parcela.cartoes.blank?.should == true
      cheque = nova_parcela.cheques.first
      cheque.parcela.should == nova_parcela
      cheque.conta_contabil_transitoria.id.should == params["parcela"]["cheques_attributes"]["0"]["conta_contabil_transitoria_id"]
      cheque.agencia.should == params["parcela"]["cheques_attributes"]["0"]["agencia"]
      cheque.banco.id.should == params["parcela"]["cheques_attributes"]["0"]["banco_id"]
      cheque.prazo.should == params["parcela"]["cheques_attributes"]["0"]["prazo"]
      cheque.numero.should == params["parcela"]["cheques_attributes"]["0"]["numero"]
      cheque.conta.should == params["parcela"]["cheques_attributes"]["0"]["conta"]
      cheque.nome_do_titular.should == params["parcela"]["cheques_attributes"]["0"]["nome_do_titular"]
      cheque.data_para_deposito.should == params["parcela"]["cheques_attributes"]["0"]["data_para_deposito"]

      assert_difference 'Movimento.count', -1 do
        assert_difference 'Parcela.count', -1 do
          assert_difference 'Cheque.count', -1 do
            assert_difference 'HistoricoOperacao.count', 1 do
              nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Cheque").should == [true, "Parcela estornada com sucesso!"]
            end
          end
        end
      end
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Cartão e depois estornar" do
      Date.stub!(:today).and_return Date.new 2010, 02, 17
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"2", "dependente_id"=>"", "vigencia"=>"2",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"28/06/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"28/06/2009",
          "valor_do_documento_em_reais"=>"200,00", "dia_do_vencimento"=>"17",
          "rateio"=>"0", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first
      parcela_mae.cheques.blank?.should == true
      parcela_mae.cartoes.blank?.should == true
      params = {"parcela_data_da_baixa"=>"18/03/2010", "data_vencimento"=>"17/02/2010", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"Paulo Vitor",
              "codigo_de_seguranca"=>"222", "numero"=>"111", "bandeira"=>Cartao::VISACREDITO, "validade"=>"12/12"}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>"", "prazo"=>"", "agencia"=>"", "nome_do_titular"=>"", "conta_contabil_transitoria_id"=>'',
              "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}},
        "id"=>recebimento.id, "valor_liquido"=>"10,00", "historico"=>"Teste de baixa com Cartão", "parcela_conta_corrente_id"=>"",
        "parcela_conta_corrente_nome"=>"", "parcela_forma_de_pagamento"=>"4"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Movimento.count', 0 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'Cartao.count', 1 do
            assert_difference 'HistoricoOperacao.count', 1 do
              recebimento.parcelas.first.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
            end
          end
        end
      end

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.valor.should == 700
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero.to_i}"
      parcela_mae.reload
      parcela_mae.valor.should == 9300
      nova_parcela.cheques.blank?.should == true
      nova_parcela.cartoes.blank?.should == false
      cartao = nova_parcela.cartoes.first
      cartao.parcela.should == nova_parcela
      cartao.nome_do_titular.should == params["parcela"]["cartoes_attributes"]["1"]["nome_do_titular"]
      cartao.validade.should == params["parcela"]["cartoes_attributes"]["1"]["validade"]
      cartao.codigo_de_seguranca.should == params["parcela"]["cartoes_attributes"]["1"]["codigo_de_seguranca"]
      cartao.bandeira.should == params["parcela"]["cartoes_attributes"]["1"]["bandeira"]
      cartao.numero.should == params["parcela"]["cartoes_attributes"]["1"]["numero"]

      assert_difference 'Parcela.count', -1 do
        assert_difference 'Cartao.count', -1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Cartão").should == [true, "Parcela estornada com sucesso!"]
          end
        end
      end
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Dinheiro e depois estornar e TEM RATEIO" do
      Date.stub!(:today).and_return Date.new 2009, 03, 29
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all; Rateio.delete_all; Movimento.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"1", "dependente_id"=>"", "vigencia"=>"1",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"29/03/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"29/03/2009",
          "valor_do_documento_em_reais"=>"120,00", "dia_do_vencimento"=>"1",
          "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first

      params = {"parcela_data_da_baixa"=>"29/03/2010", "data_vencimento"=>"01/04/2009", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"",
              "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>"243949021", "prazo"=>"", "agencia"=>"",
              "conta_contabil_transitoria_nome"=>"", "nome_do_titular"=>"", "conta_contabil_transitoria_id"=>"",
              "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}},
        "id"=>recebimento.id, "valor_liquido"=>"50,00", "historico"=>"Teste de baixa com DINHEIRO", "parcela_conta_corrente_id"=>"",
        "parcela_conta_corrente_nome"=>"", "parcela_forma_de_pagamento"=>"1"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Rateio.count', 2 do
        recebimento.parcelas.first.dados_do_rateio = {
          "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
          "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40.00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
          "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
        parcela_mae.grava_itens_do_rateio(2009, recebimento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      end
      parcela_mae.reload
      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      assert_difference 'Rateio.count', 3 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            parcela_mae.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
          end
        end
      end
      Movimento.count.should == 1

      parcela_mae.reload
      parcela_mae.rateios[0].valor.should == 3658
      parcela_mae.rateios[1].valor.should == 2927
      parcela_mae.rateios[2].valor.should == 2194

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero.to_i} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero.to_i}"
      nova_parcela.situacao.should == Parcela::QUITADA
      nova_parcela.valor.should == 3221
      parcela_mae.reload
      parcela_mae.valor.should == 8779

      nova_parcela.rateios[0].valor.should == 1342
      nova_parcela.rateios[1].valor.should == 1073
      nova_parcela.rateios[2].valor.should == 806

      movimento = Movimento.last
      movimento.parcela_id.should == nova_parcela.id

      assert_difference 'Rateio.count', -3 do
        assert_difference 'Parcela.count', -1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Dinheiro").should == [true, "Parcela estornada com sucesso!"]
          end
        end
      end
      Movimento.count.should == 0

      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Banco e depois estornar e TEM RATEIO" do
      Date.stub!(:today).and_return Date.new 2009, 03, 29
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all; Rateio.delete_all; Movimento.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"1", "dependente_id"=>"", "vigencia"=>"1",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"29/03/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"29/03/2009",
          "valor_do_documento_em_reais"=>"120,00", "dia_do_vencimento"=>"1",
          "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first

      params = {"parcela_data_da_baixa"=>"29/03/2010", "data_vencimento"=>"01/04/2009", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"",
              "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>"243949021", "prazo"=>"", "agencia"=>"",
              "conta_contabil_transitoria_nome"=>"", "nome_do_titular"=>"", "conta_contabil_transitoria_id"=>"",
              "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}},
        "id"=>recebimento.id, "valor_liquido"=>"50,00", "historico"=>"Teste de baixa com DINHEIRO",
        "parcela_conta_corrente_id"=>contas_correntes(:primeira_conta).id,
        "parcela_conta_corrente_nome"=>"Conta Corrente do Senai Varzea Grande", "parcela_forma_de_pagamento"=>"2"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Rateio.count', 2 do
        recebimento.parcelas.first.dados_do_rateio = {
          "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
          "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40.00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
          "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
        parcela_mae.grava_itens_do_rateio(2009, recebimento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      end

      parcela_mae.rateios.reload
      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      assert_difference 'Rateio.count', 3 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            parcela_mae.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
          end
        end
      end
      Movimento.count.should == 1

      parcela_mae.rateios.reload
      parcela_mae.rateios[0].valor.should == 3658
      parcela_mae.rateios[1].valor.should == 2927
      parcela_mae.rateios[2].valor.should == 2194

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero}"
      nova_parcela.situacao.should == Parcela::QUITADA
      nova_parcela.valor.should == 3221
      parcela_mae.reload
      parcela_mae.valor.should == 8779

      nova_parcela.rateios[0].valor.should == 1342
      nova_parcela.rateios[1].valor.should == 1073
      nova_parcela.rateios[2].valor.should == 806

      movimento = Movimento.last
      movimento.parcela_id.should == nova_parcela.id

      assert_difference 'Rateio.count', -3 do
        assert_difference 'Parcela.count', -1 do
          assert_difference 'HistoricoOperacao.count', 1 do
            nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Banco").should == [true, "Parcela estornada com sucesso!"]
          end
        end
      end
      Movimento.count.should == 0

      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Cheque e depois estornar e TEM RATEIO" do
      Date.stub!(:today).and_return Date.new 2009, 03, 29
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all; Rateio.delete_all; Movimento.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"1", "dependente_id"=>"", "vigencia"=>"1",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"29/03/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"29/03/2009",
          "valor_do_documento_em_reais"=>"120,00", "dia_do_vencimento"=>"1",
          "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande),
          "data_inicio_servico" => "2000-01-01", "data_final_servico" => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first

      params = {"parcela_data_da_baixa"=>"29/03/2010", "data_vencimento"=>"01/04/2009", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"",
              "codigo_de_seguranca"=>"", "numero"=>"", "bandeira"=>"", "validade"=>""}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>bancos(:banco_caixa).id, "prazo"=>Cheque::VISTA, "agencia"=>"2933",
              "nome_do_titular"=>"Carlos Fernando", "conta_contabil_transitoria_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
              "conta"=>"222", "data_para_deposito"=>"30/03/2010", "numero"=>"111"}}},
        "id"=>recebimento.id, "valor_liquido"=>"50,00", "historico"=>"Teste de baixa com Cheque",
        "parcela_conta_corrente_id"=>"", "parcela_conta_corrente_nome"=>"", "parcela_forma_de_pagamento"=>"3"}

      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Rateio.count', 2 do
        recebimento.parcelas.first.dados_do_rateio = {
          "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
          "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40.00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
          "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
        parcela_mae.grava_itens_do_rateio(2009, recebimento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      end

      parcela_mae.rateios.reload
      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      assert_difference 'Rateio.count', 3 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'Cheque.count', 1 do
            assert_difference 'HistoricoOperacao.count', 1 do
              parcela_mae.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
            end
          end
        end
      end
      Movimento.count.should == 1

      parcela_mae.rateios.reload
      parcela_mae.rateios[0].valor.should == 3658
      parcela_mae.rateios[1].valor.should == 2927
      parcela_mae.rateios[2].valor.should == 2194

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.valor.should == 3221
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero.to_i}"
      parcela_mae.reload
      parcela_mae.valor.should == 8779
      nova_parcela.rateios[0].valor.should == 1342
      nova_parcela.rateios[1].valor.should == 1073
      nova_parcela.rateios[2].valor.should == 806
      nova_parcela.cheques.blank?.should == false
      nova_parcela.cartoes.blank?.should == true
      cheque = nova_parcela.cheques.first
      cheque.parcela.should == nova_parcela
      cheque.conta_contabil_transitoria.id.should == params["parcela"]["cheques_attributes"]["0"]["conta_contabil_transitoria_id"]
      cheque.agencia.should == params["parcela"]["cheques_attributes"]["0"]["agencia"]
      cheque.banco.id.should == params["parcela"]["cheques_attributes"]["0"]["banco_id"]
      cheque.prazo.should == params["parcela"]["cheques_attributes"]["0"]["prazo"]
      cheque.numero.should == params["parcela"]["cheques_attributes"]["0"]["numero"]
      cheque.conta.should == params["parcela"]["cheques_attributes"]["0"]["conta"]
      cheque.nome_do_titular.should == params["parcela"]["cheques_attributes"]["0"]["nome_do_titular"]
      cheque.data_para_deposito.should == params["parcela"]["cheques_attributes"]["0"]["data_para_deposito"]

      movimento = Movimento.last
      movimento.parcela_id.should == nova_parcela.id

      assert_difference 'Rateio.count', -3 do
        assert_difference 'Parcela.count', -1 do
          assert_difference 'Cheque.count', -1 do
            assert_difference 'HistoricoOperacao.count', 1 do
              nova_parcela.estorna_parcela(usuarios(:quentin), "Estornando baixa em Cheque").should == [true, "Parcela estornada com sucesso!"]
            end
          end
        end
      end
      Movimento.count.should == 0

      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == []
      HistoricoOperacao.last.descricao.should == "Parcela #{nova_parcela.numero_parcela_filha} estornada"
    end


    it "verifica se baixa parcialmente por Cartão e depois estornar e TEM RATEIO" do
      Date.stub!(:today).and_return Date.new 2009, 03, 29
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all; Rateio.delete_all
      recebimento = RecebimentoDeConta.new({"numero_de_parcelas"=>"1", "dependente_id"=>"", "vigencia"=>"1",
          "cobrador_id"=>"", "centro_id"=>centros(:centro_forum_financeiro).id,
          "nome_centro"=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          "numero_nota_fiscal"=>"12345", "multa_por_atraso"=>"2.0000", "nome_pessoa"=>"Juan Vitor dos Santos Zeferino",
          "nome_conta_contabil_receita"=>"21010101009 - Fornecedores a Pagar", "nome_servico"=>"Curso de Corel do Paulo", "servico_id"=>servicos(:curso_de_corel).id, "tipo_de_documento"=>"CPMF",
          "juros_por_atraso"=>"1.0000", "nome_vendedor"=>"Rafael Felipe Koch", "data_inicio"=>"29/03/2009",
          "conta_contabil_receita_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          "historico"=>"Pagamento Cartão - 9999 - FTG Tecnologia", "nome_cobrador"=>"",
          "vendedor_id"=>pessoas(:rafael).id, "nome_unidade_organizacional"=>"131344278639 - Senai Novo",
          "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          "pessoa_id"=>pessoas(:inovare).id, "origem"=>"Interna", "data_venda"=>"29/03/2009",
          "valor_do_documento_em_reais"=>"120,00", "dia_do_vencimento"=>"1",
          "rateio"=>"1", "unidade"=>unidades(:senaivarzeagrande),
          'data_inicio_servico' => "2000-01-01", 'data_final_servico' => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      parcela_mae = recebimento.parcelas.first
      parcela_mae.cheques.blank?.should == true
      parcela_mae.cartoes.blank?.should == true

      params = {"parcela_data_da_baixa"=>"29/03/2010", "data_vencimento"=>"01/04/2009", "recebimento_de_conta_id"=>recebimento.id,
        "parcela_id"=>parcela_mae.id, "parcela"=>{"cartoes_attributes"=> {"1"=>{"nome_do_titular"=>"Paulo Vitor",
              "codigo_de_seguranca"=>"222", "numero"=>"111", "bandeira"=>Cartao::VISACREDITO, "validade"=>"12/12"}},
          "cheques_attributes"=>{"0"=>{"banco_id"=>"", "prazo"=>"", "agencia"=>"", "nome_do_titular"=>"",
              "conta_contabil_transitoria_id"=>'', "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}},
        "id"=>recebimento.id, "valor_liquido"=>"50,00", "historico"=>"Teste de baixa com Cartão",
        "parcela_conta_corrente_id"=>"", "parcela_conta_corrente_nome"=>"", "parcela_forma_de_pagamento"=>"4"}
      Gefin.calcular_juros_e_multas(:vencimento => params["data_vencimento"], :data_base => params["parcela_data_da_baixa"],
        :multa => recebimento.multa_por_atraso, :juros => recebimento.juros_por_atraso,
        :valor => parcela_mae.valor)[2]

      assert_difference 'Rateio.count', 2 do
        recebimento.parcelas.first.dados_do_rateio = {
          "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
          "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"40.00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
          "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"30.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
        parcela_mae.grava_itens_do_rateio(2009, recebimento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      end

      parcela_mae.rateios.reload
      parcela_mae.rateios[0].valor.should == 5000
      parcela_mae.rateios[1].valor.should == 4000
      parcela_mae.rateios[2].valor.should == 3000

      assert_difference 'Rateio.count', 3 do
        assert_difference 'Parcela.count', 1 do
          assert_difference 'Cartao.count', 1 do
            assert_difference 'HistoricoOperacao.count', 1 do
              recebimento.parcelas.first.baixar_parcialmente(2009, recebimento.usuario_corrente, params).should == [true, "Baixa parcial realizada com sucesso!"]
            end
          end
        end
      end

      parcela_mae.rateios.reload
      parcela_mae.rateios[0].valor.should == 3658
      parcela_mae.rateios[1].valor.should == 2927
      parcela_mae.rateios[2].valor.should == 2194

      nova_parcela = Parcela.last
      Parcela.find(:all, :conditions => ['parcela_mae_id = ?', parcela_mae]).should == [nova_parcela]
      HistoricoOperacao.last.descricao.should == "Parcela #{parcela_mae.numero} baixada parcialmente (#{nova_parcela.numero_parcela_filha})"
      nova_parcela.parcela_mae_id.should == parcela_mae.id
      nova_parcela.valor.should == 3221
      nova_parcela.numero_parcela_filha.should == "#{parcela_mae.numero.to_i}"
      parcela_mae.reload
      parcela_mae.valor.should == 8779
      nova_parcela.rateios[0].valor.should == 1342
      nova_parcela.rateios[1].valor.should == 1073
      nova_parcela.rateios[2].valor.should == 806
      nova_parcela.cheques.blank?.should == true
      nova_parcela.cartoes.blank?.should == false
      cartao = nova_parcela.cartoes.first
      cartao.parcela.should == nova_parcela
      cartao.nome_do_titular.should == params["parcela"]["cartoes_attributes"]["1"]["nome_do_titular"]
      cartao.validade.should == params["parcela"]["cartoes_attributes"]["1"]["validade"]
      cartao.codigo_de_seguranca.should == params["parcela"]["cartoes_attributes"]["1"]["codigo_de_seguranca"]
      cartao.bandeira.should == params["parcela"]["cartoes_attributes"]["1"]["bandeira"]
      cartao.numero.should == params["parcela"]["cartoes_attributes"]["1"]["numero"]

      movimento_cartao = Movimento.last
      movimento_cartao.itens_movimentos.should == []

      Cartao.baixar(2009, {'ids' => [nova_parcela.cartoes.first.id], 'data_do_deposito' => '16/06/2009',
          'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id, 'historico' => 'BAIXANDO UM CARTÃO'}, unidades(:senaivarzeagrande).id).should == [true, "Dados baixados com sucesso!"]

      movimento_cartao = Movimento.last
      movimento_cartao.itens_movimentos.should_not == []
      movimento_cartao.itens_movimentos[1].valor.should == 1342
      movimento_cartao.itens_movimentos[2].valor.should == 1073
      movimento_cartao.itens_movimentos[3].valor.should == 806
    end

  end


  describe 'testa projeção' do

    it 'para a funcao aplicar_projecao' do
      usuario = usuarios(:quentin)
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      primeira_parcela = parcelas(:primeira_parcela_recebimento)
      segunda_parcela = parcelas(:segunda_parcela_recebimento)

      hash_com_dados_do_params = {:parcelas => {
          segunda_parcela.id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '05/08/2010',
            :indice => '1.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.30',
            :valor_liquido_em_reais => '30.30', :selecionada => '1', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'},
          primeira_parcela.id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '05/07/2010',
            :indice => '1.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.30',
            :valor_liquido_em_reais => '30.30', :selecionada => '1', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'}
        }}

      Parcela.aplicar_projecao(conta.id, hash_com_dados_do_params, usuario).should == [true, "Projeção aplicada com sucesso!"]

      conta.reload
      primeira_parcela.reload
      segunda_parcela.reload

      conta.parcelas.count.should == 4
      conta.projetando.should == true
      conta.valor_do_documento.should == 6060

      primeira_parcela.data_vencimento.should == '05/07/2009'
      primeira_parcela.valor.should == 3000
      primeira_parcela.situacao.should == Parcela::RENEGOCIADA

      segunda_parcela.data_vencimento.should == '05/08/2009'
      segunda_parcela.valor.should == 3000
      segunda_parcela.situacao.should == Parcela::RENEGOCIADA

      novas_parcelas = conta.parcelas

      novas_parcelas[2].data_vencimento.should == '05/07/2010'
      novas_parcelas[2].valor.should == 3030
      novas_parcelas[2].situacao.should == Parcela::PENDENTE
      novas_parcelas[2].numero.should == 3.to_s
      novas_parcelas[2].percentual_de_desconto.should == 0

      novas_parcelas[3].data_vencimento.should == '05/08/2010'
      novas_parcelas[3].valor.should == 3030
      novas_parcelas[3].situacao.should == Parcela::PENDENTE
      novas_parcelas[3].numero.should == 4.to_s
      novas_parcelas[3].percentual_de_desconto.should == 0

      conta.historico_projecoes.should == [[1, [novas_parcelas[2].id, novas_parcelas[3].id]]]

      # Vou aplicar a projeção denovo para verificar se o historico de projecoes será incrementado

      outro_hash_com_dados_do_params = {:parcelas => {
          novas_parcelas[3].id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '05/08/2010',
            :indice => '1.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.30',
            :valor_liquido_em_reais => '30.60', :selecionada => '1', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.30'},
          novas_parcelas[2].id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '05/07/2010',
            :indice => '1.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.30',
            :valor_liquido_em_reais => '30.60', :selecionada => '1', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.30'}
        }}

      Parcela.aplicar_projecao(conta.id, outro_hash_com_dados_do_params, usuario).should == [true, "Projeção aplicada com sucesso!"]

      conta.reload

      outras_novas_parcelas = conta.parcelas
      conta.historico_projecoes.should == [[1, [outras_novas_parcelas[2].id, outras_novas_parcelas[3].id]],
        [2, [outras_novas_parcelas[4].id, outras_novas_parcelas[5].id]]]
    end

    it 'para a funcao aplicar_projecao apenas para as selecionadas' do
      usuario = usuarios(:quentin)
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      primeira_parcela = parcelas(:primeira_parcela_recebimento)
      segunda_parcela = parcelas(:segunda_parcela_recebimento)

      hash_com_dados_do_params = {:parcelas => {
          segunda_parcela.id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '05/08/2010',
            :indice => '1.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.30',
            :valor_liquido_em_reais => '30.30', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'},
          primeira_parcela.id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '05/07/2010',
            :indice => '1.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.30',
            :valor_liquido_em_reais => '30.30', :selecionada => '1', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'}
        }}

      Parcela.aplicar_projecao(conta.id, hash_com_dados_do_params, usuario).should == [true, "Projeção aplicada com sucesso!"]

      conta.reload
      primeira_parcela.reload
      segunda_parcela.reload

      conta.parcelas.count.should == 3
      conta.projetando.should == true
      conta.valor_do_documento.should == 6030

      primeira_parcela.data_vencimento.should == '05/07/2009'
      primeira_parcela.valor.should == 3000
      primeira_parcela.situacao.should == Parcela::RENEGOCIADA

      segunda_parcela.data_vencimento.should == '05/08/2009'
      segunda_parcela.valor.should == 3000
      segunda_parcela.situacao.should == Parcela::PENDENTE

      novas_parcelas = conta.parcelas

      novas_parcelas[2].data_vencimento.should == '05/07/2010'
      novas_parcelas[2].valor.should == 3030
      novas_parcelas[2].situacao.should == Parcela::PENDENTE
      novas_parcelas[2].numero.should == 3.to_s
      novas_parcelas[2].percentual_de_desconto.should == 0

      conta.historico_projecoes.should == [[1, [novas_parcelas[2].id]]]
    end

    it 'em parcelas que tem rateios' do
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all
      recebimento = RecebimentoDeConta.new({:numero_de_parcelas=>"2", :dependente_id=>"", :vigencia=>"2",
          :cobrador_id=>"", :centro_id=>centros(:centro_forum_financeiro).id,
          :nome_centro=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          :numero_nota_fiscal=>"12345", :multa_por_atraso=>"2.0000", :nome_pessoa=>"Juan Vitor dos Santos Zeferino",
          :nome_conta_contabil_receita =>"21010101009 - Fornecedores a Pagar", :nome_servico=>"Curso de Corel do Paulo", :servico_id=>servicos(:curso_de_corel).id, :tipo_de_documento=>"CPMF",
          :juros_por_atraso=>"1.0000", :nome_vendedor=>"Rafael Felipe Koch", :data_inicio=>"28/06/2009",
          :conta_contabil_receita_id=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          :historico=>"Pagamento Cartão - 9999 - FTG Tecnologia", :nome_cobrador=>"",
          :vendedor_id=>pessoas(:rafael).id, :nome_unidade_organizacional=>"131344278639 - Senai Novo",
          :unidade_organizacional_id=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          :pessoa_id=>pessoas(:inovare).id, :origem=>"Interna", :data_venda=>"28/06/2009",
          :valor_do_documento_em_reais=>"200.00", :dia_do_vencimento=>"17",
          :rateio=>"1", :unidade=>unidades(:senaivarzeagrande),
          :data_inicio_servico => "2000-01-01", :data_final_servico => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      recebimento.parcelas[0].dados_do_rateio = {
        "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"50.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
        "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"25.00", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
        "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"25.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
      recebimento.parcelas[0].grava_itens_do_rateio(2009, recebimento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]

      hash_com_dados_do_params = {:parcelas => {
          recebimento.parcelas[0].id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '17/07/2009',
            :indice => '0.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '0.00',
            :valor_liquido_em_reais => '105.00', :desconto_em_porcentagem => '0.00',
            :valor_dos_juros_em_reais => '5.00', :preco_em_reais => '100.00', :selecionada => '1'}
        }}

      recebimento.reload

      Parcela.aplicar_projecao(recebimento.id, hash_com_dados_do_params, usuarios(:quentin)).should == [true, "Projeção aplicada com sucesso!"]

      recebimento.reload

      novas_parcelas = recebimento.parcelas

      novas_parcelas.length.should == 3

      novas_parcelas[0].data_vencimento.should == '17/07/2009'
      novas_parcelas[0].valor.should == 10000
      novas_parcelas[0].situacao.should == Parcela::RENEGOCIADA

      novas_parcelas[1].data_vencimento.should == '17/08/2009'
      novas_parcelas[1].valor.should == 10000
      novas_parcelas[1].situacao.should == Parcela::PENDENTE

      novas_parcelas[2].data_vencimento.should == '17/07/2009'
      novas_parcelas[2].valor.should == 10500
      novas_parcelas[2].situacao.should == Parcela::PENDENTE
      novas_parcelas[2].numero.should == 3.to_s
      novas_parcelas[2].percentual_de_desconto.should == 0

      recebimento.historico_projecoes.should == [[1, [novas_parcelas[2].id]]]

      rateios_da_nova_parcela = novas_parcelas[2].rateios
      rateios_da_nova_parcela[0].conta_contabil_id.should == plano_de_contas(:plano_de_contas_para_boleto).id
      rateios_da_nova_parcela[0].centro_id.should == centros(:centro_forum_financeiro).id
      rateios_da_nova_parcela[0].unidade_organizacional_id.should == unidade_organizacionais(:senai_unidade_organizacional_nova).id
      rateios_da_nova_parcela[0].valor.should == 5250

      rateios_da_nova_parcela[1].valor.should == 2625

      rateios_da_nova_parcela[2].valor.should == 2625
    end

    it 'em parcelas que tem rateios com valores quebrados' do
      Parcela.delete_all; RecebimentoDeConta.delete_all; HistoricoOperacao.delete_all
      recebimento = RecebimentoDeConta.new({:numero_de_parcelas=>"2", :dependente_id=>"", :vigencia=>"2",
          :cobrador_id=>"", :centro_id=>centros(:centro_forum_financeiro).id,
          :nome_centro=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          :numero_nota_fiscal=>"12345", :multa_por_atraso=>"2.0000", :nome_pessoa=>"Juan Vitor dos Santos Zeferino",
          :nome_conta_contabil_receita =>"21010101009 - Fornecedores a Pagar", :nome_servico=>"Curso de Corel do Paulo", :servico_id=>servicos(:curso_de_corel).id, :tipo_de_documento=>"CPMF",
          :juros_por_atraso=>"1.0000", :nome_vendedor=>"Rafael Felipe Koch", :data_inicio=>"28/06/2009",
          :conta_contabil_receita_id=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          :historico=>"Pagamento Cartão - 9999 - FTG Tecnologia", :nome_cobrador=>"",
          :vendedor_id=>pessoas(:rafael).id, :nome_unidade_organizacional=>"131344278639 - Senai Novo",
          :unidade_organizacional_id=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          :pessoa_id=>pessoas(:inovare).id, :origem=>"Interna", :data_venda=>"28/06/2009",
          :valor_do_documento_em_reais=>"217.17", :dia_do_vencimento=>"17",
          :rateio=>"1", :unidade=>unidades(:senaivarzeagrande),
          :data_inicio_servico => "2000-01-01", :data_final_servico => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)
      recebimento.parcelas[1].dados_do_rateio = {
        "1"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_para_boleto).id, "centro_id"=>centros(:centro_forum_financeiro).id, "unidade_organizacional_nome"=>"131344278639 - Senai Novo", "valor"=>"23.55", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional_nova).id, "conta_contabil_nome"=>"22343456 - Conta Contábil SENAI Caixa", "centro_nome"=>"124453343 - Forum Serviço Financeiro"},
        "2"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "centro_id"=>centros(:centro_empresa).id, "unidade_organizacional_nome"=>"999999999999 - Unidade Empresa", "valor"=>"57.27", "unidade_organizacional_id"=>unidade_organizacionais(:unidade_organizacional_empresa).id, "conta_contabil_nome"=>"11010102001 - Conta bancária no Banco do Brasil", "centro_nome"=>"999999999 - CENTRO EMPRESA"},
        "3"=>{"conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_despesas).id, "centro_id"=>centros(:centro_forum_economico).id, "unidade_organizacional_nome"=>"134234239039 - Senai Matriz", "valor"=>"27.77", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_nome"=>"21010101009 - Fornecedores a Pagar", "centro_nome"=>"4567456344 - Forum Serviço Economico"}}
      recebimento.parcelas[1].grava_itens_do_rateio(2009, recebimento.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]

      hash_com_dados_do_params = {:parcelas => {
          recebimento.parcelas[1].id => {:valor_da_multa_em_reais => '0.00', :data_vencimento => '17/07/2009',
            :indice => '8.00', :retorna_valor_de_correcao_pelo_indice_em_reais => '2.40',
            :valor_liquido_em_reais => '110.99', :desconto_em_porcentagem => '100.00',
            :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '108.59', :selecionada => '1'}
        }}

      recebimento.reload

      Parcela.aplicar_projecao(recebimento.id, hash_com_dados_do_params, usuarios(:quentin)).should == [false, "O vencimento da nova parcela deve ser igual ou superior ao vencimento da parcela antiga."]

      recebimento.reload

      novas_parcelas = recebimento.parcelas

      novas_parcelas.length.should == 2

      novas_parcelas[0].data_vencimento.should == '17/07/2009'
      novas_parcelas[0].valor.should == 10858
      novas_parcelas[0].situacao.should == Parcela::PENDENTE

      novas_parcelas[1].data_vencimento.should == '17/08/2009'
      novas_parcelas[1].valor.should == 10859
      novas_parcelas[1].situacao.should == Parcela::PENDENTE

      rateios_da_nova_parcela = novas_parcelas[1].rateios
      rateios_da_nova_parcela[0].conta_contabil_id.should == plano_de_contas(:plano_de_contas_para_boleto).id
      rateios_da_nova_parcela[0].centro_id.should == centros(:centro_forum_financeiro).id
      rateios_da_nova_parcela[0].unidade_organizacional_id.should == unidade_organizacionais(:senai_unidade_organizacional_nova).id
      rateios_da_nova_parcela[0].valor.should == 2355
      rateios_da_nova_parcela[1].valor.should == 5727
      rateios_da_nova_parcela[2].valor.should == 2777
    end

    it 'calcula desconto em juros e multas para a baixa' do
      Date.stub!(:today).and_return Date.new 2010, 3, 26
      recebimento = RecebimentoDeConta.new({:numero_de_parcelas=>"2", :dependente_id=>"", :vigencia=>"2",
          :cobrador_id=>"", :centro_id=>centros(:centro_forum_financeiro).id,
          :nome_centro=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          :numero_nota_fiscal=>"12345", :multa_por_atraso=>"2.0000", :nome_pessoa=>"Juan Vitor dos Santos Zeferino",
          :nome_conta_contabil_receita =>"21010101009 - Fornecedores a Pagar", :nome_servico=>"Curso de Corel do Paulo", :servico_id=>servicos(:curso_de_corel).id, :tipo_de_documento=>"CPMF",
          :juros_por_atraso=>"1.0000", :nome_vendedor=>"Rafael Felipe Koch", :data_inicio=>"28/06/2009",
          :conta_contabil_receita_id=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          :historico=>"Pagamento Cartão - 9999 - FTG Tecnologia", :nome_cobrador=>"",
          :vendedor_id=>pessoas(:rafael).id, :nome_unidade_organizacional=>"131344278639 - Senai Novo",
          :unidade_organizacional_id=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          :pessoa_id=>pessoas(:inovare).id, :origem=>"Interna", :data_venda=>"28/06/2009",
          :valor_do_documento_em_reais=>"200.00", :dia_do_vencimento=>"17",
          :rateio=>"1", :unidade=>unidades(:senaivarzeagrande),
          :data_inicio_servico => "2000-01-01", :data_final_servico => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)

      primeira_parcela, segunda_parcela = recebimento.parcelas

      primeira_parcela.situacao_verbose.should == 'Em atraso'
      primeira_parcela.valor_dos_juros.should == 0
      primeira_parcela.valor_da_multa.should == 0
      primeira_parcela.calcular_juros_e_multas!
      primeira_parcela.valor_dos_juros.should == 877
      primeira_parcela.valor_da_multa.should == 200
      primeira_parcela.reload

      # Atribui um percentual de desconto (como se estivesse vindo das projeções)
      primeira_parcela.percentual_de_desconto = 10

      primeira_parcela.calcula_desconto_em_juros_e_multas!.should == nil
      primeira_parcela.valor_dos_juros.should == 790
      primeira_parcela.valor_da_multa.should == 180
      primeira_parcela.valor_do_desconto.should == 107
    end

    it 'calcula desconto em juros e multas com desconto nil' do
      Date.stub!(:today).and_return Date.new 2010, 3, 26
      recebimento = RecebimentoDeConta.new({:numero_de_parcelas=>"2", :dependente_id=>"", :vigencia=>"2",
          :cobrador_id=>"", :centro_id=>centros(:centro_forum_financeiro).id,
          :nome_centro=>"124453343 - Forum Serviço Financeiro", "nome_dependente"=>"",
          :numero_nota_fiscal=>"12345", :multa_por_atraso=>"2.0000", :nome_pessoa=>"Juan Vitor dos Santos Zeferino",
          :nome_conta_contabil_receita =>"21010101009 - Fornecedores a Pagar", :nome_servico=>"Curso de Corel do Paulo", :servico_id=>servicos(:curso_de_corel).id, :tipo_de_documento=>"CPMF",
          :juros_por_atraso=>"1.0000", :nome_vendedor=>"Rafael Felipe Koch", :data_inicio=>"28/06/2009",
          :conta_contabil_receita_id=>plano_de_contas(:plano_de_contas_ativo_despesas).id,
          :historico=>"Pagamento Cartão - 9999 - FTG Tecnologia", :nome_cobrador=>"",
          :vendedor_id=>pessoas(:rafael).id, :nome_unidade_organizacional=>"131344278639 - Senai Novo",
          :unidade_organizacional_id=>unidade_organizacionais(:senai_unidade_organizacional_nova).id,
          :pessoa_id=>pessoas(:inovare).id, :origem=>"Interna", :data_venda=>"28/06/2009",
          :valor_do_documento_em_reais=>"200.00", :dia_do_vencimento=>"17",
          :rateio=>"1", :unidade=>unidades(:senaivarzeagrande),
          :data_inicio_servico => "2000-01-01", :data_final_servico => '2020-12-31'})
      recebimento.ano = 2009
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.save!
      recebimento.gerar_parcelas(2009)

      primeira_parcela, segunda_parcela = recebimento.parcelas

      primeira_parcela.situacao_verbose.should == 'Em atraso'
      primeira_parcela.valor_dos_juros.should == 0
      primeira_parcela.valor_da_multa.should == 0
      primeira_parcela.calcular_juros_e_multas!
      primeira_parcela.valor_dos_juros.should == 877
      primeira_parcela.valor_da_multa.should == 200
      primeira_parcela.reload

      # Atribui um percentual de desconto (como se estivesse vindo das projeções)
      primeira_parcela.percentual_de_desconto = nil

      primeira_parcela.calcula_desconto_em_juros_e_multas!.should == nil
      primeira_parcela.valor_dos_juros.should == 877
      primeira_parcela.valor_da_multa.should == 200
      primeira_parcela.valor_do_desconto.should == 0
    end

    it 'nao calcula desconto em juros e multas se a parcela ja estiver baixada' do
      parcela = parcelas(:primeira_parcela_recebida_cheque_a_vista)
      parcela.calcula_desconto_em_juros_e_multas!.should == nil
      parcela.changed?.should == false
    end

    it 'nao calcula desconto em juros e multas se for um pagamento de conta' do
      parcela = parcelas(:terceira_parcela_sesi)
      parcela.calcula_desconto_em_juros_e_multas!.should == nil
      parcela.changed?.should == false
    end

  end

end
