class AdicionaCamposNaEntidadeConvenio < ActiveRecord::Migration
  def self.up
    add_column :convenios,:tipo_convenio,:integer
    add_column :convenios,:banco_id,:integer
    add_column :convenios,:agencia_id,:integer
    add_column :convenios,:servico_id,:integer
    add_column :convenios,:situacao,:integer
    add_column :convenios,:data_registro,:integer
    add_column :convenios,:numero_carteira,:string
    add_column :convenios,:variacao_carteira,:string
    add_column :convenios,:tipo_documento,:integer
    add_column :convenios,:indicativo_sacador,:string
    add_column :convenios,:local_pagamento,:string
    add_column :convenios,:instrucoes,:string
    add_column :convenios,:reservado_empresa,:string
    add_column :convenios,:numero_convenio_banco,:string
    add_column :convenios,:numero_bordero,:string
    add_column :convenios,:cod_operacao,:string
    add_column :convenios,:cod_respons,:string
    add_column :convenios,:tipo_convenio_boleto,:integer
    add_column :convenios,:local_emissao_documento,:integer
    add_column :convenios,:ident_distribuicao,:integer
    add_column :convenios,:ident_aceite,:integer
    

  end

  def self.down
  end
end
