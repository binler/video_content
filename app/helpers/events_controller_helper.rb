module EventsControllerHelper

  def create_and_save_event(content_type)
    @asset = Event.new(:namespace=>"VIDEO-CONTENT")
    @asset.datastreams["descMetadata"].ng_xml = PbcoreXml.collection_template
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.save
    return @asset
  end
end
