require File.dirname(__FILE__) + '/../spec_helper'

describe PlanoDeContasController do

  before do
    login_as 'quentin'
  end

  it "testa auto_complete para conta_contabil do SESI " do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_conta_contabil , :argumento=>'a'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 3
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id}", "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).codigo_contabil} - Contribuicoes Regul. oriundas do SESI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_despesas).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_despesas).id}", "#{plano_de_contas(:plano_de_contas_ativo_despesas).codigo_contabil} - Despesas do SESI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", false)
    end
  end

  it "testa auto_complete para conta_contabil com termina_em" do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_conta_contabil , :argumento=>'*oriundas'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 0
    end
  end

  it "testa auto_complete para conta_contabil do SENAI" do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_conta_contabil , :argumento=>'a'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 8
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - Contribuicoes Regul. oriundas do SENAI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_despesas_senai).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_despesas_senai).id}", "#{plano_de_contas(:plano_de_contas_ativo_despesas_senai).codigo_contabil} - Despesas do SENAI")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_ativo_caixa).id}","11010101001 - Caixa")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id}","11010102001 - Conta bancária no Banco do Brasil")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_passivo_a_pagar).id}","21010101009 - Fornecedores a Pagar")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}","3101123456 - Impostos a Pagar")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}","41010101008 - Contribuicoes Regul. oriundas do SENAI")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_devolucao).id}","22343456 - Devolucoes do SENAI")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_para_boleto).id}","22343456 - Conta Contábil SENAI Caixa")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id}", false)
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_despesas).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_despesas).id}", false)
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo).id}", false)
    end
  end

  it "testa auto_complete para conta_contabil '1 " do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_conta_contabil , :argumento=>'1'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 6
      with_tag("li[id=?]", "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - Contribuicoes Regul. oriundas do SENAI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_despesas_senai).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_despesas_senai).id}", "#{plano_de_contas(:plano_de_contas_ativo_despesas_senai).codigo_contabil} - Despesas do SENAI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id}", false)
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_despesas).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_despesas).id}", false)
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo).id}", false)
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_ativo_caixa).id}","11010101001 - Caixa")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_ativo_conta_bancaria).id}","11010102001 - Conta bancária no Banco do Brasil")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_passivo_a_pagar).id}","21010101009 - Fornecedores a Pagar")
      with_tag("li[id=?]", "1_#{plano_de_contas(:plano_de_contas_passivo_impostos_pagar).id}","3101123456 - Impostos a Pagar")
    end
  end

  it "testa auto_complete para conta_contabil '1' SENAI " do
    request.session[:unidade_id] = unidades(:senaivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_conta_contabil , :argumento=>'contrib'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 1
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).codigo_contabil} - Contribuicoes Regul. oriundas do SENAI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id}", false)
    end
  end

  it "testa auto_complete de contas contábeis" do
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    request.session[:ano] = "2009"
    post :auto_complete_for_conta_contabil, :argumento => 'sesi'
    response.should be_success
    response.should have_tag("ul") do
      with_tag 'li', 2
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).id}", "#{plano_de_contas(:plano_de_contas_ativo_contribuicoes_sesi).codigo_contabil} - Contribuicoes Regul. oriundas do SESI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_despesas).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_despesas).id}", "#{plano_de_contas(:plano_de_contas_ativo_despesas).codigo_contabil} - Despesas do SESI")
      with_tag("li[id=?]","#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).tipo_da_conta}_#{plano_de_contas(:plano_de_contas_ativo_contribuicoes).id}", false)
    end
  end

end
