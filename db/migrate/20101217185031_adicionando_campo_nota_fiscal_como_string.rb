class AdicionandoCampoNotaFiscalComoString < ActiveRecord::Migration
  def self.up
    add_column :pagamento_de_contas, :numero_nota_fiscal_string, :string
    begin
      PagamentoDeConta.transaction do
        MigraNotaFicalParaStringPagamentoDeConta.all.each do |pagamento|
          pagamento.numero_nota_fiscal_string = pagamento.numero_nota_fiscal
          pagamento.save!
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    remove_column :pagamento_de_contas, :numero_nota_fiscal_string
    begin
      PagamentoDeConta.transaction do
        MigraNotaFicalParaStringPagamentoDeConta.all.each do |pagamento|
          pagamento.numero_nota_fiscal_string = nil
          pagamento.save!
        end
      end
    rescue Exception => e
      raise e.message
    end
  end
end

class MigraNotaFicalParaStringPagamentoDeConta < ActiveRecord::Base
  set_table_name 'pagamento_de_contas'
end