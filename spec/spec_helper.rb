# frozen_string_literal: true

# spec_helper.rb is loaded before every spec file (because of --require spec_helper in .rspec).
# Put global RSpec configuration here — things that apply to ALL tests.

RSpec.configure do |config|
  # When you write `expect(x).to eq(y)` instead of the older `x.should eq(y)` syntax,
  # that is the "expect" syntax. Disabling the legacy syntax avoids accidental mixing.
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # This makes RSpec mocks stricter: a double (fake object) will fail if you
  # call a method on it that wasn't explicitly defined on that double.
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Allows `it { is_expected.to ... }` shorthand in examples.
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Run tests in a random order each time to catch order-dependent bugs.
  config.order = :random
  Kernel.srand config.seed
end
