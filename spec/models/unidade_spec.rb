require File.dirname(__FILE__) + '/../spec_helper'

describe Unidade do
  
  it "deve ser válida" do
    @unidade = Unidade.new
    @unidade.lancamentoscontaspagar.should == 5
    @unidade.lancamentoscontasreceber.should == 5
    @unidade.lancamentosmovimentofinanceiro.should == 5
    @unidade.senha_baixa_dr.should == 'teste'
    @unidade.valid?
    @unidade.errors_on(:entidade).should_not be_nil
    @unidade.errors.on(:lancamentoscontaspagar).should be_nil
    @unidade.errors.on(:lancamentoscontasreceber).should be_nil
    @unidade.errors.on(:lancamentosmovimentofinanceiro).should be_nil
    @unidade.lancamentoscontaspagar = nil
    @unidade.lancamentoscontasreceber = nil
    @unidade.lancamentosmovimentofinanceiro = nil
    @unidade.valid?
    @unidade.errors_on(:entidade).should_not be_nil
    @unidade.errors.on(:lancamentoscontaspagar).should_not be_nil
    @unidade.errors.on(:lancamentoscontasreceber).should_not be_nil
    @unidade.errors.on(:lancamentosmovimentofinanceiro).should_not be_nil
    @unidade.lancamentoscontaspagar = -1
    @unidade.lancamentoscontasreceber = -1
    @unidade.lancamentosmovimentofinanceiro = -1
    @unidade.entidade = entidades(:senai)
    @unidade.nome = "Senai"
    @unidade.sigla = "SENAI"
    @unidade.valid?
    @unidade.errors.on(:entidade).should be_nil
    @unidade.errors.on(:lancamentoscontaspagar).should_not be_nil
    @unidade.errors.on(:lancamentoscontasreceber).should_not be_nil
    @unidade.errors.on(:lancamentosmovimentofinanceiro).should_not be_nil
    @unidade.lancamentoscontaspagar = 0
    @unidade.lancamentoscontasreceber = 0
    @unidade.lancamentosmovimentofinanceiro = 0
    @unidade.entidade = entidades(:senai)
    @unidade.nome = "Senai"
    @unidade.sigla = "SENAI"
    @unidade.valid?
    @unidade.errors.on(:entidade).should be_nil
    @unidade.errors.on(:lancamentoscontaspagar).should be_nil
    @unidade.errors.on(:lancamentoscontasreceber).should be_nil
    @unidade.errors.on(:lancamentosmovimentofinanceiro).should be_nil
    @unidade.lancamentoscontaspagar = 5
    @unidade.lancamentoscontasreceber = 5
    @unidade.lancamentosmovimentofinanceiro = 5
    @unidade.limitediasparaestornodeparcelas = 5000
    @unidade.senha_baixa_dr = 'teste'
    @unidade.entidade = entidades(:senai)
    @unidade.nome = "Senai"
    @unidade.sigla = "SENAI"
    @unidade.senha_baixa_dr = 'teste'
    @unidade.should_not be_valid
    @unidade.errors.on(:nome_caixa_zeus).should == "deve ser preenchido."
    @unidade.nome_caixa_zeus = "CX.00 SENAIVG"
    @unidade.save!
    @unidade.errors.on(:nome).should be_nil
    @unidade.errors.on(:entidade).should be_nil
    @unidade.errors.on(:lancamentoscontaspagar).should be_nil
    @unidade.errors.on(:lancamentoscontasreceber).should be_nil
    @unidade.errors.on(:lancamentosmovimentofinanceiro).should be_nil
    @unidade.errors.on(:nome_caixa_zeus).should be_nil
    @unidade.errors.on(:senha_baixa_dr).should be_nil
  end
  
  it "test do atributo virtual mensagem_de_erro" do
    @unidade = Unidade.new
    @unidade.mensagem_de_erro.should == nil
  end
  
 
end

describe "Verifica se atributo ativa" do
  
  it "inicializa com true" do
    @unidade = Unidade.new
    @unidade.ativa.should == true
    @unidade.data_de_referencia.should == Date.today.to_s_br
    @unidade = Unidade.new :ativa=>false
    @unidade.ativa.should == false
  end
  
end

