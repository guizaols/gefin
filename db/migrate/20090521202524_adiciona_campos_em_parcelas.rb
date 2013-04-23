class AdicionaCamposEmParcelas < ActiveRecord::Migration
  def self.up
    add_column :parcelas, :forma_de_pagamento, :integer
    add_column :parcelas, :conta_corrente_id, :integer
    add_column :parcelas, :numero_do_comprovante, :string
    add_column :parcelas, :observacoes, :text
    add_column :parcelas, :data_do_pagamento, :datetime
  end

  def self.down
    remove_column :parcelas, :forma_de_pagamento
    remove_column :parcelas, :conta_corrente_id
    remove_column :parcelas, :numero_do_comprovante
    remove_column :parcelas, :observacoes
    remove_column :parcelas, :data_do_pagamento
  end
end
