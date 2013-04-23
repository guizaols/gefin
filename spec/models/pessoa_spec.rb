require File.dirname(__FILE__) + '/../spec_helper'


describe Pessoa do
  
  it 'deve identificar fisica ou juridica' do
    @pessoa = Pessoa.new
    @pessoa.fisica?.should == false
    @pessoa.juridica?.should == false
    @pessoa.tipo_pessoa = Pessoa::FISICA
    @pessoa.fisica?.should == true
    @pessoa.juridica?.should == false
    @pessoa.tipo_pessoa = Pessoa::JURIDICA
    @pessoa.fisica?.should == false
    @pessoa.juridica?.should == true
  end
    
  it "teste de validacao de presenca e consistencia no cpf" do
    @pessoa = pessoas(:paulo)
    @pessoa.cpf = nil
    @pessoa.should_not be_valid
    @pessoa.errors.on(:cpf).should == "deve ser preenchido"
    @pessoa.cpf = "1234"
    @pessoa.should_not be_valid
    @pessoa.errors.on(:cpf).should_not be_nil
  end
    
  it "teste de validacao de presenca e consistencia do cnpj" do
    @pessoa = pessoas(:inovare)
    @pessoa.cnpj = nil
    @pessoa.should_not be_valid
    @pessoa.errors.on(:cnpj).should == "deve ser preenchido"
    @pessoa.cnpj = "1234"
    @pessoa.should_not be_valid
    @pessoa.errors.on(:cnpj).should_not be_nil
  end
    
  it "verifica a máscara para cnpj para pessoa" do
    @pessoa = pessoas(:inovare)
    (@pessoa.cnpj.to_s).should == '08.916.988/0001-45'
  end
  
  it 'deve retornar dependente ou beneficiário se for PF ou PJ' do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA
    @pessoa.caption_dependente_beneficiario.should == 'Dependente'
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::JURIDICA
    @pessoa.caption_dependente_beneficiario.should == 'Beneficiário'
  end
  

  it 'deve desmarcar a caixa funcionário se for PJ' do
    @pessoa = Pessoa.new
    @pessoa.funcionario = true
    @pessoa.valid?
    @pessoa.funcionario?.should == true
    @pessoa.tipo_pessoa = Pessoa::JURIDICA
    @pessoa.valid?
    @pessoa.funcionario?.should == false
  end

  it 'deve retornar dependente ou beneficiário se for PF ou PJ' do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA
    @pessoa.caption_dependente_beneficiario.should == 'Dependente'
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::JURIDICA
    @pessoa.caption_dependente_beneficiario.should == 'Beneficiário'
  end
    
  it 'deve desmarcar a caixa funcionário se for PJ' do
    @pessoa = Pessoa.new
    @pessoa.funcionario = true
    @pessoa.valid?
    @pessoa.funcionario?.should == true
    @pessoa.tipo_pessoa = Pessoa::JURIDICA
    @pessoa.valid?
    @pessoa.funcionario?.should == false
  end

  
  it "teste de relacionamento" do
    pessoa = pessoas(:paulo)
    pessoa.dependentes.should == dependentes(:dependente_paulo_segundo,:dependente_paulo_primeiro)
    pessoa.localidade.should == localidades(:primeira)
    pessoa.entidade.should == entidades(:senai)
    pessoa_dois = pessoas(:felipe)
    pessoa_dois.usuario.should == usuarios(:quentin)
    pessoa = pessoas(:inovare)
    pessoa.banco.should == bancos(:banco_do_brasil)
    pessoa.agencia.should == agencias(:centro)
  end
  

  it "validar presenca dos campos" do
    @pessoa = Pessoa.new :cliente => true, :fornecedor => true, :funcionario => true
    @pessoa.should_not be_valid
    @pessoa.tipo_pessoa = 1
    @pessoa.valid?
    @pessoa.errors.on(:nome).should == "deve ser preenchido"
    @pessoa.errors.on(:tipo_pessoa).should be_nil
    @pessoa.tipo_pessoa = 2
    @pessoa.valid?
    @pessoa.errors.on(:nome).should be_nil
    @pessoa.errors.on(:tipo_pessoa).should be_nil
    @pessoa.tipo_pessoa = 3
    @pessoa.valid?
    @pessoa.errors.on(:tipo_pessoa).should == "deve ser selecionado"
    @pessoa.errors.on(:endereco).should_not be_nil
  end
   
  it "validar presenca dos campos nome e telefone se marcar a opção outros" do
    @pessoa = Pessoa.new :cliente => false, :fornecedor => false, :funcionario => false
    @pessoa.should_not be_valid
    @pessoa.errors.on(:nome).should be_nil
    @pessoa.tipo_pessoa = 1
    @pessoa.valid?
    @pessoa.errors.on(:nome).should == "deve ser preenchido"
    @pessoa.errors.on(:tipo_pessoa).should be_nil
    @pessoa.tipo_pessoa = 2
    @pessoa.valid?
    @pessoa.errors.on(:nome).should be_nil
    @pessoa.errors.on(:tipo_pessoa).should be_nil
    @pessoa.tipo_pessoa = 3
    @pessoa.valid?
    @pessoa.errors.on(:tipo_pessoa).should_not be_nil
    @pessoa.errors.on(:endereco).should_not be_nil
  end
    
  it "existe o campo virtual cidade_e_estado" do
    @pessoa = pessoas(:paulo)
    @pessoa.nome_localidade = "Varzea Grande - MT"
  end
    
  it "existe atributto virtual cidade_e_estado" do
    @pessoa = pessoas(:paulo)
    @pessoa.nome_localidade.should == "VARZEA GRANDE - MT"
  end
    
  it "apaga localidade quando vem string vazia no campo virtual cidade_e_estado" do
    @pessoa = pessoas(:paulo)
    @pessoa.localidade.should == localidades(:primeira)
    @pessoa.nome_localidade = ""
    @pessoa.save
    @pessoa.localidade_id.should == nil
  end
    
  it "nao apaga localidade quando vem nil no campo virtual cidade_e_estado" do
    @pessoa = pessoas(:paulo)
    @pessoa.localidade_id.should == localidades(:primeira).id
    @nome_localidade = nil
    @pessoa.save
    @pessoa.localidade_id.should == localidades(:primeira).id
  end
    
  it "não apaga localidade sem vem string diferente de vazia no cqampo virtual cidade_e_estado" do
    @pessoa  = pessoas(:paulo)
    @pessoa.localidade.should == localidades(:primeira)
    @pessoa.nome_localidade ="VARZEA GRANDE  - MT"
    @pessoa.save
    @pessoa.localidade.should == localidades(:primeira)
  end
  
  it "teste que verifica quando um objeto com ativo é igual a true" do
    @pessoa = Pessoa.new
    @pessoa.spc.should == false
    @pessoa = Pessoa.new :spc => true
    @pessoa.spc.should == true
  end
   
  describe 'Campo telefone ' do
      
    it "deve retornar um array" do
      @pessoa = Pessoa.new
      @pessoa.telefone.should == []
    end
  
    it "deve deletar telefones vazios" do
      @pessoa = Pessoa.new :telefone => ["33425712","",' ']
      @pessoa.valid?
      @pessoa.telefone.should == ["33425712"] 
    end
  end
    
  describe 'Campo Email' do
    it "deve retornar um array" do
      @pessoa = Pessoa.new
      @pessoa.email.should ==[]
    end
  
    it "deve deletar emails vazios" do
      @pessoa = Pessoa.new :email => ["teste@inovare.net",""]
      @pessoa.valid?
      @pessoa.email.should == ["teste@inovare.net"] 
    end
  end
    
    
  it "Retornar se o tipo da pessoa é fisica ou juridica" do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA
    @pessoa.label_do_campo_cpf_cnpj.should == "CPF"
    @pessoa.label_do_campo_rg_ie.should == "RG"    
    @pessoa.tipo_pessoa = Pessoa::JURIDICA
    @pessoa.label_do_campo_cpf_cnpj.should == " CNPJ"
    @pessoa.label_do_campo_rg_ie.should == "IE"
    @pessoa.tipo_pessoa = nil
    @pessoa.label_do_campo_cpf_cnpj.should == "CPF/CNPJ"
    @pessoa.label_do_campo_rg_ie.should == "RG/IE"
  end
  
  it 'deve exigir razão social quando for PJ' do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA
    @pessoa.valid?
    @pessoa.errors.on(:razao_social).should be_nil
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::JURIDICA
    @pessoa.valid?
    @pessoa.errors.on(:razao_social).should_not be_nil
  end
  
  it 'retorna label nome p/ pessoa fisica ou nome fantasia para pessoa juridica'do
    @pessoa = Pessoa.new :tipo_pessoa => 2
    @pessoa.label_nome_ou_nome_fantasia.should == " Nome Fantasia" 
    @pessoa.tipo_pessoa = 1
    @pessoa.label_nome_ou_nome_fantasia.should == " Nome" 
    @pessoa = Pessoa.new :tipo_pessoa => ""
    @pessoa.label_nome_ou_nome_fantasia.should == " Nome/Nome Fantasia"
  end  
  it "retorna tipo de pessoa(1=Pessoa física e 2=Pessoa jurídica)" do
    @pessoa = Pessoa.new :tipo_pessoa =>1
    @pessoa.retorna_tipo_pessoa.should == 'Pessoa física'
    @pessoa = Pessoa.new :tipo_pessoa =>2
    @pessoa.retorna_tipo_pessoa.should == 'Pessoa Jurídica'  
  end    
       
  it "Testa se existe o campo virtual novo_cargo" do
    @pessoa = Pessoa.new
    @pessoa.novo_cargo = 'Programador '
  end
  
  it "Testa se chama o metodo criar novo cargo" do
    @pessoa = Pessoa.new
    @pessoa.novo_cargo = 'Programador'
    @pessoa.valid?
    @pessoa.cargo.should == 'Programador'
    @pessoa.novo_cargo = ''
    @pessoa.valid?
    @pessoa.cargo.should == 'Programador'
  end
    

  
  it "Retornar se o tipo da pessoa é fisica ou juridica" do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA
    @pessoa.label_do_campo_cpf_cnpj.should == "CPF"
    @pessoa.label_do_campo_rg_ie.should == "RG"
    @pessoa.tipo_pessoa = Pessoa::JURIDICA
    @pessoa.label_do_campo_cpf_cnpj.should == " CNPJ"
    @pessoa.label_do_campo_rg_ie.should == "IE"
    @pessoa.tipo_pessoa = nil
    @pessoa.label_do_campo_cpf_cnpj.should == "CPF/CNPJ"
    @pessoa.label_do_campo_rg_ie.should == "RG/IE"
  end
  
  it 'deve exigir razão social quando for PJ' do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA
    @pessoa.valid?
    @pessoa.errors.on(:razao_social).should be_nil
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::JURIDICA
    @pessoa.valid?
    @pessoa.errors.on(:razao_social).should_not be_nil
  end
  
  it 'retorna label nome p/ pessoa fisica ou nome fantasia para pessoa juridica'do
    @pessoa = Pessoa.new :tipo_pessoa => 2
    @pessoa.label_nome_ou_nome_fantasia.should == " Nome Fantasia"
    @pessoa.tipo_pessoa = 1
    @pessoa.label_nome_ou_nome_fantasia.should == " Nome"
    @pessoa = Pessoa.new :tipo_pessoa => ""
    @pessoa.label_nome_ou_nome_fantasia.should == " Nome/Nome Fantasia"
  end

  
  
  it "retorna tipo de pessoa(1=Pessoa física e 2=Pessoa jurídica)" do
    @pessoa = Pessoa.new :tipo_pessoa =>1
    @pessoa.retorna_tipo_pessoa.should == 'Pessoa física'
    @pessoa = Pessoa.new :tipo_pessoa =>2
    @pessoa.retorna_tipo_pessoa.should == 'Pessoa Jurídica'
  end
    
    
  it "Testa se existe o campo virtual novo_cargo" do
    @pessoa = Pessoa.new
    @pessoa.novo_cargo = 'Programador '
  end
 
  it "Testa se chama o metodo criar novo cargo" do
    @pessoa = Pessoa.new
    @pessoa.novo_cargo = 'Programador'
    @pessoa.valid?
    @pessoa.cargo.should == 'Programador'
    @pessoa.novo_cargo = ''
    @pessoa.valid?
    @pessoa.cargo.should == 'Programador'
  end
  

  it "teste da pesquisa" do
    parametros = {"filtro"=>{"fornecedor"=>"fornecedor"},"conteudo" => "paulo"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[], false]
    parametros = {"filtro"=>{"fornecedor"=>"fornecedor"},"conteudo" => "paulo"}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).should == [[], false]
    parametros = {"filtro"=>{"cliente"=>"cliente"}, "conteudo"=>"paulo"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:paulo)], true]
    parametros = {"filtro"=>{"cliente"=>"cliente"}, "conteudo"=>"fabio"}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).should == [[pessoas(:fabio)], false]

    #Pesquisar somente por "termina em"
    parametros = {"filtro"=>{"cliente"=>"cliente"}, "conteudo"=>"paulo*"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:paulo)], true]
    parametros = {"filtro"=>{"cliente"=>"cliente"}, "conteudo"=>"fabio*"}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).should == [[pessoas(:fabio)], false]
    parametros = {"filtro"=>{"cliente"=>"cliente"}, "conteudo"=>"aulo*"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[], false]

    #Pesquisar somente por "começa com"
    parametros = {"filtro"=>{"funcionario"=>"funcionario"}, "conteudo"=>"*iotto"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:felipe)], false]
    parametros = {"filtro"=>{"funcionario"=>"funcionario"}, "conteudo"=>"*iott"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[], false]
    parametros = {"filtro"=>{"funcionario"=>"funcionario"}, "conteudo"=>"*gger"}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).should == [[pessoas(:fabio)], false]

    #Pesquisar com "Contenha"
    parametros = {"filtro"=>{"funcionario"=>"funcionario"}, "conteudo"=>"ipe"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:felipe)], false]
   
    #Pesquisar passando 'nil' no conteúdo
    parametros = {"tipo"=>{"pessoa_juridica"=>"pessoa_juridica","pessoa_fisica"=>"pessoa_fisica"},"conteudo"=>""}
    Pessoa.procurar_funcionarios(parametros, unidades(:senaivarzeagrande).id).should == [pessoas(:andre, :felipe, :guilherme, :jansen, :juan, :julio, :rafael), false]
    parametros = {"tipo"=>{"pessoa_juridica"=>"pessoa_juridica","pessoa_fisica"=>"pessoa_fisica"},"conteudo"=>""}
    Pessoa.procurar_funcionarios(parametros, unidades(:sesivarzeagrande).id).should == [[pessoas(:fabio)], false]

    parametros = {"filtro"=>{"cliente"=>"cliente"}}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [pessoas(:andre, :fabio, :guilherme, :jansen, :juan, :julio, :paulo, :rafael), true]
    parametros = {"filtro"=>{"cliente"=>"cliente"}}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).should == [pessoas(:andre, :fabio, :guilherme, :jansen, :juan, :julio, :paulo, :rafael), true]

    parametros = {"filtro"=>{"fornecedor"=>"fornecedor"}}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [pessoas(:fornecedor, :inovare), false]
    parametros = {"filtro"=>{"fornecedor"=>"fornecedor"}, "conteudo"=>"rafael"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:inovare)], false]
    parametros = {"tipo"=>{"pessoa_juridica"=>"pessoa_juridica"},"conteudo"=>""}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [pessoas(:fornecedor, :inovare), false]
    parametros = {"tipo"=>{"pessoa_juridica"=>"pessoa_juridica","pessoa_fisica"=>"pessoa_fisica"},"conteudo"=>""}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).first.length.should == 10
    parametros = {"tipo"=>{"pessoa_juridica"=>"pessoa_juridica","pessoa_fisica"=>"pessoa_fisica"},"conteudo"=>""}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).first.length.should == 10
     
    parametros = {"conteudo"=>"08.916"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:inovare)], false]
    parametros = {"filtro"=>{"cliente"=>"cliente", "fornecedor"=>"fornecedor",
        "funcionario"=>"funcionario"}, "tipo"=>{"pessoa_fisica"=>"pessoa_fisica",
        "pessoa_juridica"=>"pessoa_juridica"}, "conteudo"=>"pau"}
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [[pessoas(:paulo)], true]
    parametros = {"filtro"=>{"cliente"=>"cliente", "fornecedor"=>"fornecedor",
        "funcionario"=>"funcionario"}, "tipo"=>{"pessoa_fisica"=>"pessoa_fisica",
        "pessoa_juridica"=>"pessoa_juridica"}, "conteudo"=>"fab"}
    Pessoa.procurar_pessoas(parametros, entidades(:sesi).id).should == [[pessoas(:fabio)], false]
    parametros = {
        "filtro"=>{"cliente"=>"cliente", "fornecedor"=>"fornecedor"},
        "tipo"=>{"pessoa_fisica"=>"pessoa_fisica", "pessoa_juridica"=>"pessoa_juridica"},
        "conteudo"=>""
        }
    Pessoa.procurar_pessoas(parametros, entidades(:senai).id).should == [pessoas(:andre, :fornecedor, :fabio, :inovare, :guilherme, :jansen, :juan, :julio, :paulo, :rafael),true]
  end
    
  it "le cidade_e_estado quando nao tem" do
    @pessoa = Pessoa.new
    @pessoa.nome_localidade.should == nil
  end

  it "teste para garantir que cpf seja único situacao objeto novo" do
    @nova_pessoa = Pessoa.new
    @nova_pessoa.cpf = "06512424956"
    @nova_pessoa.tipo_pessoa = Pessoa::FISICA
    @nova_pessoa.should_not be_valid
    @nova_pessoa.errors.on(:base).should == ["O CPF número 065.124.249-56 encontra-se cadastrado em nossa base de dados em nome de Paulo Vitor Zeferino", "Uma pessoa deve ser Cliente, Fornecedor ou Funcionário"]
  end
  
  it "teste para gerantir que cnpj seja único " do
    @nova_pessoa = Pessoa.new
    @nova_pessoa.cnpj ="08916988000145"
    @nova_pessoa.tipo_pessoa = Pessoa::JURIDICA
    @nova_pessoa.should_not be_valid
    @nova_pessoa.errors.on(:base).should == ["O CNPJ número 08.916.988/0001-45 encontra-se cadastrado em nossa base de dados em nome de Inovare", "Uma pessoa deve ser Cliente, Fornecedor ou Funcionário"]
  end
  
  it "testa o metodo resumo" do
    @pessoa = pessoas(:paulo)
    @pessoa.nome.should == "Paulo Vitor Zeferino"
  end
  
  it "teste para garantir que cpf seja único situacao objeto edit" do
    @pessoa = pessoas(:paulo)
    @pessoa.cpf = "06512424956"
    @pessoa.should be_valid
  end
  
  it "teste verificar o retorno das categorias" do      
  
    @pessoa = pessoas(:paulo)
    @pessoa.categorias.should == "Cliente"

    @pessoa_dois = pessoas(:inovare)
    @pessoa_dois.categorias.should == "Fornecedor"

    @pessoa_tres = pessoas(:rafael)
    @pessoa_tres.categorias.should == "Funcionário / Cliente"
  end
  
  it "quando excluir uma pessoa deve excluir seus dependentes" do
    RecebimentoDeConta.delete_all
    PagamentoDeConta.delete_all
    Movimento.delete_all
    @pessoa = pessoas(:paulo)
    @pessoa.save
    assert_difference 'Pessoa.count',-1 do
      assert_difference 'Dependente.count',-2 do
        @pessoa.destroy
      end
    end
            
  end
  
  it "teste de data br field e converte data para data_br_field" do
    @pessoa = pessoas(:felipe)
    @pessoa.data_nascimento.should == "09/03/1984"
    @pessoa.reload
    @pessoa.data_nascimento = Date.today
    @pessoa.data_nascimento.should == Date.today.to_s_br
  end
  
  it "não permite deletar pessoa se ela possuir conta a pagar ou a receber " do
    @pessoa = pessoas(:felipe)
    assert_no_difference 'Pessoa.count' do
      @pessoa.destroy
    end
  end

  it "valida a presença de uma entidade" do
    @pessoa = pessoas(:felipe)
    @pessoa.entidade = nil
    @pessoa.save
    @pessoa.should_not be_valid
    @pessoa.errors.on(:entidade).should == "deve estar preenchido."
  end
       
  it "verifica se a pessoa possui alguma conta" do
    @pessoa = pessoas(:felipe)
    @pessoa.possui_alguma_conta?.should == true
    @pessoa = pessoas(:paulo)
    @pessoa.possui_alguma_conta?.should == true
  end
  
  it "testa atributo virtual mensagem_de_erro" do
    @pessoa = Pessoa.new
    @pessoa.mensagem_de_erro.should == nil
  end

  it "teste cria_readers_e_writers_para_o_nome_dos_atributos para agencia e o relacionamento" do
    @pessoa = Pessoa.new
    @pessoa.nome_agencia.should ==  nil
    @pessoa.agencia = agencias(:centro)
    @pessoa.nome_agencia.should == "#{agencias(:centro).numero} - #{agencias(:centro).nome}"
  end
  
  it "não insere agencia que não pertence ao banco" do
    @pessoa = pessoas(:inovare)
    @pessoa.should be_valid
    @pessoa.agencia = agencias(:prainha)
    @pessoa.should_not be_valid
    @pessoa.errors.on(:banco).should_not be_nil
  end
  
  it "teste para o método cpf_cnpj_encontrado" do
    params={:tipo_de_documento=>"cpf",:documento=>"06512424956",:id=>pessoas(:felipe).id}
    Pessoa.retorna_cpf_cnpj_encontrado(params).should == [pessoas(:paulo)]
    params={:tipo_de_documento=>"cpf",:documento=>"065.124.249-56",:id=>pessoas(:felipe).id}
    Pessoa.retorna_cpf_cnpj_encontrado(params).should == [pessoas(:paulo)]
    params={:tipo_de_documento=>"cpf",:documento=>"06512424956",:id=>pessoas(:paulo).id}
    Pessoa.retorna_cpf_cnpj_encontrado(params).should == []        
    params={:tipo_de_documento=>"cnpj",:documento=>"08.916.988/0001-45",:id=>pessoas(:paulo).id}
    Pessoa.retorna_cpf_cnpj_encontrado(params).should == [pessoas(:inovare)]        
  end

  it "teste se um fornecedor possui um banco" do
    @pessoa = pessoas(:felipe)
    @pessoa.fornecedor = true
    @pessoa.save
    @pessoa.should_not be_valid
    @pessoa.errors.on(:banco).should == "não pode ser vazio"
    @pessoa.banco = bancos(:banco_do_brasil)
    @pessoa.agencia = agencias(:centro)
    @pessoa.save
    @pessoa.should be_valid
    @pessoa.errors.on(:banco).should be_nil
  end


  it "testa se quando não é fornecedor não necessita de banco" do
    @pessoa = pessoas(:inovare)
    @pessoa.fornecedor = false
    @pessoa.cliente = true
    @pessoa.banco_id = ""
    @pessoa.agencia_id = ""
    @pessoa.save!
    @pessoa.should be_valid
    @pessoa.errors.on(:banco).should be_nil
  end

  it "testa se apaga o cnpj quando se tem cpf" do
    @pessoa = pessoas(:inovare)
    @pessoa.tipo_pessoa = Pessoa::FISICA
    @pessoa.cpf = "00979217938"
    @pessoa.data_nascimento = "10/10/1970"
    @pessoa.razao_social.should == "Inovare"
    @pessoa.save!
    @pessoa.cnpj.to_s.should == ""
    @pessoa.razao_social.should == nil
    @pessoa.cpf.to_s.should == "009.792.179-38"
    @pessoa.data_nascimento.should == "10/10/1970"
  end

  it "testa se apaga o cpf quando se tem cnpj" do
    @pessoa = pessoas(:felipe)
    @pessoa.funcionario = false
    @pessoa.fornecedor = true
    @pessoa.razao_social = "Teste"
    @pessoa.banco = bancos(:banco_do_brasil)
    @pessoa.agencia = agencias(:centro)
    @pessoa.tipo_pessoa = Pessoa::JURIDICA
    @pessoa.cnpj = "12117514000100"
    @pessoa.save!
    @pessoa.cpf.to_s.should == ""
    @pessoa.data_nascimento.should == nil
    @pessoa.cnpj.to_s.should == "12.117.514/0001-00"
    @pessoa.razao_social.should == "Teste"
  end

  it "teste se exclui o usuário quando um funcionário é excluido" do
    # Deletando os movimentos pois o juan tem movimentos simples vinculados, assim sendo ele nao poderia ser excluído
    Movimento.delete_all
    Pessoa.count.should == 11
    Usuario.count.should == 6
    @pessoa = pessoas(:juan)
    @pessoa.usuario.should == usuarios(:aaron)
    assert_difference 'Pessoa.count', -1 do
      assert_difference 'Usuario.count', -1 do
        @pessoa.destroy
      end
    end
    Pessoa.count.should == 10
    Usuario.count.should == 5
  end

  it 'cria uma pessoa com o cpf e em seguida cria outra com o mesmo cpf, tenta validar, se for funcionario inativo deve passar' do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA, :funcionario => true, :funcionario_ativo => true,
      :nome => 'Joaquim Nabuco', :endereco => 'Brigadeiro Franco', :cpf => '70722875665', :entidade => entidades(:senai),
      :unidade => unidades(:senaivarzeagrande)
    @pessoa.valid?
    @pessoa.errors.on(:base).should be_nil
    @pessoa.save.should == true

    @outra_pessoa_com_mesmo_cpf = Pessoa.new :tipo_pessoa => Pessoa::FISICA, :funcionario => true, :funcionario_ativo => true,
      :nome => 'Joaquim Nabuco', :endereco => 'Brigadeiro Franco', :cpf => '70722875665', :entidade => entidades(:senai),
      :unidade => unidades(:senaivarzeagrande)
    @outra_pessoa_com_mesmo_cpf.valid?
    @outra_pessoa_com_mesmo_cpf.errors.on(:base).should_not be_nil

    @pessoa.funcionario_ativo = false
    @pessoa.save.should == true

    @outra_pessoa_com_mesmo_cpf.valid?
    @outra_pessoa_com_mesmo_cpf.errors.on(:base).should be_nil
    @outra_pessoa_com_mesmo_cpf.save.should == true

    @mais_uma_pessoa_com_mesmo_cpf = Pessoa.new :tipo_pessoa => Pessoa::FISICA, :funcionario => true, :funcionario_ativo => true,
      :nome => 'Joaquim Nabuco', :endereco => 'Brigadeiro Franco', :cpf => '70722875665', :entidade => entidades(:senai),
      :unidade => unidades(:senaivarzeagrande)
    @mais_uma_pessoa_com_mesmo_cpf.valid?
    @mais_uma_pessoa_com_mesmo_cpf.errors.on(:base).should_not be_nil

    @outra_pessoa_com_mesmo_cpf.funcionario_ativo = false
    @outra_pessoa_com_mesmo_cpf.save.should == true

    @mais_uma_pessoa_com_mesmo_cpf.valid?
    @mais_uma_pessoa_com_mesmo_cpf.errors.on(:base).should be_nil
    @mais_uma_pessoa_com_mesmo_cpf.save.should == true
  end

  it "testa metodo eh_funcionario_e_esta_inativo?" do
    @pessoa = Pessoa.new :tipo_pessoa => Pessoa::FISICA, :funcionario => true, :funcionario_ativo => true,
      :nome => 'Joaquim Nabuco', :endereco => 'Brigadeiro Franco', :cpf => '70722875665', :entidade => entidades(:senai)
    @pessoa.eh_funcionario_e_esta_inativo?.should == false

    @outra_pessoa_com_mesmo_cpf = Pessoa.new :tipo_pessoa => Pessoa::FISICA, :funcionario => true, :funcionario_ativo => false,
      :nome => 'Joaquim Nabuco', :endereco => 'Brigadeiro Franco', :cpf => '70722875665', :entidade => entidades(:senai)
    @outra_pessoa_com_mesmo_cpf.eh_funcionario_e_esta_inativo?.should == true

    @mais_uma_pessoa_com_mesmo_cpf = Pessoa.new :tipo_pessoa => Pessoa::FISICA, :funcionario => false, :funcionario_ativo => true,
      :nome => 'Joaquim Nabuco', :endereco => 'Brigadeiro Franco', :cpf => '70722875665', :entidade => entidades(:senai)
    @mais_uma_pessoa_com_mesmo_cpf.eh_funcionario_e_esta_inativo?.should == false
  end

  it 'verifica se possui algum movimento simples' do
    @pessoa = pessoas(:rafael)
    @pessoa.possui_algum_movimento_simples?.should == false

    @outra_pessoa = pessoas(:paulo)
    @outra_pessoa.possui_algum_movimento_simples?.should == true
  end

  it 'nao pode deixar excluir pessoa que possui movimentos vinculado a ela' do
    @pessoa = pessoas(:rafael)
    assert_difference 'Pessoa.count', -1 do
      @pessoa.destroy
    end
    @pessoa.mensagem_de_erro.should == nil

    @outra_pessoa_com_movimentos_vinculados = pessoas(:juan)
    assert_no_difference 'Pessoa.count' do
      @outra_pessoa_com_movimentos_vinculados.destroy
    end
    @outra_pessoa_com_movimentos_vinculados.mensagem_de_erro.should == "Não foi possível excluir a pessoa Juan Vitor Zeferino, pois esta possui contas/lançamentos simples vinculadas."
  end

  it "testa dias em atraso" do
    Date.stub!(:today).and_return Date.new(2010, 4, 15)
    @pessoa = pessoas(:paulo)
    @pessoa.dias_em_atraso.should == 284
    @pessoa_dois = pessoas(:guilherme)
    @pessoa_dois.dias_em_atraso.should == 0

    Date.stub!(:today).and_return Date.new(2010, 4, 16)
    @pessoa = pessoas(:paulo)
    @pessoa.dias_em_atraso.should == 285

    Date.stub!(:today).and_return Date.new(2010, 4, 21)
    @pessoa = pessoas(:paulo)
    @pessoa.dias_em_atraso.should == 290
  end

end
