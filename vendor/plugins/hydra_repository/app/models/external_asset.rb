class ExternalAsset < ActiveFedora::Base
  
  include Hydra::ModelMethods
  
  has_relationship "is_member_of_collection", :has_collection_member, :inbound => true
  has_bidirectional_relationship "part_of", :is_part_of, :has_part

  has_datastream :name=>"link", :type=>ActiveFedora::Datastream, :controlGroup=>'E'

  # deletes the object identified by pid if it does not have any objects asserting has_collection_member
  def self.garbage_collect(pid)
    begin 
      obj = ExternalAsset.load_instance(pid)
      if obj.containers.empty?
        obj.delete
      end
    rescue
    end
  end

  def uri
    #assume either a redirected or external link
    link.first.attributes[:dsLocation] if link.first
  end

  has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream do |m|
  end

  def label_values=(value)
    self.label = value
  end

  def uri_values=(value)
    self.uri = value
  end
      
  def label=(label)
    super
    datastreams_in_memory["descMetadata"].title_values = label
  end    

  def uri=(uri)
    datastreams_in_memory["descMetadata"].identifier_values = uri
    if link.first
      update_named_datastream("link",{:dsid=>link.first.dsid,:dsLocation=>uri})
    else
      link_append({:dsLocation=>uri})
    end
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
