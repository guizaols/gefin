require File.dirname(__FILE__) + '/../spec_helper'

describe Rateio do

  it "teste de relacionamento" do
    @rateio = rateios(:rateio_primeira_parcela)
    @rateio.centro.should == centros(:centro_forum_social)
    @rateio.parcela.should == parcelas(:primeira_parcela)
    @rateio.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @rateio.conta_contabil.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
  end

  it "teste de campos obrigatórios" do
    @rateio = Rateio.new
    @rateio.should_not be_valid
    @rateio.errors.on(:unidade_organizacional).should_not be_nil
    @rateio.errors.on(:conta_contabil).should_not be_nil
    @rateio.errors.on(:centro).should_not be_nil
    @rateio.errors.on(:parcela).should_not be_nil
    @rateio.errors.on(:valor).should_not be_nil
  end

  it 'deve validar unidade organizacional e centro' do
    @rateio = rateios(:rateio_primeira_parcela)
    @rateio.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @rateio.centro = centros(:centro_forum_social)
    @rateio.should_not be_valid
    @rateio.errors.on(:centro).should == "pertence a outra Unidade Organizacional."

    @rateio.reload
    @rateio.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional_nova)
    @rateio.centro = centros(:centro_forum_economico)
    @rateio.should_not be_valid
    @rateio.errors.on(:centro).sort.should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."].sort

    @rateio.reload
    @rateio.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @rateio.centro = centros(:centro_forum_social)
    @rateio.should be_valid
  end

end
