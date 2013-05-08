class CriarPessoaExcluidaDaBase < ActiveRecord::Migration
  def self.up
    pessoa = Pessoa.new
    pessoa.id = 19729
    pessoa.nome = 'ANDERSON COSTA'
    pessoa.tipo_pessoa = '1'
    pessoa.cpf = '579.689.063-85'
    pessoa.funcionario_ativo = false
    pessoa.localidade = Localidade.find(37)
    pessoa.endereco = 'XX'
    pessoa.cep = '99999-999'
    pessoa.unidade = Unidade.find(3)
    pessoa.industriario = false
    pessoa.funcionario = true
    pessoa.fornecedor = false
    pessoa.cliente = false
    pessoa.spc = false
    pessoa.cargo = 'XX'
    pessoa.entidade = Entidade.find(2)
    pessoa.bairro = 'XX'
    pessoa.telefone = '---  - 065 9999-9999'
    pessoa.save false

    usuario = Usuario.find_by_login('anderson.costa')
    if !usuario.blank?
      usuario.entidade_id = pessoa.entidade_id
      usuario.status = Usuario::INATIVO
      usuario.save false
    end
  end

  def self.down
    Pessoa.destroy(19729)
  end
end
