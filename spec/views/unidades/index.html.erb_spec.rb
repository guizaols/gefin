require File.dirname(__FILE__) + '/../../spec_helper'

describe "/unidades/index.html.erb" do
  include UnidadesHelper
  
  before(:each) do
    unidade_98 = mock_model(Unidade)
    unidade_98.should_receive(:entidade).and_return("1")
    unidade_98.should_receive(:nome).and_return("MyString")
    unidade_98.should_receive(:sigla).and_return("MyString")
    unidade_98.should_receive(:endereco).and_return("MyString")
    unidade_98.should_receive(:data_de_referencia).and_return(Time.now)
    unidade_98.should_receive(:telefone).and_return("MyString")
    unidade_98.should_receive(:fax).and_return("MyString")
    unidade_98.should_receive(:nome_da_caixa_zeus).and_return("1")
    unidade_98.should_receive(:cnpj).and_return("MyString")
    unidade_98.should_receive(:complemento).and_return("MyString")
    unidade_99 = mock_model(Unidade)
    unidade_99.should_receive(:entidade_id).and_return("1")
    unidade_99.should_receive(:nome).and_return("MyString")
    unidade_99.should_receive(:sigla).and_return("MyString")
    unidade_99.should_receive(:endereco).and_return("MyString")
    unidade_99.should_receive(:data_de_referencia).and_return(Time.now)
    unidade_99.should_receive(:telefone).and_return("MyString")
    unidade_99.should_receive(:fax).and_return("MyString")
    unidade_99.should_receive(:nome_da_caixa_zeus).and_return("1")
    unidade_99.should_receive(:cnpj).and_return("MyString")
    unidade_99.should_receive(:complemento).and_return("MyString")

    assigns[:unidades] = [unidade_98, unidade_99]
  end

#  it "should render list of unidades" do
#    render "/unidades/index.html.erb"
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "1", 2)
#    response.should have_tag("tr>td", "MyString", 2)
#    response.should have_tag("tr>td", "MyString", 2)
#  end
end

