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
    m.field 'workflow_state', :string
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

  def composite_id
    unless parent.nil? || !parent.respond_to?(:composite_id)
      "#{parent.composite_id} #{derivative_id}"
    else
      derivative_id
    end
  end

  def parent
    member_of.first if member_of.any?
  end

  def owner
    num_creators = self.datastreams["descMetadata"].get_values([:pbcorePart, :pbcoreCreator]).size
    i = 0
    while i < num_creators do
      if self.datastreams["descMetadata"].get_values([:pbcorePart, {:pbcoreCreator => i}, :creator, :creator_annotation]).to_s.eql?"owner"
        values = self.datastreams["descMetadata"].get_values([:pbcorePart, {:pbcoreCreator => i}, :creator])
        return values.first unless values.empty?
      end
      i = i+1
    end
    nil
  end

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
      #owner_index = 0
      #while(i < creators.size)
      #  if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{i}"}, :creator, :creator_annotation)[person_number].content.to_s.eql?"owner")
      #     owner_index = i
      #  end
      #i = i + 1
      #end
      #if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{owner_index}"}, :creator, :creator_annotation)[person_number].content.to_s.eql?"owner")
      #  if(desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{owner_index}"}, :creator)[person_number].content.to_s.empty?)
      #    desc_ds.find_by_terms(:pbcorePart, {:pbcoreCreator => "#{owner_index}"}, :creator)[person_number].content = "#{person.first_name} #{person.last_name}"
      #  end
      #end
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

  def workflow
    @workflow ||= DerivativeWorkflow.find_or_create_by_pid(pid)
  end

  # Favoring explicit delegation for now. Perhaps method_missing should be implemented later.
  # Delegate state machine interactions to workflow
  [:state, :state_events, :state_transitions, :fire_events, :abilities_affected_by_state_change, :state_transition_comments,
   :restrict_editing_to_archival_groups?, :restrict_editing_to_archival_fields? ].each do |method|
    delegate method, :to => :workflow
  end

  DerivativeWorkflow.state_query_methods.each do |method|
    delegate method, :to => :workflow
  end

  # Delegate group and permission information to workflow
  [:groups].each do |method|
    delegate method, :to => :workflow
  end

  def class_name
    self.class.name
  end

  def to_solr(solr_doc = Solr::Document.new, opts={})
    doc = super(solr_doc, opts)
    doc << { :object_type_t => class_name.downcase }
    doc << { :object_type_facet => class_name }
    doc << { :object_state_t => state }
    doc << { :object_state_facet => state.titleize }
    return doc
  end

end
