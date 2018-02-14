# frozen_string_literal: true

module Decidim
  module Core
    module Api
      # This type represents a ParticipatoryProcess.
      ParticipatorySpaceType = GraphQL::ObjectType.define do
        name "ParticipatorySpace"
        description "A participatory space"

        field :id, !types.ID, "The Space unique ID"

        field :features, types[FeatureInterface] do
          resolve ->(participatory_space, _args, ctx) {
            Decidim::Feature.where(
              participatory_space: participatory_space
            )
          }
        end
      end
    end
  end
end
