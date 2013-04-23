// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function validarParcelaPessoa(mensagem, id, urls){
    if (confirm(mensagem)) {
        urls.each(function(url) {
            window.open(url);
        });
    }
    $(id).checked = false;
}

function verifica_localidade_vazia()
{
    if($('pessoa_nome_localidade').value == "")
    {
        alert('O campo localidade precisa ser preenchido');
    }
}

function marcaOuDesmarcaParcelas(mostrar) {
    $$('.selecionados').each(function(value, index) {
        if(value.disabled == false){
            if(mostrar == false)
                value.checked = false
            else
                value.checked = true
        }
    });
}

function DoPrinting(){
    if (!window.print){
        alert("Use o Netscape ou Internet Explorer \n nas versões 4.0 ou superior!")
        return
    }
    window.print()
}

function desenha_view(tipo_da_view)

{
    try{
        if(tipo_da_view == '2') //PAGAMENTO
        {
            $('quantidade_transmissao').show();
            $('carteira').hide();
            $('variacao_da_carteira').hide();
            $('tipo_documento').hide();
            $('indicativo_sacador').hide();
            $('local_pagamento').hide();
            $('instrucoes').hide();
            $('reservado_empresa').hide();
            $('numero_bordero').hide();
            $('cod_operacao').hide();
            $('conta_corrente').show();
        }
        else if(tipo_da_view == '1')
        {
            $('quantidade_transmissao').hide();
            $('conta_corrente').hide();
            $('carteira').show();
            $('variacao_da_carteira').show();
            $('tipo_documento').show();
            $('indicativo_sacador').show();
            $('local_pagamento').show();
            $('instrucoes').show();
            $('reservado_empresa').show();
            $('numero_bordero').show();
            $('cod_operacao').show();
            $('conta_corrente').show();
        }
        else
        {
            $('quantidade_transmissao').hide();
            $('carteira').hide();
            $('variacao_da_carteira').hide();
            $('tipo_documento').hide();
            $('indicativo_sacador').hide();
            $('local_pagamento').hide();
            $('instrucoes').hide();
            $('reservado_empresa').hide();
            $('numero_bordero').hide();
            $('cod_operacao').hide();
            $('conta_corrente').hide();
        }
    }
    catch(e)
    {
        alert('Erro de javascript:' + e.toString());
    }
    
}

function diferenciarFormaDePagamento(pagamento_ou_recebimento, conta_id, parcela_id) {
    try {
        if ($('parcela_forma_de_pagamento').value == '2') {
            $("tr_de_conta_corrente").show();
            //if ($("tr_de_data_pagamento")){
            //  $("tr_de_data_pagamento").show();
            //}
            if ($("tr_de_numero_comprovante")){
                $("tr_de_numero_comprovante").show();
            }
        } else {
            $("tr_de_conta_corrente").hide();
            //if ($("tr_de_data_pagamento")){
            //  $("tr_de_data_pagamento").hide();
            //}
            if ($("tr_de_numero_comprovante")){
                $("tr_de_numero_comprovante").hide();
            }
        }

        if(pagamento_ou_recebimento == 'recebimento_de_contas') {
            if ($('parcela_forma_de_pagamento').value == '3') {
                $("tr_tipo_de_cheque").show();
                $("tr_nome_do_banco").show();
                $("tr_nome_do_titular").show();
                $("tr_nome_agencia").show();
                $("tr_nome_conta").show();
                $("tr_numero_do_cheque").show();
                $("tr_data_deposito").show();
                $("tr_conta_transitoria").show();
            } else {
                $("tr_tipo_de_cheque").hide();
                $("tr_nome_do_banco").hide();
                $("tr_nome_do_titular").hide();
                $("tr_nome_agencia").hide();
                $("tr_nome_conta").hide();
                $("tr_numero_do_cheque").hide();
                $("tr_data_deposito").hide();
                $("tr_conta_transitoria").hide();
            }
        
            if ($('parcela_forma_de_pagamento').value == '4') {
                $("tr_bandeira").show();
                $("tr_numero_do_cartao").show();
                //$("tr_codigo_de_seguranca").show();
                $("tr_validade_do_cartao").show();
                $("tr_nome_do_titular_cartao").show();
            } else {
                $("tr_bandeira").hide();
                $("tr_numero_do_cartao").hide();
                //$("tr_codigo_de_seguranca").hide();
                $("tr_validade_do_cartao").hide();
                $("tr_nome_do_titular_cartao").hide();
            }
        }
    } catch (e) {
        alert(e);
    //window.location.href = "/" + pagamento_ou_recebimento + "/" + conta_id + "/parcelas/" + parcela_id + "/baixa";
    }
}


function mostraOuEscondeElementosEmCheques() {
    if ($('busca_situacao').value == '2' ) {
        Element.show('tr_datas');
    } else {
        Element.hide('tr_datas');
    }
}

