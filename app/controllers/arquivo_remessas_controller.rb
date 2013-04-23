class ArquivoRemessasController < ApplicationController

  PERMISSOES = {
    CUD => Perfil::ManipularArquivoRemessa,
    'any' => Perfil::ArquivoRemessa,
    'gerar' => Perfil::GerarArquivoRemessa
  }

  def index
    if params[:busca].blank?
      @arquivo_remessas = ArquivoRemessa.all :limit => 10
    else
      @arquivo_remessas = ArquivoRemessa.pesquisa(params[:busca])
    end
  end

  def show
    @arquivo_remessa = ArquivoRemessa.find(params[:id])
  end

  def new
    @arquivo_remessa = ArquivoRemessa.new
    @busca = {}
  end

  def edit
    @busca = {}
    @arquivo_remessa = ArquivoRemessa.find(params[:id])
    @parcelas = @arquivo_remessa.parcelas.group_by(&:conta)
  end

  def create
    @arquivo_remessa = ArquivoRemessa.new(params[:arquivo_remessa])
    @arquivo_remessa.unidade_id = session[:unidade_id]
    retorno = @arquivo_remessa.valida_arquivo
    if retorno.first
      @arquivo_remessa.save
      flash[:notice] = 'Arquivo de Remessa criado com sucesso!'
      redirect_to(@arquivo_remessa)
    else
      flash.now[:notice] = "Os seguintes erros foram encontrados: \n\n #{retorno.last.join("\n")}"
      @busca = params[:busca]
      @parcelas = ParcelaPagamentoDeConta.pesquisar_parcelas(:all, session[:unidade_id], params[:busca], params[:arquivo_remessa][:parcelas_ids])
      render :action => "new"
    end
  end

  def update
    @arquivo_remessa = ArquivoRemessa.find(params[:id])
    @arquivo_remessa.unidade_id = session[:unidade_id]
    retorno = @arquivo_remessa.valida_arquivo
    if retorno.first
      @arquivo_remessa.update_attributes(params[:arquivo_remessa])
      flash[:notice] = 'Arquivo de Remessa alterado com sucesso!'
      redirect_to(@arquivo_remessa)
    else
      flash[:notice] = "Os seguintes erros foram encontrados: \n\n #{retorno.last.join("\n")}"
      @busca = params[:busca]
      @parcelas = ParcelaPagamentoDeConta.pesquisar_parcelas(:all, session[:unidade_id], params[:busca], params[:arquivo_remessa][:parcelas_ids])
      render :action => "edit"
    end
  end

  def destroy
    @arquivo_remessa = ArquivoRemessa.find(params[:id])
    @arquivo_remessa.destroy
    redirect_to(arquivo_remessas_url)
  end

  def pesquisa_parcelas
    params[:busca] ||= {:data_inicial => Date.today.to_s_br, :data_final => Date.today.to_s_br}
    carregar_parcelas = lambda do |contar_ou_retornar|
      @parcelas = ParcelaPagamentoDeConta.pesquisar_parcelas(contar_ou_retornar, session[:unidade_id], params[:busca], params[:arquivo_remessa][:parcelas_ids])
    end
    carregar_parcelas.call :all
    render :update do |page|
      if @parcelas.blank?
        page.replace 'resultado_pesquisa_remessa', :text => "<tbody id=\"resultado_pesquisa_remessa\"></tbody>"
        page.alert "Não foram encontrados registros com estes parâmetros."
      else
        ids = params[:arquivo_remessa][:parcelas_ids].blank? ? [] : params[:arquivo_remessa][:parcelas_ids].collect { |id| id.to_i }
        page.replace_html('resultado_pesquisa_remessa', :partial => 'form_table', :locals => {:checked_parcelas_dis => ids, :parcelas => @parcelas})
      end
    end
  end

  def gerar
    respond_to do |format|
      format.html do
        @arquivo_remessa = ArquivoRemessa.find(params[:id])
        send_data(@arquivo_remessa.gerar, :type => "text/plain", :filename => "#{@arquivo_remessa.nome_arquivo}.txt")
      end
      format.js do
        render :update do |page|
          @arquivo_remessa = ArquivoRemessa.find(params[:id])
          retorno = @arquivo_remessa.pode_gerar?
          unless retorno.first
            page.alert("Os seguintes erros foram encontrados: \n\n #{retorno.last.join("\n")}")
          else
            page.new_window_to :format => 'html', :id => params[:id]
            page.reload
          end
        end
      end
    end
  end

  def valida_parcela
    @parcela = Parcela.find(params[:id])
    erros = ArquivoRemessa.objects_valid?(@parcela, ArquivoRemessa::PARCELA_FIELDS_VALIDS)
    erros = ArquivoRemessa.erros_to_hash(erros)
    urls = []
    erros.each do |classe, campo|
      case classe
      when "Pessoa"
          urls << edit_pessoa_path(@parcela.conta.pessoa)
      when "Agencia"
          urls << edit_agencia_path(@parcela.conta.pessoa.agencia)
      when "Localidade"
          urls << edit_localidade_path(@parcela.conta.pessoa.localidade)
      end
    end
    mensagem = ArquivoRemessa.monta_mensagem(erros)
    urls = "['#{urls.join("','")}']"
    id = "par_#{@parcela.conta.id}_#{@parcela.id}"
    render :update do |page|
      unless mensagem.blank?
        page << "validarParcelaPessoa('#{escape_javascript mensagem.join("\n")}', '#{id}', #{urls})"
      end
    end
  end

  def upload
    @file = ArquivoRemessa.new
    unless params[:file].blank?
      @file = ArquivoRemessa.read(params[:file])
      retorno = @file.layout_valid?
      unless retorno.first
        flash.now[:notice] = retorno.last
        @file = ArquivoRemessa.new
      end
    end
    unless params[:id].blank?
      file = File.open("public/arquivo_remessa/file_#{params[:id]}.txt")
      @file = ArquivoRemessa.read(file)
      retorno = @file.layout_valid?
      unless retorno.first
        flash.now[:notice] = retorno.last
        @file = ArquivoRemessa.new
      end
    end
  end

  def baixar
    @file = ArquivoRemessa.find(params[:id])
    retorno = @file.baixar(session[:ano], current_usuario, params[:arquivo_remessa])
    if retorno.first
      flash[:notice] = 'Parcelas baixadas com sucesso!'
      redirect_to arquivo_remessas_url
    else
      flash[:notice] = retorno.last.join("\n")
      render :action => "upload"
    end
  end
end
