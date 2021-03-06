# frozen_string_literal: true

module Decidim
  module Proposals
    # The data store for a Proposal in the Decidim::Proposals component.
    class Proposal < Proposals::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::Authorable
      include Decidim::HasFeature
      include Decidim::HasScope
      include Decidim::HasReference
      include Decidim::HasCategory
      include Decidim::Reportable
      include Decidim::HasAttachments
      include Decidim::Followable
      include Decidim::Proposals::CommentableProposal

      feature_manifest_name "proposals"

      has_many :endorsements, foreign_key: "decidim_proposal_id", class_name: "ProposalEndorsement", dependent: :destroy, counter_cache: "proposal_endorsements_count"
      has_many :votes, foreign_key: "decidim_proposal_id", class_name: "ProposalVote", dependent: :destroy, counter_cache: "proposal_votes_count"
      has_many :notes, foreign_key: "decidim_proposal_id", class_name: "ProposalNote", dependent: :destroy, counter_cache: "proposal_notes_count"

      validates :title, :body, presence: true

      geocoded_by :address, http_headers: ->(proposal) { { "Referer" => proposal.feature.organization.host } }

      scope :accepted, -> { where(state: "accepted") }
      scope :rejected, -> { where(state: "rejected") }
      scope :evaluating, -> { where(state: "evaluating") }
      scope :withdrawn, -> { where(state: "withdrawn") }
      scope :except_withdrawn, -> { where.not(state: "withdrawn").or(where(state: nil)) }

      def self.order_randomly(seed)
        transaction do
          connection.execute("SELECT setseed(#{connection.quote(seed)})")
          order("RANDOM()").load
        end
      end

      # Public: Check if the user has voted the proposal.
      #
      # Returns Boolean.
      def voted_by?(user)
        votes.where(author: user).any?
      end

      # Public: Check if the user has endorsed the proposal.
      #
      # Returns Boolean.
      def endorsed_by?(user, user_group = nil)
        endorsements.where(author: user, user_group: user_group).any?
      end

      # Public: Checks if the organization has given an answer for the proposal.
      #
      # Returns Boolean.
      def answered?
        answered_at.present?
      end

      # Public: Checks if the organization has accepted a proposal.
      #
      # Returns Boolean.
      def accepted?
        answered? && state == "accepted"
      end

      # Public: Checks if the organization has rejected a proposal.
      #
      # Returns Boolean.
      def rejected?
        answered? && state == "rejected"
      end

      # Public: Checks if the organization has marked the proposal as evaluating it.
      #
      # Returns Boolean.
      def evaluating?
        answered? && state == "evaluating"
      end

      # Public: Checks if the author has withdrawn the proposal.
      #
      # Returns Boolean.
      def withdrawn?
        state == "withdrawn"
      end

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end

      # Public: Whether the proposal is official or not.
      def official?
        author.nil?
      end

      # Public: The maximum amount of votes allowed for this proposal.
      #
      # Returns an Integer with the maximum amount of votes, nil otherwise.
      def maximum_votes
        maximum_votes = feature.settings.maximum_votes_per_proposal
        return nil if maximum_votes.zero?

        maximum_votes
      end

      # Public: The maximum amount of votes allowed for this proposal. 0 means infinite.
      #
      # Returns true if reached, false otherwise.
      def maximum_votes_reached?
        return false unless maximum_votes

        votes.count >= maximum_votes
      end

      # Checks whether the user can edit the given proposal.
      #
      # user - the user to check for authorship
      def editable_by?(user)
        authored_by?(user) && !answered? && within_edit_time_limit? && !copied_from_other_component?
      end

      # Checks whether the user can withdraw the given proposal.
      #
      # user - the user to check for withdrawability.
      def withdrawable_by?(user)
        user && !withdrawn? && authored_by?(user) && !copied_from_other_component?
      end

      # method for sort_link by number of comments
      ransacker :commentable_comments_count do
        query = <<-SQL
              (SELECT COUNT(decidim_comments_comments.id)
                 FROM decidim_comments_comments
                WHERE decidim_comments_comments.decidim_commentable_id = decidim_proposals_proposals.id
                  AND decidim_comments_comments.decidim_commentable_type = 'Decidim::Proposals::Proposal'
                GROUP BY decidim_comments_comments.decidim_commentable_id
              )
            SQL
        Arel.sql(query)
      end

      private

      # Checks whether the proposal is inside the time window to be editable or not.
      def within_edit_time_limit?
        limit = created_at + feature.settings.proposal_edit_before_minutes.minutes
        Time.current < limit
      end

      def copied_from_other_component?
        linked_resources(:proposals, "copied_from_component").any?
      end
    end
  end
end