function selecionaTodasAsContas(todas) {
    $$('.selecionaveis').each(function (value, index){ 
        value.checked = todas;
    });
}

function selecionarChecksPerfis(todas) {
    $$('.selecionaveis').each(function (value, index){
        value.checked = todas;
    });
}

function retornaSelecionado() {
    var identificador;
    $$('.selecionados').each(function(value, index) { 
        if (value.checked) {
            identificador = value.id.replace(/\w+_/g, '')
        }
    });
    return $("historico_" + identificador).value;

}

function alteraHistorico(tipo) {
    if ($('cheques_historico')) { 
        $('cheques_historico').value = tipo + retornaSelecionado();
    }
    if ($('cheques_historico_abandono')) { 
        $('cheques_historico_abandono').value = tipo + retornaSelecionado();
    }
}

function desmarcar_cheque_pre()
{
    $('busca_pre_datado').checked = false;
}

function desmarcar_cheque_a_vista()
{
    $('busca_vista').checked = false;
}

function mostrar_pesquisa_por_tipo_situacao()
{
    
    if ($('busca_por_situacao').checked)
        $('situacao').show();
    else
        $('situacao').hide();    

}


function soNumeros(id){
    return $(id).value.replace(/\D/g,"")
}

function somaTodosEmCheques(total_id, mostrar) {
    var total = 0;
    $$('.selecionados').each(function(value, index) {
        value.checked = mostrar;
        if (mostrar) {
            total = total + (parseFloat(value.lang) / 100);
        } else {
            total = 0.00;
        }
    });
    $(total_id).value = total;
    $(total_id).onblur();
}

function somaValorEmCheques(total_id, checkbox_id) {
    var total = $(total_id);
    var checkbox = $(checkbox_id);
    if (checkbox.checked) {
        total.value = parseFloat(total.value) + (parseFloat(checkbox.lang) / 100);
    } else {
        total.value = parseFloat(total.value) - (parseFloat(checkbox.lang) / 100);
    }
    $(total_id).onblur();
}

function desenha_a_tela_de_cadastrar_pessoa()
{
    if($('pessoa_fornecedor').checked)
    {
        $('banco').show();
        $('agencia').show();
        $('conta').show();
    }
    else
    {
        $('banco').hide();
        $('agencia').hide();
        $('conta').hide();
    }
    if($('pessoa_funcionario').checked)
    {
        $('matricula').show();
        $('cargo').show();
        $('ativo').show();
    }
    else
    {
        $('matricula').hide();
        $('cargo').hide();
        $('ativo').hide();
    }    
}

function verifica_se_existe_conta_contabil()
{
    if ($('pagamento_de_conta_provisao').value == '1')
    {
        $('conta_contabil_pessoa').highlight();
        $('conta_contabil_pessoa').show();
    }
    else
    {
        $('conta_contabil_pessoa').hide();
        if($('pagamento_de_conta_contabil_pessoa_id') != null)
        {
            $('pagamento_de_conta_conta_contabil_pessoa_id').value=null;
            $('pagamento_de_conta_nome_conta_contabil_pessoa').value=null;
        }
    }
}

function atualiza_cores_das_trs_de_listagem() {
    var classe = "par";
    $$('table.listagem tbody tr').each(function(value)
    {
        if (value.style.display != 'none') {
            if (classe == 'par') {
                removeClass(value, 'par');
                addClass(value, 'impar');
                classe = 'impar';
            } else {
                removeClass(value, 'impar');
                addClass(value, 'par');
                classe = 'par';
            }
        }
    });
}

function verifica_filtro_tipo_de_relatorio(){
    if (($('busca_opcoes').value == 'Contas a Receber') || ($('busca_opcoes').value == 'Geral do Contas a Receber')) 
    {
        $('tipo_situacao').show();   
    }
    else
    {
        $('tipo_situacao').hide();
    }
}

function verifica_tipo_de_data(){
    if (($('busca_datas').value == 'inicio_servico') || ($('busca_datas').value == 'final_servico') || ($('busca_datas').value == 'intervalo')) {
        $('datas').show();
    } else {
        $('datas').hide();
    }
}

function verifica_tipo_de_data_contrato(){
    if (($('busca_datas').value == 'inicio') || ($('busca_datas').value == 'final') || ($('busca_datas').value == 'intervalo')) {
        $('datas').show();
    } else {
        $('datas').hide();
    }
}

function verifica_tipo_de_relatorio_esconde(){
    $('vencimento_recebimento').hide();
}

function verifica_tipo_de_relatorio_mostra(){
    $('vencimento_recebimento').show();
}

function addClass(element, value) {
    if(!element.className) {
        element.className = value;
    } else {
        newClassName = element.className;
        newClassName+= " ";
        newClassName+= value;
        element.className = newClassName;
    }
}

function removeClass(element, value) {
    if(element.className) {
        newClassName = element.className;
        newClassName = newClassName.replace(value, '');
        element.className = newClassName;
    }
}

