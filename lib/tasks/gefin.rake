namespace :db do

  desc "Cria dados iniciais no banco"

  task :dados_gefin => :environment do
    cuiaba = Localidade.find_or_initialize_by_nome_and_uf :nome => 'CUIABA', :uf => 'MT'
    cuiaba.save!
    
    entidade = Entidade.find_or_initialize_by_nome :nome => 'TESTE', :codigo_zeus => 0, :sigla => 'TESTE'
    entidade.save!
    unidade = Unidade.find_or_initialize_by_nome_and_entidade_id :nome => 'TESTE', :entidade_id => entidade.id,
      :sigla => 'TESTE', :endereco => 'TESTE', :bairro => 'TESTE', :cep => '0000-000', :localidade_id => cuiaba.id,
      :ativa => true, :nome_caixa_zeus => '0', :lancamentoscontaspagar => 5, :lancamentoscontasreceber => 5,
      :lancamentosmovimentofinanceiro => 5, :limitediasparaestornodeparcelas => 5,
      :senha_baixa_dr => 'teste', :dr_nome => "Preencher", :dr_email => "Preencher", :dr_fax => "Preencher", :dr_telefone  => ["Preencher"]
    unidade.save!
    funcionario = Pessoa.find_or_initialize_by_nome :nome => 'TESTE', :endereco => 'TESTE', :tipo_pessoa => Pessoa::FISICA,
      :bairro => 'TESTE', :funcionario => true, :entidade => entidade, :telefone => ['0000-0000'], :funcionario_ativo => true,
      :unidade => unidade, :cep => '00000-000'
    funcionario.save false
    
    master = Perfil.find_or_initialize_by_descricao :descricao => 'Master', :permissao => Perfil::MASTER
    master.save!
    gerente = Perfil.find_or_initialize_by_descricao :descricao => 'Gerente', :permissao => Perfil::GERENTE
    gerente.save!
    operador_financeiro = Perfil.find_or_initialize_by_descricao :descricao => 'Operador Financeiro', :permissao => Perfil::OPERADORFINANCEIRO
    operador_financeiro.save!
    operador_cr = Perfil.find_or_initialize_by_descricao :descricao => 'Operador CR', :permissao => Perfil::OPERADORCR
    operador_cr.save!
    operador_cp = Perfil.find_or_initialize_by_descricao :descricao => 'Operador CP', :permissao => Perfil::OPERADORCP
    operador_cp.save!
    consulta = Perfil.find_or_initialize_by_descricao :descricao => 'Consulta', :permissao => Perfil::CONSULTA
    consulta.save!
    contador = Perfil.find_or_initialize_by_descricao :descricao => 'Contador', :permissao => Perfil::CONTADOR
    contador.save!

    usuario = Usuario.find_or_initialize_by_login :login => 'teste', :password => 'password', :password_confirmation => 'password',
      :perfil_id => master.id, :funcionario_id => funcionario.id
    usuario.unidade = unidade
    usuario.save!

    puts "Dados inseridos com sucesso!"
  end
  
end
