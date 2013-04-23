class AlteraNomeDoCampoPermissaoNoModelPerfis < ActiveRecord::Migration
 def self.up
    add_column :perfis,:permissao,:string
    remove_column :perfis,:permisao
  end

  def self.down
    remove_column :perfis,:permissao
    add_column :perfis,:permisao,:string
  end
end
