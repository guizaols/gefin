require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RecebimentoDeContasController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "recebimento_de_contas", :action => "index").should == "/recebimento_de_contas"
    end
  
    it "maps #new" do
      route_for(:controller => "recebimento_de_contas", :action => "new").should == "/recebimento_de_contas/new"
    end
  
    it "maps #show" do
      route_for(:controller => "recebimento_de_contas", :action => "show", :id => "1").should == "/recebimento_de_contas/1"
    end
  
    it "maps #edit" do
      route_for(:controller => "recebimento_de_contas", :action => "edit", :id => "1").should == "/recebimento_de_contas/1/edit"
    end

  it "maps #create" do
    route_for(:controller => "recebimento_de_contas", :action => "create").should == {:path => "/recebimento_de_contas", :method => :post}
  end

  it "maps #update" do
    route_for(:controller => "recebimento_de_contas", :action => "update", :id => "1").should == {:path =>"/recebimento_de_contas/1", :method => :put}
  end
  
    it "maps #destroy" do
      route_for(:controller => "recebimento_de_contas", :action => "destroy", :id => "1").should == {:path =>"/recebimento_de_contas/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/recebimento_de_contas").should == {:controller => "recebimento_de_contas", :action => "index"}
    end
  
    it "generates params for #new" do
      params_from(:get, "/recebimento_de_contas/new").should == {:controller => "recebimento_de_contas", :action => "new"}
    end
  
    it "generates params for #create" do
      params_from(:post, "/recebimento_de_contas").should == {:controller => "recebimento_de_contas", :action => "create"}
    end
  
    it "generates params for #show" do
      params_from(:get, "/recebimento_de_contas/1").should == {:controller => "recebimento_de_contas", :action => "show", :id => "1"}
    end
  
    it "generates params for #edit" do
      params_from(:get, "/recebimento_de_contas/1/edit").should == {:controller => "recebimento_de_contas", :action => "edit", :id => "1"}
    end
  
    it "generates params for #update" do
      params_from(:put, "/recebimento_de_contas/1").should == {:controller => "recebimento_de_contas", :action => "update", :id => "1"}
    end
  
    it "generates params for #destroy" do
      params_from(:delete, "/recebimento_de_contas/1").should == {:controller => "recebimento_de_contas", :action => "destroy", :id => "1"}
    end
  end
end
