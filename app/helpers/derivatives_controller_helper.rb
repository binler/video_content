module DerivativesControllerHelper

  def create_and_save_derivative(content_type, parent_id, level="1")
    @asset = Derivative.new(:namespace=>"VIDEO-CONTENT")
    @asset.datastreams["descMetadata"].ng_xml = PbcoreXml.derivative_template
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.member_of_append(parent_id)
    @asset.update_indexed_attributes({:level=>{0=>level}})
    @asset.save
    return @asset
  end
end
