require File.dirname(__FILE__) + '/../spec_helper'

describe ParcelasController do

  integrate_views

  before do
    login_as 'juliano'
  end

  it "teste da se está relacionando centro com a unidade organizacional" do
    login_as 'quentin'
    get :gerar_rateio, :id=>parcelas(:primeira_parcela),:pagamento_de_conta_id=>parcelas(:primeira_parcela).conta_id
    response.should be_success
    assigns[:parcela].should == parcelas(:primeira_parcela)
    response.should have_tag("form[method=?][action=?]", "get", gravar_rateio_pagamento_de_conta_parcela_path(parcelas(:primeira_parcela).conta_id, parcelas(:primeira_parcela).id)) do
      with_tag("script", %r{Ajax.Autocompleter.*dados_do_rateio_1_centro_nome.*\/centros\/auto_complete_for_centro.*dados_do_rateio_1_unidade_organizacional_id})
    end
  end

  it "teste da action gerar rateio e sua view para usuário com acesso e com a parcela baixada" do
    login_as 'quentin'
    get :gerar_rateio, :id=>parcelas(:primeira_parcela),:pagamento_de_conta_id=>parcelas(:primeira_parcela).conta_id
    response.should be_success
    assigns[:parcela].should == parcelas(:primeira_parcela)
    response.should have_tag("form[method=?][action=?]", "get", gravar_rateio_pagamento_de_conta_parcela_path(parcelas(:primeira_parcela).conta_id, parcelas(:primeira_parcela).id)) do
      with_tag("p","Itens do Rateio") do
        response.should_not have_tag("a[href=?][onclick*=?]","#","criaItemRateio")
      end
      with_tag("table[id=?]","itens_rateio") do
        with_tag("tbody[id=?]","tbody_itens_do_rateio") do
          with_tag("tr[class=?]","item_rateio") do
            with_tag("div[class=?]","div_explicativa")
            #Estes campos devem ter tamanho 30, para não estourar o layout
            with_tag("input[id=?][type=?]","dados_do_rateio_1_conta_contabil_id","hidden")
            with_tag("input[id=?][size=30]","dados_do_rateio_1_conta_contabil_nome")
            with_tag("input[id=?][type=?]","dados_do_rateio_1_unidade_organizacional_id","hidden")
            with_tag("input[id=?][size=30]","dados_do_rateio_1_unidade_organizacional_nome")
            with_tag("input[id=?][type=?]","dados_do_rateio_1_centro_id","hidden")
            with_tag("input[id=?][size=30]","dados_do_rateio_1_centro_nome")
            with_tag("input[id=?]","dados_do_rateio_1_valor")
            with_tag("td") do
              response.should_not have_tag("a[href=?][onclick*=?]","#",".remove","Excluir")
            end
            #            response.should have_tag("a[href=?]",estornar_parcela_baixada_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela).pagamento_de_conta_id,parcelas(:segunda_parcela).id),"Estornar Parcela")
          end
        end
      end
      with_tag("input[id=?][value=?]","replicar_para_todos","0")
      with_tag("span[id=?]","soma_total_do_rateio")
      with_tag("p") do
        response.should_not have_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
      end
    end
  end
  
  it "teste da action gerar rateio e sua view para usuário com acesso e parcela sem baixar" do
    login_as 'quentin'
    get :gerar_rateio, :id=>parcelas(:segunda_parcela),:pagamento_de_conta_id=>parcelas(:segunda_parcela).conta_id
    response.should be_success
    assigns[:parcela].should == parcelas(:segunda_parcela)
    response.should have_tag("form[method=?][action=?]","get",gravar_rateio_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela).conta_id,parcelas(:segunda_parcela).id)) do
      with_tag("p","Itens do Rateio \n    Incluir") do
        with_tag("a[href=?][onclick*=?]","#","criaItemRateio")
      end
      with_tag("table[id=?]","itens_rateio") do
        with_tag("tbody[id=?]","tbody_itens_do_rateio")
      end
      with_tag("input[id=?][value=?]","replicar_para_todos","0")
      with_tag("span[id=?]","soma_total_do_rateio")
      with_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
      with_tag("a[href=?]",pagamento_de_conta_path(parcelas(:segunda_parcela).conta_id),"Voltar")
      response.should_not have_tag("a[href=?]",estornar_parcela_baixada_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela).conta_id,parcelas(:segunda_parcela).id),"Estornar Parcela")
    end
  end
  
  it "teste da action gerar rateio e sua view para usuario sem acesso sem estar baixada e com rateio gravado" do
    login_as 'admin'
    get :gerar_rateio, :id=>parcelas(:segunda_parcela_sesi),:pagamento_de_conta_id=>parcelas(:segunda_parcela_sesi).conta_id
    response.should be_success
    assigns[:parcela].should == parcelas(:segunda_parcela_sesi)
    response.should have_tag("form[method=?][action=?]","get",gravar_rateio_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela_sesi).conta_id,parcelas(:segunda_parcela_sesi).id)) do
      with_tag("p","Itens do Rateio") do
        response.should_not have_tag("a[href=?][onclick*=?]","#","criaItemRateio")
      end
      with_tag("table[id=?]","itens_rateio") do
        with_tag("tbody[id=?]","tbody_itens_do_rateio") do
          with_tag("tr[class=?]","item_rateio") do
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?][type=?]","dados_do_rateio_1_unidade_organizacional_id","hidden")
            with_tag("input[id=?]","dados_do_rateio_1_unidade_organizacional_nome")
            with_tag("input[id=?][type=?]","dados_do_rateio_1_centro_id","hidden")
            with_tag("input[id=?]","dados_do_rateio_1_centro_nome")
            with_tag("input[id=?]","dados_do_rateio_1_valor")
            with_tag("td") do
              response.should_not have_tag("a[href=?][onclick*=?]","#",".remove","Excluir")
            end
          end
        end
      end
      with_tag("input[id=?][value=?]","replicar_para_todos","0")
      with_tag("span[id=?]","soma_total_do_rateio")
      with_tag("p") do
        response.should_not have_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
      end
    end
  end
  
  it "teste da action gerar rateio e sua view para usuario com acesso com parcela em aberto e com rateio gravado" do
    login_as 'quentin'
    get :gerar_rateio, :id=>parcelas(:segunda_parcela_sesi),:pagamento_de_conta_id=>parcelas(:segunda_parcela_sesi).conta_id
    response.should be_success
    assigns[:parcela].should == parcelas(:segunda_parcela_sesi)
    response.should have_tag("form[method=?][action=?]","get",gravar_rateio_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela_sesi).conta_id,parcelas(:segunda_parcela_sesi).id)) do
      response.should_not have_tag("p","Itens do Rateio +") do
        with_tag("a[href=?][onclick*=?]","#","criaItemRateio")
      end
      with_tag("table[id=?]","itens_rateio") do
        with_tag("tbody[id=?]","tbody_itens_do_rateio") do
          with_tag("tr[class=?]","item_rateio") do
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?][type=?]","dados_do_rateio_1_unidade_organizacional_id","hidden")
            with_tag("input[id=?]","dados_do_rateio_1_unidade_organizacional_nome")
            with_tag("input[id=?][type=?]","dados_do_rateio_1_centro_id","hidden")
            with_tag("input[id=?]","dados_do_rateio_1_centro_nome")
            with_tag("input[id=?]","dados_do_rateio_1_valor")
            response.should_not  have_tag("a[href=?][onclick*=?]","#",".remove","Excluir")
          end
        end
      end
      with_tag("input[id=?][value=?]","replicar_para_todos","0")
      with_tag("span[id=?]","soma_total_do_rateio")
      response.should_not have_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
      with_tag("a[href=?]",pagamento_de_conta_path(parcelas(:segunda_parcela_sesi).conta_id),"Voltar")
    end
  end
  
  it "teste da action gravar rateio quando passa um dados do rateio inválido" do
    login_as 'quentin'
    get :gravar_rateio, :id=>parcelas(:primeira_parcela),:pagamento_de_conta_id=>parcelas(:primeira_parcela).conta_id,:dados_do_rateio=>{"1"=>{"valor"=>"100.00","centro_id"=>centros(:centro_forum_social).id,"unidade_organizacional_id"=>unidade_organizacionais(:sesi_colider_unidade_organizacional).id}}
    response.should be_success
    response.should render_template('gerar_rateio')
  end

  it 'deve chamar o lancar impostos na parcela e exibir os links para lancar impostos na parcela e submit para quem tem acesso' do
    login_as 'quentin'
    parcela = parcelas(:segunda_parcela)
    get :lancar_impostos_na_parcela, :pagamento_de_conta_id=> parcela.conta_id , :id=>parcela.id
    response.should be_success
    assigns[:parcela].should == parcelas(:segunda_parcela)
    response.should render_template('lancar_impostos_na_parcela')
    response.should have_tag('table.listagem') do
      with_tag("thead") do
        with_tag("tr") do
          with_tag("th",'Número')
          with_tag("th",'Vencimento')
          with_tag("th",'Valor do Documento')
          with_tag("th",'Valor da Parcela')
          with_tag("th",'Valor Retido')
          with_tag("th",'Valor Líquido')
        end
      end
      with_tag("tr") do
        with_tag("td","SESICLUBE-VG-CPMF05/20093299")
        with_tag("td","30/05/2009")
        with_tag("td","R$ 100,01")
        with_tag("td","R$ 33,34")
        with_tag("td") do
          with_tag("span[id=?]","retido")
        end
        with_tag("td") do
          with_tag("span[id=?]","liquido")
        end
      end
    end
    response.should have_tag("form[action=?][method=?]",gravar_imposto_pagamento_de_conta_parcela_path(parcela.conta_id,parcela.id),"get") do
      response.should have_tag("p") do
        with_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
      end
      with_tag("table[id=?]","imposto_da_parcela") do
        with_tag("thead") do
          with_tag("tr") do
            with_tag("td[width=?]","150") do
              with_tag("b","Imposto")
            end
            with_tag("td[width=?]","220") do
              with_tag("b","Data de Recolhimento")
            end
            with_tag("td") do
              with_tag("b","Alíquota %")
            end
            with_tag("td") do
              with_tag("b","Valor R$")
            end
          end
        end
        with_tag("tfoot") do
          with_tag("tr") do
            with_tag("td[colspan=?][style=?]","4","text-align: right;") do
              with_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
            end
          end
        end
        with_tag("tbody[id=?]","tbody_itens_do_imposto") do
          with_tag("tr[id=?][class=?]","imposto_da_parcela_1","itens_do_imposto") do
            with_tag("td")
            with_tag("td") do
              with_tag("input[id=?][name=?]","dados_do_imposto_1_data_de_recolhimento","dados_do_imposto[1][data_de_recolhimento]")
              with_tag("img[alt=?][onclick*=?]","Calendar","new CalendarDateSelect")
            end
            with_tag("td") do
              with_tag("input[class=?][id=?][name=?][readonly=?][value=?]","aliquota","dados_do_imposto_1_aliquota","dados_do_imposto[1][aliquota]","readonly","5.0")
            end
            with_tag("td") do
              with_tag("input[class=?][id=?][name=?][value=?]","valor","dados_do_imposto_1_valor_imposto","dados_do_imposto[1][valor_imposto]","5,00")
            end
            with_tag("td") do
              with_tag("a[href=?][onclick*=?]","#",".remove","Excluir")
            end
          end
        end
      end
      with_tag("p") do
        with_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
        with_tag("a[href=?]",pagamento_de_conta_path(parcela.conta_id),"Voltar")
      end
      with_tag('script',%r{'dados_do_imposto_1_data_de_recolhimento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
      with_tag("script[type=?]","text/javascript")
    end
  end
  
  it 'deve chamar o lancar impostos na parcela e não exibir os links "lancar impostos na parcela" e "submit" para usuarios que não tem acesso' do
    login_as 'admin'
    parcela = parcelas(:segunda_parcela)
    get :lancar_impostos_na_parcela, :pagamento_de_conta_id=> parcela.conta_id , :id=>parcela.id
    response.should be_success
    assigns[:parcela].should == parcelas(:segunda_parcela)
    response.should render_template('lancar_impostos_na_parcela')
    response.should have_tag('table.listagem') do
      with_tag("thead") do
        with_tag("tr") do
          with_tag("th",'Número')
          with_tag("th",'Vencimento')
          with_tag("th",'Valor do Documento')
          with_tag("th",'Valor da Parcela')
          with_tag("th",'Valor Retido')
          with_tag("th",'Valor Líquido')
        end
      end
      with_tag("tr") do
        with_tag("td","SESICLUBE-VG-CPMF05/20093299")
        with_tag("td","30/05/2009")
        with_tag("td","R$ 100,01")
        with_tag("td","R$ 33,34")
        with_tag("td") do
          with_tag("span[id=?]","retido")
        end
        with_tag("td") do
          with_tag("span[id=?]","liquido")
        end
      end
    end
    response.should have_tag("form[action=?][method=?]", gravar_imposto_pagamento_de_conta_parcela_path(parcela.conta_id,parcela.id),"get") do
      response.should have_tag("p") do
        # Agora o admin tem acesso
        response.should have_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
        # response.should_not have_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
      end
      with_tag("table[id=?]","imposto_da_parcela") do
        with_tag("thead") do
          with_tag("tr") do
            with_tag("td[width=?]","150") do
              with_tag("b","Imposto")
            end
            with_tag("td[width=?]","220") do
              with_tag("b","Data de Recolhimento")
            end
            with_tag("td") do
              with_tag("b","Alíquota %")
            end
            with_tag("td") do
              with_tag("b","Valor R$")
            end
          end
        end
        with_tag("tfoot") do
          with_tag("tr") do
            with_tag("td[colspan=?][style=?]","4","text-align: right;") do
              # Agora o admin tem acesso
              response.should have_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
              # response.should_not have_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
            end
          end
        end
        with_tag("tbody[id=?]","tbody_itens_do_imposto") do
          with_tag("tr[id=?][class=?]","imposto_da_parcela_1","itens_do_imposto") do
            with_tag("td")
            with_tag("td") do
              with_tag("input[id=?][name=?]","dados_do_imposto_1_data_de_recolhimento","dados_do_imposto[1][data_de_recolhimento]")
              with_tag("img[alt=?][onclick*=?]","Calendar","new CalendarDateSelect")
            end
            with_tag("td") do
              with_tag("input[class=?][id=?][name=?]","aliquota","dados_do_imposto_1_aliquota","dados_do_imposto[1][aliquota]")
            end
            with_tag("td") do
              with_tag("input[class=?][id=?][name=?]","valor","dados_do_imposto_1_valor_imposto","dados_do_imposto[1][valor_imposto]")
            end
            with_tag("td")
          end
        end
      end
      with_tag("p") do
        # Agora o admin tem acesso
        response.should have_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
        # response.should_not have_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
        with_tag("a[href=?]",pagamento_de_conta_path(parcela.conta_id),"Voltar")
      end
      with_tag('script',%r{'dados_do_imposto_1_data_de_recolhimento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
      with_tag("script[type=?]","text/javascript")
    end
  end
  
  it 'deve chamar o lancar impostos na parcela e não exibir os links "lancar impostos na parcela" e "submit" para parcelas que estão baixadas' do
    login_as 'quentin'
    parcela = parcelas(:primeira_parcela)
    request.session[:unidade_id] = unidades(:sesivarzeagrande).id
    get :lancar_impostos_na_parcela, :pagamento_de_conta_id=> parcela.conta_id , :id=>parcela.id
    response.should be_success
    assigns[:parcela].should == parcelas(:primeira_parcela)
    response.should render_template('lancar_impostos_na_parcela')
    response.should have_tag('table.listagem') do
      with_tag("thead") do
        with_tag("tr") do
          with_tag("th",'Número')
          with_tag("th",'Vencimento')
          with_tag("th",'Valor do Documento')
          with_tag("th",'Valor da Parcela')
          with_tag("th",'Valor Retido')
          with_tag("th",'Valor Líquido')
        end
      end
      with_tag("tr") do
        with_tag("td","SESICLUBE-VG-CPMF05/20093299")
        with_tag("td","30/05/2009")
        with_tag("td","R$ 100,01")
        with_tag("td","R$ 33,33")
        with_tag("td") do
          with_tag("span[id=?]","retido")
        end
        with_tag("td") do
          with_tag("span[id=?]","liquido")
        end
      end
    end
    response.should have_tag("form[action=?][method=?]",gravar_imposto_pagamento_de_conta_parcela_path(parcela.conta_id,parcela.id),"get") do
      response.should have_tag("p") do
        response.should_not have_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
      end
      with_tag("table[id=?]","imposto_da_parcela") do
        with_tag("thead") do
          with_tag("tr") do
            with_tag("td[width=?]","150") do
              with_tag("b","Imposto")
            end
            with_tag("td[width=?]","220") do
              with_tag("b","Data de Recolhimento")
            end
            with_tag("td") do
              with_tag("b","Alíquota %")
            end
            with_tag("td") do
              with_tag("b","Valor R$")
            end
          end
        end
        with_tag("tfoot") do
          with_tag("tr") do
            with_tag("td[colspan=?][style=?]","4","text-align: right;") do
              response.should_not have_tag("a[href=?][onclick*=?]","#","criaImpostoDaParcela")
            end
          end
        end
        with_tag("tbody[id=?]","tbody_itens_do_imposto") do
          with_tag("tr[id=?][class=?]","imposto_da_parcela_1","itens_do_imposto") do
            with_tag("td")
            with_tag("td") do
              with_tag("input[id=?][name=?]","dados_do_imposto_1_data_de_recolhimento","dados_do_imposto[1][data_de_recolhimento]")
              with_tag("img[alt=?][onclick*=?]","Calendar","new CalendarDateSelect")
            end
            with_tag("td") do
              with_tag("input[class=?][id=?][name=?]","aliquota","dados_do_imposto_1_aliquota","dados_do_imposto[1][aliquota]")
            end
            with_tag("td") do
              with_tag("input[class=?][id=?][name=?]","valor","dados_do_imposto_1_valor_imposto","dados_do_imposto[1][valor_imposto]")
            end
            with_tag("td")
          end
        end
      end
      with_tag("p") do
        response.should_not have_tag("input[name=?][type=?][value=?]","commit","submit","Enviar")
        with_tag("a[href=?]",pagamento_de_conta_path(parcela.conta_id),"Voltar")
      end
      with_tag('script',%r{'dados_do_imposto_1_data_de_recolhimento'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
      with_tag("script[type=?]","text/javascript")
    end
  end
  
  it "teste da action baixa e sua view 1" do
    login_as 'quentin'
    get :baixa, :id => parcelas(:segunda_parcela), :pagamento_de_conta_id => parcelas(:segunda_parcela).conta_id
    assigns[:parcela].should == parcelas(:segunda_parcela)
    response.should be_success
    
    response.should have_tag("form[action=?]", gravar_baixa_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela).conta_id,parcelas(:segunda_parcela).id)) do
      with_tag("td") do
        with_tag("input[id=?][onchange=?]", 'parcela_data_da_baixa', %r{new Ajax.Request.*\/parcelas.*\/atualiza_juros.*})
      end
      with_tag("table") do
        with_tag("tbody[id=?]","tbody_valores") do
          with_tag("tr") do
            with_tag("td") do
              with_tag("b","Desconto")
              with_tag("div[class=?]","div_explicativa")
              #Estas tags devem ter tamanho 30, para não estourar o layout
              with_tag("input[id=?]","parcela_conta_contabil_desconto_id")
              with_tag("input[id=?][size=30]","parcela_nome_conta_contabil_desconto")
              with_tag("input[id=?]","parcela_centro_desconto_id")
              with_tag("input[id=?][size=30]","parcela_nome_centro_desconto")
              with_tag("input[id=?]","parcela_unidade_organizacional_desconto_id")
              with_tag("input[id=?][size=30]","parcela_nome_unidade_organizacional_desconto")
            end
            with_tag("td") do
              with_tag("b","Multa")
              with_tag("div[class=?]","div_explicativa")
              with_tag("input[id=?]","parcela_centro_multa_id")
              with_tag("input[id=?]","parcela_nome_centro_multa")
              with_tag("div[class=?]","div_explicativa")
              with_tag("input[id=?]","parcela_unidade_organizacional_multa_id")
              with_tag("input[id=?]","parcela_nome_unidade_organizacional_multa")
            end
          end
          with_tag("tr") do
            with_tag("td") do
              with_tag("span[id=?]","soma_total_da_parcela")
            end
          end
        end
      end
      with_tag('script',%r{'parcela_data_da_baixa'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})      
      with_tag("input[id=?][type=?]","valor_total_da_parcela","hidden")
      with_tag("span[id=?]","justificativa_outros") do
        with_tag("input[id=?]","parcela_justificativa_para_outros")
      end

      response.should_not have_tag("a[href=?]",estornar_parcela_baixada_pagamento_de_conta_parcela_path(parcelas(:segunda_parcela).conta_id,parcelas(:segunda_parcela).id),"Estornar Parcela")
      with_tag("table") do
        with_tag("tr[id=?]","tr_numero_do_cartao") do
          with_tag("td") do
            with_tag("input[id=?]","parcela_cartoes_attributes_1_numero") 
          end
        end
        with_tag("tr[id=?]","tr_bandeira") do
          with_tag("td") do
            with_tag("select[id=?]","parcela_cartoes_attributes_1_bandeira") 
          end
        end
        with_tag("tr[id=?]","tr_de_numero_comprovante") do
          with_tag("td") do
            with_tag("input[id=?]","parcela_numero_do_comprovante") 
          end
        end     
        with_tag("tr[id=?]","tr_nome_conta") do
          with_tag("td") do
            with_tag("input[id=?]","parcela_cheques_attributes_0_conta") 
          end
        end     
      end

      response.should_not have_tag("a[href=?][onclick*=?]",'#','form_para_estornar_parcela_baixada',"Estornar Parcela")

    end
  end

  it "teste da action baixa e a view de banco no pagamento de conta" do
    login_as 'quentin'
    get :baixa, :id => parcelas(:primeira_parcela), :pagamento_de_conta_id => parcelas(:primeira_parcela).conta_id
    assigns[:parcela].should == parcelas(:primeira_parcela)
    response.should be_success

    with_tag("tr[id=?]", "tr_de_data_pagamento")
    with_tag("tr[id=?]", "tr_de_numero_comprovante")
  end

  it "teste da action baixa e a view de banco no recebimento de conta" do
    login_as 'quentin'
    get :baixa, :id => parcelas(:primeira_parcela_recebimento), :recebimento_de_conta_id => parcelas(:primeira_parcela_recebimento).conta_id
    assigns[:parcela].should == parcelas(:primeira_parcela_recebimento)
    response.should be_success

    response.should_not have_tag("tr[id=?]", "tr_de_data_pagamento")
    response.should_not have_tag("tr[id=?]", "tr_de_numero_comprovante")
  end

  describe 'deve calcular os juros e multas e' do
    it "exibir os dados calculados quando estiver mostrando a view pela primeira vez" do
      login_as 'quentin'
      p = parcelas(:primeira_parcela_recebimento)
      p.valor_da_multa.should == 0
      p.valor_dos_juros.should == 0
      p.data_vencimento = '01/01/2008'
      p.save false

      Date.stub!(:today).and_return(Date.new 2008, 1, 2)

      get :baixa, :id => p.id, :recebimento_de_conta_id => p.conta_id
      assigns[:parcela].should == p
      response.should be_success
      response.should have_tag("form[action=?]",gravar_baixa_recebimento_de_conta_parcela_path(p.conta_id, p.id)) do
        with_tag("input[name=?][value=?]", "parcela[valor_da_multa_em_reais]", '0,60')
        with_tag("input[name=?][value=?]", "parcela[valor_dos_juros_em_reais]", '0,01')
        with_tag('script',%r{'parcela_data_da_baixa'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})  
      end
    end

    it "reexibir os dados digitados quando estiver mostrando a view pela segunda vez" do
      login_as 'quentin'
      p = parcelas(:primeira_parcela_recebimento)
      p.valor_da_multa.should == 0
      p.valor_dos_juros.should == 0
      p.data_vencimento = '01/01/2008'
      p.save false

      Date.stub!(:today).and_return(Date.new 2008, 1, 2)

      post :gravar_baixa, :id => p.id, :parcela => {:valor_dos_juros_em_reais => "5,00", :valor_da_multa_em_reais => "4,00"}, :recebimento_de_conta_id => p.conta_id
      assigns[:parcela].should == p
      response.should be_success

      response.should have_tag("form[action=?]",gravar_baixa_recebimento_de_conta_parcela_path(p.conta_id, p.id)) do
        with_tag("input[name=?][value=?]", "parcela[valor_da_multa_em_reais]", '4,00')
        with_tag("input[name=?][value=?]", "parcela[valor_dos_juros_em_reais]", '5,00')
      end
    end
  end

  it "teste da action baixa e sua view" do
    login_as 'quentin'
    get :baixa, :id=>parcelas(:primeira_parcela).id,:pagamento_de_conta_id=>parcelas(:primeira_parcela).conta_id
    assigns[:parcela].should == parcelas(:primeira_parcela)
    response.should be_success
    response.should have_tag("form[action=?]",gravar_baixa_pagamento_de_conta_parcela_path(parcelas(:primeira_parcela).conta_id,parcelas(:primeira_parcela).id)) do
      response.should have_tag("a[href=?][onclick*=?]",'#','form_para_estornar_parcela_baixada',"Estornar Parcela")
    end
    response.should have_tag("div[id=?]",'form_para_estornar_parcela_baixada') do
      with_tag("form[action=?][method=?]",estornar_parcela_baixada_pagamento_de_conta_parcela_path(parcelas(:primeira_parcela).conta_id,parcelas(:primeira_parcela).id),'post')
      with_tag("input[type=?]",'submit')
      with_tag("a[href=?][onclick*=?]",'#','form_para_estornar_parcela_baixada',"Cancelar")
    end
    with_tag('script',%r{'parcela_data_da_baixa'.*onkeyup.*AplicaMascara.*'XX/XX/XXXX'})
    response.should_not have_tag("div[id=?]",'form_para_senha_dr')
  end

  it "teste da action baixa e sua view para recebimento" do
    login_as 'quentin'
    get :baixa, :id=>parcelas(:primeira_parcela_recebimento).id,:recebimento_de_conta_id=>parcelas(:primeira_parcela_recebimento).conta_id
    assigns[:parcela].should == parcelas(:primeira_parcela_recebimento)
    response.should be_success
  end

  it "testa a action cancelar" do
    login_as 'quentin'
    get :cancelar, :id => parcelas(:primeira_parcela_recebimento).id, :recebimento_de_conta_id => parcelas(:primeira_parcela_recebimento).conta_id
    response.body.should include('window.location.reload()')
  end

  describe "se o contrato estiver cancelado" do

    before do
      login_as 'quentin'
      @parcela = parcelas(:primeira_parcela_recebimento)
      @parcela.conta.situacao = RecebimentoDeConta::Cancelado
      @parcela.conta.rateio = 1
      @parcela.conta.save
    end

    after do
      assigns[:recebimento_de_conta].should == @parcela.conta
      response.should redirect_to(login_path)
    end

    [:gravar_baixa, :estornar_parcela_baixada, :gravar_rateio,
      :lancar_impostos_na_parcela, :gravar_imposto].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @parcela, :recebimento_de_conta_id => @parcela.conta_id
      end
    end

  end

  describe "se a parcela estiver cancelada" do

    before do
      login_as 'quentin'
      @parcela = parcelas(:primeira_parcela)
      @parcela.situacao = 3
      @parcela.save
    end

    after do
      assigns[:parcela].should == @parcela
      response.should redirect_to(login_path)
    end

    [:baixa, :gravar_baixa, :estornar_parcela_baixada, :gerar_rateio, :gravar_rateio,
      :lancar_impostos_na_parcela, :gravar_imposto].each do |action|

      it "não deve liberar a action de #{action}" do
        get action, :id => @parcela, :pagamento_de_conta_id => @parcela.conta_id

      end
    end

  end

  it 'deve gravar impostos na parcela' do
    LancamentoImposto.delete_all
    lancamento_imposto = LancamentoImposto.count
    conta = pagamento_de_contas(:pagamento_cheque)
    conta.valor_do_documento = 5001
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas = false
    conta.numero_de_controle = nil
    conta.usuario_corrente = usuarios(:quentin)
    conta.ano_contabil_atual = 2009
    conta.save!
    conta.gerar_parcelas(2009)
    parcela = Parcela.last
    imposto = impostos(:iss)
    dados_do_imposto = {"1"=>{"data_de_recolhimento"=>"27/05/2009", "valor_imposto"=>"10.80", "imposto_id"=>"#{imposto.id}#3.6", "aliquota"=>"3.6"}}
    request.session[:ano] = 2009
    get :gravar_imposto, :pagamento_de_conta_id => parcela.conta_id, :id => parcela.id, :dados_do_imposto => dados_do_imposto
    assigns[:entidade].should == entidades(:sesi)
    LancamentoImposto.count.should == lancamento_imposto + 1
    response.should redirect_to(pagamento_de_conta_path(parcela.conta.id))
  end

  it 'nao deve gravar os impostos na parcela' do
    parcela = Parcela.new  :data_vencimento=>'04-06-2009', :conta=> pagamento_de_contas(:pagamento_cheque), :valor=> 5001
    parcela.save!
    imposto = impostos(:iss)
    dados_do_imposto = {"1"=>{"imposto_id"=>imposto.id,"data_de_recolhimento"=>"","aliquota"=>imposto.aliquota,"valor"=>"30"}}
    get :gravar_imposto, :pagamento_de_conta_id => parcela.conta_id , :id => parcela.id,:dados_do_imposto => dados_do_imposto
    assigns[:entidade].should == entidades(:sesi)
    response.should render_template('lancar_impostos_na_parcela')
  end
  
  it 'verifica se valida os dados antes de gravar os impostos na parcela' do
    parcela= Parcela.new  :data_vencimento=>'04-06-2009', :conta=> pagamento_de_contas(:pagamento_cheque), :valor=> 5001
    parcela.save!
    imposto = impostos(:ipi)
    dados_do_imposto = {"1"=>{"imposto_id"=>imposto.id,"valor_imposto"=>"2000", "aliquota"=>"50","data_de_recolhimento"=>"01/01/2009"},
      "2"=>{"imposto_id"=>imposto.id,"valor_imposto"=>"2000", "aliquota"=>"50","data_de_recolhimento"=>"01/02/2009"},
      "3"=>{"imposto_id"=>imposto.id,"valor_imposto"=>"2000", "aliquota"=>"50","data_de_recolhimento"=>"01/03/2009"}}
    get :gravar_imposto, :pagamento_de_conta_id=> parcela.conta_id , :id=>parcela.id, :dados_do_imposto=>dados_do_imposto
    response.should be_success
    assigns[:entidade].should == entidades(:sesi)
    response.should render_template('lancar_impostos_na_parcela')
    response.should have_tag('select[name=?]','dados_do_imposto[1][imposto_id]') do
      with_tag('option[value=?][selected=?]',"#{imposto.id}#50.0##{imposto.classificacao}",'selected','IPI-PF-50%')
    end
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[1][data_de_recolhimento]','01/01/2009')
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[1][aliquota]','50')
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[1][valor_imposto]','2000')
    response.should have_tag('select[name=?]','dados_do_imposto[2][imposto_id]') do
      with_tag('option[value=?][selected=?]',"#{imposto.id}#50.0##{imposto.classificacao}",'selected','IPI-PF-50%')
    end
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[2][data_de_recolhimento]','01/02/2009')
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[2][aliquota]','50')
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[2][valor_imposto]','2000')
    response.should have_tag('select[name=?]','dados_do_imposto[3][imposto_id]') do
      with_tag('option[value=?][selected=?]',"#{imposto.id}#50.0##{imposto.classificacao}",'selected','IPI-PF-50%')
    end
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[3][data_de_recolhimento]','01/03/2009')
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[3][aliquota]','50')
    response.should have_tag('input[name=?][value=?]','dados_do_imposto[3][valor_imposto]','2000')
  end
  
  it "verifica se estorna a parcela e gera follow-up" do
    login_as "quentin"
    usuario = usuarios(:quentin)
    conta = pagamento_de_contas(:pagamento_cheque)
    conta.valor_do_documento = 10000
    conta.numero_de_parcelas = 1
    conta.parcelas_geradas = false
    conta.numero_de_controle = nil
    conta.usuario_corrente = usuario
    conta.ano_contabil_atual = 2009
    conta.save!
    conta.gerar_parcelas(2009)
    parcela = Parcela.last
    parcela.data_da_baixa = '05/05/2010'
    parcela.baixando = true
    parcela.historico = conta.historico
    parcela.forma_de_pagamento = 1
    parcela.ano_contabil_atual = 2009
    parcela.save!
    get :estornar_parcela_baixada,:pagamento_de_conta_id=> parcela.conta_id , :id=>parcela.id
  end
  
  it "verifica se carrega os recibos para impressão" do
    login_as "quentin"
    post :listar_recibos, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_corel_do_paulo).id
    response.should be_success
  end
  
  it "verifica se redireciona caso não exista algum recibo pra receber" do
    login_as "quentin"
    post :listar_recibos, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_design_do_paulo).id
    response.should redirect_to(recebimento_de_conta_path(recebimento_de_contas(:curso_de_design_do_paulo).id))
  end
   
  it "verifica se imprime recibo das parcelas quando existem parcelas selecionadas" do
    login_as :quentin
    parcelas(:primeira_parcela_recebimento).valor_liquido = 3000
    parcelas(:primeira_parcela_recebimento).save false
    recebimento_de_contas(:curso_de_tecnologia_do_paulo).reload
    data = '01/05/2009'
    recibo = [parcelas(:primeira_parcela_recebimento).id]
    post :imprimir_recibos,:recebimento_de_conta_id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id,:data => data,:recibo_impresso => recibo, :format=>'pdf'
    response.should be_success
  end
  
  it "verifica se redireciona quando não existem parcelas selecionadas" do
    login_as :quentin
    parcelas(:primeira_parcela_recebimento).valor_liquido = 3000
    parcelas(:primeira_parcela_recebimento).save false
    recebimento_de_contas(:curso_de_tecnologia_do_paulo).reload
    data = '01/05/2009'
    post :imprimir_recibos,:recebimento_de_conta_id => recebimento_de_contas(:curso_de_tecnologia_do_paulo).id,:data => data
    response.should redirect_to(listar_recibos_recebimento_de_conta_parcelas_path(recebimento_de_contas(:curso_de_tecnologia_do_paulo).id))
  end

  describe 'verifica se parcela esta renegociada' do

    before do
      login_as 'quentin'
      @parcela = parcelas(:segunda_parcela_recebimento)
      @parcela.situacao = Parcela::RENEGOCIADA
      @parcela.save false
    end

    after do
      assigns[:parcela].should == @parcela
      response.should redirect_to(recebimento_de_conta_path(@parcela.conta.id))
    end

    [:baixa, :gravar_baixa, :estornar_parcela_baixada, :lancar_impostos_na_parcela, :gravar_imposto].each do |action|      
      it "não deve liberar a action de #{action}" do
        get action, :id => @parcela, :recebimento_de_conta_id => @parcela.conta_id
      end
    end
      
  end
  
  describe 'verificase se a parcela está renegociada com rateio' do

    before do
      login_as 'quentin'
      @parcela = parcelas(:segunda_parcela_recebimento)
      conta = @parcela.conta
      conta.rateio = 1
      conta.save false      
      @parcela.situacao = Parcela::RENEGOCIADA
      @parcela.save false
    end

    after do
      assigns[:parcela].should == @parcela
      response.should redirect_to(recebimento_de_conta_path(@parcela.conta.id))
    end

    [:gerar_rateio, :gravar_rateio].each do |action|     
      it "não deve liberar a action de #{action}" do
        get action, :id => @parcela, :recebimento_de_conta_id => @parcela.conta_id
      end
    end

  end

  describe "Action atualiza juros" do

    it 'chamando action atualiza juros' do
      @parcela = parcelas(:segunda_parcela_recebimento)
      # VENCIMENTO EM 05/08/2009
      post :atualiza_juros, :data => '05/09/2009', :id => @parcela.id, :recebimento_de_conta_id => @parcela.conta_id, :tipo_de_data => 'data_da_baixa'
      response.should be_success
      response.body.should include('$("parcela_valor_da_multa_em_reais").value = "0.60"')
      response.body.should include('$("parcela_valor_dos_juros_em_reais").value = "0.31"')
    end

    it 'chamando action atualiza juros sem que ocorram alterações' do
      @parcela = parcelas(:segunda_parcela_recebimento)
      # VENCIMENTO EM 05/08/2009
      post :atualiza_juros, :data => '05/08/2009', :id => @parcela.id, :recebimento_de_conta_id => @parcela.conta_id, :tipo_de_data => 'data_da_baixa'
      response.should be_success
      response.body.should include('$("parcela_valor_da_multa_em_reais").value = "0.00"')
      response.body.should include('$("parcela_valor_dos_juros_em_reais").value = "0.00"')
    end

  end

  describe "Testa filtro de contrato inativo para parcelas" do

    before do
      login_as 'quentin'
      request.session[:unidade_id] = unidades(:senaivarzeagrande).id
      @recebimento_de_conta = recebimento_de_contas(:curso_de_design_do_paulo)
    end

    it "testa o filtro de contrato inativo" do
      @recebimento_de_conta.cancelar_contrato(usuarios(:quentin))
      get :lancar_impostos_na_parcela, :id => @recebimento_de_conta.parcelas.first.id, :recebimento_de_conta_id => @recebimento_de_conta.id
      response.should redirect_to(recebimento_de_conta_path(@recebimento_de_conta.id))
    end

    it "deve liberar para a action listar_recibos" do
      @recebimento_de_conta.cancelar_contrato(usuarios(:quentin))
      get :listar_recibos, :recebimento_de_conta_id => @recebimento_de_conta.id
      request.session[:flash][:notice].should == "Não existem parcelas baixadas para impressão de recibo."
      response.should redirect_to(recebimento_de_conta_path(@recebimento_de_conta.id))
    end

  end

  it "teste da action baixa e a view com honorarios, protesto e taxa de boleto quando recebimento" do
    login_as 'quentin'
    get :baixa, :id => parcelas(:primeira_parcela_recebimento).id, :recebimento_de_conta_id => parcelas(:primeira_parcela_recebimento).conta_id
    assigns[:parcela].should == parcelas(:primeira_parcela_recebimento)
    response.should be_success

    with_tag("table") do
      with_tag("tbody[id=?]","tbody_valores") do
        with_tag("tr") do
          with_tag("td") do
            with_tag("b","Desconto")
            with_tag("div[class=?]","div_explicativa")
            #Estas tags devem ter tamanho 30, para não estourar o layout
            with_tag("input[id=?]","parcela_conta_contabil_desconto_id")
            with_tag("input[id=?][size=30]","parcela_nome_conta_contabil_desconto")
            with_tag("input[id=?]","parcela_centro_desconto_id")
            with_tag("input[id=?][size=30]","parcela_nome_centro_desconto")
            with_tag("input[id=?]","parcela_unidade_organizacional_desconto_id")
            with_tag("input[id=?][size=30]","parcela_nome_unidade_organizacional_desconto")
          end
          with_tag("td") do
            with_tag("b","Multa")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_centro_multa_id")
            with_tag("input[id=?]","parcela_nome_centro_multa")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_unidade_organizacional_multa_id")
            with_tag("input[id=?]","parcela_nome_unidade_organizacional_multa")
          end
          with_tag("td") do
            with_tag("b","Juros")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_centro_juros_id")
            with_tag("input[id=?]","parcela_nome_centro_juros")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_unidade_organizacional_juros_id")
            with_tag("input[id=?]","parcela_nome_unidade_organizacional_juros")
          end
          with_tag("td") do
            with_tag("b","Outros")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_centro_outros_id")
            with_tag("input[id=?]","parcela_nome_centro_outros")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_unidade_organizacional_outros_id")
            with_tag("input[id=?]","parcela_nome_unidade_organizacional_outros")
          end
          with_tag("td") do
            with_tag("b","Honorarios")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_centro_honorarios_id")
            with_tag("input[id=?]","parcela_nome_centro_honorarios")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_unidade_organizacional_honorarios_id")
            with_tag("input[id=?]","parcela_nome_unidade_organizacional_honorarios")
          end
          with_tag("td") do
            with_tag("b","Protesto")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_centro_protesto_id")
            with_tag("input[id=?]","parcela_nome_centro_multa")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_unidade_organizacional_protesto_id")
            with_tag("input[id=?]","parcela_nome_unidade_organizacional_protesto")
          end
          with_tag("td") do
            with_tag("b","Taxa boleto")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_centro_taxa_boleto_id")
            with_tag("input[id=?]","parcela_nome_centro_taxa_boleto")
            with_tag("div[class=?]","div_explicativa")
            with_tag("input[id=?]","parcela_unidade_organizacional_taxa_boleto_id")
            with_tag("input[id=?]","parcela_nome_unidade_organizacional_taxa_boleto")
          end
        end
        with_tag("tr") do
          with_tag("td") do
            with_tag("span[id=?]","soma_total_da_parcela")
          end
        end
      end
    end
  end

  it 'testa baixa do DR quando a senha está correta' do
    login_as 'quentin'
    get :baixa_dr, :id => parcelas(:primeira_parcela_recebimento), :recebimento_de_conta_id => parcelas(:primeira_parcela_recebimento).conta_id, :senha => 'teste'
    assigns[:parcela].should == parcelas(:primeira_parcela_recebimento)
    flash[:notice].should == "Baixa DR efetuada com sucesso!"
    response.should redirect_to(recebimento_de_conta_path(parcelas(:primeira_parcela_recebimento).conta.id))
  end

  it 'testa baixa do DR quando a senha está errada' do
    login_as 'quentin'
    get :baixa_dr, :id => parcelas(:primeira_parcela_recebimento), :recebimento_de_conta_id => parcelas(:primeira_parcela_recebimento).conta_id, :senha => 'dasdasd'
    assigns[:parcela].should == parcelas(:primeira_parcela_recebimento)
    response.should be_success
    response.flash.now[:notice].should == "A senha digitada não está correta, verifique!"
    response.should render_template('baixa')
  end

  it "teste da action de gravar baixa parcial" do
    login_as :quentin
    p = parcelas(:primeira_parcela_recebimento)
    p.valor_da_multa.should == 0
    p.valor_dos_juros.should == 0
    params = {"parcela_data_da_baixa" => "19/03/2009", "data_vencimento" => "01/01/2008", "parcela_forma_de_pagamento" => "1",
      "valor_liquido" => "25,00", "historico" => "Teste de baixa", "parcela_id" => p.id.to_s, "recebimento_de_conta_id" => p.conta_id.to_s,
      "id" => p.conta_id, "parcela" => {"cartoes_attributes"=>{"1"=>{"nome_do_titular"=>"", "codigo_de_seguranca"=>"",
            "numero"=>"", "bandeira"=>"", "validade"=>""}}, "cheques_attributes"=>{"0"=>{"banco_id"=>"243949021",
            "prazo"=>"", "agencia"=>"", "conta_contabil_transitoria_nome"=>"", "nome_do_titular"=>"",
            "conta_contabil_transitoria_id"=>"", "conta"=>"", "data_para_deposito"=>"", "numero"=>""}}}}
    post :baixa_parcial, params

    response.should be_success
  end

end