# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    module Admin
      # A command that sets a step in a participatory process as active (and
      # unsets a previous active step)
      class ActivateParticipatoryProcessStep < Rectify::Command
        # Public: Initializes the command.
        #
        # step - A ParticipatoryProcessStep that will be activated
        def initialize(step)
          @step = step
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if step.nil? || step.active?

          Decidim::ParticipatoryProcessStep.transaction do
            deactivate_active_steps
            activate_step
            notify_followers
            publish_step_settings_change
          end

          broadcast(:ok)
        end

        private

        attr_reader :step

        def deactivate_active_steps
          step.participatory_process.steps.where(active: true).each do |step|
            @previous_step = step if step.active?
            step.update_attributes!(active: false)
          end
        end

        def activate_step
          step.update_attributes!(active: true)
        end

        def notify_followers
          Decidim::EventsManager.publish(
            event: "decidim.events.participatory_process.step_activated",
            event_class: Decidim::ParticipatoryProcessStepActivatedEvent,
            resource: step,
            recipient_ids: step.participatory_process.followers.pluck(:id)
          )
        end

        def publish_step_settings_change
          step.participatory_process.features.each do |feature|
            ActiveSupport::Notifications.publish(
              "decidim.participatory_spaces.settings_change",
              participatory_process_id: step.participatory_process_id,
              feature_id: feature.id,
              step_id: step.id,
              previous_step_id: @previous_step.try(:id),
              current_step_settings: current_step_settings(feature),
              previous_step_settings: previous_step_settings(feature)
            )
          end
        end

        def current_step_settings(feature)
          feature.step_settings.fetch(step.id.to_s)
        end

        def previous_step_settings(feature)
          return {} unless @previous_step

          feature.step_settings.fetch(@previous_step.id.to_s)
        end
      end
    end
  end
end
