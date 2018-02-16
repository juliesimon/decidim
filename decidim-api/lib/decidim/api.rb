# frozen_string_literal: true

require "decidim/api/engine"

module Decidim
  # This module holds all business logic related to exposing a Public API for
  # decidim.
  module Api
    autoload :MutationType, "decidim/api/mutation_type"
    autoload :QueryType, "decidim/api/query_type"
    autoload :Schema, "decidim/api/schema"

    def self.add_query_extension(module_name)
      @query_extensions = query_extensions + [module_name]
    end

    def self.query_extensions
      @query_extensions || []
    end

    def self.add_mutation_extension(module_name)
      @mutation_extensions = mutation_extensions + [module_name]
    end

    def self.mutation_extensions
      @mutation_extensions || []
    end
  end
end
