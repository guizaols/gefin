require File.dirname(__FILE__) + '/../spec_helper'

describe Movimento do
  
  before(:each) do
    @movimento = Movimento.new
  end
  
  it "valida presença dos campos" do
    @movimento.provisao = nil
    @movimento.numero_da_parcela = nil

    @movimento.should_not be_valid
    @movimento.errors.on(:historico).should == "é inválido."
    @movimento.errors.on(:tipo_documento).should == "é inválido."
    @movimento.errors.on(:tipo_lancamento).should == "é inválido."
    @movimento.errors.on(:provisao).should == "é inválido."
    @movimento.errors.on(:unidade).should == "é inválida."
    @movimento.errors.on(:pessoa).should == "é inválido."

    @movimento.historico = "Lancamento do dia 4 de abril"
    @movimento.tipo_documento = "CTREV"
    @movimento.tipo_lancamento = "E"
    @movimento.numero_da_parcela = 0
    @movimento.provisao = 0
    @movimento.unidade = unidades(:senaivarzeagrande)
    @movimento.pessoa = pessoas(:paulo)
    @movimento.conta = pagamento_de_contas(:pagamento_cheque)
    @movimento.should be_valid
    
    @movimento.errors.on(:historico).should == nil
    @movimento.errors.on(:tipo_documento).should == nil
    @movimento.errors.on(:tipo_lancamento).should == nil
    @movimento.errors.on(:numero_da_parcela).should == nil
    @movimento.errors.on(:provisao).should == nil
    @movimento.errors.on(:unidade).should == nil
    @movimento.errors.on(:pessoa).should == nil
  end
  
  it "valida inclusão de tipo_lancamento" do
    @movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :data_lancamento => "04/08/2009", :tipo_documento => "CPMF", :valor_total => 10000, :numero_da_parcela => 0, :provisao => 0, :pessoa => pessoas(:paulo), :unidade => unidades(:senaivarzeagrande)
    @movimento.conta = pagamento_de_contas(:pagamento_cheque) 
    @movimento.should_not be_valid
    @movimento.tipo_lancamento = "E"     
    @movimento.should be_valid 
    @movimento.tipo_lancamento = "D" 
    @movimento.should_not be_valid 
    @movimento.tipo_lancamento = "S"  
    @movimento.should be_valid  
  end  
  
  it "valida relacionamento com ItensMovimento" do
    movimentos(:primeiro_lancamento_entrada).itens_movimentos.should == [itens_movimentos(:credito_primeiro_movimento), itens_movimentos(:debito_primeiro_movimento)]
  end

  it "valida relacionamento com Unidade" do
    movimentos(:primeiro_lancamento_entrada).unidade.should == unidades(:senaivarzeagrande)
  end

  it "valida relacionamento com Pessoa" do
    movimentos(:primeiro_lancamento_entrada).pessoa.should == pessoas(:paulo)
    movimentos(:segundo_lancamento_saida).pessoa.should == pessoas(:juan)
  end

  it "valida relacionamento com Parcela" do
    movimentos(:lancamento_com_a_conta_pagamento_cheque).parcela.should == parcelas(:parcela_pagamento_cheque_para_movimento)
  end

  it "teste relacionamento polimorfico de conta" do
    movimentos(:lancamento_com_a_conta_pagamento_cheque).conta.should == pagamento_de_contas(:pagamento_cheque)
  end
  
  it "verifica funcao tipo_lancamento_verbose" do
    movimentos(:primeiro_lancamento_entrada).tipo_lancamento_verbose.should == "Entrada"
    movimentos(:segundo_lancamento_saida).tipo_lancamento_verbose.should == "Saída"
  end
  
  it "transforma data para padrão brasileiro" do
    movimentos(:primeiro_lancamento_entrada).data_lancamento.should == "01/03/2009"
  end
  
  it "testa campos virtuais" do
    @movimento.lancamento_simples = {}
    @movimento.lancamento_simples.should == {}
    @movimento.valor_do_documento_em_reais.should == '0,00'
    @movimento.nome_pessoa.should == nil
  end

  it "testa leitura de lancamento simples" do
    movimento = movimentos(:primeiro_lancamento_entrada)
    movimento.lancamento_simples.should == {"centro_nome" => "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
      "centro_id" => centros(:centro_forum_economico).id, "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id,
      "conta_contabil_nome" => "11010102001 - Conta bancária no Banco do Brasil",  "conta_contabil_id" => plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id, "conta_corrente_id" => contas_correntes(:primeira_conta).id,
      "conta_corrente_nome" => "2345-3 - Conta do Senai Várzea Grande"}
  end
  
  it "testa conversao de valores correta" do
    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :data_lancamento => "04/08/2009", :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_total => "10000", :numero_da_parcela => 0, :provisao => 3, :pessoa => pessoas(:paulo)
    movimento.valid?
    
    movimento.valor_do_documento_em_reais.should == "100,00"
  end
  
  it "testa conversao de valores" do
    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :data_lancamento => "04/08/2009", :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_do_documento_em_reais => "ERRO", :numero_da_parcela => 0, :provisao => 3, :pessoa => pessoas(:paulo)
    movimento.valid?
    
    movimento.valor_do_documento_em_reais.should == '0,00'
  end
  
  it "testa data de lancamento no initialize" do
    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_total => 1000
 
    movimento.data_lancamento.should == Date.today.to_s_br
    movimento.provisao.should == 3
    movimento.numero_da_parcela == nil
    
    outro_movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :data_lancamento => "04/08/2009", :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_total => 1000, :numero_da_parcela => 1, :provisao => 1, :pessoa => pessoas(:paulo)
 
    outro_movimento.data_lancamento.should == "04/08/2009"
    outro_movimento.provisao.should == 1
    outro_movimento.numero_da_parcela == 1
  end
  
  it "testa preparacao de dados para lancamento simples de entrada" do
    # Esta função possui mocks em movimentos_controller_spec.rb

    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :data_lancamento => "04/08/2009", :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_do_documento_em_reais => "100,00", :pessoa => pessoas(:paulo),
      :lancamento_simples => { 'unidade_organizacional_id' => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
      'centro_id' => centros(:centro_forum_social).id, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
      'conta_corrente_id' => contas_correntes(:segunda_conta).id, 'unidade_organizacional_nome' => "Unidade", 'centro_nome' => "Centro", 'conta_contabil_nome' => "Conta Contabil", 'conta_corrente_nome' => "Conta Corrente" }
    
    movimento.prepara_lancamento_simples.should == 
      [movimento, 
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
          :centro => centros(:centro_forum_social), :valor => 10000 }],
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
          :centro => centros(:centro_forum_social), :valor => 10000 }]]

    Movimento.lanca_contabilidade(2009, movimento.prepara_lancamento_simples, unidades(:senaivarzeagrande).id).should == true

    Movimento.last.unidade_id.should == unidades(:senaivarzeagrande).id
  end
  
  it "testa o relacionamento do dependent" do
    movimento = movimentos(:primeiro_lancamento_entrada)
     
    assert_difference 'Movimento.count', -1 do
      assert_difference 'ItensMovimento.count', -2 do
        movimento.destroy
      end
    end    
   
  end

  it "testa funcao remove_itens_do_movimento" do
    assert_difference 'ItensMovimento.count', -2 do
      movimentos(:primeiro_lancamento_entrada).remove_itens_do_movimento
    end
  end

  it "testa preparacao de dados para lancamento simples de entrada" do
    # Esta função possui mocks em movimentos_controller_spec.rb
    
    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1",
      :data_lancamento => "04/08/2009", :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_do_documento_em_reais => "100,00", :pessoa => pessoas(:paulo),
      :lancamento_simples => { 'unidade_organizacional_id' => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
      'centro_id' => centros(:centro_forum_social).id, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
      'conta_corrente_id' => contas_correntes(:segunda_conta).id, 'unidade_organizacional_nome' => "Unidade", 'centro_nome' => "Centro", 'conta_contabil_nome' => "Conta Contabil", 'conta_corrente_nome' => "Conta Corrente" }

    movimento.prepara_lancamento_simples.should ==
      [movimento,
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional),
          :centro => centros(:centro_forum_social), :valor => 10000 }],
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional),
          :centro => centros(:centro_forum_social), :valor => 10000 }]]

    Movimento.lanca_contabilidade(2009, movimento.prepara_lancamento_simples, unidades(:senaivarzeagrande).id).should == true

    Movimento.last.unidade_id.should == unidades(:senaivarzeagrande).id
  end
  
  it "testa preparacao de dados para lancamento simples de entrada e tenta lançar, porém ele monta com os valores vazios" do
    # Esta função possui mocks em movimentos_controller_spec.rb

    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1",
      :data_lancamento => "04/08/2009", :tipo_lancamento => "S", :tipo_documento => "CPMF", :valor_do_documento_em_reais => "100,00", :pessoa => pessoas(:paulo),
      :lancamento_simples => { 'unidade_organizacional_id' => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
      'centro_id' => centros(:centro_forum_social).id, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
      'conta_corrente_id' => contas_correntes(:segunda_conta).id, 'unidade_organizacional_nome' => "Unidade", 'centro_nome' => "", 'conta_contabil_nome' => "Conta Contabil", 'conta_corrente_nome' => "Conta Corrente" }

    movimento.prepara_lancamento_simples.should == 
      [movimento, 
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
          :centro => nil, :valor => 10000 }],
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
          :centro => nil, :valor => 10000 }]]
  end
  
  it "testa preparacao de dados para lancamento simples de entrada com valor do documento em reais vazio e lança esse movimento" do
    movimento = Movimento.new :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1", 
      :data_lancamento => "04/08/2009", :tipo_lancamento => "E", :tipo_documento => "CPMF", :valor_do_documento_em_reais => "", :pessoa => pessoas(:paulo),
      :lancamento_simples => { 'unidade_organizacional_id' => unidade_organizacionais(:sesi_colider_unidade_organizacional).id,
      'centro_id' => centros(:centro_forum_social).id, 'conta_contabil_id' => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
      'conta_corrente_id' => contas_correntes(:segunda_conta).id, 'unidade_organizacional_nome' => "Unidade", 'centro_nome' => "Centro", 'conta_contabil_nome' => "Conta Contabil", 'conta_corrente_nome' => "Conta Corrente" }
    
    movimento.prepara_lancamento_simples.should == 
      [movimento, 
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
          :centro => centros(:centro_forum_social), :valor => 0 }],
      [{ :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
          :centro => centros(:centro_forum_social), :valor => 0 }]]
    
    Movimento.lanca_contabilidade(2009, movimento.prepara_lancamento_simples, unidades(:senaivarzeagrande).id).should_not == true
  end
  
  it "testa função de classe lanca_contabilidade" do
    dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "LANCAMENTO 04/08/2009", :numero_de_controle => "CONTROLE 1",
      :data_lancamento => "2009-08-04".to_date, :tipo_lancamento => "E", :tipo_documento => "CPMF", :provisao => 1, :numero_da_parcela => 1, :pessoa => pessoas(:paulo), :conta_id => pagamento_de_contas(:pagamento_dinheiro)}
   
    lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 7000 }        

    lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 7000 }    
    lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]
    
    Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)
    
    ultimo_movimento = Movimento.last    
    ultimo_movimento.historico.should == "LANCAMENTO 04/08/2009"
    ultimo_movimento.numero_de_controle.should == "CONTROLE 1"
    ultimo_movimento.data_lancamento.should == "04/08/2009"
    ultimo_movimento.tipo_lancamento.should == "E"
    ultimo_movimento.tipo_documento.should == "CPMF"
    ultimo_movimento.provisao.should == 1
    ultimo_movimento.numero_da_parcela == 1
    ultimo_movimento.pessoa.should == pessoas(:paulo)
    ultimo_movimento.unidade.should == unidades(:senaivarzeagrande)

    movimento_debito = ultimo_movimento.itens_movimentos.first    
    movimento_debito.tipo.should == "D"
    movimento_debito.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    movimento_debito.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    movimento_debito.centro.should == centros(:centro_forum_social)
    movimento_debito.valor.should == 7000
    
    movimento_credito = ultimo_movimento.itens_movimentos.last    
    movimento_credito.tipo.should == "C"
    movimento_credito.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_despesas)
    movimento_credito.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    movimento_credito.centro.should == centros(:centro_forum_social)
    movimento_credito.valor.should == 7000
  end
  
  it "testa função de classe lanca_contabilidade com dois lancamentos de debito e um de credito" do
    dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "LANCAMENTO 09/04/2009", :numero_de_controle => "CONTROLE 2",
      :conta_id=>pagamento_de_contas(:pagamento_dinheiro).id, :data_lancamento => "2009-04-09".to_date, :tipo_lancamento => "E", :tipo_documento => "CPMF", :provisao => 1, :numero_da_parcela => 1, :pessoa => pessoas(:paulo)}
    lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 4000 }        
    outro_lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 3000 }        
    lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 6000 } 
    outro_lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 1000 }     
    lancamento = [dados_do_lancamento, [lancamento_debito, outro_lancamento_debito], [lancamento_credito, outro_lancamento_credito]]
    
    Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)
    
    ultimo_movimento = Movimento.last    
    ultimo_movimento.historico.should == "LANCAMENTO 09/04/2009"
    ultimo_movimento.numero_de_controle.should == "CONTROLE 2"
    ultimo_movimento.data_lancamento.should == "09/04/2009"
    ultimo_movimento.tipo_lancamento.should == "E"
    ultimo_movimento.tipo_documento.should == "CPMF"
    ultimo_movimento.provisao.should == 1
    ultimo_movimento.numero_da_parcela == 1
    ultimo_movimento.pessoa.should == pessoas(:paulo)
    ultimo_movimento.unidade.should == unidades(:senaivarzeagrande)

    movimento_debito = ultimo_movimento.itens_movimentos.first    
    movimento_debito.tipo.should == "D"
    movimento_debito.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    movimento_debito.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    movimento_debito.centro = centros(:centro_forum_social)
    movimento_debito.valor.should == 4000
    
    outro_movimento_debito = ultimo_movimento.itens_movimentos[1]    
    outro_movimento_debito.tipo.should == "D"
    outro_movimento_debito.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    outro_movimento_debito.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    outro_movimento_debito.centro = centros(:centro_forum_social)
    outro_movimento_debito.valor.should == 3000
    
    movimento_credito = ultimo_movimento.itens_movimentos[2]    
    movimento_credito.tipo.should == "C"
    movimento_credito.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_despesas)
    movimento_credito.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    movimento_credito.centro.should == centros(:centro_forum_social)
    movimento_credito.valor.should == 6000
    
    outro_movimento_credito = ultimo_movimento.itens_movimentos.last    
    outro_movimento_credito.tipo.should == "C"
    outro_movimento_credito.plano_de_conta.should == plano_de_contas(:plano_de_contas_ativo_despesas)
    outro_movimento_credito.unidade_organizacional.should == unidade_organizacionais(:sesi_colider_unidade_organizacional)
    outro_movimento_credito.centro.should == centros(:centro_forum_social)
    outro_movimento_credito.valor.should == 1000
  end

  it "testa função de classe lanca_contabilidade com um lancamentos de debito e um de credito com valores diferentes" do
    dados_do_lancamento = { :historico => "LANCAMENTO 09/04/2009", :numero_de_controle => "CONTROLE 2", 
      :data_lancamento => "2009-04-09".to_date, :tipo_lancamento => "E", :tipo_documento => "CPMF", :provisao => 1, :numero_da_parcela => 1, :pessoa => pessoas(:paulo)}
    lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 4000 }        
    lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional), 
      :centro => centros(:centro_forum_social), :valor => 7000 }    
    lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]
    
    lambda do
      Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id).should
    end.should raise_error(RuntimeError, "Débitos e Créditos não bateram")

  end

  it "testa função de classe lanca_contabilidade com um lancamentos de debito e um de credito com provisao nula" do
    lambda do
      dados_do_lancamento = { :historico => "LANCAMENTO 09/04/2009", :numero_de_controle => "CONTROLE 2",
        :data_lancamento => "2009-04-09".to_date, :tipo_lancamento => "E", :tipo_documento => "CPMF", :provisao => nil, :numero_da_parcela => nil, :pessoa => pessoas(:paulo)}
      lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional),
        :centro => centros(:centro_forum_social), :valor => 4000 }
      lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_despesas), :unidade_organizacional => unidade_organizacionais(:sesi_colider_unidade_organizacional),
        :centro => centros(:centro_forum_social), :valor => 4000 }
      lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]

      Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id).should
    end.should raise_error(RuntimeError, "Provisao é inválido., Conta deve ser preenchida")
  end

  it "testa se está adicionando os erros de itens movimento em movimento" do
    dados_do_lancamento = Movimento.new :historico => "LANCAMENTO 09/04/2009", :numero_de_controle => "CONTROLE 2",
      :data_lancamento => "2009-04-09".to_date, :tipo_lancamento => "E", :tipo_documento => "CPMF", :pessoa => pessoas(:paulo)
    lancamento_debito = { :plano_de_conta => nil, :unidade_organizacional => nil, :centro => nil, :valor => 5000 }
    lancamento_credito = { :plano_de_conta => nil, :unidade_organizacional => nil, :centro => nil, :valor => 5000 }
    lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]

    Movimento.lanca_contabilidade(2007, lancamento, unidades(:senaivarzeagrande).id).should_not == true
    erros = dados_do_lancamento.errors.instance_variable_get(:@errors)

    erros["base"].length.should == 3
    erros["base"].include?("Plano de Conta é inválido.").should == true
    erros["base"].include?("Unidade Organizacional é inválida.").should == true
    erros["base"].include?("Centro de Responsabilidade é inválido.").should == true

    erros.has_key?("itens_movimentos").should == false
  end

  it "testa a pesquisa de movimento" do
    Movimento.delete_all

    dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "Pagamento Cheque", :numero_de_controle => "SENAI-VG - DP4/20053200",
      :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 1, :numero_da_parcela => 3, :pessoa => pessoas(:felipe)}
    lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 10001 }
    lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 10001 }
    lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]    
    Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)

    dados_do_lancamento_outra_data = {:conta => pagamento_de_contas(:pagamento_dinheiro), :historico => "Pagamento Cheque", :numero_de_controle => "2005320011",
      :data_lancamento => "2009-04-01".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 0, :numero_da_parcela => 3, :pessoa => pessoas(:inovare)}
    outro_lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 12000 }
    outro_lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 12000 }
    outro_lancamento = [dados_do_lancamento_outra_data, [outro_lancamento_debito], [outro_lancamento_credito]]
    Movimento.lanca_contabilidade(2009, outro_lancamento, unidades(:senaivarzeagrande).id)

    [
      #      # 0
      [{"data_inicial"=>"31/03/2009", "data_final"=>"31/03/2009", "ordem"=>"SENAI-VG - DP4/20053200", "tipo"=>"1"}, {1 => [Movimento.first]}],
      #      # 1
      [{"data_inicial"=>"01/04/2009", "data_final"=>"01/04/2009", "ordem"=>"SENAI-VG - DP4/20053200", "tipo"=>"1"}, {}],
      #      # 2
      [{"data_inicial"=>"31/03/2009", "data_final"=>"01/04/2009", "ordem"=>"2005320011", "tipo"=>"0"}, {0 => [Movimento.last]}],
      #      # 3
      [{"data_inicial"=>"31/03/2009", "data_final"=>"31/03/2009", "ordem"=>"2005320011", "tipo"=>"0"}, {}],
      #      # 4
      [{"data_inicial"=>"", "data_final"=>"", "ordem"=>"", "tipo"=>""}, {}],
      #      # 5
      [{"data_inicial"=>"31/03/2009", "data_final"=>"31/03/2009", "ordem"=>"SENAI-VG - DP4/20053200", "tipo"=>"2"}, {1 => [Movimento.first]}],
      #      # 6
      [{"data_inicial"=>"01/04/2009", "data_final"=>"01/04/2009", "ordem"=>"2005320011", "tipo"=>"2"}, {0 => [Movimento.last]}],
      #      # 7
      [{"data_inicial"=>"31/03/2009", "data_final"=>"01/04/2009",  "tipo"=>"1"}, {"SENAI-VG - DP4/20053200" => [Movimento.first], "2005320011" => [Movimento.last]  }],
      #      # 8
      [{"data_inicial"=>"", "data_final"=>"", "ordem"=>"SENAI-VG - DP4/20053200", "tipo"=>"1"}, {1 => [Movimento.first]}],
      #      # 9
      [{"data_inicial"=>"", "data_final"=>"", "ordem"=>"2005320011", "tipo"=>"0"}, {0 => [Movimento.last]}],
      #      # 10
      [{"data_inicial"=>"", "data_final"=>"", "ordem"=>"2005320011", "tipo"=>"2"}, {0 => [Movimento.last]}],
      #      # 11
      [{"numero_controle"=>"", "nome_fornecedor"=>"", "valor"=>"", "data_lancamento"=>""}, {"SENAI-VG - DP4/20053200" => [Movimento.first], "2005320011" => [Movimento.last]}],
      #      # 12
      [{"numero_controle"=>"SENAI-VG - DP4/20053200", "nome_fornecedor"=>"", "valor"=>"", "data_lancamento"=>""}, {"SENAI-VG - DP4/20053200" => [Movimento.first]}],
      #      # 13
      [{"numero_controle"=>"", "nome_fornecedor"=>"i", "valor"=>"", "data_lancamento"=>""}, {"SENAI-VG - DP4/20053200" => [Movimento.first], "2005320011" => [Movimento.last]}],
      #      # 14
      [{"numero_controle"=>"", "nome_fornecedor"=>"fel", "valor"=>"100.01", "data_lancamento"=>""}, {"SENAI-VG - DP4/20053200" => [Movimento.first]}],
      #      # 15
      [{"numero_controle"=>"", "nome_fornecedor"=>"", "valor"=>"100.01", "data_lancamento"=>""}, {"SENAI-VG - DP4/20053200" => [Movimento.first]}],
      #      # 16
      [{"numero_controle"=>"", "nome_fornecedor"=>"", "valor"=>"", "data_lancamento"=>"31/03/2009"}, {"SENAI-VG - DP4/20053200" => [Movimento.first]}],
      #      #17
      [{"data_inicial"=>"01/04/2009", "data_final"=>"", "ordem"=>"2005320011", "tipo"=>"0"}, {0 => [Movimento.last]}],
      #      #18
      [{"data_inicial"=>"", "data_final"=>"01/04/2009", "ordem"=>"2005320011", "tipo"=>"0"}, {0 => [Movimento.last]}],
      #      #19
      [{"numero_controle"=>"", "nome_fornecedor"=>"ino", "valor"=>"", "data_lancamento"=>""}, {"2005320011" => [Movimento.last]}],
      #      #20
      [{"numero_controle"=>"", "nome_fornecedor"=>"ftg", "valor"=>"", "data_lancamento"=>""}, {"2005320011" => [Movimento.last]}],
    ].each_with_index do |dados_consulta, index|
      #      puts index
      Movimento.procurar_movimentos(dados_consulta.first, unidades(:senaivarzeagrande).id).should == dados_consulta.last
    end

    [
      [{"data_inicial"=>"31/03/2009", "data_final"=>"31/03/2009", "ordem"=>"SENAI-VG - DP4/20053200", "tipo"=>"1"}, {}],
      [{"numero_controle"=>"", "nome_fornecedor"=>"", "valor"=>"", "data_lancamento"=>""}, {}]
    ].each_with_index do |dados_consulta, index|
      Movimento.procurar_movimentos(dados_consulta.first, unidades(:sesivarzeagrande).id).should == dados_consulta.last
    end

    # Testa pesquisa passando contabilizacao_ordem true

    [
      [{"data_inicial"=>"01/04/2009", "data_final"=>"", "ordem"=>"2005320011", "tipo"=>"0"}, [Movimento.last]],
      [{"data_inicial"=>"", "data_final"=>"01/04/2009", "ordem"=>"2005320011", "tipo"=>"0"}, [Movimento.last]]
    ].each do |dados_consulta|
      Movimento.procurar_movimentos(dados_consulta.first, unidades(:senaivarzeagrande).id, true).should == dados_consulta.last
    end

  end

  it "passando data inicial na pesquisa" do
    Movimento.should_receive(:all).with(:conditions => ["movimentos.unidade_id = ? AND movimentos.numero_de_controle = ? AND movimentos.provisao = ? AND movimentos.data_lancamento = ?", unidades(:senaivarzeagrande).id, "2005320011", 1, "2009-04-01".to_date ], :order => 'movimentos.data_lancamento,movimentos.numero_de_controle,movimentos.numero_da_parcela', :include => :pessoa).and_return({})
    @actual = Movimento.procurar_movimentos({"data_inicial"=>"01/04/2009", "data_final"=>"", "ordem"=>"2005320011", "tipo"=>"1"}, unidades(:senaivarzeagrande).id)
  end

  it "passando data final na pesquisa" do
    Movimento.should_receive(:all).with(:conditions => ["movimentos.unidade_id = ? AND movimentos.numero_de_controle = ? AND movimentos.provisao = ? AND movimentos.data_lancamento = ?", unidades(:senaivarzeagrande).id, "2005320011", 1, "2009-05-01".to_date], :order => 'movimentos.data_lancamento,movimentos.numero_de_controle,movimentos.numero_da_parcela', :include => :pessoa).and_return({})
    @actual = Movimento.procurar_movimentos({"data_inicial"=>"", "data_final"=>"01/05/2009", "ordem"=>"2005320011", "tipo"=>"1"}, unidades(:senaivarzeagrande).id)
  end

  it "passando data inicial e final na pesquisa" do
    Movimento.should_receive(:all).with(:conditions => ["movimentos.unidade_id = ? AND movimentos.numero_de_controle = ? AND movimentos.provisao = ? AND (movimentos.data_lancamento BETWEEN ? AND ?)", unidades(:senaivarzeagrande).id, "2005320011", 1, "2009-04-01".to_date, "2009-05-01".to_date], :order => 'movimentos.data_lancamento,movimentos.numero_de_controle,movimentos.numero_da_parcela', :include => :pessoa).and_return({})
    @actual = Movimento.procurar_movimentos({"data_inicial"=>"01/04/2009", "data_final"=>"01/05/2009", "ordem"=>"2005320011", "tipo"=>"1"}, unidades(:senaivarzeagrande).id)
  end
 
  it "se o lancamento não for simple deve existir uma conta" do
    @movimento = movimentos(:lancamento_com_a_conta_pagamento_cheque)
    @movimento.should be_valid
    @movimento.conta = nil
    @movimento.should_not be_valid
    @movimento.errors.on(:conta).should_not be_nil
  end

  it "testa funcao que limpa hash com dados vazios" do
    movimento = Movimento.new
    movimento.lancamento_simples = {"centro_nome" => "", "centro_id" => "1",
      "conta_corrente_nome" => "", "conta_corrente_id" => "228217796",
      "unidade_organizacional_nome" => "134234239039 - Sesi Matriz", "unidade_organizacional_id" => "677077046",
      "conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI", "conta_contabil_id"=>"937187129"}

    movimento.limpa_dados_vazios.should == {"centro_nome" => "", "centro_id" => "",
      "conta_corrente_nome" => "", "conta_corrente_id" => "",
      "unidade_organizacional_nome" => "134234239039 - Sesi Matriz", "unidade_organizacional_id" => "677077046",
      "conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI", "conta_contabil_id"=>"937187129"}
  end

  it "testa before validation" do
    movimento = Movimento.new :historico => "LANCAMENTO PROVISAO 31/03/2009", :numero_de_controle => "CONTROLE 1",
      :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "CPMF", :provisao => 3, :numero_da_parcela => nil, :nome_pessoa => '', :pessoa_id => pessoas(:paulo).id

    movimento.should_not be_valid
    movimento.pessoa_id.should == nil
  end

  it "testa criacao do numero de controle" do
    movimento = Movimento.new :historico => "LANCAMENTO PROVISAO 31/03/2009", :unidade => unidades(:senaivarzeagrande),
      :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "CPMF", :provisao => 3, :numero_da_parcela => nil, :nome_pessoa => 'Paulo', :pessoa => pessoas(:paulo)
    movimento.save
    movimento.numero_de_controle.should == "SENAI-VG-CPMF#{DateTime.now.strftime("%m/%y")}0001"

    segundo_movimento = Movimento.new :historico => "LANCAMENTO PROVISAO 31/03/2009",
      :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "CPMF", :provisao => 3, :numero_da_parcela => nil, :nome_pessoa => 'Paulo', :pessoa => pessoas(:paulo), :unidade => unidades(:senaivarzeagrande)

    segundo_movimento.save
    segundo_movimento.numero_de_controle.should == "SENAI-VG-CPMF#{DateTime.now.strftime("%m/%y")}0002"
  end
  
  it "testa se valida a data de lancamento" do
    unidades(:senaivarzeagrande).lancamentosmovimentofinanceiro = 5
    unidades(:senaivarzeagrande).save
    movimentos(:primeiro_lancamento_entrada).reload
    movimento = movimentos(:primeiro_lancamento_entrada)
    movimento.data_de_lancamento_valida?.should == false
    unidades(:senaivarzeagrande).lancamentosmovimentofinanceiro = 5000
    unidades(:senaivarzeagrande).save
    movimentos(:primeiro_lancamento_entrada).reload
    movimento = movimentos(:primeiro_lancamento_entrada)
    movimento.data_de_lancamento_valida?.should == true
  end

  it "testa se valida quando tenta extrapolar a data de lancamento em um update" do
    unidades(:senaivarzeagrande).lancamentosmovimentofinanceiro = 5
    unidades(:senaivarzeagrande).save

    movimento = movimentos(:primeiro_lancamento_entrada)
    movimento.data_lancamento = "03/03/2009"
    movimento.save.should == false
    movimento.errors.full_messages.collect.should == ["O campo data de lançamento excedeu o limite máximo permitido"]
  end

  it "verifica PROVISAO_VERBOSE" do
    m = Movimento.new :provisao => 0
    m.provisao_verbose.should == "Pago/Baixado"
    m.provisao = 1
    m.provisao_verbose.should == "Provisão"
    m.provisao = 3
    m.provisao_verbose.should == "Simples"
  end

  it "verifica Movimento.descreve_tipo_do_lancamento" do
    Movimento.descreve_tipo_do_lancamento(Movimento::BAIXA).should == "Baixados"
    Movimento.descreve_tipo_do_lancamento(Movimento::PROVISAO).should == "Provisionados"
    Movimento.descreve_tipo_do_lancamento(Movimento::SIMPLES).should == "Simples"
  end

  it "faz update de movimento" do
    movimento = movimentos(:primeiro_lancamento_entrada)
    movimento.pessoa.should == pessoas(:paulo)
    movimento.valor_total.should == 1000
    movimento.data_lancamento.should == "01/03/2009"

    # Preparando a alteração
    parametros = {"nome_pessoa" => "Juan Vitor Zeferino", "data_lancamento" => "21/08/2009", "historico" => "Primeiro lançamento de entrada mudado",
      "tipo_lancamento" => "E", "pessoa_id" => pessoas(:juan).id, "valor_do_documento_em_reais" => "100,00", "tipo_documento" => "CTREV",
      "lancamento_simples" => {"centro_nome"=> "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
        "conta_corrente_nome" => "34445-1 - Conta Caixa - SENAI-VG", "centro_id" => centros(:centro_forum_economico).id, "conta_contabil_nome" => "2101123456 - Impostos a Pagar",
        "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id, "conta_corrente_id" => contas_correntes(:conta_vazia).id,
        "conta_contabil_id" => plano_de_contas(:plano_de_contas_passivo_a_pagar).id}}
    movimento.faz_update_de_movimento(2009, parametros, unidades(:senaivarzeagrande).id).should == true
    movimento.reload

    movimento.pessoa.should == pessoas(:juan)
    movimento.valor_total.should == 10000
    movimento.data_lancamento.should == "21/08/2009"

    movimento_debito = movimento.itens_movimentos.first
    movimento_debito.tipo.should == "D"
    movimento_debito.unidade_organizacional.should == unidade_organizacionais(:unidade_organizacional_empresa)
    movimento_debito.centro.should == centros(:centro_empresa)
    # Conta corrente igual a contas_correntes(:conta_vazia), então plano de contas dessa conta é plano_de_contas(:plano_de_contas_passivo_a_pagar)
    movimento_debito.plano_de_conta.should == plano_de_contas(:plano_de_contas_passivo_a_pagar)
    movimento_debito.valor.should == 10000

    movimento_credito = movimento.itens_movimentos.last
    movimento_credito.tipo.should == "C"
    movimento_credito.unidade_organizacional.should == unidade_organizacionais(:unidade_organizacional_empresa)
    movimento_credito.centro.should == centros(:centro_empresa)
    movimento_credito.plano_de_conta.should == plano_de_contas(:plano_de_contas_passivo_a_pagar)
    movimento_credito.valor.should == 10000
  end

  it "não faz update de movimento: erro em movimento" do
    movimento = movimentos(:primeiro_lancamento_entrada)

    # Preparando a alteração
    parametros = {"nome_pessoa" => "", "data_lancamento" => "21/08/2009", "historico" => "Primeiro lançamento de entrada mudado",
      "tipo_lancamento" => "E", "pessoa_id" => "", "valor_do_documento_em_reais" => "100.00", "tipo_documento" => "CTREV",
      "lancamento_simples" => {"centro_nome"=> "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
        "conta_corrente_nome" => "34445-1 - Conta Caixa - SENAI-VG", "centro_id" => centros(:centro_forum_economico).id, "conta_contabil_nome" => "2101123456 - Impostos a Pagar",
        "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id, "conta_corrente_id" => contas_correntes(:conta_vazia).id,
        "conta_contabil_id" => plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}}
    movimento.faz_update_de_movimento(2009, parametros, unidades(:senaivarzeagrande).id).should == false
    movimento.reload
    
    movimento.itens_movimentos.should == [itens_movimentos(:credito_primeiro_movimento), itens_movimentos(:debito_primeiro_movimento)]
  end

  it "faz update de movimento: erro em itens do movimento" do
    movimento = movimentos(:primeiro_lancamento_entrada)
    movimento.pessoa.should == pessoas(:paulo)
    movimento.valor_total.should == 1000
    movimento.data_lancamento.should == "01/03/2009"

    # Preparando a alteração
    parametros = {"nome_pessoa" => "Juan Vitor Zeferino", "data_lancamento" => "21/08/2009", "historico" => "Primeiro lançamento de entrada mudado",
      "tipo_lancamento" => "E", "pessoa_id" => pessoas(:juan).id, "valor_do_documento_em_reais" => "100.00", "tipo_documento" => "CTREV",
      "lancamento_simples" => {"centro_nome"=> "", "unidade_organizacional_nome" => "134234239039 - Senai Matriz",
        "conta_corrente_nome" => "34445-1 - Conta Caixa - SENAI-VG", "centro_id" => "", "conta_contabil_nome" => "2101123456 - Impostos a Pagar",
        "unidade_organizacional_id" => unidade_organizacionais(:senai_unidade_organizacional).id, "conta_corrente_id" => contas_correntes(:conta_vazia).id,
        "conta_contabil_id" => plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}}
    movimento.faz_update_de_movimento(2009, parametros, unidades(:senaivarzeagrande).id).should == false
    movimento.reload
    
    movimento.itens_movimentos.should == [itens_movimentos(:credito_primeiro_movimento), itens_movimentos(:debito_primeiro_movimento)]
  end

  it "não pode deixar destruir movimentos que excederam o tempo" do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save
    
    movimento = movimentos(:primeiro_lancamento_entrada)
    assert_no_difference 'Movimento.count', 1 do
      movimento.destroy
    end
  end

  it "pode deixar excluir movimento" do
    assert_difference 'Movimento.count', -1 do
      movimentos(:segundo_lancamento_saida).destroy
    end
  end

  it "não deve vincular a centro e unidade especial pois começa com 41" do
    lancamento_normal = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_normal).should == lancamento_normal
  end

  it "deve vincular a centro e unidade especial: código contabil começa com 21" do
    lancamento_especial = { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => unidade_organizacionais(:unidade_organizacional_empresa),
      :centro => centros(:centro_empresa), :valor => 4000 }
  end

  it "deve vincular a centro e unidade especial: código contabil começa com 21 e foi passado centro_id, unidade_organizacional_id e plano_de_conta_id" do
    lancamento_especial = { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => unidade_organizacionais(:unidade_organizacional_empresa),
      :centro => centros(:centro_empresa), :valor => 4000 }
  end

  it "não deve vincular a centro e unidade especial: código contábil começa com 11 e não achou o ano" do
    plano_de_conta = plano_de_contas(:plano_de_contas_ativo_caixa)
    plano_de_conta.ano = 1989
    plano_de_conta.save.should == true

    lancamento_especial = { :plano_de_conta => plano_de_conta, :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    #    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => plano_de_conta, :unidade_organizacional => nil,
    #      :centro => nil, :valor => 4000 }
    
    lambda do
      Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial)
    end.should raise_error(RuntimeError, "Não existe um Centro de Responsabilidade Empresa válido.")
  end

  it "não deve vincular a centro e unidade especial: código contábil começa com 11 e não achou o entidade" do
    plano_de_conta = plano_de_contas(:plano_de_contas_ativo_caixa)
    plano_de_conta.entidade = entidades(:sesi)
    plano_de_conta.save.should == true

    lancamento_especial = { :plano_de_conta => plano_de_conta, :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    #    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => plano_de_conta, :unidade_organizacional => nil,
    #            :centro => nil, :valor => 4000 }

    lambda do
      Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial)
    end.should raise_error(RuntimeError, "Não existe um Centro de Responsabilidade Empresa válido.")
  end

  it "não deve vincular a centro e unidade especial: pois passou plano_de_conta nil" do
    lancamento_especial = { :plano_de_conta => nil, :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => nil, :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => centros(:centro_forum_economico), :valor => 4000 }
  end

  it "não deve vincular a centro e unidade especial: centro veio nulo" do
    lancamento_especial = { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => nil, :valor => 4000 }

    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
      :centro => nil, :valor => 4000 }
  end

  it "não deve vincular a centro e unidade especial: unidade veio nulo" do
    lancamento_especial = { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => nil,
      :centro => centros(:centro_forum_economico), :valor => 4000 }

    Movimento.vincula_novo_centro_e_unidade_organizacional(lancamento_especial).should == { :plano_de_conta => plano_de_contas(:plano_de_contas_passivo_a_pagar), :unidade_organizacional => nil,
      :centro => centros(:centro_forum_economico), :valor => 4000 }
  end

  describe "não pode deixar salvar quando os parâmetros de lançamento estão incorretos:" do

    it "testa se não salva movimento se passar plano_de_conta_id ao invés de plano_de_conta" do
      lambda do
        dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "Pagamento Cheque", :numero_de_controle => "SENAI-VG - DP4/20053200",
          :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 1, :numero_da_parcela => 3, :pessoa => pessoas(:felipe)}
        lancamento_debito = { :plano_de_conta_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 10001 }
        lancamento_credito = { :plano_de_conta_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 10001 }
        lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]
        Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)
      end.should raise_error(RuntimeError, "Débito com propriedades inválidas.
Crédito com propriedades inválidas.")
    end

    it "testa se não salva movimento se passar centro_id ao invés de centro" do
      lambda do
        dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "Pagamento Cheque", :numero_de_controle => "SENAI-VG - DP4/20053200",
          :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 1, :numero_da_parcela => 3, :pessoa => pessoas(:felipe)}
        lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
          :centro_id => centros(:centro_forum_economico), :valor => 10001 }
        lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
          :centro_id => centros(:centro_forum_economico), :valor => 10001 }
        lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]
        Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)
      end.should raise_error(RuntimeError, "Débito com propriedades inválidas.
Crédito com propriedades inválidas.")
    end

    it "testa se não salva movimento se passar unidade_organizacional_id ao invés de unidade_organizacional" do
      lambda do
        dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "Pagamento Cheque", :numero_de_controle => "SENAI-VG - DP4/20053200",
          :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 1, :numero_da_parcela => 3, :pessoa => pessoas(:felipe)}
        lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 10001 }
        lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 10001 }
        lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]
        Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)
      end.should raise_error(RuntimeError, "Débito com propriedades inválidas.
Crédito com propriedades inválidas.")
    end

    it "testa se não salva movimento se passar unidade_organizacional_id ao invés de unidade_organizacional porem so no crédito" do
      dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "Pagamento Cheque", :numero_de_controle => "SENAI-VG - DP4/20053200",
        :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 1, :numero_da_parcela => 3, :pessoa => pessoas(:felipe)}
      lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :valor => 10001 }
      lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :valor => 10001 }
      lancamento = [dados_do_lancamento, [lancamento_debito], [lancamento_credito]]
      lambda do
        Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id)
      end.should raise_error(RuntimeError, "Crédito com propriedades inválidas.")
    end

    it "onde existam 4 lancamentos de 1000 cada um, porém 1 débito e 1 crédito são inválidos pois foi passado unidade_organizacional_id. Nessa situação o movimento deve ser abortado" do
      lambda do
        dados_do_lancamento = {:conta => pagamento_de_contas(:pagamento_cheque), :historico => "Pagamento Cheque", :numero_de_controle => "SENAI-VG - DP4/20053200",
          :data_lancamento => "2009-03-31".to_date, :tipo_lancamento => "S", :tipo_documento => "DP", :provisao => 1, :numero_da_parcela => 3, :pessoa => pessoas(:felipe)}
        lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 1000 }
        segundo_lancamento_debito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 1000 }
        lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 1000 }
        segundo_lancamento_credito = { :plano_de_conta => plano_de_contas(:plano_de_contas_ativo_contribuicoes), :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
          :centro => centros(:centro_forum_economico), :valor => 1000 }
        lancamento = [dados_do_lancamento, [lancamento_debito, segundo_lancamento_debito], [lancamento_credito, segundo_lancamento_credito]]
      
        assert_no_difference 'Movimento.count' do
          assert_no_difference 'ItensMovimento.count' do
            Movimento.lanca_contabilidade(2009, lancamento, unidades(:senaivarzeagrande).id).should == "É preciso cadastrar um conta contábil crédito do imposto."
          end
        end
      end.should raise_error(RuntimeError, "Débito com propriedades inválidas.
Crédito com propriedades inválidas.")
    end

  end

  it 'testa liberação pelo DR do recebimento de conta' do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 1
    unidade.lancamentoscontasreceber = 1
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save

    r = movimentos(:primeiro_lancamento_entrada)
    r.data_de_lancamento_valida?.should == false
    r.valid?.should == false

    r.liberacao_dr_faixa_de_dias_permitido = true
    r.save.should == true
    r.reload

    r.liberacao_dr_faixa_de_dias_permitido.should == false
  end

end
