require File.dirname(__FILE__) + '/../spec_helper'

describe Perfil do
  
  before(:each) do
    @perfil = Perfil.new
  end

  it "should be valid" do
    @perfil.should be_valid
  end

  it "verifica relacionamentos" do
    perfis(:master_main).usuarios.should == [usuarios(:quentin), usuarios(:juliano)]
  end

#  it "retornando lista de permissoes" do
#    Perfil.lista_de_permissoes_para_view.should include ['Manipular Perfis de Acesso', Perfil::ManipularPerfisDeAcesso]
#  end

  it 'exclui se não estiver ligado a usuarios' do
    @perfil.save.should be_true
    lambda do
      @perfil.destroy
    end.should change(Perfil,:count).by(-1)
  end

  it 'não permite excluir se ligado a usuarios' do
    perfil = perfis(:gerente_main)
    lambda do
      perfil.destroy
    end.should_not change(Perfil,:count)
    perfil.errors.full_messages.should == ["Perfil não pode ser excluído enquanto estiver ligado ao(s) usuário(s): Juan Vitor Zeferino"]
    perfil = perfis(:master_main)
    lambda do
      perfil.destroy
    end.should_not change(Perfil,:count)
    perfil.errors.full_messages.should == ["Perfil não pode ser excluído enquanto estiver ligado ao(s) usuário(s): Felipe Giotto, Julio Pinheiro"]
  end

end
