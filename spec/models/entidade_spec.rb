require File.dirname(__FILE__) + '/../spec_helper'

describe Entidade do
  
  before(:each) do
    @entidade = Entidade.new
  end

  Dir.glob(RAILS_ROOT + '/app/models/*.rb').each do |arquivo|
    it 'deve validar todas as fixtures do model ' + arquivo do
      if arquivo.match %r{app/models/([\w_]+)\.rb}
        nome_model = $1.camelize.constantize
        nome_model.all.each do |r|
          violated "Fixture #{r.inspect} deveria ser válida, mas:\n#{r.errors.full_messages.join "\n"}" unless r.valid?
        end
      else
        violated 'Arquivo de model inválido: ' + arquivo
      end
    end
  end

  it "deve ser válida" do
    @entidade.valid?
    @entidade.errors_on(:nome).should_not be_nil
    @entidade.errors_on(:sigla).should_not be_nil
    @entidade.errors.on(:codigo_zeus).should_not be_nil
    @entidade.nome = "Senai"
    @entidade.sigla = "SENAI"
    @entidade.codigo_zeus = 1
    @entidade.should be_valid
  end

  it "teste de relacionamento" do
    entidade = entidades(:sesi)
    entidade.unidades.should == [unidades(:sesivarzeagrande)]
    entidade.centros.sort_by(&:id).should == centros(:centro_forum_social_2011,:centro_forum_social_2010,:centro_forum_social_2008,:centro_forum_social,:centro_forum_social_2012,:centro_forum_social_2013,:centro_forum_social_2014,:centro_forum_social_2015,:centro_forum_social_2016).sort_by(&:id)
    entidade.pessoas.should == [pessoas(:fornecedor),pessoas(:fabio)]
    entidade.impostos.should == impostos(:inss,:ipi)
    entidade.plano_de_contas.collect(&:nome).should == plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi, :plano_de_contas_ativo,:plano_de_contas_ativo_despesas).collect(&:nome)
    entidade.unidade_organizacionais.sort_by(&:id).should == unidade_organizacionais(:sesi_colider_unidade_organizacional,:sesi_colider_unidade_organizacional_2008,:sesi_colider_unidade_organizacional_2010,:sesi_colider_unidade_organizacional_2011,:sesi_colider_unidade_organizacional_2012).sort_by(&:id)
    entidade_senai = entidades(:senai)
    entidade_senai.plano_de_contas.sort_by(&:id).should == plano_de_contas(:plano_de_contas_passivo_impostos_pagar, :plano_de_contas_ativo_caixa, :plano_de_contas_devolucao, :plano_de_contas_ativo_conta_bancaria, :plano_de_contas_ativo_despesas_senai, :plano_de_contas_ativo_contribuicoes, :plano_de_contas_passivo_a_pagar, :plano_de_contas_para_boleto).sort_by(&:id)
    entidade_senai.plano_de_contas.collect(&:nome).sort.should == plano_de_contas(:plano_de_contas_passivo_impostos_pagar, :plano_de_contas_ativo_caixa, :plano_de_contas_devolucao, :plano_de_contas_ativo_conta_bancaria, :plano_de_contas_ativo_despesas_senai, :plano_de_contas_ativo_contribuicoes, :plano_de_contas_passivo_a_pagar, :plano_de_contas_para_boleto).collect(&:nome).sort
    entidade_senai.unidade_organizacionais.should == unidade_organizacionais(:unidade_organizacional_empresa, :senai_unidade_organizacional_nova, :senai_unidade_organizacional)
    entidade_senai.agencias.should == [agencias(:centro)]
    entidade_senai.historicos.should == historicos(:pagamento_cartao, :pagamento_cheque)
  end

  it "valida a presença do campo Nome" do
    @entidade.valid?
    @entidade.errors.on(:nome).should_not be_nil
    @entidade.errors.on(:sigla).should_not be_nil
    @entidade.errors.on(:codigo_zeus).should_not be_nil
    @entidade.nome = "Senai Varzea Grande"
    @entidade.sigla = "SENAI"
    @entidade.codigo_zeus = 1
    @entidade.valid?
    @entidade.errors.on(:nome).should be_nil
    @entidade.errors.on(:sigla).should be_nil
    @entidade.errors.on(:codigo_zeus).should be_nil
  end

  it "importacao dos Dados do Gefin" do
    Entidade.delete_all
    PlanoDeConta.delete_all
    UnidadeOrganizacional.delete_all
    Entidade.importar_dados_do_gefin("#{RAILS_ROOT}/spec/test_cidades.sql","#{RAILS_ROOT}/spec/entidades.sql",RAILS_ROOT+"/spec/plano_de_contas_sql.txt",RAILS_ROOT+"/spec/unidades_organizacionais.sql",RAILS_ROOT+"/spec/centro.sql")
    ################################################## Importacao das Entidades
    @entidade = Entidade.last
    @entidade.sigla.should == "QS"
    @entidade.nome.should == "ADADASDADSAD"
    @entidade.codigo_zeus.should == 16
    ############################################################### Importacao das localidades
    (Localidade.all.collect {|l| [l.nome, l.uf]}).should == [["VARZEA GRANDE", "MT"], ["CUIABA", "MT"], ["ACORIZAL", "MT"], ["AGUA BOA", "MT"],
      ["ALTO ARAGUAIA", "MT"], ["ALTO BOA VISTA", "MT"], ["ALTO GARCAS", "MT"], ["ALTO PARAGUAI", "MT"]]
    ################################################################
    @entidade = Entidade.find_by_sigla "CONDOMINIO"
    ################################################################## Importacao do Plano de Contas
    @plano_de_conta=PlanoDeConta.first
    @plano_de_conta.ano.should == 2005
    @plano_de_conta.nome.should == "ATIVO"
    @plano_de_conta.entidade_id.should == @entidade.id
    @plano_de_conta.codigo_contabil.should == "1"
    @plano_de_conta.nivel.should == 1
    @plano_de_conta.ativo.should == 1
    @plano_de_conta = PlanoDeConta.last
    @plano_de_conta.ano.should == 2009
    @plano_de_conta.nome.should == "CAIXAS"
    @plano_de_conta.codigo_contabil.should == "110101"
    @plano_de_conta.nivel.should == 4
    @plano_de_conta.ativo.should == 1
    #######################################################################
    ####### Importacao das Unidades Organizacionais
    @unidade_organizacional = UnidadeOrganizacional.last
    @unidade_organizacional.entidade_id.should == @entidade.id
    @unidade_organizacional.nome.should == "SENAI COLIDER"
    @unidade_organizacional.codigo_da_unidade_organizacional.should == "1303010803"
    @unidade_organizacional.codigo_reduzido.should == "00012"
    #######################################################################
    ### Importacao dos Centros
    @centro = Centro.last
    @centro.entidade_id.should ==@entidade.id
    @centro.ano.should == 2009
    @centro.nome.should == "Foruns em Servico Social"
    @centro.codigo_centro.should == "310010405"
  end


  it "não deixa cadastrar dois codigos_zeus com o mesmo numero" do
    @entidade = Entidade.new
    @entidade.nome = "Senai"
    @entidade.sigla = "SENAI"
    @entidade.codigo_zeus = 213
    @entidade.valid?
    @entidade.errors.on(:codigo_zeus).should_not be_nil
    @entidade.codigo_zeus = 216
    @entidade.valid?
    @entidade.errors.on(:codigo_zeus).should be_nil
  end



end
