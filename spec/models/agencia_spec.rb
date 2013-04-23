require File.dirname(__FILE__) + '/../spec_helper'

describe Agencia do
  
  before(:each) do
    @agencia = Agencia.new
  end

  it "should be valid" do
    @agencia.should_not be_valid
    @agencia.errors.on(:nome).should == "é inválido."
    @agencia.errors.on(:nome).should_not be_nil
    @agencia.errors.on(:numero).should == "é inválido."
    @agencia.errors.on(:numero).should_not be_nil
    @agencia.errors.on(:digito_verificador).should == "é inválido."
    @agencia.errors.on(:digito_verificador).should_not be_nil
    @agencia.errors.on(:banco).should == "é inválido."
    @agencia.errors.on(:banco).should_not be_nil
    @agencia.errors.on(:entidade).should == "é inválida."
    @agencia.errors.on(:entidade).should_not be_nil
    @agencia.valid?
    @agencia.nome = "Teste"; @agencia.numero = "3244"; @agencia.digito_verificador = "9"
    @agencia.banco = bancos(:banco_caixa); @agencia.localidade = localidades(:primeira); @agencia.entidade = entidades(:senai)
    @agencia.should be_valid
  end
  
  it "teste de relacionamento" do
    agencia = agencias(:centro)
    agencia.banco.should == bancos(:banco_do_brasil)
    agencia.localidade.should == localidades(:primeira)
    agencia.entidade.should == entidades(:senai)
    agencia.pessoas.should == [pessoas(:inovare)]
  end
  
  it "teste que verifica quando um objeto com ativo é igual a true" do
    @agencia.ativo.should == true
    @agencia = Agencia.new :ativo => false
    @agencia.ativo.should == false
  end
  
  it "existem os campos virtuais cidade_e_estado e banco_virtual" do
    @agencia = agencias(:centro) 
    @agencia.nome_localidade = "Varzea Grande - MT"
    @agencia.nome_banco = "800 - Banco do Brasil"
  end
  
  it "existem atributos virtuais cidade_e_estado e banco_virtual" do
    @agencia = agencias(:centro)
    @agencia.nome_localidade.should == "VARZEA GRANDE - MT"
    @agencia.nome_banco.should == "800 - Banco do Brasil"
  end

  it "se limpa os campos com autocomplete" do
    @agencia = agencias(:centro)
    @agencia.save
    agencia = Agencia.last
    agencia.nome_banco = ""
    agencia.nome_localidade = ""
    agencia.save
    agencia.should_not be_valid
    agencia.errors.on(:banco).should_not be_nil
    agencia.errors.on(:localidade).should_not be_nil
    agencia.banco_id.should == nil
    agencia.localidade_id.should == nil
  end

  
end
