class AtualizaPerfisDeAcessoComNovosAcessos < ActiveRecord::Migration
  def self.up
    execute "UPDATE perfis SET permissao = '#{Perfil::MASTER}' WHERE descricao = 'Master'"
    execute "UPDATE perfis SET permissao = '#{Perfil::GERENTE}' WHERE descricao = 'Gerente'"
    execute "UPDATE perfis SET permissao = '#{Perfil::OPERADORFINANCEIRO}' WHERE descricao = 'Operador Financeiro'"
    execute "UPDATE perfis SET permissao = '#{Perfil::OPERADORCR}' WHERE descricao = 'Operador CR'"
    execute "UPDATE perfis SET permissao = '#{Perfil::OPERADORCP}' WHERE descricao = 'Operador CP'"
    execute "UPDATE perfis SET permissao = '#{Perfil::CONSULTA}' WHERE descricao = 'Consulta'"
    execute "UPDATE perfis SET permissao = '#{Perfil::CONTADOR}' WHERE descricao = 'Contador'"    
  end

  def self.down
    execute "UPDATE perfis SET permissao = '#{Perfil::MASTER.chop}' WHERE descricao = 'Master'"
    execute "UPDATE perfis SET permissao = '#{Perfil::GERENTE.chop}' WHERE descricao = 'Gerente'"
    execute "UPDATE perfis SET permissao = '#{Perfil::OPERADORFINANCEIRO.chop}' WHERE descricao = 'Operador Financeiro'"
    execute "UPDATE perfis SET permissao = '#{Perfil::OPERADORCR.chop}' WHERE descricao = 'Operador CR'"
    execute "UPDATE perfis SET permissao = '#{Perfil::OPERADORCP.chop}' WHERE descricao = 'Operador CP'"
    execute "UPDATE perfis SET permissao = '#{Perfil::CONSULTA.chop}' WHERE descricao = 'Consulta'"
    execute "UPDATE perfis SET permissao = '#{Perfil::CONTADOR.chop}' WHERE descricao = 'Contador'"  
  end
end
