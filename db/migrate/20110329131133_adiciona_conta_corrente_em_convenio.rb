class AdicionaContaCorrenteEmConvenio < ActiveRecord::Migration
  def self.up
    add_column :convenios, :contas_corrente_id, :integer
    remove_column :contas_correntes, :convenio_id
  end

  def self.down
    remove_column :convenios, :contas_corrente_id
    add_column :contas_correntes, :convenio_id, :integer
  end
end
