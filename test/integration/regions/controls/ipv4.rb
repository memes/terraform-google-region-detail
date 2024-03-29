# frozen_string_literal: true

require 'ipaddr'
require 'json'
require 'rspec/expectations'

RSpec::Matchers.define :be_ipv4_cidr do
  match do |cidr|
    IPAddr.new(cidr).ipv4?
  end
end

control 'ipv4' do
  title 'Ensure regions module results have IPv4 CIDRs'
  impact 1.0
  results = JSON.parse(input('output_results_json'), { symbolize_names: true }).transform_values do |value|
    value[:ipv4]
  end

  only_if('Foo-bar1 test region does not have IPv4 CIDRs to verify') do
    !results.include?(:'foo-bar1')
  end

  # NOTE: the published JSON changes frequently, so it is safer to test for the
  # existence of results and that each entry is a valid IPv6 CIDR.
  results.each_value do |cidrs|
    describe cidrs do
      it { should_not be_nil }
      it { should_not be_empty }
    end
    cidrs.each do |cidr|
      describe cidr do
        it { should be_ipv4_cidr }
      end
    end
  end
end
