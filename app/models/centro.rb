class Centro < ActiveRecord::Base

  include ObjetoRastreavelEntreAnos

  acts_as_audited

  #VALIDAÇÕES
  validates_presence_of :entidade, :message => 'é inválido.'

  #RELACIONAMENTOS
  belongs_to :entidade
  has_and_belongs_to_many :unidade_organizacionais
  has_many :pagamento_de_contas  
  has_many :rateios  
  has_many :parcelas, :foreign_key => "centro_desconto_id"
  has_many :parcelas, :foreign_key => "centro_outros_id"
  has_many :parcelas, :foreign_key => "centro_juros_id"
  has_many :parcelas, :foreign_key => "centro_multa_id"

  #CONSTANTES
  HUMANIZED_ATTRIBUTES = { :entidade => 'O campo entidade' }

  
  def resumo
    "#{codigo_centro} - #{nome}"
  end

  def self.importar_centros(str)
    Centro.transaction do
      entidades = {}
      contador = 0
      conversao = Iconv.conv('UTF-8', 'ISO-8859-15', str.read)
      conversao.each_line do |line|
        if line.match %r{^(\d+);(\d+);"(\d+)";"(.+)";"(\d+)";\d+\r?$}
          entidades[$2] ||= Entidade.find_by_codigo_zeus($2).id
#          u = Centro.find_or_initialize_by_ano_and_entidade_id_and_codigo_centro :ano => $1,
#            :entidade_id => entidades[$2], :codigo_centro => $3, :nome => $4, :codigo_reduzido => $5.strip
          u = Centro.find_by_ano_and_entidade_id_and_codigo_centro($1, entidades[$2], $3)
          if(!u.blank?)
						u.ano = $1
						u.entidade_id = entidades[$2]
						u.codigo_centro = $3
						u.nome = $4
            u.codigo_reduzido = $5.strip
						u.save!
					else
						x = Centro.new
						x.ano = $1
						x.entidade_id = entidades[$2]
						x.codigo_centro = $3
						x.nome = $4
						x.codigo_reduzido = $5.strip
						x.save!
					end
          contador += 1
        end
      end
      if contador == 0
        [false, "Importação não realizada. Verifique o arquivo enviado!"]
      else
        [true, "Foram importados #{contador} Centros!"]
      end
    end
  end

  def self.importar_relacionamentos_entre_centros_e_unidades_organizacionais(str)
    Centro.transaction do
      entidades = {}
      contador = 0
      conversao = Iconv.conv('UTF-8', 'ISO-8859-15', str.read)
      conversao.each_line do |line|
        if line.match %r{^(\d+);(\d+);"(\d+)";"(\d+)";"(\d+)"\r?$}
          entidades[$2] ||= Entidade.find_by_codigo_zeus($2).id
          if c = Centro.find_by_ano_and_entidade_id_and_codigo_centro($1, entidades[$2], $4)
            u = UnidadeOrganizacional.find_by_ano_and_entidade_id_and_codigo_da_unidade_organizacional $1, entidades[$2], $3
            c.unidade_organizacionais << u unless c.unidade_organizacionais.include?(u)
            c.save!
          end
          contador += 1
        end
      end
      if contador == 0
        [false, "Importação não realizada. Verifique o arquivo enviado!"]
      else
        [true, "Foram importados #{contador} Unidades Organizacionais x Centros!"]
      end
    end
  end

end
