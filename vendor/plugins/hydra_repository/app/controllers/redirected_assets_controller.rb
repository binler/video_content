class RedirectedAssetsController < ApplicationController
  
  include Hydra::AssetsControllerHelper
  include Hydra::RedirectedAssetsHelper
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
      extra_controller_params =  {:q=>"is_part_of_s:#{escaped_uri} and has_model_field:info\:fedora/afmodel\:RedirectedAsset"}
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
      # @solr_result = ActiveFedora::SolrService.instance.conn.query('has_model_field:info\:fedora/afmodel\:RedirectedAsset', @search_params)
      @solr_result = RedirectedAsset.find_by_solr(:all)
    end
    render :action=>params[:action], :layout=>layout
  end

  def new
    render :partial=>"new", :layout=>false
  end

  def create
    begin
    @new_redirected = create_and_save_redirected_asset_from_params

    apply_depositor_metadata(@new_redirected)
        
    if !params[:container_id].nil?
      @container =  ActiveFedora::Base.load_instance(params[:container_id])
      @container.file_objects_append(@new_redirected)
      @container.save
    end
    rescue Exception => e
      flash[:notice] = "Failed to create link: invalid url"
      logger.error("Failed to create link: #{e.message}")
    end
    redirect_to catalog_path(params[:container_id],:anchor=>'link_fields')
  end

   def show
    @redirected_asset = RedirectedAsset.find(params[:id])
    if (@redirected_asset.nil?)
      logger.warn("No such redirected asset: " + params[:id])
      flash[:notice]= "No such redirected asset."
      redirect_to(:action => 'index', :q => nil , :f => nil)
    else
      # get array of parent (container) objects for this RedirectedAsset
      @id_array = @redirected_asset.containers(:response_format => :id_array)
      @downloadable = false
      # A RedirectedAsset is downloadable iff the user has read or higher access to a parent
      @id_array.each do |pid|
        @response, @document = get_solr_response_for_doc_id(pid)
        if reader?
          @downloadable = true
          break
        end
      end

      if @downloadable
        #logger.debug("Redirected asset: #{@redirected_asset.inspect}")
        unless @redirected_asset.link.empty?
          redirect_to "#{@redirected_asset.link.first.url}/content"
        else
          logger.warn("Link undefined for redirected asset: " + params[:id])
          flash[:notice]= "Link undefined for redirected asset."
          redirect_to(:action => 'index', :q => nil , :f => nil)
        end
      else
        flash[:notice]= "You do not have sufficient access privileges to download this document, which has been marked private."
        redirect_to(:action => 'index', :q => nil , :f => nil)
      end
    end
  end
end
