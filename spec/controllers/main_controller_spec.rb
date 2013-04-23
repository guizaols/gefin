require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MainController do

  describe "GET 'index'" do

    it "não deve deixa acessar sem login" do
      get 'show'
      response.should redirect_to(new_sessao_path)
    end

    it "deve deixa acessar com login" do
      login_as :quentin
      get 'show'
      response.should be_success
    end

  end
end
