require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe ParcelaRecebimentoDeConta do

  it "deve retornar todas as parcelas de recebimentos de contas" do
    ParcelaRecebimentoDeConta.all.collect(&:id).should == Parcela.all(:conditions => "conta_type = 'RecebimentoDeConta'").collect(&:id)
  end

  it 'deve possuir funcionalidades de uma parcela normal' do
    p = ParcelaRecebimentoDeConta.find(parcelas(:primeira_parcela_recebimento).id)
    p.conta.should == recebimento_de_contas(:curso_de_design_do_paulo)
    p.valor_dos_juros_em_reais.should == "0,00"
  end

  it 'deve possuir relacionamento belongs_to não polimórfico' do
    ParcelaRecebimentoDeConta.all(:include => {:conta => :servico}, :conditions => 'servicos.id = 0')
  end

  describe 'deve pesquisar para exibir relatório de contas a receber e' do

    it 'retornar todos' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id], :include =>{:conta => :pessoa},:order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "periodo_min"=>"", "cliente_id"=>"", "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "periodo_max"=>"", "recebimento_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
 
    it 'contar todos' do
      ParcelaRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return(10)
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :count, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "periodo_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == 10
    end
 
    it 'retornar filtrando por servico_id' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.servico_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id, servicos(:curso_de_tecnologia).id.to_s],  :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=> 'Curso de Ruby on Rails', "servico_id"=>servicos(:curso_de_tecnologia).id.to_s, "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'não filtrar por servico se tiver o ID mas nao tiver o nome' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id],  :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=> '', "servico_id"=>servicos(:curso_de_tecnologia).id.to_s, "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por cliente' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id, pessoas(:paulo).id.to_s], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>pessoas(:paulo).id.to_s, "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'Paulo Vitor Zeferino', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por vendedor' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.vendedor_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id, pessoas(:felipe).id.to_s], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"Felipe Giotto", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>pessoas(:felipe).id.to_s, "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'não filtrar por cliente se tiver ID mas nao tiver o nome' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:senaivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>pessoas(:paulo).id.to_s, "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por modalidade' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (recebimento_de_contas.servico_id IN (?))', unidades(:sesivarzeagrande).id, [servicos(:curso_de_corel_do_sesi).id]], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"Ensino", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por vendido_min' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda >= ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"20/12/2008", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por recebimento min e max' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20), Date.new(2008, 12, 21)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"21/12/2008", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"20/12/2008", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por pagamento min e max' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20), Date.new(2008, 12, 21)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"21/12/2008", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"20/12/2008", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por vencimento min e max' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20), Date.new(2008, 12, 21)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"vencimento", "nome_modalidade"=>"", "periodo_max"=>"21/12/2008", "vendido_min"=>"", "periodo_min"=>"20/12/2008", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "recebimento_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por vendido_min passando data inválida' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (0=1) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"aaaa", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
 
    it 'retornar filtrando por vendido_max' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda <= ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id, Date.new(2008, 12, 20)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"20/12/2008", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
    end
 
    it 'retornar filtrando por vendido_max passando data inválida, fazer com que nao retorne nada' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (0=1) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"ASDASD", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
       
    it "retornar filtrando por opcao de inadimplência e retornando todas inadimplentes" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (parcelas.data_vencimento < ?)",unidades(:sesivarzeagrande).id, [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA], Date.today], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Inadimplência", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>""
      @actual.should == []
    end
    
    it "retorna filtrando por inadimplentes e intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (parcelas.data_vencimento < ?)",unidades(:sesivarzeagrande).id,[Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA],Date.new(2009, 1, 1), Date.new(2009, 5, 1), Date.today], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"vencimento", "nome_modalidade"=>"", "periodo_max"=>"01/05/2009", "vendido_min"=>"", "periodo_min"=>"01/01/2009", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "opcoes"=>"Inadimplência", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>""
      @actual.should == []
    end
    
    it "retorna filtrando por inadimplência e intervalo de contratos vendidos " do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?)",unidades(:sesivarzeagrande).id,[Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA], Date.new(2009, 1, 1),Date.new(2009, 5, 1)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"01/01/2009", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Inadimplência", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"01/05/2009", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>""
      @actual.should == []
    end
    
    it "retorna filtrando por Contas a Receber retornando todas as contas a receber" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?))",unidades(:sesivarzeagrande).id, [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA, Parcela::CANCELADA]], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
    
    it "retorna filtrando por Contas a Receber e intervalo de contratos vendidos " do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?)",unidades(:sesivarzeagrande).id,[Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA],Date.new(2009, 1, 1),Date.new(2009, 5, 1)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"01/01/2009", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"01/05/2009", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>""
      @actual.should == []
    end
    
    it "retorna filtrando por Contas a Receber e intervalo de vencimentos" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?)",unidades(:sesivarzeagrande).id,[Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA],Date.new(2009, 1, 1),Date.new(2009, 5, 1)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"vencimento", "nome_modalidade"=>"", "periodo_max"=>"01/05/2009", "vendido_min"=>"", "periodo_min"=>"01/01/2009", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>""
      @actual.should == []
    end
       
    it "retorna filtrando por Contas a Receber e receber todas exceto juridico" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt <> ?) AND (parcelas.situacao IN (?))", unidades(:sesivarzeagrande).id, RecebimentoDeConta::Juridico, [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA]], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas - Exceto Jurídico"
      @actual.should == []
    end
    
    it "retorna filtrando por Contas a Receber e receber todas Vincendas" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (parcelas.data_vencimento >= ?)",unidades(:sesivarzeagrande).id, [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA], Date.today], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Vincendas"
      @actual.should == []
    end
    
    it "retorna filtrando por Contas a Receber e receber todas Em Atraso" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?)) AND (parcelas.data_vencimento < ?)",unidades(:sesivarzeagrande).id,[Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA], Date.today], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Em Atraso"
      @actual.should == [] 
    end
    
    it "retorna filtrando por Contas a Receber e receber todas Jurídicas" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt = ?) AND (parcelas.situacao IN (?))", unidades(:sesivarzeagrande).id,RecebimentoDeConta::Juridico, [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA]], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Jurídico"
      @actual.should == [] 
    end
    
    it "retorna filtrando por Contas a Receber e receber todas Pendentes" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.situacao IN (?))",unidades(:sesivarzeagrande).id, [Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::QUITADA]], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Pendentes"
      @actual.should == [] 
    end
    
    it "retorna filtrando por Recebimentos com Atraso" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_vencimento < parcelas.data_da_baixa)",unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Recebimentos com Atraso", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
    
    it "retorna filtrando por Recebimentos com Atraso e intervalo de Recebimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_vencimento < parcelas.data_da_baixa)",unidades(:sesivarzeagrande).id, Date.new(2009, 5,2), Date.new(2009, 6,4)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"04/06/2009", "opcoes"=>"Recebimentos com Atraso", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"02/05/2009", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
    
    it "retorna filtrando por Recebimentos com Atraso e intervalo de Vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_vencimento < parcelas.data_da_baixa)",unidades(:sesivarzeagrande).id, Date.new(2009, 5,2), Date.new(2009, 6,4)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"vencimento", "nome_modalidade"=>"", "periodo_max"=>"04/06/2009", "vendido_min"=>"", "periodo_min"=>"02/05/2009", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "opcoes"=>"Recebimentos com Atraso", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
    
    it "retorna filtrando por Vendas Realizadas e tras todas elas" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda IS NOT NULL)",unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Vendas Realizadas", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
    
    it "retorna filtrando por Vendas Realizadas num período escolhido" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda IS NOT NULL) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?)",unidades(:sesivarzeagrande).id, Date.new(2009, 6, 1), Date.new(2009, 6, 28)], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"01/06/2009", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Vendas Realizadas", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"28/06/2009", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end
     
    it "retorna filtrando por Geral do Contas a Receber Todas" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?)",unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vencimento_max"=>"", "vendido_min"=>"", "vencimento_min"=>"", "cliente_id"=>"", "nome_servico"=>"", "servico_id"=>"", "nome_vendedor"=>"", "recebimento_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "recebimento_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas"
      @actual.should == []
    end  
    
    it "retorna filtrando por Geral do Contas a Receber Todas Exceto Juridico" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.situacao_fiemt <> ?)",unidades(:sesivarzeagrande).id,3], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=>"", "servico_id"=>"", "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Todas - Exceto Jurídico"
      @actual.should == []
    end
    
    it "retorna filtrando por Geral do Contas a Receber somentes as Vincendas" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.data_vencimento >= ?)",unidades(:sesivarzeagrande).id, Date.today], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=>"", "servico_id"=>"", "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Vincendas"
      @actual.should == []
    end
    
    it "retorna filtrando por Geral do Contas a Receber todas Em Atraso" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.data_vencimento < ?)",unidades(:sesivarzeagrande).id, Date.today], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=>"", "servico_id"=>"", "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Em Atraso"
      @actual.should == []
    end

    it "retorna filtrando por Geral do Contas a Receber todas do Jurídico" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt = ?)",unidades(:sesivarzeagrande).id, 3], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=>"", "servico_id"=>"", "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Jurídico"
      @actual.should == []
    end        
  
    it "retorna filtrando por Geral do Contas a Receber todas Pendentes" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL)",unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>"", "nome_servico"=>"", "servico_id"=>"", "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"Geral do Contas a Receber", "vendedor_id"=>"", "nome_cliente"=>"", "vendido_max"=>"", "periodo_min"=>"", "ordenacao" =>"pessoas.nome", "situacao"=>"Pendente"
      @actual.should == []
    end
    
    it 'retornar filtrando por tipo de cliente ambos' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0","ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por tipo de cliente Pessoa::FISICA' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (pessoas.tipo_pessoa = ?)', unidades(:sesivarzeagrande).id, Pessoa::FISICA], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "1","ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por tipo de cliente Pessoa::JURIDICA' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (pessoas.tipo_pessoa = ?)', unidades(:sesivarzeagrande).id, Pessoa::JURIDICA], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "2","ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por situacao das parcelas' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id, ["1", "2"], unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => ["1", "2"],"ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por situacao das parcelas passando apenas pendente' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id, ["1"], unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => ["1"],"ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por situacao das parcelas passando apenas quitada' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id, ["2"], unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => ["2"],"ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por situacao das parcelas quando todos os filtros sÃ£o selecionados' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id, ["1", "2", "3"], unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => ["1", "2", "3"],"ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por situacao das parcelas sem o campo pendentes selecionado' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id, ["2"], unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => ["2"],"ordenacao" =>"pessoas.nome"
    end

    it 'retornar filtrando por situacao das contas' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id, ["1", "2"], unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=> 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"recebimento", "nome_modalidade"=>"", "vendido_min"=>"", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => ["1", "2"],"ordenacao" =>"pessoas.nome"
    end
    
  end

  describe 'pesquisa para relatorio de clientes usando situacao da parcela' do
    fixtures :recebimento_de_contas

    it 'retorna todas as parcelas Normal e Permuta' do
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).usuario_corrente = usuarios(:quentin)
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).gerar_parcelas(2009)
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).atribui_situacao_parcela(RecebimentoDeConta::Permuta)
      ParcelaRecebimentoDeConta.all :conditions=>['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?))', unidades(:senaivarzeagrande).id, [Parcela::PENDENTE, Parcela::PERMUTA]], :include => {:conta => :pessoa}
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"", "nome_modalidade"=>"", "vendido_min"=>"10/12/2005", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"21/12/2012", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => [Parcela::PENDENTE, Parcela::PERMUTA], "ordenacao" =>"pessoas.nome"
      @actual.size.should == 5
      @actual.each {|parcela| parcela.conta == recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)}
    end

    it 'retorna todas as parcelas Normal e Baixa do Conselho' do
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).usuario_corrente = usuarios(:quentin)
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).gerar_parcelas(2009)
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).atribui_situacao_parcela(RecebimentoDeConta::Baixa_do_conselho)
      ParcelaRecebimentoDeConta.all :conditions=>['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao IN (?))', unidades(:senaivarzeagrande).id, [Parcela::PENDENTE, Parcela::BAIXA_DO_CONSELHO]], :include =>{:conta => :pessoa}
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "periodo"=>"", "nome_modalidade"=>"", "vendido_min"=>"10/12/2005", "cliente_id"=>'', "nome_servico"=> '', "servico_id"=>'', "nome_vendedor"=>"", "periodo_max"=>"21/12/2012", "opcoes"=>"", "vendedor_id"=>"", "nome_cliente"=>'', "vendido_max"=>"", "periodo_min"=>"", "tipo_pessoa" => "0", "situacao_das_parcelas" => [Parcela::PENDENTE, Parcela::BAIXA_DO_CONSELHO], "ordenacao" =>"pessoas.nome"
      @actual.size.should == 5
      @actual.each {|parcela| parcela.conta == recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)}
    end

    it 'retorna todas as parcelas' do
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).usuario_corrente = usuarios(:quentin)
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).gerar_parcelas(2009)
      recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano).atribui_situacao_parcela(RecebimentoDeConta::Permuta)
      retorno = ParcelaRecebimentoDeConta.find(:all, :conditions=>['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?) AND ((parcelas.situacao = ? AND parcelas.data_vencimento >= ? AND recebimento_de_contas.unidade_id = ?) OR (parcelas.situacao = ? AND parcelas.data_vencimento < ?)) OR (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)', unidades(:senaivarzeagrande).id, Date.today - 500, Date.today + 500, unidades(:senaivarzeagrande).id, Parcela::PENDENTE, Date.today, Parcela::PENDENTE, Date.today, [Parcela::QUITADA, Parcela::CANCELADA, Parcela::JURIDICO, Parcela::RENEGOCIADA, Parcela::CANCELADA, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA], unidades(:senaivarzeagrande).id], :include => {:conta => :pessoa}, :order => nil)
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, "vendido_min"=>Date.today - 500, "cliente_id"=>"", "servico_id"=>"", "nome_servico"=>"", "situacao_das_parcelas"=>["VINCENDA", "ATRASADA", Parcela::QUITADA, Parcela::CANCELADA, Parcela::JURIDICO, Parcela::RENEGOCIADA, Parcela::CANCELADA, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA], "vendido_max"=>Date.today + 500, "tipo_pessoa"=>"0", "nome_cliente"=>""
      @actual.should == retorno
      @actual.length.should == 13
      @actual.collect(&:situacao).sort.should == [Parcela::PENDENTE, Parcela::PENDENTE, Parcela::QUITADA, Parcela::QUITADA, Parcela::QUITADA, Parcela::QUITADA, Parcela::QUITADA, Parcela::QUITADA,Parcela::QUITADA,Parcela::QUITADA, Parcela::PERMUTA, Parcela::PERMUTA, Parcela::PERMUTA]
    end
  end

  describe 'deve pesquisar e trazer o relatorio de produtividade por funcionário' do
   
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas sem intervalo de recebimento ou vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:senaivarzeagrande).id],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it "verifica se filtra por Recebimentos/Baixas Efetuadas com Intervalo de recebimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?)',unidades(:senaivarzeagrande).id, Date.new(2009, 1, 1), Date.new(2009, 8, 1)],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "01/08/2009", "periodo_min" => "01/01/2009", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
      
    it "verifica se filtra por Recebimento/Baixas Efetuadas com intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?)',unidades(:senaivarzeagrande).id, Date.new(2009, 1,1), Date.new(2009, 8, 1)],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "01/08/2009", "periodo_min" => "01/01/2009", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
    
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas e por cliente sem intervalo de recebimento ou vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (recebimento_de_contas.pessoa_id = ?) AND (pessoas.cliente = ?)',unidades(:senaivarzeagrande).id,pessoas(:paulo).id, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => pessoas(:paulo).nome, "cliente_id" => pessoas(:paulo).id, "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas e por funcionario sem intervalo de recebimento ou vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id,pessoas(:felipe).id, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" =>"", "nome_funcionario" => pessoas(:felipe).nome, "funcionario_id" => pessoas(:felipe).id, "periodo_max" => "", "periodo_min" => "", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas e por servico sem intervalo de recebimento ou vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (recebimento_de_contas.servico_id = ?)',unidades(:senaivarzeagrande).id,servicos(:curso_de_tecnologia).id],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => "", "cliente_id" =>"", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas e por servico, cliente, funcionario sem intervalo de recebimento ou vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (pessoas.funcionario = ?)', unidades(:senaivarzeagrande).id,servicos(:curso_de_tecnologia).id,pessoas(:juan).id,pessoas(:juan).id, true, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "", "periodo_min" => "", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas e por servico, cliente, funcionario com intervalo de recebimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id,Date.new(2009, 5,1), Date.new(2009, 5, 25),servicos(:curso_de_tecnologia).id,pessoas(:juan).id,pessoas(:juan).id, true, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it 'verifica se filtra por Recebimentos/Baixas Efetuadas e por servico, cliente, funcionario com intervalo de vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id,Date.new(2009, 5,1), Date.new(2009, 5, 25),servicos(:curso_de_tecnologia).id,pessoas(:juan).id,pessoas(:juan).id, true, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Produtividade do Funcionário"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it 'verifica se filtra por Renegociações Efetuadas sem intervalo de recebimento ou vencimento' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4)',unidades(:senaivarzeagrande).id],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it "verifica se filtra por Renegociações Efetuadas com Intervalo de recebimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?)',unidades(:senaivarzeagrande).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
    
    it "verifica se filtra por Renegociações Efetuadas com Intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?)',unidades(:senaivarzeagrande).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
    
    it "verifica se filtra por Renegociações Efetuadas e por cliente sem Intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (recebimento_de_contas.pessoa_id = ?) AND (pessoas.cliente = ?)',unidades(:senaivarzeagrande).id,pessoas(:juan).id, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
    
    it "verifica se filtra por Renegociações Efetuadas e por funcionario sem Intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id,pessoas(:juan).id, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "", "periodo_min" => "", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
    
    it "verifica se filtra por Renegociações Efetuadas e por servico sem Intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (recebimento_de_contas.servico_id = ?)',unidades(:senaivarzeagrande).id,servicos(:curso_de_tecnologia).id],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end 
    
    it "verifica se filtra por Renegociações Efetuadas e por servico, cliente, funcionario sem Intervalo de vencimento ou recebimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id, servicos(:curso_de_tecnologia).id,pessoas(:juan).id,pessoas(:juan).id, true, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "", "periodo_min" => "", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end

    it "verifica se filtra por Renegociações Efetuadas e por servico, cliente, funcionario com Intervalo de recebimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25),servicos(:curso_de_tecnologia).id,pessoas(:juan).id,pessoas(:juan).id, true, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it "verifica se filtra por Renegociações Efetuadas e por servico, cliente, funcionario com Intervalo de vencimento" do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = 4) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (pessoas.funcionario = ?)',unidades(:senaivarzeagrande).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25),servicos(:curso_de_tecnologia).id,pessoas(:juan).id,pessoas(:juan).id, true, true],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:juan).nome, "cliente_id" => pessoas(:juan).id, "nome_funcionario" => pessoas(:juan).nome, "funcionario_id" => pessoas(:juan).id, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Renegociações Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end     
   
    it "verifica se filtra por Ações/Cobranças " do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:senaivarzeagrande).id],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Ações Cobranças Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end
    
    it "verifica se filtra por Ações/Cobranças por período " do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?)',unidades(:senaivarzeagrande).id,Date.new(2009, 5, 25),Date.new(2009, 8, 25)],:include => {:conta => :pessoa}).and_return([parcelas(:primeira_parcela_recebimento)])
      @actual = ParcelaRecebimentoDeConta.pesquisar_produtividade_dos_funcionarios :all, unidades(:senaivarzeagrande).id, "periodo"=>"", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/08/2009", "periodo_min" => "25/05/2009", "opcoes" => "Ações Cobranças Efetuadas"
      @actual.should == [parcelas(:primeira_parcela_recebimento)]
    end  
    
  end
  
  describe 'pesquisa de relatório de clientes ao SPC' do

    it 'retornar pesquisa sem nenhum parametro' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?)", unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=>"parcelas.data_vencimento").and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_de_clientes_ao_spc :all, unidades(:sesivarzeagrande).id, {}
      @actual.should == []
    end

    it 'retornar pesquisa verificando se o cliente está no SPC' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?)", unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order=>"parcelas.data_vencimento").and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_de_clientes_ao_spc :all, unidades(:sesivarzeagrande).id, {"spc" => true}
      @actual.should == []
    end
         
    it 'retornar pesquisa verificando se a parcela está atrasada' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.situacao = ?) AND (parcelas.data_vencimento < ?)", unidades(:sesivarzeagrande).id, Parcela::PENDENTE, Date.today], :include => {:conta => :pessoa}, :order=>"parcelas.data_vencimento").and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_de_clientes_ao_spc :all, unidades(:sesivarzeagrande).id, {"data_vencimento" => Date.today, "situacao" => Parcela::PENDENTE}
      @actual.should == []
    end
    
  end

  describe 'pesquisa de relatorio de clientes' do

    it 'retornar pesquisa com situaco atrasada, vincenda e quitada' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?) AND (parcelas.situacao = ? AND parcelas.data_vencimento >= ? AND recebimento_de_contas.unidade_id = ?) OR (parcelas.situacao = ? AND parcelas.data_vencimento < ? AND recebimento_de_contas.unidade_id = ?) OR (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)", unidades(:senaivarzeagrande).id, Date.new(2008, 03, 17), Date.new(2010, 03, 17), 1, Date.today, unidades(:senaivarzeagrande).id, 1, Date.today, unidades(:senaivarzeagrande).id, ["2"], unidades(:senaivarzeagrande).id], :include => {:conta => :pessoa}, :order => nil).and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, {"vendido_min" => "17/03/2008", "cliente_id" => "", "servico_id" => "", "nome_servico" => "",
        "situacao_das_parcelas" => ["VINCENDA", "ATRASADA", "2"], "vendido_max" => "17/03/2010", "tipo_pessoa" => "0", "nome_cliente" => ""}
      @actual.should == []
    end

    it 'retornar pesquisa com situaco vincenda, quitada e canceladas' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.data_venda >= ?) AND (recebimento_de_contas.data_venda <= ?) AND (parcelas.situacao = ? AND parcelas.data_vencimento >= ? AND recebimento_de_contas.unidade_id = ?) OR (parcelas.situacao IN (?) AND recebimento_de_contas.unidade_id = ?)", unidades(:senaivarzeagrande).id, Date.new(2008, 03, 17), Date.new(2010, 03, 17), 1, Date.today, unidades(:senaivarzeagrande).id, ["2", "3"], unidades(:senaivarzeagrande).id], :include => {:conta => :pessoa}, :order => nil).and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, {"vendido_min" => "17/03/2008", "cliente_id" => "", "servico_id" => "", "nome_servico" => "",
        "situacao_das_parcelas" => ["VINCENDA", "2", "3"], "vendido_max" => "17/03/2010", "tipo_pessoa" => "0", "nome_cliente" => ""}
      @actual.should == []
    end

  end

  describe 'pesquisa de relatorio geral de contas a receber com novos parametros de situacao fiemt' do

    before(:each) do
      @hash_com_parametros = {"modalidade_id" => "", "nome_modalidade" => "", "periodo_min" => "",
        "vendido_min" => "", "cliente_id" => "", "servico_id" => "", "nome_servico" => "", "ordenacao" => "pessoas.nome",
        "nome_vendedor" => "", "periodo" => "recebimento",
        "periodo_max" => "", "vendedor_id" =>"", "vendido_max" => "", "nome_cliente" => ""}
    end

    it 'retornar com situacao fiemt: Jurídico' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt = ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Juridico], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Jurídico", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Permuta' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt = ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Permuta], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Permuta", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Baixa do Conselho' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt = ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Baixa_do_conselho], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Baixa do Conselho", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Inativo' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (recebimento_de_contas.situacao_fiemt = ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Inativo], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Inativo", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Todas - Exceto Jurídico' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.situacao_fiemt <> ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Juridico], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Todas - Exceto Jurídico", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Todas - Exceto Permuta' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.situacao_fiemt <> ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Permuta], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Todas - Exceto Permuta", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Todas - Exceto Baixa do Conselho' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.situacao_fiemt <> ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Baixa_do_conselho], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Todas - Exceto Baixa do Conselho", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end

    it 'retornar com situacao fiemt: Todas - Exceto Inativo' do
      ParcelaRecebimentoDeConta.should_receive(:all).with(:conditions => ["(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.situacao_fiemt <> ?)", unidades(:senaivarzeagrande).id, RecebimentoDeConta::Inativo], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaRecebimentoDeConta.pesquisar_parcelas_para_relatorio_a_receber_geral :all, unidades(:senaivarzeagrande).id, @hash_com_parametros.merge({"situacao" => "Todas - Exceto Inativo", "opcoes" => "Geral do Contas a Receber"})
      @actual.should == []
    end
    
  end    

end