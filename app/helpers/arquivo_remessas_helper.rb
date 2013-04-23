module ArquivoRemessasHelper

  def checked_parcelas(ids, id)
    unless ids.blank?
      ids.include?(id)
    else
      false
    end
  end

  def gerar_arquivo(arquivo)
    if arquivo.data_geracao.blank?
      "| #{link_to_remote 'Gerar',:url => { :action=>"gerar", :controller=>"arquivo_remessas", :id=> @arquivo_remessa.id}}"
    else
      "| #{link_to_remote 'Gerar',{:url => { :action=>"gerar", :controller=>"arquivo_remessas", :id=> @arquivo_remessa.id}, :confirm => "Esse arquivo foi gerado em #{data_formatada(arquivo.data_geracao)}, gerar novamente?"}}"
    end
  end

end
