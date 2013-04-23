require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjecoesController do

  describe "GET 'index'" do
    integrate_views

    it "deve retornar dados da projeção" do
      obj_para_calcular_juros_e_multas = parcelas(:primeira_parcela_recebimento)
      valores_de_juros_e_multas = Gefin.calcular_juros_e_multas(:vencimento => obj_para_calcular_juros_e_multas.data_vencimento.to_date,
        :data_base => Date.today, :valor => obj_para_calcular_juros_e_multas.valor,
        :juros => obj_para_calcular_juros_e_multas.conta.juros_por_atraso, :multa => obj_para_calcular_juros_e_multas.conta.multa_por_atraso)

      obj_para_calcular_juros_e_multas_de_outra_parcela = parcelas(:segunda_parcela_recebimento)
      valores_de_juros_e_multas_da_outra_parcela = Gefin.calcular_juros_e_multas(:vencimento => obj_para_calcular_juros_e_multas_de_outra_parcela.data_vencimento.to_date,
        :data_base => Date.today, :valor => obj_para_calcular_juros_e_multas_de_outra_parcela.valor,
        :juros => obj_para_calcular_juros_e_multas_de_outra_parcela.conta.juros_por_atraso, :multa => obj_para_calcular_juros_e_multas_de_outra_parcela.conta.multa_por_atraso)

      login_as :quentin
      get :show, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_design_do_paulo).id
      response.should be_success

