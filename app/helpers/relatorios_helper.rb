module RelatoriosHelper

  def dados_para_ordenacao
    [['', ''], ['Unidade Organizacional', 'unidade_organizacionais.codigo_da_unidade_organizacional'], ['Centro', 'centros.codigo_centro'], ['Conta Contábil', 'plano_de_contas.codigo_contabil'], ['Serviço', 'servicos.descricao'], ['Cliente', 'pessoas.nome']]
  end

end
