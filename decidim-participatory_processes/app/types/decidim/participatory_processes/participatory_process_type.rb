# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This type represents a ParticipatoryProcess.
    ParticipatoryProcessType = GraphQL::ObjectType.define do
      interfaces [Decidim::Core::Api::ParticipatorySpaceInterface]

      name "ParticipatoryProcess"
      description "A participatory process"
    end
  end
end
