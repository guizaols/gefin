ActionController::Routing::Routes.draw do |map|
  
  map.resources :arquivo_remessas,
    :collection => {
    :pesquisa_parcelas => :any,
    :valida_parcela => :any,
    :upload => :any
  },
    :member => {
    :gerar => :any,
    :baixar => :any
  }

  map.resource :main, :controller => 'main'
  map.resources :recebimento_de_contas, :collection => {
    #    :pesquisa_para_envio => :any,
    #    :envio_ao_dr_terceirizada => :any,
    :calcula_data_final => :post,
    :consulta_inadimplencia => :any,
    :analise_contratos => :any,
    :listagem_agendamentos_contabilizacao=>:any,
    :cancelar_contabilizacao=>:any,
    :auto_complete_for_clientes => :post,
    :calcular_proporcao => :get,
    :parcelas_operacoes => :get,
    :enviadas_para_dr => :any,
    :efetua_parcelas_operacoes => :any,
    :pesquisa_para_parcelas_operacoes => :post,
    :pesquisar_servicos_para_inicio_em_lote => :any,
    :iniciar_servicos_em_lote => :post,
    :importacao_de_contratos_via_xml => :any,
    :download_layout => :get
  }, :member => {
    :iniciar_servico => :post,
    :parar_servico => :post,
    :resumo => :any,
    :gerar_parcelas => :get,
    :situacao_spc => :post,
    :renegociar => :post,
    :efetuar_renegociacao => :post,
    :abdicar => :post,
    :efetuar_abdicacao => :post,
    :evadir => :post,
    :efetuar_evasao => :post,
    :carregar_modal_parcela => :post,
    :ordena_parcelas => :post,
    :inserindo_nova_parcela => :post,
    :carrega_parcelas => :get,
    :atualiza_valores_das_parcelas => :post,
    :altera_situacao_fiemt => :post,
    :libera_pagamento_de_conta_fora_do_prazo => :post,
    :cancelamento_contrato => :post,
    :muda_situacao_para_perdas_do_recebimento_do_cliente => :post,
    :reajustar => :post,
    :lancar_reajuste => :post,
    :calcula_valor_reajuste => :post,
    :reverter_cancelamentos => :post,
    :efetuar_reversao => :post,
    :reverter_evasao => :post,
    :efetuar_reversao_evasao => :post,
    :estornar_renegociacao => :post,
    :efetuar_estorno_renegociacao => :post
  } do |recebimento_de_conta|
    recebimento_de_conta.resources :historico_operacoes
    recebimento_de_conta.resources :projecoes, :collection => {:gerar_relatorio => :any, :termo_de_divida => :any, :renegociar => :any}
    recebimento_de_conta.resources :parcelas, :member => {
      :gerar_rateio => :get,
      :gravar_rateio => :get,
      :baixa => :get,
      :gravar_baixa => :post,
      :estornar_parcela_baixada => :post,
      :form_para_baixa_parcial => :post,
      :form_para_baixa_parcial_dr => :post,
      :carrega_geracao_boleto => :post,
      :gerar_boleto => :post,
      :baixa_parcial => :post,
      :baixa_parcial_dr => :post,
      :efetuar_resgate => :post,
      :cancelar_para_ctr_canc => :post
    }, :collection => {
      :imprimir_recibos => :post,
      :listar_recibos => :get
    }
  end
  map.resources :relatorios, :collection => {
    :contabilizacao_ordem => :any,
    :pesquisa_para_ordem => :post,
    :contas_a_receber_geral => :any,
    :contas_a_pagar_geral => :any,
    :contas_a_receber_geral_inadimplencia => :any,
    :contas_a_receber_geral_recebimentos_com_atraso => :any,
    :contas_a_receber_geral_vendas_realizadas => :any,
    :geral_do_contas_a_receber => :any,
    :totalizacao => :any,
    :contabilizacao_de_cheques => :any,
    :contas_a_receber_cliente_visao_contabil => :any,
    :contas_a_pagar_retencao_impostos => :any,
    :recuperacao_credito => :any,
    :historico_renegociacoes => :any,
    :pesquisa_historico_renegociacoes => :post,
    :disponibilidade_efetiva => :any,
    :extrato_contas => :any,
    :extrato_contas_beta => :any,
    :clientes_ao_spc => :any,
    :emissao_cartas => :any,
    :pesquisa_emissao_cartas => :post,
    :cartas_emitidas => :any,
    :produtividade_funcionario => :any,
    :controle_de_cartao => :any,
    :renegociacoes_efetuadas => :any,
    :contratos_vendidos => :any,
    :acoes_de_cobranca => :any,
    :clientes_inadimplentes => :any,
    :follow_up_cliente => :any,
    :agendamentos => :any,
    :receitas_por_procedimento => :any,
    :evasao => :any,
    :contabilizacao_receitas => :any,
    :faturamento => :any,
    :cancelados_evadidos => :any,
    :contas_a_pagar_visao_contabil => :any,
    :contas_a_receber_cliente_historico => :any,
    :alteracao_contas => :any,
    :efetuar_alteracao_contas => :any,
		:alteracao_efetuada => :any,
    :clientes_inadimplentes_liberados => :any
  }
  map.resources :impostos
  map.resources :perfis, :collection => {
    :update_formulario => :post
  }
  map.resources :de_para, :member => {
    :alterar => :post
  }
  map.resources :parametro_conta_valores
  map.resources :contas_correntes, :collection => {
    :auto_complete_for_conta_corrente => :post,
    :auto_complete_for_conta_corrente_com_filtro_por_identificador => :post
  }
  map.resources :agencias, :collection => {
    :auto_complete_for_agencia => :post,
    :auto_complete_for_agencias_do_banco => :post,
    :importar_agencias => :post
  }
  
  map.resources :movimentos, :collection => {
    :exportar_para_zeus => :any,
    :lancar_estornos_de_movimentos => :any,
    :gravar_lancamento_de_estorno => :post
  }, :member => {
    :libera_movimento_fora_do_prazo => :post
  } do |movimento|
    movimento.resources :historico_operacoes
  end
  
  map.resources :compromissos, :collection => {
    :auto_complete_for_contas_a_receber => :post,
    :update_tabela_compromissos => :post
  }
  map.resources :pagamento_de_contas, :member => {
    :gerar_parcelas => :get,
    :resumo => :any,
    :carrega_parcelas => :get,
    :atualiza_valores_das_parcelas => :post,
    :libera_pagamento_de_conta_fora_do_prazo => :get,
    :estorna_provisao_de_pagamento => :post
  } do |pagamento_de_conta|
    pagamento_de_conta.resources :historico_operacoes
    pagamento_de_conta.resources :parcelas, :member => {
      :gerar_rateio => :get,
      :gravar_rateio => :get,
      :baixa => :get,
      :gravar_baixa => :post,
      :estornar_parcela_baixada => :post,
      :lancar_impostos_na_parcela =>:get,
      :gravar_imposto => :get,
      :atualiza_juros => :post,
      :realizar_estorno_provisao_de_pagamento => :post,
      :form_para_baixa_parcial => :post,
      :baixa_parcial_pagamentos => :post
    } do |parcela|
      parcela.resources :lancamento_impostos
    end
  end
  map.resources :cartoes, :collection => {
    :baixar => :post,
    :estornar => :post
  }
  map.resources :cheques, :collection => {
    :baixar_abandonar_devolver_estornar => :post,
    :abandonar => :post
  }
  map.resources :plano_de_contas, :collection => {
    :auto_complete_for_conta_contabil => :post,
    :auto_complete_for_conta_contabil_ano_anterior => :post
  }
  map.resources :unidades_organizacionais, :collection => {
    :auto_complete_for_unidade_organizacional => :post
  }
  map.resources :centros, :collection => {
    :auto_complete_for_centro => :post,
    :auto_complete_for_centro_para_relatorio => :post
  }
  map.resources :servicos, :collection => {
    :prorrogar => :get,
    :gravar_dados_de_prorrogacao_de_contrato => :post,
    :auto_complete_for_servico => :post,
    :auto_complete_for_modalidade => :post
  }
  map.resources :bancos, :collection => {
    :auto_complete_for_banco => :post
  }
  map.resources :unidades, :collection => {
    :auto_complete_for_unidade => :post,
    :importar_zeus => :any
  }
  map.resources :entidades
  map.resources :localidades, :collection =>{
    :auto_complete_for_localidade => :post
  }
  map.resources :pessoas, :collection => {
    :auto_complete_for_cidade => :post,
    :adicionar_campo_hidden_field => :post,
    :funcionarios => :get,
    :importar_clientes => :any,
    :auto_complete_for_funcionario => :post,
    :auto_complete_for_dependente => :post,
    :auto_complete_for_cliente => :post,
    :auto_complete_for_cliente_cpf_cnpj => :post,
    :auto_complete_for_fornecedor_cpf_cnpj => :post,
    :auto_complete_for_funcionario_para_audit => :post,
    :verifica_se_existe_cpf_cnpj => :post,
    :auto_complete_for_pessoa => :post,
    :auto_complete_for_fornecedor => :post
  } do |pessoa|
    pessoa.resources :dependentes
  end
  map.resources :historicos, :collection => {
    :auto_complete_for_historico => :post
  }
  map.logout '/logout', :controller => 'sessao', :action => 'destroy'
  map.login '/login', :controller => 'sessao', :action => 'new'
  map.resources :usuarios, :member => {
    :carrega_form_alterar_senha => :get,
    :alterar_senha => :post,
    :ativa_inativa_usuarios => :post
  }
  map.resources :convenios
  map.resource :sessao, :controller => 'sessao', :collection => {
    :altera_ano => :post,
    :altera_unidade => :post
  }
  map.resource :configuracao, :controller => 'configuracao'
  map.resources :audits

  # The priority is based upon order of creation: first created -> highest priority.
  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action
  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }
  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end
  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.

  map.root :controller => 'sessao', :action => 'new'
  # See how all your routes lay out with "rake routes"
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
