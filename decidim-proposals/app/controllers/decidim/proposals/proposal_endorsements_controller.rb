# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal endorsement resource so that users can endorse proposals.
    class ProposalEndorsementsController < Decidim::Proposals::ApplicationController
      helper_method :proposal

      protect_from_forgery except: [:destroy, :create]
      before_action :authenticate_user!

      def create
        authorize! :endorse, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"
        user_group_id = params[:user_group_id]

        EndorseProposal.call(proposal, current_user, user_group_id) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end

          on(:invalid) do
            render json: { error: I18n.t("proposal_endorsements.create.error", scope: "decidim.proposals") }, status: 422
          end
        end
      end

      def destroy
        authorize! :unendorse, proposal
        @from_proposals_list = params[:from_proposals_list] == "true"
        user_group_id = params[:user_group_id]
        user_group = current_user.user_groups.verified.find(user_group_id) if user_group_id

        UnendorseProposal.call(proposal, current_user, user_group) do
          on(:ok) do
            proposal.reload
            render :update_buttons_and_counters
          end
        end
      end

      def identities
        authorize! :endorse, proposal

        @user_verified_groups = current_user.user_groups.verified
        render :identities, layout: false
      end

      private

      def proposal
        @proposal ||= Proposal.where(feature: current_feature).find(params[:proposal_id])
      end
    end
  end
end
