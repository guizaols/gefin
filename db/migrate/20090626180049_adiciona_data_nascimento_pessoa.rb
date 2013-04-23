class AdicionaDataNascimentoPessoa < ActiveRecord::Migration
  def self.up
    add_column :pessoas, :data_nascimento, :datetime
  end

  def self.down
    remove_column :pessoas, :data_nascimento
  end
end
