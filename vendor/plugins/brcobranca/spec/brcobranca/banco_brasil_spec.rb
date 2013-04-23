require File.dirname(__FILE__) + '/../spec_helper.rb'

describe BancoBrasil do #:nodoc:[all]

  before(:each) do
    @valid_attributes = {
      :especie_documento => "DM",
      :moeda => "9",
      :banco => "001",
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
    boleto_novo = BancoBrasil.new
    boleto_novo.banco.should eql("001")
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
    boleto_novo.carteira.should eql("18")
    boleto_novo.codigo_servico.should be_false
    boleto_novo.should be_instance_of(BancoBrasil)
  end

  it "should create a new instance given valid attributes" do
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.banco.should eql("001")
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
    boleto_novo.carteira.should eql("18")
    boleto_novo.codigo_servico.should be_false
    boleto_novo.should be_instance_of(BancoBrasil)
  end

  it "should mount a valid invoice para convenio de 8 digitos e nosso numero de 9" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.monta_codigo_43_digitos.should eql("0019376900000135000000001238798977770016818")
    boleto_novo.codigo_barras.should eql("00193376900000135000000001238798977770016818")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00190.00009 01238.798977 77700.168188 3 37690000013500")
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.nosso_numero_dv.should eql(7)

    @valid_attributes[:dias_vencimento] = 1
    @valid_attributes[:numero_documento] = "7700168"
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.monta_codigo_43_digitos.should eql("0019377000000135000000001238798900770016818")
    boleto_novo.codigo_barras.should eql("00193377000000135000000001238798900770016818")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00190.00009 01238.798902 07700.168185 3 37700000013500")
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.nosso_numero_dv.should eql("X")
  end

  it "should mount a valid invoice para convenio de 7 digitos e nosso numero de 10" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:convenio] = 1238798
    @valid_attributes[:numero_documento] = "7777700168"
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.monta_codigo_43_digitos.should eql("0019377100000135000000001238798777770016818")
    boleto_novo.codigo_barras.should eql("00193377100000135000000001238798777770016818")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00190.00009 01238.798779 77700.168188 3 37710000013500")
    boleto_novo.conta_corrente_dv.should eql(0)

    @valid_attributes[:valor] = 723.56
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:convenio] = 1238798
    @valid_attributes[:numero_documento] = "7777700168"
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.monta_codigo_43_digitos.should eql("0019377100000723560000001238798777770016818")
    boleto_novo.codigo_barras.should eql("00195377100000723560000001238798777770016818")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00190.00009 01238.798779 77700.168188 5 37710000072356")
    boleto_novo.conta_corrente_dv.should eql(0)

    @valid_attributes[:valor] = 723.56
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 1238798
    @valid_attributes[:numero_documento] = "7777700168"
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.monta_codigo_43_digitos.should eql("0019376900000723560000001238798777770016818")
    boleto_novo.codigo_barras.should eql("00194376900000723560000001238798777770016818")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00190.00009 01238.798779 77700.168188 4 37690000072356")
    boleto_novo.conta_corrente_dv.should eql(0)
  end

  it "should mount a valid invoice para convenio de 6 digitos e nosso numero de 5" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 123879
    @valid_attributes[:numero_documento] = "1234"
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.monta_codigo_43_digitos.should eql("0019376900000135001238790123440420006190018")
    boleto_novo.codigo_barras.should eql("00192376900000135001238790123440420006190018")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00191.23876 90123.440423 00061.900189 2 37690000013500")  
  end

  it "should mount a valid invoice para convenio de 6 digitos, nosso numero de 17 e carteira 16" do  
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 123879
    @valid_attributes[:numero_documento] = "1234567899"
    @valid_attributes[:carteira] = "16"
    @valid_attributes[:codigo_servico] = true
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.monta_codigo_43_digitos.should eql("0019376900000135001238790000000123456789921")
    boleto_novo.codigo_barras.should eql("00199376900000135001238790000000123456789921")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00191.23876 90000.000126 34567.899215 9 37690000013500")
  end

  it "should mount a valid invoice para convenio de 6 digitos, nosso numero de 17 e carteira 18" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 123879
    @valid_attributes[:numero_documento] = "1234567899"
    @valid_attributes[:carteira] = "18"
    @valid_attributes[:codigo_servico] = true
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.monta_codigo_43_digitos.should eql("0019376900000135001238790000000123456789921")
    boleto_novo.codigo_barras.should eql("00199376900000135001238790000000123456789921")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00191.23876 90000.000126 34567.899215 9 37690000013500")
  end

  it "should mount raise error para convenio de 6 digitos, nosso numero de 17 e carteira 17" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 123879
    @valid_attributes[:numero_documento] = "1234567899"
    @valid_attributes[:carteira] = "17"
    @valid_attributes[:codigo_servico] = true
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.conta_corrente_dv.should eql(0)
    lambda { boleto_novo.monta_codigo_43_digitos }.should raise_error(RuntimeError)
    lambda { boleto_novo.monta_codigo_43_digitos }.should raise_error("Só é permitido emitir boletos com nosso número de 17 dígitos com carteiras 16 ou 18. Sua carteira atual é 17")
  end

  it "should mount a valid invoice para convenio de 4 digitos e nosso numero de 7" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:convenio] = 1238
    @valid_attributes[:numero_documento] = "123456"
    @valid_attributes[:codigo_servico] = true
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.conta_corrente_dv.should eql(0)
    boleto_novo.monta_codigo_43_digitos.should eql("0019376900000135001238012345640420006190018")
    boleto_novo.codigo_barras.should eql("00191376900000135001238012345640420006190018")
    boleto_novo.codigo_barras.linha_digitavel.should eql("00191.23801 12345.640424 00061.900189 1 37690000013500")
  end

  # TODO -  should give exception
  it "should return nil when attributes are nil" do
    @valid_attributes[:valor] = 0
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 0
    @valid_attributes[:numero_documento] = ""
    @valid_attributes[:banco] = ""
    @valid_attributes[:carteira] = ""
    @valid_attributes[:moeda] = ""
    @valid_attributes[:convenio] = ""  

    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.monta_codigo_43_digitos.should be_nil
    boleto_novo.codigo_barras.should be_nil
  end

  it "should calculate bando_dv" do
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.banco = "85068014982"
    boleto_novo.banco_dv.should eql(9)
    boleto_novo.banco = "05009401448"
    boleto_novo.banco_dv.should eql(1)
    boleto_novo.banco = "12387987777700168"
    boleto_novo.banco_dv.should eql(2)
    boleto_novo.banco = "4042"
    boleto_novo.banco_dv.should eql(8)
    boleto_novo.banco = "61900"
    boleto_novo.banco_dv.should eql(0)
    boleto_novo.banco = "0719"
    boleto_novo.banco_dv.should eql(6)
    boleto_novo.banco = 85068014982
    boleto_novo.banco_dv.should eql(9)
    boleto_novo.banco = 5009401448
    boleto_novo.banco_dv.should eql(1)
    boleto_novo.banco = 12387987777700168
    boleto_novo.banco_dv.should eql(2)
    boleto_novo.banco = 4042
    boleto_novo.banco_dv.should eql(8)
    boleto_novo.banco = 61900
    boleto_novo.banco_dv.should eql(0)
    boleto_novo.banco = 719
    boleto_novo.banco_dv.should eql(6)
  end

  it "should calculate agencia_dv" do
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.agencia = "85068014982"
    boleto_novo.agencia_dv.should eql(9)
    boleto_novo.agencia = "05009401448"
    boleto_novo.agencia_dv.should eql(1)
    boleto_novo.agencia = "12387987777700168"
    boleto_novo.agencia_dv.should eql(2)
    boleto_novo.agencia = "4042"
    boleto_novo.agencia_dv.should eql(8)
    boleto_novo.agencia = "61900"
    boleto_novo.agencia_dv.should eql(0)
    boleto_novo.agencia = "0719"
    boleto_novo.agencia_dv.should eql(6)
    boleto_novo.agencia = 85068014982
    boleto_novo.agencia_dv.should eql(9)
    boleto_novo.agencia = 5009401448
    boleto_novo.agencia_dv.should eql(1)
    boleto_novo.agencia = 12387987777700168
    boleto_novo.agencia_dv.should eql(2)
    boleto_novo.agencia = 4042
    boleto_novo.agencia_dv.should eql(8)
    boleto_novo.agencia = 61900
    boleto_novo.agencia_dv.should eql(0)
    boleto_novo.agencia = 719
    boleto_novo.agencia_dv.should eql(6)
  end

  it "should mount nosso_numero_boleto" do
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.numero_documento = "85068014982"
    boleto_novo.nosso_numero_boleto.should eql("1238798985068014982-6")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.numero_documento = "05009401448"
    boleto_novo.nosso_numero_boleto.should eql("1238798905009401448-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = "12387987777700168"
    boleto_novo.nosso_numero_boleto.should eql("1238798912387987777700168-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = "4042"
    boleto_novo.nosso_numero_boleto.should eql("123879894042-0")
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.numero_documento = "61900"
    boleto_novo.nosso_numero_boleto.should eql("1238798961900-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = "0719"
    boleto_novo.nosso_numero_boleto.should eql("123879890719-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = 85068014982
    boleto_novo.nosso_numero_boleto.should eql("1238798985068014982-6")
    boleto_novo.nosso_numero_dv.should eql(6)
    boleto_novo.numero_documento = 5009401448
    boleto_novo.nosso_numero_boleto.should eql("123879895009401448-X")
    boleto_novo.nosso_numero_dv.should eql("X")
    boleto_novo.numero_documento = 12387987777700168
    boleto_novo.nosso_numero_boleto.should eql("1238798912387987777700168-9")
    boleto_novo.nosso_numero_dv.should eql(9)
    boleto_novo.numero_documento = 4042
    boleto_novo.nosso_numero_boleto.should eql("123879894042-0")
    boleto_novo.nosso_numero_dv.should eql(0)
    boleto_novo.numero_documento = 61900
    boleto_novo.nosso_numero_boleto.should eql("1238798961900-1")
    boleto_novo.nosso_numero_dv.should eql(1)
    boleto_novo.numero_documento = 719
    boleto_novo.nosso_numero_boleto.should eql("12387989719-3")
    boleto_novo.nosso_numero_dv.should eql(3)
  end

  it "should mount agencia_conta_boleto" do
    boleto_novo = BancoBrasil.new(@valid_attributes)
    boleto_novo.should be_instance_of(BancoBrasil)
    boleto_novo.agencia_conta_boleto.should eql("4042-8 / 61900-0")
    boleto_novo.agencia = "0719"
    boleto_novo.agencia_conta_boleto.should eql("0719-6 / 61900-0")
    boleto_novo.agencia = "0548"
    boleto_novo.conta_corrente = "1448"
    boleto_novo.agencia_conta_boleto.should eql("0548-7 / 1448-6")
  end
  
  it "should test outputs" do
    @valid_attributes[:valor] = 135.00
    @valid_attributes[:data_documento] = Date.parse("2008-02-01")
    @valid_attributes[:dias_vencimento] = 2
    @valid_attributes[:convenio] = 1238798
    @valid_attributes[:numero_documento] = "7777700168"
    boleto_novo = BancoBrasil.new(@valid_attributes)
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