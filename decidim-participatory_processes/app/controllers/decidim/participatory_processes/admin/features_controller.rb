# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # Controller that allows managing the Participatory Process' Features in the
      # admin panel.
      #
      class FeaturesController < Decidim::Admin::FeaturesController
        include Concerns::ParticipatoryProcessAdmin

        # We don't need to publish anything here since it's done when a step is activated.
        def handle_feature_settings_change(_previous_settings, _current_settings); end
      end
    end
  end
end
