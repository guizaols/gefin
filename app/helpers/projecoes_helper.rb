module ProjecoesHelper
  def valor_por_extenso(valor)
    if valor > 0
      "(#{GExtenso.moeda(valor)})"
    else
      ""
    end
  end

  def numero_por_extenso(valor)
    if valor > 0
      "(#{GExtenso.numero(valor)})"
    else
      ""
    end
  end
end
