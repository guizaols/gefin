class AdicionaHoraLiberadaDr < ActiveRecord::Migration
  def self.up
  	add_column :pessoas, :data_hora_liberacao_dr, :datetime
  end

  def self.down
  	remove_column :pessoas,:data_hora_liberacao_dr
  end
end
