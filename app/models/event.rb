require "hydra"

class Event < ActiveFedora::Base
  
  include Hydra::ModelMethods
  include Hydra::DefaultAccess
  
  has_bidirectional_relationship "members", :has_member, :is_member_of

  # Uses the Hydra Rights Metadata Schema for tracking access permissions & copyright
  has_metadata :name => "rightsMetadata", :type => Hydra::RightsMetadata 
  
  # Uses the PBCore profile for tracking most of the descriptive metadata
  has_metadata :name => "descMetadata", :type => PbcoreXml

  # A place to put extra metadata values
  has_metadata :name => "properties", :type => ActiveFedora::MetadataDatastream do |m|    
    m.field 'depositor', :string
  end

  alias_method :id, :pid

  def initialize(attrs={})
    super(attrs)
    workflow
  end

  def content
    external_file.blank? ? "" : external_file.first.content
  end

  def datastream_url ds_name="content"
    "http://fedoraAdmin:fedoraAdmin@localhost:8983/fedora/get/#{pid}/#{ds_name}"
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

  def event_id
    return @event_id if (defined? @event_id)
    values = self.datastreams["descMetadata"].term_values(:pbcoreDescriptionDocument, :pbcoreIdentifier)
    @event_id = values.any? ? values.first : ""
  end

  alias_method :composite_id, :event_id

  def apply_ldap_values(computing_id, person_number)
    return if computing_id.blank? #|| person_number.blank?
    person = Ldap::Person.new(computing_id)
    desc_ds = self.datastreams_in_memory["descMetadata"]
    return if desc_ds.nil?
    creators = self.datastreams_in_memory["descMetadata"].get_values([:pbcoreDescriptionDocument, :pbcoreCreator, :creator])
    if creators.include? "#{person.first_name} #{person.last_name}"
      return
    else
      if(!(creators[creators.size-1].empty?))
        self.insert_new_node('creator', opts={})
        desc_ds = self.datastreams_in_memory["descMetadata"]
      end
      creators = self.datastreams_in_memory["descMetadata"].get_values([:pbcoreDescriptionDocument, :pbcoreCreator, :creator])
      desc_ds.find_by_terms(:pbcoreDescriptionDocument, {:pbcoreCreator => "#{(creators.size) -1}"}, :creator)[person_number].content = "#{person.first_name} #{person.last_name}"
      desc_ds.find_by_terms(:pbcoreDescriptionDocument, {:pbcoreCreator => "#{(creators.size) -1}"}, :creatorRole)[person_number].content = "#{person.title}"
    end
  end

  def workflow
    @workflow ||= EventWorkflow.find_or_create_by_pid(pid)
  end

  # Favoring explicit delegation for now. Perhaps method_missing should be implemented later.
  # Delegate state machine interactions to workflow
  [:state, :state_events, :fire_events].each do |method|
    delegate method, :to => :workflow
  end

  EventWorkflow.state_query_methods.each do |method|
    delegate method, :to => :workflow
  end

  # Delegate group and permission information to workflow
  [:groups].each do |method|
    delegate method, :to => :workflow
  end

end
