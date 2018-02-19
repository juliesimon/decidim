# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Core
    describe ParticipatorySpaceType do
      include_context "with a graphql type"

      let(:model) { create(:participatory_process) }

      let!(:published_components) do 
        create_list(:dummy_feature, 2, participatory_space: model, published_at: Time.now)
      end

      let!(:unpublished_components) do 
        create_list(:dummy_feature, 2, participatory_space: model)
      end

      describe "title" do
        let(:query) { %[{ title { translation(locale: "en") } }] }

        it "returns the space's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end
    end
  end
end
