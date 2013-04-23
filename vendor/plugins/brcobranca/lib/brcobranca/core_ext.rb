module Brcobranca
  # Métodos auxiliares de formatação
  module Formatacao
    # Formata como CPF
    def to_br_cpf
      (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{3})(.{3})(.{3})(.{2})$/,'\1.\2.\3-\4')
    end

    # Formata como CEP
    def to_br_cep
      (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{5})(.{3})$/,'\1-\2')
    end

    # Formata como CNPJ
    def to_br_cnpj
      (self.kind_of?(String) ? self : self.to_s).gsub(/^(.{2})(.{3})(.{3})(.{4})(.{2})$/,'\1.\2.\3/\4-\5')
    end

    # Gera formatação automatica do documento baseado no tamanho do campo.
    def formata_documento
      case (self.kind_of?(String) ? self : self.to_s).size
      when 8 then self.to_br_cep
      when 11 then self.to_br_cpf
      when 14 then self.to_br_cnpj
      else
        self
      end
    end

    # Remove caracteres que não sejam numéricos do tipo MOEDA
    def limpa_valor_moeda
      return self unless self.kind_of?(String) && self.moeda?
      self.somente_numeros
    end

    # Remove caracteres que não sejam numéricos
    def somente_numeros
      return self unless self.kind_of?(String)
      self.gsub(/\D/,'')
    end

    # Completa zeros a esquerda.
    #  Ex. numero="123" :tamanho=>3 | numero="123"
    #  Ex. numero="123" :tamanho=>4 | numero="0123"
    #  Ex. numero="123" :tamanho=>5 | numero="00123"
    def zeros_esquerda(options={})
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      return valor_inicial if (valor_inicial !~ /\S/)
      digitos = options[:tamanho] || valor_inicial.size

      diferenca = (digitos - valor_inicial.size)

      return valor_inicial if (diferenca <= 0)
      return (("0" * diferenca) + valor_inicial )
    end

    # Monta a linha digitável padrão para todos os bancos segundo a BACEN.
    # Retorna + nil + para Codigo de Barras em branco,
    # Codigo de Barras com tamanho diferente de 44 dígitos e
    # Codigo de Barras que não tenham somente caracteres numéricos.
    #   A linha digitável será composta por cinco campos:
    #   1º campo
    #   Composto pelo código de Banco, código da moeda, as cinco primeiras posições do campo livre
    #   e o dígito verificador deste campo;
    #   2º campo
    #   Composto pelas posições 6ª a 15ª do campo livre e o dígito verificador deste campo;
    #   3º campo
    #   Composto pelas posições 16ª a 25ª do campo livre e o dígito verificador deste campo;
    #   4º campo
    #   Composto pelo dígito verificador do código de barras, ou seja, a 5ª posição do código de
    #   barras;
    #   5º campo
    #   Composto pelo fator de vencimento com 4(quatro) caracteres e o valor do documento com
    #   10(dez) caracteres, sem separadores e sem edição.
    #   Entre cada campo deverá haver espaço equivalente a 2 (duas) posições, sendo a 1ª
    #   interpretada por um ponto (.) e a 2ª por um espaço em branco.
    def linha_digitavel
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      raise ArgumentError, "Somente números" unless valor_inicial.numeric?
      raise ArgumentError, "Precisa conter 44 caracteres e você passou um valor com #{valor_inicial.size} caracteres" if valor_inicial.size != 44

      dv_1 = ("#{valor_inicial[0..3]}#{valor_inicial[19..23]}").modulo10
      campo_1_dv = "#{valor_inicial[0..3]}#{valor_inicial[19..23]}#{dv_1}"
      campo_linha_1 = "#{campo_1_dv[0..4]}.#{campo_1_dv[5..9]}"

      dv_2 = "#{valor_inicial[24..33]}".modulo10
      campo_2_dv = "#{valor_inicial[24..33]}#{dv_2}"
      campo_linha_2 = "#{campo_2_dv[0..4]}.#{campo_2_dv[5..10]}"

      dv_3 = "#{valor_inicial[34..43]}".modulo10
      campo_3_dv = "#{valor_inicial[34..43]}#{dv_3}"
      campo_linha_3 = "#{campo_3_dv[0..4]}.#{campo_3_dv[5..10]}"

      campo_linha_4 = "#{valor_inicial[4..4]}"

      campo_linha_5 = "#{valor_inicial[5..18]}"

      "#{campo_linha_1} #{campo_linha_2} #{campo_linha_3} #{campo_linha_4} #{campo_linha_5}"
    end
  end

  # métodos auxiliares de cálculos
  module Calculo
    # Método padrão para cálculo de módulo 10 segundo a BACEN.
    def modulo10
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      raise ArgumentError, "Somente números" unless valor_inicial.numeric?

      total = 0
      multiplicador = 2

      valor_inicial.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * multiplicador).soma_digitos
        multiplicador = multiplicador == 2 ? 1 : 2
      end

      valor = (10 - (total % 10))
      valor == 10 ? 0 : valor
    end

    # Método padrão para cálculo de módulo 11 com multiplicaroes de 9 a 2 segundo a BACEN.
    # Usado no DV do Nosso Numero, Agência e Cedente.
    #  Retorna + nil + para todos os parametros que nao forem String
    #  Retorna + nil + para String em branco
    def modulo11_9to2
      total = self.multiplicador([9,8,7,6,5,4,3,2])

      return (total % 11 )
    end

    # Método padrão para cálculo de módulo 11 com multiplicaroes de 2 a 9 segundo a BACEN.
    # Usado no DV do Código de Barras.
    #  Retorna + nil + para todos os parametros que não forem String
    #  Retorna + nil + para String em branco
    def modulo11_2to9
      total = self.multiplicador([2,3,4,5,6,7,8,9])

      valor = (11 - (total % 11))
      return [0,10,11].include?(valor) ? 1 : valor
    end

    def modulo_10_banespa
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      raise ArgumentError, "Somente números" unless valor_inicial.numeric?

      fatores = [7,3,1,9,7,3,1,9,7,3]
      total = 0
      posicao = 0
      valor_inicial.split(//).each do |digito|
        total += (digito.to_i * fatores[posicao]).to_s.split(//)[-1].to_i
        posicao = (posicao < (fatores.size - 1)) ? (posicao + 1) : 0
      end
      dv = 10 - total.to_s.split(//)[-1].to_i
      dv == 10 ? 0 : dv
    end

    # Retorna o dígito verificador de <b>modulo 11(9-2)</b> trocando retorno <b>10 por X</b>.
    #  Usado por alguns bancos.
    def modulo11_9to2_10_como_x
      valor = self.modulo11_9to2
      valor == 10 ? "X" : valor
    end

    # Retorna o dígito verificador de <b>modulo 11(9-2)</b> trocando retorno <b>10 por 0</b>.
    #  Usado por alguns bancos.
    def modulo11_9to2_10_como_zero
      valor = self.modulo11_9to2
      valor == 10 ? 0 : valor
    end

    # Soma números inteiros positivos com 2 dígitos ou mais
    # Retorna <b>0(zero)</b> caso seja impossível.
    #  Ex. 1 = 1
    #  Ex. 11 = (1+1) = 2
    #  Ex. 13 = (1+3) = 4
    def soma_digitos
      valor_inicial = self.kind_of?(Fixnum) ? self : self.to_i
      return 0 if valor_inicial == 0
      return valor_inicial if valor_inicial <= 9

      valor_inicial = valor_inicial.to_s
      total = 0

      0.upto(valor_inicial.size-1) {|digito| total += valor_inicial[digito,1].to_i }

      return total
    end

    def multiplicador(fatores)
      valor_inicial = self.kind_of?(String) ? self : self.to_s
      raise ArgumentError, "Somente números" unless valor_inicial.numeric?

      total = 0
      multiplicador_posicao = 0

      valor_inicial.split(//).reverse!.each do |caracter|
        total += (caracter.to_i * fatores[multiplicador_posicao])
        multiplicador_posicao = (multiplicador_posicao < (fatores.size - 1)) ? (multiplicador_posicao + 1) : 0
      end
      total.to_i
    end
  end

  # Métodos auxiliares de verificação e validação.
  module Validacao
    # Verifica se o valor é moeda.
    #  Ex. +1.232.33
    #  Ex. -1.232.33
    #  Ex. 1.232.33
    def moeda?
      value = self.kind_of?(String) ? self : self.to_s
      value =~ /^(\+|-)?\d+((\.|,)\d{3}*)*((\.|,)\d{2}*)$/ ? true : false
    end
  end

  # Métodos auxiliares de limpeza.
  module Limpeza
    # Retorna uma String contendo exatamente o valor FLOAT
    def limpa_valor_moeda
      valor_inicial = self.to_s
      (valor_inicial + ("0" * (2 - valor_inicial.split(/\./).last.size ))).somente_numeros
    end
  end

  # Métodos auxiliares de cálculos envolvendo <b>Datas</b>.
  module CalculoData
    # Calcula o número de dias corridos entre a <b>data base ("Fixada" em 07.10.1997)</b> e a <b>data de vencimento</b> desejado:
    #  VENCIMENTO 04/07/2000
    #  DATA BASE - 07/10/1997
    #  FATOR DE VENCIMENTO 1001
    def fator_vencimento
      data_base = Date.parse "1997-10-07"
      (self - data_base).to_i
    end

    # Mostra a data em formato <b>dia/mês/ano</b>
    def to_s_br
      self.strftime('%d/%m/%Y')
    end
    # Retorna string contendo número de dias julianos:
    #  O cálculo é feito subtraindo-se a data atual, pelo último dia válido do ano anterior,
    #  acrescentando-se o último algarismo do ano atual na quarta posição.
    #  Deve retornar string com 4 digitos.
    #  Ex. Data atual = 11/02/2009
    #     Data válida ano anterior = 31/12/2008
    #     (Data atual - Data válida ano anterior) = 42
    #     último algarismo do ano atual = 9
    #     String atual 42+9 = 429
    #     Completa zero esquerda para formar 4 digitos = "0429"
    def to_juliano
      ultima_data = Date.parse("#{self.year - 1}-12-31")
      ultimo_digito_ano = self.to_s[3..3]
      dias = (self - ultima_data)
      (dias.to_i.to_s + ultimo_digito_ano).zeros_esquerda(:tamanho => 4)
    end
  end
end

[ String, Numeric ].each do |klass|
  klass.class_eval { include Brcobranca::Formatacao }
end

[ String, Numeric ].each do |klass|
  klass.class_eval { include Brcobranca::Validacao }
end

[ String, Numeric ].each do |klass|
  klass.class_eval { include Brcobranca::Calculo }
end

[ Float ].each do |klass|
  klass.class_eval { include Brcobranca::Limpeza }
end

[ Date ].each do |klass|
  klass.class_eval { include Brcobranca::CalculoData }
end