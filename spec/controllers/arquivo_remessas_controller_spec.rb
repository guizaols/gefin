require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArquivoRemessasController do

#  def mock_arquivo_remessa(stubs={})
#    @mock_arquivo_remessa ||= mock_model(ArquivoRemessa, stubs)
#  end
#
#  describe "GET index" do
#    it "assigns all arquivo_remessas as @arquivo_remessas" do
#      ArquivoRemessa.stub!(:find).with(:all).and_return([mock_arquivo_remessa])
#      get :index
#      assigns[:arquivo_remessas].should == [mock_arquivo_remessa]
#    end
#  end
#
#  describe "GET show" do
#    it "assigns the requested arquivo_remessa as @arquivo_remessa" do
#      ArquivoRemessa.stub!(:find).with("37").and_return(mock_arquivo_remessa)
#      get :show, :id => "37"
#      assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#    end
#  end
#
#  describe "GET new" do
#    it "assigns a new arquivo_remessa as @arquivo_remessa" do
#      ArquivoRemessa.stub!(:new).and_return(mock_arquivo_remessa)
#      get :new
#      assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#    end
#  end
#
#  describe "GET edit" do
#    it "assigns the requested arquivo_remessa as @arquivo_remessa" do
#      ArquivoRemessa.stub!(:find).with("37").and_return(mock_arquivo_remessa)
#      get :edit, :id => "37"
#      assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#    end
#  end
#
#  describe "POST create" do
#
#    describe "with valid params" do
#      it "assigns a newly created arquivo_remessa as @arquivo_remessa" do
#        ArquivoRemessa.stub!(:new).with({'these' => 'params'}).and_return(mock_arquivo_remessa(:save => true))
#        post :create, :arquivo_remessa => {:these => 'params'}
#        assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#      end
#
#      it "redirects to the created arquivo_remessa" do
#        ArquivoRemessa.stub!(:new).and_return(mock_arquivo_remessa(:save => true))
#        post :create, :arquivo_remessa => {}
#        response.should redirect_to(arquivo_remessa_url(mock_arquivo_remessa))
#      end
#    end
#
#    describe "with invalid params" do
#      it "assigns a newly created but unsaved arquivo_remessa as @arquivo_remessa" do
#        ArquivoRemessa.stub!(:new).with({'these' => 'params'}).and_return(mock_arquivo_remessa(:save => false))
#        post :create, :arquivo_remessa => {:these => 'params'}
#        assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#      end
#
#      it "re-renders the 'new' template" do
#        ArquivoRemessa.stub!(:new).and_return(mock_arquivo_remessa(:save => false))
#        post :create, :arquivo_remessa => {}
#        response.should render_template('new')
#      end
#    end
#
#  end
#
#  describe "PUT update" do
#
#    describe "with valid params" do
#      it "updates the requested arquivo_remessa" do
#        ArquivoRemessa.should_receive(:find).with("37").and_return(mock_arquivo_remessa)
#        mock_arquivo_remessa.should_receive(:update_attributes).with({'these' => 'params'})
#        put :update, :id => "37", :arquivo_remessa => {:these => 'params'}
#      end
#
#      it "assigns the requested arquivo_remessa as @arquivo_remessa" do
#        ArquivoRemessa.stub!(:find).and_return(mock_arquivo_remessa(:update_attributes => true))
#        put :update, :id => "1"
#        assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#      end
#
#      it "redirects to the arquivo_remessa" do
#        ArquivoRemessa.stub!(:find).and_return(mock_arquivo_remessa(:update_attributes => true))
#        put :update, :id => "1"
#        response.should redirect_to(arquivo_remessa_url(mock_arquivo_remessa))
#      end
#    end
#
#    describe "with invalid params" do
#      it "updates the requested arquivo_remessa" do
#        ArquivoRemessa.should_receive(:find).with("37").and_return(mock_arquivo_remessa)
#        mock_arquivo_remessa.should_receive(:update_attributes).with({'these' => 'params'})
#        put :update, :id => "37", :arquivo_remessa => {:these => 'params'}
#      end
#
#      it "assigns the arquivo_remessa as @arquivo_remessa" do
#        ArquivoRemessa.stub!(:find).and_return(mock_arquivo_remessa(:update_attributes => false))
#        put :update, :id => "1"
#        assigns[:arquivo_remessa].should equal(mock_arquivo_remessa)
#      end
#
#      it "re-renders the 'edit' template" do
#        ArquivoRemessa.stub!(:find).and_return(mock_arquivo_remessa(:update_attributes => false))
#        put :update, :id => "1"
#        response.should render_template('edit')
#      end
#    end
#
#  end
#
#  describe "DELETE destroy" do
#    it "destroys the requested arquivo_remessa" do
#      ArquivoRemessa.should_receive(:find).with("37").and_return(mock_arquivo_remessa)
#      mock_arquivo_remessa.should_receive(:destroy)
#      delete :destroy, :id => "37"
#    end
#
#    it "redirects to the arquivo_remessas list" do
#      ArquivoRemessa.stub!(:find).and_return(mock_arquivo_remessa(:destroy => true))
#      delete :destroy, :id => "1"
#      response.should redirect_to(arquivo_remessas_url)
#    end
#  end

end
