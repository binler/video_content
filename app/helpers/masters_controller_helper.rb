module MastersControllerHelper

  def create_and_save_master(content_type, parent_id)
    @asset = Master.new(:namespace=>"VIDEO-CONTENT")
    @asset.datastreams["descMetadata"].ng_xml = PbcoreXml.master_template
    @asset.member_of_append(parent_id)
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.datastreams["rightsMetadata"].update_permissions(Master.default_permissions_hash)
    @asset.save
    return @asset
  end
end
