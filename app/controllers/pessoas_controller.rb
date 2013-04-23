class PessoasController < ApplicationController

  #  NAO_PASSA_POR_PERMISSAO = [:auto_complete_for_funcionario, :auto_complete_for_cliente,
  #    :auto_complete_for_fornecedor, :auto_complete_for_dependente, :auto_complete_for_pessoa]

  PERMISSOES = {
    CUD => Perfil::ManipularDadosDasPessoas,
    'any' => Perfil::Pessoas,
    'update_liberado_pelo_dr' => Perfil::LiberarNovoContratoParaInadimplente
  }

  before_filter :so_pode_alterar_pessoas_desta_entidade#, :except => [:verifica_se_existe_cpf_cnpj]
  skip_filter :verica_se_usuario_tem_permissao, :only => [:auto_complete_for_funcionario, :auto_complete_for_cliente,
    :auto_complete_for_fornecedor, :auto_complete_for_dependente, :auto_complete_for_pessoa]

  def index
    params[:busca] ||= {}
    params[:busca][:tipo] ||= {:pessoa_fisica => '1', :pessoa_juridica => '1'}
    @entidade = @unidade.entidade.id
    @pessoas = Pessoa.procurar_pessoas(params[:busca], @entidade, params[:page])
  end

  def funcionarios
    params[:busca] ||= {}
    params[:busca][:tipo] ||= {:pessoa_fisica => '1', :pessoa_juridica => '1'}
    @pessoas = Pessoa.procurar_funcionarios(params[:busca], @unidade.id, params[:page])
  end
  
  def show
    @dependentes = @pessoa.dependentes
  end

  def new
    @pessoa = Pessoa.new
  end

  def edit
  end

  def create
    @pessoa = Pessoa.new(params[:pessoa])
    @pessoa.entidade_id = @unidade.entidade_id
    @pessoa.unidade_id = @unidade.id
    
    if @pessoa.save
      flash[:notice] = 'Pessoa cadastrada com sucesso.'
      redirect_to pessoa_path(@pessoa)
    else
      render :action => "new"
    end
  end
  
  def update
    if @pessoa.update_attributes(params[:pessoa])
      flash[:notice] = 'Pessoa atualizada com sucesso.'
      redirect_to pessoa_path(@pessoa)
    else
      render :action => "edit"
    end
  end

  def update_liberado_pelo_dr
    @pessoa = Pessoa.find params[:id]
    render :update do |page|
      @pessoa.update_attribute(:liberado_pelo_dr, !@pessoa.liberado_pelo_dr)
      @pessoa.update_attribute(:liberado_por,(@current_usuario.funcionario.nome rescue nil) )
        @pessoa.update_attribute(:data_hora_liberacao_dr,(DateTime.now rescue nil) )
      page.replace_html('situacao_dr', :text => link_to_remote(@pessoa.liberado_pelo_dr ? 'Clique aqui para Restringir esse Cliente' : 'Clique aqui para Liberar esse Cliente', :url => {:action => 'update_liberado_pelo_dr'}, :with => "'id=#{@pessoa.id}'"))
    end
  end

  def destroy
    @pessoa = Pessoa.find(params[:id])
    if @pessoa.destroy
      flash[:notice] = 'Pessoa excluída com sucesso!'
    else
      flash[:notice] = @pessoa.mensagem_de_erro
    end
    redirect_to pessoas_path
  end

  def verifica_se_existe_cpf_cnpj
    @pessoas = Pessoa.retorna_cpf_cnpj_encontrado(params)

    render :update do |page|
      unless @pessoas.blank?
        page << "if (confirm ('CUIDADO! #{@pessoas.first.fisica? ? @pessoas.first.nome.upcase : @pessoas.first.razao_social.upcase} já está em nossa base de dados, para evitar duplicações deseja acessar o cadastro deste?')){"
        page.redirect_to(:action => 'edit',:id=>@pessoas.first.id)
        page << "}"
      end
    end
  end

  def auto_complete_for_funcionario
    @pessoas = Pessoa.all :conditions => ['(entidade_id = ?) AND (nome like ?) AND (funcionario = ?)', @unidade.entidade_id, params[:argumento].formatar_para_like, true], :limit => 100, :select => 'id, nome'
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=\"#{c.id}\">#{c.nome}</li>"}.join + '</ul>'
  end

  def auto_complete_for_cliente
    @pessoas = Pessoa.all :conditions => ['((razao_social LIKE ?) OR (nome LIKE ?)) AND (cliente = ?)', params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, true], :limit => 100, :select => 'id, tipo_pessoa, cpf, cnpj, nome, razao_social'
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=#{c.id}>#{c.tipo_pessoa == Pessoa::FISICA ? c.cpf : c.cnpj} -#{c.tipo_pessoa == Pessoa::FISICA ? c.nome : c.razao_social }</li>"}.join + '</ul>'
  end

  def auto_complete_for_cliente_cpf_cnpj
    @pessoas = Pessoa.all :conditions => ['((razao_social LIKE ?) OR (nome LIKE ?) OR (cpf LIKE ?) OR (cnpj LIKE ?)) AND (cliente = ?)', params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, true], :limit => 100, :select => 'id, tipo_pessoa, cpf, cnpj, nome, razao_social'
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=#{c.id}>#{c.tipo_pessoa == Pessoa::FISICA ? c.cpf : c.cnpj} - #{c.tipo_pessoa == Pessoa::FISICA ? c.nome : c.razao_social }</li>"}.join + '</ul>'
  end
  
  def auto_complete_for_fornecedor
    @pessoas = Pessoa.all :conditions => ['((nome like ?) OR (razao_social LIKE ?)) AND (fornecedor = ?)', params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, true], :limit => 100, :select => 'id, nome, razao_social'
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=\"#{c.id}\">#{c.tipo_pessoa == Pessoa::FISICA ? c.nome : c.razao_social }</li>"}.join + '</ul>'
  end

  def auto_complete_for_fornecedor_cpf_cnpj
    @pessoas = Pessoa.find(:all,:conditions => ['((nome like ?) OR (cnpj like ?) OR (cpf like ?) OR (razao_social LIKE ?)) AND (fornecedor = ?)', params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, true], :limit => 100, :select => 'id, nome, tipo_pessoa, cpf, cnpj, razao_social')
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=\"#{c.id}\">#{c.tipo_pessoa == Pessoa::FISICA ? c.cpf : c.cnpj} - #{c.tipo_pessoa == Pessoa::FISICA ? c.nome : c.razao_social }</li>"}.join + '</ul>'
  end

  def auto_complete_for_dependente
    @pessoas = Dependente.all:conditions => ["(nome LIKE ?) AND (pessoa_id = ?)",
      params[:argumento].formatar_para_like, params[:cliente_id].to_i], :select => 'id, nome'
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=#{c.id}>#{c.nome}</li>"}.join + '</ul>'
  end

  def auto_complete_for_pessoa
    find_options = {
      :conditions => [ "(LOWER(nome) LIKE ?) OR (LOWER(cpf) LIKE ?) OR (LOWER(cnpj) LIKE ?) OR (LOWER(razao_social) LIKE ?)", params[:argumento].formatar_para_like,
        params[:argumento].formatar_para_like, params[:argumento].formatar_para_like, params[:argumento].formatar_para_like],
      :limit => 100, :select => 'id, tipo_pessoa, cpf, cnpj, nome, razao_social' }

    @items = Pessoa.find(:all, find_options)
    render :text =>'<ul>' + @items.collect{|c| "<li id=#{c.id}>#{c.tipo_pessoa == Pessoa::FISICA ? c.cpf : c.cnpj} - #{c.tipo_pessoa == Pessoa::FISICA ? c.nome : c.razao_social }</li>"}.join + '</ul>'
  end

  def auto_complete_for_funcionario_para_audit
    @pessoas = Pessoa.all :include => [:usuario],
      :conditions => ['(pessoas.entidade_id = ?) AND (pessoas.nome LIKE ?) AND (pessoas.funcionario = ?) AND (usuarios.funcionario_id IS NOT NULL)',
      @unidade.entidade_id, params[:argumento].formatar_para_like, true], :limit => 100, :select => 'usuarios.id, pessoas.nome'
    render :text =>'<ul>' + @pessoas.collect{|c| "<li id=\"#{c.usuario.id}\">#{c.nome}</li>"}.join + '</ul>'
  end

  def importar_clientes
    unless params[:commit].blank?
      unless params[:file].blank?
        if (File.extname(params[:file].original_filename) == ".xml")
          retorno = Pessoa.importar_clientes(params[:file], session[:unidade_id])
          if retorno
            mensagem = "* #{retorno.first} cliente foi importado para o sistema. \n" unless retorno.first > 1
            mensagem = "* #{retorno.first} clientes foram importados para o sistema. \n" if retorno.first > 1
            unless retorno.last == 0
              mensagem << "* #{retorno.last} cliente não foi importado. Favor olhar o arquivo de Log." unless retorno.last > 1
              mensagem << "* #{retorno.last} clientes não foram importados. Favor olhar o arquivo de Log." if retorno.last > 1
            end
            flash[:notice] = mensagem
            redirect_to pessoas_path
          else
            flash.now[:notice] = "Arquivo Invalido!"
          end
        else
          flash.now[:notice] = "Tipo de Arquivo invalido!"
        end
      else
        flash.now[:notice] = "Selecione um Arquivo!"
      end
    end
  end

  private

  def so_pode_alterar_pessoas_desta_entidade
    @unidade = Unidade.find session[:unidade_id]
    if params[:id]
      @pessoa = Pessoa.find params[:id]
      #      if @pessoa.entidade_id != @unidade.entidade_id && @pessoa.cliente == false && @pessoa.fornecedor == false
      #        flash[:notice] = 'Essa Pessoa pertence a outra entidade.'
      #        redirect_to login_path
      #      end
    end
  end

end
