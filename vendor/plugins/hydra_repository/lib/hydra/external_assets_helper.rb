module Hydra::ExternalAssetsHelper
  
  # Creates a File Asset, adding the posted blob to the File Asset's datastreams and saves the File Asset
  #
  # @return [FileAsset] the File Asset  
  def create_and_save_external_asset_from_params
    if params.has_key?(:dsLocation)
      @new_link = create_external_asset_from_params
      @new_link.save
      return @new_link
    else
      render :text => "400 Bad Request", :status => 400
    end
  end
  
  # Creates a Link Asset and sets its label from params[:label]
  #
  # @return [] the Link Asset
  def create_external_asset_from_params    
    link = ExternalAsset.new
    link.uri = params[:dsLocation]
    link.label = params[:label] if params[:label]

    return link
  end  
end
