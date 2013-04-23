class AdicionaSituacaoDoChequeEmMovimento < ActiveRecord::Migration
  def self.up
    add_column :movimentos, :situacao_cheque, :integer
  end

  def self.down
    remove_column :movimentos, :situacao_cheque
  end
end
