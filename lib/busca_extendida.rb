module BuscaExtendida

  private

  def preencher_array_para_campo_com_auto_complete(params, chave_do_params, campo_no_banco)
    unless params["nome_#{chave_do_params}"].blank?
      @sqls << "(#{campo_no_banco} = ?)"
      @variaveis << params["#{chave_do_params}_id"]
    end
  end

  def preencher_array_para_buscar_por_data_minima(params, chave_do_params, campo_no_banco)
    unless params[chave_do_params].blank?
      @variaveis << params[chave_do_params].to_date
      @sqls << "(#{campo_no_banco} >= ?)"
    end
  rescue
    @sqls << '(0=1)'
  end

  def preencher_array_para_buscar_por_data_maxima(params, chave_do_params, campo_no_banco)
    unless params[chave_do_params].blank?
      @variaveis << params[chave_do_params].to_date
      @sqls << "(#{campo_no_banco} <= ?)"
    end
  rescue
    @sqls << '(0=1)'
  end
  
  def preencher_array_para_campo_simples(params, chave_do_params, campo_no_banco)
    unless params[chave_do_params.to_s].blank?
      @variaveis << params[chave_do_params.to_s]
      @sqls << "(#{campo_no_banco} = ?)"
    end
  end

  def preencher_array_para_buscar_por_faixa_de_datas(params, chave_do_params, campo_no_banco)
    preencher_array_para_buscar_por_data_minima(params, "#{chave_do_params}_min", campo_no_banco)
    preencher_array_para_buscar_por_data_maxima(params, "#{chave_do_params}_max", campo_no_banco)
  end
  
  

end