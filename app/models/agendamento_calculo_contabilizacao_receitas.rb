class AgendamentoCalculoContabilizacaoReceitas < ActiveRecord::Base
  belongs_to :usuario
  belongs_to :unidade

  #Status
  ACTIVE = 1
  EXECUTED = 2

  validates_presence_of :ano
  validates_presence_of :mes
  validates_presence_of :unidade_id
  validates_presence_of :usuario_id
  
  HUMANIZED_ATTRIBUTES = {}

  def self.find_to_execute
    now = Time.now.strftime('%H%M').to_i
    now += 2400 if now < 400

    unidades = Unidade.find(:all, :conditions => ["((#{now} - ISNULL(hora_execussao_calculos_pesados, 0)) BETWEEN 0 AND 400)"])
    unidades_ids = unidades.collect { |e| e.id }
    return [] if(unidades_ids.blank?)

    AgendamentoCalculoContabilizacaoReceitas.find(:all, :conditions => ["status = ? AND unidade_id IN (#{unidades_ids.join(",")})", ACTIVE])
  end

  def before_create
    self.status = ACTIVE if self.status.nil?
  end
  
  def calcular
    params = {'ano' => self.ano, 'mes' => self.mes}
    begin
      @recebimento_de_contas = RecebimentoDeConta.pesquisa_para_analise_de_contrato(self.unidade_id, params, true)
      @recebimento_de_contas_com_reajuste = @recebimento_de_contas.clone
    
      n_contratos = @recebimento_de_contas.length
      if n_contratos > 0
        retorno = RecebimentoDeConta.calcular_proporcao(@recebimento_de_contas, self.historico, params)
        RecebimentoDeConta.contabilizacao_reajuste(@recebimento_de_contas_com_reajuste, self.historico, params)
        if retorno.first
          contrato = retorno[2] > 1 ? 'contratos' : 'contrato'
          parcela = retorno[1] > 1 ? 'parcelas' : 'parcela'
          @resultado = "Proporção calculada com sucesso em #{retorno[2]} #{contrato} em um total de #{retorno[1]} #{parcela}"
        else
          @resultado = retorno.last
        end
      else
        @resultado = 'Nenhum contrato encontrado.'
      end
    rescue Exception => e
      @resultado = e.message
    end

    self.update_attributes({:resultado => @resultado, :status => EXECUTED})
  end

  @@run = true
  def self.thread_process_running?
    if File.exists? 'tmp/calculo_contabilizacao_receitas_last_execution'
      file = File.new("tmp/calculo_contabilizacao_receitas_last_execution", "r")
      timeint = file.readline.to_i
      file.close
      ((Time.now.to_i - timeint) < 1300)
    else
      false
    end
  end

  def self.thread_stop
    @@run = false
  end

  def self.thread_stopped?
    !@@run
  end

  def self.thread_start
    @@run = true
    unless self.thread_process_running?
      IO.popen "ruby #{Dir.pwd}/script/runner #{Dir.pwd}/batch/calculo_contabilizacao_receitas.rb"
    end
  end
end
