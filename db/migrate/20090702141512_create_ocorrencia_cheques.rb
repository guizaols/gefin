class CreateOcorrenciaCheques < ActiveRecord::Migration
  def self.up
    create_table :ocorrencia_cheques do |t|
      t.integer :cheque_id
      t.datetime :data_do_evento
      t.integer :tipo_da_ocorrencia
      t.integer :alinea
      t.timestamps
    end
  end

  def self.down
    drop_table :ocorrencia_cheques
  end
end
