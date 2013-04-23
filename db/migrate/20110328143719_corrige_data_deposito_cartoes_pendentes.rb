class CorrigeDataDepositoCartoesPendentes < ActiveRecord::Migration
  def self.up
    begin
      Cartao.transaction do
        cartoes = Cartao.find(:all, :conditions => ['situacao = ? AND data_do_deposito IS NOT NULL', Cartao::GERADO])
        if !cartoes.blank?
          cartoes.each do |cartao|
            cartao.data_do_deposito = nil
            cartao.save false
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
  end
end
