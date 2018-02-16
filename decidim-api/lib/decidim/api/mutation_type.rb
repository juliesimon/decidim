# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root mutation type of the whole API
    MutationType = GraphQL::ObjectType.define do
      name "Mutation"
      description "The root mutation of this schema"

      Api.mutation_extensions.each do |name|
        name.constantize.extend!(self)
      end
    end
  end
end
