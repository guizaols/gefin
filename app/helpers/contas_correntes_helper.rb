module ContasCorrentesHelper

  def diferenciar_identificador
    "if ($('contas_corrente_identificador').value == '#{ContasCorrente::BANCO}') {
       Element.show('tr_agencia');
       Element.show('tr_numero_conta');
       Element.show('tr_tipo');
     } else {
       Element.hide('tr_agencia');
       Element.hide('tr_numero_conta');
       Element.hide('tr_tipo');
     }"
  end

end
