class CreateServicos < ActiveRecord::Migration
  def self.up
    create_table :servicos do |t|
      t.integer :unidade_id
      t.string :descricao
      t.boolean :ativo
      t.string :modalidade
      t.string :codigo_do_servico_sigat

      t.timestamps
    end
  end

  def self.down
    drop_table :servicos
  end
end
