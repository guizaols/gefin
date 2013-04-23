module ConveniosHelper
  def listagem_de_contas_para_convenio(convenio)
    listagem_de_contas_para_convenio = convenio.contas_correntes.collect{|conta| link_to conta.descricao, contas_corrente_path(conta)}.join("<br />").untaint
    listagem_de_contas_para_convenio
  end
end
