# frozen_string_literal: true

require "spec_helper"

describe Decidim::Debates::Admin::CreateDebate do
  subject { described_class.new(form) }

  let(:organization) { create :organization, available_locales: [:en, :ca, :es], default_locale: :en }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:current_feature) { create :feature, participatory_space: participatory_process, manifest_name: "debates" }
  let(:category) { create :category, participatory_space: participatory_process }
  let(:form) do
    double(
      invalid?: invalid,
      title: { en: "title" },
      description: { en: "description" },
      information_updates: { en: "information updates" },
      instructions: { en: "instructions" },
      start_time: 1.day.from_now,
      end_time: 1.day.from_now + 1.hour,
      category: category,
      current_feature: current_feature
    )
  end
  let(:invalid) { false }

  context "when the form is not valid" do
    let(:invalid) { true }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:debate) { Decidim::Debates::Debate.last }

    it "creates the debate" do
      expect { subject.call }.to change { Decidim::Debates::Debate.count }.by(1)
    end

    it "sets the category" do
      subject.call
      expect(debate.category).to eq category
    end

    it "sets the feature" do
      subject.call
      expect(debate.feature).to eq current_feature
    end

    describe "events" do
      let(:space_follower) { create(:user, organization: organization) }
      let!(:space_follow) { create :follow, followable: participatory_process, user: space_follower }

      it "notifies the change to the author followers" do
        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.debates.debate_created",
            event_class: Decidim::Debates::CreateDebateEvent,
            resource: kind_of(Decidim::Debates::Debate),
            recipient_ids: [space_follower.id],
            extra: { type: "participatory_space" }
          )

        subject.call
      end
    end
  end
end
