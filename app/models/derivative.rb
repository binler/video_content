require "hydra"

class Derivative < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include Hydra::DefaultAccess

  has_bidirectional_relationship "member_of", :is_member_of, :has_member
  has_bidirectional_relationship "members", :has_member, :is_member_of
  
  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the PBCore profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => PbcoreXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|    
    m.field 'depositor', :string
    m.field 'derivative_type', :string
    m.field 'level', :string
    m.field 'chapter', :string
  end

  has_datastream :name=>"external_file", :type=>ActiveFedora::Datastream, :controlGroup=>'R'

  alias_method :id, :pid

  def content
    external_file.blank? ? "" : external_file.first.content
  end

  def level
    return @level if (defined? @level)
    values = self.fields[:level][:values]
    @level = values.any? ? values.first : ""
  end

  def chapter
    return @chapter if (defined? @chapter)
    values = self.fields[:chapter][:values]
    @chapter = values.any? ? values.first : ""
  end

  def derivative_id
    return @derivative_id if (defined? @derivative_id)
    values = self.datastreams["descMetadata"].term_values(:pbcorePart, :pbcoreInstantiation, :instantiationIdentifier)
    @derivative_id = values.any? ? values.first : ""
  end

  alias_method :composite_id, :derivative_id

  #returns the parent event for this derivative
  def parent_event
    parent = self.member_of.first
    counter = 0
    while (parent.respond_to?(:member_of)) do
      parent = parent.member_of.first
      puts "parent: #{parent.pid}"
    end
    return parent
  end

  def apply_ldap_values(computing_id, person_number)
    return if computing_id.blank? #|| person_number.blank?
    person = Ldap::Person.new(computing_id)
    desc_ds = self.datastreams_in_memory["descMetadata"]
    return if desc_ds.nil?
    creators = self.datastreams_in_memory["descMetadata"].get_values([:pbcorePart, :pbcoreCreator, :creator])
    j = 0
    creator_index = 0
    while(j < creators.size)
      if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{j}"}, :creator, :creator_annotation)[person_number].content.to_s.eql?"creator")
	creator_index = j
      end
      j = j + 1
    end
    if creators.include? "#{person.first_name} #{person.last_name}"
      return
    else
      if((!(creators[creator_index].empty?)))
        self.insert_new_node('creator_master', opts={})
	desc_ds = self.datastreams_in_memory["descMetadata"]
	creators = self.datastreams_in_memory["descMetadata"].get_values([:pbcorePart, :pbcoreCreator, :creator])
	creator_index = creators.size - 1
	desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{(creators.size) -1}"}, :creator, :creator_annotation)[person_number].content = "creator"
      end
      if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{creator_index}"}, :creator)[person_number].content.to_s.empty?)
        desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{creator_index}"}, :creator)[person_number].content = "#{person.first_name} #{person.last_name}"
        desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{creator_index}"}, :creatorRole)[person_number].content = "#{person.title}"
      end
      i = 0
      owner_index = 0
      while(i < creators.size)
	if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{i}"}, :creator, :creator_annotation)[person_number].content.to_s.eql?"owner")
	  owner_index = i
	end
	i = i + 1
      end
      if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{owner_index}"}, :creator, :creator_annotation)[person_number].content.to_s.eql?"owner")
        if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{owner_index}"}, :creator)[person_number].content.to_s.empty?)
          desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{owner_index}"}, :creator)[person_number].content = "#{person.first_name} #{person.last_name}"
        end
      end
    end
  end

  def load_datastream(id)
    resource = self.load_instance(id)
    content = resource.content
    return content
  end
  
  def insert_new_node(type, opts)
    ds = self.datastreams_in_memory["descMetadata"]
    node, index = ds.insert_node(type, opts)
    return node, index
  end

  def remove_child(type, index)
    ds = self.datastreams_in_memory["descMetadata"]
    result = ds.remove_node(type,index)
    return result
  end
  
end
