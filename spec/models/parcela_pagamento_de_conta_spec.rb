require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ParcelaPagamentoDeConta do

  it "Deve retornar todas as parcelas referente a Pagamento de Conta" do
    ParcelaPagamentoDeConta.all.collect(&:id).should == Parcela.all(:conditions => "conta_type = 'PagamentoDeConta'").collect(&:id)
  end  
  
  it "Deve possuir funcionalidade de uma parcela de contas a Pagar normal" do
    p = ParcelaPagamentoDeConta.find(parcelas(:primeira_parcela).id)
    p.conta.should == pagamento_de_contas(:pagamento_cheque_outra_unidade)
    p.valor_dos_juros_em_reais.should == "1,00"
  end 

  it "Deve possuir relacionamento belongs_to não polimorfico com o model conta" do
    p = pagamento_de_contas(:pagamento_cheque).id
    ParcelaPagamentoDeConta.all(:include => {:conta =>:centro}, :conditions =>'centros.id = 0')
  end

  describe "Deve pesquisar para exibir relatórios de contas a pagar e" do

    it "passar tipo opção de relatorio vazio e vencimento" do
      pag = pagamento_de_contas(:pagamento_cheque)
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions=>['(pagamento_de_contas.unidade_id = ?) AND (parcelas.id IS NOT NULL)',unidades(:senaivarzeagrande).id], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return(pag.parcelas[0])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:senaivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"", "vencimento_max"=>""
      @actual.should == pag.parcelas[0]
    end

    it "passar tipo opção de relatorio vazio e vencimento e contar" do
      pag = pagamento_de_contas(:pagamento_dinheiro)
      pag.usuario_corrente = usuarios(:quentin)
      pag.gerar_parcelas(2009)
      pag.save!
      pagamento_de_contas(:pagamento_dinheiro).gerar_parcelas(2009)
      ParcelaPagamentoDeConta.should_receive(:count).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.id IS NOT NULL)',unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa}, :order => 'pessoas.nome').and_return(4)
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :count, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"", "vencimento_max"=>""
      @actual.should == 4
    end

    it "retornar todos" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions=>['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id],:include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento))
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento)
    end
  
    it "contar todos" do
      ParcelaPagamentoDeConta.should_receive(:count).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(3)
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :count, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == 3
    end



    it "retornar todos os pagamentos" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions=>['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id],:include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento))
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento)
    end

    it "contar todos os pagamentos" do
      ParcelaPagamentoDeConta.should_receive(:count).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id], :include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(3)
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :count, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == 3
    end

    it "retornar todos as inadimplencias" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions=>["(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.data_vencimento < ?)",unidades(:sesivarzeagrande).id, Date.today.to_s],:include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento))
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"inadimplencia", "vencimento_max"=>""
      @actual.should == parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento)
    end

    it "contar todos as inadimplencias" do
      ParcelaPagamentoDeConta.should_receive(:count).with(:conditions => ["(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (parcelas.data_vencimento < ?)", unidades(:sesivarzeagrande).id, Date.today.to_s], :include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(3)
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :count, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"inadimplencia", "vencimento_max"=>""
      @actual.should == 3
    end

    it "retornar todas as pendentes" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions=>['(pagamento_de_contas.unidade_id = ?) AND (parcelas.situacao = ?)',unidades(:sesivarzeagrande).id, Parcela::PENDENTE],:include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento))
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"todos", "vencimento_max"=>"", "situacao" => Parcela::PENDENTE.to_s
      @actual.should == parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento)
    end

    it "contar todas as pendentes" do
      ParcelaPagamentoDeConta.should_receive(:count).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.situacao = ?)', unidades(:sesivarzeagrande).id, Parcela::PENDENTE], :include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(3)
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :count, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"todos", "vencimento_max"=>"", "situacao" => Parcela::PENDENTE.to_s
      @actual.should == 3
    end

    it "retornar todas as quitadas" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions=>['(pagamento_de_contas.unidade_id = ?) AND (parcelas.situacao = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id, Parcela::QUITADA],:include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento))
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"todos", "vencimento_max"=>"", "situacao" => Parcela::QUITADA.to_s
      @actual.should == parcelas(:primeira_parcela_sesi,:segunda_parcela_pagamento_banco,:segunda_parcela_recebimento)
    end

    it "contar todas as quitadas" do
      ParcelaPagamentoDeConta.should_receive(:count).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.situacao = ?) AND (parcelas.data_da_baixa IS NOT NULL)', unidades(:sesivarzeagrande).id, Parcela::QUITADA], :include =>{:conta => :pessoa},:order=>'pessoas.nome').and_return(3)
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :count, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=>"", "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"todos", "vencimento_max"=>"", "situacao" => Parcela::QUITADA.to_s
      @actual.should == 3
    end

    


    it "filtrar por fornecedor" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (pagamento_de_contas.pessoa_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id,pessoas(:inovare).id], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=> pessoas(:inovare).nome , "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id, "ordenacao"=>"pessoas.nome", "opcoes"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == ([]) 
    end
       
    it "não filtrar por fornecedor quando tem o id mas não tem o nome " do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=> "" , "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>pessoas(:inovare).id, "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == ([])
    end    
  
    it "filtrar por tipo de documento" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (pagamento_de_contas.tipo_de_documento = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id,'CPMF'], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id,"pagamento_max"=>"", "nome_fornecedor"=> "" , "vencimento_min"=>"", "pagamento_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"CPMF", "opcao_de_relatorio"=>"pagamentos", "vencimento_max"=>""
      @actual.should == ([])
    end
    
    it "filtrar por pagamento min" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id,Date.new(2008, 01, 01)], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"pagamento", "periodo_max"=>"", "nome_fornecedor"=> "" , "periodo_min"=>"01/01/2008", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos"
      @actual.should == ([])
    end

    it "filtrar por pagamento min e max" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa >= ?) AND (parcelas.data_da_baixa <= ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id,Date.new(2008, 01, 01),Date.new(2008, 10, 01)], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"pagamento", "periodo_max"=>"01/10/2008", "nome_fornecedor"=> "" , "vencimento_min"=>"", "periodo_min"=>"01/01/2008", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos"
      @actual.should == ([])
    end 
   
    it "filtrar por vencimento min" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id,Date.new(2008, 01, 01)], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"vencimento", "periodo_max"=>"", "nome_fornecedor"=> "" , "periodo_min"=>"01/01/2008", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos"
      @actual.should == ([])
    end
    
    it "filtrar por vencimento min e max" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_vencimento >= ?) AND (parcelas.data_vencimento <= ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id,Date.new(2008, 01, 01),Date.new(2008, 10, 01)], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"vencimento", "nome_fornecedor"=> "" , "periodo_min"=>"01/01/2008", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos", "periodo_max"=>"01/10/2008"
      @actual.should == ([])
    end

    it "filtrar por tipo_de_relatorio" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"pagamento", "periodo_max"=>"", "nome_fornecedor"=> "" , "periodo_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos"
      @actual.should == ([])
    end     
    
    it "filtrar por ordenação" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ['(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL)',unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa},:order=>'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"pagamento", "periodo_max"=>"", "nome_fornecedor"=> "" , "periodo_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos"
      @actual.should == ([])
    end

    it "filtrar por opcao_de_relatorio: contas_a_pagar" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ["(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NULL) AND (situacao = ?)", unidades(:sesivarzeagrande).id, Parcela::PENDENTE], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"pagamento", "periodo_max"=>"", "nome_fornecedor"=> "" , "periodo_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"contas_a_pagar"
      @actual.should == ([])
    end

    it "filtrar por opcao_de_relatorio: pagamentos_com_atraso" do
      ParcelaPagamentoDeConta.should_receive(:all).with(:conditions => ["(pagamento_de_contas.unidade_id = ?) AND (parcelas.data_da_baixa IS NOT NULL) AND (data_vencimento < data_da_baixa)", unidades(:sesivarzeagrande).id], :include => {:conta => :pessoa}, :order => 'pessoas.nome').and_return([])
      @actual = ParcelaPagamentoDeConta.pesquisar_parcelas_para_relatorio_de_contas_a_pagar_geral :all, unidades(:sesivarzeagrande).id, "periodo"=>"pagamento", "periodo_max"=>"", "nome_fornecedor"=> "" , "periodo_min"=>"", "fornecedor_id"=>"", "ordenacao"=>"pessoas.nome", "tipo_de_documento"=>"", "opcao_de_relatorio"=>"pagamentos_com_atraso"
      @actual.should == ([])
    end
    
  end  

end  

