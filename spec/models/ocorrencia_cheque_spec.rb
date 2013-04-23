require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OcorrenciaCheque do

  it "valida campos obrigatórios" do
    @ocorrencia = OcorrenciaCheque.new
    @ocorrencia.should_not be_valid
    @ocorrencia.errors.on(:cheque).should_not be_nil
    @ocorrencia.errors.on(:data_do_evento).should_not be_nil
    @ocorrencia.errors.on(:tipo_da_ocorrencia).should_not be_nil
    @ocorrencia.errors.on(:historico).should_not be_nil
  end
  
  it "verifica se são validos os dados do campo alinea" do
    @ocorrencia = OcorrenciaCheque.new(:cheque => cheques(:prazo),
      :data_do_evento => "12/12/2009", :tipo_da_ocorrencia => Cheque::DEVOLUCAO,
      :alinea => 11, :historico => "Testando")
    @ocorrencia.save!
    @ocorrencia_2 = OcorrenciaCheque.last
    @ocorrencia_2.alinea = 93
    @ocorrencia_2.save
    @ocorrencia_2.errors.on(:alinea).should == "não está incluso na lista"
  end
  
  it "teste do método verbose" do
    @ocorrencia = OcorrenciaCheque.new
    @ocorrencia.alinea = 11
    @ocorrencia.alinea_verbose.should == "11 - Insuficiência de fundos 1ª apresentação"
    @ocorrencia.alinea = 23
    @ocorrencia.alinea_verbose.should == "23 - Cheques de órgão da administração federal em desacordo com o Decreto-Lei nº 200"
  end
  
  it "testa o reader da data para não mostrar as horas" do
    @ocorrencia = OcorrenciaCheque.new
    @ocorrencia.data_do_evento = Time.now
    @ocorrencia.data_do_evento.should == Date.today.to_s_br
  end

  it "teste do método verbose para o tipo de ocorrencia" do
    @ocorrencia = OcorrenciaCheque.new
    @ocorrencia.tipo_da_ocorrencia = Cheque::RENEGOCIACAO
    @ocorrencia.tipo_da_ocorrencia_verbose.should == 'Baixado'
    @ocorrencia.tipo_da_ocorrencia = Cheque::ENVIO_DR
    @ocorrencia.tipo_da_ocorrencia_verbose.should ==  'Baixa de transferência para o DR'
    @ocorrencia.tipo_da_ocorrencia = Cheque::DEVOLUCAO
    @ocorrencia.tipo_da_ocorrencia_verbose.should ==  'Reapresentação de Cheque'
  end
  
  
end
