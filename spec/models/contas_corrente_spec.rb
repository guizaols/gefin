require File.dirname(__FILE__) + '/../spec_helper'

describe ContasCorrente do
  before(:each) do
    @contas_corrente = ContasCorrente.new
  end

  it "should be valid" do
    @contas_corrente = ContasCorrente.new
    @contas_corrente.should_not be_valid
    @contas_corrente.errors.on(:descricao).should_not be_nil
    @contas_corrente.errors.on(:unidade).should == "é inválido."
    @contas_corrente.errors.on(:unidade).should_not be_nil
    @contas_corrente.errors.on(:conta_contabil).should == "é inválido."
    @contas_corrente.errors.on(:conta_contabil).should_not be_nil
    @contas_corrente.valid?

    @contas_corrente = ContasCorrente.new :descricao => "Conta do Senai", :unidade => unidades(:senaivarzeagrande), :conta_contabil => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :identificador => 0,:saldo_inicial=>100,:saldo_atual=>100
    @contas_corrente.should be_valid
  end

  it "testa validates se identificador = BANCO" do
    @contas_corrente = ContasCorrente.new :identificador => ContasCorrente::BANCO
    @contas_corrente.should_not be_valid
    @contas_corrente.errors.on(:numero_conta).should_not be_nil
    @contas_corrente.errors.on(:numero_conta).should == "é inválido."

    @contas_corrente.numero_conta = '123'
    @contas_corrente.digito_verificador = '9'
    @contas_corrente.valid?
    @contas_corrente.errors.on(:numero_conta).should be_nil
    @contas_corrente.errors.on(:digito_verificador).should be_nil

    ["1", "5", "X", "B"].each do |dv|
      @contas_corrente.digito_verificador = dv
      @contas_corrente.valid?
      @contas_corrente.errors.on(:digito_verificador).should be_nil
    end

    ["11", "X1", "Xb", "1n"].each do |dv|
      @contas_corrente.digito_verificador = dv
      @contas_corrente.valid?
      @contas_corrente.errors.on(:digito_verificador).should == "é inválido."
    end

    @contas_corrente.numero_conta = 'ABC'
    @contas_corrente.digito_verificador = '10'
    @contas_corrente.valid?
    @contas_corrente.errors.on(:numero_conta).should == 'é inválido.'
    @contas_corrente.errors.on(:digito_verificador).should == 'é inválido.'

    @contas_corrente.errors.on(:digito_verificador).should_not be_nil
    @contas_corrente.errors.on(:digito_verificador).should == "é inválido."
    @contas_corrente.errors.on(:agencia).should_not be_nil
    @contas_corrente.errors.on(:agencia).should == "é inválido."
    @contas_corrente.valid?

    @contas_corrente = ContasCorrente.new :saldo_inicial=>1,:saldo_atual=>1,:numero_conta => "2353", :digito_verificador => "9", :agencia => agencias(:centro), :descricao => "Conta do Senai", :unidade => unidades(:senaivarzeagrande), :conta_contabil => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :identificador => 1
    @contas_corrente.should be_valid
  end
  
  it "teste de relacionamento" do
    conta_corrente = contas_correntes(:primeira_conta)
    conta_corrente.agencia.should == agencias(:centro)
    conta_corrente.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    conta_corrente.unidade.should == unidades(:senaivarzeagrande)
  end
  
  it "teste que verifica quando um objeto com ativo é igual a true" do
    @contas_corrente = ContasCorrente.new
    @contas_corrente.ativo.should == true
    @contas_corrente = ContasCorrente.new :ativo => false
    @contas_corrente.ativo.should == false
  end
  
  it "teste de campo virtual" do
    @contas_corrente = ContasCorrente.new
    @contas_corrente.saldo_inicial_em_reais.should == nil
    @contas_corrente.saldo_atual_em_reais.should == nil
    c = contas_correntes(:primeira_conta)
    c.saldo_inicial_em_reais.should == "10,00"
    c.saldo_atual_em_reais.should == "50,00"

    c.saldo_inicial_em_reais = "20,00"
    c.saldo_atual_em_reais = "30,00"
    c.valid?
    c.saldo_inicial.should == 2000
    c.saldo_atual.should == 3000
  end
  
  it "teste de campo virtual nome_identificador" do
    @contas_corrente = ContasCorrente.new
    @contas_corrente.nome_identificador.should == nil
    @contas_corrente.nome_identificador = "teste"
    @contas_corrente.nome_identificador.should == nil
    @contas_corrente.identificador = 0
    @contas_corrente.nome_identificador.should == "Caixa"
    @contas_corrente.identificador = 1
    @contas_corrente.nome_identificador.should == "Banco"
  end
  
  it "teste de validação para saldo inicial negativo" do
    @contas_corrente = contas_correntes(:primeira_conta)
    @contas_corrente.saldo_inicial = -100
    @contas_corrente.should_not be_valid
    @contas_corrente.errors.on(:saldo_inicial).should ==  "deve ser maior do que zero."
  end

  it "testa metodo resumo da conta corrente" do
    @contas_corrente = contas_correntes(:primeira_conta)
    @contas_corrente.resumo_conta_corrente.should == "2345-3 - Conta do Senai Várzea Grande"

    @outra_conta_corrente = contas_correntes(:conta_caixa)
    @outra_conta_corrente.resumo_conta_corrente.should == "Conta Caixa do Senai Várzea Grande"
  end
  
  it "teste para atributo virtual do nome_conta_contabil " do
    @conta_corrente = ContasCorrente.new
    @conta_corrente.nome_conta_contabil.should == nil
    @conta_corrente.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @conta_corrente.nome_conta_contabil.should == "41010101008 - Contribuicoes Regul. oriundas do SENAI"
  end

  it "teste para verificar se limpa autocomplete" do
    contas_corrente = contas_correntes(:primeira_conta)
    contas_corrente.nome_unidade.should == 'SENAI - Varzea Grande'
    contas_corrente.nome_agencia.should == '2445 - Centro'
    contas_corrente.nome_unidade = ""
    contas_corrente.nome_agencia = ""
    contas_corrente.nome_conta_contabil = ""
    contas_corrente.save

    contas_corrente.should_not be_valid
    contas_corrente.errors.on(:unidade).should_not be_nil
    contas_corrente.errors.on(:agencia).should_not be_nil
    contas_corrente.errors.on(:conta_contabil).should_not be_nil
    contas_corrente.unidade_id.should == nil
    contas_corrente.agencia_id.should == nil
    contas_corrente.conta_contabil_id.should == nil
  end
  
  it "teste de validacao do identificador" do
    @contas_corrente = ContasCorrente.new
    @contas_corrente.identificador = 3
    @contas_corrente.should_not be_valid
    @contas_corrente.errors.on(:identificador).should_not be_nil
    @contas_corrente.identificador = 1
    @contas_corrente.should_not be_valid
    @contas_corrente.errors.on(:identificador).should be_nil
  end

  it 'testa funcao verifica_saldo anterior' do
    contas_corrente = contas_correntes(:primeira_conta)
    ItensMovimento.should_receive(:sum).with(:valor, :conditions => ["(contas_correntes.id = ?) AND (movimentos.unidade_id = ?) AND (itens_movimentos.tipo = ?) AND (movimentos.data_lancamento < ?)", contas_corrente.id, unidades(:senaivarzeagrande).id, 'D','01/01/2009'.to_date], :include => [{:movimento=>:parcela}, {:plano_de_conta => :contas_corrente}])
    @actual = contas_corrente.verifica_saldo({'tipo' => 'D', 'data_max' => '01/01/2009'}, unidades(:senaivarzeagrande).id)
  end

  it 'testa funcao verifica_saldo durante' do
    contas_corrente = contas_correntes(:primeira_conta)
    ItensMovimento.should_receive(:sum).with(:valor, :conditions => ["(contas_correntes.id = ?) AND (movimentos.unidade_id = ?) AND (itens_movimentos.tipo = ?) AND (movimentos.data_lancamento > ?) AND (movimentos.data_lancamento < ?)", contas_corrente.id, unidades(:senaivarzeagrande).id, 'D', '01/07/2009'.to_date, '02/07/2009'.to_date], :include => [{:movimento=>:parcela}, {:plano_de_conta => :contas_corrente}])
    @actual = contas_corrente.verifica_saldo({'tipo' => 'D', 'data_min' => '01/07/2009', 'data_max' => '02/07/2009'}, unidades(:senaivarzeagrande).id)
  end

  it 'testa funcao verifica_saldo posteriores' do
    contas_corrente = contas_correntes(:primeira_conta)
    ItensMovimento.should_receive(:sum).with(:valor, :conditions => ["(contas_correntes.id = ?) AND (movimentos.unidade_id = ?) AND (itens_movimentos.tipo = ?) AND (movimentos.data_lancamento > ?)", contas_corrente.id, unidades(:senaivarzeagrande).id, 'C', '01/07/2009'.to_date], :include => [{:movimento=>:parcela}, {:plano_de_conta => :contas_corrente}])
    @actual = contas_corrente.verifica_saldo({'tipo' => 'C', 'data_min' => '01/07/2009'}, unidades(:senaivarzeagrande).id)
  end

  it 'testa funcao saldo_anterior' do
    (contas_correntes(:primeira_conta).verifica_saldo({'data_max' => '31/03/2009', 'tipo' => 'D'}, unidades(:senaivarzeagrande).id) -
        contas_correntes(:primeira_conta).verifica_saldo({'data_max' => '31/03/2009', 'tipo' => 'C'}, unidades(:senaivarzeagrande).id)).should == contas_correntes(:primeira_conta).saldo_anterior('31/03/2009', unidades(:senaivarzeagrande).id)
  end

end