describe "Verifica se " do
  
  it "existe a entidade" do
    @unidade = unidades(:senaivarzeagrande)
    @unidade.entidade = nil
    @unidade.valid?
    @unidade.errors.on(:entidade).should_not be_nil
    @unidade.entidade = entidades(:senai)
    @unidade.valid?
    @unidade.errors.on(:entidade).should be_nil
  end
  
  it "existe relacionamento" do
    unidades(:sesivarzeagrande).servicos.should == [servicos(:curso_de_corel_do_sesi)]
    unidades(:sesivarzeagrande).parametro_conta_valores.should == [parametro_conta_valores(:two)]
    unidades(:sesivarzeagrande).contas_corrente.should == [contas_correntes(:segunda_conta)]
    unidades(:sesivarzeagrande).compromissos.should == [compromissos(:visitar_cliente)]
    
    unidades(:senaivarzeagrande).entidade.should == entidades(:senai)
    entidades(:senai).unidades.should == [unidades(:senaivarzeagrande)]
    unidades(:senaivarzeagrande).localidade.should == localidades(:primeira)
    localidades(:primeira).unidades.should == [unidades(:senaivarzeagrande)]
    unidades(:senaivarzeagrande).usuarios.should == usuarios(:quentin,:aaron,:juvenal)
    unidades(:senaivarzeagrande).pagamento_de_contas.should == pagamento_de_contas(:pagamento_cheque,:pagamento_dinheiro)
  end
  
  it "existe o data_br_field" do
    data = Date.today.to_s_br
    data.should == unidades(:senaivarzeagrande).data_de_referencia.to_date.to_s_br
  end
  
  it "existe o campo virtual cidade_e_estado e grava dados corretamente" do
    @unidade = unidades(:senaivarzeagrande) 
    @unidade.nome_localidade = "Varzea Grande - MT"
  end
  
  it "existe o campo virtual cidade_e_estado e grava string vazia" do
    @unidade = unidades(:senaivarzeagrande)
    @unidade.nome_localidade = ""
  end
 
  it "existe atributo virtual cidade_e_estado" do
    @unidade = unidades(:senaivarzeagrande)
    @unidade.nome_localidade.should == "VARZEA GRANDE - MT" 
  end
  
  it "apaga localidade quando vem string vazia no campo virtual cidade_e_estado" do
    @unidade = unidades(:senaivarzeagrande)
    @unidade.localidade.should == localidades(:primeira)
    @unidade.nome_localidade = ""
    @unidade.save
    @unidade.localidade_id.should == nil
  end
  
  it "nao apaga localidade quando vem nil no campo virtual cidade_e_estado" do
    @unidade = unidades(:senaivarzeagrande)
    @unidade.localidade_id.should == localidades(:primeira).id
    @nome_localidade = nil
    @unidade.save
    @unidade.localidade_id.should == localidades(:primeira).id
  end
  
  it "não apaga localidade se vem string diferente de vazia no campo virtual cidade_e_estado" do
    @unidade  = unidades(:senaivarzeagrande)
    @unidade.localidade.should == localidades(:primeira)
    @unidade.nome_localidade ="VARZEA GRANDE  - MT"
    @unidade.save
    @unidade.localidade.should == localidades(:primeira)
  end
  
  it "le cidade_estado quando não tem" do
    @unidade = Unidade.new
    @unidade.nome_localidade.should == nil
  end
    
  it "testa o metodo retorna_unidade_para_select" do
    Unidade.retorna_unidade_para_select.should == [[unidades(:senaivarzeagrande).nome,unidades(:senaivarzeagrande).id],[unidades(:sesivarzeagrande).nome,unidades(:sesivarzeagrande).id]]
  end
  
  it 'verifica se retorna o cnpj com máscara' do
    @unidade = unidades(:senaivarzeagrande)
    (@unidade.cnpj.to_s).should == '03.819.150/0004-62'
  end
  
  describe 'Campo telefone ' do

    it "deve retornar um array" do
      @unidade=Unidade.new
      @unidade.telefone.should == []
    end

    it "deve deletar telefones vazios" do
      @unidade = Unidade.new :telefone => ["33425712","",' ']
      @unidade.valid?
      @unidade.telefone.should == ["33425712"] 
    end
  end
  
end