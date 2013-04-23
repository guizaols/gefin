class AddLimiteDiasParaEstornoToUnidades < ActiveRecord::Migration
    def self.up
    add_column :unidades, :limitediasparaestornodeparcelas, :integer
    execute "update unidades set limitediasparaestornodeparcelas = 5000"
  end

  def self.down
    remove_column :unidades, :limitediasparaestornodeparcelas
  end
end
