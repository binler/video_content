module Hydra::ExternalAssetsHelper
  
  # Creates a File Asset, adding the posted blob to the File Asset's datastreams and saves the File Asset
  #
  # @return [FileAsset] the File Asset  
  def create_and_save_external_asset_from_params
    if params.has_key?(:dsLocation) && params.has_key?(:Filename)
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
    attrs={}
    attrs.merge!({:namespace=>params[:namespace]}) if params[:namespace]
    attrs.merge!(:dsLabel=>params[:Filename]) if params[:Filename]
    ext_asset = ExternalAsset.new(attrs)
    uri = params[:dsLocation]
    uri = "http://#{uri}" unless uri.include?("://")
    ext_asset.link_append({:dsLocation=>uri,:dsLabel=>params[:Filename], :mimeType=>mime_type(params[:Filename])})
    ext_asset.filename = params[:Filename]
    ext_asset.identifier = uri
    return ext_asset
  end  

  private
  # Return the mimeType for a given file name
  # @param [String] file_name The filename to use to get the mimeType
  # @return [String] mimeType for filename passed in. Default: application/octet-stream if mimeType cannot be determined
  def mime_type file_name
    mime_types = MIME::Types.of(file_name)
    mime_type = mime_types.empty? ? "application/octet-stream" : mime_types.first.content_type
  end
end