#     puts response.body

      response.should have_tag('form') do
        with_tag 'tbody' do
          with_tag 'tr', 2 #2 parcelas em aberto
          with_tag 'tr[id=?]', "parcela_#{parcelas(:primeira_parcela_recebimento).id}" do
            with_tag 'input[name=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][selecionada]"
            with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][data_vencimento]", '05/07/2009'
            with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][indice]", '0,00'
            with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][retorna_valor_de_correcao_pelo_indice_em_reais]", '0,00'
            with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][preco_em_reais]", '30,00'
            with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][valor_dos_juros_em_reais]", (valores_de_juros_e_multas[0].to_f / 100).to_s.gsub(".",",")
            # Não pude usar o (valores_de_juros_e_multas[1].to_f / 100) pois ele arredonda o 0, e na view está apresentado como 0.60 e nao 0.6
            with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][valor_da_multa_em_reais]", '0,60'
            with_tag 'input[name=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][valor_liquido_em_reais]"
          end
        end
        with_tag 'input[name=?][value=?]', "data_base", Date.today.to_s_br
        with_tag 'input[name=?][value=?]', "total_indices", '0.0'
        with_tag 'input[name=?][value=?]', "total_parcelas", '0.0'
        with_tag 'input[name=?][value*=?]', "total_geral", (valores_de_juros_e_multas[2] + valores_de_juros_e_multas_da_outra_parcela[2]).to_f / 100
        with_tag 'input[name=?][value=?]', 'total_juros_selecionadas', '0.0'
        with_tag 'input[name=?][value*=?]', 'total_juros', (valores_de_juros_e_multas[0] + valores_de_juros_e_multas_da_outra_parcela[0]).to_f / 100
        with_tag 'input[name=?][value=?]', 'total_multas_selecionadas', '0.0'
        with_tag 'input[name=?][value=?]', 'total_multas', '1.2'
      end
    end


  end

  describe 'deve atualizar os dados via AJAX no update e' do

    it 'não atualizar nada que não esteja selecionado' do
      login_as :quentin
      put :update, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_design_do_paulo).id, :recebimento_de_conta => {:parcelas => {
          parcelas(:primeira_parcela_recebimento).id.to_s => {:indice => "6.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => '01/01/2009', :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'},
          parcelas(:segunda_parcela_recebimento).id.to_s  => {:indice => "5.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => '01/02/2009', :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'}}},
        :data_base => "01/06/2009", :acao => 'Calcular'
      response.should be_success
      # Agora atualiza
      # response.should_not have_rjs(:replace, "parcela_#{parcelas(:primeira_parcela_recebimento).id}")
      response.should have_rjs(:replace, "parcela_#{parcelas(:primeira_parcela_recebimento).id}")
      # Agora atualiza
      # response.should_not have_rjs(:replace, "parcela_#{parcelas(:segunda_parcela_recebimento).id}")
      response.should have_rjs(:replace, "parcela_#{parcelas(:segunda_parcela_recebimento).id}")
    end

    it 'atualizar as duas parcelas selecionadas considerando alterações na parcela' do
      obj_para_calcular_juros_e_multas = parcelas(:primeira_parcela_recebimento)
      valores_de_juros_e_multas = Gefin.calcular_juros_e_multas(:vencimento => Date.today,
        :data_base => Date.today + 10.month, :valor => obj_para_calcular_juros_e_multas.valor,
        :juros => obj_para_calcular_juros_e_multas.conta.juros_por_atraso, :multa => obj_para_calcular_juros_e_multas.conta.multa_por_atraso)

      obj_para_calcular_juros_e_multas_de_outra_parcela = parcelas(:segunda_parcela_recebimento)
      valores_de_juros_e_multas_da_outra_parcela = Gefin.calcular_juros_e_multas(:vencimento => Date.today + 1.month,
        :data_base => Date.today + 10.month, :valor => obj_para_calcular_juros_e_multas_de_outra_parcela.valor,
        :juros => obj_para_calcular_juros_e_multas_de_outra_parcela.conta.juros_por_atraso, :multa => obj_para_calcular_juros_e_multas_de_outra_parcela.conta.multa_por_atraso)

      login_as :quentin
      put :update, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_design_do_paulo).id, :recebimento_de_conta => {:parcelas => {
          parcelas(:primeira_parcela_recebimento).id.to_s => {:indice => "6.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => Date.today.to_s_br, :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00', :selecionada => '1'},
          parcelas(:segunda_parcela_recebimento).id.to_s  => {:indice => "5.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => (Date.today + 1.month).to_s_br, :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00', :selecionada => '1'}}},
        :data_base => (Date.today + 10.month).to_s_br, :acao => 'Calcular'
      response.should be_success
#            response.should have_rjs(:replace, "parcela_#{parcelas(:primeira_parcela_recebimento).id}") do
#              with_tag 'input[name=?][checked]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][selecionada]"
#              with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][data_vencimento]", Date.today.to_s_br
#              with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][indice]", '6,00'
#              with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][retorna_valor_de_correcao_pelo_indice_em_reais]", '1,80'
#              with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][preco_em_reais]", '30,00'
#              with_tag 'input[name=?][value=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][valor_da_multa_em_reais]", '0,60'
#              with_tag 'input[name=?][value*=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][valor_dos_juros_em_reais]", (valores_de_juros_e_multas[0].to_f / 100).to_s.gsub('.',',')
#              with_tag 'input[name=?][value*=?]', "recebimento_de_conta[parcelas][#{parcelas(:primeira_parcela_recebimento).id}][valor_liquido_em_reais]", ((valores_de_juros_e_multas[2].to_f + 180.0) / 100).to_s.gsub('.',',')
#            end
#            response.should have_rjs(:replace, "parcela_#{parcelas(:segunda_parcela_recebimento).id}")
#
#      response.body.should include("$(\"total_indices\").value = 3.3")
#      response.body.should include("$(\"total_parcelas\").value = #{(((valores_de_juros_e_multas_da_outra_parcela[2].to_f + 150.0) / 100) + ((valores_de_juros_e_multas[2].to_f + 180.0) / 100)).to_s.gsub('.',',')}")
#      response.body.should include("$(\"total_geral\").value = #{(((valores_de_juros_e_multas_da_outra_parcela[2].to_f + 150.0) / 100) + ((valores_de_juros_e_multas[2].to_f + 180.0) / 100)).to_s.gsub('.',',')}")
#      response.body.should include("$(\"total_juros_selecionadas\").value = #{((valores_de_juros_e_multas_da_outra_parcela[0].to_f / 100) + (valores_de_juros_e_multas[0].to_f / 100)).to_s.gsub('.',',')}")
#      response.body.should include("$(\"total_juros\").value = #{((valores_de_juros_e_multas_da_outra_parcela[0].to_f / 100) + (valores_de_juros_e_multas[0].to_f / 100)).to_s.gsub('.',',')}")
#      response.body.should include('$("total_multas_selecionadas").value = 1.2')
#      response.body.should include('$("total_multas").value = 1.2')
    end

    it 'não deve atualizar uma parcela de outro documento' do
      login_as :quentin
      lambda do
        put :update, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_design_do_paulo).id, :recebimento_de_conta => {:parcelas => {
            parcelas(:primeira_parcela).id.to_s => {:indice => "6.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => '01/01/2009', :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00', :selecionada => '1'},
            parcelas(:segunda_parcela_recebimento).id.to_s  => {:indice => "5.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => '01/02/2009', :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'}},
          :data_base => "01/06/2009"}, :acao => 'Calcular'
      end.should raise_error(NoMethodError)
    end

    it 'não deve aplicar projeçao para uma parcela de outro documento' do
      login_as :quentin
      put :update, :recebimento_de_conta_id => recebimento_de_contas(:curso_de_design_do_paulo).id, :recebimento_de_conta => {:parcelas => {
          parcelas(:primeira_parcela).id.to_s => {:indice => "6.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => '01/01/2009', :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00', :selecionada => '1'},
          parcelas(:segunda_parcela_recebimento).id.to_s  => {:indice => "5.00", :valor_da_multa_em_reais => '0.00', :data_vencimento => '01/02/2009', :valor_liquido_em_reais => '30.00', :valor_dos_juros_em_reais => '0.00', :preco_em_reais => '30.00'}}
      }, :acao => 'Aplicar', :data_base => "01/06/2009"
      response.body.should include("Element.hide(\"loading_loading\");\nalert(\"N\\u00e3o foi poss\\u00edvel aplicar a proje\\u00e7\\u00e3o!\");\nwindow.location.reload();")
    end

  end
end

