require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BancoUnibanco do
  before(:each) do
    @valid_attributes = {
      :especie_documento => "DM",
      :moeda => "9",
      :data_documento => Date.today,
      :dias_vencimento => 1,
      :aceite => "S",
      :quantidade => 1,
      :valor => 0.0,
      :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO",
      :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => 12387989,
      :numero_documento => "777700168"
    }
  end

  it "should create a new default instance" do
    boleto_novo = BancoUnibanco.new
    boleto_novo.banco.should eql("409")
    boleto_novo.especie_documento.should eql("DM")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql("S")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.carteira.should eql("5")
    boleto_novo.should be_instance_of(BancoUnibanco)
  end

  it "should create a new instance given valid attributes" do
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.banco.should eql("409")
    boleto_novo.especie_documento.should eql("DM")
    boleto_novo.especie.should eql("R$")
    boleto_novo.moeda.should eql("9")
    boleto_novo.data_documento.should eql(Date.today)
    boleto_novo.dias_vencimento.should eql(1)
    boleto_novo.data_vencimento.should eql(Date.today + 1)
    boleto_novo.aceite.should eql("S")
    boleto_novo.quantidade.should eql(1)
    boleto_novo.valor.should eql(0.0)
    boleto_novo.valor_documento.should eql(0.0)
    boleto_novo.local_pagamento.should eql("QUALQUER BANCO ATÉ O VENCIMENTO")
    boleto_novo.cedente.should eql("Kivanio Barbosa")
    boleto_novo.documento_cedente.should eql("12345678912")
    boleto_novo.sacado.should eql("Claudio Pozzebom")
    boleto_novo.sacado_documento.should eql("12345678900")
    boleto_novo.conta_corrente.should eql("61900")
    boleto_novo.agencia.should eql("4042")
    boleto_novo.convenio.should eql(12387989)
    boleto_novo.numero_documento.should eql("777700168")
    boleto_novo.carteira.should eql("5")
    boleto_novo.should be_instance_of(BancoUnibanco)
  end

  it "should mount a valid bank invoice para carteira registrada" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:carteira] = "4"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    @valid_attributes[:convenio] = 2031671
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoUnibanco)
    boleto_novo.nosso_numero_dv.should eql(5)
    boleto_novo.monta_codigo_43_digitos.should eql("4099422300002952950409043001236018030299015")
    boleto_novo.codigo_barras.should eql("40997422300002952950409043001236018030299015")
    boleto_novo.codigo_barras.linha_digitavel.should eql("40990.40901 43001.236017 80302.990157 7 42230000295295")  
  end

  it "should mount a valid bank invoice para carteira sem registro" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:carteira] = "5"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    @valid_attributes[:convenio] = 2031671
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoUnibanco)
    boleto_novo.nosso_numero_dv.should eql(5)
    boleto_novo.monta_codigo_43_digitos.should eql("4099422300002952955203167100000018030299015")
    boleto_novo.codigo_barras.should eql("40995422300002952955203167100000018030299015")
    boleto_novo.codigo_barras.linha_digitavel.should eql("40995.20316 67100.000016 80302.990157 5 42230000295295")
  end

  it "should NOT mount a valid bank invoice" do
    @valid_attributes[:valor] = 0
    @valid_attributes[:data_documento] = Date.parse("2004-09-03")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = ""
    @valid_attributes[:carteira] = ""
    @valid_attributes[:conta_corrente] = ""
    @valid_attributes[:agencia] = ""
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoUnibanco)
    lambda { boleto_novo.nosso_numero_dv }.should raise_error(ArgumentError)
    
    boleto_novo.monta_codigo_43_digitos.should be_nil
    boleto_novo.codigo_barras.should be_nil
  end
  
  it "should mount nosso_numero_boleto" do
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoUnibanco)
    boleto_novo.numero_documento = "85068014982"
    boleto_novo.nosso_numero_boleto.should eql("00085068014982-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = "05009401448"
    boleto_novo.nosso_numero_boleto.should eql("00005009401448-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = "12387987777700168"
    boleto_novo.nosso_numero_boleto.should eql("12387987777700168-2")
    boleto_novo.nosso_numero_dv.should eql(2)
    boleto_novo.numero_documento = "4042"
    boleto_novo.nosso_numero_boleto.should eql("00000000004042-8")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = "61900"
    boleto_novo.nosso_numero_boleto.should eql("00000000061900-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = "0719"
    boleto_novo.nosso_numero_boleto.should eql("00000000000719-6")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.numero_documento = 85068014982
    boleto_novo.nosso_numero_boleto.should eql("00085068014982-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = 5009401448
    boleto_novo.nosso_numero_boleto.should eql("00005009401448-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 12387987777700168
    boleto_novo.nosso_numero_boleto.should eql("12387987777700168-2")
    boleto_novo.nosso_numero_dv.should eql(2)
    boleto_novo.numero_documento = 4042
    boleto_novo.nosso_numero_boleto.should eql("00000000004042-8")
    boleto_novo.nosso_numero_dv.should eql(8)
    boleto_novo.numero_documento = 61900
    boleto_novo.nosso_numero_boleto.should eql("00000000061900-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 719
    boleto_novo.nosso_numero_boleto.should eql("00000000000719-6")
    boleto_novo.nosso_numero_dv.should eql(6)
  end
  
  it "should mount agencia_conta_boleto" do
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoUnibanco)
    boleto_novo.agencia_conta_boleto.should eql("0123 / 100618-5")
    boleto_novo.agencia = "0548"
    boleto_novo.conta_corrente = "1448"
    boleto_novo.agencia_conta_boleto.should eql("0548 / 1448-6")
  end
  
  it "should test outputs" do
    @valid_attributes[:valor] = 2952.95
    @valid_attributes[:data_documento] = Date.parse("2009-04-30")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = "1803029901"
    @valid_attributes[:carteira] = "4"
    @valid_attributes[:conta_corrente] = "100618"
    @valid_attributes[:agencia] = "0123"
    @valid_attributes[:convenio] = 2031671
    boleto_novo = BancoUnibanco.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoUnibanco)
    %w| pdf jpg tif png ps |.each do |format|
      file_body=boleto_novo.to(format.to_sym)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end
end