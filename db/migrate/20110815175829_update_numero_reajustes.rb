class UpdateNumeroReajustes < ActiveRecord::Migration
  def self.up
    execute 'UPDATE unidades SET numero_de_reajustes = 1'
  end

  def self.down
    execute 'UPDATE unidades SET numero_de_reajustes = NULL'
  end
end
