require File.dirname(__FILE__) + '/../spec_helper'

describe Gefin do

  describe 'deve calcular juros e multas corretamente e' do

    it 'deve retornar zero se estiver um dia adiantado' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.today, :data_base => Date.yesterday, :valor => 100000,
        :juros => 1, :multa => 2).should == [0, 0, 100000]
    end

    it 'deve retornar zero se estiver no prazo' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.today, :data_base => Date.today, :valor => 200000,
        :juros => 1, :multa => 2).should == [0, 0, 200000]
    end

    it 'deve retornar multa e juros proporcionais a 28 dias se estiver com um dia de atraso' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.new(2009, 2, 20), :data_base => Date.new(2009, 2, 21),
        :valor => 100000, :juros => 1, :multa => 2).should == [36, 2000, 102036]
    end

    it 'deve retornar multa e juros arredondando' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.new(2009, 2, 20), :data_base => Date.new(2009, 2, 21),
        :valor => 33333, :juros => 1, :multa => 2).should == [12, 667, 34012]
    end

    it 'deve retornar multa e juros passando data como string' do
      Gefin.calcular_juros_e_multas(:vencimento => '20/02/2009', :data_base => '21/02/2009',
        :valor => 100000, :juros => 1, :multa => 2).should == [36, 2000, 102036]
    end

    it 'deve retornar multa e juros proporcionais a 28 dias se estiver com 20 dias de atraso' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.new(2009, 1, 31), :data_base => Date.new(2009, 2, 20),
        :valor => 100000, :juros => 5, :multa => 5).should == [3705, 5000, 108705]
    end

    it 'deve retornar multa e juros proporcionais a 31 dias se estiver com 1 mês de atraso' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.new(2008, 12, 31), :data_base => Date.new(2009, 1, 31),
        :valor => 100000, :juros => 5, :multa => 5).should == [5250, 5000, 110250]
    end

    it 'deve retornar multa e juros proporcionais a 31 dias se estiver com 1 ano de atraso' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.new(2008, 12, 31), :data_base => Date.new(2009, 12, 31),
        :valor => 100000, :juros => 5, :multa => 5).should == [83565, 5000, 188565]
    end

    it 'deve retornar multa e juros proporcionais a 31 dias se estiver com 1 ano de atraso com juros e multas quebradas' do
      Gefin.calcular_juros_e_multas(:vencimento => Date.new(2008, 12, 31), :data_base => Date.new(2009, 12, 31),
        :valor => 100000, :juros => 5.5, :multa => 5.5).should == [95077, 5500, 200577]
    end
  end

  describe "testes da geração de números de controles" do

    it "verifica se gera a sequência correta" do
      RecebimentoDeConta.delete_all
      movimento = Movimento.new :tipo_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :tipo_lancamento => "E", :historico => "Teste", :pessoa => pessoas(:felipe)
      movimento.save!
      movimento.numero_de_controle.should == "SENAI-VG-CPMF#{Date.today.strftime("%m/%y")}0001"

      recebimento = RecebimentoDeConta.new :usuario_corrente => usuarios(:quentin),
        :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "12345", :pessoa => pessoas(:paulo),
        :servico => servicos(:curso_de_tecnologia), :dia_do_vencimento => 1,
        :valor_do_documento => 1000, :numero_de_parcelas => 1, :vigencia => 1,
        :rateio => 1, :historico => "Teste", :origem => 1,
        :conta_contabil_receita => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), 
        :data_inicio_servico => "2009/06/01", :data_final_servico => "2009/07/01"
      recebimento.ano = 2009
      recebimento.save!
      recebimento.numero_de_controle.should == "SENAI-VG-CPMF#{Date.today.strftime("%m/%y")}0002"

      pagamento = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
        :tipo_de_documento => "CPMF", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 1, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 1000, :numero_de_parcelas => 1, :rateio => 1,
        :historico => "Teste", :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :ano => 2009
      pagamento.save!
      pagamento.numero_de_controle.should == "SENAI-VG-CPMF#{Date.today.strftime("%m/%y")}0003"


      movimento_dois = Movimento.new :tipo_documento => "CTREV", :unidade => unidades(:senaivarzeagrande),
        :tipo_lancamento => "E", :historico => "Teste", :pessoa => pessoas(:felipe)
      movimento_dois.save!
      movimento_dois.numero_de_controle.should == "SENAI-VG-CTREV#{Date.today.strftime("%m/%y")}0001"

      recebimento_dois = RecebimentoDeConta.new :usuario_corrente => usuarios(:quentin),
        :tipo_de_documento => "NTS", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "12345", :pessoa => pessoas(:paulo),
        :servico => servicos(:curso_de_tecnologia), :dia_do_vencimento => 1,
        :valor_do_documento => 1000, :numero_de_parcelas => 1, :vigencia => 1,
        :rateio => 1, :historico => "Teste", :origem => 1,
        :conta_contabil_receita => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico),
        :data_inicio_servico => "2009/06/01", :data_final_servico => "2009/07/01"
      recebimento_dois.ano = 2009
      recebimento_dois.save!
      recebimento_dois.numero_de_controle.should == "SENAI-VG-NTS#{Date.today.strftime("%m/%y")}0001"

      pagamento_dois = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
        :tipo_de_documento => "RPA", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "54321", :pessoa => pessoas(:inovare),
        :provisao => 1, :conta_contabil_despesa => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :valor_do_documento => 1000, :numero_de_parcelas => 1, :rateio => 1,
        :historico => "Teste", :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico), :ano => 2009
      pagamento_dois.save!
      pagamento_dois.numero_de_controle.should == "SENAI-VG-RPA#{Date.today.strftime("%m/%y")}0001"
    end

    it "teste quando não gera numero de controle" do
      pagamento = PagamentoDeConta.new :usuario_corrente => usuarios(:quentin),
        :tipo_de_documento => "RPA", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => ""
      pagamento.save false
      pagamento.numero_de_controle.should_not == "SENAI-VG-RPA#{Date.today.strftime("%m/%y")}0001"
    end

    it "teste quando gera numero de controle na sequencia com NTS" do
      recebimento = recebimento_de_contas(:curso_de_tecnologia_do_paulo)
      RecebimentoDeConta.delete_all("id!=#{recebimento.id}")
      recebimento.numero_de_controle = "SENAI-VG-NTS#{Date.today.strftime("%m/%y")}0001"
      recebimento.save!
      recebimento_dois = RecebimentoDeConta.new :usuario_corrente => usuarios(:quentin),
        :tipo_de_documento => "NTS", :unidade => unidades(:senaivarzeagrande),
        :numero_nota_fiscal => "12345", :pessoa => pessoas(:paulo),
        :servico => servicos(:curso_de_tecnologia), :dia_do_vencimento => 1,
        :valor_do_documento => 1000, :numero_de_parcelas => 1, :vigencia => 1,
        :rateio => 1, :historico => "Teste", :origem => 1,
        :conta_contabil_receita => plano_de_contas(:plano_de_contas_ativo_contribuicoes),
        :unidade_organizacional => unidade_organizacionais(:senai_unidade_organizacional),
        :centro => centros(:centro_forum_economico),
        :data_inicio_servico => "2009/06/01", :data_final_servico => "2009/07/01"
      recebimento_dois.ano = 2009
      recebimento_dois.save!
      recebimento_dois.numero_de_controle.should == "SENAI-VG-NTS#{Date.today.strftime("%m/%y")}0002"
    end

  end

  describe "testes da importação das entidades" do

    it "importa as entidades do arquivo e as unidades que forem validas" do
      Gefin.stubs(:puts)
      Agencia.delete_all
      Banco.delete_all
      Centro.delete_all
      ContasCorrente.delete_all
      Dependente.delete_all
      Entidade.delete_all
      Historico.delete_all
      Imposto.delete_all
      ItensMovimento.delete_all
      Localidade.delete_all
      Movimento.delete_all
      PagamentoDeConta.delete_all
      Parcela.delete_all
      Pessoa.delete_all
      PlanoDeConta.delete_all
      Rateio.delete_all
      RecebimentoDeConta.delete_all
      Servico.delete_all
      Unidade.delete_all
      UnidadeOrganizacional.delete_all
      Usuario.delete_all

      entidades ||= {}
      localidades ||= {}
      unidades ||= {}
    
      arquivo = RAILS_ROOT + "/test/importacao_entidades"

      entidade = Entidade.create! :codigo_zeus => '111', :nome => 'Entidade Nome Teste', :sigla => 'Entidade Sigla Teste'

      unidade = Unidade.create! :nome => "Teste", :sigla => "TES", :nome_caixa_zeus => "TEST",
        :endereco => "Teste", :telefone => ["2321-3213"], :cnpj => "65.400.887/0001-50",
        :entidade => entidade, :senha_baixa_dr => 'teste', :limitediasparaestornodeparcelas => 5000

      assert_difference 'ItensMovimento.count', 4 do # 6 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
        assert_difference 'Movimento.count', 15 do # 17 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
          assert_difference 'Rateio.count', 6 do # 8 VÁLIDOS NO ARQUIVO SENDO 3 REPETIDOS
            assert_difference 'Parcela.count', 24 do # X VÁLIDAS NO ARQUIVO SENDO Y REPETIDAS
              assert_difference 'PagamentoDeConta.count', 7 do # 9 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
                assert_difference 'RecebimentoDeConta.count', 10 do # 15 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
                  assert_difference 'Usuario.count', 5 do # 7 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
                    assert_difference 'Historico.count', 12 do # 14 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
                      assert_difference 'ContasCorrente.count', 5 do # 7 VÁLIDAS NO ARQUIVO SENDO 2 REPETIDAS
                        assert_difference 'Imposto.count', 11 do # 14 VÁLIDOS NO ARQUIVO SENDO 3 REPETIDOS
                          assert_difference 'PlanoDeConta.count', 68 do # 70 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
                            assert_difference 'Centro.count', 40 do # 42 VÁLIDOS NO ARQUIVO SENDO 2 REPETIDOS
                              assert_difference 'Servico.count', 10 do # 10 VÁLIDOS NO ARQUIVO SENDO 0 REPETIDOS
                                assert_difference 'Dependente.count', 3 do # 4 VÁLIDOS NO ARQUIVO SENDO 1 REPETIDO
                                  assert_difference 'Pessoa.count', 22 do # 14 CLIENTES VÁL (2 REP); 7 FUNCIONÁRIOS VÁL (1 REP); 6 FORNECEDORES VÁL (2 REP)
                                    assert_difference 'Agencia.count', 5 do # 6 VÁLIDAS NO ARQUIVO SENDO 1 REPETIDA
                                      assert_difference 'Banco.count', 19 do # 20 VÁLIDOS NO ARQUIVO SENDO 1 REPETIDO
                                        assert_difference 'UnidadeOrganizacional.count', 32 do # 33 VÁLIDAS NO ARQUIVO SENDO 1 REPETIDA
                                          assert_difference 'Unidade.count', 4 do # 5 VÁLIDAS NO ARQUIVO SENDO 1 REPETIDA
                                            assert_difference 'Entidade.count', 7 do # 8 VÁLIDAS NO ARQUIVO SENDO 1 REPETIDA
                                              assert_difference 'Localidade.count', 20 do # 21 VÁLIDAS NO ARQUIVO SENDO 1 REPETIDA
                                                Gefin.importacao_entidades_localidades_unidades(arquivo, entidades, localidades, unidades)
                                                Gefin.importacao(arquivo, unidade, entidades, localidades, unidades)
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      agencia = Agencia.last
      banco = Banco.last
      centro = Centro.last
      centro_dois = Centro.all[11]
      cliente_fis = Pessoa.last :conditions => ["(cliente = ?) AND (tipo_pessoa = ?)", true, Pessoa::FISICA]
      cliente_jur = Pessoa.last :conditions => ["(cliente = ?) AND (tipo_pessoa = ?)", true, Pessoa::JURIDICA]
      conta_corrente = ContasCorrente.last
      dependente = Dependente.last
      fornecedor_fis = Pessoa.last :conditions => ["(fornecedor = ?) AND (tipo_pessoa = ?)", true, Pessoa::FISICA]
      fornecedor_jur = Pessoa.last :conditions => ["(fornecedor = ?) AND (tipo_pessoa = ?)", true, Pessoa::JURIDICA]
      funcionario = Pessoa.last :conditions => ["(funcionario = ?)", true]
      historico = Historico.last
      imposto = Imposto.last
      item_movimento = ItensMovimento.last
      localidade = Localidade.last
      movimento = Movimento.last
      pagamento_de_conta = PagamentoDeConta.last
      parcela = Parcela.last
      plano_de_conta = PlanoDeConta.last
      rateio = Rateio.last
      recebimento_de_conta = RecebimentoDeConta.last
      servico = Servico.last
      servico_dois = Servico.all[5]
      unidade_dois = Unidade.last
      unidade_organizacional = UnidadeOrganizacional.last
      usuario = Usuario.last

      # Unidade
      unidade_dois.nome.should == "SESIESCOLA  VARZEA GRANDE"
      unidade_dois.sigla.should == "SESIESCOLA-VG"

      # Entidade
      unidade_dois.entidade.should == Entidade.all[2]
      unidade_dois.entidade.nome.should == "SERVIÇO SOCIAL DA INDÚSTRIA NO ESTADO DE MT"
      unidade_dois.entidade.sigla.should == "SESI-DR-MT"
      unidade_dois.entidade.codigo_zeus.should == 213

      # Serviço
      servico.unidade.should == Unidade.all[3]
      servico.unidade.nome.should == "SESI CLUBE VARZEA GRANDE"
      servico.unidade.sigla.should == "SESICLUBE-VG"
      servico.descricao.should == "ARRENDAMENTOS"

      servico_dois.unidade.should == Unidade.all[4]
      servico_dois.unidade.nome.should == "SESIESCOLA  VARZEA GRANDE"
      servico_dois.unidade.sigla.should == "SESIESCOLA-VG"
      servico_dois.descricao.should == "EDUCACAO"

      # Unidade Organizacional
      unidade_organizacional.entidade.should == Entidade.all[1]
      unidade_organizacional.entidade.nome.should == "SERVIÇO NACIONAL DE APRENDIZAGEM INDUSTRIA NO MT"
      unidade_organizacional.nome.should == "CFP MELVIN JONES"
      unidade_organizacional.ano.should == 2005
      unidade_organizacional.codigo_da_unidade_organizacional.should == "13010302"
      unidade_organizacional.codigo_reduzido.should == "00019"

      # Centro
      centro.entidade.should == Entidade.all[4]
      centro.entidade.nome.should == "CONDOMÍNIO CASA DA INDÚSTRIA NO ESTADO DE MT"
      centro.nome.should == "FINANCEIRO"
      centro.ano.should == 2005
      centro.codigo_centro.should == "50202"
      centro.codigo_reduzido.should == "00029"

      # CENTRO <=> UNIDADE ORGANIZACIONAL (8 ASSOCIAÇÕES VÁLIDAS NO ARQUIVO SENDO 4 REPETIDAS)
      centro_dois.entidade.should == Entidade.all[2]
      centro_dois.entidade.nome.should == "SERVIÇO SOCIAL DA INDÚSTRIA NO ESTADO DE MT"
      centro_dois.nome.should == "Academia"
      centro_dois.ano.should == 2007
      centro_dois.codigo_centro.should == "30302020302"
      centro_dois.codigo_reduzido.should == "00263"
      centro_dois.unidade_organizacionais.should == [UnidadeOrganizacional.all[8], UnidadeOrganizacional.all[11]]

      # LOCALIDADE
      localidade.nome.should == "BOM JESUS DO ARAGUAIA"
      localidade.uf.should == "MT"

      # PLANO DE CONTAS
      plano_de_conta.ano.should == 2009
      plano_de_conta.entidade.should == entidade
      plano_de_conta.codigo_contabil.should == "11030399125"
      plano_de_conta.nome.should == "Regina de Fatima Alves Souza"
      plano_de_conta.nivel.should == 6
      plano_de_conta.ativo.should == 0
      plano_de_conta.tipo_da_conta.should == 1
      plano_de_conta.codigo_reduzido.should == "5504"

      # BANCO
      banco.descricao.should == "BANCO DO BRASIL SA"
      banco.ativo.should == true
      banco.codigo_do_banco.should == "001"
      banco.codigo_do_zeus.should == ""
      banco.digito_verificador.should == "9"

      # AGÊNCIA
      agencia.nome.should == "CAIXA ESC VG"
      agencia.numero.should == "001"
      agencia.digito_verificador == "1"
      agencia.endereco.should == "a"
      agencia.bairro.should == "a"
      agencia.complemento.should == ""
      agencia.telefone.should == "6"
      agencia.fax.should == "6"
      agencia.email.should == "fiemt@fiemt.com.br"
      agencia.nome_contato.should == "a"
      agencia.telefone_contato.should == "6"
      agencia.email_contato.should == "a"
      agencia.ativo.should == true
      agencia.localidade.should == Localidade.all[12]
      agencia.localidade.nome.should == "VARZEA GRANDE"
      agencia.localidade.uf.should == "MT"
      agencia.banco.should == Banco.all[14]
      agencia.banco.ativo.should == true
      agencia.banco.descricao.should == "TESOURARIA"
      agencia.banco.codigo_do_banco.should == "00000"
      agencia.banco.codigo_do_zeus.should == ""
      agencia.banco.digito_verificador.should == "0"
      agencia.cidade.should == ""
      agencia.cep.should == "78055500"

      # CLIENTE - PESSOA FÍSICA
      cliente_fis.cliente.should == true
      cliente_fis.nome.should == "ALVARO ROMEIRO"
      cliente_fis.cpf.numero.should == "792.787.958-87"
      cliente_fis.tipo_pessoa.should == Pessoa::FISICA
      cliente_fis.endereco.should == "RUA B, QD. 06, CASA 02 - VILA SADIA"
      cliente_fis.email.should == []
      cliente_fis.telefone.should == ["(   )   -"]
      cliente_fis.bairro.should == "CRISTO REI"
      cliente_fis.localidade.should == Localidade.all[12]
      cliente_fis.localidade.nome.should == "VARZEA GRANDE"
      cliente_fis.localidade.uf.should == "MT"
      cliente_fis.spc.should == false
      cliente_fis.complemento.should == ""
      cliente_fis.cep.should == "78150000"
      cliente_fis.entidade.should == entidade

      # CLIENTE - PESSOA JURÍDICA
      cliente_jur.cliente.should == true
      cliente_jur.nome.should == "SESI - SERVICO SOCIAL DA INDUS"
      cliente_jur.cnpj.numero.should == "03.819.157/0005-65"
      cliente_jur.razao_social.should == "SESI - SERVICO SOCIAL DA INDUSTRIA - VG"
      cliente_jur.contato.should == "ALAN KARDEC"
      cliente_jur.tipo_pessoa.should == Pessoa::JURIDICA
      cliente_jur.endereco.should == "R.DOM ORLANDO CHAVES N.1086"
      cliente_jur.email.should == []
      cliente_jur.telefone.should == ["6536852311", "6536852311"]
      cliente_jur.bairro.should == "CRISTO REI"
      cliente_jur.localidade.should == Localidade.all[12]
      cliente_jur.localidade.nome.should == "VARZEA GRANDE"
      cliente_jur.localidade.uf.should == "MT"
      cliente_jur.spc.should == false
      cliente_jur.complemento.should == ""
      cliente_jur.cep.should == "78115830"
      cliente_jur.entidade.should == entidade

      # FUNCIONÁRIO
      funcionario.funcionario.should == true
      funcionario.nome.should == "CLEONICE MARQUES LEAL"
      funcionario.matricula.should == "45360"
      funcionario.email.should == ["contabilsenai@senaimt.com.br"]
      funcionario.telefone.should == ["3611-1602"]
      funcionario.cpf.numero.should == "689.532.591-34"
      funcionario.cargo.should == "TECNICO DE APOIO"
      funcionario.endereco.should == "."
      funcionario.entidade.should == Entidade.all[1]
      funcionario.entidade.nome.should == "SERVIÇO NACIONAL DE APRENDIZAGEM INDUSTRIA NO MT"
      funcionario.entidade.sigla.should == "SENAI-DR-MT"
      funcionario.entidade.codigo_zeus.should == 313
      funcionario.funcionario_ativo.should == false
      funcionario.tipo_pessoa.should == Pessoa::FISICA

      # FORNECEDOR - PESSOA FÍSICA
      fornecedor_fis.fornecedor.should == true
      fornecedor_fis.cpf.numero.should == "453.203.491-49"
      fornecedor_fis.nome.should == "BENEDITO RAMON GUSMÃO PEREZ"
      fornecedor_fis.email.should == []
      fornecedor_fis.endereco.should == "RUA COLUMBIA, 629"
      fornecedor_fis.bairro.should == "SANTA ROSA II"
      fornecedor_fis.complemento.should == "A"
      fornecedor_fis.localidade.should == Localidade.all[16]
      fornecedor_fis.localidade.nome.should == "CUIABÁ"
      fornecedor_fis.localidade.uf.should == "MT"
      fornecedor_fis.cep.should == "78040000"
      fornecedor_fis.telefone.should == ["36261130"]
      fornecedor_fis.entidade.should == entidade
      fornecedor_fis.tipo_pessoa.should == Pessoa::FISICA
      fornecedor_fis.agencia.should == Agencia.all[1]
      fornecedor_fis.agencia.nome.should == "AG. EMPRESARIAL.."
      fornecedor_fis.agencia.numero.should == "4205"
      fornecedor_fis.agencia.digito_verificador.should == "6"
      fornecedor_fis.banco.should == Banco.all[18]
      fornecedor_fis.banco.descricao.should == "BANCO DO BRASIL SA"
      fornecedor_fis.banco.codigo_do_banco.should == "001"
      fornecedor_fis.banco.digito_verificador.should == "9"
      fornecedor_fis.tipo_da_conta.should == ""
      fornecedor_fis.conta.should == "5245"

      # FORNECEDOR - PESSOA JURIDICA
      fornecedor_jur.fornecedor.should == true
      fornecedor_jur.cnpj.numero.should == "04.688.630/0001-51"
      fornecedor_jur.razao_social.should == "MARQUES & ASSUNÇAO LTDA - ME"
      fornecedor_jur.nome.should == "AUTO PEÇAS CIDADE ALTA"
      fornecedor_jur.email.should == []
      fornecedor_jur.endereco.should == "AV. JORNALISTA ALVES OLIVEIRA"
      fornecedor_jur.bairro.should == "CIDADE ALTA"
      fornecedor_jur.complemento.should == ""
      fornecedor_jur.localidade.should == Localidade.all[13]
      fornecedor_jur.localidade.nome.should == "CUIABA"
      fornecedor_jur.localidade.uf.should == "MT"
      fornecedor_jur.cep.should == "78030360"
      fornecedor_jur.telefone.should == ["3637-2010/ 2120"]
      fornecedor_jur.entidade.should == entidade
      fornecedor_jur.contato.should == ""
      fornecedor_jur.tipo_pessoa.should == Pessoa::JURIDICA
      fornecedor_jur.agencia.should == Agencia.all[0]
      fornecedor_jur.agencia.nome.should == "AGÊNCIA PRAINHA"
      fornecedor_jur.agencia.numero.should == "1569"
      fornecedor_jur.agencia.digito_verificador.should == "0"
      fornecedor_jur.banco.should == Banco.all[3]
      fornecedor_jur.banco.descricao.should == "Caixa Econômica Federal"
      fornecedor_jur.banco.codigo_do_banco.should == ""
      fornecedor_jur.banco.digito_verificador.should == ""
      fornecedor_jur.tipo_da_conta.should == ""
      fornecedor_jur.conta.should == ""

      # DEPENDENTE
      dependente.nome.should == "VITORIA MARTINS DE CARVALHO"
      dependente.nome_do_pai.should == "OSMAR DE CARVALHO"
      dependente.nome_da_mae.should == "CÉLIA MARTINS PEREIRA DE CARVALHO"
      dependente.codccr.should == 22
      dependente.pessoa.should == Pessoa.all[6]
      dependente.pessoa.nome.should == "OSMAR DE CARVALHO"
      dependente.pessoa.cpf.numero.should == "430.066.201-00"

      # IMPOSTO
      imposto.descricao.should == "INSS - PJ - 11%"
      imposto.sigla.should == "INSS - PJ - 11%"
      imposto.aliquota.should == 11
      imposto.classificacao.should == Imposto::RETEM
      imposto.conta_debito.should == nil
      imposto.conta_credito.should == PlanoDeConta.all[58]
      imposto.tipo.should == Imposto::FEDERAL

      # CONTA CORRENTE
      conta_corrente.agencia.should == Agencia.all[1]
      conta_corrente.agencia.nome.should == "AG. EMPRESARIAL.."
      conta_corrente.conta_contabil.should == PlanoDeConta.all[25]
      conta_corrente.conta_contabil.nome.should == "B. Brasil - 9392-0 - Escola V. Grande"
      conta_corrente.unidade.should == Unidade.all[4]
      conta_corrente.unidade.nome.should == "SESIESCOLA  VARZEA GRANDE"
      conta_corrente.ativo.should == true
      conta_corrente.numero_conta.should == "9392"
      conta_corrente.digito_verificador.should == "0"
      conta_corrente.descricao.should == "CONTA ARRECADACAO BB"
      conta_corrente.identificador.should == 1
      conta_corrente.data_abertura.should == "01/05/2008"
      conta_corrente.data_encerramento.should == nil
      conta_corrente.saldo_inicial.should == 82
      conta_corrente.saldo_atual.should == -1048288
      conta_corrente.tipo.should == 1

      # HISTÓRICO
      historico.descricao.should == "IEL - INSTITUTO EUVALDO LODI"
      historico.entidade.should == entidade
      historico.entidade.nome.should == "Entidade Nome Teste"

      # USUÁRIO
      usuario.login.should == "keila"
      usuario.unidade.should == unidade
      usuario.funcionario.should == Pessoa.all[16]
      usuario.funcionario.nome.should == "EUSMAR AQUINO DE SANTANA"
      usuario.perfil.should == Perfil.all[1]
      usuario.perfil.descricao.should == "Gerente"

      # RECEBIMENTO DE CONTA
      recebimento_de_conta.data_inicio.should == "13/08/2009"
      recebimento_de_conta.data_final.should == "13/09/2009"
      recebimento_de_conta.vigencia.should == 1
      recebimento_de_conta.situacao_fiemt.should == 7
      recebimento_de_conta.numero_nota_fiscal.should == "EVG-OR08/090045"
      recebimento_de_conta.numero_de_parcelas.should == 1
      recebimento_de_conta.valor_do_documento.should == 35
      recebimento_de_conta.numero_de_renegociacoes.should == 0
      recebimento_de_conta.dia_do_vencimento.should == 1
      recebimento_de_conta.rateio.should == 0
      recebimento_de_conta.tipo_de_documento.should == "OR"
      recebimento_de_conta.numero_de_controle.should == "EVG-OR08/090045"
      recebimento_de_conta.historico.should == "VLR REF. RECEBIMENTO  - MATERIAL DIDATICO - SESI - SERVICO SOCIAL DA INDUSTRIA - VG - EDUCACAO"
      recebimento_de_conta.data_venda.should == "13/08/2009"
      recebimento_de_conta.origem.should == 1
      recebimento_de_conta.centro.should == Centro.all[36]
      recebimento_de_conta.cobrador.should == nil
      recebimento_de_conta.conta_contabil_receita.should == PlanoDeConta.all[51]
      recebimento_de_conta.dependente.should == nil
      recebimento_de_conta.pessoa.should == Pessoa.all[11]
      recebimento_de_conta.servico.should == Servico.all[5]
      recebimento_de_conta.unidade.should == Unidade.all[4]
      recebimento_de_conta.unidade_organizacional.should == UnidadeOrganizacional.all[3]
      recebimento_de_conta.vendedor.should == nil
      
      # PAGAMENTO DE CONTA
      pagamento_de_conta.data_emissao.should == "31/07/2009"
      pagamento_de_conta.data_lancamento.should == "13/08/2009"
      pagamento_de_conta.numero_nota_fiscal.should == 391
      pagamento_de_conta.valor_do_documento.should == 250
      pagamento_de_conta.numero_de_parcelas.should == 1
      pagamento_de_conta.rateio.should == 0
      pagamento_de_conta.tipo_de_documento.should == "NFS"
      pagamento_de_conta.numero_de_controle.should == "EVG-NFS08/090004"
      pagamento_de_conta.historico.should == "VLR REF NFS Nº 391 - JOAO GABRIEL GUIZZO - EPP - CAPAS E CONTRA CAPAS P/ ENCADERNAÇÃO APOSTILAS DO PROJETO EBEP"
      pagamento_de_conta.primeiro_vencimento.should == "13/08/2009"
      pagamento_de_conta.centro.should == Centro.all[1]
      pagamento_de_conta.conta_contabil_despesa.should == PlanoDeConta.all[63]
      pagamento_de_conta.conta_contabil_pessoa.should == PlanoDeConta.all[66]
      pagamento_de_conta.pessoa.should == Pessoa.all[15]
      pagamento_de_conta.provisao.should == 1
      pagamento_de_conta.unidade.should == Unidade.all[4]
      pagamento_de_conta.unidade_organizacional.should == UnidadeOrganizacional.all[3]

      # PARCELA
      parcela.data_vencimento.should == "06/10/2008"
      parcela.valor.should == 1987
      parcela.numero.should == 1
      parcela.data_da_baixa.should == "06/10/2008"
      parcela.valor_liquido.should == 1987
      parcela.historico.should == "VLR REF NFS Nº12.102  - DIARIO DE CUIABA LTDA - (REF. A PERMUTA MENSALIDADES - ALUNO BRUNO BIRAL - ANO LETIVO 2006 RESP. ROBERTA G. BIRAL)"
      parcela.forma_de_pagamento.should == 1
      parcela.conta_corrente_id.should == nil
      parcela.numero_do_comprovante.should == nil
      parcela.observacoes.should == "PERMUTA DIARIO DE CUIABA"
      parcela.data_do_pagamento.should == nil
      parcela.conta_id.should == nil
      parcela.conta_type.should == "PagamentoDeConta"
      parcela.recibo_impresso.should == nil
      parcela.situacao.should == 1
      parcela.valor_da_multa.should == 0
      parcela.valor_dos_juros.should == 0
      parcela.valor_do_desconto.should == 0
      parcela.outros_acrescimos.should == 0
      parcela.justificativa_para_outros.should == ""
      parcela.conta_contabil_multa_id.should == nil
      parcela.unidade_organizacional_multa_id.should == nil
      parcela.centro_multa_id.should == nil
      parcela.conta_contabil_juros_id.should == nil
      parcela.unidade_organizacional_juros_id.should == nil
      parcela.centro_juros_id.should == nil
      parcela.conta_contabil_outros_id.should == nil
      parcela.unidade_organizacional_outros_id.should == nil
      parcela.centro_outros_id.should == nil
      parcela.conta_contabil_desconto_id.should == nil
      parcela.unidade_organizacional_desconto_id.should == nil
      parcela.centro_desconto_id.should == nil

      # RATEIO
      rateio.unidade_organizacional.should == UnidadeOrganizacional.all[3]
      rateio.centro.should == Centro.all[36]
      rateio.valor.should == 35
      rateio.parcela.should == Parcela.all[0]
      rateio.conta_contabil.should == PlanoDeConta.all[51]

      # MOVIMENTO

      movimento.tipo_documento.should == "OR"
      movimento.tipo_lancamento.should == "E"
      movimento.data_lancamento.should == "17/04/2008"
      movimento.historico.should == "VLR REF. DEPOSITO BANCARIO EM 17/04/2008  - SESICLUBE VARZEA GRANDE"
      movimento.numero_de_controle.should == "SSVG-OR04/080035"
      movimento.provisao.should == Movimento::SIMPLES
      movimento.pessoa.should == Pessoa.all[11]
      movimento.unidade.should == Unidade.all[3]
      movimento.valor_total.should == 1731
      movimento.conta.should == RecebimentoDeConta.all[1]
      movimento.numero_da_parcela.should == nil
      movimento.parcela.should == nil

      # ITEM MOVIMENTO
      item_movimento.valor.should == 1539
      item_movimento.centro.should == Centro.all[12]
      item_movimento.movimento.should == Movimento.last
      item_movimento.unidade_organizacional.should == UnidadeOrganizacional.all[12]
      item_movimento.plano_de_conta.should == PlanoDeConta.all[56]
      item_movimento.tipo.should == "C"
    end

    it "verifica se gera os erros" do
      Centro.delete_all
      Entidade.delete_all
      Pessoa.delete_all
      Servico.delete_all
      Unidade.delete_all
      UnidadeOrganizacional.delete_all

      entidades ||= {}
      localidades ||= {}
      unidades ||= {}

      arquivo = RAILS_ROOT + "/test/importacao_entidades_errada"

      entidade = Entidade.create! :codigo_zeus => '111', :nome => 'Entidade Teste', :sigla => 'TESTE'

      unidade = Unidade.create! :nome => "Teste", :sigla => "TES", :nome_caixa_zeus => "TEST",
        :endereco => "Teste", :telefone => ["2321-3213"], :cnpj => "65.400.887/0001-50",
        :entidade => entidade, :senha_baixa_dr => 'teste', :limitediasparaestornodeparcelas => 5000

      assert_difference 'Centro.count', 0 do
        assert_difference 'UnidadeOrganizacional.count', 3 do
          assert_difference 'Servico.count', 0 do
            assert_difference 'Pessoa.count', 0 do
              assert_difference 'Unidade.count', 0 do
                assert_difference 'Entidade.count', 1 do
                  Gefin.importacao_entidades_localidades_unidades(arquivo, entidades, localidades, unidades)
                  Gefin.importacao(arquivo, unidade, entidades, localidades, unidades)
                end
              end
            end
          end
        end
      end
    end

  end

  #  describe "testes da importação de clientes" do
  #
  #    it "verifica se lê o arquivo e grava 5 pessoas" do
  #      # O ARQUIVO TEM 5 REGISTROS CORRETOS, TODOS COM PESSOA FÍSICA
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_teste_1"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 5 do
  #        Gefin.importacao(arquivo, unidade)
  #      end
  #      pessoa = Pessoa.first
  #      pessoa.cpf.numero.should == "389.711.359-72"
  #      pessoa.nome.should == "ELIZABETH ANHOLETO"
  #      pessoa.tipo_pessoa.should == Pessoa::FISICA
  #      pessoa.email.should == []
  #      pessoa.endereco.should == "AV. PRES. ARTHUR BERNARDES, QD-15"
  #      pessoa.bairro.should == "AP-A02JD. AEROPORTO"
  #      pessoa.complemento.should == ""
  #      pessoa.localidade_id.should == 0
  #      pessoa.cep.should == ""
  #      pessoa.telefone.should == []
  #      pessoa.cliente.should == true
  #      pessoa.spc.should == false
  #      pessoa.entidade_id.should == unidade.entidade_id
  #    end
  #
  #    it "verifica se le o arquivo e grava 1 pessoa jurídica" do
  #      # O ARQUIVO TEM 7 REGISTROS CORRETOS, GRAVANDO TODOS NO FINAL, SENDO OS 2 ÚLTIMOS
  #      # PESSOA JURÍDICA
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_teste_2"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 7 do
  #        Gefin.importacao(arquivo, unidade)
  #      end
  #      pessoa = Pessoa.last
  #      pessoa.cnpj.numero.should == "33.641.358/0109-72"
  #      pessoa.razao_social.should == "SESI - SINOP"
  #      pessoa.endereco.should == "AV. JACARANDAS, 3100"
  #      pessoa.bairro.should == ""
  #      pessoa.complemento.should == ""
  #      pessoa.localidade_id.should == 0
  #      pessoa.cep.should == ""
  #      pessoa.telefone.should == []
  #      pessoa.email.should == []
  #      pessoa.contato.should == ""
  #      pessoa.nome.should == ""
  #      pessoa.cliente.should == true
  #      pessoa.spc.should == false
  #      pessoa.entidade_id.should == unidade.entidade_id
  #    end
  #
  #    it "verifica se le o arquivo e gera exceção de pessoa fisica" do
  #      # O ARQUIVO TEM 3 REGISTROS, SENDO O ÚLTIMO COM CPF INVÁLIDO --> 000.000.000-00
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_erro_fisica"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 2 do
  #        Gefin.importacao(arquivo, unidade)
  #      end
  #
  #    end
  #
  #    it "verifica se le o arquivo e gera exceções com 6 registros inválidos" do
  #      # O ARQUIVO TEM 280 REGISTROS, SENDO 6 COM DADOS ERRADOS, COMO CPF OU CNPJ INVÁLIDOS,
  #      # OU COM A FALTA DO ENDEREÇO
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_teste"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 274 do
  #        Gefin.importacao(arquivo, unidade)
  #      end
  #    end
  #
  #    it "verifica se le o arquivo e converte para UTF-8" do
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_caracteres"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 13 do
  #        Gefin.importacao(arquivo, unidade).should == "5222203\tVILA BOA\tGO\n5222302\tVILA PROPICIO\tGO\n5300108\tBRASILIA\tDF\n1111111\tSANTO ANTONIO DO LESTE\tMT\n0000000\tSÃO PAULO\tSP\n\\.\n\n\n--\n-- TOC entry 2548 (class 0 OID 37576)\n-- Dependencies: 1569\n-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: admin\n--\n\nCOPY cliente (codcli, idcli, identcli, emailpes, endres, bairrores, compres, codcidres, cepres, telres, telcel, endcom, bairrocom, compcom, codcidcom, cepcom, telcom, emailcom, nomcont, telcont, emailcont, tipocli, atraso, spc, fantasia) FROM stdin;\n19264\t389.711.359-72    \tELIZABETH ANHOLETO\t\tAV. PRES. ARTHUR BERNARDES, QD-15\tAP-A02JD. AEROPORTO\t\t\\N\t        \t                \t                \t\t\t\t\\N\t        \t                \t\t\\N\t\\N\t\\N\tF\t0\tN\t\\N\n19265\t453.114.041-91    \tLUIZ RODRIGUES SOUZA\t\tAV. HI, Q. 6, C. 3\tLOTEAM. HELIO P. ARRUDA\t\t\\N\t78155530\t                \t                \t\t\t\t\\N\t        \t                \t\t\\N\t\\N\t\\N\tF\t0\tN\t\\N\n19266\t240.817.011-72    \tBENEDITO GONCALVES DE SOUZA\t\tR. MOURITE, 120\tPEDREGAL\t\t\\N\t78000000\t                \t                \t\t\t\t\\N\t        \t                \t\t\\N\t\\N\t\\N\tF\t0\tN\t\\N\n19267\t469.185.401-06    \tVANILDO DE MELLO FILHO\t\tR. DR. JONAS DA COSTA, 387\tVERDAO\t\t\\N\t78030510\t                \t                \t\t\t\t\\N\t        \t                \t\t\\N\t\\N\t\\N\tF\t0\tN\t\\N\n19268\t346.389.701-68    \tORCINO XAVIER DA COSTA\t\tR. MARAJO, 179\tPEDREGAL\t\t\\N\t        \t                \t                \t\t\t\t\\N\t        \t                \t\t\\N\t\\N\t\\N\tF\t0\tN\t\\N\n44447\t07.605.738/0001-21\tF. J. FERNANDES - ME\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\tRUA 01, QD. 13,  N.07-B - SETOR 2\tCPAIII\t\t5103403\t7800000 \t3646-4044       \t\tFABIANA\t3646-4044       \t\tJ\t0\tN\tCANTINA\n27339\t33.641.358/0109.72\tSESI - SINOP\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\tAV. JACARANDAS, 3100\t\t\t\\N\t        \t                \t\t\t                \t\tJ\t1\tN\t\\N\n39205\t43.217.850/0002-30\tIOB INFORMAÇÕES OBJETIVAS PUBLICAÇÕES JURIDICAS\t\t \t\t\t\\N\t        \t                \t                \tRUA CORREIA DIAS, 2º ANDAR 184\tPARAISO\tSAO PAULO\t120    \t79050010\t67 342-3300     \t\tSUMAIA KERSROUANI BORGES\t08007837777     \t\tJ\t0\tN\t\\N\n42850\t00.831.964/0001-81\tH PRINT REPROGRAFIA E AUTOMAÇÃO DE ESCRITORIO\t\t \t\t\t\\N\t        \t                \t                \tAV. 31 DE MARÇO 1826\tDUQUE DE CAXIAS\t\t5      \t78040000\t3616-7435       \tx\tX\tX               \tx\tJ\t0\tN\t\\N\n36562\t06.053.377/0001-95\tRABISCOS COMERCIO E SERVIÇOS DE PAPELARIA LTDA\t\t \t\t\t\\N\t        \t                \t                \tAV. CORONEL ESCOLASTICO 592\tBANDEIRANTES\t\t5      \t78010200\t3025-5255       \t\tF\t3025-5255       \t\tJ\t0\tN\t\\N\n42898\t00.482.913/0001-91\tSISAN CONST E INCORPORAÇÃO LTDA\t\t \t\t\t\\N\t        \t                \t                \tRUA BARAO DE MELGAÇO 3080\tCENTRO\t\t5      \t78000000\t                \t\t.......\t..........      \t\tJ\t0\tN\t\\N\n38307\t40.281.347/0012-27\tAUTOTRAC COMERCIO E TELECOMUNICAÇÕES S/A\t\t \t\t\t\\N\t        \t                \t                \tAV FERNANDO CORREA DA COSTA 7141\tCOXIPO DA PONTE\t\t5103403\t78080300\t665-5188        \t\tXX\t661-7100        \t\tJ\t0\tN\t\\N\n28318\t14.952.766/0001.80\tESC. DE 1§ GRAU\"O PEQUENO PRINCIPE\"\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\t\\N\tRUA LIBERDADE 457\tCENTRO\t\t\\N\t78600000\t0658611269      \t\tNEUZA MŠ GUIMARAES\t0658611269      \t\tJ\t0\tN\t\\N\n\\.\n\n\n--\n-- TOC entry 2548 (class 0 OID 37576)\n-- Dependencies: 1569\n-- Data for Name: cliente; Type: TABLE DATA; Schema: public; Owner: admin\n--\n"
  #      end
  #    end
  #
  #    it "executa 2 arquivos diferentes e só grava registro quando ele está certo" do
  #      # O ARQUIVO 1 TEM 280 REGISTROS, SENDO 6 COM DADOS ERRADOS, COMO CPF OU CNPJ INVÁLIDOS,
  #      # OU COM A FALTA DO ENDEREÇO
  #      # O ARQUIVO 2 TEM 5 REGISTROS, SENDO TODOS VÁLIDOS, E O PRIMEIRO É UM DOS QUE ESTÃO COM
  #      # PROBLEMA NO ARQUIVO 1.
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_teste"
  #      arquivo_dois = RAILS_ROOT + "/test/importacao_clientes/clientes_teste_1"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 275 do
  #        Gefin.importacao(arquivo, unidade)
  #        Gefin.importacao(arquivo_dois, unidade)
  #      end
  #    end
  #
  #    it "executa o mesmo arquivo 2 vezes e só grava na primeira vez" do
  #      # O ARQUIVO 1 TEM 280 REGISTROS, SENDO 6 COM DADOS ERRADOS, COMO CPF OU CNPJ INVÁLIDOS,
  #      # OU COM A FALTA DO ENDEREÇO
  #      # O ARQUIVO 2 TEM 5 REGISTROS, SENDO TODOS VÁLIDOS, E O PRIMEIRO É UM DOS QUE ESTÃO COM
  #      # PROBLEMA NO ARQUIVO 1.
  #      Pessoa.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_clientes/clientes_teste"
  #      arquivo_dois = RAILS_ROOT + "/test/importacao_clientes/clientes_teste"
  #      unidade = unidades(:sesivarzeagrande)
  #      assert_difference 'Pessoa.count', 274 do
  #        Gefin.importacao(arquivo, unidade)
  #        Gefin.importacao(arquivo_dois, unidade)
  #      end
  #    end
  #
  #  end

  #  describe "Testa importação de serviços" do
  #
  #    it "importando todos os serviços" do
  #      Servico.delete_all
  #      arquivo = RAILS_ROOT + "/test/importacao_servicos/servicos_teste_1"
  #      unidade = unidades(:senaivarzeagrande)
  #      assert_difference 'Servico.count', 41 do
  #        Gefin.importacao(arquivo, unidade)
  #      end
  #      servico = Servico.last
  #      servico.ativo.should == true
  #      servico.codigo_do_servico_sigat.should == "01"
  #      servico.descricao.should == "ARRENDAMENTOS"
  #      servico.modalidade.should == "Outros"
  #      servico.unidade.should == Unidade.first # VERIFICAR!
  #    end
  #
  #  end
  #
  #    describe "Testa importação de unidades" do
  #
  #      it "importando todas as unidades" do
  #        arquivo = RAILS_ROOT + "/test/importacao_unidades/unidades_teste_1"
  #        unidade = unidades(:sesivarzeagrande)
  #        assert_difference 'Unidade.count', 4 do
  #          Gefin.importacao(arquivo, unidade)
  #        end
  #        unidd = Unidade.last
  #        unidd.ativa.should == true
  #        unidd.bairro.should == "CRISTO REI"
  #        unidd.cep.should == "78115530"
  #        unidd.cnpj.numero.should == "03.819.157/0005-65"
  #        unidd.complemento.should == ""
  #        unidd.data_de_referencia.should == "30/12/1899"
  #        unidd.email.should == "sesiescolavg@sesimt.com.br"
  #        unidd.endereco.should == "AV. DOM ORLANDO CHAVES 1086"
  #        unidd.entidade.should == Entidade.first # VERIFICAR!
  #        unidd.fax.should == "65"
  #        unidd.lancamentoscontaspagar.should == 5
  #        unidd.lancamentoscontasreceber.should == 5
  #        unidd.lancamentosmovimentofinanceiro.should == 5
  #        unidd.localidade_id.should == 5108402
  #        unidd.nome.should == "SESIESCOLA  VARZEA GRANDE"
  #        unidd.nome_caixa_zeus.should == "CX-ESCVG"
  #        unidd.sigla.should == "SESIESCOLA-VG"
  #        unidd.telefone.should == ["(65) 685-2311"]
  #      end
  #
  #    end

end
