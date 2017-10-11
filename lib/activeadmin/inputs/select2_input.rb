module ActiveAdmin
  module Inputs
    class Select2Input < Formtastic::Inputs::SelectInput
      include Select2::SelectInputExtension
    end
  end
end