function valor_total_do_rateio()
{
    var j = 0, soma = 0.0, valor= 0;
    $$('input.valores').each(function(value)
    {
        
        if ((value.value).empty())
            valor = 0.0;
        else
            valor = parseFloat(value.value.replace('.', '').replace(',', '.')) * 100;
        soma = soma + valor;
    });

    if (isNaN(soma))
        soma = 0.0;
    else
    {
        soma = (soma / 100.0).toFixed(2);
        $('soma_total_do_rateio').innerHTML = (formatar_dinheiro(soma.toString()));
        verifica_se_valor_do_rateio_e_igual_ao_da_parcela();
    }
}

function valor_total_das_parcelas()
{
    var soma = 0, valor = 0;
    $$('input.valor').each(function(value)
    {
        if ((value.value).empty() || (value.lang == 4) || (value.lang == 3))
            valor = 0.0;
        else
            valor = parseFloat(value.value.replace('.', '').replace(',', '.')) * 100;
        soma = soma + valor;
    });

    if (isNaN(soma))
        soma = 0.0;
    else
    {
        soma = (soma / 100.0).toFixed(2);
        $('soma_total_das_parcelas').innerHTML = (formatar_dinheiro(soma.toString()));
        verifica_se_valor_do_documento_e_igual_a_soma_das_parcelas();
    }

}

function verifica_se_valor_do_documento_e_igual_a_soma_das_parcelas()
{
    if($('soma_total_das_parcelas').innerHTML == $('valor_do_documento').innerHTML)
    {
        $('soma_total_das_parcelas').style.color='#00FF00';
        $('valor_do_documento').style.color='#00FF00';
    }
    else
    {
        $('soma_total_das_parcelas').style.color='#FF0000';
        $('valor_do_documento').style.color='#FF0000';
    }
    
}


function verifica_se_valor_do_rateio_e_igual_ao_da_parcela()
{
    
    if($('valor_da_parcela').innerHTML == $('soma_total_do_rateio').innerHTML)
    {
        $('valor_da_parcela').style.color='#00FF00';
        $('soma_total_do_rateio').style.color='#00FF00';
    }
    else
    {
        $('valor_da_parcela').style.color='#FF0000';
        $('soma_total_do_rateio').style.color='#FF0000';
    }
}

function recebe_id_da_localidade(text){
    return(text.id);
}

function verificaSeElementoEstaVisivel(id_elemento) {
    if (Element.visible(id_elemento) == false) {
        Element.show(id_elemento)
    }
}
function formatar_dinheiro(numero)
{
    var tamanho,posicao_ponto,subt,continha;
    //campo é o campo do form q recebe valor por outra função
    //tamanho é o tamanho do campo
    tamanho=numero.length;
    //onde é o lugar q tem o ponto
    posicao_ponto=numero.indexOf(".");
    //faz-se uma continha pra quantas casas tem depois da virgula (ou quase isso)
    continha= tamanho - posicao_ponto;
    //se onde for -1 (ou seja se naum achar o ponto .)
    //acrescento .00 pq naum tinha casas decimais
    if (posicao_ponto==-1)
    {
        subt=numero+".00";
    }
    //se tiver ponto eu conto as casas
    if (posicao_ponto>=0)
    {
        //e se na conta o resultado for 2 significa que tem 1 casa decima
        //entao so atribuo numero em sbt pois ele se encontra formatado
        if (continha==2)
            subt=numero + "0";
        else
            subt=numero;
    }
    return subt;
}

function mostra_elemento_justificativa()
{
    
    if(parseFloat($('parcela_outros_acrescimos_em_reais').value) > 0)
    {
        $('justificativa_outros').highlight();
        $('justificativa_outros').show();
    }
    else
    {
        $('justificativa_outros').hide();
    }
    
}

function valor_total()
{
    var j = 0, soma = 0, valor = 0, aux = 0.0;
    $$('input.valores').each(function(value)
    {
        if ((value.value).empty()) {
            valor = 0.0;
        } else {
            aux = value.value.split('.');
            if(aux[1] != undefined) {
                valor = parseFloat(value.value.replace(',', '.').replace('.', '')) * 100;
            } else {
                valor = parseFloat(value.value.replace(',', '.')) * 100;
            }
        }

        soma = soma + valor;
    });
    $$('input.valores_desconto').each(function(value)
    {
        if ((value.value).empty()) {
            valor = 0.0;
        } else {
            aux = value.value.split('.');
            if(aux[1] != undefined) {
                valor = parseFloat(value.value.replace(',', '.').replace('.', '')) * (-100);
            } else {
                valor = parseFloat(value.value.replace(',', '.')) * (-100);
            }
        }

        soma = soma + valor;
    });
    if (isNaN(soma))
        soma = 0.0;
    else
    {
        if ($('valor_da_retencao'))
            soma += parseFloat($('valor_da_retencao').value) * (-100);
        soma = (soma / 100.0).toFixed(2);
        if ($('soma_total'))
            $('soma_total').innerHTML = (formatar_dinheiro(soma.toString()));
        $('soma_total_da_parcela').innerHTML = (formatar_dinheiro(soma.toString()));
    }
}

