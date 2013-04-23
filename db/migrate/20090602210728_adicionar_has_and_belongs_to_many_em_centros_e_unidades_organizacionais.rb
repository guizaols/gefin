class AdicionarHasAndBelongsToManyEmCentrosEUnidadesOrganizacionais < ActiveRecord::Migration
  def self.up
    create_table 'centros_unidade_organizacionais', :id => false do |t|
      t.integer :centro_id
      t.integer :unidade_organizacional_id
    end
    remove_column :centros, :unidade_organizacional_id
  end

  def self.down
    drop_table 'centros_unidade_organizacionais'
    add_column :centros, :unidade_organizacional_id, :integer
  end
end
