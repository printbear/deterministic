require 'spec_helper'

describe Deterministic::Result do
  include Deterministic::Prelude::Result

  it "can't call Result#new directly" do
   expect { described_class.new(1)}
    .to raise_error(NoMethodError, "private method `new' called for Deterministic::Result:Class")
  end

  it "fmap" do
    expect(Success(1).fmap { |n| n + 1}).to eq Success(2)
    expect(Failure(0).fmap { |n| n + 1}).to eq Failure(1)
  end

  it "map" do
    expect(Success(1).map { |n| Success(n + 1)}).to eq Success(2)
    expect(Failure(0).map { |n| Success(n + 1)}).to eq Failure(0)
  end

  it "+" do
    expect(Success([1]) + Failure([2])).to eq Failure([2])
    expect(Success(1) + Success(1)).to eq Success(2)
    expect(Failure(2) + Success(1)).to eq Failure(2)
    expect(Failure([2]) + Failure([3]) + Success(1)).to eq Failure([2, 3])
    expect(Success([1]) + Success([1])).to eq Success([1, 1])
    expect { Success([1]) + Success(1)}.to raise_error TypeError
  end

  subject { Success(1) }
  # specify { expect(subject).to be_an_instance_of described_class }
  specify { expect(subject).to be_success }
  specify { expect(subject).not_to be_failure }
  specify { expect(subject.success?).to be_truthy }
  specify { expect(subject.failure?).to be_falsey }

  specify { expect(subject).to be_a described_class }
  # specify { expect(subject).to eq(described_class.new(1)) }
  specify { expect(subject.fmap { |v| v + 1} ).to eq Success(2) }
  specify { expect(subject.map { |v| Failure(v + 1) } ).to eq Failure(2) }
  specify { expect(subject.map_err { |v| Failure(v + 1) } ).to eq Success(1) }

  specify { expect(subject.pipe{ |r| raise RuntimeError unless r == Success(1) } ).to eq Success(1) }

  specify { expect(subject.or(Success(2))).to eq Success(1)}
  specify { expect(subject.or_else { Success(2) }).to eq Success(1)}

  specify { expect(subject.and(Success(2))).to eq Success(2)}
  specify { expect(subject.and(Failure(2))).to eq Failure(2)}
  specify { expect(subject.and_then { Success(2) }).to eq Success(2)}
  specify { expect(subject.and_then { Failure(2) }).to eq Failure(2)}


  it "Try" do
    expect(described_class.Try { 1 }).to eq Success(1)
    expect(described_class.Try { raise "error" }.inspect).to eq Failure(RuntimeError.new("error")).inspect
  end

  it "ensure_success!" do
    expect { Success(1).ensure_success! }.not_to raise_error
    expect { Failure(RuntimeError.new("foobar")).ensure_success! }.to raise_error(RuntimeError, "foobar")
  end
end
