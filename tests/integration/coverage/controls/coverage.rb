# frozen_string_literal: true

require 'json'

control 'coverage' do
  title 'Ensure the results do not include an unknown region'
  impact 1.0
  results = JSON.parse(input('output_results_json'),
                       { symbolize_names: true }).keep_if do |_, v|
    v[:display_name] == 'Unknown region'
  end

  describe results do
    it { should_not be_nil }
    it { should be_empty }
  end
end
