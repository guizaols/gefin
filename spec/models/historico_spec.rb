require File.dirname(__FILE__) + '/../spec_helper'

describe Historico do
  
  before(:each) do
    @historico = Historico.new
  end

  it "teste de campos obrigatórios" do
    @historico.should_not be_valid
    @historico.errors.on(:descricao).should_not be_nil
    @historico.errors.on(:entidade).should_not be_nil
    @historico.valid?
    @historico.descricao = "Pagamento Dinheiro"
    @historico.entidade = entidades(:senai)
    @historico.should be_valid
  end

  it "teste de relacionamento" do
    historicos(:pagamento_cheque).entidade.should == entidades(:senai)
    historicos(:pagamento_cartao).entidade.should == entidades(:senai)
  end

end
