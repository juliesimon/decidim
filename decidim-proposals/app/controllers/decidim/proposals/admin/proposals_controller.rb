# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      # This controller allows admins to manage proposals in a participatory process.
      class ProposalsController < Admin::ApplicationController
        helper Proposals::ApplicationHelper
        helper_method :proposals, :query

        def new
          authorize! :create, Proposal
          @form = form(Admin::ProposalForm).from_params(
            attachment: form(AttachmentForm).from_params({})
          )
        end

        def create
          authorize! :create, Proposal
          @form = form(Admin::ProposalForm).from_params(params)

          Admin::CreateProposal.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("proposals.create.success", scope: "decidim.proposals.admin")
              redirect_to proposals_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.create.invalid", scope: "decidim.proposals.admin")
              render action: "new"
            end
          end
        end

        def update_category
          authorize! :update, Proposal

          Admin::UpdateProposalCategory.call(params[:category][:id], params[:proposal_ids]) do
            on(:invalid_category) do
              flash[:alert] = I18n.t(
                "proposals.update_category.select_a_category",
                scope: "decidim.proposals.admin"
              )
            end

            on(:invalid_proposal_ids) do
              flash[:alert] = I18n.t(
                "proposals.update_category.select_a_proposal",
                scope: "decidim.proposals.admin"
              )
            end

            on(:update_proposals_category) do
              if @response[:oks].present?
                flash[:notice] = I18n.t(
                  "proposals.update_category.success",
                  category: @response[:category_name],
                  proposals: @response[:oks].to_sentence,
                  scope: "decidim.proposals.admin"
                )
              end

              if @response[:kos].present?
                flash[:alert] = I18n.t(
                  "proposals.update_category.invalid",
                  category: @response[:category_name],
                  proposals: @response[:kos].to_sentence,
                  scope: "decidim.proposals.admin"
                )
              end
            end
          end

          redirect_to proposals_path
        end

        private

        def query
          @query ||= Proposal.where(feature: current_feature).ransack(params[:q])
        end

        def proposals
          @proposals ||= query.result.page(params[:page]).per(15)
        end

        def proposal
          @proposal ||= Proposal.where(feature: current_feature).find(params[:id])
        end
      end
    end
  end
end
