class AddDataDeNascimentoToDependentes < ActiveRecord::Migration
  def self.up
    add_column :dependentes, :data_de_nascimento, :date
  end

  def self.down
    remove_column :dependentes, :data_de_nascimento
  end
end
