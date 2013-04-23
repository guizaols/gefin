while (!AgendamentoCalculoContabilizacaoReceitas.thread_stopped?)
  file = File.new("tmp/calculo_contabilizacao_receitas_last_execution", "w")
  file.puts Time.now.to_i
  file.close
  AgendamentoCalculoContabilizacaoReceitas.find_to_execute.each do |agendamento|
    agendamento.calcular
    file = File.new("tmp/calculo_contabilizacao_receitas_last_execution", "w")
    file.puts Time.now.to_i
    file.close
  end
  sleep 1200
end