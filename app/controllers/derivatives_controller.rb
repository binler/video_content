require 'net/http'
require 'mediashelf/active_fedora_helper'
#require "#{RAILS_ROOT}/vendor/pluggins/video_content/app/models/pbcore_xml.rb"

class DerivativesController < CatalogController
  include Hydra::AssetsControllerHelper
  include Hydra::FileAssetsHelper  
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  include WhiteListHelper
  include Blacklight::CatalogHelper
  include ApplicationHelper
  include DerivativesControllerHelper

  helper :hydra, :metadata, :infusion_view

  #before_filter :initialize_collection, :except=>[:index, :new]
  before_filter :require_solr, :require_fedora, :only=>[:show, :edit, :index, :new, :update, :add, :removenode]
  def index
    @events = Derivative.find_by_solr(:all).hits.map{|result| Derivative.load_instance_from_solr(result["id"])}
  end

  def update
    af_model = retrieve_af_model(params[:content_type])
    unless af_model 
      af_model = Derivative
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
    logger.debug("returning #{response.inspect}")

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
      if params.keys.include?"level"
        if params[:id]
	  @parent = af_model.load_instance(params[:id])
	  parent_id = ""
          if(@parent.level.eql?"1")
            parent_id = params[:id]
          else
	    parent_id = @parent.member_of.first.pid
	  end
          @asset = create_and_save_derivative(af_model, parent_id, params[:level])
        end
      elsif
        @asset = create_and_save_derivative(af_model, params[:master_id])
      end
    end
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :content_type => params[:content_type], :master_id => params[:master_id], :event_id => params[:event_id])
  end

  def add
    @asset = Derivative.load_instance(params[:id])
    @asset.insert_new_node(params[:field_type], {"descMetadata"=>params[:text_field]})
    @asset.save

    url_params = {
      :action       => 'edit',
      :controller   => 'catalog',
      :id           => @asset.pid,
      :content_type => params[:content_type]
    }
    # NOTE anchor tag is defined in edit event view code
    url_params[:anchor] = "assetlink_#{get_last_assetlink_count(@asset)}" if params[:content_type] == 'derivative'
    redirect_to url_for(url_params)
  end

  def removenode
    @asset = Derivative.load_instance(params[:id])
    @asset.remove_child(params[:nodetype], params[:node_counter])
    @asset.save
    index = get_prev_assetlink_count(@asset,params[:node_counter].to_i)
    index == -1 ? anchor = "links" : anchor = "assetlink_#{index}" 
    redirect_to url_for(:action=>"edit", :controller=>"catalog", :label => params[:label], :id=>@asset.pid, :anchor=>anchor)
  end

  def show
    show_without_customizations
  end

  def trigger
    workflow = DerivativeWorkflow.find_by_pid(params[:id])
    events_to_fire = params[:derivative][:events_to_fire].map{ |event| event.to_sym }
    # NOTE: comment handling makes the assumption that events will be triggered one at a time.
    comments = params[:derivative][:state_transition_comments]
    events_to_fire.each do |state_event|
      if can? state_event, DerivativeWorkflow
        workflow.state_transition_comments = comments
        workflow.from_address = current_user.email
        workflow.fire_events(state_event)
      end
    end
    redirect_to edit_catalog_path(params[:id])
  end

  private 

  def get_last_assetlink_count(asset)
    pbparts = asset.datastreams_in_memory["descMetadata"].find_by_terms(:pbcorePart, :pbcorePart)
    count = 0
    last_link_index = -1
    pbparts.each do|pbpart|
      last_link_index = count if pbpart.inspect.include?("ASSET LINK")
      count = count + 1
    end
    last_link_index
  end

  def get_prev_assetlink_count(asset, count)
    pbparts = asset.datastreams_in_memory["descMetadata"].find_by_terms(:pbcorePart, :pbcorePart)
    index = 0
    prev_link_index = -1
    pbparts.each do|pbpart|
      prev_link_index = index if pbpart.inspect.include?("ASSET LINK") && index < count
      index = index + 1
    end
    prev_link_index
  end
end
