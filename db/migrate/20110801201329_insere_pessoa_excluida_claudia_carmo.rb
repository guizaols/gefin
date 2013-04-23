class InserePessoaExcluidaClaudiaCarmo < ActiveRecord::Migration
  def self.up
    pessoa = Pessoa.new
    pessoa.nome = 'CLAUDIA EVANGELISTA DO CARMO'
    pessoa.tipo_pessoa = '1'
    pessoa.cpf = '688.713.761-53'
    pessoa.funcionario_ativo = true
    pessoa.localidade_id = 37
    pessoa.endereco = 'AV. 15 DE NOVEMBRO'
    pessoa.cep = '78000-000'
    pessoa.unidade_id = 3
    pessoa.industriario = false
    pessoa.funcionario = true
    pessoa.fornecedor = false
    pessoa.cliente = false
    pessoa.spc = false
    pessoa.cargo = 'TA - AGENTE EXTERNO MERCADO'
    pessoa.entidade_id = 2
    pessoa.bairro = 'PORTO'
    pessoa.telefone = '---  - 065 3612-1725'
    pessoa.save false

    usuario = Usuario.find_by_login('claudia.carmo')
    if !usuario.blank?
      usuario.funcionario_id = pessoa.id
      usuario.save false
    end
  end

  def self.down
    usuario = Usuario.find_by_login('claudia.carmo')
    if !usuario.blank?
      usuario.funcionario_id = 9999999
      usuario.save false
    end

    pessoa = Pessoa.find_by_nome('CLAUDIA EVANGELISTA DO CARMO')
    if !pessoa.blank?
      pessoa.destroy
    end
  end

end
