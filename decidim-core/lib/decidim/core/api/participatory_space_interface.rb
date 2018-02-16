# frozen_string_literal: true

module Decidim
  module Core
    module Api
      # This type represents a ParticipatoryProcess.
      ParticipatorySpaceInterface = GraphQL::InterfaceType.define do
        name "ParticipatorySpaceInterface"
        description "A feature inside a participatory space"

        field :id, !types.ID, "The Feature's unique ID"

        field :title, !TranslatedFieldType, "The name of this feature."

        field :features, types[FeatureInterface] do
          resolve ->(participatory_space, _args, ctx) {
            Decidim::Feature.where(
              participatory_space: participatory_space
            )
          }
        end

        resolve_type -> (obj, ctx) {
          obj.manifest.api_type.constantize
        }
      end
    end
  end
end
