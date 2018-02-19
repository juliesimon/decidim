# frozen_string_literal: true

module Decidim
  module Api
    # Main GraphQL schema for decidim's API.
    Schema = GraphQL::Schema.define do
      query QueryType
      mutation MutationType

      default_max_page_size 50
      max_depth 10
      max_complexity 300

      orphan_types(
        Decidim.feature_manifests.map(&:api_type).map(&:constantize).uniq +
        Decidim.participatory_space_manifests.map(&:api_type).map(&:constantize).uniq
      )

      resolve_type ->(_type, _obj) {}
    end
  end
end
