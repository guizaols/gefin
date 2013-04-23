require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecebimentoDeConta do

  before(:each) do
    @quentin = usuarios(:quentin)
    @valid_attributes = {
      :tipo_de_documento => "CPMF",
      :numero_nota_fiscal => "999888777",
      :pessoa_id => pessoas(:paulo).id,
      :dependente_id => dependentes(:dependente_paulo_primeiro).id,
      :servico_id => servicos(:curso_de_tecnologia).id,
      :data_inicio => Time.now,
      :data_final => Time.now,
      :dia_do_vencimento => 1,
      :valor_do_documento_em_reais => '10,00',
      :numero_de_parcelas => 1,
      :vigencia=>1,
      :rateio => 1,
      :historico => "value for historico",
      :conta_contabil_receita_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id,
      :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional).id,
      :centro_id => centros(:centro_forum_social).id,
      :data_venda => Time.now,
      :origem => 1,
      :vendedor_id => 1,
      :cobrador_id => 1,
      :parcelas_geradas => false,
      :situacao => 1,
      :numero_de_renegociacoes => 0,
      :usuario_corrente => usuarios(:quentin)
    }
  end

  it "should create a new instance given valid attributes" do
    RecebimentoDeConta.delete_all
    r = RecebimentoDeConta.new @valid_attributes
    r.unidade = unidades(:senaivarzeagrande)
    r.centro = centros(:centro_forum_economico)
    r.ano = 2009
    r.data_inicio_servico = "01/06/2009"
    r.data_final_servico = "01/09/2009"
    r.save!
  end
  
  it 'deve validar campo tipo_de_documento' do
    r = RecebimentoDeConta.new :tipo_de_documento => nil
    r.valid?
    assert r.errors.invalid?(:tipo_de_documento)
    r.tipo_de_documento = 'ABC'
    r.valid?
    assert r.errors.invalid?(:tipo_de_documento)
    r.tipo_de_documento = 'CTRSE'
    r.valid?
    assert !r.errors.invalid?(:tipo_de_documento)
  end

  it 'deve validar inclusion de situacao_fiemt' do
    r = RecebimentoDeConta.new @valid_attributes
    r.valid?
    assert !r.errors.invalid?(:situacao_fiemt)
    r.situacao_fiemt = nil
    r.valid?
    assert r.errors.invalid?(:situacao_fiemt)
  end

  it 'deve validar situacao_fiemt verbose' do
    r = RecebimentoDeConta.new @valid_attributes
    r.situacao_fiemt_verbose.should == "Normal"
    r.situacao_fiemt = RecebimentoDeConta::Renegociado
    r.situacao_fiemt_verbose.should == "Renegociado"
    r.situacao_fiemt = RecebimentoDeConta::Juridico
    r.situacao_fiemt_verbose.should == "Jurídico"
    r.situacao_fiemt = RecebimentoDeConta::Permuta
    r.situacao_fiemt_verbose.should == "Permuta"
    r.situacao_fiemt = RecebimentoDeConta::Baixa_do_conselho
    r.situacao_fiemt_verbose.should == "Baixa do Conselho"
    r.situacao_fiemt = RecebimentoDeConta::Inativo
    r.situacao_fiemt_verbose.should == "Inativo"
  end

  it 'testa a funcao situacoes' do
    r = RecebimentoDeConta.new @valid_attributes
    r.situacoes.should == "Normal"
    r.situacao_fiemt = RecebimentoDeConta::Juridico
    r.situacoes.should == "Normal / Jurídico"
  end

  it "quando criar objeto inserindo parcela deve ser false" do
    c = RecebimentoDeConta.new
    c.inserindo_nova_parcela.should == false
  end
  
  it 'deve validar cliente e dependente' do
    #Deve exigir cliente
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:pessoa)
    #Deve aceitar cliente válido
    r = RecebimentoDeConta.new :pessoa_id => pessoas(:paulo).id
    r.valid?
    assert !r.errors.invalid?(:pessoa)
    #Deve aceitar sem dependente
    assert !r.errors.invalid?(:dependente)
    #Deve aceitar dependente válido
    r.dependente = dependentes(:dependente_paulo_primeiro)
    r.valid?
    assert !r.errors.invalid?(:dependente)
    #Não deve aceitar dependente de outro cliente
    r.pessoa = pessoas(:felipe)
    r.valid?
    assert r.errors.invalid?(:dependente)
  end
  
  it 'deve validar e proteger unidade' do
    r = RecebimentoDeConta.new :unidade_id => unidades(:senaivarzeagrande).id
    r.valid?
    assert r.errors.invalid?(:unidade)
    assert_equal nil, r.unidade
    r.unidade = unidades(:senaivarzeagrande)
    r.valid?
    assert !r.errors.invalid?(:unidade)
  
  end
    
  it 'deve validar e proteger situacao' do
    r = RecebimentoDeConta.new :situacao=>"teste"
    r.situacao.should == 1
    r.situacao = 8
    r.valid?
    r.errors.on(:situacao).should_not be_nil
  end
    
  
  it 'deve validar campo servico' do
    r = RecebimentoDeConta.new :servico_id => nil
    r.valid?
    assert r.errors.invalid?(:servico)
    r = RecebimentoDeConta.new :servico_id => servicos(:curso_de_tecnologia).id, :unidade => unidades(:senaivarzeagrande)
    r.valid?
    assert !r.errors.invalid?(:servico)
    #Não deve aceitar serviço de outra unidade
    r = RecebimentoDeConta.new :servico_id => servicos(:curso_de_tecnologia).id, :unidade => unidades(:sesivarzeagrande)
    r.valid?
    assert r.errors.invalid?(:servico)
  end
  
  it 'deve validar :numero_de_parcelas' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:numero_de_parcelas)
    r = RecebimentoDeConta.new :numero_de_parcelas => 0
    r.valid?
    assert r.errors.invalid?(:numero_de_parcelas)
    r = RecebimentoDeConta.new :numero_de_parcelas => -1
    r.valid?
    assert r.errors.invalid?(:numero_de_parcelas)
    r = RecebimentoDeConta.new :numero_de_parcelas => 1
    r.valid?
    assert !r.errors.invalid?(:numero_de_parcelas)
  end
  
  it 'deve validar :vigencia' do
    r = RecebimentoDeConta.new
    r.valid?
    r.errors.on(:vigencia).should_not be_nil
    r.vigencia= -1
    r.errors.on(:vigencia).should_not be_nil
  end

  it 'deve validar :situacao quando com cancelado_pela_situacao_fiemt_was = true' do
    r = recebimento_de_contas(:curso_de_design_do_paulo)
    r.cancelado_pela_situacao_fiemt = true
    r.situacao = RecebimentoDeConta::Cancelado
    r.save false
    r.situacao = RecebimentoDeConta::Normal
    r.save
    r.should be_valid
    r.errors.on(:situacao).should == nil
  end

  it "carrega dados_da_parcela" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.dados_parcela.should == {parcelas(:primeira_parcela_recebimento).id.to_s => {"numero" => 1.to_s, "data_vencimento" => "05/07/2009", "situacao_verbose" => "Em atraso", "valor" => 3000, "situacao" => 1},
      parcelas(:segunda_parcela_recebimento).id.to_s => {"numero" => 2.to_s, "data_vencimento" => "05/08/2009", "situacao_verbose" => "Em atraso", "valor" => 3000, "situacao" => 1}}

    conta_a_receber_sem_parcela_gerada = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    conta_a_receber_sem_parcela_gerada.dados_parcela.should == {}
  end
    
  it 'deve validar data_de_inicio' do
    recebimento_de_contas(:curso_de_tecnologia_do_paulo).data_inicio.should == '24/09/2009'
    r = RecebimentoDeConta.new
    r.data_inicio.should == Date.today.to_s_br
    r.data_venda.should == Date.today.to_s_br
      
    r.data_inicio = ''
    r.data_venda = ''
    r.valid?
    r.errors.should be_invalid(:data_inicio)
    r.errors.should be_invalid(:data_venda)
  
    r = RecebimentoDeConta.new :data_inicio => Date.yesterday.to_s_br, :data_venda => Date.yesterday.to_s_br
    r.data_inicio.should == Date.yesterday.to_s_br
    r.data_venda.should == Date.yesterday.to_s_br
    r.valid?
    r.errors.should_not be_invalid(:data_inicio)
    r.errors.should_not be_invalid(:data_venda)
  end
  
  it 'deve proteger e calcular data_final' do
    r = RecebimentoDeConta.new :data_inicio => '01/01/2009', :vigencia => '10', :data_final => '01/01/2009'
    r.data_final.should == nil
    r.valid?
    r.data_final.should == '01/11/2009'
  
  
    r.data_inicio = ''
    r.valid?
    assert r.errors.invalid?(:data_inicio)
  
    r = RecebimentoDeConta.new :data_inicio => Date.yesterday.to_s_br
    r.data_inicio.should == Date.yesterday.to_s_br
    r.valid?
    assert !r.errors.invalid?(:data_inicio)
  
    #Com campos incorretos
    r = RecebimentoDeConta.new :data_inicio => '01/01/2009', :vigencia => 'AAA'
    r.valid?
    r.data_final.should == nil
  
    #Se não existir a data final (ex: 31/02), agendar para antes
    r = RecebimentoDeConta.new :data_inicio => '31/01/2009', :vigencia => '1'
    r.valid?
    r.data_final.should == '28/02/2009'
  end
  
  it 'deve validar vencimento' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:dia_do_vencimento)
      
    r = RecebimentoDeConta.new :dia_do_vencimento => 0
    r.valid?
    assert r.errors.invalid?(:dia_do_vencimento)
  
    r = RecebimentoDeConta.new :dia_do_vencimento => 1
    r.valid?
    assert !r.errors.invalid?(:dia_do_vencimento)
  
    r = RecebimentoDeConta.new :dia_do_vencimento => 31
    r.valid?
    assert !r.errors.invalid?(:dia_do_vencimento)
  
    r = RecebimentoDeConta.new :dia_do_vencimento => 32
    r.valid?
    assert r.errors.invalid?(:dia_do_vencimento)
  
    r = RecebimentoDeConta.new :dia_do_vencimento => -1
    r.valid?
    assert r.errors.invalid?(:dia_do_vencimento)
  end
  
  it 'deve validar valor_do_documento' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:valor_do_documento)
  
    r = RecebimentoDeConta.new :valor_do_documento_em_reais => '0,00'
    r.valid?
    assert r.errors.invalid?(:valor_do_documento)
  
    r = RecebimentoDeConta.new :valor_do_documento_em_reais => '-1,00'
    r.valid?
    assert r.errors.invalid?(:valor_do_documento)
  
    r = RecebimentoDeConta.new :valor_do_documento_em_reais => '1,00'
    r.valid?
    assert !r.errors.invalid?(:valor_do_documento)
  
    r = RecebimentoDeConta.new :valor_do_documento_em_reais => '1000,00'
    r.valid?
    assert !r.errors.invalid?(:valor_do_documento)
  
    recebimento_de_contas(:curso_de_tecnologia_do_paulo).valor_do_documento_em_reais.should == "10,00"
  end
  
  it 'deve validar rateio' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:rateio)
  
    r = RecebimentoDeConta.new :rateio => RecebimentoDeConta::Nao
    r.valid?
    assert !r.errors.invalid?(:rateio)
  
    r = RecebimentoDeConta.new :rateio => RecebimentoDeConta::Sim
    r.valid?
    assert !r.errors.invalid?(:rateio)
  
    r = RecebimentoDeConta.new :rateio => 2
    r.valid?
    assert r.errors.invalid?(:rateio)
  end
  
  it 'deve exigir historico' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:historico)
  
    r = RecebimentoDeConta.new :historico => 'Conta a Receber do João'
    r.valid?
    assert !r.errors.invalid?(:historico)
  end
  
  it 'deve validar conta_contabil_receita' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:conta_contabil_receita)
  
    r = RecebimentoDeConta.new :conta_contabil_receita_id => plano_de_contas(:plano_de_contas_ativo_contribuicoes).id
    r.valid?
    assert !r.errors.invalid?(:conta_contabil_receita)
  
    #Não deve aceitar conta sintética
    r = RecebimentoDeConta.new :conta_contabil_receita_id => plano_de_contas(:plano_de_contas_ativo).id
    r.valid?
    assert r.errors.invalid?(:conta_contabil_receita)
  end
  
  it 'deve exigir unidade organizacional' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:unidade_organizacional)
  
    r = RecebimentoDeConta.new :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional).id
    r.valid?
    assert !r.errors.invalid?(:unidade_organizacional)
  end
  
  it 'deve exigir centro' do
    r = RecebimentoDeConta.new
    r.valid?
    assert r.errors.invalid?(:centro)
  
    r = RecebimentoDeConta.new :unidade_organizacional_id => unidade_organizacionais(:senai_unidade_organizacional).id, :centro_id => centros(:centro_forum_economico).id
    r.valid?
    assert !r.errors.invalid?(:centro)
  end
  
  it 'deve exigir data_venda' do
    r = RecebimentoDeConta.new :data_venda => ''
    r.valid?
    assert r.errors.invalid?(:data_venda)
  
    r = RecebimentoDeConta.new :data_venda => '31/12/2008'
    r.data_venda.should == '31/12/2008'
    r.valid?
    assert !r.errors.invalid?(:data_venda)
  end

  uses_transaction "testa o método inserir_nova_parcela"
  it "testa o método inserir_nova_parcela" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.usuario_corrente = usuarios(:quentin)
    conta_a_receber.numero_de_parcelas.should == 2
    conta_a_receber.rateio = 1
    parcela = {"inserindo_nova_parcela"=>true,"valor" => "100,00", "data_vencimento" => "19/06/2009"}
    assert_difference 'Parcela.count',1 do
      assert_difference 'Rateio.count',1 do
        conta_a_receber.inserir_nova_parcela(parcela).should == [true, "Parcela gerada com sucesso."]
        conta_a_receber.inserindo_nova_parcela.should == true
      end
    end
    rateio = Rateio.last
    rateio.conta_contabil.should == conta_a_receber.conta_contabil_receita
    rateio.valor.should == 10000
    conta_a_receber.reload
    conta_a_receber.valor_do_documento.should == 16000
    parcela = Parcela.last
    parcela.valor.should == 10000
    parcela.data_vencimento.should == "19/06/2009"
    parcela.numero.should == 3.to_s
    conta_a_receber.numero_de_parcelas.should == 3
  end

  it "testa o quando não inserir_nova_parcela" do
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    parcela = {"inserindo_nova_parcela" => true, "valor" => "", "data_vencimento" => "19/06/2009"}
    assert_difference 'Parcela.count', 0 do
      conta_a_receber.inserir_nova_parcela(parcela).first.should == false
    end
  end

  it "deve verificar o verbose da situacao" do
    r = RecebimentoDeConta.new
    r.situacao_verbose.should == "Normal"
    r.situacao = 2
    r.situacao_verbose.should == "Cancelado"
    r.situacao = 3
    r.situacao_verbose.should == "Jurídico"
    r.situacao = 4
    r.situacao_verbose.should == "Renegociado"
    r.situacao = 5
    r.situacao_verbose.should == "Inativo"
  end

  it 'deve validar origem e, se for interna, exigir vendedor' do
    #Deve exigir origem
    r = RecebimentoDeConta.new
    r.valid?
    r.errors.should be_invalid(:origem)
    r.errors.should_not be_invalid(:vendedor)
    r.origem_verbose.should == nil
  
    #Como é interno, deve exigir vendedor
    r = RecebimentoDeConta.new :origem => RecebimentoDeConta::Interna
    r.valid?
    r.errors.should_not be_invalid(:origem)
    r.errors.should be_invalid(:vendedor)
    r.origem_verbose.should == 'Interna'
  
    #Não deve aceitar vendedor que não seja funcionário
    r = RecebimentoDeConta.new :origem => RecebimentoDeConta::Interna, :vendedor_id => pessoas(:paulo).id
    r.valid?
    r.errors.should_not be_invalid(:origem)
    r.errors.should be_invalid(:vendedor)
  
    #Não deve aceitar vendedor que não seja funcionário
    r = RecebimentoDeConta.new :origem => RecebimentoDeConta::Interna, :vendedor_id => pessoas(:felipe).id
    r.valid?
    r.errors.should_not be_invalid(:origem)
    r.errors.should_not be_invalid(:vendedor)
  
    #Não deve exigir vendedor em venda externa
    r = RecebimentoDeConta.new :origem => RecebimentoDeConta::Externa
    r.valid?
    r.errors.should_not be_invalid(:origem)
    r.errors.should_not be_invalid(:vendedor)
    r.origem_verbose.should == 'Externa'
  
    #Origem incorreta
    r = RecebimentoDeConta.new :origem => 5
    r.valid?
    assert r.errors.invalid?(:origem)
    r.errors.should_not be_invalid(:vendedor)
  end
  
  it 'cobrador (opcional) deve ser funcionário' do
    r = RecebimentoDeConta.new
    r.valid?
    r.errors.should_not be_invalid(:cobrador)
  
    r = RecebimentoDeConta.new :cobrador_id => pessoas(:felipe).id
    r.valid?
    r.errors.should_not be_invalid(:cobrador)
      
    r = RecebimentoDeConta.new :cobrador_id => pessoas(:paulo).id
    r.valid?
    r.errors.should be_invalid(:cobrador)
  end
  
  it 'deve validar relacionamentos' do
    r = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    r.pessoa.should == pessoas(:paulo)
    r.servico.should == servicos(:curso_de_tecnologia)
    r.conta_contabil_receita.should == plano_de_contas(:plano_de_contas_ativo_despesas_senai)
    r.unidade_organizacional.should == unidade_organizacionais(:senai_unidade_organizacional)
    r.centro.should == centros(:centro_forum_economico)
    r.vendedor.should == pessoas(:felipe)
    r.cobrador.should == pessoas(:felipe)
    r.unidade.should == unidades(:senaivarzeagrande)
    r.historico_operacoes.should == [historico_operacoes(:historico_operacao_recebimento_lancado)]
  
    #Deve zerar se gravar em branco
  
    r.nome_unidade_organizacional.should == "134234239039 - Senai Matriz"
    RecebimentoDeConta.new.nome_unidade_organizacional.should == nil
    r.nome_unidade_organizacional = '' #Deve ter o writer também
    r.valid?
    r.unidade_organizacional_id.should == nil
  
    r.nome_centro.should == '4567456344 - Forum Serviço Economico'
    RecebimentoDeConta.new.nome_centro.should == nil
    r.nome_centro = '' #Deve ter o writer também
    r.valid?
    r.centro_id.should == nil
  
    r.nome_servico.should == 'Curso de Ruby on Rails'
    RecebimentoDeConta.new.nome_servico.should == nil
    r.nome_servico = '' #Deve ter o writer também
    r.valid?
    r.servico_id.should == nil
  
    r.nome_conta_contabil_receita.should == "45010101999 - Despesas do SENAI"
    RecebimentoDeConta.new.nome_conta_contabil_receita.should == nil
    r.nome_conta_contabil_receita = '' #Deve ter o writer também
    r.valid?
    r.conta_contabil_receita_id.should == nil
  
    r.nome_vendedor.should == "Felipe Giotto"
    RecebimentoDeConta.new.nome_vendedor.should == nil
    r.nome_vendedor = '' #Deve ter o writer também
    r.valid?
    r.vendedor_id.should == nil
  
    r.nome_cobrador.should == "Felipe Giotto"
    RecebimentoDeConta.new.nome_cobrador.should == nil
    r.nome_cobrador = '' #Deve ter o writer também
    r.valid?
    r.cobrador_id.should == nil
  
    r.nome_dependente.should == "Joao"
    RecebimentoDeConta.new.nome_dependente.should == nil
    r.nome_dependente = '' #Deve ter o writer também
    r.valid?
    r.dependente_id.should == nil
  end
  
  it 'deve exibir nome de pessoas e zerar ID caso seja gravado parametro string em branco' do
    r = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
  
    r.nome_pessoa.should == 'Paulo Vitor Zeferino'
    RecebimentoDeConta.new.nome_pessoa.should == nil
  
    r.nome_pessoa = nil
    r.valid?
    r.pessoa_id.should == pessoas(:paulo).id
  
    r.nome_pessoa = ''
    r.valid?
    r.pessoa_id.should == nil
  end
  
  it 'deve proteger e validar ano' do
    r = RecebimentoDeConta.new
    r.valid?
    r.errors.should be_invalid(:ano)
  
    r = RecebimentoDeConta.new :ano => 2008
    r.ano.should == nil
    r.valid?
    r.errors.should be_invalid(:ano)
  
    r = RecebimentoDeConta.new
    r.ano = 2009
    r.valid?
    r.errors.should_not be_invalid(:ano)
  end

  def uses_transaction(*methods)
    @uses_transaction = [] unless defined?(@uses_transaction)
    @uses_transaction.concat methods.map(&:to_s)
  end

  def uses_transaction?(method)
    @uses_transaction = [] unless defined?(@uses_transaction)
    @uses_transaction.include?(method.to_s)
  end

  def run_in_transaction?
    use_transactional_fixtures && !self.class.uses_transaction?(method_name)
  end

  uses_transaction 'teste de renegociacao'
  it "teste de renegociacao" do
    self.run_in_transaction?.should == false
    params = {"numero_de_parcelas" => "4", "vigencia" => "4", "dia_do_vencimento" => "20", "data_inicio" => "20/12/2009",
      "valor_do_documento_em_reais" => "400.00"}
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.usuario_corrente = usuarios(:quentin)
    conta_a_receber.parcelas.length.should == 2

    assert_difference 'HistoricoOperacao.count', 2 do
      assert_difference 'Parcela.count', 4 do
        conta_a_receber.renegociar(params).should == true
      end
    end
    conta_a_receber.reload

    conta_a_receber.numero_de_renegociacoes.should == 1
    conta_a_receber.numero_de_parcelas.should == 4
    conta_a_receber.dia_do_vencimento.should == 20
    conta_a_receber.data_inicio.should == "20/12/2009"
    conta_a_receber.data_final.should == "20/04/2010"
    conta_a_receber.parcelas.length.should == 6
    conta_a_receber.parcelas.select {|parcela| parcela.situacao == Parcela::RENEGOCIADA }.length.should == 2
    conta_a_receber.parcelas.select {|parcela| parcela.situacao == Parcela::PENDENTE }.length.should == 4
  end

  uses_transaction 'teste de renegociacao em recebimento que tem parcelas quitadas'
  it "teste de renegociacao em recebimento que tem parcelas quitadas" do
    self.run_in_transaction?.should == false
    params = {"numero_de_parcelas" => "4", "vigencia" => "4", "dia_do_vencimento" => "20", "data_inicio" => "20/12/2009",
      "valor_do_documento_em_reais" => "400.00"}
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.usuario_corrente = usuarios(:quentin)
    conta_a_receber.parcelas.length.should == 2
    conta_a_receber.parcelas.first.update_attributes!({"ano_contabil_atual"=>2009,"historico" => "Baixando..","baixando" => true, "valor_dos_juros_em_reais" => "0.00", "valor_da_multa_em_reais" => "0.00", "forma_de_pagamento" => "1", "data_do_pagamento" => Date.today.strftime("%d/%m/%Y"), "valor_do_desconto_em_reais" => "0.00", "data_da_baixa" => Date.today.strftime("%d/%m/%Y")})
    conta_a_receber.parcelas.reload

    assert_difference 'HistoricoOperacao.count', 2 do
      assert_difference 'Parcela.count', 4 do
        conta_a_receber.renegociar(params).should == true
      end
    end
    conta_a_receber.reload

    conta_a_receber.numero_de_renegociacoes.should == 1
    conta_a_receber.numero_de_parcelas.should == 4
    conta_a_receber.dia_do_vencimento.should == 20
    conta_a_receber.data_inicio.should == "20/12/2009"
    conta_a_receber.data_final.should == "20/04/2010"
    conta_a_receber.parcelas.length.should == 6
    conta_a_receber.parcelas.select {|parcela| parcela.situacao == Parcela::RENEGOCIADA }.length.should == 1
    conta_a_receber.parcelas.select {|parcela| parcela.situacao == Parcela::QUITADA }.length.should == 1
    conta_a_receber.parcelas.select {|parcela| parcela.situacao == Parcela::PENDENTE }.length.should == 4
  end

  uses_transaction "nao deve renegociar pois nao mudou numero_de_parcelas ou valor do documento"
  it "nao deve renegociar pois nao mudou numero_de_parcelas ou valor do documento" do
    self.run_in_transaction?.should == false
    params = {"numero_de_parcelas" => "2", "vigencia" => "4", "dia_do_vencimento" => "20", "data_inicio" => "20/12/2009",
      "valor_do_documento_em_reais" => "60,00"}
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.usuario_corrente = usuarios(:quentin)
    conta_a_receber.parcelas.length.should == 2
    conta_a_receber.parcelas.first.update_attributes!({"ano_contabil_atual"=>2009,"historico" => "Baixando..", "baixando" => true, "valor_dos_juros_em_reais" => "0.00", "valor_da_multa_em_reais" => "0.00", "forma_de_pagamento" => "1", "data_do_pagamento" => Date.today.strftime("%d/%m/%Y"), "valor_do_desconto_em_reais" => "0.00", "data_da_baixa" => Date.today.strftime("%d/%m/%Y")})
    conta_a_receber.parcelas.reload
    assert_no_difference 'HistoricoOperacao.count' do
      assert_no_difference 'Parcela.count' do
        conta_a_receber.renegociar(params)
        conta_a_receber.errors.full_messages.collect.should == ["Para efetuação da renegociação, deve ser alterado o campo número da parcela ou o campo valor."]
      end
    end
  end

  uses_transaction "deve renegociar pois mudou o número de parcelas"
  it "deve renegociar pois mudou o número de parcelas" do
    self.run_in_transaction?.should == false
    params = {"numero_de_parcelas" => "4", "vigencia" => "4", "dia_do_vencimento" => "20", "data_inicio" => "20/12/2009",
      "valor_do_documento_em_reais" => "60.00"}
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.usuario_corrente = usuarios(:quentin)
    conta_a_receber.parcelas.length.should == 2
    conta_a_receber.parcelas.first.update_attributes!({"ano_contabil_atual"=>2009,"historico" => "Baixando..", "baixando" => true, "valor_dos_juros_em_reais" => "0.00", "valor_da_multa_em_reais" => "0.00", "forma_de_pagamento" => "1", "data_do_pagamento" => Date.today.strftime("%d/%m/%Y"), "valor_do_desconto_em_reais" => "0.00", "data_da_baixa" => Date.today.strftime("%d/%m/%Y")})
    conta_a_receber.parcelas.reload

    assert_difference 'HistoricoOperacao.count', 2 do
      assert_difference 'Parcela.count', 4 do
        conta_a_receber.renegociar(params).should == true
        conta_a_receber.errors.full_messages.collect.should == []
      end
    end
  end

  uses_transaction "deve renegociar pois mudou o valor"
  it "deve renegociar pois mudou o valor" do
    self.run_in_transaction?.should == false
    params = {"numero_de_parcelas" => "2", "vigencia" => "4", "dia_do_vencimento" => "20", "data_inicio" => "20/12/2009",
      "valor_do_documento_em_reais" => "1000.00"}
    conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
    conta_a_receber.usuario_corrente = usuarios(:quentin)
    conta_a_receber.parcelas.length.should == 2
    conta_a_receber.parcelas.first.update_attributes!({"ano_contabil_atual"=>2009,"historico" => "Baixando..", "baixando" => true, "valor_dos_juros_em_reais" => "0.00", "valor_da_multa_em_reais" => "0.00", "forma_de_pagamento" => "1", "data_do_pagamento" => Date.today.strftime("%d/%m/%Y"), "valor_do_desconto_em_reais" => "0.00", "data_da_baixa" => Date.today.strftime("%d/%m/%Y")})
    conta_a_receber.parcelas.reload

    assert_difference 'HistoricoOperacao.count', 2 do
      assert_difference 'Parcela.count', 2 do
        conta_a_receber.renegociar(params).should == true
        conta_a_receber.errors.full_messages.collect.should == []
      end
    end
  end

  it 'deve proteger parcelas geradas' do
    r = RecebimentoDeConta.new
    r.parcelas_geradas.should == false
  
    r = RecebimentoDeConta.new :parcelas_geradas => true
    r.parcelas_geradas.should == false
  
    r = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    r.parcelas_geradas.should == false
    r.update_attributes! :parcelas_geradas => true
    r.reload
    r.parcelas_geradas.should == false
  end
  
  it 'deve proteger e gerar numero_de_controle' do
    Date.stub!(:today).and_return Date.new(2009, 5, 9)
  
    r = RecebimentoDeConta.new :usuario_corrente=>@quentin, :numero_de_controle => 'ASD'
    r.numero_de_controle.should == nil
  
    r = RecebimentoDeConta.new @valid_attributes
    r.ano = 2009
    r.centro = centros(:centro_forum_economico)
    r.unidade = unidades(:senaivarzeagrande)
    r.data_inicio_servico = "01/06/2009"
    r.data_final_servico = "01/09/2009"
    r.save!
  
    #Primeiro (0001) documento de maio (05) de 2009 (09)
    r.numero_de_controle.should == 'SENAI-VG-CPMF05/090001'
    r = RecebimentoDeConta.new @valid_attributes
    r.ano = 2009
    r.centro = centros(:centro_forum_economico)
    r.unidade = unidades(:senaivarzeagrande)
    r.data_inicio_servico = "01/06/2009"
    r.data_final_servico = "01/09/2009"
    r.save!
  
    #Segundo (0002) documento de maio (05) de 2009 (09)
    r.numero_de_controle.should == 'SENAI-VG-CPMF05/090002'
  
    r = RecebimentoDeConta.new @valid_attributes
    r.ano = 2009
    r.centro = centros(:centro_forum_economico)
    r.unidade = unidades(:senaivarzeagrande)
    r.data_inicio_servico = "01/06/2009"
    r.data_final_servico = "01/09/2009"
    r.save!
  
    #Terceir (0003) documento de maio (05) de 2009 (09)
    r.numero_de_controle.should == 'SENAI-VG-CPMF05/090003'
  
    Date.stub!(:today).and_return Date.new(2009, 11, 9)
    RecebimentoDeConta.delete_all
    r = RecebimentoDeConta.new @valid_attributes
    r.ano = 2009
    r.centro = centros(:centro_forum_economico)
    r.unidade = unidades(:senaivarzeagrande)
    r.data_inicio_servico = "01/06/2009"
    r.data_final_servico = "01/09/2009"
    r.save!
  
    #Primeiro (0001) documento de novembro (11) de 2009 (09)
    r.numero_de_controle.should == 'SENAI-VG-CPMF11/090001'
  end
  
  it 'deve gerar follow-up' do
    RecebimentoDeConta.delete_all
    r = RecebimentoDeConta.new @valid_attributes
    lambda do
      r.ano = 2009
      r.centro = centros(:centro_forum_economico)
      r.unidade = unidades(:senaivarzeagrande)
      r.data_inicio_servico = "01/06/2009"
      r.data_final_servico = "01/09/2009"
      r.save!
    end.should change(HistoricoOperacao, :count)
  
    h = r.historico_operacoes.first
    h.descricao.should == 'Conta a receber criada'
    h.usuario.should == usuarios(:quentin)
  end
  
  it 'deve relacionar-se com parcelas' do
    recebimento_de_contas(:curso_de_design_do_paulo).parcelas.should == [parcelas(:primeira_parcela_recebimento), parcelas(:segunda_parcela_recebimento)]
  end
  
  it 'deve gerar parcelas corretamente' do
    @conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    @conta.usuario_corrente = usuarios(:quentin)
  
    assert_difference 'Parcela.count', 1 do
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta.gerar_parcelas(2009)
        historico_operacao = @conta.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 1 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta
      end
    end
  
    parcelas = @conta.parcelas
    @primeira_parcela = parcelas[0]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "01/10/2009"
    @primeira_parcela.numero.should == 1.to_s
    @primeira_parcela.valor.should == 1000
  end
  
  it 'deve gerar parcelas para o proximo ano' do
    @conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
    @conta.usuario_corrente = usuarios(:quentin)
  
    assert_difference 'Parcela.count', 3 do
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta.gerar_parcelas(2009)
        historico_operacao = @conta.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 3 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta
      end
    end
  
    parcelas = @conta.parcelas
    @primeira_parcela = parcelas[0]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "05/01/2010"
    @primeira_parcela.numero.should == 1.to_s
    @primeira_parcela.valor.should == 3000
  
    parcelas = @conta.parcelas
    @primeira_parcela = parcelas[1]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "05/02/2010"
    @primeira_parcela.numero.should == 2.to_s
    @primeira_parcela.valor.should == 3000
  
    parcelas = @conta.parcelas
    @primeira_parcela = parcelas[2]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "05/03/2010"
    @primeira_parcela.numero.should == 3.to_s
    @primeira_parcela.valor.should == 3000
  end
  
  it 'deve gerar parcelas com outra data para o próximo mês, porèm deve deixar o mesmo dia de vencimento para os meses restantes' do
    @conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_no_proximo_mes)
    @conta.usuario_corrente = usuarios(:quentin)
  
    assert_difference 'Parcela.count', 2 do
      assert_difference 'HistoricoOperacao.count', 1 do
        @conta.gerar_parcelas(2009)
        historico_operacao = @conta.historico_operacoes.last
        historico_operacao.descricao.should == "Geradas 2 parcelas"
        historico_operacao.usuario = usuarios(:quentin)
        historico_operacao.conta = @conta
      end
    end
  
    parcelas = @conta.parcelas
    @primeira_parcela = parcelas[0]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "01/05/2009"
    @primeira_parcela.numero.should == 1.to_s
    @primeira_parcela.valor.should == 4500
  
    parcelas = @conta.parcelas
    @primeira_parcela = parcelas[1]
    @primeira_parcela.data_vencimento.to_date.to_s_br.should == "01/06/2009"
    @primeira_parcela.numero.should == 2.to_s
    @primeira_parcela.valor.should == 4500
  end
  
  it 'teste de geração de nova de data de vencimento' do
    recebimento_de_conta = RecebimentoDeConta.new
  
    recebimento_de_conta.gerar_nova_data_de_vencimento("01/01/2009", 5).should == "05/01/2009".to_date
    recebimento_de_conta.gerar_nova_data_de_vencimento("31/12/2009", 31).should == "31/12/2009".to_date
    recebimento_de_conta.gerar_nova_data_de_vencimento("31/12/2009", 1).should == "01/01/2010".to_date
    recebimento_de_conta.gerar_nova_data_de_vencimento("29/02/2008", 30).should == "01/03/2008".to_date
  end
    
  it "testa se valida a data de lancamento" do
    Date.stub(:today).and_return(Date.new(2009, 9, 20))
    unidades(:senaivarzeagrande).lancamentoscontasreceber = 5
    unidades(:senaivarzeagrande).save
    recebimento_de_contas(:curso_de_tecnologia_do_paulo).reload
    recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    recebimento_de_conta.validar_data_inicio.should == true
    unidades(:senaivarzeagrande).lancamentoscontasreceber = 5000
    unidades(:senaivarzeagrande).save
    recebimento_de_contas(:curso_de_tecnologia_do_paulo).reload
    recebimento_de_conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    recebimento_de_conta.validar_data_inicio.should == true
  end
  
  it 'deve validar multas e juros' do
    r = RecebimentoDeConta.new
    r.multa_por_atraso.should == 2
    r.juros_por_atraso.should == 1
    r.valid?
    r.errors.should_not be_invalid(:multa_por_atraso)
    r.errors.should_not be_invalid(:juros_por_atraso)
  
    r = RecebimentoDeConta.new :multa_por_atraso => 0, :juros_por_atraso => 0
    r.multa_por_atraso.should == 0
    r.juros_por_atraso.should == 0
    r.valid?
    r.errors.should_not be_invalid(:multa_por_atraso)
    r.errors.should_not be_invalid(:juros_por_atraso)
  
    r.multa_por_atraso = 1
    r.juros_por_atraso = 1
    r.valid?
    r.errors.should_not be_invalid(:multa_por_atraso)
    r.errors.should_not be_invalid(:juros_por_atraso)
  
    r.multa_por_atraso = -1
    r.juros_por_atraso = -1
    r.valid?
    r.errors.should be_invalid(:multa_por_atraso)
    r.errors.should be_invalid(:juros_por_atraso)
  end
  
  it 'deve retornar parcelas em aberto' do
    p = parcelas(:segunda_parcela_recebimento)
    p.data_da_baixa = Date.yesterday
    p.save false
  
    r = recebimento_de_contas(:curso_de_design_do_paulo)
    r.parcelas.should == parcelas(:primeira_parcela_recebimento, :segunda_parcela_recebimento)
    r.parcelas_em_aberto.should == [parcelas(:primeira_parcela_recebimento)]
  end
  
  it 'deve validar unidade organizacional e centro' do
    @conta_a_receber = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    @conta_a_receber.centro = centros(:centro_forum_social)
    @conta_a_receber.should_not be_valid
    @conta_a_receber.errors.on(:centro).sort.should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."].sort
  
    @conta_a_receber.reload
    @conta_a_receber.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    @conta_a_receber.centro = centros(:centro_forum_economico)
    @conta_a_receber.should_not be_valid
    @conta_a_receber.errors.on(:centro).should == "pertence a outra Unidade Organizacional."
  
    @conta_a_receber.reload
    @conta_a_receber.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @conta_a_receber.centro = centros(:centro_forum_social)
    @conta_a_receber.should_not be_valid
    @conta_a_receber.errors.on(:centro).sort.should == ["tem ano inválido.", "pertence a outra Unidade Organizacional."].sort
  
    @conta_a_receber.reload
    @conta_a_receber.unidade_organizacional = unidade_organizacionais(:senai_unidade_organizacional)
    @conta_a_receber.centro = centros(:centro_forum_economico)
    @conta_a_receber.should be_valid
  end
    
  describe 'deve alterar o valor das parcelas' do

    it "conseguiu alterar valor das parcelas conta sem rateio" do
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      conta.valor_do_documento.should == 6000
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas.first.to_s => {"valor" => "70,00", "data_vencimento" => "22/07/2009"},
        ids_das_parcelas.last.to_s => {"valor" => "30,00", "data_vencimento" => "22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      conta.reload
      conta.valor_do_documento.should == 10000
      conta.parcelas.first.valor.should == 7000
      conta.parcelas.first.data_vencimento.should == "22/07/2009"
      conta.parcelas.last.valor.should == 3000
      conta.parcelas.last.data_vencimento.should == "22/08/2009"
    end

    it "conseguiu alterar valor das parcelas sem rateio menos as renegociadas" do
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      # Vinculando nova parcela para auxiliar no teste
      nova_parcela_da_conta = Parcela.new "conta_id" => conta.id, "data_vencimento" => Date.new(2009, 6, 6), "recibo_impresso" => true, "valor_dos_juros" => 0,
        "valor" => 1000, "situacao" => Parcela::RENEGOCIADA, "valor_do_desconto" => 0, "outros_acrescimos" => 0, "valor_da_multa" => 0, "numero" => 3, "conta_type" => "RecebimentoDeConta"
      nova_parcela_da_conta.save
      nova_parcela_da_conta.reload

      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas.first.to_s => {"valor"=>"40,00","data_vencimento"=>"22/07/2009"}, ids_das_parcelas[1].to_s => {"valor"=>"20,00","data_vencimento"=>"22/07/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      conta.reload

      conta.parcelas.first.valor.should == 4000
      conta.parcelas.first.data_vencimento.should == "22/07/2009"
      conta.parcelas[1].valor.should == 2000
      conta.parcelas[1].data_vencimento.should == "22/07/2009"
      conta.parcelas.last.valor.should == 1000
      conta.parcelas.last.data_vencimento.should == "06/06/2009"
    end

    it "conseguiu alterar valor das parcelas sem rateio menos as canceladas" do
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      # Vinculando nova parcela para auxiliar no teste
      nova_parcela_da_conta = Parcela.new "conta_id" => conta.id, "data_vencimento" => Date.new(2009, 6, 6), "recibo_impresso" => true, "valor_dos_juros" => 0,
        "valor" => 1000, "situacao" => Parcela::CANCELADA, "valor_do_desconto" => 0, "outros_acrescimos" => 0, "valor_da_multa" => 0, "numero" => 3, "conta_type" => "RecebimentoDeConta"
      nova_parcela_da_conta.save
      nova_parcela_da_conta.reload

      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas.first.to_s => {"valor"=>"40,00","data_vencimento"=>"22/07/2009"}, ids_das_parcelas[1].to_s => {"valor"=>"20,00","data_vencimento"=>"22/07/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
      conta.reload

      conta.parcelas.first.valor.should == 4000
      conta.parcelas.first.data_vencimento.should == "22/07/2009"
      conta.parcelas[1].valor.should == 2000
      conta.parcelas[1].data_vencimento.should == "22/07/2009"
      conta.parcelas.last.valor.should == 1000
      conta.parcelas.last.data_vencimento.should == "06/06/2009"
    end
      
    it "conseguiu alterar valor das parcelas de conta com rateio" do
      Parcela.delete_all
      Rateio.delete_all
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      conta.rateio = 1
      conta.save
      conta.gerar_parcelas(2009)
      conta.reload
      primeira_parcela = conta.parcelas.first
      primeira_parcela.dados_do_rateio = {"1" => {"centro_nome" => "4567456344 - Forum Serviço Economico", "unidade_organizacional_nome" => "134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_economico).id.to_s, "valor"=>"15.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s, "conta_contabil_nome" => "41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2" => {"centro_nome" => "124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome" => "134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"15.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s, "conta_contabil_nome"=> "41010101008 - Contribuicoes Regul. oriundas do SESI"}
      }
      primeira_parcela.grava_itens_do_rateio(2009, conta.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      primeira_parcela.rateios.first.destroy
      atributos = {conta.parcelas.first.id.to_s => {"valor" => "10,00","data_vencimento"=>"22/07/2009"},
        conta.parcelas.last.id.to_s => {"valor" => "10,00","data_vencimento" => "22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
    end

    it "não conseguiu alterar valor das parcelas de conta com rateio pois a data de vencimento está em branco" do
      Parcela.delete_all
      Rateio.delete_all
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      conta.rateio = 1
      conta.save!
      conta.gerar_parcelas(2009)
      conta.reload
      primeira_parcela = conta.parcelas.first
      primeira_parcela.dados_do_rateio = {"1"=>{"centro_nome"=>"4567456344 - Forum Serviço Economico", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_economico).id.to_s, "valor"=>"15.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"},
        "2"=>{"centro_nome"=>"124453343 - Forum Serviço Financeiro", "unidade_organizacional_nome"=>"134234239039 - Sesi Matriz", "centro_id"=>centros(:centro_forum_financeiro).id.to_s, "valor"=>"15.00", "unidade_organizacional_id"=>unidade_organizacionais(:senai_unidade_organizacional).id, "conta_contabil_id"=>plano_de_contas(:plano_de_contas_ativo_contribuicoes).id.to_s,"conta_contabil_nome"=>"41010101008 - Contribuicoes Regul. oriundas do SESI"}
      }
      primeira_parcela.grava_itens_do_rateio(2009, conta.usuario_corrente).should == [true, "Rateio gravado com sucesso!"]
      primeira_parcela.rateios.first.destroy
      atributos= {conta.parcelas.first.id.to_s=>{"valor"=>"50,00","data_vencimento"=>""},
        conta.parcelas.last.id.to_s=>{"valor"=>"10,00","data_vencimento"=>"22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should ==  "A data de vencimento deve ser preenchida."
    end
      
    it "não conseguiu alterar valor das parcelas pois data_vencimento_em_branco " do
      conta=recebimento_de_contas(:curso_de_design_do_paulo)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos= {ids_das_parcelas.first.to_s=>{"valor"=>"40,00","data_vencimento"=>""},
        ids_das_parcelas.last.to_s=>{"valor"=>"20,00","data_vencimento"=>"22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "A data de vencimento deve ser preenchida."
      conta.reload
      conta.parcelas.first.valor.should == 3000
      conta.parcelas.last.valor.should == 3000
    end
    
    it "não conseguiu alterar valor das parcelas pois data_vencimento era menor que a data de início do contrato " do
      conta=recebimento_de_contas(:curso_de_design_do_paulo)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos= {ids_das_parcelas.first.to_s=>{"valor"=>"40,00","data_vencimento"=>"11/09/2000"},
        ids_das_parcelas.last.to_s=>{"valor"=>"20,00","data_vencimento"=>"22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "A parcela com data de vencimento 11/09/2000 é inválida, pois a data de início do contrato é 28/06/2009"
      conta.reload
      conta.parcelas.first.valor.should == 3000
      conta.parcelas.last.valor.should == 3000
    end
      
    it "não conseguiu altear valor das parcelas pois valor de uma das parcelas é zero" do
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas.first.to_s => {"valor" => "0", "data_vencimento" => "22/07/2009"},
        ids_das_parcelas.last.to_s => {"valor" => "20,00", "data_vencimento" => "22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "O campo valor deve ser maior do que zero."
    end
      
    it "não conseguiu alterar valor das parcelas pois valor de uma das parcelas está em branco" do
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas.first.to_s => {"valor" => "", "data_vencimento" => "22/07/2009"},
        ids_das_parcelas.last.to_s => {"valor" => "20,00", "data_vencimento" => "22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == "O campo valor deve ser maior do que zero."
    end
      
    it "conseguiu altear valor das parcelas mesmo com a soma do valor das parcelas sendo maior do que o valor do documento" do
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      conta.usuario_corrente = usuarios(:quentin)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      atributos = {ids_das_parcelas.first.to_s => {"valor" => "900,00", "data_vencimento" => "22/07/2009"},
        ids_das_parcelas.last.to_s => {"valor" => "20,00", "data_vencimento" => "22/08/2009"}}
      conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true
    end
      
    it "verifica se a soma do valor das parcelas é igual ao valor do documento" do
      conta=recebimento_de_contas(:curso_de_design_do_paulo)
      ids_das_parcelas = conta.parcelas.collect(&:id)
      # Valores são iguais
      atributos= {ids_das_parcelas.first.to_s=>{"valor"=>"40,00","data_vencimento"=>"22/07/2009"},
        ids_das_parcelas.last.to_s=>{"valor"=>"20,00","data_vencimento"=>"22/08/2009"}}
      conta.valores_das_parcelas_sao_diferentes?(atributos).should == false
      # Valor são diferentes
      atributos= {ids_das_parcelas.first.to_s=>{"valor"=>"60,00","data_vencimento"=>"22/07/2009"},
        ids_das_parcelas.last.to_s=>{"valor"=>"20,00","data_vencimento"=>"22/08/2009"}}
      conta.valores_das_parcelas_sao_diferentes?(atributos).should == true
    end
      
  end
    
  describe 'deve permitir alterar dados de parcelas' do
      
    #    it 'mas proteger os atributos de mass-assignment' do
    #      r = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    #      assert_equal true, r.update_attributes('parcelas_attributes' => [{'data_vencimento' => Date.today.to_s}])
    #      assert_equal 0, r.parcelas.count
    #    end
  
#    it "deve prorrogar o prazo do curso e criar follow-up" do
#      centros(:centro_forum_economico).ano = 2008
#      centros(:centro_forum_economico).save
#      centros(:centro_forum_economico).reload
#      unidade_organizacionais(:senai_unidade_organizacional).ano = 2008
#      unidade_organizacionais(:senai_unidade_organizacional).save
#      unidade_organizacionais(:senai_unidade_organizacional).reload
#      servicos(:curso_de_design).unidade = unidades(:sesivarzeagrande)
#      servicos(:curso_de_design).save
#      servicos(:curso_de_design).reload
#      contratosenai2008 = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
#      contratosenai2008.ano = 2008
#      contratosenai2008.data_inicio = "24/09/2008"
#      contratosenai2008.data_final = "24/10/2008"
#      contratosenai2008.data_inicio_servico = "24/09/2008"
#      contratosenai2008.data_final_servico = "24/10/2008"
#      contratosenai2008.data_venda = "01/09/2008"
#      contratosenai2008.save false
#      contratosesi2009 = recebimento_de_contas(:curso_de_design_do_paulo)
#      contratosesi2009.centro = centros(:centro_forum_social)
#      contratosesi2009.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
#      contratosesi2009.unidade = unidades(:sesivarzeagrande)
#      contratosesi2009.save false
#      justificativa = "Pedido prorrogado por solicitação da diretoria."
#      lambda do
#        RecebimentoDeConta.prorroga_todos_contratos(usuarios(:quentin),unidades(:senaivarzeagrande).id,2008,{:servico_id => servicos(:curso_de_tecnologia).id, :nome_servico => "Curso de Ruby on Rails", :vigencia => 2, :data_inicio => "24/10/2008"},justificativa).should == true
#        contratosenai2008.historico_operacoes.last.descricao.should == "Pedido prorrogado, nova data de início 24/10/2008 com vigência de 2 meses finalizando em 24/12/2008."
#        contratosenai2008.historico_operacoes.last.justificativa.should == "Pedido prorrogado por solicitação da diretoria."
#      end.should change(HistoricoOperacao, :count).by(1)
#      lambda do
#        RecebimentoDeConta.prorroga_todos_contratos(usuarios(:quentin),unidades(:sesivarzeagrande).id,2009,{:servico_id => servicos(:curso_de_design).id, :nome_servico => "Curso de Flex", :vigencia => 4, :data_inicio => "28/08/2009"},justificativa).should == true
#        contratosesi2009.historico_operacoes.last.descricao.should == "Pedido prorrogado, nova data de início 28/08/2009 com vigência de 4 meses finalizando em 28/12/2009."
#        contratosesi2009.historico_operacoes.last.justificativa.should == "Pedido prorrogado por solicitação da diretoria."
#      end.should change(HistoricoOperacao, :count).by(1)
#      contratosenai2008.reload
#      contratosesi2009.reload
#      contratosenai2008.data_inicio.should == "24/10/2008"
#      contratosenai2008.vigencia.should == 2
#      contratosenai2008.data_final.should == "24/12/2008"
#      contratosesi2009.data_inicio.should == "28/08/2009"
#      contratosesi2009.vigencia.should == 4
#      contratosesi2009.data_final.should == "28/12/2009"
#    end
      
#    it "não deve prorrogar o curso e não deve criar follow_up" do
#      servicos(:curso_de_design).unidade = unidades(:sesivarzeagrande)
#      servicos(:curso_de_design).save
#      servicos(:curso_de_design).reload
#      contratosesi2009 = recebimento_de_contas(:curso_de_design_do_paulo)
#      contratosesi2009.centro = centros(:centro_forum_social)
#      contratosesi2009.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
#      contratosesi2009.unidade = unidades(:sesivarzeagrande)
#      contratosesi2009.save false
#      justificativa = "Pedido prorrogado por solicitação da diretoria."
#      lambda do
#        RecebimentoDeConta.prorroga_todos_contratos(usuarios(:quentin),unidades(:sesivarzeagrande).id,2009,{:servico_id => servicos(:curso_de_design).id, :nome_servico => "Curso de Flex", :vigencia => '', :data_inicio => "28/08/2009"},justificativa).should == false
#      end.should_not change(HistoricoOperacao, :count)
#      contratosesi2009.reload
#      contratosesi2009.data_inicio.should == "28/06/2009"
#      contratosesi2009.vigencia.should == 2
#      contratosesi2009.data_final.should == "28/08/2009"
#    end
#
#    it "deve retornar false caso a pesquisa não retorne nenhum contrato e o servico id for nil" do
#      servicos(:curso_de_design).unidade = unidades(:sesivarzeagrande)
#      servicos(:curso_de_design).save
#      servicos(:curso_de_design).reload
#      contratosesi2009 = recebimento_de_contas(:curso_de_design_do_paulo)
#      contratosesi2009.centro = centros(:centro_forum_social)
#      contratosesi2009.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
#      contratosesi2009.unidade = unidades(:sesivarzeagrande)
#      contratosesi2009.save false
#      justificativa = "Pedido prorrogado por solicitação da diretoria."
#      lambda do
#        RecebimentoDeConta.prorroga_todos_contratos(usuarios(:quentin),unidades(:sesivarzeagrande).id,2009,{:servico_id => '', :nome_servico => "Curso de Flex", :vigencia => '', :data_inicio => "28/08/2009"},justificativa).should == false
#      end.should_not change(HistoricoOperacao, :count)
#      contratosesi2009.reload
#      contratosesi2009.data_inicio.should == "28/06/2009"
#      contratosesi2009.vigencia.should == 2
#      contratosesi2009.data_final.should == "28/08/2009"
#    end
#
#    it "deve retornar false caso a pesquisa retorne parametros sem justificatica" do
#      servicos(:curso_de_design).unidade = unidades(:sesivarzeagrande)
#      servicos(:curso_de_design).save
#      servicos(:curso_de_design).reload
#      contratosesi2009 = recebimento_de_contas(:curso_de_design_do_paulo)
#      contratosesi2009.centro = centros(:centro_forum_social)
#      contratosesi2009.unidade_organizacional = unidade_organizacionais(:sesi_colider_unidade_organizacional)
#      contratosesi2009.unidade = unidades(:sesivarzeagrande)
#      contratosesi2009.save false
#      justificativa = ''
#      lambda do
#        RecebimentoDeConta.prorroga_todos_contratos(usuarios(:quentin),unidades(:sesivarzeagrande).id,2009,{:servico_id => servicos(:curso_de_design).id, :nome_servico => "Curso de Flex", :vigencia => '2', :data_inicio => "28/08/2009"},justificativa).should == false
#      end.should_not change(HistoricoOperacao, :count)
#      contratosesi2009.reload
#      contratosesi2009.data_inicio.should == "28/06/2009"
#      contratosesi2009.vigencia.should == 2
#      contratosesi2009.data_final.should == "28/08/2009"
#    end
  
  
    #    it 'deve aceitar alterar o valor de parcelas, se bater os dados' do
    #      r = recebimento_de_contas(:curso_de_design_do_paulo)
    #      assert_equal true, r.atualizar_valor_das_parcelas([{:id => parcelas(:primeira_parcela_recebimento).id, :data_vencimento => '10/07/2009', :preco_em_reais => '30.00'},
    #          {:id => parcelas(:segunda_parcela_recebimento).id,  :data_vencimento => '05/08/2009', :preco_em_reais => '30.00'}])
  
    #
  
    #
  
    #      p = parcelas(:primeira_parcela_recebimento)
    #      p.reload
    #      assert_equal '10/07/2009', p.data_vencimento
    #      assert_equal 3000, p.valor
    #    end
      
    #    it 'não deve aceitar alterar o valor de parcelas, se os valores não baterem' do
    #      r = recebimento_de_contas(:curso_de_design_do_paulo)
    #      assert_equal false, r.atualizar_valor_das_parcelas([{:id => parcelas(:primeira_parcela_recebimento).id, :data_vencimento => '10/07/2009', :preco_em_reais => '40.00'},
    #                                                         {:id => parcelas(:segunda_parcela_recebimento).id,  :data_vencimento => '05/08/2009', :preco_em_reais => '30.00'}])
    #      assert r.errors.on(:parcelas)
    #      p = parcelas(:primeira_parcela_recebimento)
    #      p.reload
    #      assert_equal '05/07/2009', p.data_vencimento
    #      assert_equal 3000, p.valor
    #    end
  
  end
  
  describe "Abdicação dos contratos" do
  
    it "abdicação, validação da situacao, alteração da situação das parcelas e contagem de follow-up" do
      Date.stub!(:today).and_return Date.new(2009, 5, 9)
      data_abdicacao = "20/07/2009"
      justificativa = "Contrato cancelado para testar."
      conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
      conta_a_receber.usuario_corrente = usuarios(:quentin)
      usuario_corrente = conta_a_receber.usuario_corrente
      conta_a_receber.situacao.should == RecebimentoDeConta::Normal
      conta_a_receber.situacao_verbose.should == "Normal"
      conta_a_receber.parcelas.first.situacao.should == Parcela::PENDENTE
      #      conta_a_receber.parcelas.first.situacao_verbose.should == "Vincenda"
  
      lambda {
        conta_a_receber.abdicar_contrato(data_abdicacao, usuario_corrente, justificativa)
      }.should change(HistoricoOperacao, :count)
      
      conta_a_receber.situacao.should == RecebimentoDeConta::Cancelado
      conta_a_receber.situacao_verbose.should == "Cancelado"
      conta_a_receber.parcelas.first.situacao.should == Parcela::CANCELADA
      conta_a_receber.parcelas.first.situacao_verbose.should == "Cancelada"
  
      historico = conta_a_receber.historico_operacoes.last
      historico.descricao.should == "Contrato abdicado em #{data_abdicacao}"
      historico.justificativa == "Contrao cancelado para testar."
  
      conta_a_receber.situacao = RecebimentoDeConta::Inativo
      conta_a_receber.save
      conta_a_receber.should_not be_valid
      conta_a_receber.errors.on(:situacao).should == "do contrato é cancelado."
    end
  
    it "abdicação e alteração da situação das parcelas quitadas" do
      data_abdicacao = "20/07/2009"
      justificativa = "Contrato cancelado para testar."
      conta_a_receber = recebimento_de_contas(:curso_de_corel_do_paulo)
      conta_a_receber.usuario_corrente = usuarios(:quentin)
      usuario_corrente = conta_a_receber.usuario_corrente
      conta_a_receber.situacao.should == RecebimentoDeConta::Normal
      conta_a_receber.situacao_verbose.should == "Normal"
      conta_a_receber.parcelas.first.situacao.should == Parcela::QUITADA
      conta_a_receber.parcelas.first.situacao_verbose.should == "Quitada"
  
      lambda {
        conta_a_receber.abdicar_contrato(data_abdicacao, usuario_corrente, justificativa)
      }.should change(HistoricoOperacao, :count)
  
      conta_a_receber.situacao.should == RecebimentoDeConta::Cancelado
      conta_a_receber.situacao_verbose.should == "Cancelado"
      conta_a_receber.parcelas.first.situacao.should == Parcela::QUITADA
      conta_a_receber.parcelas.first.situacao_verbose.should == "Quitada"
    end
  
    it "validacao do preenchimento do campo justificativa" do
      data_abdicacao = "20/07/2009"
      justificativa = ""
      conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
      conta_a_receber.usuario_corrente = usuarios(:quentin)
      usuario_corrente = conta_a_receber.usuario_corrente
      conta_a_receber.abdicar_contrato(data_abdicacao, usuario_corrente, justificativa).should == "O campo justificativa deve ser preenchido."
    end
  
    it "validacao do preenchimento do campo data da abdicacao" do
      data_abdicacao = ""
      justificativa = "Contrao cancelado para testar."
      conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
      conta_a_receber.usuario_corrente = usuarios(:quentin)
      usuario_corrente = conta_a_receber.usuario_corrente
      conta_a_receber.abdicar_contrato(data_abdicacao, usuario_corrente, justificativa).should == "O campo data de abdicação deve ser preenchido."
    end
  
    it "teste de retorno do metodo pode_ser_modificado?" do
      conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo)
      conta_a_receber.usuario_corrente = usuarios(:quentin)
      conta_a_receber.pode_ser_modificado?.should == true
      conta_a_receber.situacao = RecebimentoDeConta::Cancelado
      conta_a_receber.save
      conta_a_receber.situacao.should == RecebimentoDeConta::Cancelado
      conta_a_receber.situacao_verbose.should == 'Cancelado'
      conta_a_receber.pode_ser_modificado?.should == false
      conta_a_receber.situacao = RecebimentoDeConta::Normal
      conta_a_receber.save
      conta_a_receber.errors.on(:situacao).should == "do contrato é cancelado."
    end
  
    it "teste de retorno de mensagens ou links para gerar parcelas" do
      conta_a_receber = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      conta_a_receber.pode_gerar_parcelas.should == nil
      conta_a_receber.situacao = RecebimentoDeConta::Cancelado
      conta_a_receber.save
      conta_a_receber.pode_gerar_parcelas.should == true
    end
  
  end
    
  describe "Teste do dependent destroy" do
      
    it "quando excluir uma conta deve excluir suas parcelas" do
      @conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @conta.usuario_corrente = Usuario.first
      @conta.gerar_parcelas(2009)
      assert_difference 'RecebimentoDeConta.count', -1 do
        assert_difference 'Parcela.count', -1 do
          @conta.destroy
        end
      end
    end
    
    it "não excluir uma conta que teve parcelas baixadas" do
      @conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      @conta.usuario_corrente = Usuario.first
      @conta.gerar_parcelas(2009)
      @conta.parcelas.each{|parcela| parcela.data_da_baixa = '22/09/2009';parcela.historico="teste",parcela.forma_de_pagamento = 1}
      assert_no_difference 'RecebimentoDeConta.count' do
        assert_no_difference 'Parcela.count' do
          @conta.destroy
        end
      end
    end
  end
    
  it 'verifica geração de novas parcelas' do
    @conta = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
    @conta.usuario_corrente = Usuario.first
    @conta.gerar_parcelas(2009)
    @conta.situacao = RecebimentoDeConta::Cancelado
    @conta.save!
    params = {"data_vencimento"=>Date.today.to_s_br, "valor"=>"200.00"}
    @conta.inserir_nova_parcela params
    @conta.should_not be_valid
    @conta.errors.on(:valor_do_documento).should == "não pode ser alterado porque o contrato está cancelado."
    @conta.situacao = RecebimentoDeConta::Normal
    @conta.gerar_parcelas(2009)
    @conta.save false
    @conta.inserir_nova_parcela params
    @conta.should be_valid
    @conta.errors_on(:valor_do_documento).should_not == "não pode ser alterado porque o contrato está cancelado."
  end

  it 'testa geração de novas parcelas com outras parcelas já baixadas/canceladas' do
    @conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
    @conta.usuario_corrente = Usuario.first
    @conta.gerar_parcelas(2009)
    @conta.parcelas.first.situacao = Parcela::CANCELADA
    @conta.parcelas.first.save!
    @conta.parcelas.last.situacao = Parcela::QUITADA
    @conta.parcelas.last.save!
    @conta.save!
    params = {"data_vencimento"=>Date.today.to_s_br, "valor"=>"200.00"}
    @conta.inserir_nova_parcela params
    @conta.should be_valid
    @conta.errors_on(:valor_do_documento).should_not == "não pode ser alterado porque o contrato está cancelado."
  end

  it "testa o método virtual inserindo_nova_parcela e atualizando_parcelas" do
    @conta = RecebimentoDeConta.new
    @conta.inserindo_nova_parcela.should == false
    @conta.atualizando_parcelas.should == false
  end

  
  describe 'pesquisar para registro de Recuperação de Crédito' do
    
    #    it " Faz pesquisa   " do
    #      contas = RecebimentoDeConta.all :conditions=>["unidade_id = ? AND ano = ?",unidades(:senaivarzeagrande).id,2009], :order=>'situacao'
    #
    #      a_receber=contas.sum(&:valor_do_documento)
    #      soma_do_valor_das_parcelas = 0
    #      contas.each do |conta|
    #        conta.parcelas.each do |parcela|
    #          soma_do_valor_das_parcelas += parcela.valor if parcela.situacao != Parcela::QUITADA && parcela.situacao != Parcela::CANCELADA
    #        end
    #      end
    #      indice =0
    #      x= a_receber
    #      y= a_receber+soma_do_valor_das_parcelas
    #      indice= ((x.to_f/y) * 100)
    #     # p contas.group_by(&:mes_venda)
    #      contas= RecebimentoDeConta.recuperacao_de_creditos(unidades(:senaivarzeagrande).id,2009)
    #      #contas.should == {"total"=>{"a_receber"=>a_receber,"recebido"=>soma_do_valor_das_parcelas,"geral"=>contas.sum(&:valor_do_documento)+soma_do_valor_das_parcelas,"inadimplencia"=>indice}}
    #      p contas.sort
    #
    #    end
    
  end
  
  describe 'deve pesquiar registros' do

    def valida_resultados_de_busca_para(fixture_unidade, parametros, expected)
      RecebimentoDeConta.pesquisa_simples(unidades(fixture_unidade).id, parametros).collect(&:numero_de_controle).sort.should == expected.collect(&:numero_de_controle).sort
    end

    it 'deve retornar todas as contas de uma unidade' do
      valida_resultados_de_busca_para :senaivarzeagrande, {}, RecebimentoDeConta.find_all_by_unidade_id(unidades(:senaivarzeagrande).id, :order => 'situacao')
    end

    it 'deve retornar as contas do paulo ordenadas por situacao' do
      contas_do_paulo = RecebimentoDeConta.all(:conditions => ["unidade_id = ? AND pessoa_id = ?", unidades(:senaivarzeagrande).id, pessoas(:paulo).id], :order => 'situacao')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'paulo'}, contas_do_paulo
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => '065.124'}, contas_do_paulo
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'john nobody'}, []
    end
    
    it 'deve retornar as contas que tem flex ordenados pelo servico' do
      contas_do_paulo = RecebimentoDeConta.all(:include=>:servico,:conditions => ["recebimento_de_contas.unidade_id = ? AND  servicos.descricao like ?", unidades(:senaivarzeagrande).id, "%flex%"], :order => 'servicos.descricao')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'flex', 'ordem'=>'servicos.descricao'}, contas_do_paulo
    end
    
    it 'deve retornar as contas que tem flex ordenados pela data_inicio' do
      contas_do_paulo = RecebimentoDeConta.all(:include=>:servico,:conditions => ["recebimento_de_contas.unidade_id = ? AND  servicos.descricao like ?", unidades(:senaivarzeagrande).id, "%flex%"], :order => 'data_inicio')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'flex', 'ordem'=>'servicos.descricao'}, contas_do_paulo
    end
    
    it 'deve retornar ordenando por valor' do
      contas_do_paulo = RecebimentoDeConta.all(:conditions => ["unidade_id = ? AND pessoa_id = ?", unidades(:senaivarzeagrande).id, pessoas(:paulo).id], :order => 'valor_do_documento')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'pau', 'ordem' => 'valor_do_documento'}, contas_do_paulo
    end
    
    it "deve retornar ordenado pelo nome do cliente" do
      contas_do_paulo = RecebimentoDeConta.all(:include=>:pessoa,:conditions => ["recebimento_de_contas.unidade_id = ? AND pessoas.nome like ?", unidades(:senaivarzeagrande).id, "%pau%"], :order => 'pessoas.nome')
      valida_resultados_de_busca_para :senaivarzeagrande, {'texto' => 'pau', 'ordem' => 'pessoas.nome'}, contas_do_paulo
    end

    #Rafael

    it 'retornar o conditions da pesquisa' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_controle LIKE ?)', unidades(:sesivarzeagrande).id, "%ad%"],
        :order => 'recebimento_de_contas.situacao', :include => [:pessoa, :servico, :dependente]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:sesivarzeagrande).id, {"pesquisa" => "ad"}
    end

    it 'retornar o conditions da pesquisa passando ordem' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_controle LIKE ?)', unidades(:sesivarzeagrande).id, "%ad%"],
        :order => 'pessoas.nome', :include => [:pessoa, :servico, :dependente]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:sesivarzeagrande).id, {"pesquisa" => "ad", "ordem" => 'pessoas.nome'}
    end

    it 'retornar o conditions da pesquisa sem passar texto' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?)', unidades(:sesivarzeagrande).id], :order => 'recebimento_de_contas.situacao', :include => [:pessoa, :servico, :dependente]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:sesivarzeagrande).id, {}
    end

    it 'retornar o conditions da pesquisa passando numero de renegociacoes' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_controle LIKE ?) AND (recebimento_de_contas.numero_de_renegociacoes >= ?)', unidades(:sesivarzeagrande).id, "%ad%", 1],
        :order => 'recebimento_de_contas.situacao', :include => [:pessoa, :servico, :dependente]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:sesivarzeagrande).id, {"pesquisa" => "ad", "numero_de_renegociacoes" => 1}
    end

    it 'retornar o conditions da pesquisa passando dias de atraso, passando 20 e 45' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_controle LIKE ?)', unidades(:senaivarzeagrande).id, "%paulo%"],
        :order => 'recebimento_de_contas.situacao', :include => [:pessoa, :servico, :dependente]).and_return([recebimento_de_contas(:curso_de_design_do_paulo)])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:senaivarzeagrande).id, {"emissao_cartas"=>true, "pesquisa" => "paulo", "dias_de_atraso" => RecebimentoDeConta::CARTA_1}
    end

    it 'retornar o conditions da pesquisa passando dias de atraso, passando 20 e 45 com should' do
      Date.stub!(:today).and_return Date.new 2009,7,30
      RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, {"emissao_cartas" => true, "texto" => "paulo", "dias_de_atraso" => RecebimentoDeConta::CARTA_1}).should == [recebimento_de_contas(:curso_de_design_do_paulo)]
    end

    it 'retornar o conditions da pesquisa passando dias de atraso, passando 45 e 60' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_controle LIKE ?)', unidades(:senaivarzeagrande).id, "%paulo%"],
        :order => 'recebimento_de_contas.situacao', :include => [:pessoa, :servico, :dependente]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:senaivarzeagrande).id, {"emissao_cartas"=>true, "pesquisa" => "paulo", "dias_de_atraso" => RecebimentoDeConta::CARTA_2}
    end

    it 'retornar o conditions da pesquisa passando dias de atraso, passando 90' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_controle LIKE ?)', unidades(:senaivarzeagrande).id, "%paulo%"],
        :order => 'recebimento_de_contas.situacao', :include => [:pessoa, :servico, :dependente]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_simples unidades(:senaivarzeagrande).id, {"emissao_cartas"=>true, "pesquisa" => "paulo", "dias_de_atraso" => RecebimentoDeConta::CARTA_3}
    end

    it 'teste das situações do combo quando retorna TUDO e a situação é NORMAL' do
      busca = {"ordem" => "situacao", "texto" => "1"}
      RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, busca).count.should == 8
    end

    it 'teste das situações do combo quando não retorna NADA e a situação é BAIXA DO CONSELHO' do
      busca = {"ordem" => "situacao", "texto" => "7"}
      RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, busca).should == []
      RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, busca).count.should == 0
    end

    it 'teste das situações do combo quando não retorna NADA e a situação é PERMUTA' do
      busca = {"ordem" => "situacao", "texto" => "6"}
      RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, busca).should == []
      RecebimentoDeConta.pesquisa_simples(unidades(:senaivarzeagrande).id, busca).count.should == 0
    end

  end
  
  describe 'Deve pesquisar conta renegociadas' do
    
    it 'Deve trazer todas as contas renegociadas' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_renegociacoes > 0)',unidades(:senaivarzeagrande).id], :include => :pessoa, :order=> 'pessoas.nome').and_return([])
      @actual = RecebimentoDeConta.pesquisa_renegociacoes :all, unidades(:senaivarzeagrande).id, "periodo"=>"recebimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "", "periodo_min" => "", "opcoes" => "Renegociações Efetuadas"
    end
    
    it "filtrando por periodo e por servico" do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_renegociacoes > 0) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.created_at >= ?) AND (recebimento_de_contas.created_at <= ?)', unidades(:senaivarzeagrande).id, servicos(:curso_de_tecnologia).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => :pessoa, :order =>"pessoas.nome").and_return(0)
      @actual = RecebimentoDeConta.pesquisa_renegociacoes :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por cliente" do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_renegociacoes > 0) AND (recebimento_de_contas.pessoa_id = ?) AND (pessoas.cliente = ?) AND (recebimento_de_contas.created_at >= ?) AND (recebimento_de_contas.created_at <= ?)', unidades(:senaivarzeagrande).id, pessoas(:paulo).id, true, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => :pessoa, :order =>"pessoas.nome").and_return(0)
      @actual = RecebimentoDeConta.pesquisa_renegociacoes :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => pessoas(:paulo).nome, "cliente_id" => pessoas(:paulo).id, "nome_funcionario" => "", "funcionario_id" => "", "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por funcionario" do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_renegociacoes > 0) AND (recebimento_de_contas.cobrador_id = ?) AND (recebimento_de_contas.created_at >= ?) AND (recebimento_de_contas.created_at <= ?)', unidades(:senaivarzeagrande).id, pessoas(:paulo).id, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => :pessoa, :order =>"pessoas.nome").and_return(0)
      @actual = RecebimentoDeConta.pesquisa_renegociacoes :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => "", "servico_id" => "", "nome_cliente" => "", "cliente_id" => "", "nome_funcionario" => pessoas(:paulo).nome, "funcionario_id" => pessoas(:paulo).id, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
    it "filtrando por periodo e por servico, cliente, funcionario" do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['(recebimento_de_contas.unidade_id = ?) AND (recebimento_de_contas.numero_de_renegociacoes > 0) AND (recebimento_de_contas.servico_id = ?) AND (recebimento_de_contas.pessoa_id = ?) AND (recebimento_de_contas.cobrador_id = ?) AND (pessoas.cliente = ?) AND (recebimento_de_contas.created_at >= ?) AND (recebimento_de_contas.created_at <= ?)', unidades(:senaivarzeagrande).id, servicos(:curso_de_tecnologia).id, pessoas(:paulo).id, pessoas(:paulo).id, true, Date.new(2009, 5, 1), Date.new(2009, 5, 25)], :include => :pessoa, :order =>"pessoas.nome").and_return(0)
      @actual = RecebimentoDeConta.pesquisa_renegociacoes :all, unidades(:senaivarzeagrande).id, "periodo"=>"vencimento", "nome_servico" => servicos(:curso_de_tecnologia).descricao, "servico_id" => servicos(:curso_de_tecnologia).id, "nome_cliente" => pessoas(:paulo).nome, "cliente_id" => pessoas(:paulo).id, "nome_funcionario" => pessoas(:paulo).nome, "funcionario_id" => pessoas(:paulo).id, "periodo_max" => "25/05/2009", "periodo_min" => "01/05/2009", "opcoes" => "Ações/Cobranças Efetuadas"    
    end
    
  end
   

  describe 'atribui datas de cartas de cobrança' do

    before(:each) do
      @data_atual = Date.today.strftime("%d/%m/%Y")
    end

    it 'vincular carta de cobrança numero 1' do
      recebimento = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      recebimento.save

      assert_difference 'HistoricoOperacao.count', 1 do
        params = {'ids' => [recebimento.id.to_s], 'tipo'=>'cartas', 'tipo_de_carta' => RecebimentoDeConta::CARTA_1, 'usuario' => usuarios(:quentin)}
        RecebimentoDeConta.vincular_carta(params).should == [RecebimentoDeConta.find(recebimento.id)]
      end
      
      recebimento_com_datas = RecebimentoDeConta.find(recebimento.id)
      recebimento_com_datas.data_primeira_carta.should == @data_atual
      recebimento_com_datas.data_segunda_carta.should == nil
      recebimento_com_datas.data_terceira_carta.should == nil
    end

    it 'vincular carta de cobrança numero 2' do
      recebimento = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      recebimento.save

      assert_difference 'HistoricoOperacao.count', 1 do
        params = {'ids' => [recebimento.id.to_s], 'tipo'=>'cartas', 'tipo_de_carta' => RecebimentoDeConta::CARTA_2, 'usuario' => usuarios(:quentin)}
        RecebimentoDeConta.vincular_carta(params).should == [RecebimentoDeConta.find(recebimento.id)]
      end

      recebimento_com_datas = RecebimentoDeConta.find(recebimento.id)
      recebimento_com_datas.data_primeira_carta.should == nil
      recebimento_com_datas.data_segunda_carta.should == @data_atual
      recebimento_com_datas.data_terceira_carta.should == nil
    end

    it 'vincular carta de cobrança numero 3' do
      recebimento = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      recebimento.save

      assert_difference 'HistoricoOperacao.count', 1 do
        params = {'ids' => [recebimento.id.to_s], 'tipo'=>'cartas', 'tipo_de_carta' => RecebimentoDeConta::CARTA_3, 'usuario' => usuarios(:quentin)}
        RecebimentoDeConta.vincular_carta(params).should == [RecebimentoDeConta.find(recebimento.id)]
      end
      
      recebimento_com_datas = RecebimentoDeConta.find(recebimento.id)
      recebimento_com_datas.data_primeira_carta.should == nil
      recebimento_com_datas.data_segunda_carta.should == nil
      recebimento_com_datas.data_terceira_carta.should == @data_atual
    end

    it 'verifica excessao em caso de id inválido' do
      assert_no_difference 'HistoricoOperacao.count', 1 do
        params = {'ids' => [15131321.to_s], 'tipo'=>'cartas', 'tipo_de_carta' => RecebimentoDeConta::CARTA_1, 'usuario' => usuarios(:quentin)}
        RecebimentoDeConta.vincular_carta(params).should == "Conta inválida!"
      end
    end

  end

  it 'verifica função resumo_de_parcelas_atrasadas' do
    Date.stub!(:today).and_return Date.new 2009,7,20
    recebimento_de_contas(:curso_de_corel_do_paulo).resumo_de_parcelas_atrasadas.should == []
    recebimento_de_contas(:curso_de_design_do_paulo).resumo_de_parcelas_atrasadas.should == [["05/07/2009", (Date.today - "05/07/2009".to_date).numerator, 3000]]
  end

  it "verificação dos valores alterados em um contrato, com parcelas já baixada" do
    conta = recebimento_de_contas(:curso_de_design_do_paulo)
    conta.usuario_corrente = usuarios(:quentin)
    # Vinculando nova parcela para auxiliar no teste
    nova_parcela_da_conta = Parcela.new "conta_id" => conta.id, "data_vencimento" => Date.new(2009, 6, 6), "recibo_impresso" => true, "valor_dos_juros" => 0,
      "valor" => 1000, "situacao" => Parcela::QUITADA, "valor_do_desconto" => 0, "outros_acrescimos" => 0, "valor_da_multa" => 0, "numero" => 3, "conta_type" => "RecebimentoDeConta"
    nova_parcela_da_conta.save.should == true
    nova_parcela_da_conta.reload

    ids_das_parcelas = conta.parcelas.collect(&:id)
    atributos = {ids_das_parcelas.first.to_s => {"valor" => "30,00", "data_vencimento" => "05/07/2009"},
      ids_das_parcelas[1].to_s => {"valor" => "60,00", "data_vencimento" => "05/08/2009"}}
    conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true

    conta.reload
    conta.parcelas.first.valor.should == 3000
    conta.parcelas.first.data_vencimento.should == "05/07/2009"
    conta.parcelas[1].valor.should == 6000
    conta.parcelas[1].data_vencimento.should == "05/08/2009"
    conta.parcelas.last.valor.should == 1000
    conta.parcelas.last.data_vencimento.should == "06/06/2009"
  end

  it "verificação dos valores alterados em um contrato, com 3 parcelas e 2 já baixadas" do
    conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
    conta.data_inicio = "05/07/2009"
    conta.usuario_corrente = usuarios(:quentin)
    conta.save!
    conta.gerar_parcelas(2009)

    conta.parcelas[0].situacao = Parcela::QUITADA
    conta.parcelas[0].save!
    ids_das_parcelas = conta.parcelas.collect(&:id)    
    atributos = {ids_das_parcelas[1].to_s => {"valor" => "40,00", "data_vencimento" => "05/08/2009"},
      ids_das_parcelas[2].to_s => {"valor" => "50,00", "data_vencimento" => "05/09/2009"}}
    conta.atualizar_valor_das_parcelas(2009, atributos, conta.usuario_corrente).should == true

    conta.reload
    conta.parcelas[0].valor.should == 3000
    conta.parcelas[0].data_vencimento.should == "05/07/2009"
    conta.parcelas[1].valor.should == 4000
    conta.parcelas[1].data_vencimento.should == "05/08/2009"
    conta.parcelas[2].valor.should == 5000
    conta.parcelas[2].data_vencimento.should == "05/09/2009"
  end

  it 'teste para verificar quando se cria um objeto e o destrói antes de salvar' do
    recebimento = RecebimentoDeConta.new
    recebimento.destroy
  end

  it 'teste de verificação de quando se renegocia um contrato não apaga os movimentos de parcelas já baixadas' do
    Movimento.delete_all; ItensMovimento.delete_all

    conta = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
    conta.data_inicio = "05/07/2009"
    conta.usuario_corrente = usuarios(:quentin)
    conta.save!
    conta.gerar_parcelas(2009)
    params = {"valor_da_multa_em_reais"=>"0,00", "centro_desconto_id"=>"", "nome_conta_contabil_desconto"=>"", "forma_de_pagamento"=>"1", "centro_outros_id"=>"", "centro_juros_id"=>"", "nome_unidade_organizacional_multa"=>"", "nome_centro_desconto"=>"", "conta_contabil_desconto_id"=>"", "nome_unidade_organizacional_outros"=>"", "conta_contabil_outros_id"=>"", "nome_centro_juros"=>"", "unidade_organizacional_juros_id"=>"", "conta_contabil_multa_id"=>"", "nome_unidade_organizacional_desconto"=>"", "centro_multa_id"=>"", "nome_conta_contabil_juros"=>"", "conta_corrente_id"=>"", "nome_conta_contabil_outros"=>"", "nome_unidade_organizacional_juros"=>"", "historico"=>"Pagamento Cartão  - 123 - Juan Vitor Zeferino - Curso de Corel Draw", "observacoes"=>"", "nome_centro_outros"=>"", "outros_acrescimos_em_reais"=>"0.00", "conta_contabil_juros_id"=>"", "valor_do_desconto_em_reais"=>"0.00", "nome_conta_corrente"=>"", "valor_dos_juros_em_reais"=>"0.00", "nome_centro_multa"=>"", "unidade_organizacional_desconto_id"=>"", "justificativa_para_outros"=>"", "unidade_organizacional_outros_id"=>"", "unidade_organizacional_multa_id"=>"", "nome_conta_contabil_multa"=>"", "data_da_baixa"=>"03/09/2009"}

    assert_difference 'Movimento.count', 2 do
      assert_difference 'ItensMovimento.count', 4 do
        conta.parcelas.first.baixar_parcela(2009, conta.usuario_corrente, params)
        conta.parcelas.last.baixar_parcela(2009, conta.usuario_corrente, params)
      end
    end

    params_reneg = {"numero_de_parcelas" => "2", "vigencia" => "2", "dia_do_vencimento" => "20", "data_inicio" => "20/07/2009", "valor_do_documento_em_reais" => "90,00"}
    
    assert_difference 'Parcela.count', 2 do
      conta.renegociar(params_reneg)
    end

    Movimento.count.should == 2
    ItensMovimento.count.should == 4

  end

  it 'testa da funcao cancelar_contrato' do
    usuario = usuarios(:quentin)
    recebimento = recebimento_de_contas(:curso_de_design_do_paulo)

    # assert_difference 'HistoricoOperacao', 3 do
    recebimento.cancelar_contrato(usuario).should == true
    # end

    recebimento.situacao.should == RecebimentoDeConta::Cancelado
    recebimento.situacao_fiemt.should == RecebimentoDeConta::Inativo
    recebimento.cancelado_pela_situacao_fiemt.should == true

    recebimento.parcelas.each do |parcela|
      parcela.situacao.should == Parcela::CANCELADA
      parcela.cancelado_pelo_contrato.should == true
    end
  end

  it 'testa da funcao cancelar_contrato' do
    usuario = usuarios(:quentin)
    recebimento = recebimento_de_contas(:curso_de_design_do_paulo)

    # Carregando e cancelando
    primeira_parcela_do_contrato = recebimento.parcelas.first
    primeira_parcela_do_contrato.situacao = Parcela::CANCELADA
    primeira_parcela_do_contrato.save.should == true

    recebimento.parcelas.each_with_index do |parcela, i|
      i == 0 ? parcela.situacao.should == Parcela::CANCELADA : parcela.situacao.should == Parcela::PENDENTE
      parcela.cancelado_pelo_contrato.should == nil
    end

    # assert_difference 'HistoricoOperacao', 3 do
    recebimento.cancelar_contrato(usuario).should == true
    # end

    recebimento.situacao.should == RecebimentoDeConta::Cancelado
    recebimento.situacao_fiemt.should == RecebimentoDeConta::Inativo
    recebimento.cancelado_pela_situacao_fiemt.should == true

    recebimento.parcelas.each do |parcela|
      parcela.situacao.should == Parcela::CANCELADA
      parcela.cancelado_pelo_contrato.should == true
    end
  end

  it 'testa a funcao estornar_contrato' do
    usuario = usuarios(:quentin)
    recebimento = recebimento_de_contas(:curso_de_design_do_paulo)

    # assert_difference 'HistoricoOperacao', 3 do
    recebimento.cancelar_contrato(usuario).should == true
    # end

    # assert_difference 'HistoricoOperacao', 3 do
    recebimento.estornar_contrato(usuario).should == true
    # end

    recebimento.situacao.should == RecebimentoDeConta::Normal
    recebimento.situacao_fiemt.should == RecebimentoDeConta::Normal
    recebimento.cancelado_pela_situacao_fiemt.should == nil

    recebimento.parcelas.each do |parcela|
      parcela.situacao.should == Parcela::PENDENTE
      parcela.cancelado_pelo_contrato.should == nil
    end
    
  end

  describe "testa o método Atribuir Situação e Atribui Situação Parcela" do

    it "verifica NORMAL" do
      recebimento = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.gerar_parcelas(2009)
      recebimento.atribui_situacao_parcela(RecebimentoDeConta::Normal)
      recebimento.parcelas.collect(&:situacao).should == [Parcela::PENDENTE, Parcela::PENDENTE, Parcela::PENDENTE]
    end

    it "verifica JURIDICO" do
      recebimento = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.gerar_parcelas(2009)
      recebimento.atribui_situacao_parcela(RecebimentoDeConta::Juridico)
      recebimento.parcelas.collect(&:situacao).should == [Parcela::JURIDICO, Parcela::JURIDICO, Parcela::JURIDICO]
    end

    it "verifica PERMUTA" do
      recebimento = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.gerar_parcelas(2009)
      recebimento.atribui_situacao_parcela(RecebimentoDeConta::Permuta)
      recebimento.parcelas.collect(&:situacao).should == [Parcela::PERMUTA, Parcela::PERMUTA, Parcela::PERMUTA]
    end

    it "verifica BAIXA DO CONSELHO" do
      recebimento = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.gerar_parcelas(2009)
      recebimento.atribui_situacao_parcela(RecebimentoDeConta::Baixa_do_conselho)
      recebimento.parcelas.collect(&:situacao).should == [Parcela::BAIXA_DO_CONSELHO, Parcela::BAIXA_DO_CONSELHO, Parcela::BAIXA_DO_CONSELHO]
    end

    it "verifica DESCONTO EM FOLHA" do
      recebimento = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      recebimento.usuario_corrente = usuarios(:quentin)
      recebimento.gerar_parcelas(2009)
      recebimento.atribui_situacao_parcela(RecebimentoDeConta::Desconto_em_folha)
      recebimento.parcelas.collect(&:situacao).should == [Parcela::DESCONTO_EM_FOLHA, Parcela::DESCONTO_EM_FOLHA, Parcela::DESCONTO_EM_FOLHA]
    end

  end

  describe "Verifica Clientes Inadimplentes" do

    def gerar_mais_contratos_com_parcelas_vencidas
      rc = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_no_proximo_mes)
      rc.usuario_corrente = @quentin
      rc.gerar_parcelas(2009)
      rc.parcelas.first.data_vencimento = '2005-05-05'
      rc.parcelas.first.save
      rc.save
      rc = recebimento_de_contas(:curso_de_design_do_paulo_onde_as_parcelas_vencerao_proximo_ano)
      rc.usuario_corrente = @quentin
      rc.gerar_parcelas(2009)
      parcelas = rc.parcelas
      parcelas[0].data_vencimento = '2010-10-10'
      parcelas[1].data_vencimento = '2010-05-05'
      parcelas[2].data_vencimento = '2011-11-11'
      parcelas.each(&:save)
      rc.save
    end

    before :each do
      gerar_mais_contratos_com_parcelas_vencidas
    end
    it "Deve pesquisar todos Clientes inadimplentes até a Data Atual"  do
      contas = RecebimentoDeConta.pesquisa_clientes_inadimplentes :all, unidades(:senaivarzeagrande).id, "cliente_id" => "","periodo_max" => "", "periodo_min" => ""
      resposta = contas.collect {|conta| [conta.numero_de_controle, conta.parcelas.collect(&:data_vencimento)]}
      #      resposta.sort.should == [["SVG-CPMF09/09762444", ["05/07/2009", "05/08/2009"]], ["SVG-CTR09/09000777", ["05/05/2005", "01/06/2009"]], ["SVG-CTR09/09000798", ["05/07/2005"]]]
      resposta.sort.should == [["SVG-CPMF09/09762444", ["05/07/2009", "05/08/2009"]], ["SVG-CTR09/09000777", ["05/05/2005", "01/06/2009"]], ["SVG-CPMF09/09111555", ["05/05/2010"]]].sort
    end

    it "Deve pesquisar o Cliente inadimplente filtrado pelo seu id" do
      contas = RecebimentoDeConta.pesquisa_clientes_inadimplentes :all, unidades(:senaivarzeagrande).id, "cliente_id" => pessoas(:paulo).id,"periodo_max" => "", "periodo_min" => ""
      resposta = contas.collect {|conta| [conta.numero_de_controle,conta.parcelas.collect(&:data_vencimento)]}
      resposta.sort.should == [["SVG-CPMF09/09762444", ["05/07/2009", "05/08/2009"]], ["SVG-CTR09/09000777", ["05/05/2005", "01/06/2009"]], ["SVG-CPMF09/09111555", ["05/05/2010"]]].sort
    end

    it "Deve pesquisar todos Clientes inadimplentes por intervalo de vencimento" do
      contas = RecebimentoDeConta.pesquisa_clientes_inadimplentes :all, unidades(:senaivarzeagrande).id,"cliente_id" => "","periodo_max" => "01/01/2011", "periodo_min" => "01/01/2008"
      resposta = contas.collect {|conta| [conta.numero_de_controle,conta.parcelas.collect(&:data_vencimento)]}
      resposta.sort.should == [["SVG-CPMF09/09111555", ["05/05/2010"]], ["SVG-CPMF09/09762444", ["05/07/2009", "05/08/2009"]], ["SVG-CTR09/09000777", ["01/06/2009"]]].sort
    end

    it "Deve pesquisar todos Clientes inadimplentes até 2008" do
      contas = RecebimentoDeConta.pesquisa_clientes_inadimplentes :all, unidades(:senaivarzeagrande).id,"cliente_id" => "","periodo_max" => "31/12/2008", "periodo_min" => ""
      resposta = contas.collect {|conta| [conta.numero_de_controle,conta.parcelas.collect(&:data_vencimento)]}
      #      resposta.sort.should == [["SVG-CTR09/09000777", ["05/05/2005"]], ["SVG-CTR09/09000798", ["05/07/2005"]]].sort
      resposta.sort.should == [["SVG-CTR09/09000777", ["05/05/2005"]]].sort
    end

    it "Deve pesquisar todos Clientes inadimplentes depois de 2009" do
      contas = RecebimentoDeConta.pesquisa_clientes_inadimplentes :all, unidades(:senaivarzeagrande).id,"cliente_id" => "","periodo_max" => "", "periodo_min" => "01/01/2010"
      resposta = contas.collect {|conta| [conta.numero_de_controle,conta.parcelas.collect(&:data_vencimento)]}
      resposta.sort.should == [["SVG-CPMF09/09111555", ["05/05/2010"]]].sort
    end
  end

  it 'destroi os agendamentos caso a conta seja destruida' do
    #    compromisso = compromissos(:ligar_para_o_cliente)
    #    conta = recebimento_de_contas(:curso_de_corel_do_paulo)
    #    conta.compromissos.should include compromisso
    #    conta.parcelas.each{ |parcela| parcela.update_attributes(:situacao => Parcela::PENDENTE) }
    #    lambda do
    #      lambda do
    #        conta.destroy
    #      end.should change(RecebimentoDeConta, :count).by(-1)
    #    end.should change(Compromisso, :count).by(-2)
  end

  it 'nao destroi as contas caso os agendamentos sejam destruidos' do
    compromisso = compromissos(:ligar_para_o_cliente)
    conta = recebimento_de_contas(:curso_de_corel_do_paulo)
    conta.compromissos.should include compromisso
    lambda do
      lambda do
        compromisso.destroy
      end.should change(Compromisso, :count).by(-1)
    end.should_not change(RecebimentoDeConta, :count)
  end

  describe "Envio ao DR/Terceirizada" do

    it 'testa pesquisa sem passar datas' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.envio_para_dr IS NULL AND recebimento_de_contas.envio_para_terceirizada IS NULL AND parcelas.situacao = ? AND parcelas.data_vencimento < ?', unidades(:senaivarzeagrande).id, Parcela::PENDENTE, Date.today], :include => [:parcelas]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_por_datas_e_parcelas_atrasadas unidades(:senaivarzeagrande).id, {}
    end

    it 'testa pesquisa passando data inicial' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.envio_para_dr IS NULL AND recebimento_de_contas.envio_para_terceirizada IS NULL AND parcelas.situacao = ? AND parcelas.data_vencimento < ? AND recebimento_de_contas.data_inicio >= ?', unidades(:senaivarzeagrande).id, Parcela::PENDENTE, Date.today, '01/01/2000'.to_date], :include => [:parcelas]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_por_datas_e_parcelas_atrasadas unidades(:senaivarzeagrande).id, {:data_inicial => '01/01/2000'}
    end

    it 'testa pesquisa passando data inicial' do
      RecebimentoDeConta.should_receive(:all).with(:conditions => ['recebimento_de_contas.unidade_id = ? AND recebimento_de_contas.envio_para_dr IS NULL AND recebimento_de_contas.envio_para_terceirizada IS NULL AND parcelas.situacao = ? AND parcelas.data_vencimento < ? AND recebimento_de_contas.data_inicio >= ? AND recebimento_de_contas.data_inicio <= ?', unidades(:senaivarzeagrande).id, Parcela::PENDENTE, Date.today, '01/01/2000'.to_date, '01/01/2010'.to_date], :include => [:parcelas]).and_return([])
      @actual = RecebimentoDeConta.pesquisa_por_datas_e_parcelas_atrasadas unidades(:senaivarzeagrande).id, {:data_inicial => '01/01/2000', :data_final => '01/01/2010'}
    end

    def hash_simulacao
      {:ids => [recebimento_de_contas(:curso_de_tecnologia_do_andre).id, recebimento_de_contas(:curso_de_design_do_paulo).id], :dr_ou_terceirizada => RecebimentoDeConta::DR}
    end

    def hash_simulacao_terceirizada
      {:ids => [recebimento_de_contas(:curso_de_tecnologia_do_andre).id, recebimento_de_contas(:curso_de_design_do_paulo).id], :dr_ou_terceirizada => RecebimentoDeConta::TERCEIRIZARA}
    end

    it 'testa funcao que trata para envio ao dr/terceirizada' do
      usuario = usuarios(:quentin)
      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, hash_simulacao).should == [recebimento_de_contas(:curso_de_tecnologia_do_andre), recebimento_de_contas(:curso_de_design_do_paulo)]
    end

    it 'testa funcao que trata para envio ao dr e verifica suas parcelas' do
      usuario = usuarios(:quentin)
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [conta.id], :dr_ou_terceirizada => RecebimentoDeConta::DR}).should == [conta]

      conta.reload

      conta.envio_para_dr.should == true
      conta.envio_para_terceirizada.should == false

      parcela_modificada = Parcela.first(:conditions => ['conta_id = ? AND data_vencimento = ?', conta.id, '05/07/2009'.to_date])
      parcela_modificada.situacao.should == Parcela::CANCELADA
    end

    it 'testa funcao que trata para envio a terceirizada e verifica suas parcelas' do
      usuario = usuarios(:quentin)
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [conta.id], :dr_ou_terceirizada => RecebimentoDeConta::TERCEIRIZADA}).should == [conta]

      conta.reload

      conta.envio_para_dr.should == false
      conta.envio_para_terceirizada.should == true

      parcela_modificada = Parcela.first(:conditions => ['conta_id = ? AND data_vencimento = ?', conta.id, '05/07/2009'.to_date])
      parcela_modificada.situacao.should == Parcela::CANCELADA
    end

    it 'testa funcao que trata para envio a terceirizada e verifica suas parcelas e em seguida chama a funcao denovo' do
      usuario = usuarios(:quentin)
      conta = recebimento_de_contas(:curso_de_design_do_paulo)
      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [conta.id], :dr_ou_terceirizada => RecebimentoDeConta::TERCEIRIZADA}).should == [conta]

      conta.reload

      conta.envio_para_dr.should == false
      conta.envio_para_terceirizada.should == true

      parcela_modificada = Parcela.first(:conditions => ['conta_id = ? AND data_vencimento = ?', conta.id, '05/07/2009'.to_date])
      parcela_modificada.situacao.should == Parcela::CANCELADA

      assert_no_difference 'HistoricoOperacao.count' do
        RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [conta.id], :dr_ou_terceirizada => RecebimentoDeConta::TERCEIRIZADA}).should == []
      end

    end

    it 'testa a funcao, re-gerando o envio' do
      usuario = usuarios(:quentin)
      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [recebimento_de_contas(:curso_de_tecnologia_do_andre).id], :dr_ou_terceirizada => RecebimentoDeConta::DR, :data_inicial => '20/06/2008', :data_final => '12/05/2009'}).should == [recebimento_de_contas(:curso_de_tecnologia_do_andre)]

      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [recebimento_de_contas(:curso_de_design_do_paulo).id], :dr_ou_terceirizada => RecebimentoDeConta::DR, :data_inicial => '20/06/2008', :data_final => '10/03/2010'}).should == [recebimento_de_contas(:curso_de_tecnologia_do_andre), recebimento_de_contas(:curso_de_design_do_paulo)]
    end

    it 'testa a funcao, re-gerando o envio porem para destinos diferentes' do
      usuario = usuarios(:quentin)
      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [recebimento_de_contas(:curso_de_tecnologia_do_andre).id], :dr_ou_terceirizada => RecebimentoDeConta::DR, :data_inicial => '20/06/2008', :data_final => '12/05/2009'}).should == [recebimento_de_contas(:curso_de_tecnologia_do_andre)]

      RecebimentoDeConta.carrega_recebimentos_para_envio(usuario, unidades(:senaivarzeagrande).id, {:ids => [recebimento_de_contas(:curso_de_design_do_paulo).id], :dr_ou_terceirizada => RecebimentoDeConta::TERCEIRIZADA, :data_inicial => '20/06/2008', :data_final => '10/03/2010'}).should == [recebimento_de_contas(:curso_de_design_do_paulo)]
    end

  end

  it 'se a pessoa tiver parcelas atrasadas em outros contratos e nao tiver sido liberada pelo dr nao podera gerar outro contrato e se puder, devera gerar followup' do
    lambda do
      jansen = pessoas(:jansen)
      jansen.liberado_pelo_dr.should be_false
      jansen.cliente = true

      rc_a_salvar = RecebimentoDeConta.new @valid_attributes
      rc_a_nao_salvar = RecebimentoDeConta.new @valid_attributes

      rc_a_salvar.unidade    = rc_a_nao_salvar.unidade    = unidades(:senaivarzeagrande)
      rc_a_salvar.centro     = rc_a_nao_salvar.centro     = centros(:centro_forum_economico)
      rc_a_salvar.dependente = rc_a_nao_salvar.dependente = nil
      rc_a_salvar.ano        = rc_a_nao_salvar.ano        = 2009
      rc_a_salvar.pessoa     = rc_a_nao_salvar.pessoa     = jansen
      rc_a_salvar.data_inicio_servico    = rc_a_nao_salvar.data_inicio_servico     = "01/06/2010"
      rc_a_salvar.data_final_servico     = rc_a_nao_salvar.data_final_servico      = "01/09/2010"


      lambda do
        curso_design = recebimento_de_contas(:curso_de_design_do_paulo)
        curso_design.resumo_de_parcelas_atrasadas.to_s.should match(%r{\.*[\d{2}\/\d{2}\/\d{4}13000]{2}\.*})

        parcela = curso_design.parcelas.first.clone
        parcela.data_vencimento = Time.new.yesterday
        parcela.save.should be_true

        jansen.tem_parcelas_atrasadas?.should be_false

        rc_a_salvar.parcelas << parcela
        rc_a_salvar.save!.should be_true

        jansen.tem_parcelas_atrasadas?.should be_true

        rc_a_nao_salvar.save.should be_false
        rc_a_nao_salvar.errors.full_messages.should == ["O cliente #{jansen.nome.upcase} possui parcelas atrasadas #{jansen.unidade_parcelas_atrasadas} e por isso não pode ter outro contrato cadastrado. Consulte o DR para realizar a liberação."]

        jansen.liberado_pelo_dr = true
      end.should change(HistoricoOperacao,:count).by(1)

      rc_a_nao_salvar.save.should be_true

      jansen.liberado_pelo_dr.should be_false
    end.should change(HistoricoOperacao,:count).by(2)
  end

  it 'após cadastrar um novo contrato liberado_pelo_dr deve voltar a false' do
    felipe = pessoas(:felipe)
    felipe.liberado_pelo_dr = true
    felipe.save.should be_true
    rc = RecebimentoDeConta.new @valid_attributes
    rc.dependente = nil
    rc.unidade = unidades(:senaivarzeagrande)
    rc.centro = centros(:centro_forum_economico)
    rc.ano = 2009
    rc.pessoa = felipe
    rc.data_inicio_servico = "01/06/2009"
    rc.data_final_servico = "01/09/2009"
    rc.save!.should be_true
    felipe.liberado_pelo_dr.should be_false
    felipe.changed?.should be_false #se foi salvo
  end

  it 'pessoa bloqueada não pode cadastrar fazer nenhum contrato sem ser liberado' do
    rc = RecebimentoDeConta.new @valid_attributes
    pessoa = pessoas(:paulo)
    rc.dependente = nil
    rc.unidade = unidades(:senaivarzeagrande)
    rc.centro = centros(:centro_forum_economico)
    rc.ano = 2009
    rc.pessoa = pessoa
    rc.save.should be_false
    rc.errors.full_messages.should include("O cliente #{pessoa.nome.upcase} possui parcelas atrasadas #{pessoa.unidade_parcelas_atrasadas} e por isso não pode ter outro contrato cadastrado. Consulte o DR para realizar a liberação.")
    pessoa.liberado_pelo_dr = true
    pessoa.save.should be_true
  end

  #  it 'deve apenas permitir ser alterado para Enviado_ao_DR uma vez' do
  #    rc = RecebimentoDeConta.find recebimento_de_contas(:curso_de_design_do_paulo).id
  #    rc.situacao_fiemt=RecebimentoDeConta::Inativo
  #    rc.save.should be_true
  #    rc.situacao_fiemt=RecebimentoDeConta::Normal
  #    rc.save.should be_true
  #    rc.situacao_fiemt=RecebimentoDeConta::Enviado_ao_DR
  #    rc.save.should be_true
  #    rc.situacao_fiemt=RecebimentoDeConta::Normal
  #    rc.save.should be_false
  #    rc.errors.on(:situacao_fiemt).should == 'não pode ser modificado por estar como Enviado ao DR'
  #  end

  #  it 'deve apenas permitir ser alterado para Devedores_Duvidosos_Ativos uma vez' do
  #    rc = RecebimentoDeConta.find recebimento_de_contas(:curso_de_design_do_paulo).id
  #    rc.situacao_fiemt=RecebimentoDeConta::Inativo
  #    rc.save.should be_true
  #    rc.situacao_fiemt=RecebimentoDeConta::Normal
  #    rc.save.should be_true
  #    rc.situacao_fiemt=RecebimentoDeConta::Devedores_Duvidosos_Ativos
  #    rc.save.should be_true
  #    rc.situacao_fiemt=RecebimentoDeConta::Normal
  #    rc.save.should be_false
  #    rc.errors.on(:situacao_fiemt).should == 'não pode ser modificado por estar como Perdas no Recebimento de Creditos - Clientes'
  #  end

  it 'apos a mudanca de situacao_fiemt para Enviado_ao_DR' do
    rc = RecebimentoDeConta.find recebimento_de_contas(:curso_de_design_do_paulo).id
    rc.parcelas.collect(&:situacao).should == [Parcela::PENDENTE,Parcela::PENDENTE]
    rc.situacao.should == RecebimentoDeConta::Normal
    rc.situacao_fiemt = RecebimentoDeConta::Enviado_ao_DR
    rc.save.should be_true
    rc.parcelas.collect(&:situacao).should == [Parcela::CANCELADA,Parcela::CANCELADA]
    rc.situacao.should == RecebimentoDeConta::Inativo
  end

  it 'apos a mudanca de situacao_fiemt para Devedores_Duvidosos_Ativos' do
    rc = RecebimentoDeConta.find recebimento_de_contas(:curso_de_design_do_paulo).id
    rc.parcelas.collect(&:situacao).should == [Parcela::PENDENTE,Parcela::PENDENTE]
    rc.situacao.should == RecebimentoDeConta::Normal
    rc.situacao_fiemt = RecebimentoDeConta::Devedores_Duvidosos_Ativos
    rc.save.should be_true
    rc.parcelas.collect(&:situacao).should == [Parcela::CANCELADA,Parcela::CANCELADA]
    rc.situacao.should == RecebimentoDeConta::Inativo
  end

  it 'testa liberação pelo DR do recebimento de conta' do
    unidade = unidades(:senaivarzeagrande)
    unidade.lancamentoscontaspagar = 1
    unidade.lancamentoscontasreceber = 1
    unidade.lancamentosmovimentofinanceiro = 1
    unidade.save

    r = recebimento_de_contas(:curso_de_design_do_paulo)
    r.validar_data_inicio.should == false    
    r.valid?.should == false

    r.numero_nota_fiscal = 99999999
    r.liberacao_dr_faixa_de_dias_permitido = true
    r.save.should == true
    r.reload

    r.liberacao_dr_faixa_de_dias_permitido.should == false
  end
  
end
