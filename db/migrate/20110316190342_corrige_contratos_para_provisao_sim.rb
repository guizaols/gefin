class CorrigeContratosParaProvisaoSim < ActiveRecord::Migration
  def self.up
    begin
      RecebimentoDeConta.transaction do
        numeros_de_controle = ["SECBA-CTR12/100394", "SECBA-CTR12/100568", "SECBA-CTR12/100668", "SECBA-CTR12/100834", "SECBA-CTR12/100853",
          "SECBA-CTR01/110043", "SECBA-CTR01/110064", "SECBA-CTR01/110223", "SECBA-CTR01/110224", "SECBA-CTR01/110226", "SECBA-CTR01/110227",
          "SECBA-CTR01/110228", "SECBA-CTR01/110230", "SECBA-CTR01/110231", "SECBA-CTR01/110233", "SECBA-CTR01/110234", "SEVG-CTR02/110471",
          "SECBA-CTR01/110235", "SECBA-CTR01/110236", "SECBA-CTR01/110237", "SECBA-CTR01/110238", "SECBA-CTR01/110239", "SEVG-OR02/110002",
          "SECBA-CTR01/110240", "SECBA-CTR01/110241", "SECBA-CTR01/110242", "SECBA-CTR01/110243", "SECBA-CTR01/110244", "SECBA-CTR01/110245",
          "SECBA-CTR01/110246", "SECBA-CTR01/110247", "SECBA-CTR01/110248", "SECBA-CTP01/110005", "SECBA-CTR01/110249", "SECBA-CTR01/110250",
          "SECBA-CTR01/110251", "SECBA-CTR01/110252", "SECBA-CTR01/110253", "SECBA-CTR01/110254", "SECBA-CTR01/110255", "SECBA-CTR01/110256",
          "SECBA-CTR01/110257", "SECBA-CTR01/110258", "SECBA-CTR01/110259", "SECBA-CTR01/110261", "SECBA-CTR01/110262", "SECBA-CTR01/110263",
          "SECBA-CTR01/110264", "SECBA-CTR01/110265", "SECBA-CTR01/110266", "SECBA-CTR01/110267", "SECBA-CTR02/110001", "SECBA-CTR02/110002",
          "SECBA-CTR02/110003", "SECBA-CTR02/110004", "SECBA-CTR02/110005", "SECBA-CTR02/110006", "SECBA-CTR02/110007", "SECBA-CTR02/110008",
          "SECBA-CTR02/110009", "SECBA-CTR02/110010", "SECBA-CTR02/110011", "SECBA-CTR02/110012", "SECBA-CTR02/110013", "SECBA-CTR02/110015",
          "SECBA-CTR02/110016", "SECBA-CTR02/110017", "SECBA-CTR02/110018", "SECBA-CTR02/110019", "SECBA-CTR02/110020", "SECBA-CTR02/110021",
          "SECBA-CTR02/110022", "SECBA-CTR02/110023", "SECBA-CTR02/110024", "SECBA-CTR02/110025", "SECBA-CTR02/110026", "SECBA-CTR02/110027",
          "SECBA-CTR02/110028", "SECBA-CTR02/110029", "SECBA-CTR02/110030", "SECBA-CTR02/110032", "SECBA-CTR02/110033", "SECBA-CTR02/110034",
          "SECBA-CTP02/110001", "SECBA-CTR02/110035", "SECBA-CTR02/110036", "SECBA-CTR02/110037", "SEVG-CTR01/110175"]

        numeros_de_controle.each do |numero|
          conta = RecebimentoDeConta.find_by_numero_de_controle(numero)
          if conta
            conta.provisao = RecebimentoDeConta::SIM
            conta.data_inicio = Date.new(2011, 2, 5)
            if conta.data_inicio && conta.vigencia && conta.vigencia > 0
              conta.data_final = conta.data_inicio.to_date + conta.vigencia.months
            end
            conta.save false
            conta.efetua_lancamento!
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end

  def self.down
    begin
      RecebimentoDeConta.transaction do
        numeros_de_controle = ["SECBA-CTR12/100394", "SECBA-CTR12/100568", "SECBA-CTR12/100668", "SECBA-CTR12/100834", "SECBA-CTR12/100853",
          "SECBA-CTR01/110043", "SECBA-CTR01/110064", "SECBA-CTR01/110223", "SECBA-CTR01/110224", "SECBA-CTR01/110226", "SECBA-CTR01/110227",
          "SECBA-CTR01/110228", "SECBA-CTR01/110230", "SECBA-CTR01/110231", "SECBA-CTR01/110233", "SECBA-CTR01/110234", "SEVG-CTR02/110471",
          "SECBA-CTR01/110235", "SECBA-CTR01/110236", "SECBA-CTR01/110237", "SECBA-CTR01/110238", "SECBA-CTR01/110239", "SEVG-OR02/110002",
          "SECBA-CTR01/110240", "SECBA-CTR01/110241", "SECBA-CTR01/110242", "SECBA-CTR01/110243", "SECBA-CTR01/110244", "SECBA-CTR01/110245",
          "SECBA-CTR01/110246", "SECBA-CTR01/110247", "SECBA-CTR01/110248", "SECBA-CTP01/110005", "SECBA-CTR01/110249", "SECBA-CTR01/110250",
          "SECBA-CTR01/110251", "SECBA-CTR01/110252", "SECBA-CTR01/110253", "SECBA-CTR01/110254", "SECBA-CTR01/110255", "SECBA-CTR01/110256",
          "SECBA-CTR01/110257", "SECBA-CTR01/110258", "SECBA-CTR01/110259", "SECBA-CTR01/110261", "SECBA-CTR01/110262", "SECBA-CTR01/110263",
          "SECBA-CTR01/110264", "SECBA-CTR01/110265", "SECBA-CTR01/110266", "SECBA-CTR01/110267", "SECBA-CTR02/110001", "SECBA-CTR02/110002",
          "SECBA-CTR02/110003", "SECBA-CTR02/110004", "SECBA-CTR02/110005", "SECBA-CTR02/110006", "SECBA-CTR02/110007", "SECBA-CTR02/110008",
          "SECBA-CTR02/110009", "SECBA-CTR02/110010", "SECBA-CTR02/110011", "SECBA-CTR02/110012", "SECBA-CTR02/110013", "SECBA-CTR02/110015",
          "SECBA-CTR02/110016", "SECBA-CTR02/110017", "SECBA-CTR02/110018", "SECBA-CTR02/110019", "SECBA-CTR02/110020", "SECBA-CTR02/110021",
          "SECBA-CTR02/110022", "SECBA-CTR02/110023", "SECBA-CTR02/110024", "SECBA-CTR02/110025", "SECBA-CTR02/110026", "SECBA-CTR02/110027",
          "SECBA-CTR02/110028", "SECBA-CTR02/110029", "SECBA-CTR02/110030", "SECBA-CTR02/110032", "SECBA-CTR02/110033", "SECBA-CTR02/110034",
          "SECBA-CTP02/110001", "SECBA-CTR02/110035", "SECBA-CTR02/110036", "SECBA-CTR02/110037", "SEVG-CTR01/110175"]

        numeros_de_controle.each do |numero|
          conta = RecebimentoDeConta.find_by_numero_de_controle(numero)
          if conta
            conta.provisao = RecebimentoDeConta::NAO
            conta.save false
            conta.movimentos.each do |mov|
              if mov.lancamento_inicial
                mov.destroy || raise("Não foi possível excluir o movimento -- ID: #{mov.id}")
              end
            end
          end
        end
      end
    rescue Exception => e
      raise e.message
    end
  end
end
