module EventsControllerHelper

  def create_and_save_event(content_type)
    @asset = Event.new(:namespace=>"VIDEO-CONTENT")
    @asset.datastreams["descMetadata"].ng_xml = PbcoreXml.event_template
    apply_depositor_metadata(@asset)
    set_collection_type(@asset, content_type)
    @asset.datastreams["rightsMetadata"].update_permissions(Event.default_permissions_hash)
    @asset.save
    return @asset
  end
end
