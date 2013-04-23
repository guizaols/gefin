class AddHorarioExecussaoDeCalculosPesados < ActiveRecord::Migration
  def self.up
    add_column :unidades, :hora_execussao_calculos_pesados, :integer
  end

  def self.down
    remove_column :unidades, :hora_execussao_calculos_pesados
  end
end
