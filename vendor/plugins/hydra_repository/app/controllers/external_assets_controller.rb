class ExternalAssetsController < ApplicationController
  
  include Hydra::AssetsControllerHelper
  include Hydra::ExternalAssetsHelper
  include Hydra::RepositoryController  
  include MediaShelf::ActiveFedoraHelper
  include Blacklight::SolrHelper
  
  before_filter :require_fedora
  before_filter :require_solr, :only=>[:index, :create, :show, :destroy]

  def index
    if params[:layout] == "false"
      # action = "index_embedded"
      layout = false
    end
    if !params[:container_id].nil?
      container_uri = "info:fedora/#{params[:container_id]}"
      escaped_uri = container_uri.gsub(/(:)/, '\\:')
      extra_controller_params =  {:q=>"is_part_of_s:#{escaped_uri} and has_model_field:info\:fedora/afmodel\:ExternalAsset"}
      @response, @document_list = get_search_results( extra_controller_params )
      
      # Including this line so permissions tests can be run against the container
      @container_response, @document = get_solr_response_for_doc_id(params[:container_id])
      
      # Including these lines for backwards compatibility (until we can use Rails3 callbacks)
      @container =  ActiveFedora::Base.load_instance(params[:container_id])
      @solr_result = @container.file_objects(:response_format=>:solr)
      @solr_result.each do |result|
        logger.debug("{result.inspect}")
      end
    else
      # @solr_result = ActiveFedora::SolrService.instance.conn.query('has_model_field:info\:fedora/afmodel\:ExternalAsset', @search_params)
      @solr_result = ExternalAsset.find_by_solr(:all)
    end
    render :action=>params[:action], :layout=>layout
  end

  def new
    render :partial=>"new", :layout=>false
  end

  def create
    begin
    @new_external_asset = create_and_save_external_asset_from_params

    apply_depositor_metadata(@new_external_asset)
        
    if !params[:container_id].nil?
      @container =  ActiveFedora::Base.load_instance(params[:container_id])
      @container.file_objects_append(@new_link)
      @container.save
    end
    rescue Exception => e
      flash[:notice] = "Failed to create link: invalid url"
      logger.error("Failed to create link: #{e.message}")
    end
    redirect_to catalog_path(params[:container_id],:anchor=>'files')
  end

   def show
    @external_asset = ExternalAsset.find(params[:id])
    if (@external_asset.nil?)
      logger.warn("No such external file asset: " + params[:id])
      flash[:notice]= "No such external file asset."
      redirect_to(:action => 'index', :q => nil , :f => nil)
    else
      # get array of parent (container) objects for this ExternalAsset
      @id_array = @external_asset.containers(:response_format => :id_array)
      @downloadable = false
      # A ExternalAsset is downloadable iff the user has read or higher access to a parent
      @id_array.each do |pid|
        @response, @document = get_solr_response_for_doc_id(pid)
        if reader?
          @downloadable = true
          break
        end
      end

      if @downloadable
        #logger.debug("External asset: #{@external_asset.inspect}")
        unless @external_asset.link.empty?
          redirect_to "#{@external_asset.uri}"
        else
          logger.warn("Link undefined for external asset: " + params[:id])
          flash[:notice]= "Link undefined for external asset."
          redirect_to(:action => 'index', :q => nil , :f => nil)
        end
      else
        flash[:notice]= "You do not have sufficient access privileges to download this document, which has been marked private."
        redirect_to(:action => 'index', :q => nil , :f => nil)
      end
    end
  end
end