function confirmarAlteracao()
{
    if (confirm ("Deseja replicar este rateio para todas as parcelas?"))
    {
        $('replicar_para_todos').value=1;
    }
}

function verificaSeElementoEstaAparecendo()
{
    var conta_tags = 0;
    $$('input.valor').each(function(value){
        conta_tags = conta_tags + 1;
    });
    if(conta_tags < 1)
    {
        return true
    }
    else
    {
        return false
    }
}

function atualiza_valores_retido_liquido_e_aliquota(valor, parcela)
{
    var indice = 0,
    id_aliquota = '',
    id_imposto = '',
    id_valor = '',
    retido = 0.0,
    vetor_aliquotas = new Array(), vetor_valores = new Array(), vetor_classificacao = new Array();
    valor = valor / 100.0;
    parcela = parcela / 100.0;
    
    $$('input.valor').each(function(value)
    {
        indice = value.id.split("_")[3]
        id_imposto="dados_do_imposto_"+indice.toString()+"_imposto_id";
        id_aliquota = "dados_do_imposto_"+indice.toString()+"_aliquota";
        id_valor = value.id;
        vetor_classificacao[indice] = parseFloat($(id_imposto).value.split("#").last());
        vetor_aliquotas[indice] = parseFloat($(id_imposto).value.split("#")[1]);
        vetor_valores[indice] = valor * (vetor_aliquotas[indice]/100.0)
        if (isNaN(vetor_aliquotas[indice])){
            $(id_aliquota).value = 0;
            $(id_valor).value = 0;
        }
        else
        {
            $(id_aliquota).value = vetor_aliquotas[indice];
            $(id_valor).value = vetor_valores[indice].toFixed(2);
            retido = retido + vetor_valores[indice];
        }
    });

    if (vetor_classificacao[indice] == 1) {
        atualiza_cabecalho(parcela);
    }
}

function atualiza_item_de_lancamento_de_imposto(valor_imposto, valor_doc, parcela, indice){
    var
    id_aliquota = '',
    id_imposto = '',
    id_valor = '',
    classificacao = '',
    aliquota = 0.0,
    valor_calc = 0,
    valor = 0.0,
    valor_doc = valor_doc/100.0

    //atualiza_os_valores_do_indice
    id_imposto = "dados_do_imposto_"+indice+"_imposto_id";

    id_aliquota = "dados_do_imposto_"+indice+"_aliquota";
    id_valor = "dados_do_imposto_"+indice+"_valor_imposto";
    classificacao = parseFloat($(id_imposto).value.split("#").last());
    
    aliquota = parseFloat($(id_imposto).value.split("#")[1]);
    valor_calc = valor_doc * (aliquota/100.0);
    $(id_valor).setAttribute('lang', classificacao);

    if (isNaN(aliquota)){
        $(id_aliquota).value = 0;
        $(id_valor).value = 0;
    }
    else
    {
        $(id_aliquota).value = aliquota;
        if (valor_imposto == 0)
            $(id_valor).value = valor_calc.toFixed(2).replace('.', ',');
        else
            $(id_valor).value = valor_imposto.toFixed(2).replace('.', ',');
    }

    atualiza_cabecalho(parcela);
}

function atualiza_cabecalho(parcela){
    
    var liquido = 0.0,
    indice_soma = 0,
    retido = 0;

    $$('input.valor').each(function(value){
        indice_soma = value.id.split("_")[3];
        if (value.getAttribute('lang') == 1) {
            if (!isNaN(parseFloat($("dados_do_imposto_"+indice_soma.toString()+"_valor_imposto").value.replace('.', ',')))){
                retido += parseFloat($("dados_do_imposto_"+indice_soma.toString()+"_valor_imposto").value.replace('.', '').replace(',', '.'));
            }
        }
    });

    parcela = parcela / 100.0;
    
    if(!retido){
        liquido = parcela;
    } else {
        liquido = parcela - retido;
    }

    if (retido > parcela){
        $('retido').setAttribute('class', 'retidovermelho')
        document.getElementById("retido").innerHTML = 'R$'+'<span>&nbsp;</span>'+ formatar_dinheiro((retido.toFixed(2)).toString())
        document.getElementById("liquido").innerHTML ='R$'+'<span>&nbsp;</span>'+ formatar_dinheiro((liquido.toFixed(2)).toString())
    }
    else{
        $('retido').setAttribute('class', 'retidopreto')
        document.getElementById("retido").innerHTML = 'R$'+'<span>&nbsp;</span>'+ formatar_dinheiro((retido.toFixed(2)).toString())
        document.getElementById("liquido").innerHTML ='R$'+'<span>&nbsp;</span>'+ formatar_dinheiro((liquido.toFixed(2)).toString())
    }
}
 
