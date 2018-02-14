# frozen_string_literal: true

module Decidim
  module Core
    module Api
      # This type represents a ParticipatoryProcess.
      FeatureType = GraphQL::ObjectType.define do
        interfaces [FeatureInterface]
       
        name "Feature"
        description "A feature"
      end
    end
  end
end
