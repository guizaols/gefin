class ArquivoRemessa < ActiveRecord::Base
  #RELACIONAMENTOS
  belongs_to :unidade
  belongs_to :contas_corrente
  has_many :parcelas
  belongs_to :convenio

  attr_accessor :parcelas_ids, :file, :result_parcelas, :result_parcelas_datas, :hash_file
  data_br_field  :data_geracao, :data_leitura_banco, :created_at, :updated_at
  validates_presence_of :nome, :unidade, :convenio, :numero_de_registros, :message => 'deve ser preenchido.'

  OCORRENCIA_PARA_RETORNO_REMESSA = {
    '00' => 'Crédito ou Débito Efetivado',
    '01' => 'Insuficiência de Fundos - Débito Não Efetuado',
    '02' => 'Crédito ou Débito Cancelado pelo Pagador/Credor',
    '03' => 'Débito Autorizado pela Agência - Efetuado',
    'AA' => 'Controle Inválido',
    'AB' => 'Tipo de Operação Inválido',
    'AC' => 'Tipo de Serviço Inválido',
    'AD' => 'Forma de Lançamento Inválida',
    'AE' => 'Tipo/Número de Inscrição Inválido',
    'AF' => 'Código de Convênio Inválido',
    'AG' => 'Agência/Conta Corrente/DV Inválido',
    'AH' => 'Nº Seqüencial do Registro no Lote Inválido',
    'AI' => 'Código de Segmento de Detalhe Inválido',
    'AJ' => 'Tipo de Movimento Inválido',
    'AK' => 'Código da Câmara de Compensação do Banco Favorecido/Depositário Inválido',
    'AL' => 'Código do Banco Favorecido ou Depositário Inválido',
    'AM' => 'Agência Mantenedora da Conta Corrente do Favorecido Inválida',
    'AN' => 'Conta Corrente/DV do Favorecido Inválido',
    'AO' => 'Nome do Favorecido Não Informado',
    'AP' => 'Data Lançamento Inválido',
    'AQ' => 'Tipo/Quantidade da Moeda Inválido',
    'AR' => 'Valor do Lançamento Inválido',
    'AS' => 'Aviso ao Favorecido - Identificação Inválida',
    'AT' => 'Tipo/Número de Inscrição do Favorecido Inválido',
    'AU' => 'Logradouro do Favorecido Não Informado',
    'AV' => 'Nº do Local do Favorecido Não Informado',
    'AW' => 'Cidade do Favorecido Não Informada',
    'AX' => 'CEP/Complemento do Favorecido Inválido',
    'AY' => 'Sigla do Estado do Favorecido Inválida',
    'AZ' => 'Código/Nome do Banco Depositário Inválido',
    'BA' => 'Código/Nome da Agência Depositária Não Informado',
    'BB' => 'Seu Número Inválido',
    'BC' => 'Nosso Número Inválido',
    'BD' => 'Inclusão Efetuada com Sucesso',
    'BE' => 'Alteração Efetuada com Sucesso',
    'BF' => 'Exclusão Efetuada com Sucesso',
    'BG' => 'Agência/Conta Impedida Legalmente',
    'BH' => 'Empresa não pagou salário',
    'BI' => 'Falecimento do mutuário',
    'BJ' => 'Empresa não enviou remessa do mutuário',
    'BK' => 'Empresa não enviou remessa no vencimento',
    'BL' => 'Valor da parcela inválida',
    'BM' => 'Identificação do contrato inválida',
    'BN' => 'Operação de Consignação Incluída com Sucesso',
    'BO' => 'Operação de Consignação Alterada com Sucesso',
    'BP' => 'Operação de Consignação Excluída com Sucesso',
    'BQ' => 'Operação de Consignação Liquidada com Sucesso',
    'CA' => 'Código de Barras - Código do Banco Inválido',
    'CB' => 'Código de Barras - Código da Moeda Inválido',
    'CC' => 'Código de Barras - Dígito Verificador Geral Inválido',
    'CD' => 'Código de Barras - Valor do Título Inválido',
    'CE' => 'Código de Barras - Campo Livre Inválido',
    'CF' => 'Valor do Documento Inválido',
    'CG' => 'Valor do Abatimento Inválido',
    'CH' => 'Valor do Desconto Inválido',
    'CI' => 'Valor de Mora Inválido',
    'CJ' => 'Valor da Multa Inválido',
    'CK' => 'Valor do IR Inválido',
    'CL' => 'Valor do ISS Inválido',
    'CM' => 'Valor do IOF Inválido',
    'CN' => 'Valor de Outras Deduções Inválido',
    'CO' => 'Valor de Outros Acréscimos Inválido',
    'CP' => 'Valor do INSS Inválido',
    'HA' => 'Lote Não Aceito',
    'HB' => 'Inscrição da Empresa Inválida para o Contrato',
    'HC' => 'Convênio com a Empresa Inexistente/Inválido para o Contrato',
    'HD' => 'Agência/Conta Corrente da Empresa Inexistente/Inválido para o Contrato',
    'HE' => 'Tipo de Serviço Inválido para o Contrato',
    'HF' => 'Conta Corrente da Empresa com Saldo Insuficiente',
    'HG' => 'Lote de Serviço Fora de Seqüência',
    'HH' => 'Lote de Serviço Inválido',
    'HI' => 'Arquivo não aceito',
    'HJ' => 'Tipo de Registro Inválido',
    'HK' => 'Código Remessa / Retorno Inválido',
    'HL' => 'Versão de layout inválida',
    'HM' => 'Mutuário não identificado',
    'HN' => 'Tipo do beneficio não permite empréstimo',
    'HO' => 'Beneficio cessado/suspenso',
    'HP' => 'Beneficio possui representante legal',
    'HQ' => 'Beneficio é do tipo PA (Pensão alimentícia)',
    'HR' => 'Quantidade de contratos permitida excedida',
    'HS' => 'Beneficio não pertence ao Banco informado',
    'HT' => 'Início do desconto informado já ultrapassado',
    'HU' => 'Número da parcela inválida',
    'HV' => 'Quantidade de parcela inválida',
    'HW' => 'Margem consignável excedida para o mutuário dentro do prazo do contrato',
    'HX' => 'Empréstimo já cadastrado',
    'HY' => 'Empréstimo inexistente',
    'HZ' => 'Empréstimo já encerrado',
    'H1' => ' Arquivo sem trailer',
    'H2' => 'Mutuário sem crédito na competência',
    'H3' => 'Não descontado – outros motivos',
    'H4' => 'Retorno de Crédito não pago',
    'H5' => 'Cancelamento de empréstimo retroativo',
    'H6' => 'Outros Motivos de Glosa',
    'H7' => 'Margem consignável excedida para o mutuário acima do prazo do contrato',
    'H8' => 'Mutuário desligado do empregador',
    'H9' => 'Mutuário afastado por licença',
    'IA' => 'Primeiro nome do mutuário diferente do primeiro nome do movimento do censo ou diferente da base de Titular do Benefício',
    'TA' => 'Lote Não Aceito - Totais do Lote com Diferença',
    'YA' => 'Título Não Encontrado',
    'YB' => 'Identificador Registro Opcional Inválido',
    'YC' => 'Código Padrão Inválido',
    'YD' => 'Código de Ocorrência Inválido',
    'YE' => 'Complemento de Ocorrência Inválido',
    'YF' => 'Alegação já Informada',
    'ZA' => 'Agência / Conta do Favorecido Substituída',
    'ZB' => 'Divergência entre o primeiro e último nome do beneficiário versus primeiro e último nome na Receita Federal',
    'ZC' => 'Confirmação de Antecipação de Valor'
  }


  HUMANIZED_ATTRIBUTES = {
    :nome => 'O campo nome',
    :nome_arquivo => 'O campo nome do arquivo',
    :status => 'O campo status',
    :unidade => 'O campo unidade',
    :contas_corrente => 'O campo conta corrente',
    :numero_de_registros => 'O campo numero de registros',
    :convenio => 'O campo campo conta corrente'
  }

  HUMANAZED_CLASSES = {
    :ContasCorrente => "Conta Corrente",
    :Unidade => "Unidade",
    :Localidade => "Localidade",
    :Parcela => "Parcela",
    :Agencia => "Agência",
    :Banco => "Banco",
    :Pessoa => "Pessoa"
  }

  BANCO = {
    "banco_do_brasil" => 001,
    "itau" => 002,
    "bradesco" => 003,
    "real" => 004
  }

  PARCELA_FIELDS_VALIDS = [
    "valor","data_vencimento",
    ["conta",[
        ["pessoa", [
            "nome","conta","endereco","numero","bairro","cep",
            ["localidade", [
                "nome","uf"
              ]],
            ["agencia", [
                "numero","digito_verificador"
              ]]
          ]]
      ]],

  ]
  
  CONTAS_CORRENTE_FIELDS_VALIDS = [
    ["agencia",[
        ["banco", [
            "descricao"
          ]],
        "numero","digito_verificador"
      ]],
    "numero_conta","digito_verificador",
  ]

  UNIDADE_FIELDS_VALIDS = [
    "cnpj","nome","endereco","cep",
    ["localidade",[
        "nome", "uf"
      ]]
  ]

  def before_validation
    if self.parcelas_ids.blank?
      self.parcelas_ids = self.array_parcelas_ids
    end
    self.numero_de_registros = self.parcelas_ids.length
    self.nome_arquivo = self.nome
  end

  def validate
    errors.add :base, 'Selecione ao menos uma parcela para gera um arquivo' if self.parcelas_ids.blank?