function insere_nome_e_id_para_baixa(id,elemento)
{
    unidade_centro = $('unidade_centro').value.split("_");
    
    nome = 'parcela_nome_unidade_organizacional'+'_'+elemento;
    elemento_id = 'parcela_unidade_organizacional'+'_'+elemento+'_id';
    nome_centro = 'parcela_nome_centro'+'_'+elemento;
    id_do_centro = 'parcela_centro'+'_'+elemento+'_id';
    nome_conta = 'parcela_nome_conta_contabil'+'_'+elemento;
    id_da_conta = 'parcela_conta_contabil'+'_'+elemento+'_id';

    if (parseFloat(id.value.replace(',', '.')) > 0)
    {
        if ($(nome).value.empty())
        {
            $(nome).value = unidade_centro[1];
            $(elemento_id).value=unidade_centro[0];
            $(id_do_centro).value = unidade_centro[2];
            $(nome_centro).value = unidade_centro[3];
        }
    } else {
        $(nome).value = null;
        $(elemento_id).value = null;
        $(id_do_centro).value = null;
        $(nome_centro).value = null;
        $(id_da_conta).value = null;
        $(nome_conta).value = null;
    }
}

function insere_nome_e_id_para_baixa_na_atualizacao_de_juros()
{
    insere_nome_e_id_para_baixa($('parcela_valor_da_multa_em_reais'), 'multa');
    insere_nome_e_id_para_baixa($('parcela_valor_dos_juros_em_reais'), 'juros');
}
    
function exibir_explicacao_para_busca(ordem,mensagem)
{
    
    if (ordem == 'exibir') {
        id_explicacao = 'explicacao_busca';
        texto_explicacao = 'explicacao_texto';
        Element.update(texto_explicacao, mensagem);
        $(id_explicacao).show();
    }
    else
    {
        $(id_explicacao).hide();

    }
}

function filtra_parcelas(padrao) {

    if (padrao){
        $(padrao).checked = true
    }

    if ($('filtro_todas').checked) {
        $$('.listagem tbody tr.pc').each(function(element){
            Element.show(element);
        })
    } else {
        $$('.listagem tbody tr.pc').each(function(element){
            Element.hide(element);
        })
        if ($('filtro_vincendas').checked) {
            $$('.listagem tbody tr.pc.Vincenda').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_em_atraso').checked) {
            $$('.listagem tbody tr.pc.Em.atraso').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_canceladas').checked) {
            $$('.listagem tbody tr.pc.Cancelada').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_renegociadas') && $('filtro_renegociadas').checked) {
            $$('.listagem tbody tr.pc.Renegociada').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_quitadas').checked) {
            $$('.listagem tbody tr.pc.Quitada').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_enviada_ao_dr') && $('filtro_enviada_ao_dr').checked) {
            $$('.listagem tbody tr.pc.Enviada.ao.DR').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_perdas_no_recebimento_de_creditos_-_clientes') && $('filtro_perdas_no_recebimento_de_creditos_-_clientes').checked) {
            $$('.listagem tbody tr.pc.Perdas.no.Recebimento.de.Creditos.-.Clientes').each(function(element){
                Element.show(element);
            })
        }
        if ($('filtro_estornadas').checked) {
            $$('.listagem tbody tr.pc.Estornada').each(function(element){
                Element.show(element);
            })
        }
    }
    atualiza_cores_das_trs_de_listagem();
}

function desmarcar_recebimento()
{
    $('busca_periodo_recebimento').checked = false;
    if( $('busca_periodo_vencimento').checked)
        $('tr_datas').show();
    else
        $('tr_datas').hide();
}

function desmarcar_vencimento()
{
    $('busca_periodo_vencimento').checked = false;
    if( $('busca_periodo_recebimento').checked)
        $('tr_datas').show();
    else
        $('tr_datas').hide();
}

function desmarcar_recebimento_vencimento()
{
    $('busca_periodo_vencimento').checked = false;
    $('busca_periodo_recebimento').checked = false;
    if( $('busca_periodo_baixa').checked)
        $('tr_datas').show();
    else
        $('tr_datas').hide();
    
}

function seleciona_situacoes()
{
    $('tr_situacao').hide();
    if ($('busca_opcao_relatorio').value == "2")
        $('tr_situacao').show();
    else
        $('tr_situacao').hide();
}

function AplicaMascara(Mascara, elemento){
    if(!elemento) return false;
    function in_array( oque, onde ){
        for(var i = 0 ; i < onde.length; i++){
            if(oque == onde[i]){
                return true;
            }
        }
        return false;
    }
    var SpecialChars = [':', '-', '.', '(',')', '/', ',', '_'];
    var oValue = elemento.value;
    var novo_valor = '';
    for( i = 0 ; i < oValue.length; i++){
        var nowMask = Mascara.charAt(i);
        var nowLetter = oValue.charAt(i);
        if(in_array(nowMask, SpecialChars) == true && nowLetter != nowMask){
            novo_valor +=  nowMask + '' + nowLetter;
        } else {
            novo_valor += nowLetter;
        }
        var DuplicatedMasks = nowMask+''+nowMask;
        var loops = 0
        while ((novo_valor.indexOf(DuplicatedMasks) >= 0) && (loops < 100)) {
            novo_valor = novo_valor.replace(DuplicatedMasks, nowMask);
            loops++;
        }
    }
    elemento.value = novo_valor;
 
}

