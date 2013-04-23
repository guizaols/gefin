require File.dirname(__FILE__) + '/../spec_helper'

describe Centro do
  
  fixtures :all
  
  it "teste de relacionamento" do
    centros(:centro_forum_social).entidade.should == entidades(:sesi)
    centros(:centro_forum_social).rateios.should == rateios(:segundo_rateio_primeira_parcela,:rateio_primeira_parcela,:rateio_segunda_parcela)
    centros(:centro_forum_social).parcelas.should == [parcelas(:primeira_parcela)]
    centros(:centro_forum_economico).entidade.should == entidades(:senai)
    centros(:centro_forum_social).pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque_outra_unidade, :pagamento_dinheiro_outra_unidade_mesmo_ano, :pagamento_banco_outra_unidade, :pagamento_dinheiro_outra_unidade_outro_ano)
    centros(:centro_forum_economico).pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque, :pagamento_dinheiro)
    centros(:centro_forum_social).unidade_organizacionais.should == [unidade_organizacionais(:sesi_colider_unidade_organizacional)]
    centros(:centro_forum_economico).unidade_organizacionais.should == [unidade_organizacionais(:senai_unidade_organizacional)]
    centros(:centro_forum_financeiro).unidade_organizacionais.sort_by(&:id).should == unidade_organizacionais(:senai_unidade_organizacional,:senai_unidade_organizacional_nova).sort_by(&:id)
    centros(:centro_forum_social).objeto_do_proximo_ano.should == centros(:centro_forum_social_2010)
  end
  
  it 'deve ter descricao' do
    centros(:centro_forum_social).resumo.should == '310010405 - Forum Serviço Social'
  end

  it 'valida presença dos campos' do
    centro = Centro.new
    centro.should_not be_valid
    centro.errors.on(:entidade).should_not be_nil
    centro.should_not be_valid
    centro.entidade = entidades(:senai)  
    centro.should be_valid
  end

  describe "Verifica se a funcao ''pesquisar_correspondente_no_ano_de'' traz" do 
  
    it "ele mesmo quando pesquisa o ano equivalente ao dele" do
      centro = centros(:centro_forum_social)
      centro.pesquisar_correspondente_no_ano_de(2009).should == centro   
    end
  
    it "o correspondente desse objeto no ano de 2010 e retornar o objeto" do
      centro = centros(:centro_forum_social)
      centro.pesquisar_correspondente_no_ano_de(2010).should == centros(:centro_forum_social_2010)      
    end

    it "o correspondente desse objeto no ano de 2011 e retornar o objeto" do
      centro = centros(:centro_forum_social)
      centro.pesquisar_correspondente_no_ano_de(2011).should == centros(:centro_forum_social_2011)     
    end

    it "uma exeção quando o objeto não possui objeto correspondente ao escolhido" do
      centro = centros(:centro_forum_economico)
      lambda {centro.pesquisar_correspondente_no_ano_de(2017)}.should raise_error("#{centro.nome} não possui correpondente no ano 2017")
    end
    
    it "uma exeção quando o ano do objeto pesquisado for menor que sua criação" do
      centro = centros(:centro_forum_social)
      lambda {centro.pesquisar_correspondente_no_ano_de(2008)}.should raise_error("Não é possível realizar um lançamento com data anterior à sua criação")
    end

    it "o centro de mesmo código no ano seguinte, mas sem nenhum associado" do
      centro = centros(:centro_forum_social)
      centro.pesquisar_correspondente_no_ano_de(2012).should == centros(:centro_forum_social_2012)
    end

    it "o centro de mesmo código sem objeto rastreavel" do
      centro = centros(:centro_forum_social_2014)
      centro.pesquisar_correspondente_no_ano_de(2015).should == centros(:centro_forum_social_2015)
    end

    it "centro com objeto rastreavel" do
      centro = centros(:centro_forum_social_2015)
      centro.pesquisar_correspondente_no_ano_de(2016).should == centros(:centro_forum_social_2016)
    end

  end
  
  it "Verifica se o objeto do proximo ano e igual ao ano atual + 1" do
    centro  = centros(:centro_forum_social)
    centro.objeto_do_proximo_ano.ano.should == centro.ano + 1 
  end
  
  it "Verifica se ao salvar objeto, certifica se o objeto do proximo ano tem o ano igual ao ano do objeto + 1 " do
    centro = Centro.new :ano => 2010, :entidade => entidades(:senai) , :codigo_centro => 4567456344, :nome => "Forum  Serviço Econômico", :codigo_reduzido => '00790'
    centro_validado = centros(:centro_forum_economico)
    centro_validado.objeto_do_proximo_ano = centro
    centro_validado.ano.should == centro.ano - 1
    centro_validado.entidade.should == centro.entidade
    centro_validado.save.should == true
  end
  
  it "Verifica se ao salvar objeto, certifica se o objeto nao consegue ser salvo ao tentar atribuir um centro que nao tenha o ano correto " do
    centro = Centro.new :ano => 2011, :entidade => entidades(:senai) , :codigo_centro => 4567456344, :nome => "Forum  Serviço Econômico", :codigo_reduzido => '00790'
    centro_validado = centros(:centro_forum_economico)
    centro_validado.objeto_do_proximo_ano = centro
    centro_validado.entidade.should == centro.entidade
    centro_validado.save.should == false
    centro_validado.errors.on(:ano).should == "O objeto do proximo ano deve ter ano válido."
  end
   
  it "Verifica se ao salvar objeto, certifica se o objeto nao consegue ser salvo ao tentar atribuir um centro que nao tenha a mesma entidade " do
    centro = Centro.new :ano => 2010, :entidade => entidades(:sesi) , :codigo_centro => 4567456344, :nome => "Forum  Serviço Econômico", :codigo_reduzido => '00790'
    centro_validado = centros(:centro_forum_economico)
    centro_validado.objeto_do_proximo_ano = centro
    centro_validado.ano.should == centro.ano - 1
    centro_validado.save.should == false
    centro_validado.errors.on(:entidade).should == "O objeto do proximo ano deve ter entidade válida."
  end
  
end
