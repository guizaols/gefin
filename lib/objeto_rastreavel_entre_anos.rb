module ObjetoRastreavelEntreAnos
  
  def self.included(base)
    base.belongs_to :objeto_do_proximo_ano, :class_name => "#{base}", :foreign_key => 'objeto_do_proximo_ano_id'
    base.validate 'valida_ano_entidade'
  end

  def pesquisar_correspondente_no_ano_de(ano)
    objeto = self
    raise "Não é possível realizar um lançamento com data anterior à sua criação" if self.ano > ano
    while objeto.ano != ano
      unless objeto.objeto_do_proximo_ano.blank?
        objeto = objeto.objeto_do_proximo_ano
      else
        resultado = objeto.is_a?(Centro) ? Centro.find_by_entidade_id_and_codigo_centro_and_ano(objeto.entidade_id, objeto.codigo_centro, objeto.ano + 1) :
          UnidadeOrganizacional.find_by_entidade_id_and_codigo_da_unidade_organizacional_and_ano(objeto.entidade_id, objeto.codigo_da_unidade_organizacional, objeto.ano + 1)
        objeto = resultado || raise("#{self.nome} não possui correpondente no ano #{ano}")
      end
    end
    objeto
  end

  def valida_ano_entidade
    errors.add :ano, 'O objeto do proximo ano deve ter ano válido.' if (objeto_do_proximo_ano) && (objeto_do_proximo_ano.ano != ano + 1)
    errors.add :entidade, 'O objeto do proximo ano deve ter entidade válida.' if (objeto_do_proximo_ano) && (objeto_do_proximo_ano.entidade != entidade)
  end
   
end
