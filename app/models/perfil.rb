class Perfil < ActiveRecord::Base

  acts_as_audited

  has_many :usuarios

  def before_destroy
    unless self.usuarios.empty?
      errors.add_to_base "Perfil não pode ser excluído enquanto estiver ligado ao(s) usuário(s): #{self.usuarios.collect(&:nome).join(', ')}"
      false
    end
  end

  #PERFIS ANTIGOS
  #                      0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90
  #MASTER =             "S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S".gsub(" ", "")
  #GERENTE =            "S  S  N  S  S  S  N  S  S  S  S  S  S  S  S  S  S  S  N  S  S  N  S  S  N  N  S  N  S  S  S  S  S  N  S  N  N  N  S  S  S  S  N  N  S  N  N  N  S  S  S  S  S  S  S  S  S  S  N  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  #OPERADORFINANCEIRO = "S  S  N  S  S  S  N  S  S  S  S  S  S  S  N  S  N  N  N  S  S  N  S  S  N  N  S  N  S  S  S  S  S  N  S  N  N  N  N  N  S  S  N  N  S  N  N  N  S  S  S  S  S  S  S  S  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  #OPERADORCR =         "N  N  N  N  S  S  N  S  S  S  S  S  S  N  S  S  N  N  N  N  N  N  N  S  N  N  N  N  N  N  S  N  N  N  S  N  N  N  N  N  N  N  N  N  S  N  N  N  N  S  S  S  N  S  S  S  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  #OPERADORCP =         "N  N  N  N  S  S  N  S  S  S  S  S  S  N  S  S  N  N  N  N  N  N  N  S  N  N  N  N  N  N  S  S  N  N  S  N  N  N  N  N  N  N  N  N  S  N  N  N  S  N  N  N  N  S  S  S  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  #CONSULTA =           "N  N  N  N  S  S  N  S  N  N  N  S  S  N  S  S  N  N  N  N  N  N  N  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  #CONTADOR =           "N  N  N  N  S  S  N  S  N  S  S  S  S  N  S  S  N  N  N  N  N  N  N  S  N  N  S  N  S  S  S  S  N  N  S  N  N  N  N  N  N  S  N  N  S  N  S  S  S  S  S  S  S  S  S  S  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")

  #NOVOS PERFIS
  #                     0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17
  MASTER =             "S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S  S".gsub(" ", "")
  GERENTE =            "S  S  N  S  S  N  N  S  S  S  S  S  S  S  N  S  N  N  S  S  S  N  S  S  N  N  S  S  S  S  S  S  S  N  S  N  N  N  N  N  S  S  S  N  S  S  N  N  S  S  S  S  S  S  N  N  N  S  S  S  N  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  OPERADORFINANCEIRO = "S  S  N  N  S  N  N  S  S  S  S  N  S  S  N  S  N  N  S  S  S  N  N  S  N  N  S  S  S  S  N  S  S  N  S  N  N  N  N  N  S  S  S  N  S  S  N  N  N  S  S  S  S  N  N  N  N  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  OPERADORCR =         "S  S  N  N  S  N  N  N  S  N  N  N  S  S  N  S  N  N  S  S  S  N  N  S  N  N  N  S  N  N  N  S  S  N  S  N  N  N  N  N  N  N  S  N  S  S  N  N  N  S  S  S  N  N  N  N  N  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  OPERADORCP =         "S  S  N  N  S  N  N  S  S  S  S  N  S  S  N  S  N  N  S  S  S  N  N  S  N  N  S  S  S  S  N  S  S  N  S  N  N  N  N  N  S  S  S  N  N  N  N  N  N  N  N  N  S  N  N  N  N  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  CONSULTA =           "N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")
  CONTADOR =           "N  N  N  N  N  N  N  S  N  S  S  N  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  S  N  S  N  S  N  S  N  S  S  S  N  N  N  S  N  N  N  N  S  S  S  S  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N  N".gsub(" ", "")

  Agencias = 0
  Bancos = 1
  Centros = 2
  ContasCorrentes = 3
  Dependentes = 4
  Entidades = 5
  Historicos = 6
  ItensMovimentos = 7 # Não utilizado mais
  Localidades = 8
  Movimentos = 9
  PagamentoDeContas = 10
  ParametroContaValores = 11 # Não utilizado mais
  Parcelas = 12
  Pessoas = 13
  PlanoDeContas = 14
  Servicos = 15
  Unidades = 16
  UnidadeOrganizacionais = 17
  Usuarios = 18
  ManipularDadosDasAgencias = 19
  ManipularDadosDosBancos = 20
  ManipularDadosDosCentros = 21
  ManipularDadosDasContasCorrentes = 22
  ManipularDadosDosDependentes = 23
  ManipularDadosDasEntidades = 24
  ManipularDadosDosHistoricos = 25
  ManipularDadosDosItensMovimentos = 26 # Não utilizado mais
  ManipularDadosDasLocalidades = 27
  ManipularDadosDosMovimentos = 28
  ManipularDadosDePagamentoDeContas = 29
  ManipularDadosDeParametroContaValores = 30
  ManipularDadosDasParcelas = 31
  ManipularDadosDasPessoas = 32
  ManipularDadosDoPlanoDeContas = 33
  ManipularDadosDeServicos = 34
  ManipularDadosDasUnidades = 35
  ManipularDadosDasUnidadesOrganizacionais = 36
  ManipularDadosDosUsuarios = 37
  Impostos = 38
  ManipularDadosDosImpostos = 39
  LancamentoImpostos = 40
  ManipularDadosDeLancamentoImpostos = 41
  Configuracao = 42
  ManipularDadosDeConfiguracao = 43
  RecebimentoDeContas = 44
  ManipularDadosDeRecebimentoDeContas = 45
  RealizarExportacaoZeus = 46
  RealizarImportacaoZeus = 47
  DeParaEntreAnosDoOrcamento = 48
  ControleDeCheques = 49
  ControleDeCartoes = 50
  ControleDeCompromissos = 51
  ControleDeLancamentosDiarios = 52
  ParametroContaValor = 53
  EstruturaSFIEMT = 54
  MenuFinanceiro = 55
  MenuGerais = 56
  Relatorios = 57 # Não utilizado mais
  AlterarAnoUnidade = 58 # Não utilizado mais
  AlterarAno = 59
  AlterarUnidade = 60
  PerfisDeAcesso = 61
  ManipularPerfisDeAcesso = 62
  LiberarNovoContratoParaInadimplente = 63
  BloquearOrdens = 64
  ConsultarRelatoriosContasAPagar = 65
  ConsultarRelatoriosContasAReceber = 66
  LiberarContratoPeloDrMovimento = 67
  LiberarContratoPeloDrPagamentoDeConta = 68
  LiberarContratoPeloDrRecebimentoDeConta = 69
  Convenios = 70
  ManipularDadosDosConvenios = 71
  ArquivoRemessa = 72
  ManipularArquivoRemessa = 73
  GerarArquivoRemessa = 74
  PararServico = 75
  ProrrogarContrato = 76
  AnaliseContratos = 77
  EnviarParcelasAoDR = 78
  Auditoria = 79
  BaixaDr = 80
  ConsultarFollowUpAPagar = 81
  ConsultarFollowUpAReceber = 82
  ConsultaDeTransacoes = 83
  ConsultarRelatoriosCheque = 84
  ConsultarRelatoriosContabilizacao = 85
  ConsultarRelatoriosContasCorrentes = 86
  ManipularControleDeCompromissos = 87
  ManipularControleDeCartoes = 88
  ManipularControleDeCheques = 89
  ReversaoDeContratos = 90
  CancelarParcCtrCancelado = 91
  LancarEstornoMovimentos = 92
  ImportarXmlContasAReceber = 93
  CancelarAgendamento = 94
  FollowUpMovimento = 95


  def self.lista_de_permissoes_para_view
    [
      ['Acessar Recebimento de Contas', RecebimentoDeContas, [
          ['Manipular Dados de Recebimento de Contas', ManipularDadosDeRecebimentoDeContas],
          ['Iniciar / Parar Servico', PararServico],
          ['Acessar Controle de Cartões', ControleDeCartoes, [
              ['Manipular Controle de Cartões', ManipularControleDeCartoes]
            ]],
          ['Acessar Controle de Cheques', ControleDeCheques, [
              ['Manipular Controle de Cheques', ManipularControleDeCheques]
            ]],
          ['Acessar Controle de Compromissos', ControleDeCompromissos, [
              ['Manipular Controle de Compromissos', ManipularControleDeCompromissos]
            ]],
          ['Acessar Controle de Lançamentos Diários', ControleDeLancamentosDiarios],
          ['Acessar Prorrogação de Contratos', ProrrogarContrato],
          ['Baixa DR', BaixaDr],
          ['Consulta de Follow-Up a Receber', ConsultarFollowUpAReceber],
          ['Contabilização das Receitas', AnaliseContratos],
          ['Enviar parcelas ao DR', EnviarParcelasAoDR],
          ['Reversão de Contratos (Cancelamento/Evasão)', ReversaoDeContratos],
          ['Cancelar parcelas de Contratos Cancelados/Evadidos', CancelarParcCtrCancelado],
          ['Importar Contratos de Contas a Receber (XML)', ImportarXmlContasAReceber],
          ['Cancelamento de Agendamento de Contabilização',CancelarAgendamento],
          ['Excluir Agendamento de Contabilização',CancelarAgendamento],
          
        ]],

      ['Acessar Pagamentos de Contas', PagamentoDeContas, [
          ['Manipular Dados de Pagamento de Contas', ManipularDadosDePagamentoDeContas],
          ['Acessar Lançamento de Impostos', LancamentoImpostos],
          ['Consulta de Follow-Up a Pagar', ConsultarFollowUpAPagar],
          ['Manipular Dados de Lançamento de Impostos', ManipularDadosDeLancamentoImpostos],
          ['Acessar Arquivos de Remesa', ArquivoRemessa, [
              ['Manipular Dados dos Arquivos de Remessas', ManipularArquivoRemessa],
              ['Gerar Arquivos de Remessas', GerarArquivoRemessa],
            ]],
        ]],

      ['Acessar Movimentos', Movimentos, [
          ['Manipular Dados dos Movimentos', ManipularDadosDosMovimentos],
          ['Consultar Follow-Up de Movimento Financeiro', FollowUpMovimento]
        ]],

      ['Acessar Relatórios', nil, [
          ['Consultar Relatórios de Cheques', ConsultarRelatoriosCheque],
          ['Consultar Relatórios de Contabilização', ConsultarRelatoriosContabilizacao],
          ['Consultar Relatórios de Contas a Pagar', ConsultarRelatoriosContasAPagar],
          ['Consultar Relatórios de Contas a Receber', ConsultarRelatoriosContasAReceber],
          ['Consultar Relatórios de Contas Correntes', ConsultarRelatoriosContasCorrentes],
          ['Consulta de Transações', ConsultaDeTransacoes]
        ]],

      ['Cadastros', nil, [
          ['Acessar Estrutura SFIEMT', EstruturaSFIEMT, [
              ['Acessar Entidades', Entidades, [
                  ['Manipular Dados das Entidades', ManipularDadosDasEntidades],
                  ['Acessar Unidades', Unidades, [
                      ['Manipular Dados das Unidades', ManipularDadosDasUnidades],
                    ]],
                  ['Acessar Unidades Organizacionais',UnidadeOrganizacionais, [
                      ['Manipular Dados das Unidades Organizacionais', ManipularDadosDasUnidadesOrganizacionais],
                    ]],
                  ['Acessar Serviços', Servicos, [
                      ['Manipular Dados de Serviços', ManipularDadosDeServicos],
                    ]],
                ]],
            ]],
          ['Financeira', nil, [
              ['Acessar Impostos', Impostos, [
                  ['Manipular Dados dos Impostos', ManipularDadosDosImpostos],
                ]],
              ['Acessar Bancos', Bancos, [
                  ['Manipular Dados dos Bancos', ManipularDadosDosBancos]
                ]],
              ['Acessar Agências', Agencias, [
                  ['Manipular Dados das Agências',ManipularDadosDasAgencias],
                ]],
              ['Acessar Contas Correntes', ContasCorrentes, [
                  ['Manipular Dados das Contas Correntes', ManipularDadosDasContasCorrentes]
                ]],
              ['Acessar Convênios', Convenios, [
                  ['Manipular Dados dos Convênios', ManipularDadosDosConvenios]
                ]],
              ['Acessar Históricos', Historicos, [
                  ['Manipular Dados dos Históricos', ManipularDadosDosHistoricos]
                ]],
              ['Acessar Centros', Centros, [
                  ['Manipular Dados dos Centros', ManipularDadosDosCentros]
                ]],
            ]],
          ['Gerais', nil, [
              ['Acessar Pessoas', Pessoas, [
                  ['Liberar Novo Contrato para Inadimplentes', LiberarNovoContratoParaInadimplente],
                  ['Manipular Dados das Pessoas', ManipularDadosDasPessoas],
                  ['Acessar Dependentes', Dependentes, [
                      ['Manipular Dados dos Dependentes', ManipularDadosDosDependentes]
                    ]],
                ]],
              ['Acessar Usuários', Usuarios, [
                  ['Manipular Dados dos Usuários', ManipularDadosDosUsuarios],
                ]],
              ['Acessar Localidades', Localidades, [
                  ['Manipular Dados das Localidades', ManipularDadosDasLocalidades],
                ]],
              ['Acessar Perfis de Acesso', PerfisDeAcesso, [
                  ['Manipular Perfis de Acesso', ManipularPerfisDeAcesso],
                ]],
            ]],
        ]],

      ['Estornos', nil, [
        ['Lançar Estorno de Movimento', LancarEstornoMovimentos]
      ]],

      ['Utilitários', nil, [
          ['Acessar Parâmetro Conta/Valor', ParametroContaValor, [
              ['Manipular Dados de Parametro Conta/Valores', ManipularDadosDeParametroContaValores],
            ]],
          ['Alterar Ano', AlterarAno],
          ['Alterar Unidade', AlterarUnidade],
          ['Acessar Configuração', Configuracao, [
              ['Manipular Dados de Configuração', ManipularDadosDeConfiguracao],
              ['Liberar Movimentos Simples que Excederam o Tempo Limite Permitido', LiberarContratoPeloDrMovimento],
              ['Liberar Pagamentos de Conta que Excederam o Tempo Limite Permitido', LiberarContratoPeloDrPagamentoDeConta],
              ['Liberar Recebimentos de Conta que Excederam o Tempo Limite Permitido', LiberarContratoPeloDrRecebimentoDeConta],
            ]],
          ['Acessar Plano de Contas', PlanoDeContas, [
              ['Manipular Dados do Plano de Contas', ManipularDadosDoPlanoDeContas],
            ]],
          ['Bloquear Ordens', BloquearOrdens],
          ['Realizar Exportação para o Zeus', RealizarExportacaoZeus],
          ['Realizar Importação do Zeus', RealizarImportacaoZeus],
          ['Acessar De-para/Entre anos do Orçamento', DeParaEntreAnosDoOrcamento],

        ]],
      ['Acessar Parcelas', Parcelas, [
          ['Manipular Dados das Parcelas', ManipularDadosDasParcelas],
        ]],
      ['Auditoria', Auditoria],
      #      ['Vizualizar Menu Financeiro', MenuFinanceiro],
      #      ['Alterar Ano/Unidade', AlterarAnoUnidade],
      #      ['Acessar Parametro Conta/Valores', ParametroContaValores],
      #      ['Acessar Itens Movimentos', ItensMovimentos],
      #      ['Manipular Dados dos Itens Movimentos', ManipularDadosDosItensMovimentos],
      #      ['Vizualizar Menu Geral', MenuGerais],
    ]
  end

end