function marcarEtiquetas(){
    $('recebimentos_tipo_cartas').checked = false;
    $('tipo_de_carta').hide();
    $('carta_municipio').hide();
    $('tipo_de_etiqueta').show();
    $('etiqueta_coluna').show();
    $('etiqueta_linha').show();
    if(!$('recebimentos_tipo_etiquetas').checked)
    {
        $('tipo_de_carta').hide();
        $('tipo_de_etiqueta').hide();
        $('etiqueta_coluna').hide();
        $('etiqueta_linha').hide();
        $('carta_municipio').hide();
    }
}

function marcarCartas(){
    $('recebimentos_tipo_etiquetas').checked = false;
    $('tipo_de_etiqueta').hide();
    $('etiqueta_coluna').hide();
    $('etiqueta_linha').hide();
    $('tipo_de_carta').show();
    $('carta_municipio').show();
    if(!$('recebimentos_tipo_cartas').checked)
    {
        $('tipo_de_carta').hide();
        $('tipo_de_etiqueta').hide();
        $('etiqueta_coluna').hide();
        $('etiqueta_linha').hide();
        $('carta_municipio').hide();
    }
}

function carregarLinhaColuna(){
    tipo = $('recebimentos_etiqueta').value;
    linha = 0;
    coluna = 0;

    switch (tipo) {
        case "A4263":
            linha = 7;
            coluna = 2;
            break;
        case "6080":
            linha = 10;
            coluna = 3;
            break;
        case "6081":
            linha = 10;
            coluna = 2;
            break;
        case "6082":
            linha = 7;
            coluna = 2;
            break;
        case "6083":
            linha = 5;
            coluna = 2;
            break;
    }
    string = "";
    for (i=1; i<=linha; i++ ){
        string = string + "<option value='"+i+"'>"+i+"</option>";
    }


    $('recebimentos_linha').innerHTML = string;

    string = "";
    for (i=1; i<=coluna; i++ ){
        string = string + "<option value='"+i+"'>"+i+"</option>";
    }

    $('recebimentos_coluna').innerHTML = string;

}

function limpaCampo(campo){
    if(campo.value == ""){
        $(campo.id.replace("_nome","")+"_id").value = "";
    }
}

function MascaraMoeda(objTextBox, SeparadorMilesimo, SeparadorDecimal, e){
    if(objTextBox.readOnly == false){
        var sep = 0;
        var key = '';
        var i = j = 0;
        var len = len2 = 0;
        var strCheck = '0123456789';
        var aux = aux2 = '';
        var whichCode = (window.Event) ? e.which : e.keyCode;
        //    if (whichCode == 13 || e.keyCode == 8 || e.keyCode == 9 || e.keyCode == 35 || e.keyCode == 36 || e.keyCode == 37 || e.keyCode == 38 || e.keyCode == 39 || e.keyCode == 40 || e.keyCode == 46 || e.keyCode == 116) return true;
        if (whichCode == 13 || whichCode == 0 || whichCode == 8) return true;
        len = objTextBox.value.length;

        key = String.fromCharCode(whichCode);

        if (strCheck.indexOf(key) == -1) return false;

        for(i = 0; i < len; i++)
            if ((objTextBox.value.charAt(i) != '0') && (objTextBox.value.charAt(i) != SeparadorDecimal)) break;
        aux = '';
        for(; i < len; i++)
            if (strCheck.indexOf(objTextBox.value.charAt(i))!=-1) aux += objTextBox.value.charAt(i);
        aux += key;

        len = aux.length;
        if (len == 0) objTextBox.value = '';
        if (len == 1) objTextBox.value = '0'+ SeparadorDecimal + '0' + aux;
        if (len == 2) objTextBox.value = '0'+ SeparadorDecimal + aux;
        if (len > 2) {
            aux2 = '';
            for (j = 0, i = len - 3; i >= 0; i--) {
                if (j == 3) {
                    aux2 += SeparadorMilesimo;
                    j = 0;
                }
                aux2 += aux.charAt(i);
                j++;
            }
            objTextBox.value = '';
            len2 = aux2.length;
            for (i = len2 - 1; i >= 0; i--)
                objTextBox.value += aux2.charAt(i);
            objTextBox.value += SeparadorDecimal + aux.substr(len - 2, len);
        }
    }
    return false;
    
}

