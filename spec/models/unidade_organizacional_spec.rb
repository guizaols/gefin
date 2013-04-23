require File.dirname(__FILE__) + '/../spec_helper'

describe UnidadeOrganizacional do
  before(:each) do
    @unidade_organizacional = UnidadeOrganizacional.new
  end
  
  it 'deve importar arquivo do Gefin' do
    UnidadeOrganizacional.delete_all
    Centro.delete_all

    #Importação de Unidades Organizacionais    
    lambda do
      arq_com_unidades = File.open(RAILS_ROOT + '/test/importacao/t_undorg_2009.txt')
      retorno_unidade = UnidadeOrganizacional.importar_unidades_organizacionais(arq_com_unidades)
      retorno_unidade.first.should == true
      retorno_unidade.last.should == "Foram importadas 27 unidades organizacionais!"
    end.should change(UnidadeOrganizacional, :count).by(27)

    u = UnidadeOrganizacional.last
    u.ano.should == 2009
    u.entidade.should == entidades(:senai)
    u.codigo_da_unidade_organizacional.should == '9999999999'
    u.nome.should == 'UNIDADE EMPRESA'
    u.codigo_reduzido.should == '00032'

    lambda do
      arq_com_unidades_organizacionais = File.open(RAILS_ROOT + '/test/importacao/t_undorg_2009.txt')
      UnidadeOrganizacional.importar_unidades_organizacionais(arq_com_unidades_organizacionais)
    end.should_not change(UnidadeOrganizacional, :count)

    #Importação de Centros
    
    lambda do
      arq_com_centros = File.open(RAILS_ROOT + '/test/importacao/t_centro_2009.txt')
      retorno_centro = Centro.importar_centros(arq_com_centros)
      retorno_centro.first.should == true
      retorno_centro.last.should == "Foram importados 100 Centros!"
    end.should change(Centro, :count).by(100)

    u = Centro.last
    u.ano.should == 2009
    u.entidade.should == entidades(:senai)
    u.codigo_centro.should == '308040104'
    u.nome.should == "Atividades Fisicas"
    u.codigo_reduzido.should == '00392'

    lambda do
      segundo_arq_com_centros = File.open(RAILS_ROOT + '/test/importacao/t_centro_2009.txt')
      Centro.importar_centros(segundo_arq_com_centros)
    end.should_not change(Centro, :count)

    #Importação do relacionamento entre centros e unidades organizacionais
    arq_com_relacionamentos = File.open(RAILS_ROOT + '/test/importacao/t_Centro_undorg_2009.txt')
    retorno_unid_centro = Centro.importar_relacionamentos_entre_centros_e_unidades_organizacionais(arq_com_relacionamentos)
    retorno_unid_centro.first.should == true
    retorno_unid_centro.last.should == "Foram importados 942 Unidades Organizacionais x Centros!"
    
    u = Centro.find_by_codigo_centro '30202010101'
    u.unidade_organizacionais.collect(&:codigo_da_unidade_organizacional).sort.should == ['13030113', '1303010801', '1303010803', '13030110'].sort

    segundo_arq_com_relaciomentos = File.open(RAILS_ROOT + '/test/importacao/t_Centro_undorg_2009.txt')
    Centro.importar_relacionamentos_entre_centros_e_unidades_organizacionais(segundo_arq_com_relaciomentos)

    u = Centro.find_by_codigo_centro '30202010101'
    u.unidade_organizacionais.collect(&:codigo_da_unidade_organizacional).sort.should == ['13030113', '1303010801', '1303010803', '13030110'].sort
  end

  it "should be valid" do
    @unidade_organizacional.should be_valid
  end
  
  it "teste de relacionamento" do
    unidade_org = unidade_organizacionais(:sesi_colider_unidade_organizacional)
    unidade_org.parcelas.should == [parcelas(:primeira_parcela)]
    unidade_org.rateios.should == rateios(:segundo_rateio_primeira_parcela,:rateio_primeira_parcela,:rateio_segunda_parcela)
    unidade_org.centros.sort_by(&:id).should == centros(:centro_forum_social_2008,:centro_forum_social_2010,:centro_forum_social_2011,:centro_forum_social,:centro_forum_social_2012,:centro_forum_social_2013,:centro_forum_social_2014,:centro_forum_social_2015,:centro_forum_social_2016).sort_by(&:id)
    unidade_org.entidade.should == entidades(:sesi)
    unidade_org.pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque_outra_unidade, :pagamento_dinheiro_outra_unidade_mesmo_ano, :pagamento_banco_outra_unidade, :pagamento_dinheiro_outra_unidade_outro_ano)
    unidade_organizacionais(:senai_unidade_organizacional).pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque, :pagamento_dinheiro)
    unidade_organizacionais(:senai_unidade_organizacional).centros.sort_by(&:id).should == centros( :centro_forum_economico, :centro_forum_financeiro).sort_by(&:id)
    unidade_organizacionais(:sesi_colider_unidade_organizacional).objeto_do_proximo_ano.should == unidade_organizacionais(:sesi_colider_unidade_organizacional_2010)
  end

  it 'deve retornar descricao' do
    unidade_organizacionais(:sesi_colider_unidade_organizacional).resumo.should == '1303010803 - SESI COLIDER'
  end
  
  it "Verifica se ao salvar objeto, certifica se o objeto do proximo ano tem o ano igual ao ano do objeto + 1 " do
    unidadeorganizacional = UnidadeOrganizacional.new :ano => 2010, :entidade => entidades(:senai) , :codigo_da_unidade_organizacional => 4567456344, :nome => "Senai Matriz", :codigo_reduzido => '15'
    unidade_validada = unidade_organizacionais(:senai_unidade_organizacional)
    unidade_validada.objeto_do_proximo_ano = unidadeorganizacional
    unidade_validada.ano.should == unidadeorganizacional.ano - 1
    unidade_validada.entidade.should == unidadeorganizacional.entidade
    unidade_validada.save.should == true
  end
  
  it "Verifica se ao salvar objeto, certifica se o objeto nao consegue ser salvo ao tentar atribuir um centro que nao tenha o ano correto " do
    unidadeorganizacional = UnidadeOrganizacional.new :ano => 2011, :entidade => entidades(:senai) , :codigo_da_unidade_organizacional => 4567456344, :nome => "Senai Matriz", :codigo_reduzido => '15'
    unidade_validada = unidade_organizacionais(:senai_unidade_organizacional)
    unidade_validada.objeto_do_proximo_ano = unidadeorganizacional
    unidade_validada.entidade.should == unidadeorganizacional.entidade
    unidade_validada.save.should == false
    unidade_validada.errors.on(:ano).should == "O objeto do proximo ano deve ter ano válido."
  end
   
  it "Verifica se ao salvar objeto, certifica se o objeto nao consegue ser salvo ao tentar atribuir um centro que nao tenha a mesma entidade " do
    unidadeorganizacional = UnidadeOrganizacional.new :ano => 2010, :entidade => entidades(:sesi) , :codigo_da_unidade_organizacional => 4567456344, :nome => "Senai Matriz", :codigo_reduzido => '15'
    unidade_validada = unidade_organizacionais(:senai_unidade_organizacional)
    unidade_validada.objeto_do_proximo_ano = unidadeorganizacional
    unidade_validada.ano.should == unidadeorganizacional.ano - 1
    unidade_validada.save.should == false
    unidade_validada.errors.on(:entidade).should == "O objeto do proximo ano deve ter entidade válida." 
  end

  it "unidade com objeto rastreavel" do
    unidade = unidade_organizacionais(:sesi_colider_unidade_organizacional_2010)
    unidade.pesquisar_correspondente_no_ano_de(2011).should == unidade_organizacionais(:sesi_colider_unidade_organizacional_2011)
  end

  it "unidade de mesmo código sem objeto rastreavel" do
    unidade = unidade_organizacionais(:sesi_colider_unidade_organizacional_2011)
    unidade.pesquisar_correspondente_no_ano_de(2012).should == unidade_organizacionais(:sesi_colider_unidade_organizacional_2012)
  end
  
end
