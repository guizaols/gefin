require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Compromisso do
  
  fixtures :all
  
  it "verifica os relacionamentos" do
    compromissos(:ligar_para_o_cliente).conta.should == recebimento_de_contas(:curso_de_corel_do_paulo)
    compromissos(:ligar_para_o_cliente).unidade.should == unidades(:senaivarzeagrande)    
  end
  
  it "testa a obrigatoriedade dos campos" do
    @compromisso = Compromisso.new 
    @compromisso.valid?
    @compromisso.errors.on(:unidade).should_not be_nil
    @compromisso.errors.on(:conta).should_not be_nil
    @compromisso.errors.on(:data_agendada).should_not be_nil
    @compromisso.errors.on(:descricao).should_not be_nil
    @compromisso.unidade = unidades(:senaivarzeagrande)
    @compromisso.conta = recebimento_de_contas(:curso_de_corel_do_paulo)
    @compromisso.conta_type = RecebimentoDeConta
    @compromisso.data_agendada = "2009-02-15 00:00:00"
    @compromisso.descricao = "Ligar para o cliente"
    @compromisso.valid?
    @compromisso.errors.on(:unidade).should be_nil
    @compromisso.errors.on(:conta).should be_nil
    @compromisso.errors.on(:data_agendada).should be_nil
    @compromisso.errors.on(:descricao).should be_nil 
  end
  
  it "verifica o formato da data agendada" do
    @compromisso = Compromisso.new
    @compromisso.data_agendada = "2009-02-10 00:00:00"
    @compromisso.data_agendada.should == "10/02/2009"
    @compromisso.data_agendada  = "10/06/2009"
    @compromisso.data_agendada.should == "10/06/2009"
  end
  
  it "verifica se o atributo unidade_id está protegido" do
    @compromisso = Compromisso.new :unidade_id => unidades(:senaivarzeagrande).id
    @compromisso.unidade_id.should == nil
    @compromisso.unidade_id = unidades(:senaivarzeagrande).id
    @compromisso.unidade_id.should == unidades(:senaivarzeagrande).id
  end

  describe "Testa filtro de compromissos em Contas a Receber" do

    it 'pesquisa o nome da conta para auto_complete com conta' do
      compromissos(:ligar_para_o_cliente).nome_conta.should == 'SVG-CTR09/09000791'
    end

    it 'pesquisa o nome da conta para auto_complete sem conta' do
      comp = compromissos(:ligar_para_o_cliente)
      comp.conta = nil
      comp.save false
      comp.nome_conta.should == ''
    end
  end
  
  
  
end
