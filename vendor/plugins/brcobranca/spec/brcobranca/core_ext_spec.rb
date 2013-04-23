require File.dirname(__FILE__) + '/../spec_helper.rb'

module Brcobranca
  describe Formatacao do
    it "should format CPF" do
      98789298790.to_br_cpf.should eql("987.892.987-90")
      "98789298790".to_br_cpf.should eql("987.892.987-90")
    end

    it "should format CEP" do
      85253100.to_br_cep.should eql("85253-100")
      "85253100".to_br_cep.should eql("85253-100")
    end

    it "should format CNPJ" do
      88394510000103.to_br_cnpj.should eql("88.394.510/0001-03")
      "88394510000103".to_br_cnpj.should eql("88.394.510/0001-03")
    end

    it "should format documents based in your lenght" do
      98789298790.formata_documento.should eql("987.892.987-90")
      "98789298790".formata_documento.should eql("987.892.987-90")
      85253100.formata_documento.should eql("85253-100")
      "85253100".formata_documento.should eql("85253-100")
      88394510000103.formata_documento.should eql("88.394.510/0001-03")
      "88394510000103".formata_documento.should eql("88.394.510/0001-03")
      "8839".formata_documento.should eql("8839")
      "8839451000010388394510000103".formata_documento.should eql("8839451000010388394510000103")
    end

    it "should fill with zeros at left until lenght seted" do
      "123".zeros_esquerda.should eql("123")
      "123".zeros_esquerda(:tamanho => 0).should eql("123")
      "123".zeros_esquerda(:tamanho => 1).should eql("123")
      "123".zeros_esquerda(:tamanho => 2).should eql("123")
      "123".zeros_esquerda(:tamanho => 3).should eql("123")
      "123".zeros_esquerda(:tamanho => 4).should eql("0123")
      "123".zeros_esquerda(:tamanho => 5).should eql("00123")
      "123".zeros_esquerda(:tamanho => 10).should eql("0000000123")
      "123".zeros_esquerda(:tamanho => 5).should be_a_kind_of(String)

      123.zeros_esquerda.should eql("123")
      123.zeros_esquerda(:tamanho => 0).should eql("123")
      123.zeros_esquerda(:tamanho => 1).should eql("123")
      123.zeros_esquerda(:tamanho => 2).should eql("123")
      123.zeros_esquerda(:tamanho => 3).should eql("123")
      123.zeros_esquerda(:tamanho => 4).should eql("0123")
      123.zeros_esquerda(:tamanho => 5).should eql("00123")
      123.zeros_esquerda(:tamanho => 10).should eql("0000000123")
      123.zeros_esquerda(:tamanho => 5).should be_a_kind_of(String)
    end

    it "should mount linha digitavel" do
      "00192376900000135000000001238798777770016818".linha_digitavel.should eql("00190.00009 01238.798779 77700.168188 2 37690000013500")
      "00192376900000135000000001238798777770016818".linha_digitavel.should be_a_kind_of(String)
      lambda { "".linha_digitavel }.should raise_error(ArgumentError)
      lambda { "00193373700".linha_digitavel }.should raise_error(ArgumentError)
      lambda { "0019337370000193373700".linha_digitavel }.should raise_error(ArgumentError)
      lambda { "00b193373700bb00193373700".linha_digitavel }.should raise_error(ArgumentError)
      lambda { "0019337370000193373700bbb".linha_digitavel }.should raise_error(ArgumentError)
      lambda { "0019237690000c135000c0000123f7987e7773016813".linha_digitavel }.should raise_error(ArgumentError)
    end
  end

  describe Calculo do
    it "should calculate mod10" do
      lambda { "".modulo10 }.should raise_error(ArgumentError)
      lambda { " ".modulo10 }.should raise_error(ArgumentError)
      "001905009".modulo10.should eql(5)
      "4014481606".modulo10.should eql(9)
      "0680935031".modulo10.should eql(4)
      "29004590".modulo10.should eql(5)
      "341911012".modulo10.should eql(1)
      "3456788005".modulo10.should eql(8)
      "7123457000".modulo10.should eql(1)
      "00571234511012345678".modulo10.should eql(8)
      "001905009".modulo10.should be_a_kind_of(Fixnum)
      0.modulo10.should eql(0)
      1905009.modulo10.should eql(5)
      4014481606.modulo10.should eql(9)
      680935031.modulo10.should eql(4)
      29004590.modulo10.should eql(5)
      1905009.modulo10.should be_a_kind_of(Fixnum)
    end

    it "should calculate mo10_banespa" do
      "4007469108".modulo_10_banespa.should eql(1)
      4007469108.modulo_10_banespa.should eql(1)
      "1237469108".modulo_10_banespa.should eql(3)
      1237469108.modulo_10_banespa.should eql(3)
    end

    it "should test multiplicador" do
      "85068014982".multiplicador([2,3,4,5,6,7,8,9]).should eql(255)
      "05009401448".multiplicador([2,3,4,5,6,7,8,9]).should eql(164)
      "12387987777700168".multiplicador([2,3,4,5,6,7,8,9]).should eql(460)
      "34230".multiplicador([2,3,4,5,6,7,8,9]).should eql(55)
      "258281".multiplicador([2,3,4,5,6,7,8,9]).should eql(118)
      "5444".multiplicador([2,3,4,5,6,7,8,9]).should be_a_kind_of(Fixnum)
      "000000005444".multiplicador([2,3,4,5,6,7,8,9]).should be_a_kind_of(Fixnum)
      85068014982.multiplicador([2,3,4,5,6,7,8,9]).should eql(255)
      5009401448.multiplicador([2,3,4,5,6,7,8,9]).should eql(164)
      5444.multiplicador([2,3,4,5,6,7,8,9]).should eql(61)
      1129004590.multiplicador([2,3,4,5,6,7,8,9]).should eql(162)
      5444.multiplicador([2,3,4,5,6,7,8,9]).should be_a_kind_of(Fixnum)
      lambda { "2582fd81".multiplicador([2,3,4,5,6,7,8,9]) }.should raise_error(ArgumentError)
    end

    it "should calculate mo11 - 9to2" do
      "85068014982".modulo11_9to2.should eql(9)
      "05009401448".modulo11_9to2.should eql(1)
      "12387987777700168".modulo11_9to2.should eql(2)
      "4042".modulo11_9to2.should eql(8)
      "61900".modulo11_9to2.should eql(0)
      "0719".modulo11_9to2.should eql(6)
      "000000005444".modulo11_9to2.should eql(5)
      "5444".modulo11_9to2.should eql(5)
      "01129004590".modulo11_9to2.should eql(3)
      "15735".modulo11_9to2.should eql(10)
      "777700168".modulo11_9to2.should eql(0)
      "77700168".modulo11_9to2.should eql(3)
      "00015448".modulo11_9to2.should eql(2)
      "15448".modulo11_9to2.should eql(2)
      "12345678".modulo11_9to2.should eql(9)
      "34230".modulo11_9to2.should eql(0)
      "258281".modulo11_9to2.should eql(3)
      "5444".modulo11_9to2.should be_a_kind_of(Fixnum)
      "000000005444".modulo11_9to2.should be_a_kind_of(Fixnum)
      85068014982.modulo11_9to2.should eql(9)
      5009401448.modulo11_9to2.should eql(1)
      12387987777700168.modulo11_9to2.should eql(2)
      4042.modulo11_9to2.should eql(8)
      61900.modulo11_9to2.should eql(0)
      719.modulo11_9to2.should eql(6)
      5444.modulo11_9to2.should eql(5)
      1129004590.modulo11_9to2.should eql(3)
      5444.modulo11_9to2.should be_a_kind_of(Fixnum)
      lambda { "2582fd81".modulo11_9to2 }.should raise_error(ArgumentError)
    end

    it "should calculate mod11 - 9to2, X instead of 10" do
      "85068014982".modulo11_9to2_10_como_x.should eql(9)
      "05009401448".modulo11_9to2_10_como_x.should eql(1)
      "12387987777700168".modulo11_9to2_10_como_x.should eql(2)
      "4042".modulo11_9to2_10_como_x.should eql(8)
      "61900".modulo11_9to2_10_como_x.should eql(0)
      "0719".modulo11_9to2_10_como_x.should eql(6)
      "000000005444".modulo11_9to2_10_como_x.should eql(5)
      "5444".modulo11_9to2_10_como_x.should eql(5)
      "01129004590".modulo11_9to2_10_como_x.should eql(3)
      "15735".modulo11_9to2_10_como_x.should eql("X")
      "15735".modulo11_9to2_10_como_x.should be_a_kind_of(String)
      "5444".modulo11_9to2_10_como_x.should be_a_kind_of(Fixnum)
      "000000005444".modulo11_9to2_10_como_x.should be_a_kind_of(Fixnum)
      lambda { "2582fd81".modulo11_9to2_10_como_x }.should raise_error(ArgumentError)
    end

    it "should calculate mod11 - 2to9" do
      "0019373700000001000500940144816060680935031".modulo11_2to9.should eql(3)
      "0019373700000001000500940144816060680935031".modulo11_2to9.should be_a_kind_of(Fixnum)
      "3419166700000123451101234567880057123457000".modulo11_2to9.should eql(6)
      19373700000001000500940144816060680935031.modulo11_2to9.should eql(3)
      19373700000001000500940144816060680935031.modulo11_2to9.should be_a_kind_of(Fixnum)
      lambda { "2582fd81".modulo11_2to9 }.should raise_error(ArgumentError)
    end

    it "should calculate digit's sum side by side" do
      111.soma_digitos.should eql(3)
      8.soma_digitos.should eql(8)
      "111".soma_digitos.should eql(3)
      "8".soma_digitos.should eql(8)
      111.soma_digitos.should be_a_kind_of(Fixnum)
      "111".soma_digitos.should be_a_kind_of(Fixnum)
    end
  end

  describe Validacao do
    it "should return true when value is a currency" do
      1234.03.to_s.moeda?.should be_true
      +1234.03.to_s.moeda?.should be_true
      -1234.03.to_s.moeda?.should be_true
      1234.03.moeda?.should be_true
      +1234.03.moeda?.should be_true
      -1234.03.moeda?.should be_true
      "1234.03".moeda?.should be_true
      "1234,03".moeda?.should be_true
      "1,234.03".moeda?.should be_true
      "1.234.03".moeda?.should be_true
      "1,234,03".moeda?.should be_true
      "12.340,03".moeda?.should be_true
      "+1234.03".moeda?.should be_true
      "+1234,03".moeda?.should be_true
      "+1,234.03".moeda?.should be_true
      "+1.234.03".moeda?.should be_true
      "+1,234,03".moeda?.should be_true
      "+12.340,03".moeda?.should be_true
      "-1234.03".moeda?.should be_true
      "-1234,03".moeda?.should be_true
      "-1,234.03".moeda?.should be_true
      "-1.234.03".moeda?.should be_true
      "-1,234,03".moeda?.should be_true
      "-12.340,03".moeda?.should be_true
    end

    it "should return false when value is NOT a currency" do
      123403.to_s.moeda?.should be_false
      -123403.to_s.moeda?.should be_false
      +123403.to_s.moeda?.should be_false
      123403.moeda?.should be_false
      -123403.moeda?.should be_false
      +123403.moeda?.should be_false
      "1234ab".moeda?.should be_false
      "ab1213".moeda?.should be_false
      "ffab".moeda?.should be_false
      "1234".moeda?.should be_false
      "23[;)]ddf".moeda?.should be_false
    end
  end

  describe Limpeza do
    it "should return just numbers when value is a currency" do
      1234.03.limpa_valor_moeda.should == "123403"
      +1234.03.limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      -1234.03.limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "1234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "1234,03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "1,234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "1.234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "1,234,03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "12.340,03".limpa_valor_moeda.limpa_valor_moeda.should == "1234003"
      "+1234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "+1234,03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "+1,234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "+1.234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "+1,234,03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "+12.340,03".limpa_valor_moeda.limpa_valor_moeda.should == "1234003"
      "-1234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "-1234,03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "-1,234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "-1.234.03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "-1,234,03".limpa_valor_moeda.limpa_valor_moeda.should == "123403"
      "-12.340,03".limpa_valor_moeda.limpa_valor_moeda.should == "1234003"
    end

    it "should NOT modify value when it is NOT a currency" do
      "1234ab".limpa_valor_moeda.limpa_valor_moeda.should == "1234ab"
      "ab1213".limpa_valor_moeda.limpa_valor_moeda.should == "ab1213"
      "ffab".limpa_valor_moeda.limpa_valor_moeda.should == "ffab"
      "1234".limpa_valor_moeda.limpa_valor_moeda.should == "1234"
    end
  end

  describe CalculoData do
    it "should return number of days between Date and 1997-10-07" do
      (Date.parse "2008-02-01").fator_vencimento.should == 3769
      (Date.parse "2008-02-02").fator_vencimento.should == 3770
      (Date.parse "2008-02-06").fator_vencimento.should == 3774
    end

    it "should format Date to Brazillian format" do
      (Date.parse "2008-02-01").to_s_br.should == "01/02/2008"
      (Date.parse "2008-02-02").to_s_br.should == "02/02/2008"
      (Date.parse "2008-02-06").to_s_br.should == "06/02/2008"
    end

    it "should calculate julian date from a Date" do
      (Date.parse "2009-02-11").to_juliano.should eql("0429")
      (Date.parse "2008-02-11").to_juliano.should eql("0428")
      (Date.parse "2009-04-08").to_juliano.should eql("0989")
      # Ano 2008 eh bisexto
      (Date.parse "2008-04-08").to_juliano.should eql("0998")
    end
  end

end