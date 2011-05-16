require 'net/http'
require 'mediashelf/active_fedora_helper'
#require "#{RAILS_ROOT}/vendor/pluggins/video_content/app/models/pbcore_xml.rb"

class EventsController < CatalogController
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include EventsControllerHelper

  helper :hydra, :metadata, :infusion_view

  #before_filter :initialize_collection, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit, :index, :new, :update, :create, :add, :download, :removespeaker, :removenode]
  def index
    @events = Event.find_by_solr(:all).hits.map{|result| Event.load_instance_from_solr(result["id"])}
  end

  def update
    af_model = retrieve_af_model(params[:content_type])
    unless af_model 
      af_model = Event
    end
    @document = af_model.find(params[:id])
    updater_method_args = prep_updater_method_args(params)
    result = @document.update_indexed_attributes(updater_method_args[:params], updater_method_args[:opts])
    apply_depositor_metadata(@document)
    @document.save
    response = Hash["updated"=>[]]
    last_result_value = ""
    result.each_pair do |field_name,changed_values|
      changed_values.each_pair do |index,value|
        response["updated"] << {"field_name"=>field_name,"index"=>index,"value"=>value} 
        last_result_value = value
      end
    end

  # If handling submission from jeditable (which will only submit one value at a time), return the value it submitted
    if params.has_key?(:field_id)
      response = last_result_value
    end

    respond_to do |want| 
      want.js {
        render :json=> response
      }
      want.textile {
        if response.kind_of?(Hash)
          response = response.values.first
        end
        render :text=> white_list( RedCloth.new(response, [:sanitize_html]).to_html )
      }
    end
  end

  def new
    content_type = params[:content_type]
    af_model = retrieve_af_model(content_type)
    if af_model
      @asset = create_and_save_event(af_model)
    end
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :content_type => params[:content_type])
  end

  # Creates new datastream with name COPYRIGHTS for each file upload
  def create
    @asset = Event.find(params[:container_id])
    @asset.save
    render :nothing => true
#    redirect_to url_for(:action=>"edit", :controller=>"catalog", :id=>@asset.pid, :content_type => params[:content_type])
  end

  # Adds a new node for speakers
  def add
    @asset = Event.load_instance(params[:id])
#    @asset.insert_new_node('creator', {"descMetadata"=>"pbcoreDescription_pbcoreCreator"})
    @asset.insert_new_node(params[:field_type], {"descMetadata"=>params[:text_field]})
    if(params[:field_type].eql?"creator")
      creator = @asset.datastreams["descMetadata"].get_values([:pbcoreDescriptionDocument, :pbcoreCreator])
      @asset.update_indexed_attributes({[:pbcoreDescriptionDocument, {:pbcoreCreator => "#{(creator.size)-1}"}, :creatorRole]=>{0=>"producer"}})
    end
    @asset.save

    url_params = {
      :action       => 'edit',
      :controller   => 'catalog',
      :id           => @asset.pid,
      :content_type => params[:content_type]
    }
    # NOTE anchor tag is defined in edit event view code
    
    #find the last index that is a speaker
    url_params[:anchor] = "speaker_#{get_last_speaker_count(@asset)}" if params[:field_type] == 'contributor'
    url_params[:anchor] = "assetlink_#{get_last_assetlink_count(@asset)}" if params[:field_type] == 'assetlink'
    redirect_to url_for(url_params)
  end

  def removenode
    @asset = Event.load_instance(params[:id])
    @asset.remove_child(params[:nodetype], params[:node_counter])
    @asset.save
    if params[:nodetype] == "speaker"
      index = get_prev_speaker_count(@asset,params[:node_counter].to_i)
      index == -1 ? anchor = "speakers" : anchor = "speaker_#{index}" 
    elsif params[:nodetype] == "assetlink"
      index = get_prev_assetlink_count(@asset,params[:node_counter].to_i)
      index == -1 ? anchor = "links" : anchor = "assetlink_#{index}" 
    end
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :anchor=>anchor)
  end

  def show  
    show_without_customizations
  end

  def download
    af_model = retrieve_af_model(params[:content_type])
    @file_asset = af_model.find(params[:id])
    send_datastream @file_asset.datastreams_in_memory["#{params[:ds_name]}"]
  end

  def destroy
  end

  private 

  def get_last_speaker_count(asset)
    pbparts = asset.datastreams_in_memory["descMetadata"].find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
    count = 0
    last_speaker_index = -1
    pbparts.each do|pbpart|
      last_speaker_index = count if pbpart.inspect.include?("speaker")
      count = count + 1
    end
    last_speaker_index
  end

  def get_last_assetlink_count(asset)
    pbparts = asset.datastreams_in_memory["descMetadata"].find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
    count = 0
    last_link_index = -1
    pbparts.each do|pbpart|
      last_link_index = count if pbpart.inspect.include?("ASSET LINK")
      count = count + 1
    end
    last_link_index
  end

  def get_prev_speaker_count(asset, count)
    pbparts = asset.datastreams_in_memory["descMetadata"].find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
    index = 0
    prev_speaker_index = -1
    pbparts.each do|pbpart|
      prev_speaker_index = index if pbpart.inspect.include?("speaker") && index < count
      index = index + 1
    end
    prev_speaker_index
  end

  def get_prev_assetlink_count(asset, count)
    pbparts = asset.datastreams_in_memory["descMetadata"].find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
    index = 0
    prev_link_index = -1
    pbparts.each do|pbpart|
      prev_link_index = index if pbpart.inspect.include?("ASSET LINK") && index < count
      index = index + 1
    end
    prev_link_index
  end

end
