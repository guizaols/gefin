module PessoasHelper

  def diferenciar_PF_PJ
    update_page do |page|
      page.if "$('pessoa_tipo_pessoa').value == '#{Pessoa::FISICA}'" do
        page.replace_html "nome", 'Nome* '
        page.hide :razao_social
        page.hide :contato
        page.show :cpf
        page.show :data_nascimento
        page.hide :cnpj
        page.replace_html "rg_ie",'RG*'
        page.show :label_pessoa_funcionario
      end
      page.if "$('pessoa_tipo_pessoa').value == '#{Pessoa::JURIDICA}'" do
        page.replace_html "nome", 'Nome Fantasia* '
        page.show :razao_social
        page.show :contato
        page.show :cnpj
        page.hide :data_nascimento
        page.hide :cpf
        page.replace_html "rg_ie",'IE*'
        page.hide :label_pessoa_funcionario
      end
    end
  end

  def pesquisa_se_cpf_ou_cnpj_ja_existem(tipo_documento,id)
    remote_function(:url => {:action => :verifica_se_existe_cpf_cnpj}, :with => "'documento=' + $('pessoa_#{tipo_documento}').value + '&id='+ '#{id}' + '&tipo_de_documento=' + '#{tipo_documento}'", :loading => "Element.show('loading_form');", :success => "Element.hide('loading_form');")
  end

end
