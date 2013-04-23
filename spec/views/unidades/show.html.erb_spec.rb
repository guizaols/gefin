require File.dirname(__FILE__) + '/../../spec_helper'

describe "/unidades/show.html.erb" do
  include UnidadesHelper
  
  before(:each) do
    @unidade = mock_model(Unidade)
    @unidade.stub!(:entidade).and_return("1")
    @unidade.stub!(:nome).and_return("MyString")
    @unidade.stub!(:sigla).and_return("MyString")
    @unidade.stub!(:endereco).and_return("MyString")
    @unidade.stub!(:bairro).and_return("MyString")
    @unidade.stub!(:cep).and_return("MyString")
    @unidade.stub!(:localidade_id).and_return("1")
    @unidade.stub!(:ativa).and_return(false)
    @unidade.stub!(:data_de_referencia).and_return(Time.now)
    @unidade.stub!(:telefone).and_return("MyString")
    @unidade.stub!(:fax).and_return("MyString")
    @unidade.stub!(:nome_da_caixa_zeus).and_return("1")
    @unidade.stub!(:cnpj).and_return("MyString")
    @unidade.stub!(:complemento).and_return("MyString")
    assigns[:unidade] = @unidade
  end

#  it "should render attributes in <p>" do
#    render "/unidades/show.html.erb"
#    response.should have_text(/1/)
#    response.should have_text(/MyString/)
#    response.should have_text(/MyString/)
#    response.should have_text(/1/)
#    response.should have_text(false) 
#    response.should have_text(/Time.now/)
#    response.should have_text(/MyString/)
#    response.should have_text(/MyString/)
#    response.should have_text(/1/)
#    response.should have_text(/MyString/)
#    response.should have_text(/MyString/)
#  end
  
end

