# frozen_string_literal: true

module Decidim
  module Admin
    # A command to invite an admin.
    class InviteAdmin < Rectify::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(form)
        @form = form
      end

      def call
        return broadcast(:invalid) if form.invalid?

        transaction do
          invite_user
          generate_nickname
          log_action
        end

        broadcast(:ok)
      end

      private

      attr_reader :user, :form

      def invite_user
        InviteUser.call(form) do
          on(:ok) do |user|
            save_user(user)
          end
        end
      end

      def generate_nickname
        user.update_attributes(nickname: User.nicknamize(user.name))
      end

      # Ugly fix to get the user from the block inside the
      # `InviteUser#call` method. I'm not proud of this.
      def save_user(user)
        @user = user
      end

      def log_action
        Decidim::ActionLogger.log(
          "invite",
          form.current_user,
          user,
          extra: {
            invited_user_role: form.role,
            invited_user_id: user.id
          }
        )
      end
    end
  end
end
