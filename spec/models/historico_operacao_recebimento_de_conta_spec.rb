require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HistoricoOperacaoRecebimentoDeConta do

  it "deve retornar todas as historico operacao de recebimentos de contas" do
    HistoricoOperacaoRecebimentoDeConta.all.collect(&:id).should == HistoricoOperacao.all(:conditions => "conta_type = 'RecebimentoDeConta'").collect(&:id)
  end

  it 'deve possuir funcionalidades de um historico operacao normal' do
    h = HistoricoOperacaoRecebimentoDeConta.find(historico_operacoes(:historico_operacao_recebimento_lancado))
    h.conta.should == recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    h.descricao.should == 'Conta a Receber Lançada'
  end

  it 'deve possuir relacionamento belongs_to não polimórfico' do
    HistoricoOperacaoRecebimentoDeConta.all(:include => {:conta => :servico}, :conditions => 'servicos.id = 0')
  end

  it 'verifica relacionamento com usuário' do
    h = HistoricoOperacaoRecebimentoDeConta.find(historico_operacoes(:historico_operacao_recebimento_lancado))
    h.usuario.should == usuarios(:quentin)
  end

  describe 'pesquisa de histórico operação' do

    it 'sem passar parâmetros com count' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:count).with(:conditions => ['(historico_operacoes.numero_carta_cobranca IS NOT NULL)'], :include => [{:conta => :pessoa}, :usuario], :order =>"recebimento_de_contas.numero_de_controle").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :count, {"ordenacao"=>"recebimento_de_contas.numero_de_controle","emissao_min"=>"", "funcionario_id"=>"", "unidade_id"=>"", "tipo_de_carta"=>"",
        "nome_unidade"=>"", "emissao_max"=>"", "nome_funcionario"=>""}
    end

    it 'passando tipo_de_carta parâmetros com all' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(historico_operacoes.numero_carta_cobranca = ?)', 1], :include => [{:conta => :pessoa}, :usuario], :order =>"recebimento_de_contas.numero_de_controle").and_return([])
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :all, {"ordenacao"=>"recebimento_de_contas.numero_de_controle", "emissao_min"=>"", "funcionario_id"=>"", "unidade_id"=>"", "tipo_de_carta"=>"1",
        "nome_unidade"=>"", "emissao_max"=>"", "nome_funcionario"=>""}
    end

    it 'passando unidade parâmetros com all' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(historico_operacoes.numero_carta_cobranca = ?) AND (recebimento_de_contas.unidade_id = ?)', 1, 1234], :include => [{:conta => :pessoa}, :usuario], :order =>"recebimento_de_contas.numero_de_controle").and_return([])
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :all, {"ordenacao"=>"recebimento_de_contas.numero_de_controle", "emissao_min"=>"", "funcionario_id"=>"", "unidade_id"=>"1234", "tipo_de_carta"=>"1",
        "nome_unidade"=>"Unidade nova", "emissao_max"=>"", "nome_funcionario"=>""}
    end

    it 'passando pessoa parâmetros com all' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:count).with(:conditions => ['(historico_operacoes.numero_carta_cobranca = ?) AND (recebimento_de_contas.unidade_id = ?) AND (usuarios.funcionario_id = ?)', 1, 1234, 4321], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :count, {"ordenacao"=>"pessoas.nome", "emissao_min"=>"", "funcionario_id"=>"4321", "unidade_id"=>"1234", "tipo_de_carta"=>"1",
        "nome_unidade"=>"Unidade nova", "emissao_max"=>"", "nome_funcionario"=>"Rafael"}
    end

    it 'passando data de emissão mínima parâmetros com all' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:count).with(:conditions => ['(historico_operacoes.numero_carta_cobranca IS NOT NULL) AND (historico_operacoes.created_at >= ?)', Date.new(2009, 07, 28)], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :count, {"ordenacao"=>"pessoas.nome", "emissao_min"=>"28/07/2009", "funcionario_id"=>"", "unidade_id"=>"", "tipo_de_carta"=>"",
        "nome_unidade"=>"", "emissao_max"=>"", "nome_funcionario"=>""}
    end

    it 'passando data de emissão máxima parâmetros com all' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:count).with(:conditions => ['(historico_operacoes.numero_carta_cobranca IS NOT NULL) AND (historico_operacoes.created_at <= ?)', Date.new(2009, 07, 28)], :include => [{:conta => :pessoa}, :usuario], :order =>"historico_operacoes.created_at").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :count, {"ordenacao"=>"historico_operacoes.created_at", "emissao_min"=>"", "funcionario_id"=>"", "unidade_id"=>"", "tipo_de_carta"=>"",
        "nome_unidade"=>"", "emissao_max"=>"28/07/2009", "nome_funcionario"=>""}
    end

    it 'passando intervalo entre datas parâmetros com all' do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:count).with(:conditions => ['(historico_operacoes.numero_carta_cobranca IS NOT NULL) AND (historico_operacoes.created_at >= ?) AND (historico_operacoes.created_at <= ?)', Date.new(2009, 07, 27), Date.new(2009, 07, 28)], :include => [{:conta => :pessoa}, :usuario], :order=>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisar_historicos_operacoes :count, {"ordenacao"=>"pessoas.nome", "emissao_min"=>"27/07/2009", "funcionario_id"=>"", "unidade_id"=>"", "tipo_de_carta"=>"", 
        "nome_unidade"=>"", "emissao_max"=>"28/07/2009", "nome_funcionario"=>""}
    end

  end
  
   
  describe "pesquisa_follow_up_agrupado_por_funcionario" do
    
    it "filtrando por periodo" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:count).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (historico_operacoes.created_at >= ?) AND (historico_operacoes.created_at <= ?)', unidades(:senaivarzeagrande).id,Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario :count, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por servico" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.servico_id = ?) AND (historico_operacoes.created_at >= ?) AND (historico_operacoes.created_at <= ?)', unidades(:senaivarzeagrande).id, servicos(:curso_de_tecnologia).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por cliente" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (pessoas.id = ?) AND (pessoas.cliente = ?) AND (historico_operacoes.created_at >= ?) AND (historico_operacoes.created_at <= ?)', unidades(:senaivarzeagrande).id, pessoas(:paulo).id, true, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => pessoas(:paulo).nome, "cliente_id" => pessoas(:paulo).id.to_s, "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por funcionario" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (usuarios.funcionario_id = ?) AND (historico_operacoes.created_at >= ?) AND (historico_operacoes.created_at <= ?)', unidades(:senaivarzeagrande).id, pessoas(:paulo).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => pessoas(:paulo).nome, "funcionario_id" => pessoas(:paulo).id.to_s, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por servico, cliente, funcionario" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.servico_id = ?) AND (pessoas.id = ?) AND (pessoas.cliente = ?) AND (usuarios.funcionario_id = ?) AND (historico_operacoes.created_at >= ?) AND (historico_operacoes.created_at <= ?)', unidades(:senaivarzeagrande).id, servicos(:curso_de_tecnologia).id, pessoas(:paulo).id, true, pessoas(:paulo).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => [{:conta => :pessoa}, :usuario], :order =>"pessoas.nome").and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_funcionario :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:paulo).nome, "cliente_id" => pessoas(:paulo).id, "nome_funcionario" => pessoas(:paulo).nome, "funcionario_id" => pessoas(:paulo).id.to_s, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
  end

  it 'retorna agrupamento' do
    h = HistoricoOperacaoRecebimentoDeConta.find(historico_operacoes(:historico_operacao_recebimento_lancado).id)
    h.retorna_agrupamento_para_pesquisa('Entidade').should == h.conta.unidade.entidade
    h.retorna_agrupamento_para_pesquisa('Unidade').should == h.conta.unidade
    h.retorna_agrupamento_para_pesquisa('Funcionário').should == h.usuario
  end

  describe "pesquisa_follow_up_cliente" do

    it "filtrando por cliente quando cliente não está em branco" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (pessoas.id = ?) AND (pessoas.cliente = true)', unidades(:senaivarzeagrande).id, pessoas(:paulo).id], :include => {:conta => :pessoa}).and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_cliente :all, unidades(:senaivarzeagrande).id,"nome_cliente" => pessoas(:paulo).nome, "cliente_id" => pessoas(:paulo).id.to_s
    end

    it "filtrando por cliente quando cliente está em branco" do
      HistoricoOperacaoRecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (pessoas.id = ?) AND (pessoas.cliente = true)', unidades(:senaivarzeagrande).id,''], :include => {:conta => :pessoa}).and_return(0)
      @actual = HistoricoOperacaoRecebimentoDeConta.pesquisa_follow_up_por_cliente :all, unidades(:senaivarzeagrande).id,"cliente_id" => '', "nome_cliente"=>''
    end

  end

end
