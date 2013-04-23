module ImpostosHelper

  def diferenciar_impostos
    update_page do |page|
    page.if "$('imposto_classificacao').value == ''" do
        page.hide :conta_debito
        page.hide :conta_credito
    end
      page.if "$('imposto_classificacao').value == '#{Imposto::INCIDE}'" do
        page.show :conta_debito
        page.show :conta_credito
      end
      page.if "$('imposto_classificacao').value == '#{Imposto::RETEM}'" do
        page.hide :conta_debito
        page.show :conta_credito
      end
    end
  end

end
