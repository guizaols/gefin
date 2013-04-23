class AddConvenioIdToContasCorrentes < ActiveRecord::Migration
  def self.up
    add_column :contas_correntes, :convenio_id, :integer
  end

  def self.down
    remove_column :contas_correntes, :convenio_id
  end
end
