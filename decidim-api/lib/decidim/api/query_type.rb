# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root query type of the whole API.
    QueryType = GraphQL::ObjectType.define do
      name "Query"
      description "The root query of this schema"

      Api.query_extensions.each do |name|
        name.constantize.extend!(self)
      end
    end
  end
end
