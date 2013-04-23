class AdicionarCampoCidadeEmAgencia < ActiveRecord::Migration
def self.up
    add_column :agencias, :cidade, :string
    add_column :agencias, :cep, :string
  end

  def self.down
    remove_column :agencias, :cidade
    remove_column :agencias, :cep
  end
end
