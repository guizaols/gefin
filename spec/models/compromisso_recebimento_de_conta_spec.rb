require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CompromissoRecebimentoDeConta do
  it "Verifica se traz todos compromissos quando não receber nenhum parâmetro " do
    CompromissoRecebimentoDeConta.should_receive(:all).with(:include => {:conta => :pessoa}, :conditions => ['(compromissos.unidade_id = ?) AND (pessoas.cliente = ?)', unidades(:senaivarzeagrande).id, true]).and_return(0)
    @actual = CompromissoRecebimentoDeConta.pesquisa_agendamentos :all, unidades(:senaivarzeagrande).id, 'periodo_min'=>'','periodo_max'=>''
  end

  it "Verifica se traz todos compromissos quando receber datas como parâmetro " do
    CompromissoRecebimentoDeConta.should_receive(:all).with(:include => {:conta => :pessoa}, :conditions => ['(compromissos.unidade_id = ?) AND (pessoas.cliente = ?) AND (compromissos.data_agendada >= ?) AND (compromissos.data_agendada <= ?)', unidades(:senaivarzeagrande).id,true,Date.new(2009, 1,1),Date.new(2009, 12, 31)]).and_return(0)
    @actual = CompromissoRecebimentoDeConta.pesquisa_agendamentos :all, unidades(:senaivarzeagrande).id, 'periodo_min'=>'01/01/2009','periodo_max'=>'31/12/2009'
  end

end