#    errors.add :base, 'A conta corrente selecionada não possui um convênio vinculado a si' if self.contas_corrente.convenios.blank?
    unless self.parcelas_ids.blank?
      self.parcelas_ids.each do |parcela_id|
        parcela = Parcela.find(parcela_id)
        errors.add :base,  "A Parcela com ID: #{parcela.id} já pertence a um arquivo de remessa" unless parcela.pode_add_ao_arquivo?(self.id)
        #errors.add :base, "A Parcela de ID: #{parcela.id} já está vencida" unless parcela.vencida?
      end
    end
  end

  def before_update
    self.parcelas.each do |parcela|
      unless self.parcelas_ids.collect{|id| id.to_i}.include?(parcela.id)
        parcela.remove_arquivo_remessa
      else
        self.parcelas_ids -= [parcela.id.to_s]
      end
    end
  end

  def after_save
    self.parcelas_ids.each do |parcela_id|
      parcela = Parcela.find(parcela_id)
      parcela.add_arquivo_remessa(self.id)
    end
  end

  def before_destroy
    self.parcelas.each do |parcela|
      parcela.remove_arquivo_remessa
    end
  end

  def array_parcelas_ids
    if self.new_record?
      self.parcelas_ids.blank? ? [] : self.parcelas_ids.collect { |id| id.to_i  }
    else
      self.parcelas.collect { |p| p.id }
    end
  end

  def pode_gerar?
    erros = valida_arquivo
    if erros.first
      self.data_geracao = Date.today
      self.parcelas_ids = self.array_parcelas_ids
      self.parcelas_ids
      self.save
      [true]
    else
      [false, erros.last]
    end
  end

  def gerar
    self.file = ""
    gerar_header_file({:banco => 'banco_do_brasil'})
    gerar_header_lote_pagamento({:banco => 'banco_do_brasil'}, 1)
    valor = 0
    self.parcelas.each_with_index do |parcela, index|
      gerar_pagamento_seguimento_a({:banco => 'banco_do_brasil', :banco_favorecido => 'banco_do_brasil'}, 1, index, parcela)
      gerar_pagamento_seguimento_b({:banco => 'banco_do_brasil'}, 1, index, parcela)
      #gerar_pagamento_seguimento_c({:banco => 'banco_do_brasil'}, index)
      valor += parcela.valor
    end
    gerar_trailer_lote_pagamento({:banco => 'banco_do_brasil'}, 1, self.parcelas.length, valor)
    gerar_trailer_file('banco_do_brasil', 12, 1, self.parcelas.length)
    self.file
  end

  def trata_alfa(value, length, expression = [])
    value = value.to_s
    expression.each do |exp|
      value = value.gsub(exp, "")
    end
    value = value.first(length)
    value = value.ljust(length)
    value
  end

  def trata_num(value, length, expression = [])
    value = value.to_s
    expression.each do |exp|
      value = value.gsub(exp, "")
    end
    value = value.first(length)
    value = value.rjust(length, "0")
    value
  end

  def trata_data(data)
    dia = data[0..1]
    mes = data[2..3]
    ano = data[4..7]
    "#{dia}/#{mes}/#{ano}"
  end

  def gerar_header_file(attributes)
    self.file << BANCO[attributes[:banco]].to_s.rjust(3,"0")
    self.file << "0000"
    self.file << "0"
    self.file << "".ljust(9)
    self.file << "2"
    self.file << trata_num(self.unidade.cnpj, 14, ['/','-','.'])
    self.file << self.convenio.numero.to_s.ljust(20)
    #self.file << self.contas_corrente.convenios.first.numero.to_s.ljust(20)
    self.file << trata_num(self.convenio.contas_corrente.agencia.numero, 5)
    #self.file << trata_num(self.contas_corrente.agencia.numero, 5)
    self.file << trata_alfa(self.convenio.contas_corrente.agencia.digito_verificador, 1)
    #self.file << trata_alfa(self.contas_corrente.agencia.digito_verificador, 1)
    self.file << trata_num(self.convenio.contas_corrente.numero_conta, 12)
    #self.file << trata_num(self.contas_corrente.numero_conta, 12)
    self.file << trata_alfa(self.convenio.contas_corrente.digito_verificador, 1)
    #self.file << trata_alfa(self.contas_corrente.digito_verificador, 1)
    self.file << attributes[:agencia_conta_dv].to_s.ljust(1)
    self.file << trata_alfa(self.unidade.nome, 30)
    self.file << trata_alfa(self.convenio.contas_corrente.agencia.banco.descricao, 30) #self.file << trata_alfa(self.contas_corrente.agencia.banco.descricao, 30)
    self.file << "".ljust(10)
    self.file << "1"
    self.file << DateTime.now.strftime("%d%m%Y")
    self.file << DateTime.now.strftime("%H%M%S")
    self.file << trata_num(self.id, 6)
    self.file << "084"
    self.file << attributes[:densidade].to_s.rjust(5,"0")
    self.file << "".ljust(20)
    self.file << trata_alfa(self.id, 20)
    self.file << "".ljust(29)
    self.file << "\n"
  end

  def gerar_trailer_file(banco, conciliacao, lotes, registros)
    self.file << BANCO[banco].to_s.rjust(3,"0")
    self.file << "9999"
    self.file << "9"
    self.file << "".ljust(9)
    self.file << lotes.to_s.rjust(6,"0")
    self.file << registros.to_s.rjust(6,"0")
    self.file << conciliacao.to_s.rjust(6,"0")
    self.file << "".ljust(205)
    self.file << "\n"
  end

  def gerar_header_lote_pagamento(attributes, lote)
    self.file << BANCO[attributes[:banco]].to_s.rjust(3,"0")
    self.file << trata_num(lote, 4)
    self.file << "1"
    self.file << "C"
    self.file << attributes[:tipo_de_servico].to_s.rjust(2,"0")
    self.file << attributes[:forma_de_lancamento].to_s.rjust(2,"0")
    self.file << "043"
    self.file << " "
    self.file << "2"
    self.file << trata_num(self.unidade.cnpj, 14, ['/','-','.'])
    self.file << self.convenio.numero.to_s.ljust(20)
    #self.file << self.contas_corrente.convenios.first.numero.to_s.ljust(20)
    self.file << trata_num(self.convenio.contas_corrente.agencia.numero, 5)
    #self.file << trata_num(self.contas_corrente.agencia.numero, 5)
    self.file << trata_alfa(self.convenio.contas_corrente.agencia.digito_verificador, 1)
    #self.file << trata_alfa(self.contas_corrente.agencia.digito_verificador, 1)
    self.file << trata_num(self.convenio.contas_corrente.numero_conta, 12)
    #self.file << trata_num(self.contas_corrente.numero_conta, 12)
    self.file << trata_alfa(self.convenio.contas_corrente.digito_verificador, 1)
    #self.file << trata_alfa(self.contas_corrente.digito_verificador, 1)
    self.file << attributes[:agencia_conta_dv].to_s.ljust(1)
    self.file << trata_alfa(self.unidade.nome, 30)
    self.file << attributes[:mensagem].to_s.ljust(40)
    self.file << trata_alfa(self.unidade.endereco.split(",").first, 30)
    self.file << trata_num(self.unidade.endereco.split(",").last, 5, [".", " "])
    self.file << trata_alfa(self.unidade.complemento, 15)
    self.file << trata_alfa(self.unidade.localidade.nome, 20)
    self.file << trata_num(self.unidade.cep, 5)
    self.file << self.unidade.cep.to_s.last(3).ljust(3)
    self.file << trata_alfa(self.unidade.localidade.uf, 2)
    self.file << "".ljust(8)
    self.file << attributes[:ocorrencia].to_s.ljust(10)
    self.file << "\n"
  end

  def gerar_trailer_lote_pagamento(attributes, lote, registros, valor)
    self.file << BANCO[attributes[:banco]].to_s.rjust(3,"0")
    self.file << trata_num(lote, 4)
    self.file << "5"
    self.file << "".ljust(9)
    self.file << trata_num(registros, 6)
    self.file << trata_num(valor, 18)
    self.file << attributes[:quantidade_moeda].to_s.rjust(18,"0")
    self.file << "".rjust(6,"0")
    self.file << "".ljust(165)
    self.file << attributes[:ocorrencia].to_s.ljust(10)
    self.file << "\n"
  end

  def gerar_pagamento_seguimento_a(attributes, lote, sequencia, parcela)
    pessoa = parcela.conta.pessoa
    self.file << BANCO[attributes[:banco]].to_s.rjust(3,"0")
    self.file << trata_num(lote, 4)
    self.file << "3"
    self.file << trata_num(sequencia, 5)
    self.file << "A"
    self.file << attributes[:tipo_movimento].to_s.rjust(1,"0")
    self.file << attributes[:codigo_movimento].to_s.rjust(2,"0")
    self.file << attributes[:codigo_camara_centralizadora].to_s.rjust(3,"0")
    self.file << BANCO[attributes[:banco_favorecido]].to_s.rjust(3,"0")
    self.file << trata_num(pessoa.agencia.numero, 5)
    self.file << trata_alfa(pessoa.agencia.digito_verificador, 1)
    self.file << trata_num(pessoa.conta, 12)
    self.file << attributes[:conta_dv].to_s.ljust(1)
    self.file << attributes[:agencia_conta_dv].to_s.ljust(1)
    self.file << trata_alfa(pessoa.nome, 30)
    self.file << trata_num(parcela.id, 20)
    self.file << DateTime.now.strftime("%d%m%Y")
    self.file << "BRL"
    self.file << attributes[:quantidade_moeda].to_s.rjust(15, "0")
    self.file << trata_num(parcela.valor, 15)
    self.file << "".rjust(20,"0")
    self.file << "".rjust(8,"0")
    self.file << "".rjust(15, "0")
    self.file << attributes[:mensagem].to_s.ljust(40)
    self.file << attributes[:tipo_servico].to_s.ljust(2)
    self.file << attributes[:codigo_finalidade].to_s.ljust(5)
    self.file << attributes[:codigo_finalidade_complementar].to_s.ljust(2)
    self.file << "".ljust(3)
    self.file << attributes[:aviso].to_s.rjust(1, "0")
    self.file << attributes[:ocorencia].to_s.ljust(10)
    self.file << "\n"
  end

  def gerar_pagamento_seguimento_b(attributes, lote, sequencia, parcela)
    pessoa = parcela.conta.pessoa
    self.file << BANCO[attributes[:banco]].to_s.rjust(3,"0")
    self.file << trata_num(lote, 4)
    self.file << "3"
    self.file << trata_num(sequencia, 5)
    self.file << "B"
    self.file << "".ljust(3)
    self.file << attributes[:tipo_inscricao].to_s.rjust(1,"0")
    self.file << attributes[:numero_inscricao].to_s.rjust(14,"0")
    self.file << trata_alfa(pessoa.endereco, 30)
    self.file << trata_num(pessoa.numero, 5)
    self.file << trata_alfa(pessoa.complemento, 15)
    self.file << trata_alfa(pessoa.bairro, 15)
    self.file << trata_alfa((pessoa.localidade.nome rescue ''), 20)
    self.file << trata_num(pessoa.cep, 5)
    self.file << pessoa.cep.to_s.last(3).ljust(3)
    self.file << trata_alfa((pessoa.localidade.uf rescue ''), 2)
    self.file << trata_num(parcela.data_vencimento, 8, ["/"])
    self.file << trata_num(parcela.valor, 15)
    self.file << attributes[:abatimento].to_s.rjust(15,"0")
    self.file << attributes[:desconto].to_s.rjust(15,"0")
    self.file << attributes[:mora].to_s.rjust(15,"0")
    self.file << attributes[:multa].to_s.rjust(15,"0")
    self.file << trata_num(pessoa.id, 15)
    self.file << attributes[:aviso].to_s.rjust(1,"0")
    self.file << "".ljust(14)
    self.file << "\n"
  end

  def gerar_pagamento_seguimento_c(attributes, lote, sequencia)
    self.file << BANCO[attributes[:banco]].to_s.rjust(3,"0")
    self.file << trata_num(lote, 4)
    self.file << "3"
    self.file << trata_num(sequencia, 5)
    self.file << "C"
    self.file << "".ljust(3)
    self.file << attributes[:valor_ir].to_s.rjust(15,"0")
    self.file << attributes[:valor_iss].to_s.rjust(15,"0")
    self.file << attributes[:valor_iof].to_s.rjust(15,"0")
    self.file << attributes[:outras_deducoes].to_s.rjust(15,"0")
    self.file << attributes[:outros_acrecimos].to_s.rjust(15,"0")
    self.file << attributes[:agencia].to_s.rjust(5,"0")
    self.file << attributes[:agencia_dv].to_s.ljust(1)
    self.file << attributes[:conta].to_s.rjust(12,"0")
    self.file << attributes[:conta_dv].to_s.ljust(1)
    self.file << attributes[:agencia_conta_dv].to_s.ljust(1)
    self.file << attributes[:valor_inss].to_s.rjust(15,"0")
    self.file << "".ljust(113)
    self.file << "\n"
  end

  def self.pesquisa(params)
    ArquivoRemessa.all :conditions => "(nome LIKE '#{params.formatar_para_like}') OR (nome_arquivo LIKE '#{params.formatar_para_like}')", :limit => 10
  end


  def self.objects_valid?(object, fields)
    erros = []
    fields.each do |field|
      unless field.is_a?(Array)
        if object.send(field).blank?
          erros << [object.class.to_s, field]
        end
      else
        if object.send(field.first).blank?
          erros << [object.class.to_s, field.first]
        else
          erros += objects_valid?(object.send(field.first), field.last)
        end
      end
    end
    return erros
  end

  def self.erros_to_hash(erros)
    erros_hash = {}
    erros.each do |erro|
      if erros_hash[erro.first].blank?
        erros_hash[erro.first] = [erro.last.to_sym]
      else
        erros_hash[erro.first] << erro.last.to_sym
      end
    end
    erros_hash
  end

  def self.monta_mensagem(erros)
    unless erros.is_a?(Hash)
      erros = erros_to_hash(erros)
    end
    mensagem = []
    erros.each do |classe, campos|
      mensagem << "#{HUMANAZED_CLASSES[classe.to_sym]}: "
      campos.each do |campo|
        mensagem << "* #{classe.constantize::HUMANIZED_ATTRIBUTES[campo]} deve ser preenchido"
      end
    end
    return mensagem
  end

  def valida_arquivo
    full_messages = []
    erros = []
    unless self.valid?
      full_messages << "Arquivo de Remessa:"
      full_messages << self.errors.full_messages.collect{|item| "* #{item}"}
    end
    erros += ArquivoRemessa.objects_valid?(self.unidade, UNIDADE_FIELDS_VALIDS) unless self.unidade.blank?
    erros += ArquivoRemessa.objects_valid?(self.contas_corrente, CONTAS_CORRENTE_FIELDS_VALIDS) unless self.contas_corrente.blank?
    unless erros.blank?
      full_messages << ArquivoRemessa.monta_mensagem(erros)
    end
    if full_messages.blank?
      [true]
    else
      [false, full_messages]
    end
  end

  def self.monta_resultado(result)
    array = []
    0.step(9, 2) do |n|
      array << result[n..n+1]
    end
    array
  end

  def self.monta_data(data)
    "#{data[0..1]}/#{data[2..3]}/#{data[4..7]}"
  end

  def mostra_resultado(id)
    array = []
    self.result_parcelas[id].each do |value|
      unless value == "  "
        array << OCORRENCIA_PARA_RETORNO_REMESSA[value]
      end
    end
    array.join("<br />")
  end

  def pode_baixar_parcela?(id)
    unless self.result_parcelas[id].blank?
      result = self.result_parcelas[id]
      result.include?("00")? true : false
    else
      false
    end
  end
  
  def pode_baixar?
    File.exist?("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{self.id}.txt") && !self.baixado?
  end

  def baixado?
    !self.data_leitura_banco.blank?
  end


  def self.read (txt_file)
    ax_hash_file = self.file_to_hash(txt_file)
    objetc_file = self.find(self.file_id(ax_hash_file))
    objetc_file.hash_file = ax_hash_file
    objetc_file.result_parcelas = {}
    Dir.mkdir(RAILS_ROOT + '/tmp/arquivo_remessa/') unless File.exist?("#{RAILS_ROOT}/tmp/arquivo_remessa")

    if File.exist?("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{objetc_file.id}.txt")
      File.delete("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{objetc_file.id}.txt")
    end
    txt_file.rewind
    File.open("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{objetc_file.id}.txt", "wb") { |f| f.write(txt_file.read) }
    objetc_file.hash_file[:registros].each  do |hash_parcela|
      objetc_file.result_parcelas[hash_parcela.last["A"][73..92].to_i] = self.monta_resultado(hash_parcela.last['A'][230..239])
    end
    return objetc_file
  end

  def baixar(ano, current_usuario, params)
    self.file = File.open("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{self.id}.txt")
    self.hash_file = ArquivoRemessa.file_to_hash(self.file)
    self.result_parcelas = {}
    self.result_parcelas_datas = {}
    self.hash_file[:registros].each  do |hash_parcela|
      self.result_parcelas[hash_parcela.last["A"][73..92].to_i] = ArquivoRemessa.monta_resultado(hash_parcela.last['A'][230..239])
      self.result_parcelas_datas[hash_parcela.last["A"][73..92].to_i] = ArquivoRemessa.monta_data(hash_parcela.last['A'][154..161])
    end
    erros = []
    params[:parcelas_ids].each do|parcela_id|
      unless self.pode_baixar_parcela?(parcela_id.to_i)
        parcela = Parcela.find(parcela_id)
        erros << "A parcela N° #{parcela.numero} do contrato #{parcela.conta.numero_de_controle} não foi baixada pelo banco"
      end
    end
    return [false, erros] unless erros.blank?
    erros = []
    baixar_barcela = false
    2.times do
      params[:parcelas_ids].each do|parcela_id|
        params_parcelas = {
          "valor_da_multa_em_reais" => "0,00",
          "numero_do_comprovante" => "0000000",
          "forma_de_pagamento" => "2",
          "conta_corrente_id" => self.contas_corrente_id,
          "historico" => "Pago atravás de arquivo de remessa",
          "data_do_pagamento" => self.result_parcelas_datas[parcela_id.to_i],
          "outros_acrescimos_em_reais" => "0,00",
          "valor_do_desconto_em_reais" => "0,00",
          "nome_conta_corrente" => self.contas_corrente.descricao,
          "valor_dos_juros_em_reais" => "0,00",
          "data_da_baixa" => DateTime.now.strftime("%d/%m/%Y")
        }
        parcela = Parcela.find(parcela_id)
        if baixar_barcela
          parcela.baixar_parcela(ano, current_usuario, params_parcelas)
        else
          unless parcela.baixar_parcela_valid?(ano, params_parcelas)
            erros << "A parcela n° #{parcela.numero} do contrato #{parcela.conta.numero_de_controle}, teve os seguintes erros: \n #{parcela.errors.full_messages.collect{|item| "* #{item}"}.join("\n")} \n"
          end
        end
      end
      if erros.blank?
        baixar_barcela = true
      else
        return [false, erros] 
      end
    end
    self.data_leitura_banco = DateTime.now.strftime("%d/%m/%Y")
    self.save
    File.delete("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{self.id}.txt")
    return [true]
  end

  def self.file_id(hash_file)
    hash_file[:file_header][191..210].to_i
  end

  def self.file_to_hash(file)
    hash = {}
    hash[:registros] = {}
    file.each_line do |linha|
      case linha[7..7]
      when '0'; hash[:file_header] = linha.gsub("\n","")
      when '1'; hash[:lote_header] = linha.gsub("\n","")
      when '3'
        if hash[:registros][linha[8..12].to_i].blank?
          hash[:registros][linha[8..12].to_i]= { linha[13..13] => linha.gsub("\n","")}
        else
          hash[:registros][linha[8..12].to_i][linha[13..13]] = linha.gsub("\n","")
        end
      when '5'; hash[:lote_trailer] = linha.gsub("\n","")
      when '9'; hash[:file_trailer] = linha.gsub("\n","")
      end
    end
    hash
  end

  def layout_valid?
    begin
      exceptions = []
      exceptions << file_header_valid?.last unless file_header_valid?.first
      exceptions << file_trailer_valid?.last unless file_trailer_valid?.first
      raise exceptions.join("\n") unless exceptions.blank?
      [true]
    end
  rescue Exception => e
    File.delete("#{RAILS_ROOT}/tmp/arquivo_remessa/file_#{self.id}.txt")
    [false, e.message]
  end
  
  def file_header_valid?
    exceptions = []
    begin
      hash = self.hash_file
      exceptions << "Código de Remessa/Retorno incorreto!" if hash[:file_header][142..142] != "2"
      exceptions << "Lote Cabeçario inicial Incorreto!" if hash[:file_header][3..6] != "0000"
      exceptions << "Tipo de Cabeçario Incoreto!" if hash[:file_header][7..7] != "0"
      raise exceptions.join("\n") unless exceptions.blank?
      [true]
    end
  rescue Exception => e
    [false, e.message]
  end
  
  def file_trailer_valid?
    exceptions = []
    begin
      hash = self.hash_file
      exceptions << "Tipo do Rodapé Incoreto!" if hash[:file_trailer][7..7] != "9"
      exceptions << "Lote do Rodapé Incorreto!" if hash[:file_trailer][3..6] != "9999"
      exceptions << "Total de Registros Incorretos!" if self.parcelas.length != hash[:registros].length
      raise exceptions.join("\n") unless exceptions.blank?
      [true]
    end
  rescue Exception => e
    [false, e.message]
  end
end
