require File.dirname(__FILE__) + '/../../spec_helper'

describe "/localidades/edit.html.erb" do
  include LocalidadesHelper
  
  before do
    @localidade = mock_model(Localidade)
    @localidade.stub!(:nome).and_return("CURITIBA")
    @localidade.stub!(:uf).and_return("PR")
    assigns[:localidade] = @localidade
  end

  it "should render edit form" do
    render "/localidades/edit.html.erb"
    
    response.should have_tag("form[action=#{localidade_path(@localidade)}][method=post]") do
      with_tag('input#localidade_nome[name=?]', "localidade[nome]")
      with_tag('select#localidade_uf[name=?]', "localidade[uf]")
    end
  end
end


