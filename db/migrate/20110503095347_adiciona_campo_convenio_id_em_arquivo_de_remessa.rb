class AdicionaCampoConvenioIdEmArquivoDeRemessa < ActiveRecord::Migration
  def self.up
    add_column :arquivo_remessas,:convenio_id,:integer
  end

  def self.down
    remove_column :arquivo_remessas,:convenio_id
  end
end
