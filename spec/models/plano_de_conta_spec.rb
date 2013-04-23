require File.dirname(__FILE__) + '/../spec_helper'

describe PlanoDeConta do

  it "teste de relacionamentos" do
    @plano_de_conta = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    @plano_de_conta.contas_corrente.should == contas_correntes(:primeira_conta)
    @plano_de_conta.entidade.should == entidades(:senai)
    @plano_de_conta.parametro_conta_valores.sort_by{|parametro| parametro.id}.should == parametro_conta_valores(:conta_fornecedor,:one,:two, :conta_cliente, :conta_faturamento).sort_by{|parametro| parametro.id}
    @plano_de_conta.pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque, :pagamento_dinheiro)
    @plano_de_conta.rateios.should == [rateios(:rateio_segunda_parcela)]
    @plano = plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
    @plano.entidade.should == entidades(:sesi)
    @plano.pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque_outra_unidade, :pagamento_dinheiro_outra_unidade_mesmo_ano, :pagamento_banco_outra_unidade, :pagamento_dinheiro_outra_unidade_outro_ano)
    @plano.rateios.should == [rateios(:rateio_primeira_parcela)]
    @plano = plano_de_contas(:plano_de_contas_ativo_despesas)
    @plano.cheques.should == cheques(:cheque_do_andre_primeira_parcela,:vista,:prazo,:cheque_do_andre_segunda_parcela)
    @plano_de_conta = plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi)
    @plano_de_conta.parcelas.should == [parcelas(:primeira_parcela)]
    
  end
  
  it "verifica se retorna corretamente" do
    plano_de_conta = plano_de_contas(:plano_de_contas_ativo_contribuicoes)
    plano_de_conta.retorna_codigo_contabil_e_descricao.should == "41010101008 - Contribuicoes Regul. oriundas do SENAI"
  end

  it 'deve importar arquivo do Gefin' do
    PlanoDeConta.delete_all

    #Importação de Unidades Organizacionais

    lambda do
      arq_plano_de_conta = File.open(RAILS_ROOT + '/test/importacao/t_plcta_plano de conta 2009.txt')
      retorno_plano = PlanoDeConta.importar_plano_de_contas(arq_plano_de_conta)
      retorno_plano.first.should == true
      retorno_plano.last.should == "Foram importados 100 Planos de Conta!"
    end.should change(PlanoDeConta, :count).by(100)

    u = PlanoDeConta.last
    u.ano.should == 2009
    u.entidade.should == entidades(:senai)
    u.codigo_contabil.should == '1'
    u.nome.should == 'ATIVO'
    u.tipo_da_conta.should == 0

    u = PlanoDeConta.find_by_codigo_contabil('110313020090201')
    u.tipo_da_conta.should == 1
    
    lambda do
      arq_plano_de_conta = File.open(RAILS_ROOT + '/test/importacao/t_plcta_plano de conta 2009.txt')
      PlanoDeConta.importar_plano_de_contas(arq_plano_de_conta)
    end.should_not change(PlanoDeConta, :count)
  end
end
