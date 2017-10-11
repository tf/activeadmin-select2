require 'activeadmin/select2/engine'
require 'activeadmin/select2/filter_select_input_extension.rb'
require 'activeadmin/select2/option_collection'
require 'activeadmin/select2/resource_extension'
require 'activeadmin/select2/resource_dsl_extension'
require 'activeadmin/select2/select_input_extension'
require 'activeadmin/inputs/filter_select2_multiple_input.rb'

ActiveAdmin::Inputs::Filters::SelectInput.send :include, ActiveAdmin::Select2::Inputs::FilterSelectInputExtension

ActiveAdmin::Resource.send :include, ActiveAdmin::Select2::ResourceExtension
ActiveAdmin::ResourceDSL.send :include, ActiveAdmin::Select2::ResourceDSLExtension
