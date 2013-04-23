class TrocaTipoDateParaDateTimeEmTodaBase < ActiveRecord::Migration
  def self.up
    change_column :pagamento_de_contas,:data_lancamento,:datetime
    change_column :pagamento_de_contas,:data_emissao,:datetime
    change_column :pagamento_de_contas,:primeiro_vencimento,:datetime
    change_column :unidades,:data_de_referencia,:datetime
    change_column :parcelas,:data_vencimento,:datetime
  end

  def self.down
  end
end
