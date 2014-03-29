require 'spec_helper'
require_relative '../monad_axioms'
require_relative 'either_shared'

include Deterministic

describe Deterministic::Failure do

  it_behaves_like 'a Monad' do
    let(:monad) { described_class }
  end

  subject { described_class.new(1) }

  specify { expect(subject).to be_an_instance_of described_class }
  specify { expect(subject).to be_failure }
  specify { expect(subject).not_to be_success }

  specify { expect(subject).to be_an_instance_of described_class }
  specify { expect(subject).to eq(described_class.new(1)) }
  specify { expect(subject << Success(2)).to eq(Failure(1)) }
  specify { expect(subject << Failure(2)).to eq(Failure(1)) }
  specify { expect(subject.map { |v| v + 1} ).to eq Failure(2) }

  it_behaves_like 'Either' do
    let(:either) { described_class }
  end
end
