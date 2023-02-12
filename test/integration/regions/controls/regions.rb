# frozen_string_literal: true

control 'regions' do
  title 'Ensure regions module results match expectations'
  impact 1.0
  results = JSON.parse(input('output_results_json'), { symbolize_names: true })
  expected = JSON.parse(input('output_expected_json'), { symbolize_names: true })

  describe results do
    it { should_not be_nil }
    it { should_not be_empty }
    it { should cmp expected }
  end
end
