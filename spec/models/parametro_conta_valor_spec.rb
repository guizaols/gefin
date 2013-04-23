require File.dirname(__FILE__) + '/../spec_helper'

describe "Verifica se" do
  
  before(:each) do
    @parametro_conta_valor = ParametroContaValor.new
  end
   
  it "os campos Unidade, Conta Contábil, Tipo e Ano são obrigatórios" do
    @parametro_conta_valor.valid?
    @parametro_conta_valor.errors.on(:unidade).should_not be_nil
    @parametro_conta_valor.errors.on(:conta_contabil).should_not be_nil
    @parametro_conta_valor.errors.on(:tipo).should_not be_nil
    @parametro_conta_valor.errors.on(:ano).should_not be_nil
    @parametro_conta_valor.unidade_id = unidades(:senaivarzeagrande).id
    @parametro_conta_valor.conta_contabil = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @parametro_conta_valor.tipo = 1
    @parametro_conta_valor.ano = 2009
    @parametro_conta_valor.valid?
    @parametro_conta_valor.errors.on(:unidade_id).should be_nil
    @parametro_conta_valor.errors.on(:conta_contabil).should be_nil
    @parametro_conta_valor.errors.on(:tipo).should be_nil
    @parametro_conta_valor.errors.on(:ano).should be_nil
  end
  
  it "existe relacionamento com o model unidade" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.unidade.should == unidades(:senaivarzeagrande)
    @parametro_conta_valor.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @unidade = unidades(:senaivarzeagrande)
    @unidade.parametro_conta_valores.sort_by{ |p| p.id }.should == parametro_conta_valores(:conta_fornecedor, :conta_faturamento, :conta_cliente, :conta_desconto_pessoa_fisica, :conta_desconto_pessoa_juridica, :conta_juros_multas_renegociados, :one).sort_by { |p| p.id }
  end
  
  it "retorna todas os tipo de parâmetros" do
    ParametroContaValor.retorna_tipos_de_parametro.should == [['Juros/Multa',0],['Taxa de Boleto',1],['Desconto PF',2],
      ['Desconto PJ',3],['Outros (Débito)',4],['Outros (Crédito)',5],['Fornecedor',6],['Cheque Pré-Datado',7], ["Clientes", 8], ["Faturamento", 9], ["Juros e Multas de Contratos Renegociados", 10]]
  end
  
 it "retorna valor correto do tipo de parametro" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.tipo_de_parametro_verbose.should == 'Taxa de Boleto'
    @parametro_conta_valor = parametro_conta_valores(:two)
    @parametro_conta_valor.tipo_de_parametro_verbose.should == 'Desconto PF'
  end
  
  it "valida conta contabil ao criar um parametro" do
    @parametro_conta_valor = ParametroContaValor.new :unidade_id => 1, :conta_contabil=> plano_de_contas(:plano_de_contas_ativo), :tipo => 1, :ano => 2005
    @parametro_conta_valor.should_not be_valid
    @parametro_conta_valor.errors.on(:conta_contabil).should == "deve ser analítica."
    @parametro_conta_valor = ParametroContaValor.new :unidade_id => 1, :conta_contabil=> plano_de_contas(:plano_de_contas_ativo_contribuicoes), :tipo => 1, :ano => 2005
    @parametro_conta_valor.valid?
    @parametro_conta_valor.errors.on(:conta_contabil).should be_nil
  end
  
  it "valida campo virtual e atributto virtual" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.nome_conta_contabil = 41010101008
    @parametro_conta_valor.nome_conta_contabil.should == '41010101008 - Contribuicoes Regul. oriundas do SENAI'
  end
  
  it "apaga conta_contabil quando vem string vazia no campo virtual nome_conta_contabil" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.conta_contabil_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    @parametro_conta_valor.nome_conta_contabil = ""
    @parametro_conta_valor.save
    @parametro_conta_valor.conta_contabil_id.should == nil
  end
  
  it "nao apaga conta_contabil quando vem nil no campo virtual nome_conta_contabil" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.conta_contabil_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    @nome_conta_contabil = nil
    @parametro_conta_valor.save
    @parametro_conta_valor.conta_contabil_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
  end
  
  it "não apaga conta_contabil se vem string diferente de vazia no campo virtual nome_conta_contabil" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.conta_contabil_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    @parametro_conta_valor.nome_conta_contabil = "41010101008 - Contribuicoes Regul. oriundas do SESI"
    @parametro_conta_valor.save
    @parametro_conta_valor.conta_contabil_id.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
  end
  
  it "não gera parametro com dados duplicados para unidade e ano referente ao tipo" do
    @parametro_conta_valor.unidade_id = unidades(:sesivarzeagrande).id
    @parametro_conta_valor.conta_contabil_id = plano_de_contas(:plano_de_contas_ativo).id
    @parametro_conta_valor.ano = 2009
    @parametro_conta_valor.tipo = 2
    @parametro_conta_valor.valid?
    @parametro_conta_valor.errors.on(:tipo).should_not be_nil
    @parametro_conta_valor.unidade_id = unidades(:senaivarzeagrande).id
    @parametro_conta_valor.conta_contabil_id = plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    @parametro_conta_valor.ano = 2009
    @parametro_conta_valor.tipo = 2
    @parametro_conta_valor.valid?
    @parametro_conta_valor.errors.on(:tipo).should == 'já está em uso para essa unidade.'
  end
  
  it "gera corretamente novo parametro com dados válidos" do
    @parametro_conta_valor = parametro_conta_valores(:one)
    @parametro_conta_valor.ano = 2010
    @parametro_conta_valor.tipo = 3
    @parametro_conta_valor.save
    @parametro_conta_valor.unidade_id.should == unidades(:senaivarzeagrande).id
    @parametro_conta_valor.ano.should == 2010
    @parametro_conta_valor.tipo.should == 3
  end
  
  it "Verifica se o atributo unidade_id e ano estão protegidos" do
    @parametro_conta_valor = ParametroContaValor.new :unidade_id => unidades(:sesivarzeagrande).id, :conta_contabil=> plano_de_contas(:plano_de_contas_ativo), :tipo => 1, :ano => 2005
    @parametro_conta_valor.unidade_id.should == nil
    @parametro_conta_valor.ano.should == nil
    @parametro_conta_valor.unidade_id = unidades(:sesivarzeagrande).id
    @parametro_conta_valor.ano = 2005
    @parametro_conta_valor.unidade_id.should == unidades(:sesivarzeagrande).id
    @parametro_conta_valor.ano.should == 2005
  end
  
   
end
