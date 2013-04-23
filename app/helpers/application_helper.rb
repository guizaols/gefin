# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def campo_para_busca_por_data campo
    calendar_date_select_tag_com_mascara "busca[#{campo}]", params[:busca][campo]
  end

  # Modificando..
  def verifica_acesso_do_menu(menu)
    if menu == 'Contas a Receber' && current_usuario.possui_permissao_para_um_item(Perfil::RecebimentoDeContas)
      return true 
    end
    if menu == 'Contas a Pagar' && current_usuario.possui_permissao_para_um_item(Perfil::PagamentoDeContas, Perfil::ArquivoRemessa)
      return true
    end
    if menu == 'Movimento Financeiro' && current_usuario.possui_permissao_para_um_item(Perfil::Movimentos)
      return true
    end
    if menu == 'Cadastros' && current_usuario.possui_permissao_para_um_item(Perfil::Entidades, Perfil::Unidades,
        Perfil::Servicos, Perfil::Bancos, Perfil::Agencias, Perfil::ContasCorrentes, Perfil::Historicos,
        Perfil::Pessoas, Perfil::Usuarios, Perfil::Localidades, Perfil::PerfisDeAcesso, Perfil::Convenios)
      return true
    end
    if menu == 'Relatórios' && current_usuario.possui_permissao_para_um_item(Perfil::ConsultarRelatoriosContasAPagar, Perfil::ConsultarRelatoriosContasAPagar, Perfil::ConsultaDeTransacoes, Perfil::ConsultarRelatoriosCheque, Perfil::ConsultarRelatoriosContabilizacao, Perfil::ConsultarRelatoriosContasCorrentes)
      return true
    end
    if menu == 'Utilitários' && current_usuario.possui_permissao_para_um_item(Perfil::ParametroContaValor, Perfil::Configuracao, Perfil::RealizarExportacaoZeus,
        Perfil::RealizarImportacaoZeus, Perfil::DeParaEntreAnosDoOrcamento, Perfil::AlterarAno, Perfil::AlterarUnidade)
      return true
    end
    false
  end
  
  def link_para_imposto_rateio(tipo,parcela = nil,entidade = nil,conta = nil)
    tipo == 'imposto' ? "criaImpostoDaParcela(#{render(:partial => 'parcelas/imposto_da_parcela',:locals=>{:chave=>nil,:entidade_id => entidade.id,:valor_doc=>conta.valor_do_documento,:parcela=>parcela.valor,:data_da_baixa=>parcela.data_da_baixa}).to_json},#{parcela.dados_do_imposto.length},#{parcela.valor});":
      "criaItemRateio(#{render(:partial => 'parcelas/itens_rateio',:locals=>{:indice=>nil}).to_json},#{parcela.dados_do_rateio.length});"
  end

  def campo_para_busca_por_faixa_de_data campo
    campo_para_busca_por_data("#{campo}_min") + '  <b>a</b>  ' + campo_para_busca_por_data("#{campo}_max")
  end

  def campo_de_cadastro label, valor
    '<tr><td class="field_descriptor">' + label + '</td><td>' + valor + '</td></tr>'
  end

  def calendar_date_select_tag_com_mascara *args
    calendar_date_select_tag(*args) + mascara_para_data(sanitize_to_id(args.first))
  end
  
  def calendar_date_select_com_mascara(f, nome)
    f.calendar_date_select(nome, :maxlength => '10') + mascara_para_data(f.object_name + "_" + nome)
  end
  
  def esta_na_tela_de_login
    params[:controller] == 'sessao'
  end

  def show_unless_blank(label, campo, options = {})
    campo = h campo unless options[:safe_html]
    "<tr><td><b>#{label}:</b></td><td>#{campo}</td></tr>" unless campo.blank?
  end

  def data_formatada(data)
    unless data.blank?
      data.to_date.to_s_br
    end
  end

  def mascara_para_valor(id)
    javascript_tag "oNumberMask = new Mask('###.00', 'number'); oNumberMask.attach($('#{id}')); $('#{id}').onblur();"
  end
  
  def mascara_para_data(id)
    javascript_tag "$('#{id}').onkeyup=function(){AplicaMascara('XX/XX/XXXX', this)};"
  end

  def mascara_para_cpf(id)
    javascript_tag "$('#{id}').onkeyup=function(){AplicaMascara('XXX.XXX.XXX-XX', this)};"
  end

  def mascara_para_cnpj(id)
    javascript_tag "$('#{id}').onkeyup=function(){AplicaMascara('XX.XXX.XXX/XXXX-XX', this)};"
  end

  def mascara_para_validade_cartao(id)
    javascript_tag "$('#{id}').onkeyup=function(){AplicaMascara('XX/XX', this)};"
  end

  def preco_formatado(preco, cifrao = '')
    number_to_currency(preco / 100.0, :unit => cifrao, :separator => ",", :delimiter => ".") rescue nil
  end

  def preco_formatado_com_ponto(preco)
    number_to_currency(preco / 100.0, :separator => ".", :unit => '').to_s.strip
  end

  def preco_formatado_com_decimal_ponto(preco)
    preco = preco_formatado_com_ponto(preco).split(".")
    decimal = preco.pop
    "#{preco.join()}.#{decimal}"
  end

  def mensagem_da_pesquisa(busca)
    if (busca rescue true)
      "<b>Não foram encontrados registros com estes parâmetros de busca.</b>"
    else
      "<b>Entre com os parâmetros válidos para a pesquisa.</b>"
    end
  end
  
  def data_formatada(data)
    data.to_date.to_s_br unless data.blank?
  end
  
 
  def listagem_table(options = {})
    if options[:permissoes].blank?
      @permissoes_links_new_edit_delete = true
    else
      @permissoes_links_new_edit_delete = current_usuario.possui_permissao_para(options[:permissoes])
    end
    @ocultar_ultima_th = options[:ocultar_ultima_th]
    
    table_tag = content_tag('table', '', :class => 'listagem', :cellspacing => 0, :style => options[:style]).gsub '</table>', ''
    concat table_tag
    if headers = options.delete(:headers)
      concat "<thead><tr class='thead_image'><td colspan=\"#{ headers.length + (@ocultar_ultima_th ? 0 : 1) }\"></td></tr><tr>"
      headers.each do |header|
        if header.is_a?(Array)
          concat "<th class='#{header.first.downcase.gsub(" ", "_")}'>#{header.first}#{header.last}</th>"
        else
          concat "<th class='#{header.downcase.gsub(" ", "_")}'>#{header}</th>"
        end
      end
      if options[:new]
        concat '<th class="ultima_coluna">'
        concat link_to(image_tag('layout/novo.png'), options[:new])  if @permissoes_links_new_edit_delete
        concat '</th>'
      end
      concat '</tr></thead>'
    end
    yield
    concat '</table>'
  end

  def listagem_tr(options = {})
    if options[:permissoes].blank?
      @permissoes_links_new_edit_delete = true
    else
      @permissoes_links_new_edit_delete = current_usuario.possui_permissao_para(options[:permissoes])
    end
    if options[:id]
      concat "<tr id=\"#{options[:id]}\" class=\"#{ cycle 'impar', 'par' }\">"
    else
      concat "<tr class=\"#{ cycle 'impar', 'par' }\">"
    end
    yield

    if (options[:edit] || options[:destroy] || options[:after]) && @ocultar_ultima_th.blank?
      concat '<td class="ultima_coluna">'
      concat link_to(image_tag('layout/alterar.png'), options[:edit]) if options[:edit] && @permissoes_links_new_edit_delete
      concat link_to(image_tag('layout/excluir.png'), options[:destroy], :confirm => 'Confirma a exclusão?', :method => 'delete') if options[:destroy] && @permissoes_links_new_edit_delete
      concat options[:after] if options[:after]
      concat '</td></tr>'
    else
      concat '</tr>'
    end
  end
  
  def divs_para_explicar_auto_complete(id)
    "<div class=\"div_explicativa\"><div id=\"#{sanitize_to_id(id)}_explicacao_busca\" class=\"explicacao_busca_auto_complete\" style=\"display: none\">Este é um campo dinâmico de pesquisa de dados. Digite parcialmente o dado que você procura e aguarde um instante. O sistema irá retornar automaticamente os resultados da busca. <br />Para utilizar a função 'Começa com', digite um * à direita do texto (ex: 'Joao*'). <br />Para utilizar a função 'Termina com', digite um * à esquerda do texto (ex: '*Santos')." +
      image_tag('seta_tooltip.gif') + "</div>" +
      "</div>"
  end

  def hash_com_opcoes_do_auto_complete(id)
    { :onfocus => "$('#{sanitize_to_id(id)}_explicacao_busca').show()",
      :onblur => "$('#{sanitize_to_id(id)}_explicacao_busca').hide(); limpaCampo(this);" }
  end

  def loading_image(id)
    image_tag('loading.gif', :id=>"loading_#{id}",:style=>"display:none")
  end

  #    def limpa_campos_unidade_organizacional_centro(objeto, campo, elemento = nil)
  #    variavel = ["#{objeto.object_name}_nome_#{campo}"] << (elemento if elemento)
  #    variavel = variavel.join("_")
  #
  #    js = ([["#{objeto.object_name}_unidade_organizacional", "id"], ["#{objeto.object_name}_nome_centro", ""],
  #        ["#{objeto.object_name}_centro", "id"]].collect do |valores|
  #        (novo_array = [valores.first] << (elemento if elemento)) << (valores.last if valores.last == "id")
  #        "$('#{novo_array.join('_')}').value = null;"
  #      end).join(' ')
  #
  #      variavel = "#{objeto.object_name}_nome_#{campo}" + "_#{elemento}"
  #      "if ($('#{variavel}').empty())
  #       {
  #          $('#{objeto.object_name}_unidade_organizacional_id').value = null;
  #          $('#{objeto.object_name}_nome_centro').value = null;
  #          $('#{objeto.object_name}_centro_id').value = null;
  #       }"
  #    end

  def auto_complete_para_conta_contabil_parametrizada(f, objeto, campo, options = {})
    conta = objeto.send("#{campo}_id_parametrizada")
    if conta
      objeto.send("#{campo}_id=", conta) #Força utilizar a conta parametrizada
      f.hidden_field("#{campo}_id") + '<b>' + h(objeto.send("nome_#{campo}")) + '</b>'
    else
      auto_complete_para_qualquer_campo(f, campo, auto_complete_for_conta_contabil_plano_de_contas_path, {:analisar_conta => true}.merge(options))
    end
  end
  
  def insere_campos_para_busca_de_contas(opcoes_para_select, mensagem_para_busca)
    (text_field_tag 'busca[texto]', params[:busca][:texto], :onfocus => "exibir_explicacao_para_busca('exibir','#{mensagem_para_busca}')", :onblur => "exibir_explicacao_para_busca('ocultar','')") +
      '&nbsp;&nbsp;' +
      (select_tag('busca[ordem]', options_for_select(opcoes_para_select,params[:busca][:ordem]))) +
      '&nbsp;&nbsp;' +
      (submit_tag 'Pesquisar')
  end

  def auto_complete_para_qualquer_campo(objeto, campo, url, options = {})
    #    Como passar o options!
    #    options = {:analisar_conta => true, :complemento_dos_params => "", :complemento_do_after_update_element => "", :opcoes_para_text_field => {:tamanho => 30, :desabilitar => false}}  
    divs_para_explicar_auto_complete("#{objeto.object_name}_nome_#{campo}") +
      objeto.hidden_field("#{campo}_id") +
      objeto.text_field("nome_#{campo}", { :simple_tag => true }.merge(hash_com_opcoes_do_auto_complete("#{objeto.object_name}_nome_#{campo}").merge(options[:opcoes_para_text_field] ? options[:opcoes_para_text_field] : {}))) +
      "<div id='#{objeto.object_name}_nome_#{campo}_auto_complete' class='auto_complete_para_conta'></div>" +
      auto_complete_field("#{objeto.object_name}_nome_#{campo}", :url => url, :with => "'argumento=' + element.value#{options[:complemento_dos_params]}",
      :after_update_element =>  options[:analisar_conta] ? analisa_tipo_de_conta(campo, objeto) :  "function(element, value) { $('#{objeto.object_name}_#{campo}_id').value = value.id; #{options[:complemento_do_after_update_element]} }",
      :indicator => "loading_#{campo}") +
      loading_image(campo)
  end

  def auto_complete_tag_para_qualquer_campo(campo, url)
    divs_para_explicar_auto_complete(campo) +
      text_field_tag("busca[nome_#{campo}]", params[:busca]["nome_campo"], {:size => 50}.merge(hash_com_opcoes_do_auto_complete(campo))) +
      "<div id='busca_nome_#{campo}_auto_complete' class='auto_complete_para_conta'></div>" +
      hidden_field_tag("busca[#{campo}_id]", params[:busca]["#{campo}_id"]) +
      auto_complete_field("busca_nome_#{campo}", :url => url, :with => "'argumento=' + element.value", :after_update_element => "function(element, value){$('busca_#{sanitize_to_id(campo)}_id').value = value.id;}", :indicator => "loading_busca_#{campo}") +
      image_tag('loading.gif', :id => "loading_busca_#{campo}", :style => "display:none")
  end

  def auto_complete_para_qualquer_campo_tag(campo, url, id = nil, nome = nil, options = {})
    #    Como passar o options!
    #    options = {:analisar_conta => true, :complemento_dos_params => "", :complemento_do_after_update_element => "", opcoes_para_text_field => {:tamanho => 30, :desabilitar => false}}
    divs_para_explicar_auto_complete(campo) +
      hidden_field_tag("#{campo}", id) +
      text_field_tag("#{campo.sub("_id","_nome")}", nome, hash_com_opcoes_do_auto_complete(campo).merge(options[:opcoes_para_text_field] ? options[:opcoes_para_text_field] : {})) +
      "<span id='#{sanitize_to_id(campo.sub "_id", "_nome")}_auto_complete' class='auto_complete_para_conta'></span>"+
      auto_complete_field("#{sanitize_to_id(campo.sub "_id", "_nome")}", :url => url, :with => "'argumento=' + element.value#{options[:complemento_dos_params]}",
      :after_update_element => (options[:analisar_conta] ? analisa_tipo_de_conta(campo,nil,options[:complemento_do_after_update_element]) : "function(element, value){$('#{sanitize_to_id(campo)}').value = value.id; #{options[:complemento_do_after_update_element]}}"),
      :indicator => "loading_#{sanitize_to_id(campo)}") +
      image_tag('loading.gif', :id => "loading_#{sanitize_to_id(campo)}", :style=> "display:none")
  end

  def analisa_tipo_de_conta(campo, objeto = nil,complemento = nil)
    unless objeto
      array = [sanitize_to_id(campo), sanitize_to_id(campo.sub("_id", "_nome"))]
    else
      array = ["#{objeto.object_name}_#{campo}_id", "#{objeto.object_name}_nome_#{campo}"]
    end
    "function(element, value)
      {
         var tipo_da_conta;
         tipo_da_conta = value.id;
        if (tipo_da_conta.charAt(0) == '1')
          $('#{array.first}').value = tipo_da_conta.substring(2, tipo_da_conta.length)
        else
        {
          alert('O usuário só pode selecionar contas analíticas');
          $('#{array.first}').value = null;
          $('#{array.last}').value = null;
        }
         #{complemento unless complemento.blank?}

      }"
  end
  
  #  def auto_complete_para_qualquer_campo(f,campo,url,javascript_para_conta,desabilitar = false, tamanho = 30, options = {})
  #    divs_para_explicar_auto_complete("#{f.object_name}_nome_#{campo}") +
  #      f.hidden_field("#{campo}_id") +
  #      f.text_field("nome_#{campo}", {:simple_tag=>true}.merge(hash_para_explicar_auto_complete("#{f.object_name}_nome_#{campo}",tamanho,desabilitar)))+
  #      "<div id='#{f.object_name}_nome_#{campo}_auto_complete' class='auto_complete_para_conta'></div>" +
  #      auto_complete_field("#{f.object_name}_nome_#{campo}", :url=> url, :with => "'argumento=' + element.value#{options[:complemento_dos_params]}" , :after_update_element =>  javascript_para_conta ? analisa_tipo_de_conta(campo, f) :  "function(element, value) { $('#{f.object_name}_#{campo}_id').value = value.id; #{options[:complemento_do_after_update_element]} }" ,:indicator => "loading_#{campo}")+loading_image(campo)
  #  end

  #  def auto_complete_para_qualquer_campo(f,campo,url,javascript_para_conta,desabilitar = false, tamanho = 30)
  #    divs_para_explicar_auto_complete("#{f.object_name}_nome_#{campo}") +
  #      f.hidden_field("#{campo}_id") +
  #      f.text_field("nome_#{campo}", {:simple_tag=>true}.merge(hash_para_explicar_auto_complete("#{f.object_name}_nome_#{campo}",tamanho,desabilitar)))+
  #      "<div id='#{f.object_name}_nome_#{campo}_auto_complete' class='auto_complete_para_conta'></div>" +
  #      auto_complete_field("#{f.object_name}_nome_#{campo}", :url=> url, :with => "'argumento=' + element.value" , :after_update_element =>  javascript_para_conta ? analisa_tipo_de_conta(campo, f) :  "function(element, value) { $('#{f.object_name}_#{campo}_id').value = value.id }" ,:indicator => "loading_#{campo}")+image_tag('loading.gif', :id=>"loading_#{campo}",:style=>"display:none")
  #  end
  
  #  def auto_complete_para_qualquer_campo_tag(campo, url, id = nil, nome = nil, javascript_para_conta = false,desabilitar = false)
  #    divs_para_explicar_auto_complete(campo) +
  #      hidden_field_tag("#{campo}",id)+
  #      text_field_tag("#{campo.sub "_id","_nome"}",nome,hash_para_explicar_auto_complete(campo,nil,desabilitar ))+
  #      "<span id='#{sanitize_to_id(campo.sub "_id", "_nome")}_auto_complete' class='auto_complete_para_conta'></span>"+
  #      auto_complete_field("#{sanitize_to_id(campo.sub "_id","_nome")}", :url=> url, :with => "'argumento=' + element.value",
  #      :after_update_element => (javascript_para_conta ? analisa_tipo_de_conta(campo) : "function(element, value){$('#{sanitize_to_id(campo)}').value = value.id;}") ,:indicator => "loading_#{sanitize_to_id(campo)}", :indicator => "loading_#{sanitize_to_id(campo)}") +
  #      image_tag('loading.gif', :id => "loading_#{sanitize_to_id(campo)}", :style=> "display:none")
  #  end

  def hl(texto)
    h(l(texto).gsub('"', '').gsub('&', ' '))
  end

  def monta_data_hora_emissao
    Time.now.to_s_br.split("\s").join(" às ")
  end

  def monta_data_por_extenso
    data = Date.today
    data.strftime("%d de %B de %Y")
  end

  def gera_periodo_relatorio(data_min, data_max, tipo_periodo = nil, vendas = nil)
    if tipo_periodo == 'recebimento' && vendas.blank?
      tipo = 'de Recebimento: '
    elsif tipo_periodo == 'vencimento' && vendas.blank?
      tipo = 'de Vencimento: '
    elsif tipo_periodo == 'pagamento' && vendas.blank?
      tipo = 'de Pagamento: '
    elsif tipo_periodo == 'baixa' && vendas.blank?
      tipo = 'de Baixa: '
    elsif (tipo_periodo == 'recebimento' || tipo_periodo == 'vencimento') && !vendas.blank?
      tipo = 'de Venda: '
    end

    periodo = 'Período '
    if !data_min.blank? && !data_max.blank?
      tipo.blank? ? periodo + data_min + " à " + data_max : periodo + tipo + data_min + " à " + data_max
    elsif !data_min.blank? && data_max.blank?
      tipo.blank? ? periodo + 'a partir de ' + data_min : periodo + tipo + 'a partir de ' + data_min
    elsif data_min.blank? && !data_max.blank?
      tipo.blank? ? periodo + 'até ' + data_max : periodo + tipo + 'até ' + data_max
    end
  end

  def gera_filtros_dos_relatorios(params = {}, action = nil)
    if params.blank?
      params = {}
    end
    #-------------------------------TODOS-----------------------------------------------------------------------
    filtro = "Filtrado por:\\newline "
    #-------------------------------CONTAS A RECEBER - RECUPERÇÃO DE CRÉDITO------------------------------------
    filtro = filtro + "Tipo Relatório: Resumido\\newline " if params[:tipo_do_relatorio] == "0"
    filtro = filtro + "Tipo Relatório: Detalhado\\newline " if params[:tipo_do_relatorio] == "1"
    filtro = filtro + "Ano: " + params[:ano] + "\\newline " if !params[:ano].blank?
    #-------------------------------CONTAS A RECEBER - CLIENTE--------------------------------------------------
    filtro = filtro + "Tipo de Pessoa: Ambos\\newline " if params[:tipo_pessoa] == "0"
    filtro = filtro + "Tipo de Pessoa: Física\\newline " if params[:tipo_pessoa] == "1"
    filtro = filtro + "Tipo de Pessoa: Jurídica\\newline " if params[:tipo_pessoa] == "2"
    #-------------------------------TODOS QUE POSSUEM SERVIÇO,CLIENTE,FUNCIONÁRIO,MODALIDADE COMO FILTRO--------
    filtro = filtro + "Serviço: #{params[:nome_servico]}\\newline "  unless params[:nome_servico].blank?
    filtro = filtro + "Cliente: #{params[:nome_cliente]}\\newline "  unless params[:nome_cliente].blank?
    filtro = filtro + "Fornecedor: #{params[:nome_fornecedor]}\\newline "  unless params[:nome_fornecedor].blank?
    filtro = filtro + "Funcionário: #{params[:nome_funcionario]}\\newline "  unless params[:nome_funcionario].blank?
    filtro = filtro + "Modalidade: #{params[:nome_modalidade]}\\newline "  unless params[:nome_modalidade].blank? && params[:modalidade_id].blank?
    #--------------------------------TODOS QUE POSSUEM PERIODO DE VENDA------------------------------------------
    if !params[:vendido_min].blank? && !params[:vendido_max].blank?
      filtro = filtro + "Período da Venda entre " + params[:vendido_min] + " à " + params[:vendido_max] + "\\newline "
    elsif !params[:vendido_min].blank? && params[:vendido_max].blank?
      filtro = filtro + "Período da Venda a partir de " + params[:vendido_min] + "\\newline "
    elsif params[:vendido_min].blank? && !params[:vendido_max].blank?
      filtro = filtro + "Período da Venda até" + params[:vendido_max] + "\\newline "
    end
    #----------------------------CONTAS A PAGAR - RETENÇÃO DE IMPOSTOS -----------------------------------------
    if !params[:recolhimento_min].blank? && !params[:recolhimento_max].blank?
      filtro = filtro + "Período da Venda " + params[:recolhimento_min] + " à " + params[:recolhimento_max] + "\\newline "
    elsif !params[:recolhimento_min].blank? && params[:recolhimento_max].blank?
      filtro = filtro + "Período da Venda" + "a partir de " + params[:recolhimento_min] + "\\newline "
    elsif params[:recolhimento_min].blank? && !params[:recolhimento_max].blank?
      filtro = filtro + "Período da Venda" + "até " + params[:recolhimento_max] + "\\newline "
    end
    if !params[:impostos].blank?
      imposto = Imposto.find(params[:impostos])
      filtro = filtro + "Imposto: #{imposto.descricao} \\newline "
    end
    #----------------------------CONTAS A PAGAR - GERAIS/CONTAS A RECEBER - GERAIS/CHEQUES------------------------------
    filtro = filtro + "Vendedor: #{params[:nome_vendedor]}\\newline "  unless params[:nome_vendedor].blank? && params[:vendedor_id].blank?
    if !params[:periodo_min].blank? && !params[:periodo_max].blank? && params[:periodo] && !params[:periodo].blank?
      filtro = filtro + "Período de " + params[:periodo].capitalize + ":\\newline " + params[:periodo_min] + " à " + params[:periodo_max] + "\\newline "
    elsif !params[:periodo_min].blank? && params[:periodo_max].blank? && params[:periodo]
      filtro = filtro + "Período de " + params[:periodo].capitalize + ":\\newline " + "a partir de " + params[:periodo_min] + "\\newline "
    elsif params[:periodo_min].blank? && !params[:periodo_max].blank? && params[:periodo]
      filtro = filtro + "Período de " + params[:periodo].capitalize + ":\\newline " + "até " + params[:periodo_max] + "\\newline "
    end
    unless action == 'agendamentos' || action == 'clientes_inadimplentes' || action == 'contas_a_pagar_geral' || action == 'evasao'
      if !params[:periodo_min].blank? && !params[:periodo_max].blank? && params[:periodo] && params[:periodo].blank?
        filtro = filtro + "Período de Baixa\\newline " + params[:periodo_min] + " à " + params[:periodo_max] + "\\newline "
      elsif !params[:periodo_min].blank? && params[:periodo_max].blank?
        filtro = filtro + "Período de Baixa\\newline " + "a partir de " + params[:periodo_min] + "\\newline "
      elsif params[:periodo_min].blank? && !params[:periodo_max].blank?
        filtro = filtro + "Período de Baixa\\newline " + "até " + params[:periodo_max] + "\\newline "
      end
    end
    filtro = filtro + "Tipo de Relatório: " + params[:opcoes] + "\\newline " if (!params[:opcoes].blank? && action != 'contas_a_receber_cliente' && action != "contas_a_pagar_retencao_impostos")
    if (params[:opcoes] == "Contas a Receber" || params[:opcoes] == "Geral do Contas a Receber")
      filtro = filtro + "Situação: Todas\\newline " if params[:situacao] == ''
      filtro = filtro + "Situação: Todas\\newline " if params[:situacao] == 'Todas'
      filtro = filtro + "Situação: Pendentes\\newline " if params[:situacao] == 'Pendentes'
      filtro = filtro + "Situação: Vincendas\\newline " if params[:situacao] == 'Vincendas'
      filtro = filtro + "Situação: Em Atraso\\newline " if params[:situacao] == 'Em Atraso'
      filtro = filtro + "Situação: Jurídico\\newline " if params[:situacao] == 'Jurídico'
      filtro = filtro + "Situação: Permuta\\newline " if params[:situacao] == 'Permuta'
      filtro = filtro + "Situação: Baixa do Conselho\\newline " if params[:situacao] == 'Baixa do Conselho'
      filtro = filtro + "Situação: Inativo\\newline " if params[:situacao] == 'Inativo'
      filtro = filtro + "Situação: Todas - Exceto Jurídico\\newline " if params[:situacao] == 'Todas - Exceto Jurídico'
      filtro = filtro + "Situação: Todas - Exceto Baixa do Conselho \\newline " if params[:situacao] == 'Todas - Exceto Baixa do Conselho'
      filtro = filtro + "Situação: Todas - Exceto Inativo\\newline " if params[:situacao] == 'Todas - Exceto Inativo'
      filtro = filtro + "Situação: Todas - Exceto Permuta\\newline " if params[:situacao] == 'Todas - Exceto Permuta'
    end
    if (params[:opcoes]) && (params[:opcoes].size == 1)
      filtro = filtro + "Tipo de Relatório: Ordem Alfabética\\newline " if params[:opcoes] == '1'
      filtro = filtro + "Tipo de Relatório: Data de Vencimento\\newline " if params[:opcoes] == '2'
    end
    filtro = filtro + "Situação: " + params[:situacao] + "\\newline " if (params[:opcao_relatorio]) && (params[:opcao_relatorio].blank?) && (params[:situacao].size > 1)
    #-----------------------------CONTAS A RECEBER - TOTALIZAÇÕES ---------------------------------------------
    if (!params[:opcao_relatorio].blank?)
      filtro = filtro + "Opção de Relatório: Recebimentos\\newline " if params[:opcao_relatorio] == '1'
      filtro = filtro + "Opção de Relatório: Contas a Receber\\newline " if params[:opcao_relatorio] == '2'
      filtro = filtro + "Opção de Relatório: Recebimentos com Atraso\\newline " if params[:opcao_relatorio] == '3'
      filtro = filtro + "Opção de Relatório: Inadimplência\\newline " if params[:opcao_relatorio] == '4'
    end
    if (!params[:opcao_relatorio].blank?) && (params[:opcao_relatorio] == "2")
      filtro = filtro + "Situação: Todas\\newline " if params[:situacao] == '0'
      filtro = filtro + "Situação: Normal\\newline " if params[:situacao] == '1'
      filtro = filtro + "Situação: Cancelado\\newline " if params[:situacao] == '2'
      filtro = filtro + "Situação: Renegociado\\newline " if params[:situacao] == '3'
    end
    #-----------------------------CONTAS A RECEBER - GERAL/CONTAS A PAGAR - GERAL/CONTABILIZACAO DE CHEQUES/CARTAS EMITIDAS----
    if action != 'contas_a_pagar_geral'
      filtro = filtro + "Ordenação: Nome\\newline " if params[:ordenacao] == "pessoas.nome" && action != "contas_a_pagar_geral"
      filtro = filtro + "Ordenação: Data de Recebimentos/Venda\\newline " if params[:ordenacao] == "parcelas.data_da_baixa"
      filtro = filtro + "Ordenação: Data de Vencimento\\newline " if params[:ordenacao] == "parcelas.data_vencimento"
      filtro = filtro + "Ordenação: Ordem Alfabética\\newline " if params[:ordenacao] == "cheques.nome_do_titular"
      filtro = filtro + "Ordenação: Contrato\\newline " if params[:ordenacao] == "recebimento_de_contas.numero_de_controle"
      filtro = filtro + "Ordenação: Data de Emissão\\newline " if params[:ordenacao] == "historico_operacoes.created_at"
    end
    #-----------------------------CONTAS A RECEBER - CLIENTES--------------------------------------------------
    if params[:situacao_das_parcelas] && !params[:situacao_das_parcelas].empty?
      array_parcelas = []
      params[:situacao_das_parcelas].each do |string|
        array_parcelas << "Vincendas" if string == "VINCENDA"
        array_parcelas << "Em Atraso" if string == "ATRASADA"
        array_parcelas << "Quitadas" if string == "2"
        array_parcelas << "Cancelada" if string == "3"
        array_parcelas << "Renegociada" if string == "4"
        array_parcelas << "Jurídico" if string ==  "5"
        array_parcelas << "Permuta" if string == "6"
        array_parcelas << "Baixa do Conselho" if string ==  "7"
        array_parcelas << "Desconto em Folha" if string == "8"
      end
      filtro = filtro + "Situação das Parcelas: #{array_parcelas.join(', ')}\\newline "
    end
    #----------------------------RELATORIO DE CONTROLE DE CARTÕES----------------------------------------------
    if !params[:data_de_recebimento_min].blank? && !params[:data_de_recebimento_max].blank?
      filtro = filtro + "Período de Recebimento entre" + params[:data_de_recebimento_min] + " à " + params[:data_de_recebimento_max] + "\\newline "
    elsif !params[:data_de_recebimento_min].blank? && params[:data_de_recebimento_max].blank?
      filtro = filtro + "Período de Recebimento a partir de " + params[:data_de_recebimento_min] + "\\newline "
    elsif params[:data_de_recebimento_min].blank? && !params[:data_de_recebimento_max].blank?
      filtro = filtro + "Período de Recebimento até " + params[:data_de_recebimento_max] + "\\newline "
    end
    if !params[:data_do_deposito_min].blank? && !params[:data_do_deposito_max].blank? && params[:situacao] == '2'
      filtro = filtro + "Data do Depósito entre " + params[:data_do_deposito_min] + " à " + params[:data_do_deposito_max] + "\\newline "
    elsif !params[:data_do_deposito_min].blank? && params[:data_do_deposito_max].blank? && params[:situacao] == '2'
      filtro = filtro + "Data do Depósito a partir de " + params[:data_do_deposito_min] + "\\newline "
    elsif params[:data_do_deposito_min].blank? && !params[:data_do_deposito_max].blank?  && params[:situacao] == '2'
      filtro = filtro + "Data do Depósito até " + params[:data_do_deposito_max] + "\\newline "
    end
    if params[:bandeira]
      filtro = filtro + "Cartão/Operadora: Todas\\newline " if params[:bandeira].blank?
      filtro = filtro + "Cartão/Operadora: Visa Crédito\\newline " if params[:bandeira] == '1'
      filtro = filtro + "Cartão/Operadora: Redecard\\newline " if params[:bandeira] == '2'
      filtro = filtro + "Cartão/Operadora: Mastercard\\newline " if params[:bandeira] == '3'
      filtro = filtro + "Cartão/Operadora: Diners\\newline " if params[:bandeira] == '4'
      filtro = filtro + "Cartão/Operadora: American Express\\newline " if params[:bandeira] == '5'
      filtro = filtro + "Cartão/Operadora: Maestro\\newline " if params[:bandeira] == '6'
      filtro = filtro + "Cartão/Operadora: Credicard\\newline " if params[:bandeira] == '7'
      filtro = filtro + "Cartão/Operadora: Ourocard\\newline " if params[:bandeira] == '8'
      filtro = filtro + "Cartão/Operadora: Visa Débito\\newline " if params[:bandeira] == '9'
      filtro = filtro + "Situação: Pendente " if params[:situacao] == '1'
      filtro = filtro + "Situação: Baixado " if params[:situacao] == '2'
    end
    #----------------------------------CLIENTES INADIMPLENTES---------------------------------------------------
    if action != 'contas_a_pagar_geral'
      if !params[:periodo_min].blank? && !params[:periodo_max].blank? && params[:periodo].blank?
        filtro = filtro + "Período de " + params[:periodo_min] + " à " + params[:periodo_max] + "\\newline "
      elsif !params[:periodo_min].blank? && params[:periodo_max].blank?
        filtro = filtro + "Período a partir de " + params[:periodo_min] + "\\newline "
      elsif params[:periodo_min].blank? && !params[:periodo_max].blank?
        filtro = filtro + "Período até " + params[:periodo_max] + "\\newline "
      end
    end
    #----------------------------------CONTAS A PAGAR - GERAL---------------------------------------------------
    filtro = filtro + "Tipo de Documento: " + params[:tipo_de_documento] + "\\newline " if params[:tipo_de_documento] && !params[:tipo_de_documento].blank?
    filtro = filtro + "Tipo de Relatório: " + (params[:opcao_de_relatorio].blank? ? "Todas\\newline " : params[:opcao_de_relatorio].gsub('_', ' ').capitalize + "\\newline ")  if action == "contas_a_pagar_geral"
    filtro = filtro + "Situação: " + params[:situacao].capitalize + "\\newline " if (params[:tipo_de_documento]) && (params[:situacao].size != 1)
    filtro = filtro + "Situação: Pendentes\\newline" if (params[:tipo_de_documento]) && (params[:situacao] == '1')
    filtro = filtro + "Situação: Quitadas\\newline" if (params[:tipo_de_documento]) && (params[:situacao] == '2')
    filtro = filtro + "Ordenação: Ordem Alfabética\\newline " if params[:ordenacao] == "pessoas.nome" && action == "contas_a_pagar_geral"
    filtro = filtro + "Ordenação: Data do Pagamento\\newline " if params[:ordenacao] == "parcelas.data_do_pagamento" && action == "contas_a_pagar_geral"
    filtro = filtro + "Ordenação: Data do Vencimento\\newline " if params[:ordenacao] == "parcelas.data_vencimento" && action == "contas_a_pagar_geral"
    #-----------------------------------CONTABILIZACAO DA ORDEM-------------------------------------------------
    filtro = filtro + "Tipo: Provisionados\\newline " if params[:tipo] == '1'
    filtro = filtro + "Tipo: Pagos/Baixados\\newline " if params[:tipo] == '0'
    filtro = filtro + "Tipo: Todos\\newline " if params[:tipo] == '2'
    filtro = filtro + "Ordem: " +params[:ordem] +"\\newline " if params[:ordem] && !params[:ordem].blank?
    if !params[:data_inicial].blank? && !params[:data_final].blank?
      filtro = filtro + "Período de " + params[:data_inicial] + " à " + params[:data_final] + "\\newline "
    elsif !params[:data_inicial].blank? && params[:data_final].blank?
      filtro = filtro + "Período a partir de " + params[:data_inicial] + "\\newline "
    elsif params[:data_inicial].blank? && !params[:data_final].blank?
      filtro = filtro + "Período até " + params[:data_final] + "\\newline "
    end
    #-----------------------------------CONTAS CORRENTES - DISPONIBILIDADES EFETIVAS----------------------------
    filtro = filtro + "Conta Corrente: " + params[:nome_conta_corrente] + "\\newline "  if params[:nome_conta_corrente] && !params[:nome_conta_corrente].blank?
    if !params[:data_min].blank? && !params[:data_max].blank?
      filtro = filtro + "Período de " + params[:data_min] + " à " + params[:data_max] + "\\newline "
    elsif !params[:data_min].blank? && params[:data_max].blank?
      filtro = filtro + "Período a partir de " + params[:data_min] + "\\newline "
    elsif params[:data_min].blank? && !params[:data_max].blank?
      filtro = filtro + "Período até " + params[:data_max] + "\\newline "
    end
    #------------------------------------CARTAS EMITIDAS---------------------------------------------------------
    filtro = filtro + "Unidade: " + params[:nome_unidade] + "\\newline " if !params[:nome_unidade].blank?
    if !params[:emissao_min].blank? && !params[:emissao_max].blank?
      filtro = filtro + "Período de " + params[:emissao_min] + " à " + params[:emissao_max] + "\\newline "
    elsif !params[:emissao_min].blank? && params[:emissao_max].blank?
      filtro = filtro + "Período a partir de " + params[:emissao_min] + "\\newline "
    elsif params[:emissao_min].blank? && !params[:emissao_max].blank?
      filtro = filtro + "Período até " + params[:emissao_max] + "\\newline "
    end
    filtro = filtro + "Agrupar por: " + params[:agrupar] + "\\newline " if params[:agrupar]
    filtro = filtro + "Tipo de Carta: Carta" + params[:tipo_de_carta] + "\\newline " if params[:tipo_de_carta] && !params[:tipo_de_carta].blank?
    filtro = filtro + "Tipo de Carta: Todas\\newline " if params[:tipo_de_carta] && params[:tipo_de_carta].blank?
    #----------------------------------CONTAS RECEBER - CHEQUES--------------------------------------------------
    if params[:filtro]
      filtro = filtro + "Situação: Pendente\\newline " if params[:situacao] == '1'
      filtro = filtro + "Situação: Baixado\\newline " if params[:situacao] == '2'
      filtro = filtro + "Tipo de Filtro: À Vista\\newline " if params[:filtro] == '1'
      filtro = filtro + "Tipo de Filtro: Pré-Datados\\newline " if params[:filtro] == '2'
      filtro = filtro + "Tipo de Filtro: Devolvidos\\newline " if params[:filtro] == '3'
      filtro = filtro + "Tipo de Filtro: Cheques Baixados\\newline " if params[:filtro] == '4'
    end
    #----------------------------------RECEITAS POR PROCEDIMENTO---------------------------------------------------
    if !params[:nome_unidade_organizacional_inicial].blank? && !params[:nome_unidade_organizacional_final].blank?
      filtro = filtro + "Unidades Organizacionais:  " + "#{params[:nome_unidade_organizacional_inicial]}" + " à " + "#{params[:nome_unidade_organizacional_final]}" + "\\newline "
    elsif !params[:nome_unidade_organizacional_inicial].blank? && params[:nome_unidade_organizacional_final].blank?
      filtro = filtro + "Unidade Organizacional:  " + "#{params[:nome_unidade_organizacional_inicial]}\\newline "
    elsif params[:nome_unidade_organizacional_inicial].blank? && !params[:nome_unidade_organizacional_final].blank?
      filtro = filtro + "Unidade Organizacional:  " + "#{params[:nome_unidade_organizacional_final]}\\newline "
    end

    if !params[:nome_centro_inicial].blank? && !params[:nome_centro_final].blank?
      filtro = filtro + "Centros de Responsabilidade:  " + "#{params[:nome_centro_inicial]}" + " à " + "#{params[:nome_centro_final]}" + "\\newline "
    elsif !params[:nome_centro_inicial].blank? && params[:nome_centro_final].blank?
      filtro = filtro + "Centro de Responsabilidade:  " + "#{params[:nome_centro_inicial]}\\newline "
    elsif params[:nome_centro_inicial].blank? && !params[:nome_centro_final].blank?
      filtro = filtro + "Centro de Responsabilidade:  " + "#{params[:nome_centro_final]}\\newline "
    end

    if !params[:nome_conta_contabil_inicial].blank? && !params[:nome_conta_contabil_final].blank?
      filtro = filtro + "Contas Contábeis:  " + "#{params[:nome_conta_contabil_inicial]}" + " à " + "#{params[:nome_conta_contabil_final]}" + "\\newline "
    elsif !params[:nome_conta_contabil_inicial].blank? && params[:nome_conta_contabil_final].blank?
      filtro = filtro + "Conta Contábil:  " + "#{params[:nome_conta_contabil_inicial]}\\newline "
    elsif params[:nome_conta_contabil_inicial].blank? && !params[:nome_conta_contabil_final].blank?
      filtro = filtro + "Conta Contábil:  " + "#{params[:nome_conta_contabil_final]}\\newline "
    end
    #----------------------------------HISTÓRICO DE RENEGOCIAÇÕES---------------------------------------------------
    if action == 'historico_renegociacoes' && !params[:numero_de_controle].blank?
      filtro = filtro + "Número de Controle:  " + "#{params[:numero_de_controle]}\\newline "
    end
    #--------------------------------------------------EVASÃO--------------------------------------------------------
    if action == 'evasao' && !params[:servico_nome].blank?
      filtro = filtro + "Serviço: #{params[:nome_servico]}\\newline" unless params[:nome_servico].blank?
    end
    #--------------------------------------CONTABILIZAÇÃO DE RECEITAS-----------------------------------------------
    if action == 'contabilizacao_receitas'
      filtro = filtro + "Mês:  " + "#{Date::MONTHNAMES[params[:mes].to_i]}\\newline "
      filtro = filtro + "Ordenação: " + "#{RecebimentoDeConta::HASH_ORDENACAO[params['ordenacao_1']]} | #{RecebimentoDeConta::HASH_ORDENACAO[params['ordenacao_2']]} | #{RecebimentoDeConta::HASH_ORDENACAO[params['ordenacao_3']]} | #{RecebimentoDeConta::HASH_ORDENACAO[params['ordenacao_4']]} | #{RecebimentoDeConta::HASH_ORDENACAO[params['ordenacao_5']]}" + "\\newline\\"
    end
    #----------------------------------------------FATURAMENTO------------------------------------------------------
    if action == 'faturamento'
      filtro = filtro + "Mês:  " + "#{Date::MONTHNAMES[params[:mes].to_i]}\\newline "
    end
    (filtro == "Filtrado por:\\newline ") ? "\\newline" : filtro
  end

  def count_gera_filtros_dos_relatorios(params = {}, action = nil)
    if params.blank?
      params = {}
    end
    str = gera_filtros_dos_relatorios(params, action)
    stra = str.split("\\newline")
    linhas = stra.length
    n = 20
    case action
    when "contas_a_receber_geral_inadimplencia"
      n = 70
    else
      n = 20
    end
    (n+linhas*13).to_s
  end

  def options_for_actions_for_parcelas(conta, parcela)
    options_for_actions_for_parcelas = {}
    normal_requests = {}
    ajax_requests = {}
    unless parcela.data_da_baixa.blank? && ([Parcela::CANCELADA, Parcela::RENEGOCIADA].include?(parcela.situacao))
      normal_requests['Baixa'] = url_for({:controller => 'parcelas', :action => 'baixa', :id => parcela.id}.merge(verifica_se_recebimento_ou_pagamento)) unless (!parcela.parcela_mae_id.blank? if conta.is_a?(RecebimentoDeConta)) || (conta.is_a?(PagamentoDeConta) && parcela.situacao == Parcela::ESTORNADA)
      normal_requests['Imposto'] = url_for({:controller => 'parcelas', :action => 'lancar_impostos_na_parcela', :id => parcela.id, :pagamento_de_conta_id => conta.id}) if conta.is_a?(PagamentoDeConta)
      normal_requests['Rateio'] = url_for({:controller => 'parcelas', :action => 'gerar_rateio', :id => parcela.id}.merge(verifica_se_recebimento_ou_pagamento)) if conta.rateio == 1

      if conta.is_a?(RecebimentoDeConta) && [Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao) && !parcela.parcela_mae_id.blank? || [nil, Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::DEVEDORES_DUVIDOSOS_ATIVOS, Parcela::ENVIADO_AO_DR].include?(parcela.situacao)
        ajax_requests['Baixa Parcial'] = url_for({:id => conta.id, :action => 'carrega_baixa_parcial', :controller => 'recebimento_de_contas', :parcela_id => parcela.id}) if !conta.is_a?(PagamentoDeConta) && (current_usuario.possui_permissao_para(Perfil::ManipularDadosDasParcelas) || [Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao))
      end

      if conta.is_a?(PagamentoDeConta) && [Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA, Parcela::ESTORNADA].include?(parcela.situacao) && !parcela.parcela_mae_id.blank? || [nil, Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::DEVEDORES_DUVIDOSOS_ATIVOS, Parcela::ENVIADO_AO_DR].include?(parcela.situacao)
        ajax_requests['Baixa Parcial'] = url_for({:id => conta.id, :action => 'carrega_baixa_parcial', :controller => 'pagamento_de_contas', :parcela_id => parcela.id}) if !conta.is_a?(RecebimentoDeConta) && current_usuario.possui_permissao_para(Perfil::ManipularDadosDasParcelas)
      end
      
      if conta.is_a?(RecebimentoDeConta) && [Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao) && !parcela.parcela_mae_id.blank? || [nil, Parcela::PENDENTE, Parcela::JURIDICO, Parcela::PERMUTA, Parcela::BAIXA_DO_CONSELHO, Parcela::DESCONTO_EM_FOLHA, Parcela::DEVEDORES_DUVIDOSOS_ATIVOS, Parcela::ENVIADO_AO_DR].include?(parcela.situacao)
        ajax_requests['Baixa Parcial DR'] = url_for({:id => conta.id, :action => 'carrega_baixa_parcial_dr', :controller => 'recebimento_de_contas', :parcela_id => parcela.id}) if !conta.is_a?(PagamentoDeConta) && (current_usuario.possui_permissao_para(Perfil::ManipularDadosDasParcelas) || [Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao))
      end

      if conta.is_a?(RecebimentoDeConta) && ![Parcela::QUITADA, Parcela::CANCELADA].include?(parcela.situacao)
        ajax_requests['Baixa do Conselho'] = url_for({:id => conta.id, :action => 'muda_situacao_para_baixa_do_conselho', :controller => 'recebimento_de_contas', :parcela_id => parcela.id})
      end

      if conta.is_a?(RecebimentoDeConta) && ![Parcela::QUITADA, Parcela::CANCELADA].include?(parcela.situacao)
        ajax_requests['Perdas Recebim.'] = url_for({:id => conta.id, :action => 'muda_situacao_para_perdas_do_recebimento_do_cliente', :controller => 'recebimento_de_contas', :parcela_id => parcela.id})
      end

      if conta.is_a?(PagamentoDeConta) && ![Parcela::QUITADA].include?(parcela.situacao)
        ajax_requests['Estor. Prov.'] = url_for({:id => conta.id, :action => 'estorna_provisao_de_pagamento', :controller => 'pagamento_de_contas', :parcela_id => parcela.id})
      end

      if conta.is_a?(RecebimentoDeConta)
        ajax_requests['Gerar Boleto'] = url_for({ :id => parcela.id, :controller => 'parcelas', :action => 'carrega_geracao_boleto', :recebimento_de_conta_id => conta.id})
      end
      
      if conta.is_a?(RecebimentoDeConta) && conta.provisao == RecebimentoDeConta::NAO && parcela.situacao != Parcela::QUITADA
        ajax_requests['Cancelar'] = url_for({:id => conta.id, :action => 'mostrar_form_para_insercao_de_justificativa', :controller=>'recebimento_de_contas', :parcela_id => parcela.id})
      end
      if current_usuario.possui_permissao_para_um_item(Perfil::CancelarParcCtrCancelado)
        if conta.is_a?(RecebimentoDeConta) && conta.provisao == RecebimentoDeConta::SIM && [RecebimentoDeConta::Cancelado, RecebimentoDeConta::Evadido].include?(conta.situacao_fiemt) && ![Parcela::QUITADA, Parcela::RENEGOCIADA, Parcela::CANCELADA].include?(parcela.situacao)
          ajax_requests['Cancelamento DR'] = url_for({:id => conta.id, :action => 'form_para_justificativa_ctr_cancelado', :controller => 'recebimento_de_contas', :parcela_id => parcela.id})
        end
      end
    end
    options_for_actions_for_parcelas['normal'] = normal_requests
    options_for_actions_for_parcelas['ajax'] = ajax_requests
    options_for_actions_for_parcelas
  end

  def actions_for_parcelas(conta, parcela)
    return "" unless parcela.mostra_menu?
    actions_for_parcelas = [['', '']]
    options_for_actions = options_for_actions_for_parcelas(conta, parcela)
    options_for_normal_requests = options_for_actions['normal']
    options_for_ajax_requests = options_for_actions['ajax']

    options_for_normal_requests.each do |name, url|
      actions_for_parcelas << [name, url]
    end

    options_for_ajax_requests.each do |name, url|
      actions_for_parcelas << [name, url]
    end

    select_tag "action_for_parcela_#{parcela.id}", options_for_select(actions_for_parcelas), :onchange => "
      var selectedOption = Selector.findChildElements(this, ['option'])[this.selectedIndex];
      switch (selectedOption.innerHTML) {
        case '':
          $('form_para_inserir_justificativa').innerHTML = '';
          $('form_para_baixa_parcial').innerHTML = '';
          $('form_para_geracao_boleto').innerHTML = '';
          break;
        case 'Imposto':
          url = selectedOption.value;
          window.location.href = url;
          break;
        case 'Rateio':
          url = selectedOption.value;
          window.location.href = url;
          break;
        case 'Baixa':
          url = selectedOption.value;
          window.location.href = url;
          break;
        case 'Baixa Parcial':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Baixa Parcial DR':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Gerar Boleto':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Cancelar':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Perdas Recebim.':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Estor. Prov.':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Baixa do Conselho':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
        case 'Cancelamento DR':
          url = selectedOption.value;
          new Ajax.Request(url, {asynchronous:true, evalScripts:true, parameters:'parcela_id=' + 1039623219}); return false;
          break;
      }
    "
  end

  def meses_para_selecao(selected = nil)
    options_for_select(Date::MONTHNAMES.collect{|monthname| [monthname, Date::MONTHNAMES.index(monthname)]}, selected)
  end

  def anos_para_selecao(selected = nil)
   ano_inicial = Date.today.year
   ano_inicial -= 1
   ano_final = Date.today.year
   ano_final += 5
    options_for_select((ano_inicial..ano_final).collect{|ano| ano}, selected)
  end

end
