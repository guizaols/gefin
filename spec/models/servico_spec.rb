require File.dirname(__FILE__) + '/../spec_helper'

describe Servico do
  
  it "presenca de campos obrigatorios" do
    @servico = Servico.new
    @servico.should_not be_valid
    @servico.errors.on(:descricao).should_not be_nil
    @servico.errors.on(:descricao).should == "deve ser preenchido"
    @servico.errors.on(:unidade).should_not be_nil
    @servico.errors.on(:modalidade).should_not be_nil
    @servico = Servico.new :descricao => "Teste", :modalidade => "teste"
    @servico.unidade = unidades(:senaivarzeagrande)
    @servico.should be_valid
  end

  it "teste de relacionamentos" do
    servicos(:curso_de_tecnologia).unidade.should == unidades(:senaivarzeagrande)
  end
 
  it "Testa se chama o metodo criar_nova_modalidade" do
    @servico = Servico.new
    @servico.novo_modalidade = 'x'
    @servico.valid?
    @servico.modalidade.should == 'x'
    @servico.novo_modalidade = ''
    @servico.valid?
    @servico.modalidade.should == 'x'
  end
  
  it "Teste do atributo ativo" do
    @servico = Servico.new
    @servico.ativo.should == true
    @servico = Servico.new :ativo => false
    @servico.ativo.should == false
  end
  
  it "teste do metodo resumo" do
    @servico = servicos(:curso_de_tecnologia)
    @servico.resumo.should == @servico.descricao
  end
  
  it "testa o atributo unidade_id" do
    @servico = Servico.new :unidade_id => "2"
    @servico.unidade_id.should == nil
    @servico.unidade_id = 1
    @servico.unidade_id.should == 1
  end

end
