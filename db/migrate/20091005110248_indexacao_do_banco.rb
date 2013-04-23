class IndexacaoDoBanco < ActiveRecord::Migration
  def self.up
    add_index :agencias, :entidade_id
    add_index :cartoes, :parcela_id
    add_index :centros, :entidade_id
    add_index :centros, :codigo_centro
    add_index :centros, :ano
    add_index :centros_unidade_organizacionais, :centro_id, :name => 'cent_und_org_centro_id'
    add_index :centros_unidade_organizacionais, :unidade_organizacional_id, :name => 'cent_und_org_unidade_id'
    add_index :cheques, :parcela_id
    add_index :compromissos, :unidade_id
    add_index :contas_correntes, :unidade_id
    add_index :historicos, :entidade_id
    add_index :impostos, :entidade_id
    add_index :itens_movimentos, :movimento_id
    add_index :lancamento_impostos, :parcela_id
    add_index :localidades, :nome
    add_index :movimentos, :numero_de_controle
    add_index :movimentos, :unidade_id
    add_index :ocorrencia_cheques, :cheque_id
    add_index :pagamento_de_contas, :pessoa_id
    add_index :pagamento_de_contas, :unidade_id
    add_index :pagamento_de_contas, :ano
    add_index :pagamento_de_contas, :numero_de_controle
    add_index :parametro_conta_valores, :unidade_id
    add_index :parcelas, :conta_id
    add_index :parcelas, :conta_type
    add_index :pessoas, :nome
    add_index :pessoas, :cliente
    add_index :pessoas, :funcionario
    add_index :pessoas, :fornecedor
    add_index :pessoas, :razao_social
    add_index :pessoas, :tipo_pessoa
    add_index :pessoas, :cpf
    add_index :pessoas, :cnpj
    add_index :pessoas, :entidade_id
    add_index :plano_de_contas, :ano
    add_index :plano_de_contas, :entidade_id
    add_index :plano_de_contas, :codigo_contabil
    add_index :plano_de_contas, :nome
    add_index :rateios, :parcela_id
    add_index :recebimento_de_contas, :pessoa_id
    add_index :recebimento_de_contas, :unidade_id
    add_index :recebimento_de_contas, :ano
    add_index :recebimento_de_contas, :numero_de_controle
    add_index :servicos, :unidade_id
    add_index :servicos, :descricao
    add_index :unidade_organizacionais, :ano
    add_index :unidade_organizacionais, :entidade_id
    add_index :unidade_organizacionais, :codigo_da_unidade_organizacional, :name => 'undorg_codigo'
    add_index :unidade_organizacionais, :nome
    add_index :unidades, :entidade_id
  end

  def self.down
    remove_index :agencias, :entidade_id
    remove_index :cartoes, :parcela_id
    remove_index :centros, :entidade_id
    remove_index :centros, :codigo_centro
    remove_index :centros, :ano
    remove_index :centros_unidade_organizacionais, :name => 'cent_und_org_centro_id'
    remove_index :centros_unidade_organizacionais, :name => 'cent_und_org_unidade_id'
    remove_index :cheques, :parcela_id
    remove_index :compromissos, :unidade_id
    remove_index :contas_correntes, :unidade_id
    remove_index :historicos, :entidade_id
    remove_index :impostos, :entidade_id
    remove_index :itens_movimentos, :movimento_id
    remove_index :lancamento_impostos, :parcela_id
    remove_index :localidades, :nome
    remove_index :movimentos, :numero_de_controle
    remove_index :movimentos, :unidade_id
    remove_index :ocorrencia_cheques, :cheque_id
    remove_index :pagamento_de_contas, :pessoa_id
    remove_index :pagamento_de_contas, :unidade_id
    remove_index :pagamento_de_contas, :ano
    remove_index :pagamento_de_contas, :numero_de_controle
    remove_index :parametro_conta_valores, :unidade_id
    remove_index :parcelas, :conta_id
    remove_index :parcelas, :conta_type
    remove_index :pessoas, :nome
    remove_index :pessoas, :cliente
    remove_index :pessoas, :funcionario
    remove_index :pessoas, :fornecedor
    remove_index :pessoas, :razao_social
    remove_index :pessoas, :tipo_pessoa
    remove_index :pessoas, :cpf
    remove_index :pessoas, :cnpj
    remove_index :pessoas, :entidade_id
    remove_index :plano_de_contas, :ano
    remove_index :plano_de_contas, :entidade_id
    remove_index :plano_de_contas, :codigo_contabil
    remove_index :plano_de_contas, :nome
    remove_index :rateios, :parcela_id
    remove_index :recebimento_de_contas, :pessoa_id
    remove_index :recebimento_de_contas, :unidade_id
    remove_index :recebimento_de_contas, :ano
    remove_index :recebimento_de_contas, :numero_de_controle
    remove_index :servicos, :unidade_id
    remove_index :servicos, :descricao
    remove_index :unidade_organizacionais, :ano
    remove_index :unidade_organizacionais, :entidade_id
    remove_index :unidade_organizacionais, :name => 'undorg_codigo'
    remove_index :unidade_organizacionais, :nome
    remove_index :unidades, :entidade_id
  end
end
