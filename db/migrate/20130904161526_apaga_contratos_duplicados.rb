class ApagaContratosDuplicados < ActiveRecord::Migration

  def self.up
    begin
      RecebimentoDeConta.transaction do
				### select * from parcelas where conta_id = 70724 AND conta_type = 'RecebimentoDeConta'
				### select * from parcelas where conta_id = 70725 AND conta_type = 'RecebimentoDeConta'
				Parcela.delete_all("conta_id = 70724 AND conta_type = 'RecebimentoDeConta'")
				Parcela.delete_all("conta_id = 70725 AND conta_type = 'RecebimentoDeConta'")
				
				### select * from movimentos where numero_de_controle = 'SSSIN-CTR09/130137'
				Movimento.delete_all("numero_de_controle = 'SSSIN-CTR09/130137'")

				### select * from recebimento_de_contas where numero_de_controle = 'SSSIN-CTR09/130137'
				RecebimentoDeConta.delete_all("numero_de_controle = 'SSSIN-CTR09/130137'")
      end
    rescue Exception => e
      p e.message
    end
  end

  def self.down
  end
  
end
