require File.dirname(__FILE__) + '/../spec_helper'

describe ItensMovimento do
  
  before(:each) do
    @itens_movimento = ItensMovimento.new
  end

  it "valida relacionamento com Movimento, Centro, UnidadeOrganizacional e PlanoDeConta" do
    itens_movimentos(:debito_primeiro_movimento).movimento.should == movimentos(:primeiro_lancamento_entrada)
    itens_movimentos(:debito_primeiro_movimento).centro.should == centros(:centro_forum_economico)
    itens_movimentos(:debito_primeiro_movimento).unidade_organizacional.should == unidade_organizacionais(:senai_unidade_organizacional)
    itens_movimentos(:debito_primeiro_movimento).plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
  end
  
  it "valida presença dos campos" do
    @itens_movimento.should_not be_valid
    @itens_movimento.errors.on(:movimento).should == "é inválido."
    @itens_movimento.errors.on(:plano_de_conta).should == "é inválido."
    @itens_movimento.errors.on(:unidade_organizacional).should == "é inválida."
    @itens_movimento.errors.on(:centro).should == "é inválido."
    @itens_movimento.errors.on(:valor).should == "deve ser maior do que zero."
    @itens_movimento.errors.on(:tipo).should == "é inválido."
    
    @itens_movimento.movimento = movimentos(:primeiro_lancamento_entrada)
    @itens_movimento.plano_de_conta = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @itens_movimento.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @itens_movimento.centro = centros(:centro_forum_social)
    @itens_movimento.valor = "6000"
    @itens_movimento.tipo = "D"
   
    @itens_movimento.should be_valid
    
    @itens_movimento.errors.on(:movimento).should == nil
    @itens_movimento.errors.on(:plano_de_conta).should == nil
    @itens_movimento.errors.on(:unidade_organizacional).should == nil
    @itens_movimento.errors.on(:centro).should == nil
    @itens_movimento.errors.on(:valor).should == nil
    @itens_movimento.errors.on(:tipo).should == nil
  end
  
  it "valida inclusão de tipo" do
    @itens_movimento = ItensMovimento.new :movimento => movimentos(:primeiro_lancamento_entrada),
      :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => "6000"
    
    @itens_movimento.should_not be_valid
    @itens_movimento.tipo = "C"     
    @itens_movimento.should be_valid 
    @itens_movimento.tipo = "S" 
    @itens_movimento.should_not be_valid 
    @itens_movimento.tipo = "D"  
    @itens_movimento.should be_valid   
  end
  
  it "verifica tipo_verbose" do
    itens_movimentos(:debito_primeiro_movimento).tipo_verbose.should == "Débito"
    itens_movimentos(:credito_primeiro_movimento).tipo_verbose.should == "Crédito"
  end

  it 'deve validar unidade organizacional e centro' do
    @itens_movimento = itens_movimentos(:debito_primeiro_movimento)
    @itens_movimento.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @itens_movimento.centro = centros(:centro_forum_social)
    @itens_movimento.should_not be_valid
    @itens_movimento.errors.on(:centro).should == "pertence a outra Unidade Organizacional."

    @itens_movimento.reload
    @itens_movimento.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @itens_movimento.centro = centros(:centro_forum_economico)
    @itens_movimento.should be_valid
  end

  it "verifica função de valor" do
    itens_movimentos(:debito_primeiro_movimento).verifica_valor.should == 1000
    itens_movimentos(:credito_primeiro_movimento).verifica_valor.should == -1000
  end

  describe 'pesquisa de disponibilizacao da ordem e extrato de contas' do

    it 'quando não se passa nada com count' do
      ItensMovimento.should_receive(:count).with(:conditions => ['(movimentos.unidade_id = ?) AND (contas_correntes.id IN (?))', unidades(:senaivarzeagrande).id, ContasCorrente.all.collect(&:id)], :include => [:movimento, {:plano_de_conta => :contas_corrente}], :order=>"movimentos.data_lancamento").and_return(2)
      @actual = ItensMovimento.disponibilidade_efetiva :count, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_DISPONIBILIDADE_EFETIVA, "data_max" => "", "conta_corrente_id" => "", "nome_conta_corrente" => ""}, unidades(:senaivarzeagrande).id
      @actual.should == 2
    end

    it 'quando não se passa nada com all' do
      ItensMovimento.should_receive(:all).with(:conditions => ['(movimentos.unidade_id = ?) AND (contas_correntes.id IN (?))', unidades(:senaivarzeagrande).id, ContasCorrente.all.collect(&:id)], :include => [:movimento, {:plano_de_conta => :contas_corrente}], :order=>"movimentos.data_lancamento").and_return([])
      @actual = ItensMovimento.disponibilidade_efetiva :all, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_DISPONIBILIDADE_EFETIVA, "data_max" => "", "conta_corrente_id" => "", "nome_conta_corrente" => ""}, unidades(:senaivarzeagrande).id
      @actual.should == []
    end

    it 'quando se passa conta corrente com count' do
      ItensMovimento.should_receive(:count).with(:conditions => ['(movimentos.unidade_id = ?) AND (movimentos.data_lancamento <= ?) AND (contas_correntes.id = ?) AND (contas_correntes.id IN (?))', unidades(:senaivarzeagrande).id, "01/02/2000".to_date, contas_correntes(:primeira_conta).id, ContasCorrente.all.collect(&:id)], :include => [:movimento, {:plano_de_conta => :contas_corrente}], :order=>"movimentos.data_lancamento").and_return(0)
      @actual = ItensMovimento.disponibilidade_efetiva :count, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_DISPONIBILIDADE_EFETIVA, "data_max" => "01/02/2000", "conta_corrente_id" => contas_correntes(:primeira_conta).id, "nome_conta_corrente" => "2345-3 - Conta do Senai Várzea Grande"}, unidades(:senaivarzeagrande).id
      @actual.should == 0
    end

    it 'quando se passa conta corrente com count sem mock' do
      ItensMovimento.disponibilidade_efetiva(:count, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_DISPONIBILIDADE_EFETIVA, "data_max" => "01/02/2000", "conta_corrente_id" => contas_correntes(:primeira_conta).id, "nome_conta_corrente" => "2345-3 - Conta do Senai Várzea Grande"}, unidades(:senaivarzeagrande).id).should == 0
    end

    it 'quando não se passa data mínima com all' do
      ItensMovimento.should_receive(:all).with(:conditions => ['(movimentos.unidade_id = ?) AND (movimentos.data_lancamento >= ?) AND (contas_correntes.id IN (?))', unidades(:senaivarzeagrande).id, "01/02/2000".to_date,ContasCorrente.all.collect(&:id)], :include => [:movimento, {:plano_de_conta => :contas_corrente}], :order=>"movimentos.data_lancamento").and_return([])
      @actual = ItensMovimento.disponibilidade_efetiva :all, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_DISPONIBILIDADE_EFETIVA, "data_min" => "01/02/2000", "conta_corrente_id" => "", "nome_conta_corrente" => ""}, unidades(:senaivarzeagrande).id
      @actual.should == []
    end

    it 'quando não se passa data máxima com count' do
      ItensMovimento.should_not_receive(:count).with(:conditions => ['(movimentos.unidade_id = ?) AND (movimentos.data_lancamento <= ?)', unidades(:senaivarzeagrande).id, "01/02/2000".to_date], :include => [:movimento, {:plano_de_conta => :contas_corrente}], :order=>"movimentos.data_lancamento")
      @actual = ItensMovimento.disponibilidade_efetiva :count, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_EXTRATO_CONTAS, "data_max" => "01/02/2000", "conta_corrente_id" => "", "nome_conta_corrente" => ""}, unidades(:senaivarzeagrande).id
      @actual.should == 0
    end

    it 'quando não se passa conta corrente e tipo do relatorio é de extrato de contas com all' do
      (ItensMovimento.disponibilidade_efetiva :all, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_EXTRATO_CONTAS, "data_min" => "01/02/2000", "conta_corrente_id" => "", "nome_conta_corrente" => ""}, unidades(:senaivarzeagrande).id).should == []
    end

    it 'quando não se passa conta corrente e tipo do relatorio é de extrato de contas com count' do
      (ItensMovimento.disponibilidade_efetiva :count, {"tipo_de_relatorio" => ItensMovimento::RELATORIO_EXTRATO_CONTAS, "data_min" => "01/02/2000", "conta_corrente_id" => "", "nome_conta_corrente" => ""}, unidades(:senaivarzeagrande).id).should == 0
    end

  end

  describe "testes da exportação para o Zeus" do

    it "ALL testa os registros gerados passando a data de 31/03/2009 na unidade SENAI" do
      params = {"data" => "31/03/2009"}
      ItensMovimento.exportacao_zeus(:all, unidades(:senaivarzeagrande).id, params).should ==
        [true, "313\t134234239039\t4567456344      \t41010101008     \tC\t100.01          \t31/03/2009\t1  \t1000\tCX.00 SENAIVG   \tPagamento Cheque                                                                                                                                                                                                                                               \n313\t134234239039\t4567456344      \t41010101008     \tD\t100.01          \t31/03/2009\t1  \t1000\tCX.00 SENAIVG   \tPagamento Cheque                                                                                                                                                                                                                                               "]
    end

    it "COUNT testa os registros gerados não passando passando a data de 31/03/2009 na unidade SENAI" do
      params = {"data" => "31/03/2009"}
      ItensMovimento.exportacao_zeus(:count, unidades(:senaivarzeagrande).id, params).should == 2
    end

    it "ALL testa os registros gerados passando a data de 31/03/2009 para a unidade SESI" do
      params = {"data" => "31/03/2009"}
      ItensMovimento.exportacao_zeus(:all, unidades(:sesivarzeagrande).id, params).should ==
        [true, "213\t1303010803\t310010405       \t42210101009     \tC\t10.00           \t31/03/2009\t1  \t1000\tCX - CAC        \tPrimeiro lançamento de entrada outra unidade                                                                                                                                                                                                                  \n213\t1303010803\t310010405       \t41010101009     \tD\t10.00           \t31/03/2009\t1  \t1000\tCX - CAC        \tPrimeiro lançamento de entrada outra unidade                                                                                                                                                                                                                  "]
    end

    it "COUNT testa os registros gerados passando a data de 31/03/2009 para a unidade SESI" do
      params = {"data" => "31/03/2009"}
      ItensMovimento.exportacao_zeus(:count, unidades(:sesivarzeagrande).id, params).should == 2
    end

    it "ALL testa os registros gerados passando uma data que não tem lançamentos" do
      params = {"data" => "30/08/2025"}
      ItensMovimento.exportacao_zeus(:all, unidades(:senaivarzeagrande).id, params).should == [true, ""]
    end

    it "COUNT testa os registros gerados passando uma data que não tem lançamentos" do
      params = {"data" => "30/08/2025"}
      ItensMovimento.exportacao_zeus(:count, unidades(:sesivarzeagrande).id, params).should == 0
    end

    it "ALL testa geração de exceções" do
      unidade = unidades(:senaivarzeagrande)
      unidade.nome_caixa_zeus = nil
      unidade.save false
      params = {"data" => "31/03/2009"}
      ItensMovimento.exportacao_zeus(:all, unidades(:senaivarzeagrande).id, params).should == [false, 'Nome do caixa Zeus é inválido']
    end

  end

  describe "Testa filtro do relatorio receitas por procedimento" do

    it "Verifica se traz os dados quando se preenche todos os filtros" do
      ItensMovimento.should_receive(:all).with(:conditions => ["(movimentos.unidade_id = ?) AND (itens_movimentos.tipo = 'C') AND (plano_de_contas.codigo_contabil BETWEEN ? AND ?) AND (unidade_organizacionais.codigo_da_unidade_organizacional BETWEEN ? AND ?) AND (centros.codigo_centro BETWEEN ? AND ?) AND (movimentos.data_lancamento >= ?) AND (movimentos.data_lancamento <= ?)", unidades(:senaivarzeagrande).id, plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil, plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil, unidade_organizacionais(:senai_unidade_organizacional).codigo_da_unidade_organizacional, unidade_organizacionais(:senai_unidade_organizacional).codigo_da_unidade_organizacional, centros(:centro_forum_economico).codigo_centro, centros(:centro_forum_economico).codigo_centro,Date.new(2008,1,1),Date.new(2010,3,1)], :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro]).and_return(0)
      @actual = ItensMovimento.pesquisa_receitas_das_contas_contabeis :all, unidades(:senaivarzeagrande).id, 'conta_contabil_inicial_id' => "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", 'conta_contabil_final_id' => "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", 'periodo_min'=>'01/01/2008', 'periodo_max'=>'01/03/2010', 'unidade_organizacional_inicial_id'=> unidade_organizacionais(:senai_unidade_organizacional).id, 'unidade_organizacional_final_id'=> unidade_organizacionais(:senai_unidade_organizacional).id, 'centro_inicial_id'=>centros(:centro_forum_economico).id, 'centro_final_id'=>centros(:centro_forum_economico).id,
        'nome_conta_contabil_inicial'=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'nome_conta_contabil_final'=> plano_de_contas(:plano_de_contas_ativo_contribuicoes).nome, 'nome_unidade_organizacional_inicial' => unidade_organizacionais(:senai_unidade_organizacional).nome, 'nome_unidade_organizacional_final' => unidade_organizacionais(:senai_unidade_organizacional).nome, 'nome_centro_inicial' => centros(:centro_forum_economico).nome, 'nome_centro_final' => centros(:centro_forum_economico).nome
    end

    it "Verifica se traz os dados quando se preenche somente o filtro de unidade organizacional" do
      ItensMovimento.should_receive(:all).with(:conditions => ["(movimentos.unidade_id = ?) AND (itens_movimentos.tipo = 'C') AND (unidade_organizacionais.codigo_da_unidade_organizacional BETWEEN ? AND ?) AND (movimentos.data_lancamento < ?)",unidades(:senaivarzeagrande).id,unidade_organizacionais(:senai_unidade_organizacional).codigo_da_unidade_organizacional, unidade_organizacionais(:senai_unidade_organizacional_nova).codigo_da_unidade_organizacional, Date.today], :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro]).and_return(0)
      @actual = ItensMovimento.pesquisa_receitas_das_contas_contabeis :all, unidades(:senaivarzeagrande).id, 'periodo_min'=>'', 'periodo_max'=>'', 'unidade_organizacional_inicial_id'=> unidade_organizacionais(:senai_unidade_organizacional).id, 'unidade_organizacional_final_id'=> unidade_organizacionais(:senai_unidade_organizacional_nova).id, 'conta_contabil_inicial_id'=>'', 'conta_contabil_final_id'=>'', 'centro_inicial_id'=>'', 'centro_final_id'=>'',
        'nome_conta_contabil_inicial'=>'', 'nome_conta_contabil_final'=>'', 'nome_unidade_organizacional_inicial' => unidade_organizacionais(:senai_unidade_organizacional).nome, 'nome_unidade_organizacional_final' => unidade_organizacionais(:senai_unidade_organizacional_nova).nome, 'nome_centro_inicial' => '', 'nome_centro_final' => ''
    end

    it "Verifica se traz os dados quando se preenche somente o filtro de conta_contabil" do
      ItensMovimento.should_receive(:all).with(:conditions => ["(movimentos.unidade_id = ?) AND (itens_movimentos.tipo = 'C') AND (plano_de_contas.codigo_contabil BETWEEN ? AND ?) AND (movimentos.data_lancamento < ?)", unidades(:senaivarzeagrande).id, plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil, plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil, Date.today], :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro]).and_return(0)
      @actual = ItensMovimento.pesquisa_receitas_das_contas_contabeis :all, unidades(:senaivarzeagrande).id, 'conta_contabil_inicial_id' => "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", 'conta_contabil_final_id' => "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", 'periodo_min'=>'', 'periodo_max'=>'', 'unidade_organizacional_inicial_id'=>'', 'unidade_organizacional_final_id'=>'', 'centro_inicial_id'=>'', 'centro_final_id'=>'',
        'nome_conta_contabil_inicial'=>'', 'nome_conta_contabil_final'=>'', 'nome_unidade_organizacional_inicial' => '', 'nome_unidade_organizacional_final' => '', 'nome_centro_inicial' => '', 'nome_centro_final' => ''
    end

    it "Verifica se traz os dados quando se preenche somente o filtro de centros de responsabilidade" do
      ItensMovimento.should_receive(:all).with(:conditions => ["(movimentos.unidade_id = ?) AND (itens_movimentos.tipo = 'C') AND (centros.codigo_centro BETWEEN ? AND ?) AND (movimentos.data_lancamento < ?)", unidades(:senaivarzeagrande).id, centros(:centro_forum_economico).codigo_centro, centros(:centro_forum_economico).codigo_centro, Date.today], :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro]).and_return(0)
      @actual = ItensMovimento.pesquisa_receitas_das_contas_contabeis :all, unidades(:senaivarzeagrande).id, 'periodo_min'=>'', 'periodo_max'=>'', 'unidade_organizacional_inicial_id'=> '', 'unidade_organizacional_final_id'=> '', 'conta_contabil_inicial_id'=>'', 'conta_contabil_final_id'=>'', 'centro_inicial_id'=> centros(:centro_forum_economico).id, 'centro_final_id'=> centros(:centro_forum_economico).id,
        'nome_conta_contabil_inicial'=>'', 'nome_conta_contabil_final'=>'', 'nome_unidade_organizacional_inicial' => '', 'nome_unidade_organizacional_final' => '', 'nome_centro_inicial' => centros(:centro_forum_economico).nome, 'nome_centro_final' => centros(:centro_forum_economico).nome
    end

    it "Verifica se traz os dados quando se preenche somente os filtros de datas" do
      ItensMovimento.should_receive(:all).with(:conditions => ["(movimentos.unidade_id = ?) AND (itens_movimentos.tipo = 'C') AND (movimentos.data_lancamento >= ?) AND (movimentos.data_lancamento <= ?)", unidades(:senaivarzeagrande).id, Date.new(2005, 1, 1), Date.new(2005, 12, 31)], :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro]).and_return(0)
      @actual = ItensMovimento.pesquisa_receitas_das_contas_contabeis :all, unidades(:senaivarzeagrande).id, 'periodo_min'=>'01/01/2005','periodo_max'=>'31/12/2005', 'unidade_organizacional_inicial_id'=> '', 'unidade_organizacional_final_id'=> '', 'conta_contabil_inicial_id'=>'', 'conta_contabil_final_id'=>'', 'centro_inicial_id'=> '', 'centro_final_id'=> '',
        'nome_conta_contabil_inicial'=>'', 'nome_conta_contabil_final'=>'', 'nome_unidade_organizacional_inicial' => '', 'nome_unidade_organizacional_final' => '', 'nome_centro_inicial' => '', 'nome_centro_final' => ''
    end

    it "Verifica se traz os dados quando não se preenche nenhum filtro" do
      ItensMovimento.should_receive(:all).with(:conditions => ["(movimentos.unidade_id = ?) AND (itens_movimentos.tipo = 'C') AND (movimentos.data_lancamento < ?)",unidades(:senaivarzeagrande).id, Date.today], :include => [:movimento, :plano_de_conta, :unidade_organizacional, :centro]).and_return(0)
      @actual = ItensMovimento.pesquisa_receitas_das_contas_contabeis :all, unidades(:senaivarzeagrande).id, 'periodo_min'=>'','periodo_max'=>'', 'unidade_organizacional_inicial_id'=> '', 'unidade_organizacional_final_id'=> '', 'conta_contabil_inicial_id'=>'', 'conta_contabil_final_id'=>'', 'centro_inicial_id'=> '', 'centro_final_id'=> '',
        'nome_conta_contabil_inicial'=>'', 'nome_conta_contabil_final'=>'', 'nome_unidade_organizacional_inicial' => '', 'nome_unidade_organizacional_final' => '', 'nome_centro_inicial' => '', 'nome_centro_final' => ''
    end

  end

end
