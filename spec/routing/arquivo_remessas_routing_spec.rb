require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArquivoRemessasController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "arquivo_remessas", :action => "index").should == "/arquivo_remessas"
    end

    it "maps #new" do
      route_for(:controller => "arquivo_remessas", :action => "new").should == "/arquivo_remessas/new"
    end

    it "maps #show" do
      route_for(:controller => "arquivo_remessas", :action => "show", :id => "1").should == "/arquivo_remessas/1"
    end

    it "maps #edit" do
      route_for(:controller => "arquivo_remessas", :action => "edit", :id => "1").should == "/arquivo_remessas/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "arquivo_remessas", :action => "create").should == {:path => "/arquivo_remessas", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "arquivo_remessas", :action => "update", :id => "1").should == {:path =>"/arquivo_remessas/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "arquivo_remessas", :action => "destroy", :id => "1").should == {:path =>"/arquivo_remessas/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/arquivo_remessas").should == {:controller => "arquivo_remessas", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/arquivo_remessas/new").should == {:controller => "arquivo_remessas", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/arquivo_remessas").should == {:controller => "arquivo_remessas", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/arquivo_remessas/1").should == {:controller => "arquivo_remessas", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/arquivo_remessas/1/edit").should == {:controller => "arquivo_remessas", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/arquivo_remessas/1").should == {:controller => "arquivo_remessas", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/arquivo_remessas/1").should == {:controller => "arquivo_remessas", :action => "destroy", :id => "1"}
    end
  end
end
