class ExcluiLancamentoSesiSaudeRoo < ActiveRecord::Migration
  def self.up
    begin
      Movimento.transaction do
        conta = RecebimentoDeConta.find_by_numero_de_controle('SSROO-CTR01/110053')
        if conta
          movimento = Movimento.find_by_conta_id_and_conta_type(conta.id, 'RecebimentoDeConta')
          if movimento
            movimento.destroy
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
