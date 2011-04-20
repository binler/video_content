module ApplicationHelper

  require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
  require_dependency 'vendor/plugins/hydra_repository/app/helpers/application_helper.rb'

  def application_name
    'Hydrangea'
  end

  def custom_radio_button(resource, datastream_name, field_key, opts={})
    field_name = field_name_for(field_key)
    field_values = get_values_from_datastream(resource, datastream_name, field_key, opts)
    logger.debug("Field key: #{field_key}")
    logger.debug("Field values: #{field_values.inspect}")
    base_id = generate_base_id(field_name, field_values.first, field_values, opts.merge({:multiple=>false}))
    result = ""
    h_name = OM::XML::Terminology.term_hierarchical_name(*field_key)
    field_values.each_with_index do |current_value, z|
      name = "asset[#{datastream_name}][#{field_name}][#{z}][#{resource.pid}]"
      logger.debug("field_values : #{current_value}")
      result << radio_button_tag (name, opts.first[0], (opts.first[0].to_s==current_value),:data_pid=>resource.pid,
                                  :datastream=>"asset[#{datastream_name}][#{field_name}][#{z}]", :class=>"fieldselector", :rel=>h_name)
      result << " #{opts.first[1]}"
    end
    return result
  end
end