function liberaTravaCampos(parcela_id) {
    var elemento_checkbox = $("parcela_" + parcela_id + "_checkbox");
    if (elemento_checkbox.checked) {
        $("parcela_" + parcela_id + "_data_vencimento").readOnly = false;
        $("recebimento_de_conta_parcelas_" + parcela_id + "_indice").readOnly = false;
        $("recebimento_de_conta_parcelas_" + parcela_id + "_retorna_valor_de_correcao_pelo_indice_em_reais").readOnly = false;
        $("recebimento_de_conta_parcelas_" + parcela_id + "_desconto_em_porcentagem").readOnly = false;
    } else {
        $("parcela_" + parcela_id + "_data_vencimento").readOnly = true;
        $("recebimento_de_conta_parcelas_" + parcela_id + "_indice").readOnly = true;
        $("recebimento_de_conta_parcelas_" + parcela_id + "_retorna_valor_de_correcao_pelo_indice_em_reais").readOnly = true;
        $("recebimento_de_conta_parcelas_" + parcela_id + "_desconto_em_porcentagem").readOnly = true;
    }
}

function liberaCamposTodos(parcela_id) {
    $$('.selecionados').each(function(value, index){
        value.checked = true;
    });
    var elemento_checkbox = $("parcela_" + parcela_id + "_checkbox");
    $("parcela_" + parcela_id + "_data_vencimento").readOnly = false;
    $("recebimento_de_conta_parcelas_" + parcela_id + "_indice").readOnly = false;
    $("recebimento_de_conta_parcelas_" + parcela_id + "_retorna_valor_de_correcao_pelo_indice_em_reais").readOnly = false;
    $("recebimento_de_conta_parcelas_" + parcela_id + "_desconto_em_porcentagem").readOnly = false;
}

function travaCamposNenhum(parcela_id) {
    $$('.selecionados').each(function(value, index){
        value.checked = false;
    });
    var elemento_checkbox = $("parcela_" + parcela_id + "_checkbox");
    $("parcela_" + parcela_id + "_data_vencimento").readOnly = true;
    $("recebimento_de_conta_parcelas_" + parcela_id + "_indice").readOnly = true;
    $("recebimento_de_conta_parcelas_" + parcela_id + "_retorna_valor_de_correcao_pelo_indice_em_reais").readOnly = true;
    $("recebimento_de_conta_parcelas_" + parcela_id + "_desconto_em_porcentagem").readOnly = true;
}

function calculaDesconto(elemento, elemento_valor_total, valor_dos_juros, valor_das_multas) {
    var elemento_valor = parseFloat(elemento.value);
    var elemento_total = parseFloat(elemento_valor_total);
    var juros_valor = parseFloat(valor_dos_juros);
    var multas_valor = parseFloat(valor_das_multas)
    var soma_de_juros_e_multas = juros_valor + multas_valor;

    if (elemento_valor > 0 && elemento_valor <= 100) {
        var resultado = (elemento_valor * soma_de_juros_e_multas) / parseFloat(100);
        elemento_valor_total.value = (elemento_total - resultado).toFixed(2);
    } else {
        elemento.value = null;
    }
}

function verificaDatasProjecao(elemento, data_inserida, data_atual, data_objeto) {
    var regexp = /([0-9]{1,2})\/([0-9]{1,2})\/([0-9]{4})/;
    if (regexp.test(data_inserida)) {
        var data_inserida_quebrada = data_inserida.split("/");
        var data_atual_quebrada = data_atual.split("/");
        var data_inserida_em_date = new Date();
        var data_atual_em_date = new Date();
        if (data_inserida_em_date.setFullYear(data_inserida_quebrada[2], data_inserida_quebrada[1], data_inserida_quebrada[0]) <
            data_atual_em_date.setFullYear(data_atual_quebrada[2], data_atual_quebrada[1], data_atual_quebrada[0]) && data_inserida != data_objeto) {
            alert('Não é possível inserir uma data menor que a atual.')
            elemento.value = data_objeto;
        }
    } else {
        elemento.value = data_objeto;
    }
}


