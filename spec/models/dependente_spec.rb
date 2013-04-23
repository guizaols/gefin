require File.dirname(__FILE__) + '/../spec_helper'

describe Dependente do
  before(:each) do
    @dependente = Dependente.new
  end

  it "testes de campos obrigatorios" do
    @dependente = Dependente.new
    @dependente.should_not be_valid
    @dependente.errors.on(:pessoa).should_not be_nil
    @dependente.pessoa = pessoas(:paulo)
    @dependente.should_not be_valid
    @dependente.errors.on(:nome).should_not be_nil
    @dependente.errors.on(:nome_da_mae).should_not be_nil
    @dependente.errors.on(:nome_do_pai).should_not be_nil
    @dependente.errors.on(:data_de_nascimento).should_not be_nil
    @dependente = Dependente.new :nome =>"Jose", :nome_do_pai=>"Maria", :nome_da_mae=>"Teresa"
    @dependente.should_not be_valid
    @dependente.errors.on(:pessoa).should_not be_nil
    @dependente = Dependente.new :nome =>"Jose", :nome_do_pai=>"Maria", :nome_da_mae=>"Teresa", :pessoa=>pessoas(:paulo), :data_de_nascimento=>"2000-01-01"
    @dependente.should be_valid

    @dependente = Dependente.new
    @dependente.pessoa = pessoas(:inovare)
    @dependente.should_not be_valid
    @dependente.errors.on(:nome).should_not be_nil
    @dependente.errors.on(:nome_da_mae).should be_nil
    @dependente.errors.on(:nome_do_pai).should be_nil
    @dependente.errors.on(:data_de_nascimento).should_not be_nil
  end
  
  it "teste de relacionamento" do
    dependente = dependentes(:dependente_paulo_primeiro)
    pessoa = pessoas(:paulo)
    dependente.pessoa.should == pessoa
  end
  
  
  
end
