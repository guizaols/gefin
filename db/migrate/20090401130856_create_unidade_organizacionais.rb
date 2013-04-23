class CreateUnidadeOrganizacionais < ActiveRecord::Migration
  def self.up
    create_table :unidade_organizacionais do |t|
      t.integer :ano
      t.integer :entidade_id
      t.string :codigo_da_unidade_organizacional
      t.string :nome
      t.string :codigo_reduzido
      t.timestamps
    end
  end

  def self.down
    drop_table :unidade_organizacionais
  end
end
