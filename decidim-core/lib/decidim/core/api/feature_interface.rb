# frozen_string_literal: true

module Decidim
  module Core
    module Api
      # This type represents a ParticipatoryProcess.
      FeatureInterface = GraphQL::InterfaceType.define do
        name "FeatureInterface"
        description "A feature inside a participatory space"

        field :id, !types.ID, "The Feature's unique ID"

        field :name, !TranslatedFieldType, "The name of this feature."

        resolve_type -> (obj, ctx) {
          obj.manifest.api_type.constantize
        }
      end
    end
  end
end
