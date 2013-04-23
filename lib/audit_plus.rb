class Audit
  extend BuscaExtendida

  def self.criar_audit(usuario, titulo, unidade_id, tipo)
    Audit.create(:user_id => usuario, :unidade_id => unidade_id, :auditable_type => "Relatório #{titulo.titleize} " + (tipo.blank? ? '' : tipo.upcase),
      :action => 'relatorio', :changes => {"descrição" => ["Relatório #{titulo.titleize}" + (tipo.blank? ? '' : " em #{tipo.upcase}") + " emitido."]
      })
  end

  def changes_verbose
    changes_dup = changes.dup
    changes_dup.reject! {|campo, valores| (campo == 'updated_at') }
    changes_dup.collect do |campo, valores|
      valores ||= []
      valores = [valores] if valores.is_a? String
      valores = valores.to_a
      unless valores.all?(&:blank?)
        valores.collect! {|valor| valor == true ? 'Sim' : valor == false ? 'Não' : valor.to_s.gsub(%r{[\n\r]+}, ', ')}
        case
        when campo == 'unidade_id';                     valores.collect! {|item| Unidade.find(item).nome rescue '' }
        when campo == 'tipo';                           valores.collect! {|item| item == 'D' ? 'Débito' : 'Crédito' rescue '' }
        when campo == 'conta_type';                     campo = 'Tipo de Conta'
        when campo == 'vigencia';                       campo = 'Vigência'
        when campo == 'situacao';                       campo = 'Situação'; valores.collect! {|item| item rescue '' }
        when campo.include?('data');                    valores.collect! {|item| item.to_date.to_s_br rescue '' }
        when campo.include?('pessoa');                  valores.collect! {|item| Pessoa.find(item).nome rescue '' }
        when campo.include?('funcionario');             valores.collect! {|item| Pessoa.find(item).nome rescue '' }
        when campo.include?('cobrador');                valores.collect! {|item| Pessoa.find(item).nome rescue '' }
        when campo.include?('vendedor');                valores.collect! {|item| Pessoa.find(item).nome rescue '' }
        when campo.include?('servico_id');              valores.collect! {|item| Servico.find(item).descricao rescue '' }
        when campo.include?('valor');                   valores.collect! {|item| Dinheiro.new(item.to_i/100).real_contabil unless item.blank? rescue '' }
        when campo.include?('movimento');               valores.collect! {|item| "ID - #{item}" rescue '' }
        when campo.include?('parcela_id');              valores.collect! {|item| "ID - #{item}" rescue '' }
        when campo.include?('conta') && campo != 'conta_type'; valores.collect! {|item| "ID - #{item}" rescue '' }
        when campo.include?('tipo_lancamento');         valores.collect! {|item| item.to_s == 'E' ? 'Entrada' : 'Saída' rescue '' }
        when campo.include?('servico_iniciado');        valores.collect! {|item| item.to_s == 'true' ? 'Sim' : 'Não' rescue '' }
        when campo.include?('rateio');                  valores.collect! {|item| item.to_i == 1 ? 'Sim' : 'Não' rescue '' }
        when campo.include?('origem');                  valores.collect! {|item| item.to_i == 0 ? 'Interna' : 'Externa' rescue '' }
        when campo.include?('juros_por_atraso');        valores.collect! {|item| item + " %" rescue '' }
        when campo.include?('multa_por_atraso');        valores.collect! {|item| item + " %" rescue '' }
        when campo.include?('fiemt');                   valores.collect! {|item| retorna_situacao_fiemt_verbose(item.to_i) rescue '' }
        when campo.include?('provisao');                valores.collect! {|item| item.to_i == 1 ? 'Sim' : 'Não' rescue '' }
        when campo.include?('centro');                  valores.collect! {|item| "#{Centro.find(item).codigo_centro} - #{Centro.find(item).nome}" rescue '' }
        when campo.include?('conta_contabil');          valores.collect! {|item| "#{PlanoDeConta.find(item).codigo_contabil} - #{PlanoDeConta.find(item).nome}" rescue '' }
        when campo.include?('plano_de_conta');          valores.collect! {|item| "#{PlanoDeConta.find(item).codigo_contabil} - #{PlanoDeConta.find(item).nome}" rescue '' }
        when campo.include?('unidade_organizacional');  valores.collect! {|item| "#{UnidadeOrganizacional.find(item).codigo_da_unidade_organizacional} - #{UnidadeOrganizacional.find(item).nome}" rescue '' }
        when campo.include?('crypted_password');        campo = 'Senha'
        end
        "#{campo.humanize.titleize}: \n#{ valores.join ' => ' }"
      end
    end.compact.join "\n\n"
  rescue
    ''
  end
 
  def self.procurar_auditorias(unidade_id, params, tabela, page = nil)
    @sqls = []
    @variaveis = []

    @sqls << '(unidade_id = ?)'
    @variaveis << unidade_id
    
    unless tabela.blank?
      @sqls << '(auditable_type = ?)'
      @variaveis << tabela
    end

    preencher_array_para_campo_com_auto_complete params, :funcionario, 'user_id'
    preencher_array_para_buscar_por_faixa_de_datas params, :periodo, 'created_at'
    
    paginate(:all, :conditions => [@sqls.join(' AND ')] + @variaveis, :order => 'created_at DESC', :page => page, :per_page => 20)
  end

  def retorna_situacao_fiemt_verbose(situacao)
    situacao_fiemt_verbose = case situacao
    when nil; 'Evadido'
    when RecebimentoDeConta::Normal; 'Normal'
    when RecebimentoDeConta::Juridico; 'Jurídico'
    when RecebimentoDeConta::Renegociado; 'Renegociado'
    when RecebimentoDeConta::Inativo; 'Inativo'
    when RecebimentoDeConta::Permuta; 'Permuta'
    when RecebimentoDeConta::Baixa_do_conselho; 'Baixa do Conselho'
    when RecebimentoDeConta::Desconto_em_folha; 'Desconto em Folha'
    when RecebimentoDeConta::Enviado_ao_DR; 'Enviado ao DR'
    when RecebimentoDeConta::Devedores_Duvidosos_Ativos; 'Perdas no Recebimento de Creditos - Clientes'
    end
    situacao_fiemt_verbose
  end


  
  #  def self.identificar_model(campo, valor1)
  #    valor = case campo
  #    when 'usuario_id',
  #        'usuario_que_reservou_id',
  #        'usuario_que_emprestou_id';   Usuario.find(valor1).nome
  #    when 'tipo_de_material_id';        TipoDeMaterial.find(valor1).nome
  #    when 'biblioteca_id';              Biblioteca.find(valor1).nome
  #    else valor1
  #    end
  #    case valor.to_s
  #    when 'true'; 'SIM'
  #    when 'false'; 'NÃO'
  #    else valor.to_s
  #    end
  #  rescue
  #    valor1
  #  end

end