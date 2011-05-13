module Hydra::ExternalAssetModelMethods
  
  def uri
    #assume either a redirected or external link
    "#{Fedora::Repository.instance.base_url}/get/#{pid}/#{link.first.dsid}" if link.first
  end

  def filename
    datastreams_in_memory["descMetadata"].title_values.first unless datastreams_in_memory["descMetadata"].title_values.empty? 
  end
     
  def filename=(filename)
    datastreams_in_memory["descMetadata"].title_values = filename
  end

  def identifier=(identifier)
    datastreams_in_memory["descMetadata"].identifier_values = identifier
  end
 
  def identifier
    datastreams_in_memory["descMetadata"].identifier_values.first unless datastreams_in_memory["descMetadata"].identifier_values.empty? 
  end

  # Mimic the relationship accessor that would be created if a containers relationship existed
  # Decided to create this method instead because it combines more than one relationship list
  # from is_member_of_collection and part_of
  # @param [Hash] opts The options hash that can contain a :response_format value of :id_array, :solr, or :load_from_solr
  # @return [Array] Objects found through inbound has_collection_member and part_of relationships
  def containers(opts={})
    is_member_array = is_member_of_collection(:response_format=>:id_array)
      
    if !is_member_array.empty?
      logger.warn "This object has inbound collection member assertions.  hasCollectionMember will no longer be used to track file_object relationships after active_fedora 1.3.  Use isPartOf assertions in the RELS-EXT of child objects instead."
      if opts[:response_format] == :solr || opts[:response_format] == :load_from_solr
        logger.warn ":solr and :load_from_solr response formats for containers search only uses parts relationships (usage of hasCollectionMember is no longer supported)"
        result = part_of(opts)
      else
        con_result = is_member_of_collection(opts)
        part_of_result = part_of(opts)
        ary = con_result+part_of_result
        result = ary.uniq
      end
    else
      result = part_of(opts)
    end
    return result
  end

  # Calls +containers+ with the :id_array option to return a list of pids for containers found.
  # @return [Array] Container ids (via is_member_of_collection and part_of relationships)
  def containers_ids
    containers(:response_format => :id_array)
  end
  
  # Calls +containers+ with the option to load objects found from solr instead of Fedora.      
  # @return [Array] ActiveFedora::Base objects populated via solr
  def containers_from_solr
    containers(:response_format => :load_from_solr)
  end
end
