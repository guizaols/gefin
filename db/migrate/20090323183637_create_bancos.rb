class CreateBancos < ActiveRecord::Migration
  def self.up
    create_table :bancos do |t|
      t.string :descricao
      t.boolean :ativo
      t.string :codigo_do_banco
      t.string :codigo_do_zeus
      t.string :digito_verificador

      t.timestamps
    end
  end

  def self.down
    drop_table :bancos
  end
end
