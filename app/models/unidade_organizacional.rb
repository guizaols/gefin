class UnidadeOrganizacional < ActiveRecord::Base
  include ObjetoRastreavelEntreAnos

  acts_as_audited

  #RELACIONAMENTOS
  belongs_to :entidade
  has_many :unidade
  has_many :pagamento_de_contas
  has_many :rateios
  has_and_belongs_to_many :centros
  has_many :parcelas,:foreign_key=>"unidade_organizacional_desconto_id"
  has_many :parcelas,:foreign_key=>"unidade_organizacional_outros_id"
  has_many :parcelas,:foreign_key=>"unidade_organizacional_juros_id"
  has_many :parcelas,:foreign_key=>"unidade_organizacional_multa_id"
  
  
  def resumo
    "#{codigo_da_unidade_organizacional} - #{ Iconv.conv('iso-8859-15','utf-8',nome)}"
  end

  def self.importar_unidades_organizacionais(str)
    UnidadeOrganizacional.transaction do
      entidades = {}
      contador = 0
      conversao = Iconv.conv('UTF-8', 'ISO-8859-15', str.read)
      conversao.each_line do |line|
        if line.match %r{^(\d+);(\d+);"(\d+)";"(.*)";"([\d\s]+)";(\d+);\r?$}
          entidades[$2] ||= Entidade.find_by_codigo_zeus($2).id
#          u = UnidadeOrganizacional.find_or_initialize_by_ano_and_entidade_id_and_codigo_da_unidade_organizacional :ano => $1,
#            :entidade_id => entidades[$2], :codigo_da_unidade_organizacional => $3, :nome => $4, :codigo_reduzido => $5.strip
#          u.save!
          u = UnidadeOrganizacional.find_or_initialize_by_ano_and_entidade_id_and_codigo_da_unidade_organizacional($1, entidades[$2], $3)
          if(!u.blank?)
						u.ano = $1
						u.entidade_id = entidades[$2]
						u.codigo_da_unidade_organizacional = $3
						u.nome = $4
            u.codigo_reduzido = $5.strip
						u.save!
					else
						x = Centro.new
						x.ano = $1
						x.entidade_id = entidades[$2]
						x.codigo_da_unidade_organizacional = $3
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
        [true, "Foram importadas #{contador} unidades organizacionais!"]
      end
    end
  end

end