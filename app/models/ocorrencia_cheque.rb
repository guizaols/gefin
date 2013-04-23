class OcorrenciaCheque < ActiveRecord::Base

  acts_as_audited
   
  #CONSTANTES
  HUMANIZED_ATTRIBUTES = {:cheque =>"O campo cheque",:data_do_evento=>"O campo data do evento",
    :tipo_da_ocorrencia=>"O campo tipo da ocorrência",:historico=>"O campo histórico",
    :alinea => "O campo alínea"
  }

  ALINEAS = [["11 - Insuficiência de fundos 1ª apresentação",11],
    ["12 - Insuficiência de fundos 2ª apresentação",12],
    ["13 - Conta encerrada",13],
    ["14 - Prática espúria (Compromisso de Pronto Acolhimento)",14],
    ["21 - Contra-ordem ou oposição ao pagamento",21],
    ["22 - Divergência ou insuficiência da assinatura",22],
    ["23 - Cheques de órgão da administração federal em desacordo com o Decreto-Lei nº 200",23],
    ["24 - Bloqueio judicial ou determinação do BACEN",24],
    ["25 - Cancelamento de talonário pelo banco sacado",25],
    ["26 - Inoperância temporária de transporte",26],
    ["28 - Contra-ordem ou oposição ao pagamento motivada por furto ou roubo",28],
    ["29 - Falta de confirmação do recebimento do talonário pelo correntista",29],
    ["30 - Furto ou roubo de malotes",30],
    ["31 - Erro formal de preenchimento",31],
    ["32 - Ausência ou irregularidade na aplicação do carimbo de compensação",32],
    ["27 - Feriado municipal não previsto",27],
    ["33 - Divergência de endosso",33],
    ["34 - Cheque apresentado por estabelecimento que não o indicado no cruzamenteo em preto",34],
    ["35 - Cheque fraudado",35],
    ["36 - Cheque emitido com mais de um endosso Lei nº 9.311/96",36],
    ["37 - Registro inconsistente CEL",37],
    ["40 - Moeda inválida",40],
    ["41 - Cheque apresentado a banco que não o sacado",41],
    ["42 - Cheque não compensável na sessão ou sistema de compensação em que apresentado e o recibo bancário trocado em sessão indevida.",42],
    ["43 - Cheque devolvido anteriormente pelos motivos 21",43],
    ["44 - Cheque prescrito",44],
    ["45 - Cheque emitido por entidade obrigada a emitir Ordem Bancária",45],
    ["46 - CR Comunicação de Remessa cujo cheque correspondente não for entregue no prazo devido ao banco remetente",46],
    ["47 - CR Comunicação de Remessa com ausência ou inconsistência de dados obrigatórios",47],
    ["48 - Cheque do valor superior a R$ 100,00",48],
    ["49 - Remessa nula",49]]

  easy_verbose({:alinea => ALINEAS}, {:if => Proc.new { |obj| obj.cheque && obj.cheque.situacao != 5 }})
  belongs_to :cheque
  validates_presence_of :cheque, :data_do_evento, :tipo_da_ocorrencia, :historico
  converte_para_data_para_formato_date :data_do_evento

  def tipo_da_ocorrencia_verbose
    case tipo_da_ocorrencia
    when Cheque::ENVIO_DR; 'Baixa de transferência para o DR'
    when Cheque::RENEGOCIACAO; 'Baixado'
    when Cheque::DEVOLUCAO; "Reapresentação de Cheque"
    end
  end

end
