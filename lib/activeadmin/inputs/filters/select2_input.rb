module ActiveAdmin
  module Inputs
    module Filters
      class Select2Input < SelectInput
        include Select2::SelectInputExtension
      end
    end
  end
end
