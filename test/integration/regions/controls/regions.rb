# frozen_string_literal: true

require 'json'

control 'regions' do
  title 'Ensure regions module results match expectations'
  impact 1.0
  # Remove IPv4/IPv6 values from the results since those are tested in the other
  # controls
  results = JSON.parse(input('output_results_json'),
                       { symbolize_names: true }).transform_values do |value|
    value.reject do |k, _|
      %i[ipv4 ipv6].include?(k)
    end
  end
  expected = JSON.parse(input('output_expected_json'), { symbolize_names: true })

  describe results do
    it { should_not be_nil }
    it { should_not be_empty }
    it { should cmp expected }
  end
end
