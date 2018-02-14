# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # Controller that allows managing the Assembly' Features in the
      # admin panel.
      #
      class FeaturesController < Decidim::Admin::FeaturesController
        include Concerns::AssemblyAdmin

        def handle_feature_settings_change(previous_settings, current_settings)
          ActiveSupport::Notifications.publish(
            "decidim.features.settings_change",
            participatory_space_id: @feature.participatory_space.id,
            feature_id: @feature.id,
            current_feature_settings: previous_settings,
            previous_feature_settings: current_settings
          )
        end
      end
    end
  end
end
