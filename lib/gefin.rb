class Gefin

  #Options = Hash
  # vencimento => Data de Vencimento (Date)
  # data_base => Data do Pagamento (Date)
  # valor => Valor original da parcela (Fixnum)
  # juros => Taxa de juros (%) mensal (Float)
  # multa => Valor da multa (%) (Float)
  #Retorno: Array
  # Posição 0 => Valor dos juros (Int)
  # Posição 1 => Valor da multa (Int)
  # Posição 2 => Valor corrigido da parcela
  def self.calcular_juros_e_multas(options)
    valor_corrigido = options[:valor]
    valor_original = valor_corrigido
    data_base = options[:data_base].to_date
    vencimento = options[:vencimento].to_date
    dias_em_atraso = data_base - vencimento

    if dias_em_atraso > 0

      multas = (valor_corrigido * options[:multa] / 100.0).round
      valor_corrigido += multas

      meses_proporcionais_atrasados = 0.0

      mes_da_contagem_de_dias_em_atraso = 0
      dias_em_atraso_no_mes_atual = 0

      (vencimento .. data_base - 1).each do |dia|
        if dia.month != mes_da_contagem_de_dias_em_atraso

          if mes_da_contagem_de_dias_em_atraso != 0
            meses_proporcionais_atrasados += dias_em_atraso_no_mes_atual.to_f / Time.days_in_month(mes_da_contagem_de_dias_em_atraso, dia.year)
          end

          mes_da_contagem_de_dias_em_atraso = dia.month
          dias_em_atraso_no_mes_atual = 0
        end

        dias_em_atraso_no_mes_atual += 1

      end
      if mes_da_contagem_de_dias_em_atraso != 0
        meses_proporcionais_atrasados += dias_em_atraso_no_mes_atual.to_f / Time.days_in_month(mes_da_contagem_de_dias_em_atraso, data_base.year)
      end

      #juros = ((((1 + (options[:juros] / 100.0)) ** meses_proporcionais_atrasados) - 1) * valor_corrigido).round

      juros_dizima = (options[:juros] / 30).to_f.round(4)
      juros = ((valor_original * dias_em_atraso * juros_dizima).round / 100.0).round.to_i

      valor_corrigido += juros

      [juros, multas, valor_corrigido]
    else
      [0, 0, valor_corrigido]
    end
  end

  def self.monta_numeros_de_controle(prefixo)
    retorno = []
    maior_numero = 0
    retorno << Movimento.first(:conditions => ['numero_de_controle LIKE ?', prefixo + '%'], :order => 'numero_de_controle DESC')
    retorno << PagamentoDeConta.first(:conditions => ['numero_de_controle LIKE ?', prefixo + '%'], :order => 'numero_de_controle DESC')
    retorno << RecebimentoDeConta.first(:conditions => ['numero_de_controle LIKE ?', prefixo + '%'], :order => 'numero_de_controle DESC')
    unless retorno.compact.empty?
      maior_numero = retorno.compact.collect(&:numero_de_controle).max.match(%r{#{prefixo}(.*)})[1].to_i
    else
      maior_numero = 0
    end
    numero_controle = prefixo + (maior_numero + 1).to_s.rjust(4, '0')
    numero_controle
  end

  def self.importacao_cargos(line, cargos)
    dados = line.chomp.split("\t")
    cargos[dados[0]] = dados[2].gsub("\\N", "").strip
  end

  def self.importacao_historicos(line, entidade, historicos)
    dados = line.chomp.split("\t")

    hash = {
      :descricao => dados[1].gsub("\\N", "").strip,
      :entidade_id => entidade.id
    }

    historico = Historico.find_or_initialize_by_descricao_and_entidade_id hash

    if historico.save
      historicos[dados[0]] = historico.id
    else
      erro = "Não foi possível importar os dados do histórico #{dados[1].gsub("\\N", "").strip}!\n#{historico.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_localidades(line, localidades)
    dados = line.chomp.split("\t")

    hash = {
      :nome => dados[1].gsub("\\N", "").strip,
      :uf => dados[2].gsub("\\N", "").strip
    }

    localidade = Localidade.find_or_initialize_by_nome_and_uf hash
    if localidade.save
      localidades[dados[0]] = localidade.id
    else
      erro = "Não foi possível importar os dados da localidade #{dados[1].gsub("\\N", "").strip}!\n#{localidade.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_planos_de_conta(line, entidade, planos_de_conta)
    dados = line.chomp.split("\t")

    hash = {
      :ano => dados[0],
      :codigo_contabil => dados[2].gsub("\\N", "").strip,
      :nome => dados[3].gsub("\\N", "").strip,
      :nivel => dados[6],
      :ativo => dados[7],
      :tipo_da_conta => dados[8],
      :codigo_reduzido => dados[9].gsub("\\N", "").strip,
      :entidade_id => (entidade.id if entidade)
    }

    plano_de_conta = PlanoDeConta.find_or_initialize_by_ano_and_entidade_id_and_codigo_contabil hash
    if plano_de_conta.save
      planos_de_conta[dados[10]] = plano_de_conta.id
    else
      erro = "Não foi possível importar os dados do plano de conta #{dados[3].gsub("\\N", "").strip}!\n#{plano_de_conta.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_bancos(line, bancos)
    dados = line.chomp.split("\t")

    case dados[3]
    when "S"; atv = true
    when "N"; atv = false
    end

    hash = {
      :descricao => dados[1].gsub("\\N", "").strip,
      :ativo => atv,
      :codigo_do_zeus => dados[4].gsub("\\N", "").strip,
      :codigo_do_banco => (dados[6].gsub("\\N", "").strip if dados[6]),
      :digito_verificador => (dados[7].gsub("\\N", "").strip if dados[7])
    }

    banco = Banco.find_or_initialize_by_descricao_and_codigo_do_zeus_and_codigo_do_banco hash

    if banco.save
      bancos[dados[0]] = banco.id
    else
      erro = "Não foi possível importar os dados do banco #{dados[1].gsub("\\N", "").strip}!\n#{banco.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_agencias(line, agencias, bancos, entidade, localidades)
    dados = line.chomp.split("\t")

    case dados[13].gsub("\\N", "").strip
    when 'S'; atv = true
    when 'N'; atv = false
    end

    banco = Banco.find_by_id bancos[dados[0]]
    localidade = Localidade.find_by_id localidades[dados[5].gsub("\\N", "").strip]

    hash = {
      :nome => dados[2].gsub("\\N", "").strip,
      :endereco => dados[3].gsub("\\N", "").strip,
      :bairro => dados[4].gsub("\\N", "").strip,
      :cep => dados[6].gsub("\\N", "").strip,
      :telefone => dados[8].gsub("\\N", "").strip,
      :fax => dados[9].gsub("\\N", "").strip,
      :nome_contato => dados[10],
      :telefone_contato => dados[11].gsub("\\N", "").strip,
      :email => dados[18].gsub("\\N", "").strip,
      :email_contato => dados[19].gsub("\\N", "").strip,
      :digito_verificador => dados[20],
      :numero => dados[21],
      :ativo => atv,
      :banco => banco,
      :cidade => "",
      :complemento => "",
      :entidade_id => entidade.id,
      :localidade => localidade
    }

    agencia = Agencia.find_or_initialize_by_nome_and_entidade_id hash

    if agencia.save
      agencias[dados[1]] = agencia.id
    else
      erro = "Não foi possível importar os dados da agência #{dados[2].gsub("\\N", "").strip}!\n#{agencia.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_funcionarios(line, cargos, entidades, unidades, funcionarios)
    dados = line.chomp.split("\t")

    case dados[8].gsub("\\N", "").strip
    when "1"; atv = true
    when "0"; atv = false
    end

    entidade = Entidade.find_by_id entidades[dados[1]]

    hash = {
      :nome => dados[2].gsub("\\N", "").strip,
      :matricula => dados[3].gsub("\\N", "").strip,
      :email => [dados[6].gsub("\\N", "").strip],
      :telefone => [dados[7].gsub("\\N", "").strip],
      :cpf => dados[9].gsub(%r{(\s)(\-*)(\.*)(\/*)} , ""),
      :cargo => cargos[dados[4]],
      :endereco => ".",
      :entidade_id => entidade.id,
      :funcionario => true,
      :funcionario_ativo => atv,
      :tipo_pessoa => Pessoa::FISICA
    }

    funcionario = Pessoa.find_or_initialize_by_cpf_and_entidade_id hash

    if funcionario.save
      funcionarios[dados[0]] = funcionario.id
    else
      erro = "Não foi possível importar os dados do funcionário #{dados[2].gsub("\\N", "").strip}!\n#{funcionario.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_impostos(line, entidade, impostos, planos_de_conta)
    dados = line.chomp.split("\t")

    case dados[4].gsub("\\N", "").strip
    when "E"; tipo = Imposto::ESTADUAL
    when "F"; tipo = Imposto::FEDERAL
    when "M"; tipo = Imposto::MUNICIPAL
    end

    case dados[5].gsub("\\N", "").strip
    when "D"; classificacao = Imposto::INCIDE
    when "R"; classificacao = Imposto::RETEM
    end

    conta_debito = PlanoDeConta.find_by_id planos_de_conta[dados[6]]
    conta_credito = PlanoDeConta.find_by_id planos_de_conta[dados[7]]

    hash = {
      :descricao => dados[1].gsub("\\N", "").strip,
      :sigla => dados[2].gsub("\\N", "").strip,
      :aliquota => dados[3],
      :classificacao => classificacao,
      :conta_credito => conta_credito,
      :conta_debito => conta_debito,
      :tipo => tipo,
      :entidade_id => (entidade.id if entidade)
    }

    imposto = Imposto.find_or_initialize_by_descricao_and_classificacao_and_tipo_and_entidade_id hash
    imposto.entidade = entidade

    if imposto.save
      impostos[dados[0]] = imposto.id
    else
      erro = "Não foi possível importar os dados do imposto #{dados[1].gsub("\\N", "").strip}!\n#{imposto.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_usuarios(line, funcionarios, unidade, usuarios)
    dados = line.chomp.split("\t")

    funcionario = Pessoa.find_by_id funcionarios[dados[1].gsub("\\N", "").strip]

    case dados[3].gsub("\\N", "").strip
    when "0"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Master']
    when "1"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Gerente']
    when "2"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Operador Financeiro']
    when "3"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Operador CR']
    when "4"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Operador CP']
    when "5"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Consulta']
    when "6"; perfil = Perfil.find :first, :conditions => ['descricao = ?', 'Contador']
    end

    password = ""; dados[2].each_byte {|b| (password << (155-b).chr) }

    hash = {
      :login => dados[0].gsub("\\N", "").strip,
      :perfil_id => (perfil.id if perfil),
      :funcionario_id => (funcionario.id if funcionario),
      :password => password,
      :password_confirmation => password
    }

    usuario = Usuario.new hash
    usuario.unidade = unidade

    if usuario.save
      usuarios[dados[0]] = usuario.id
    else
      erro = "Não foi possível importar os dados do usuário #{dados[0].gsub("\\N", "").strip}!\n#{usuario.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_fornecedores(line, agencias, entidade, fornecedores, localidades)
    dados = line.chomp.split("\t")
    endereco = nil

    agencia = Agencia.find_by_id(agencias[dados[22].gsub("\\N", "").strip])

    case dados[21]
    when "F"
      localidade = Localidade.find_by_id(localidades[dados[7].gsub("\\N", "").strip])

      endereco = dados[4].gsub("\\N", "").strip
      endereco = "." if endereco.empty?

      hash = {
        :cpf => dados[1].gsub(%r{(\s)(\-*)(\.*)(\/*)}, ""),
        :nome => dados[2].gsub("\\N", "").strip,
        :email => [dados[3].gsub("\\N", "").strip],
        :endereco => endereco,
        :bairro => dados[5].gsub("\\N", "").strip,
        :complemento => dados[6].gsub("\\N", "").strip,
        :cep => dados[8].gsub("\\N", "").strip,
        :telefone => [dados[9].gsub("\\N", "").strip, dados[10].gsub("\\N", "").strip],
        :tipo_da_conta => dados[23].gsub("\\N", "").strip,
        :conta => dados[24],
        :agencia => agencia,
        :banco => (agencia.banco if agencia),
        :entidade_id => entidade.id,
        :fornecedor => true,
        :localidade => localidade,
        :tipo_pessoa => Pessoa::FISICA
      }
      fornecedor = Pessoa.find_or_initialize_by_cpf_and_entidade_id hash
      if fornecedor.save
        fornecedores[dados[0]] = fornecedor.id
      else
        erro = "Não foi possível importar os dados do fornecedor (pessoa física) #{dados[2].gsub("\\N", "").strip}!\n#{fornecedor.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
    when "J"
      localidade = Localidade.find_by_id(localidades[dados[14].gsub("\\N", "").strip])

      endereco = dados[11].gsub("\\N", "").strip
      endereco = "." if endereco.empty?

      hash = {
        :cnpj => dados[1].gsub(%r{(\s)(\-*)(\.*)(\/*)}, ""),
        :razao_social => dados[2].gsub("\\N", "").strip,
        :endereco => endereco,
        :bairro => dados[12].gsub("\\N", "").strip,
        :complemento => dados[13].gsub("\\N", "").strip,
        :localidade => localidade,
        :cep => dados[15].gsub("\\N", "").strip,
        :telefone => [dados[16].gsub("\\N", "").strip, dados[19].gsub("\\N", "").strip],
        :email => [dados[17].gsub("\\N", "").strip, dados[20].gsub("\\N", "").strip],
        :contato => dados[18].gsub("\\N", "").strip,
        :tipo_da_conta => dados[23].gsub("\\N", "").strip,
        :conta => dados[24],
        :nome => dados[27].gsub("\\N", ""),
        :agencia => agencia,
        :banco => (agencia.banco if agencia),
        :entidade_id => entidade.id,
        :fornecedor => true,
        :tipo_pessoa => Pessoa::JURIDICA
      }
      fornecedor = Pessoa.find_or_initialize_by_cnpj_and_entidade_id hash
      if fornecedor.save
        fornecedores[dados[0]] = fornecedor.id
      else
        erro = "Não foi possível importar os dados do fornecedor (pessoa jurídica) #{dados[2].gsub("\\N", "").strip}!\n#{fornecedor.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
    end
  end

  def self.importacao_entidades(line, entidades)
    dados = line.chomp.split("\t")
    hash = {
      :nome => dados[1].gsub("\\N", "").strip,
      :sigla => dados[2].gsub("\\N", "").strip,
      :codigo_zeus => dados[3]
    }

    entidade = Entidade.find_or_initialize_by_codigo_zeus hash

    if entidade.save
      entidades[dados[0]] = entidade.id
    else
      erro = "Não foi possível importar os dados da entidade #{dados[1].gsub("\\N", "").strip}!\n#{entidade.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_unidades(line, entidades, localidades, unidades)
    dados = line.chomp.split("\t")

    case dados[21].gsub("\\N", "").strip
    when 't'; ativa = true
    when 'f'; ativa = false
    end
    
    entidade = Entidade.find_by_id entidades[dados[1]]
    localidade = Localidade.find_by_id localidades[dados[6].gsub("\\N", "").strip]

    hash = {
      :ativa => ativa,
      :bairro => dados[13].gsub("\\N", "").strip,
      :cep => dados[14].gsub("\\N", "").strip,
      :cnpj => dados[23].gsub("\\N", "").strip,
      :complemento => dados[16].gsub("\\N", "").strip,
      :data_de_referencia => dados[27].gsub("\\N", "").strip,
      :email => dados[5].gsub("\\N", "").strip,
      :endereco => dados[12].gsub("\\N", "").strip,
      :fax => dados[15].gsub("\\N", "").strip,
      :lancamentoscontaspagar => dados[9],
      :lancamentoscontasreceber => dados[10],
      :lancamentosmovimentofinanceiro => dados[8],
      :localidade => localidade,
      :nome => dados[2].gsub("\\N", "").strip,
      :nome_caixa_zeus => dados[24].gsub("\\N", "").strip,
      :sigla => dados[3].gsub("\\N", "").strip,
      :telefone => [dados[4].gsub("\\N", "").strip],
      :entidade_id => (entidade.id if entidade),
      :senha_baixa_dr => 'teste'
    }
    unidade = Unidade.find_or_initialize_by_sigla_and_entidade_id hash
    unidade.limitediasparaestornodeparcelas=10000
    if unidade.save
      unidades[dados[0]] = unidade.id
    else
      erro = "Não foi possível importar os dados da unidade #{dados[2].gsub("\\N", "").strip}!\n#{unidade.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_servicos(line, servicos, unidades)
    dados = line.chomp.split("\t")

    case dados[3].gsub("\\N", "").strip
    when "t"; atv = true;
    when "f"; atv = false;
    end

    case dados[4].gsub("\\N", "").strip
    when "1"; mod = "Qualificação"
    when "2"; mod = "Aperfeiçoamento"
    when "3"; mod = "Aprendizagem"
    when "4"; mod = "S.T.T"
    when "5"; mod = "Curso Tecnológico"
    when "6"; mod = "Habilitação Eletro-eletrônica"
    when "7"; mod = "Habilitação em Segurança no Trabalho"
    when "8"; mod = "Eventos"
    when "9"; mod = "Outros"
    end

    unidade = Unidade.find_by_id unidades[dados[1]]

    hash = {
      :ativo => atv,
      :codigo_do_servico_sigat => dados[5].gsub("\\N", "").strip,
      :descricao => dados[2].gsub("\\N", "").strip,
      :modalidade => mod,
      :unidade_id => (unidade.id if unidade)
    }

    servico = Servico.find_or_initialize_by_descricao_and_unidade_id hash

    servico.unidade_id = (unidade.id if unidade)

    if servico.save
      servicos[dados[0]] = servico.id
    else
      erro = "Não foi possível importar o serviço #{dados[2].gsub("\\N", "").strip}!\n#{servico.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_clientes(line, clientes, entidade, localidades)
    dados = line.chomp.split("\t")
    endereco = nil

    case dados[23].gsub("\\N", "").strip
    when "N"; spc = false
    when "S"; spc = true
    end

    case dados[21]
    when "F"
      localidade = Localidade.find_by_id localidades[dados[7].gsub("\\N", "").strip]

      endereco = dados[4].gsub("\\N", "").strip
      endereco = "." if endereco.empty?

      hash = {
        :cpf => dados[1].gsub(%r{(\s)(\-*)(\.*)(\/*)}, ""),
        :nome => dados[2].gsub("\\N", "").strip,
        :tipo_pessoa => Pessoa::FISICA,
        :email => [dados[3].gsub("\\N", "").strip],
        :endereco => endereco,
        :bairro => dados[5].gsub("\\N", "").strip,
        :complemento => dados[6].gsub("\\N", "").strip,
        :localidade => localidade,
        :cep => dados[8].gsub("\\N", "").strip,
        :telefone => [dados[9].gsub("\\N", "").strip, dados[10].gsub("\\N", "").strip],
        :entidade_id => (entidade.id if entidade),
        :cliente => true,
        :spc => spc
      }
      cliente = Pessoa.find_or_initialize_by_cpf_and_entidade_id hash
      if cliente.save
        clientes[dados[0]] = cliente.id
      else
        erro = "Não foi possível importar os dados da pessoa física #{dados[2].gsub("\\N", "").strip}!\n#{cliente.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
    when "J"
      localidade = Localidade.find_by_id localidades[dados[14].gsub("\\N", "").strip]

      endereco = dados[11].gsub("\\N", "").strip
      endereco = "." if endereco.empty?

      hash = {
        :cnpj => dados[1].gsub(%r{(\-*)(\.*)(\/*)}, ""),
        :razao_social => dados[2].gsub("\\N", "").strip,
        :bairro => dados[12].gsub("\\N", "").strip,
        :complemento => dados[13].gsub("\\N", "").strip,
        :cep => dados[15].gsub("\\N", "").strip,
        :telefone => [dados[16].gsub("\\N", "").strip, dados[19].gsub("\\N", "").strip],
        :email => [dados[17].gsub("\\N", "").strip, dados[20].gsub("\\N", "").strip],
        :contato => dados[18].gsub("\\N", "").strip,
        :nome => dados[24].gsub("\\N", "").strip,
        :cliente => true,
        :endereco => endereco,
        :entidade_id => (entidade.id if entidade),
        :localidade => localidade,
        :spc => spc,
        :tipo_pessoa => Pessoa::JURIDICA
      }
      cliente = Pessoa.find_or_initialize_by_cnpj_and_entidade_id hash
      if cliente.save
        clientes[dados[0]] = cliente.id
      else
        erro = "Não foi possível importar os dados da pessoa jurídica #{dados[2].gsub("\\N", "").strip}!\n#{cliente.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
    end
  end

  def self.importacao_contas_correntes(line, agencias, contas_correntes, planos_de_conta, unidades)
    dados = line.chomp.split("\t")

    agencia = Agencia.find_by_id agencias[dados[1].gsub("\\N", "").strip]
    conta_contabil = PlanoDeConta.find_by_id planos_de_conta[dados[8].gsub("\\N", "").strip]
    unidade = Unidade.find_by_id unidades[dados[10].gsub("\\N", "").strip]

    case dados[5].gsub("\\N", "").strip
    when "N"; ativo = false
    when "S"; ativo = true
    end

    hash = {
      :numero_conta => dados[2].gsub("\\N", "").strip,
      :descricao => dados[3].gsub("\\N", "").strip,
      :data_abertura => dados[4].gsub("\\N", "").strip,
      :data_encerramento => dados[6].gsub("\\N", "").strip,
      :saldo_inicial => dados[9].gsub("\\N", "").strip,
      :tipo => dados[11].gsub("\\N", "").strip,
      :saldo_atual => dados[12].gsub("\\N", "").strip,
      :identificador => dados[13].gsub("\\N", "").strip,
      :digito_verificador => dados[16],
      :agencia_id => (agencia.id if agencia),
      :ativo => ativo,
      :conta_contabil => conta_contabil,
      :unidade_id => (unidade.id if unidade)
    }

    conta_corrente = ContasCorrente.find_or_initialize_by_numero_conta_and_agencia_id_and_unidade_id hash

    if conta_corrente.save
      contas_correntes[dados[7]] = conta_corrente.id
    else
      erro = "Não foi possível importar os dados da conta corrente #{dados[3].gsub("\\N", "").strip}!\n#{conta_corrente.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_unidades_organizacionais(line, unidades_organizacionais)
    dados = line.chomp.split("\t")
    entidade = Entidade.find_by_codigo_zeus dados[1]

    hash = {
      :ano => dados[0],
      :codigo_da_unidade_organizacional => dados[2].gsub("\\N", "").strip,
      :nome => dados[3].gsub("\\N", "").strip,
      :codigo_reduzido => dados[4].gsub("\\N", "").strip,
      :entidade_id => (entidade.id if entidade)
    }

    unidade_org = UnidadeOrganizacional.find_or_initialize_by_codigo_da_unidade_organizacional_and_nome_and_entidade_id_and_ano hash
    
    if unidade_org.save
      unidades_organizacionais[dados[5]] = unidade_org.id
    else
      erro = "Não foi possível importar os dados da unidade organizacional #{dados[3].gsub("\\N", "").strip}!\n#{unidade_org.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_centros(line, centros)
    dados = line.chomp.split("\t")
    entidade = Entidade.find_by_codigo_zeus dados[1]

    hash = {
      :ano => dados[0],
      :codigo_centro => dados[2].gsub("\\N", "").strip,
      :nome => dados[3].gsub("\\N", "").strip,
      :codigo_reduzido => dados[4].gsub("\\N", "").strip,
      :entidade_id => (entidade.id if entidade)
    }

    centro = Centro.find_or_initialize_by_ano_and_entidade_id_and_codigo_centro hash

    if centro.save
      centros[dados[5]] = centro.id
    else
      erro = "Não foi possível importar os dados do centro #{dados[3].gsub("\\N", "").strip}!\n#{centro.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_dependentes(line, clientes, dependentes)
    dados = line.chomp.split("\t")
    pessoa = Pessoa.find_by_id clientes[dados[1]]

    hash = {
      :nome => dados[2],
      :nome_do_pai => dados[3],
      :nome_da_mae => dados[4],
      :codccr => dados[5],
      :pessoa_id => (pessoa.id if pessoa)
    }

    dependente = Dependente.find_or_initialize_by_nome_and_pessoa_id hash
    if (dependente.errors.count == 1) && (dependente.errors["data_de_nascimento"])
      dependente.save false
    end
      if dependente.save
        dependentes[dados[0]] = dependente.id
      else
        erro = "Não foi possível importar os dados do dependente #{dados[2].gsub("\\N", "").strip}!\n#{dependente.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
  end

  def self.importacao_centros_unidades_organizacionais(line)
    dados = line.chomp.split("\t")

    ano = dados[0].gsub("\\N", "").strip
    codigo_reduzido = dados[4]

    codigo_centro = dados[3].gsub("\\N", "").strip
    codigo_und_org = dados[2].gsub("\\N", "").strip

    centro = Centro.find :first, :conditions => ["(codigo_centro = ?) AND (ano = ?) AND (codigo_reduzido = ?)", codigo_centro, ano, codigo_reduzido]
    unidade_organizacional = UnidadeOrganizacional.find :first, :conditions => ["(codigo_da_unidade_organizacional = ?) AND (ano = ?)", codigo_und_org, ano]

    if centro.nil?
      erro = "Não foi possível associar a unidade organizacional ao centro. Centro de código #{codigo_centro} é inválido.\n\n"
    elsif unidade_organizacional.nil?
      erro = "Não foi possível associar a unidade organizacional ao centro. A Unidade Organizacional de código #{codigo_und_org} é inválida.\n\n"
    elsif centro.unidade_organizacionais.exists?(unidade_organizacional.id)
      erro = "O centro #{codigo_centro} e a unidade #{codigo_und_org} já estão associados.\n\n"
    else
      centro.unidade_organizacionais << unidade_organizacional
    end
    gravar_log_importacao(erro) if erro
  end

  def self.importacao_recebimento_e_pagamento_de_contas(line, centros, clientes, dependentes, fornecedores, funcionarios, pagamentos_de_conta, planos_de_conta, recebimentos_de_conta, servicos, unidades, unidades_organizacionais)
    dados = line.chomp.split("\t")

    centro = Centro.find_by_id centros[dados[22].gsub("\\N", "").strip]
    cobrador = Pessoa.find_by_id funcionarios[dados[46].gsub("\\N", "").strip]
    conta_contabil_despesa = PlanoDeConta.find_by_id planos_de_conta[dados[23].gsub("\\N", "").strip]
    conta_contabil_fornecedor = PlanoDeConta.find_by_id planos_de_conta[dados[37].gsub("\\N", "").strip]
    conta_contabil_receita = PlanoDeConta.find_by_id planos_de_conta[dados[23].gsub("\\N", "").strip]
    dependente = Dependente.find_by_id dependentes[dados[8].gsub("\\N", "").strip]
    fornecedor = Pessoa.find_by_id fornecedores[dados[36].gsub("\\N", "").strip]
    unidade = Unidade.find_by_id unidades[dados[5].gsub("\\N", "").strip]
    pessoa = Pessoa.find_by_id clientes[dados[7].gsub("\\N", "").strip]
    servico = Servico.find_by_id servicos[dados[9].gsub("\\N", "").strip]
    unidade_organizacional = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[21].gsub("\\N", "").strip]
    usuario = Usuario.first
    vendedor = Pessoa.find_by_id funcionarios[dados[45].gsub("\\N", "").strip]

    ano = nil
    if centro
      ano = centro.ano
    elsif conta_contabil_receita
      ano = conta_contabil_receita.ano
    elsif unidade_organizacional
      ano = unidade_organizacional.ano
    end

    case dados[32].gsub("\\N", "").strip
    when "0"; provisao = false
    when "1"; provisao = true
    end

    tempo_limite_contas_pagar = unidade.lancamentoscontaspagar
    tempo_limite_contas_receber = unidade.lancamentoscontasreceber

    unidade.lancamentoscontaspagar = 10000
    unidade.lancamentoscontasreceber = 10000
    unidade.limitediasparaestornodeparcelas = 10000
    unidade.senha_baixa_dr = 'teste'
    unidade.save

    case dados[31].gsub("\\N", "").strip
    when "P"
      hash = {
        :data_emissao => dados[2].gsub("\\N", "").strip,
        :data_lancamento => dados[3].gsub("\\N", "").strip,
        :numero_nota_fiscal_string => dados[6].gsub("\\N", "").strip,
        :valor_do_documento => dados[10],
        :numero_de_parcelas => dados[11].gsub("\\N", "").strip,
        :rateio => dados[27],
        :tipo_de_documento => dados[29].gsub("\\N", "").strip,
        #        :numero_de_controle => dados[30].gsub("\\N", "").strip,
        :historico => dados[33].gsub("\\N", "").strip,
        :primeiro_vencimento => dados[34].gsub("\\N", "").strip,
        :centro => centro,
        :conta_contabil_despesa => conta_contabil_despesa,
        :conta_contabil_pessoa => conta_contabil_fornecedor,
        :pessoa => fornecedor,
        :provisao => provisao,
        :unidade => unidade,
        :unidade_organizacional => unidade_organizacional,
        :usuario_corrente => usuario,
        #:parcelas_geradas => ,
      }
      pagamento_de_conta = PagamentoDeConta.new hash

      pagamento_de_conta.numero_de_controle = dados[30].gsub("\\N", "").strip
      pagamento_de_conta.ano = ano

      if pagamento_de_conta.save
        pagamentos_de_conta[dados[0]] = pagamento_de_conta.id
      else
        erro = "Não foi possível importar os dados do pagamento de conta #{dados[6].gsub("\\N", "").strip}!\n#{pagamento_de_conta.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
    when "R"
      hash = {
        :data_inicio => dados[2].gsub("\\N", "").strip,
        :data_final => dados[3].gsub("\\N", "").strip,
        :vigencia => dados[4],
        #        :situacao_fiemt => dados[12].gsub("\\N", "").strip,
        :situacao_fiemt => RecebimentoDeConta::Permuta,
        :numero_nota_fiscal => dados[6].gsub("\\N", "").strip,
        :numero_de_parcelas => dados[11].gsub("\\N", "").strip,
        :valor_do_documento => dados[10],
        :numero_de_renegociacoes => dados[16].gsub("\\N", "").strip,
        :dia_do_vencimento => dados[24].gsub("\\N", "").strip,
        :rateio => dados[27],
        :tipo_de_documento => dados[29].gsub("\\N", "").strip,
        #        :numero_de_controle => dados[30].gsub("\\N", "").strip,
        :historico => dados[33].gsub("\\N", "").strip,
        :data_venda => dados[43].gsub("\\N", "").strip,
        :origem => dados[44].gsub("\\N", "").strip,
        :centro => centro,
        :cobrador => cobrador,
        :conta_contabil_receita => conta_contabil_receita,
        :dependente => dependente,
        :pessoa => pessoa,
        :servico => servico,
        :unidade => unidade,
        :unidade_organizacional => unidade_organizacional,
        :vendedor => vendedor,
        :usuario_corrente => usuario,
        #      :data_primeira_carta => ,
        #      :data_segunda_carta => ,
        #      :data_terceira_carta => ,
        #      :juros_por_atraso => ,
        #      :multa_por_atraso => ,
        #      :parcelas_geradas => ,
      }
      recebimento_de_conta = RecebimentoDeConta.new hash

      recebimento_de_conta.numero_de_controle = dados[30].gsub("\\N", "").strip
      recebimento_de_conta.situacao_fiemt = dados[12].gsub("\\N", "").strip
      recebimento_de_conta.ano = ano

      if recebimento_de_conta.save
        recebimentos_de_conta[dados[0]] = recebimento_de_conta.id
      else
        erro = "Não foi possível importar os dados do recebimento de conta #{dados[6].gsub("\\N", "").strip}!\n#{recebimento_de_conta.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end
    end

    unidade.lancamentoscontaspagar = tempo_limite_contas_pagar
    unidade.lancamentoscontasreceber = tempo_limite_contas_receber
    unidade.save
  end

  def self.importacao_movimentos(line, centros, clientes, fornecedores, movimentos, planos_de_conta, unidades, unidades_organizacionais)
    dados = line.chomp.split("\t")

    pessoas = {}
    codctarec = dados[29].gsub("\\N", "").strip
    codpar = dados[30].gsub("\\N", "").strip

    if (codctarec.empty? && codpar.empty?)
      case dados[34].gsub("\\N", "").strip
      when "0"; pessoas = fornecedores
      when "1"; pessoas = clientes
      end

      pessoa = Pessoa.find_by_id pessoas[dados[33].gsub("\\N", "").strip]
      unidade = Unidade.find_by_id unidades[dados[1].gsub("\\N", "").strip]
      tipo_documento = dados[5].gsub("\\N", "").gsub("DB", "DP").strip

      tempo_limite_movimento_financeiro = unidade.lancamentosmovimentofinanceiro
      unidade.lancamentosmovimentofinanceiro = 10000
      unidade.limitediasparaestornodeparcelas = 10000
      unidade.save

      busca_pag = PagamentoDeConta.find_by_numero_de_controle(dados[35].gsub("\\N", "")) rescue nil
      busca_rec = RecebimentoDeConta.find_by_numero_de_controle(dados[35].gsub("\\N", "")) rescue nil

      if !busca_pag.blank?
        conta = busca_pag
      elsif !busca_rec.blank?
        conta = busca_rec
      end

      parcela_id = conta.parcelas.select{|par| par.numero == dados[30].gsub("\\N", "").strip}.pop if conta

      hash = {
        :tipo_documento => dados[3].gsub("\\N", "").strip,
        :tipo_lancamento => tipo_documento,
        :data_lancamento => dados[6].gsub("\\N", "").strip,
        :historico => dados[12].gsub("\\N", "").strip,
        :numero_de_controle => dados[35].gsub("\\N", "").strip,
        :provisao => Movimento::SIMPLES,
        :pessoa => pessoa,
        :unidade_id => (unidade.id if unidade),
        :conta => conta,
        :numero_da_parcela => dados[30].gsub("\\N", "").strip,
        :valor_total => dados[10].gsub("\\N", "").strip,
        :parcela => (parcela_id if parcela_id)
      }

      movimento = Movimento.find_or_initialize_by_numero_de_controle_and_unidade_id hash

      if movimento.save
        movimentos[dados[0].gsub("\\N", "").strip] = movimento.id
      else
        erro = "Não foi possível importar os dados do movimento #{dados[35].gsub("\\N", "").strip}!\n#{movimento.errors.full_messages.join("\n")}\n\n"
        gravar_log_importacao(erro)
      end

      unidade.lancamentosmovimentofinanceiro = tempo_limite_movimento_financeiro
      unidade.save
    end
  end

  def self.importacao_itens_movimento(line, centros, movimentos, planos_de_conta, unidades_organizacionais)
    dados = line.chomp.split("\t")

    plano_de_conta = PlanoDeConta.find_by_id planos_de_conta[dados[0].gsub("\\N", "").strip]
    unidade_organizacional = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[1].gsub("\\N", "").strip]
    centro = Centro.find_by_id centros[dados[2].gsub("\\N", "").strip]
    movimento = Movimento.find_by_id movimentos[dados[7].gsub("\\N", "").strip]

    hash = {
      :centro_id => (centro.id if centro),
      :movimento_id => (movimento.id if movimento),
      :plano_de_conta_id => (plano_de_conta.id if plano_de_conta),
      :unidade_organizacional_id => (unidade_organizacional.id if unidade_organizacional)
    }

    case dados[3].gsub("\\N", "").strip
    when "C"
      hash[:valor] = dados[6].gsub("\\N", "").strip
      hash[:tipo] = "C"
    when "D"
      hash[:valor] = dados[5].gsub("\\N", "").strip
      hash[:tipo] = "D"
    end

    item_movimento = ItensMovimento.find_or_initialize_by_plano_de_conta_id_and_movimento_id_and_centro_id_and_unidade_organizacional_id hash

    unless item_movimento.save
      erro = "Não foi possível importar os dados do item do movimento #{dados[7].gsub("\\N", "").strip}!\n#{item_movimento.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end

    if movimento
      tempo_limite_movimento_financeiro = movimento.unidade.lancamentosmovimentofinanceiro
      movimento.unidade.lancamentosmovimentofinanceiro = 10000
      movimento.unidade.limitediasparaestornodeparcelas = 10000
      movimento.unidade.save

      itens_movimento = ItensMovimento.all(:conditions => ['(tipo = ?) AND (movimento_id = ?)', 'C', movimento.id])
      movimento.valor_total = itens_movimento.collect{ |i| i.valor }.sum
      movimento.save

      movimento.unidade.lancamentosmovimentofinanceiro = tempo_limite_movimento_financeiro
      movimento.unidade.save
    end
  end

  def self.importacao_parcelas(line, centros, pagamentos_de_conta, parcelas, planos_de_conta, recebimentos_de_conta, unidades_organizacionais)
    dados = line.chomp.split("\t")

    conta_contabil_multa = PlanoDeConta.find_by_id planos_de_conta[dados[38].gsub("\\N", "").strip]
    conta_contabil_juros = PlanoDeConta.find_by_id planos_de_conta[dados[41].gsub("\\N", "").strip]
    conta_contabil_desconto = PlanoDeConta.find_by_id planos_de_conta[dados[50].gsub("\\N", "").strip]
    conta_contabil_outros = PlanoDeConta.find_by_id planos_de_conta[dados[53].gsub("\\N", "").strip]
    conta_contabil_devolucao = PlanoDeConta.find_by_id planos_de_conta[dados[63].gsub("\\N", "").strip]

    unidade_organizacional_multa = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[36].gsub("\\N", "").strip]
    unidade_organizacional_juros = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[39].gsub("\\N", "").strip]
    unidade_organizacional_desconto = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[48].gsub("\\N", "").strip]
    unidade_organizacional_outros = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[51].gsub("\\N", "").strip]

    centro_multa = Centro.find_by_id centros[dados[37].gsub("\\N", "").strip]
    centro_juros = Centro.find_by_id centros[dados[40].gsub("\\N", "").strip]
    centro_desconto = Centro.find_by_id centros[dados[49].gsub("\\N", "").strip]
    centro_outros = Centro.find_by_id centros[dados[52].gsub("\\N", "").strip]

    conta_corrente = ContasCorrente.find_by_numero_conta(dados[34].gsub("\\N", "").strip) rescue nil
    plano_de_conta = PlanoDeConta.find_by_codigo_contabil(dados[35].gsub("\\N", "").strip) rescue nil
    banco = Banco.find_by_codigo_do_banco(dados[22].gsub("\\N", "").strip) rescue nil

    conta_type = (dados[66].gsub("\\N", "").strip) == 'R' ? 'RecebimentoDeConta' : 'PagamentoDeConta'

    busca_pag = PagamentoDeConta.find_by_numero_de_controle(dados[65].gsub("\\N", "")) rescue nil
    busca_rec = RecebimentoDeConta.find_by_numero_de_controle(dados[65].gsub("\\N", "")) rescue nil

    if !busca_pag.blank?
      conta = busca_pag
    elsif !busca_rec.blank?
      conta = busca_rec
    end

    hash = {
      :data_vencimento => dados[2].gsub("\\N", "").strip,
      :valor => dados[3].gsub("\\N", "").strip,
      :valor_da_multa => dados[8].gsub("\\N", "").strip,
      :valor_dos_juros => dados[9].gsub("\\N", "").strip,
      :valor_do_desconto => dados[12].gsub("\\N", "").strip,
      :outros_acrescimos => dados[13].gsub("\\N", "").strip,
      :observacoes => dados[29].gsub("\\N", "").strip, # campo 29????
      :centro_desconto_id => (centro_desconto.id if centro_desconto),
      :centro_multa_id => (centro_multa.id if centro_multa),
      :centro_juros_id => (centro_juros.id if centro_juros),
      :centro_outros_id => (centro_outros.id if centro_outros),
      :conta_contabil_desconto_id => (conta_contabil_desconto.id if conta_contabil_desconto),
      :conta_contabil_multa_id => (conta_contabil_multa.id if conta_contabil_multa),
      :conta_contabil_juros_id => (conta_contabil_juros.id if conta_contabil_juros),
      :conta_contabil_outros_id => (conta_contabil_outros.id if conta_contabil_outros),
      :unidade_organizacional_desconto_id => (unidade_organizacional_desconto.id if unidade_organizacional_desconto),
      :unidade_organizacional_multa_id => (unidade_organizacional_multa.id if unidade_organizacional_multa),
      :unidade_organizacional_juros_id => (unidade_organizacional_juros.id if unidade_organizacional_juros),
      :unidade_organizacional_outros_id => (unidade_organizacional_outros.id if unidade_organizacional_outros),
      :numero => dados[1].gsub("\\N", "").strip,
      :data_da_baixa => dados[4].gsub("\\N", "").strip,
      :valor_liquido => dados[5].gsub("\\N", "").strip,
      :justificativa_para_outros => dados[32].gsub("\\N", "").strip,
      :historico => dados[80].gsub("\\N", "").strip,
      :forma_de_pagamento => dados[19].gsub("\\N", "").strip,
      :conta_corrente_id => conta_corrente,
      #  :numero_do_comprovante => ,
      #  :data_do_pagamento => ,
      :conta_id => conta,
      :conta_type => conta_type,
      #  :recibo_impresso => ,
      :situacao => dados[15].gsub("\\N", "").strip
    }

    parcela = Parcela.new hash

    case dados[19].gsub("\\N", "").strip
    when "3"
      hash_cheque = {
        #            :parcela => ,
        :banco => banco,
        :agencia => dados[23].gsub("\\N", "").strip,
        #            :conta => ,
        :numero => dados[24].gsub("\\N", "").strip,
        :data_de_recebimento => dados[25].gsub("\\N", "").strip,
        #            :data_para_deposito => ,
        :nome_do_titular => dados[21].gsub("\\N", "").strip,
        :data_do_deposito => dados[26].gsub("\\N", "").strip,
        :plano_de_conta => plano_de_conta,
        #            :historico => ,
        #            :situacao => ,
        #            :conta_contabil_transitoria => ,
        :conta_contabil_devolucao => conta_contabil_devolucao,
        #            :prazo =>
      }
    when "4"
      hash_cartao = {
        :nome_do_titular => dados[21].gsub("\\N", "").strip,
        :codigo_de_seguranca => dados[27].gsub("\\N", "").strip,
        :numero => dados[30].gsub("\\N", "").strip,
        :validade => dados[28].gsub("\\N", "").strip,
        :plano_de_conta => plano_de_conta,
        #            :bandeira => dados[].gsub("\\N", "").strip,
        #            :situacao => ""
      }
    end

    if parcela.save
      hash_cheque["parcela_id"] = parcela.id if hash_cheque
      hash_cartao["parcela_id"] = parcela.id if hash_cartao
      parcelas[dados[0].gsub("\\N", "").strip + dados[1].gsub("\\N", "").strip] = parcela.id
    else
      erro = "Não foi possível importar os dados da parcela #{dados[1].gsub("\\N", "").strip}!\n#{parcela.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao_rateios(line, centros, parcelas, planos_de_conta, unidades_organizacionais)
    dados = line.chomp.split("\t")

    parcela_id = dados[0].gsub("\\N", "").strip + dados[1].gsub("\\N", "").strip

    parcela = Parcela.find_by_id parcelas[parcela_id]
    conta_contabil = PlanoDeConta.find_by_id planos_de_conta[dados[2].gsub("\\N", "").strip]
    unidade_organizacional = UnidadeOrganizacional.find_by_id unidades_organizacionais[dados[3].gsub("\\N", "").strip]
    centro = Centro.find_by_id centros[dados[4].gsub("\\N", "").strip]

    hash = {
      :unidade_organizacional_id => (unidade_organizacional.id if unidade_organizacional),
      :centro_id => (centro.id if centro),
      :valor => dados[5].gsub("\\N", "").strip,
      :parcela_id => (parcela.id if parcela),
      :conta_contabil_id => (conta_contabil.id if conta_contabil)
    }

    rateio = Rateio.find_or_initialize_by_parcela_id hash

    unless rateio.save
      erro = "Não foi possível importar os dados do rateio #{dados[1].gsub("\\N", "").strip}!\n#{rateio.errors.full_messages.join("\n")}\n\n"
      gravar_log_importacao(erro)
    end
  end

  def self.importacao(str, ident_unidade, entidades, localidades, unidades)
    agencias ||= {}
    bancos ||= {}
    cargos ||= {}
    centros ||= {}
    clientes ||= {}
    contas_correntes ||= {}
    dependentes ||= {}
    fornecedores ||= {}
    funcionarios ||= {}
    historicos ||= {}
    impostos ||= {}
    movimentos ||= {}
    parcelas ||= {}
    pagamentos_de_conta ||= {}
    planos_de_conta ||= {}
    recebimentos_de_conta ||= {}
    usuarios ||= {}
    servicos ||= {}
    unidades_organizacionais ||= {}

    encontrou_inicio = ""
    arquivo = Iconv.conv('UTF-8', 'ISO-8859-15', File.read(str))

    # BANCO ----- CARGO ----- HISTÓRICO ----- PLANO DE CONTA
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY banco (codbco, nomebco, dtatu, ativo, codzeus, siglabco, codg_banco, dv_banco) FROM stdin;\n"
          encontrou_inicio = "banco"
        elsif line == "COPY cargo (codcar, codent, dsccar) FROM stdin;\n"
          encontrou_inicio = "cargo"
        elsif line == "COPY historico (codhist, dschist, dtatu, ativo) FROM stdin;\n"
          encontrou_inicio = "historico"
        elsif line == "COPY plcta (ano, codemp, codcta, nomecta, codclascta, dtatu, nivel, ativo, tipocta, codreduz, idplcta, caractercta) FROM stdin;\n"
          encontrou_inicio = "plano_de_conta"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "banco"; self.importacao_bancos(line, bancos)
          when "cargo"; self.importacao_cargos(line, cargos)
          when "historico"; self.importacao_historicos(line, ident_unidade.entidade, historicos)
          when "plano_de_conta"; self.importacao_planos_de_conta(line, ident_unidade.entidade, planos_de_conta)
          end
        end
      end
    end

    # AGÊNCIA ----- CONTA CORRENTE ----- IMPOSTO ----- PESSOA ----- USUÁRIO ----- SERVIÇO
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY agencia (codbco, codage, nomeage, endage, bairage, codcid, cepage, cxpostalage, telage, faxage, nomecontage, telcontage, cargcontage, ativo, dtatu, codbcozeus, codagezeus, hpageage, emailage, emailcontage, dv, numero) FROM stdin;\n"
          encontrou_inicio = "agencia"
        elsif line == "COPY cliente (codcli, idcli, identcli, emailpes, endres, bairrores, compres, codcidres, cepres, telres, telcel, endcom, bairrocom, compcom, codcidcom, cepcom, telcom, emailcom, nomcont, telcont, emailcont, tipocli, atraso, spc, fantasia) FROM stdin;\n"
          encontrou_inicio = "cliente"
        elsif line == "COPY ctacor (codbco, codage, numctacor, nomectacor, dtabertura, ativo, dtencerramento, idctacor, idplcta, saldoini, codund, tipo, saldo, identificador, ultima_conciliacao, saldo_conciliado, dv_numctacor) FROM stdin;\n"
          encontrou_inicio = "conta_corrente"
        elsif line == "COPY fornecedor (codfor, codidfor, identfor, emailpes, endres, bairrores, compres, codcidres, cepres, telres, telcel, endcom, bairrocom, compcom, codcidcom, cepcom, telcom, emailcom, nomcont, telcont, emailcont, tipofor, codage, tipoctacor, numconta, dv, idctactb, fantasia) FROM stdin;\n"
          encontrou_inicio = "fornecedor"
        elsif line == "COPY funcionario (codfun, codent, nomefun, matricula, codcar, codund, emailfun, telfun, ativo, cpffun, codfuncao) FROM stdin;\n"
          encontrou_inicio = "funcionario"
        elsif line == "COPY imposto (imposto, descricao, sigla, aliquota, tipo_imposto, incide_retem, conta_debito, conta_credito, ponteiro) FROM stdin;\n"
          encontrou_inicio = "imposto"
        elsif line == "COPY senha (\"login\", func, senha, nivel, dtultaces, hrultaces) FROM stdin;\n"
          encontrou_inicio = "senha"
        elsif line == "COPY servico (codser, codund, dscser, ativo, codmod, codsigat, moda_id) FROM stdin;\n"
          encontrou_inicio = "servico"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "agencia"; self.importacao_agencias(line, agencias, bancos, ident_unidade.entidade, localidades)
          when "cliente"; self.importacao_clientes(line, clientes, ident_unidade.entidade, localidades)
          when "conta_corrente"; self.importacao_contas_correntes(line, agencias, contas_correntes, planos_de_conta, unidades)
          when "fornecedor"; self.importacao_fornecedores(line, agencias, ident_unidade.entidade, fornecedores, localidades)
          when "funcionario"; self.importacao_funcionarios(line, cargos, entidades,unidades, funcionarios)
          when "imposto"; self.importacao_impostos(line, ident_unidade.entidade, impostos, planos_de_conta)
          when "senha"; self.importacao_usuarios(line, funcionarios, ident_unidade, usuarios)
          when "servico"; self.importacao_servicos(line, servicos, unidades)
          end
        end
      end
    end

    # CENTRO ----- DEPENDENTE ----- UNIDADE ORGANIZACIONAL
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY centro (ano, codemp, codcentro, nomecentro, codreduz, codidcentro) FROM stdin;\n"
          encontrou_inicio = "centro"
        elsif line == "COPY dependente (coddep, codcli, nomedep, paidep, maedep, codccr) FROM stdin;\n"
          encontrou_inicio = "dependente"
        elsif line == "COPY undorg (ano, codemp, codundorg, nomeundorg, codreduz, idundorg, codundccr) FROM stdin;\n"
          encontrou_inicio = "unidade_org"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "centro"; self.importacao_centros(line, centros)
          when "dependente"; self.importacao_dependentes(line, clientes, dependentes)
          when "unidade_org"; self.importacao_unidades_organizacionais(line, unidades_organizacionais)
          end
        end
      end
    end

    # CENTRO <=> UNIDADES ORGANIZACIONAIS ----- PAGAMENTO/RECEBIMENTO DE CONTAS
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY centro_undorg (ano, codemp, codundorg, codcentro, codreduz) FROM stdin;\n"
          encontrou_inicio = "centro_undorg"
        elsif line == "COPY contrato (codctarec, dtreg, dtini, dtfim, vigencia, codund, numdoc, codcli, coddep, codser, valor, qtdpar, situacao, codope, dtaber, conectado, numrenego, impct01, impct02, impct03, atraso, codundorg, codcen, codplcta, diavenc, justificativa, dtcancel, rateio, imp, tipodoc, controle, tipo, provisionado, historico, dtvenc, dtprov, codfor, idctafor, retem, dtinicio_p, dtfim_p, justifica, forma_pagto, dtvenda, venda, vendedor, codcobrador, contabilizar, dtmov, importado, numconv) FROM stdin;\n"
          encontrou_inicio = "pagamento_recebimento_de_contas"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "centro_undorg"; self.importacao_centros_unidades_organizacionais(line)
          when "pagamento_recebimento_de_contas"; self.importacao_recebimento_e_pagamento_de_contas(line, centros, clientes, dependentes, fornecedores, funcionarios, pagamentos_de_conta, planos_de_conta, recebimentos_de_conta, servicos, unidades, unidades_organizacionais)
          end
        end
      end
    end

    # MOVIMENTOS ----- PARCELAS ----- RATEIOS
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY movdia (codmovdia, codund, diareg, tipodoc, numdoc, tipolanc, dtlanc, idctactb, idundorg, idcentro, valor, codctacor, historico, origem, entrada, saida, codforma, codbco, agencia, conta, titular, numch, dtch, dtcomp, dtdep, numdev, motivo, codali, situacao, codctarec, codpar, seqrenego, idmovdia, codpessoa, tipopessoa, control, data_conciliacao, conciliar, saldo_banco_conciliado) FROM stdin;\n"
          encontrou_inicio = "movdia"
        elsif line == "COPY parcela (codctarec, codpar, dtvenc, val, dtrec, valrec, mul, jur, valmul, valjur, valhon, valprot, valdes, valout, valtxbol, status, codope, codfun, imprec, codforma, digito, titular, codbco, nomeage, numcta, dtche, dtdep, codseg, validade, obs, codcar, numrec, obsout, seqrenego, codctacor, codplcta, codundorgmul, codcentromul, codidplctamul, codundorgjur, codcentrojur, codidplctajur, codundorghon, codcentrohon, codidplctahon, codundorgpro, codcentropro, codidplctapro, codundorgdes, codcentrodes, codidplctades, codundorgout, codcentroout, codidplctaout, codundorgbol, codcentrobol, codidplctabol, codredout, sel, situcart, ndev, situdev, idplctadevdat, idplctadevbco, idctacorbco, controle, tipo, valret, valpar, dtemissao, contabilizada, data_conciliacao, conciliar, selecionado, ultima_devolucao, descarte, baixada_dr, data_descarte, eletronico, data_eletronico, historico, sel_cheque, tipo_baixa, dtbaixa, sigat, ultatu, numsigat, dtmov, gerouboleto) FROM stdin;\n"
          encontrou_inicio = "parcela"
        elsif line == "COPY rateiopar (codctarec, codpar, codplcta, codundorg, codcentro, val, seqrenego, codrateiopar, perc, principal, tipo) FROM stdin;\n"
          encontrou_inicio = "rateio"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "movdia"; self.importacao_movimentos(line, centros, clientes, fornecedores, movimentos, planos_de_conta, unidades, unidades_organizacionais)
          when "parcela"; self.importacao_parcelas(line, centros, pagamentos_de_conta, parcelas, planos_de_conta, recebimentos_de_conta, unidades_organizacionais)
          when "rateio"; self.importacao_rateios(line, centros, parcelas, planos_de_conta, unidades_organizacionais)
          end
        end
      end
    end

    # ITENS MOVIMENTO
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY contabildia (idctactb, idundorg, idcentro, tipo, valor, entrada, saida, idmovdia, data, codctarec, codpar, seqrenego, provisionado, controle, fato, idcontabildia, historico, codund, exportada, incluida) FROM stdin;\n"
          encontrou_inicio = "contabildia"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "contabildia"; self.importacao_itens_movimento(line, centros, movimentos, planos_de_conta, unidades_organizacionais)
          end
        end
      end
    end
  end

  def self.importacao_entidades_localidades_unidades(str, entidades, localidades, unidades)
    encontrou_inicio = ""
    arquivo = Iconv.conv('UTF-8', 'ISO-8859-15', File.read(str))

    # CIDADE (LOCALIDADE) ----- ENTIDADE ----- UNIDADE
    arquivo.each_line do |line|
      if (line == "-- PostgreSQL database dump complete\n")
        puts "Fim do arquivo."
      else
        if line == "COPY entidade (codent, dscent, siglaent, codzeus) FROM stdin;\n"
          encontrou_inicio = "entidade"
        elsif line == "COPY cidade (codcid, nomecid, ufcid) FROM stdin;\n"
          encontrou_inicio = "cidade"
        elsif line == "COPY unidade (codund, codent, dscund, siglaund, telund, emailund, codcid, limbaixa, limmf, limcp, limcr, sigla, endereco, bairro, cep, telfax, complemento, databasename, hostname, username, \"password\", ativa, ultexp, cnpj, cxzeus, numcr, codintegrator, dtref) FROM stdin;\n"
          encontrou_inicio = "unidade"
        elsif line == "\\.\n"
          encontrou_inicio = ""
        else
          case (encontrou_inicio)
          when "cidade"; self.importacao_localidades(line, localidades)
          when "entidade"; self.importacao_entidades(line, entidades)
          when "unidade"; self.importacao_unidades(line, entidades, localidades, unidades)
          end
        end
      end
    end
  end

  def self.inserir_dados_importacao
    entidades ||= {}
    localidades ||= {}
    unidades ||= {}

    file = "#{RAILS_ROOT}/log/importacao.log"
    File.delete(file) if File.exist?(file)

    puts "Insira o nome do arquivo que deseja importar: "
    arquivo = gets.chomp

    begin
      Pessoa.transaction do
        Gefin.importacao_entidades_localidades_unidades(arquivo, entidades, localidades, unidades)

        puts "Verifique os dados acima e insira 'S' para confirmar ou 'N' para cancelar a operação:"
        confirmacao = gets.chomp.upcase
        while (confirmacao != "S" && confirmacao != "N")
          puts "Insira 'S' para confirmar ou 'N' para cancelar a operação:"
          confirmacao = gets.chomp.upcase
        end
        raise "Operação cancelada" if (confirmacao == "N")
      end
    end

    # ----------

    lista_unidades = Unidade.all; unidade = nil
    while unidade == nil do
      puts "Unidades disponíveis no GEFIN"
      puts "------------------------------"
      lista_unidades.each{|item| [puts "(#{item.id}) --> " + item.nome]}
      puts "------------------------------"
      puts "Insira o número da Unidade de que deseja importar os dados:"
      id_unidade = gets.chomp
      unidade = Unidade.find_by_id(id_unidade)
    end

    begin
      Parcela.transaction do
        Gefin.importacao(arquivo, unidade, entidades, localidades, unidades)

        puts "Verifique os dados acima e insira 'S' para confirmar ou 'N' para cancelar a operação:"
        confirmacao = gets.chomp.upcase
        while (confirmacao != "S" && confirmacao != "N")
          puts "Insira 'S' para confirmar ou 'N' para cancelar a operação:"
          confirmacao = gets.chomp.upcase
        end
        raise "Operação cancelada" if (confirmacao == "N")
      end
    end
  end

  def self.gravar_log_importacao(mensagem)
    File.open "#{RAILS_ROOT}/log/importacao.log", 'a' do |f|
      puts mensagem
      f.puts mensagem
    end
  end

end
