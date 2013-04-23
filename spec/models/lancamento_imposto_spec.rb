require File.dirname(__FILE__) + '/../spec_helper'

describe LancamentoImposto do
  
  before(:each) do
    @lancamento_imposto = LancamentoImposto.new
  end
  
  it "Verifica os relacionamentos" do
    lancamento_impostos(:primeira).parcela.should == parcelas(:primeira_parcela)
    lancamento_impostos(:primeira).imposto.should == impostos(:iss)
  end
  
  it "Verifica se o atributo parcela está protegido" do
    @lancamento_imposto = LancamentoImposto.new :parcela_id => parcelas(:primeira_parcela).id, :imposto_id => impostos(:iss).id, :data_de_recolhimento => '01/04/2009'
    @lancamento_imposto.parcela_id.should == nil
    @lancamento_imposto.parcela_id = parcelas(:primeira_parcela).id
    @lancamento_imposto.parcela_id.should == parcelas(:primeira_parcela).id
  end
  
  it "Verifica a obrigatoriedades dos campos Imposto, Data de Recolhimento, Alíquota e Valor" do
    @lancamento_imposto.valid?
    @lancamento_imposto.errors.on(:parcela_id).should_not be_nil
    @lancamento_imposto.errors.on(:imposto_id).should_not be_nil
    @lancamento_imposto.errors.on(:data_de_recolhimento).should_not be_nil
    @lancamento_imposto.errors.on(:valor).should_not be_nil
    @lancamento_imposto.parcela_id = parcelas(:primeira_parcela).id
    @lancamento_imposto.imposto_id = impostos(:iss).id
    @lancamento_imposto.data_de_recolhimento = '01/04/2009'
    @lancamento_imposto.valor = 500
    @lancamento_imposto.valid?
    @lancamento_imposto.errors.on(:parcela_id).should be_nil
    @lancamento_imposto.errors.on(:imposto_id).should be_nil
    @lancamento_imposto.errors.on(:data_de_recolhimento).should be_nil
    @lancamento_imposto.errors.on(:valor).should be_nil
  end
  
  it "Verifica se tem o data br field" do
    lancamento_impostos(:primeira).data_de_recolhimento.to_date.to_s_br.should == '04/04/2009'
  end
  
  it "teste do atributo virtual valor de Lancamento Impostos" do
    @lancamento_imposto = LancamentoImposto.new
    @lancamento_imposto.valor.should be_nil
    @lancamento_imposto.valor = 0
    @lancamento_imposto.valor_em_reais.should == "0,00"
    @lancamento_imposto.valor = 500
    @lancamento_imposto.valor_em_reais.should == "5,00"
  end
  
  it "teste que verifica se grava em formato inteiro no banco" do
    @lancamento_imposto = LancamentoImposto.new :parcela_id => parcelas(:primeira_parcela).id, :imposto_id => impostos(:iss).id, :data_de_recolhimento => '01/04/2009',:valor_em_reais => 5.00
    @lancamento_imposto.valid?
    @lancamento_imposto.valor.should == 500
  end
  
  it "verifica se não deixa salvar valores de impostos negativos ou menos que 1" do
    @lancamento_imposto = LancamentoImposto.new :parcela_id => parcelas(:primeira_parcela).id, :imposto_id => impostos(:iss).id, :data_de_recolhimento => '01/04/2009',:valor_em_reais => -1.00
    @lancamento_imposto.valid?
    @lancamento_imposto.errors.on(:valor).should_not be_nil
    @lancamento_imposto.valor.should == -100
    @lancamento_imposto.valor_em_reais = 0.00
    @lancamento_imposto.valid?
    @lancamento_imposto.errors.on(:valor).should_not be_nil
    @lancamento_imposto.valor.should == 0
    @lancamento_imposto.valor_em_reais = 1.00
    @lancamento_imposto.valid?
    @lancamento_imposto.errors.on(:valor).should be_nil
    @lancamento_imposto.valor.should == 100
  end

  describe 'deve pesquisar para exibir relatório de retencao de impostos e' do

    it 'retornar todos' do
      ordem = 'impostos.descricao ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?)', unidades(:senaivarzeagrande).id], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return(parcelas(:primeira_parcela, :segunda_parcela))
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:senaivarzeagrande).id, "opcoes" => LancamentoImposto::ALFABETICA, "impostos" => "", "recolhimento_max"=>"", "recolhimento_min"=>"", "fornecedor_id" => "", "nome_fornecedor" => ""
      @actual.should == parcelas(:primeira_parcela, :segunda_parcela)
    end

    it 'contar todos' do
      ordem = 'impostos.descricao ASC'
      LancamentoImposto.should_receive(:count).with(:conditions => ['(pagamento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return(2)
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :count, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::ALFABETICA, "impostos" => "","recolhimento_max"=>"", "recolhimento_min"=>"", "fornecedor_id" => "", "nome_fornecedor" => ""
      @actual.should == 2
    end

    it 'retornar filtrando por imposto_id' do
      ordem = 'impostos.descricao ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (lancamento_impostos.imposto_id = ?)', unidades(:sesivarzeagrande).id, impostos(:iss).id.to_s], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return([parcelas(:primeira_parcela)])
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::ALFABETICA, "impostos" => impostos(:iss).id.to_s, "recolhimento_max"=>"", "recolhimento_min"=>"", "fornecedor_id" => "", "nome_fornecedor" => ''
    end

    it 'retornar filtrando por fornecedor' do
      ordem = 'lancamento_impostos.data_de_recolhimento ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (pagamento_de_contas.pessoa_id = ?)', unidades(:sesivarzeagrande).id, pessoas(:inovare).id.to_s], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return([parcelas(:primeira_parcela)])
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::VENCIMENTO, "impostos" => "", "recolhimento_max"=>"", "recolhimento_min"=>"", "fornecedor_id" => pessoas(:inovare).id.to_s, "nome_fornecedor" => 'FTG'
    end

    it 'não filtrar por fornecedor se tiver ID mas nao tiver o nome' do
      ordem = 'lancamento_impostos.data_de_recolhimento ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return([parcelas(:primeira_parcela)])
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::VENCIMENTO, "impostos" => "", "recolhimento_max"=>"", "recolhimento_min"=>"", "fornecedor_id" => pessoas(:inovare).id.to_s, "nome_fornecedor"=>""
    end

    it 'retornar filtrando por recolhimento min e max' do
      ordem = 'lancamento_impostos.data_de_recolhimento ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (lancamento_impostos.data_de_recolhimento >= ?) AND (lancamento_impostos.data_de_recolhimento <= ?)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20), Date.new(2008, 12, 21)], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return([parcelas(:primeira_parcela)])
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::VENCIMENTO, "impostos" => "", "recolhimento_max"=>"21/12/2008", "recolhimento_min"=>"20/12/2008", "fornecedor_id"=>'', "nome_fornecedor"=> ''
    end

    it 'retornar filtrando por recolhimento max' do
      ordem = 'lancamento_impostos.data_de_recolhimento ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (lancamento_impostos.data_de_recolhimento <= ?)', unidades(:sesivarzeagrande).id, Date.new(2009, 12, 21)], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return([parcelas(:primeira_parcela)])
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::VENCIMENTO, "impostos" => "", "recolhimento_max"=>"21/12/2009", "recolhimento_min"=>"", "fornecedor_id"=>'', "nome_fornecedor"=> ''
    end

    it 'retornar filtrando por recolhimento min' do
      ordem = 'impostos.descricao ASC'
      LancamentoImposto.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (lancamento_impostos.data_de_recolhimento >= ?)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20)], :include => [:imposto, [:parcela_pagamento_de_conta => {:conta => :pessoa}]], :order => ordem).and_return([parcelas(:primeira_parcela)])
      @actual = LancamentoImposto.pesquisar_parcelas_para_relatorio_retencao_impostos :all, unidades(:sesivarzeagrande).id, "opcoes" => LancamentoImposto::ALFABETICA, "impostos" => "", "recolhimento_max"=>"", "recolhimento_min"=>"20/12/2008", "fornecedor_id"=>'', "nome_fornecedor"=> ''
    end

  end

end
