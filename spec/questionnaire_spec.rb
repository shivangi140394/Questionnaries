# questionnaire_spec.rb

require "pstore"
require_relative '../questionnaire'


RSpec.describe "Questionnaire" do

  let(:test_responses) do
    {
      "q1" => "yes",
      "q2" => "no",
      "q3" => "yes",
      "q4" => "yes",
      "q5" => "no"
    }
  end

  store = PStore.new(STORE_NAME)

  describe "#do_prompt" do
    let(:dummy_responses) { { "q1" => "yes", "q2" => "no", "q3" => "yes", "q4" => "yes", "q5" => "no" } }

    before do
      allow_any_instance_of(Kernel).to receive(:gets).and_return("yes", "no", "yes", "yes", "no")
    end

    it "should prompt the user for responses and return a hash of responses" do
      expect(do_prompt).to eq(dummy_responses)
    end

    context "when no input is received" do
      before do
        allow_any_instance_of(Kernel).to receive(:gets).and_return(nil)
      end

      it "should return an empty hash" do
        expect(do_prompt).to eq({})
      end
    end
  end

  describe "#calculate_rating" do
    let(:responses) { { "q1" => "yes", "q2" => "no", "q3" => "yes", "q4" => "yes", "q5" => "no" } }

    it "should calculate the rating based on the responses" do
      expect(calculate_rating(responses)).to eq(60.0)
    end
  end

  describe "#do_report" do
    let(:store_name) { "test_store.pstore" }
    let(:store) { PStore.new(store_name) }
    let(:dummy_responses) { [{ "q1" => "yes", "q2" => "no", "q3" => "yes", "q4" => "yes", "q5" => "no" }] }

    before do
      allow_any_instance_of(Kernel).to receive(:gets).and_return("yes", "no", "yes", "yes", "no")
      store.transaction do
        store["responses"] = dummy_responses
      end
    end

    it "should report the rating for each run and overall average rating" do
      expect { do_report(store) }.to output(/Rating for this run:/).to_stdout
      expect { do_report(store) }.to output(/Overall average rating for all runs:/).to_stdout
    end
  end
end
