require File.dirname(__FILE__) + '/../../spec_helper'

describe "/localidades/new.html.erb" do
  include LocalidadesHelper
  
  before(:each) do
    @localidade = mock_model(Localidade)
    @localidade.stub!(:new_record?).and_return(true)
    @localidade.stub!(:nome).and_return("CURITIBA")
    @localidade.stub!(:uf).and_return("PR")
    assigns[:localidade] = @localidade
  end

  it "should render new form" do
    render "/localidades/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", localidades_path) do
      with_tag("input#localidade_nome[name=?]", "localidade[nome]")
      with_tag("select#localidade_uf[name=?]", "localidade[uf]")
    end
  end
end


