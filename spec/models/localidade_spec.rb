require File.dirname(__FILE__) + '/../spec_helper'

describe Localidade do
  
  before(:each) do
    @localidade = Localidade.new
  end

  it "should be valid" do
    @localidade.should_not be_valid
  end
  
  it "deve validar a presença dos campos" do
    @localidade.should_not be_valid
    @localidade.errors.on(:nome).should == "deve ser preenchido."
    @localidade.errors.on(:uf).should == "não está incluído na lista."
  end
  
  it "deve validar se o uf está correto" do
    @localidade = Localidade.new :nome => "CURITIBA", :uf => "PT"
    @localidade.should_not be_valid
    @localidade.errors.on(:uf).should_not be_nil
    @localidade.uf = "PR"
    @localidade.should be_valid
    @localidade.errors.on(:uf).should be_nil    
  end

  it "verifica se está carregando os estados" do
    [['AC', 'ACRE'], ['AL', 'ALAGOAS'], ['AP', 'AMAPÁ'], ['AM', 'AMAZONAS'], ['BA', 'BAHIA'], ['CE', 'CEARÁ'], 
      ['DF', 'DISTRITO FEDERAL'], ['GO', 'GOIÁS'], ['ES', 'ESPÍRITO SANTO'], ['MA', 'MARANHÃO'], ['MT', 'MATO GROSSO'], 
      ['MS', 'MATO GROSSO DO SUL'], ['MG', 'MINAS GERAIS'], ['PA', 'PARÁ'], ['PB', 'PARAÍBA'], ['PR', 'PARANÁ'], 
      ['PE', 'PERNAMBUCO'], ['PI', 'PIAUÍ'], ['RJ', 'RIO DE JANEIRO'], ['RN', 'RIO GRANDE DO NORTE'], ['RS', 'RIO GRANDE DO SUL'],
      ['RO', 'RONDÔNIA'], ['RR', 'RORAIMA'], ['SP', 'SÃO PAULO'], ['SC', 'SANTA CATARINA'], ['SE', 'SERGIPE'], ['TO', 'TOCANTINS']].each do |item|
      Localidade::ESTADOS[item.first].should == item.last
    end
  end
    
  it "verifica se está retornando array de estados corretamente" do
    Localidade.retorna_estados_como_array.should ==
      [["ACRE - AC", "AC"], ["ALAGOAS - AL", "AL"], ["AMAPÁ - AP", "AP"], ["AMAZONAS - AM", "AM"], ["BAHIA - BA", "BA"],
      ["CEARÁ - CE", "CE"], ["DISTRITO FEDERAL - DF", "DF"], ["ESPÍRITO SANTO - ES", "ES"], ["GOIÁS - GO", "GO"], 
      ["MARANHÃO - MA", "MA"], ["MATO GROSSO - MT", "MT"], ["MATO GROSSO DO SUL - MS", "MS"], ["MINAS GERAIS - MG", "MG"], 
      ["PARANÁ - PR", "PR"], ["PARAÍBA - PB", "PB"], ["PARÁ - PA", "PA"], ["PERNAMBUCO - PE", "PE"], ["PIAUÍ - PI", "PI"], 
      ["RIO DE JANEIRO - RJ", "RJ"], ["RIO GRANDE DO NORTE - RN", "RN"], ["RIO GRANDE DO SUL - RS", "RS"], ["RONDÔNIA - RO", "RO"], 
      ["RORAIMA - RR", "RR"], ["SANTA CATARINA - SC", "SC"], ["SERGIPE - SE", "SE"], ["SÃO PAULO - SP", "SP"], ["TOCANTINS - TO", "TO"]]    
  end
  
  it "verifica se existe o atributo virtual cidade_e_estado" do
    @localidade = localidades(:primeira)
    @localidade.nome_localidade.should == 'VARZEA GRANDE - MT'
    @localidade = localidades(:segunda)
    @localidade.nome_localidade.should == 'CUIABA - MT'
  end
  
  it "verifica se existe relacionamento" do
    @pessoa = pessoas(:paulo)
    @localidade = localidades(:primeira)
    @localidade.agencias.should ==  [agencias(:centro)]
    @localidade.unidades.should == [unidades(:senaivarzeagrande)]
    @pessoa.localidade.should == localidades(:primeira)
    @localidade.pessoas.should == [pessoas(:paulo)]
  end
  
  it "testa o atributo virtual mensagem_de_erro" do
    @localidade = Localidade.new
    @localidade.mensagem_de_erro.should == nil
  end
  
  it "não permite excluir se possuir unidade,pessoas e agencias com esta localidade" do
    @localidade = localidades(:primeira)
    assert_no_difference 'Localidade.count' do
      @localidade.destroy
    end
    @localidade.mensagem_de_erro.should == ["* Não foi possível excluir, pois esta localidade está vinculada a UNIDADES", "* Não foi possível excluir, pois esta localidade está vinculada a PESSOAS", "* Não foi possível excluir, pois esta localidade está vinculada a AGÊNCIAS"]
  end

  it "teste da def resumo" do
    localidades(:primeira).resumo.should == "VARZEA GRANDE - MT"
  end
 
end

