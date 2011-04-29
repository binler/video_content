class ExternalAssetsController < ApplicationController
  
  include Hydra::AssetsControllerHelper
  include Hydra::ExternalAssetsHelper
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  
  before_filter :require_fedora
  before_filter :require_solr, :only=>[:index, :create, :show, :destroy]

  def new
    render :partial=>"new", :layout=>false
  end

  def create
    #begin
    @new_external_asset = create_and_save_external_asset_from_params

    apply_depositor_metadata(@new_external_asset)
        
    if !params[:container_id].nil?
      @container =  ActiveFedora::Base.load_instance(params[:container_id])
      @container.file_objects_append(@new_link)
      @container.save
    end
    #rescue
    
    #end
  end
end
