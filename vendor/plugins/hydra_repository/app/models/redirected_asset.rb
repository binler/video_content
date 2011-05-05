class RedirectedAsset < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include Hydra::ExternalAssetModelMethods
  
  has_relationship "is_member_of_collection", :has_collection_member, :inbound => true
  has_bidirectional_relationship "part_of", :is_part_of, :has_part

  has_datastream :name=>"link", :type=>ActiveFedora::Datastream, :controlGroup=>'R'

  # deletes the object identified by pid if it does not have any objects asserting has_collection_member
  def self.garbage_collect(pid)
    begin 
      obj = RedirectedAsset.load_instance(pid)
      if obj.containers.empty?
        obj.delete
      end
    rescue
    end
  end

  has_metadata :name => "descMetadata", :type => ActiveFedora::QualifiedDublinCoreDatastream do |m|
  end
end
