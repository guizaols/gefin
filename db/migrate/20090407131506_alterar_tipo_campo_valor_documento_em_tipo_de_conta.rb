class AlterarTipoCampoValorDocumentoEmTipoDeConta < ActiveRecord::Migration
  def self.up
    remove_column :pagamento_de_contas, :valor_do_documento
    add_column :pagamento_de_contas, :valor_do_documento, :integer
  end

  def self.down
    add_column :pagamento_de_contas, :valor_do_documento, :float
    remove_column :pagamento_de_contas, :valor_do_documento
  end
end
