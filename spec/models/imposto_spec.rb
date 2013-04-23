require File.dirname(__FILE__) + '/../spec_helper'

describe Imposto do
  
  before(:each) do
    @imposto = Imposto.new
  end
  
    it "Testes de Relacionamentos" do
     impostos(:iss).conta_credito.should == plano_de_contas(:plano_de_contas_passivo_impostos_pagar)
     impostos(:fgts).conta_debito.should == plano_de_contas(:plano_de_contas_ativo_despesas)
     impostos(:iss).entidade.should == entidades(:senai)
    end

    it "Verifica a obrigatoriedade dos campos Entidade, Descricao, Sigla, Aliquota, Tipo, Classificacao, Conta_Debito e Conta_Crédito" do
    @imposto.valid?
    @imposto.errors.on(:entidade).should_not be_nil
    @imposto.errors.on(:descricao).should_not be_nil
    @imposto.errors.on(:sigla).should_not be_nil
    @imposto.errors.on(:aliquota).should_not be_nil
    @imposto.errors.on(:tipo).should_not be_nil
    @imposto.errors.on(:classificacao).should_not be_nil
    @imposto.entidade = entidades(:sesi)
    @imposto.descricao = 'ISS-PF-5%'
    @imposto.sigla = 'ISS-PF-5%'
    @imposto.aliquota = '5,00'
    @imposto.tipo = Imposto::ESTADUAL
    @imposto.classificacao = Imposto::INCIDE
    @imposto.conta_debito = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @imposto.conta_credito = plano_de_contas(:plano_de_contas_ativo_despesas)
    @imposto.valid?
    @imposto.errors.on(:entidade).should be_nil
    @imposto.errors.on(:descricao).should be_nil
    @imposto.errors.on(:sigla).should be_nil
    @imposto.errors.on(:aliquota).should be_nil
    @imposto.errors.on(:tipo).should be_nil
    @imposto.errors.on(:classificacao).should be_nil
    @imposto.errors.on(:conta_debito).should be_nil
    @imposto.errors.on(:conta_credito).should be_nil
  end
  
  it "Verifica a obrigatoriedade dos campos Conta Débito ou Conta Débito " do
    @imposto = impostos(:iss)
    @imposto.aliquota = '5,00'
    @imposto.classificacao = Imposto::INCIDE
    @imposto.conta_debito = nil
    @imposto.conta_credito = nil
    @imposto.valid?
    @imposto.errors.on(:conta_debito).should_not be_nil
    @imposto.errors.on(:conta_credito).should_not be_nil
    @imposto.aliquota = '5,00'
    @imposto.classificacao = Imposto::RETEM
    @imposto.conta_debito = nil
    @imposto.conta_credito = nil
    @imposto.valid?
    @imposto.errors.on(:conta_debito).should be_nil
    @imposto.errors.on(:conta_credito).should_not be_nil
  end
  
  it "Verifica se o atributo entidade_id está protegido" do
    @imposto = Imposto.new :entidade_id => entidades(:sesi).id,
    :descricao=>'ISS-PS-5%',:sigla=>'ISS-PS-5%', :tipo=>Imposto::ESTADUAL, 
    :classificacao => Imposto::INCIDE, :conta_debito => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
    :conta_credito => plano_de_contas(:plano_de_contas_ativo_despesas)
    @imposto.entidade_id.should == nil
    @imposto.entidade_id = entidades(:sesi).id
    @imposto.entidade_id.should == entidades(:sesi).id
  end
  
  it "Testa se retorna os tipos e as classificacoes das aliquotas" do
    Imposto.retorna_tipos_de_aliquota.should == [['Municipal',0],['Estadual',1],['Federal',2]]
    Imposto.retorna_classificacoes_das_aliquotas.should == [['Incide',0],['Retém',1]]
  end
  
  it "Testa o campo e atributo virtual nome_conta_credito" do
    @imposto = impostos(:iss)
    @imposto.nome_conta_credito = 41010101008
    @imposto.nome_conta_credito.should == '3101123456 - Impostos a Pagar'
  end
  
  it "Testa o campo e atributo virtual nome_conta_debito" do
    @imposto = impostos(:fgts)
    @imposto.nome_conta_debito = 41010101009
    @imposto.nome_conta_debito.should == '41010101009 - Despesas do SESI'
  end
  
   it "apaga conta_credito quando vem string vazia no campo virtual nome_conta_credito" do
    @imposto = impostos(:iss)
    @imposto.aliquota = "10,00"
    @imposto.conta_credito_id.should == plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id
    @imposto.nome_conta_credito = ""
    @imposto.save
    @imposto.conta_credito_id.should == nil
  end
  
  it "nao apaga conta_credito quando vem nil no campo virtual nome_conta_credito" do
    @imposto = impostos(:iss)
    @imposto.aliquota = "10,00"
    @imposto.conta_credito_id.should == plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id
    @nome_conta_credito = nil
    @imposto.save
    @imposto.conta_credito_id.should == plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id
  end
  
  it "apaga conta_debito quando vem string vazia no campo virtual nome_conta_debito" do
    @imposto = impostos(:fgts)
    @imposto.aliquota = "10,00"
    @imposto.conta_debito_id.should == plano_de_contas(:plano_de_contas_ativo_despesas).id
    @imposto.nome_conta_debito = ""
    @imposto.save
    @imposto.conta_debito_id.should == nil
  end
  
  it "nao apaga conta_debito quando vem nil no campo virtual nome_conta_debito" do
    @imposto = impostos(:fgts)
    @imposto.aliquota = "10,00"
    @imposto.conta_debito_id.should == plano_de_contas(:plano_de_contas_ativo_despesas).id
    @nome_conta_debito = nil
    @imposto.save
    @imposto.conta_debito_id.should == plano_de_contas(:plano_de_contas_ativo_despesas).id
  end
  
  it "Verifica tipos e as classificações das aliquotas verbose " do
    @imposto = impostos(:iss)
    @imposto.tipo_de_aliquota_verbose.should == 'Estadual'
    @imposto.classificacoes_das_aliquotas_verbose ==  'Retém'
  end


end