function VerificaData(digData){
    var data = digData.value;
    retorno = true;
    if (data.length == 10){
        var dia = data.substr(0,2)
        var mes = data.substr(3,2)
        var ano = data.substr(6,4)
        
        switch (mes) {
            case '01': case '03': case '05': case '07':
            case '08': case '10': case '12':
                if  (dia <= 31){
                    retorno = false;
                }
                break

            case '04': case '06':
            case '09': case '11':
                if  (dia <= 30){
                    retorno = false;
                }
                break

            case '02':
                if ((ano % 4 == 0) || (ano % 100 == 0) || (ano % 400 == 0)){
                    if (dia <= 29){
                        retorno = false;
                    }
                } else {
                    if (dia <= 28){
                        retorno = false;
                    }
                }
                break
        }
    }
    if (retorno) {
        alert("A Data "+data+" é inválida!");
    }
}
/* PODE SER APROVEITADO */
//function formataValor(campo) {
//        campo.value = filtraCampo(campo);
//        vr = campo.value;
//        tam = vr.length;
//        if (tam <= 2 ){
//                campo.value = vr ; }
//        if ((tam > 2) && (tam <= 5) ){
//                campo.value = vr.substr( 0, tam - 2 ) + ',' + vr.substr( tam - 2, tam ) ; }
//        if ((tam >= 6) && (tam <= 8) ){
//                campo.value = vr.substr( 0, tam - 5 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
//        if ((tam >= 9) && (tam <= 11) ){
//                campo.value = vr.substr( 0, tam - 8 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
//        if ((tam >= 12) && (tam <= 14) ){
//                campo.value = vr.substr( 0, tam - 11 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ; }
//        if ((tam >= 15) && (tam <= 18) ){
//                campo.value = vr.substr( 0, tam - 14 ) + '.' + vr.substr( tam - 14, 3 ) + '.' + vr.substr( tam - 11, 3 ) + '.' + vr.substr( tam - 8, 3 ) + '.' + vr.substr( tam - 5, 3 ) + ',' + vr.substr( tam - 2, tam ) ;}
//}
//
//function filtraCampo(campo){
//        var s = "";
//        var cp = "";
//        var CaracValidos = /[-0123456789]/;
//        vr = campo.value;
//        tam = vr.length;
//        for (i = 0; i < tam ; i++) {
//                if(CaracValidos.test(vr.substring(i,i+1))){
//                        s = s + vr.substring(i,i + 1);}
//        }
//        campo.value = s;
//   return cp = campo.value;
//}

function listarContratos() {
    $('listagem').show();
    $('ocultar_contratos').show();
    $('listar_contratos').hide();
}

function ocultarContratos() {
    $('listagem').hide();
    $('ocultar_contratos').hide();
    $('listar_contratos').show();
}

function selecionarTodas(chkBox) {
    $(chkBox.form).getInputs('checkbox').each(function (elem) {
        if (!elem.disabled) {
            elem.checked = chkBox.checked;
        }
    });
}

function insere_a_razao_social_no_nome_fantasia() {
    $('pessoa_nome').value = $('pessoa_razao_social').value;
}

function diferenciarFormaDePagamentoParaResgate() {
    if ($('forma_de_pagamento').value == '2') {
        $("banco_conta_corrente").show();
        $("cartao_numero_do_cartao").hide();
        $("cartao_validade_do_cartao").hide();
        $("cartao_nome_do_titular_cartao").hide();
        $("cartao_bandeira").hide();
        $("cheque_tipo_de_cheque").hide();
        $("cheque_nome_do_banco").hide();
        $("cheque_nome_do_titular").hide();
        $("cheque_nome_agencia").hide();
        $("cheque_nome_conta").hide();
        $("cheque_numero_do_cheque").hide();
        $("cheque_data_deposito").hide();
        $("cheque_conta_transitoria").hide();
    } else if ($('forma_de_pagamento').value == '3') {        
        $("cheque_tipo_de_cheque").show();
        $("cheque_nome_do_banco").show();
        $("cheque_nome_do_titular").show();
        $("cheque_nome_agencia").show();
        $("cheque_nome_conta").show();
        $("cheque_numero_do_cheque").show();
        $("cheque_data_deposito").show();
        $("cheque_conta_transitoria").show();
        $("banco_conta_corrente").hide();
        $("cartao_numero_do_cartao").hide();
        $("cartao_validade_do_cartao").hide();
        $("cartao_nome_do_titular_cartao").hide();
        $("cartao_bandeira").hide();
    } else if ($('forma_de_pagamento').value == '4') {
        $("cartao_numero_do_cartao").show();
        $("cartao_validade_do_cartao").show();
        $("cartao_nome_do_titular_cartao").show();
        $("cartao_bandeira").show();
        $("banco_conta_corrente").hide();
        $("cheque_tipo_de_cheque").hide();
        $("cheque_nome_do_banco").hide();
        $("cheque_nome_do_titular").hide();
        $("cheque_nome_agencia").hide();
        $("cheque_nome_conta").hide();
        $("cheque_numero_do_cheque").hide();
        $("cheque_data_deposito").hide();
        $("cheque_conta_transitoria").hide();
    } else {
        $("banco_conta_corrente").hide();
        $("cheque_tipo_de_cheque").hide();
        $("cheque_nome_do_banco").hide();
        $("cheque_nome_do_titular").hide();
        $("cheque_nome_agencia").hide();
        $("cheque_nome_conta").hide();
        $("cheque_numero_do_cheque").hide();
        $("cheque_data_deposito").hide();
        $("cheque_conta_transitoria").hide();
        $("cartao_numero_do_cartao").hide();
        $("cartao_validade_do_cartao").hide();
        $("cartao_nome_do_titular_cartao").hide();
    }
}

function aumentaMB() {
    var obj = document.getElementById('MB_window');
    obj.style.width = '700px';
}