# frozen_string_literal: true

require_dependency "decidim/core/participatory_space_interface"

module Decidim
  module Core
    # This type represents a ParticipatoryProcess.
    ParticipatorySpaceType = GraphQL::ObjectType.define do
      interfaces [ParticipatorySpaceInterface]

      name "ParticipatorySpace"
      description "A participatory space"
    end
  end
end
