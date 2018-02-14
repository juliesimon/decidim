# frozen_string_literal: true

module Decidim
  autoload :AuthorInterface, "decidim/core/api/author_interface"
  autoload :TranslatedFieldType, "decidim/core/api/translated_field_type"
  autoload :LocalizedStringType, "decidim/core/api/localized_string_type"
  autoload :SessionType, "decidim/core/api/session_type"
  autoload :UserGroupType, "decidim/core/api/user_group_type"
  autoload :UserType, "decidim/core/api/user_type"
  autoload :DecidimType, "decidim/core/api/decidim_type"

  module Core
    module Api
      autoload :ParticipatorySpaceType, "decidim/core/api/participatory_space_type"
      autoload :FeatureInterface, "decidim/core/api/feature_interface"
      autoload :FeatureType, "decidim/core/api/feature_type"
    end
  end
end
