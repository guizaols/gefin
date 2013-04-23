require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Convenio do
  before(:each) do
    @valid_attributes = {
      :numero => "6432451",
      :tipo_de_servico => "Tipo Válido",
      :quantidade_de_trasmissao => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Convenio.create!(@valid_attributes)
  end
end
