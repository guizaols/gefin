require File.dirname(__FILE__) + '/../spec_helper'

describe Banco do

  it "teste de campos obrigatorios" do
    @banco = Banco.new
    @banco.should_not be_valid
    @banco.errors.on(:descricao).should_not be_nil
    @banco.errors.on(:descricao).should == "é inválido."
    @banco = Banco.new :descricao =>"teste"
    @banco.should be_valid
  end
  
  it "teste atributo virtual mensagem_de_erro" do
    @banco = Banco.new
    @banco.mensagem_de_erro.should == nil
  end
  
  it "teste para método resumo" do
    @banco = bancos(:banco_do_brasil)
    @banco.resumo.should == @banco.nome_banco
  end

  it "teste se quando instancia um objeto o ativo é igual a true" do
    @banco = Banco.new
    @banco.ativo.should == true
    @banco = Banco.new :ativo=>false
    @banco.ativo.should == false
  end
  
  it "teste de relacionamento enter banco e agência" do
    @banco = bancos(:banco_do_brasil)
    @banco.agencias.should == [agencias(:centro)]
    @banco.pessoas.should ==[pessoas(:inovare)]
    @banco.cheques.should == cheques(:cheque_do_andre_primeira_parcela,:vista,:prazo,:cheque_do_andre_segunda_parcela)
  end
  
  it "não deve permitir deletar um banco se ele tiver agencia" do
    banco = bancos(:banco_do_brasil)
    assert_no_difference 'Banco.count' do
      banco.destroy
    end
  end

  it 'testa a retirada da mensagem VALIDATION FAILED com a classe na libs agora, pois no lançamento de
    contabilidade quando há algum item incorreto gera uma exceção com Validation Failed' do
    banco = Banco.new
    begin
      banco.save!
    rescue Exception => e
      e.message.should == "O campo descrição é inválido."
    end
  end
  
end
