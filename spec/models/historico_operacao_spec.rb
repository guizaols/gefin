require File.dirname(__FILE__) + '/../spec_helper'

describe HistoricoOperacao do

  it "verificando relacionamento com plano de contas" do
    historico_operacoes(:historico_operacao_pagamento_cheque).conta.should == pagamento_de_contas(:pagamento_cheque)
    historico_operacoes(:historico_operacao_pagamento_cheque).usuario.should == usuarios(:quentin)
  end

  it "verificando presença dos campos" do
    historico_operacao = HistoricoOperacao.new
    historico_operacao.valid?
    historico_operacao.errors.on(:conta).should_not be_nil
    historico_operacao.errors.on(:usuario).should_not be_nil
    historico_operacao.errors.on(:descricao).should_not be_nil

    historico_operacao.conta = pagamento_de_contas(:pagamento_cheque)
    historico_operacao.usuario = usuarios(:quentin)
    historico_operacao.descricao = "Novo histórico de operação"

    historico_operacao.should be_valid
    historico_operacao.errors.on(:conta).should be_nil
    historico_operacao.errors.on(:usuario).should be_nil
    historico_operacao.errors.on(:descricao).should be_nil
  end

  it "testando numero_carta_cobranca_verbose" do
    historico_operacao = HistoricoOperacao.new :numero_carta_cobranca => nil
    historico_operacao.numero_carta_cobranca_verbose.should == 'Nenhuma'
    
    historico_operacao.numero_carta_cobranca = 1
    historico_operacao.numero_carta_cobranca_verbose.should == 'Carta de cobrança de 30 dias'

    historico_operacao.numero_carta_cobranca = 2
    historico_operacao.numero_carta_cobranca_verbose.should == 'Carta de cobrança de 60 dias'

    historico_operacao.numero_carta_cobranca = 3
    historico_operacao.numero_carta_cobranca_verbose.should == 'Carta de cobrança de 90 dias'

    historico_operacao.numero_carta_cobranca = 4
    historico_operacao.numero_carta_cobranca_verbose.should == 'Carta promocional'
  end


  it "testando cria follow up sem justificativa" do
    conta = pagamento_de_contas(:pagamento_cheque)
    conta.usuario_corrente = usuarios(:quentin)
    descricao = "Conta a pagar criada no dia 21/05"
    usuario = conta.usuario_corrente
    
    HistoricoOperacao.cria_follow_up(descricao, usuario, conta)
    historico_operacao = HistoricoOperacao.last
    historico_operacao.descricao.should == "Conta a pagar criada no dia 21/05"
    historico_operacao.justificativa.should == nil
    historico_operacao.valid?

    lambda do
      descricao = ""
      HistoricoOperacao.cria_follow_up(descricao, usuario, conta)
    end.should raise_error(ActiveRecord::RecordInvalid)

  end
  
  it "testando cria follow up com justificativa" do
    conta = pagamento_de_contas(:pagamento_cheque)
    conta.usuario_corrente = usuarios(:quentin)
    descricao = "Conta a pagar criada no dia 21/05"
    justificativa = "Conta a pagar criada referente a parcela do dia 21/05 "
    usuario = conta.usuario_corrente
    
    HistoricoOperacao.cria_follow_up(descricao, usuario, conta, justificativa)
    historico_operacao = HistoricoOperacao.last
    historico_operacao.descricao.should == "Conta a pagar criada no dia 21/05"
    historico_operacao.justificativa.should == "Conta a pagar criada referente a parcela do dia 21/05 "
    historico_operacao.valid?

    lambda do
      descricao = ""
      HistoricoOperacao.cria_follow_up(descricao, usuario, conta, justificativa)
    end.should raise_error(ActiveRecord::RecordInvalid)

  end

  it 'cria follow-up de acordo com a carta de cobrança' do
    assert_difference 'HistoricoOperacao.count', 1 do
      HistoricoOperacao.cria_follow_up('Geração da carta de cobrança número 1', usuarios(:quentin), pagamento_de_contas(:pagamento_cheque), nil, 1)
    end

    historico_operacao = HistoricoOperacao.last
    historico_operacao.descricao.should == 'Geração da carta de cobrança número 1'
    historico_operacao.usuario.should == usuarios(:quentin)
    historico_operacao.conta.should == pagamento_de_contas(:pagamento_cheque)
    historico_operacao.justificativa.should == nil
    historico_operacao.numero_carta_cobranca.should == 1
  end

end
