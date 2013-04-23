class AdicionaCampoDataEnvioAoDr < ActiveRecord::Migration
  def self.up
  	add_column :parcelas,:data_envio_ao_dr,:date
  end

  def self.down
  remove_column :parcelas,:data_envio_ao_dr
  end
end
