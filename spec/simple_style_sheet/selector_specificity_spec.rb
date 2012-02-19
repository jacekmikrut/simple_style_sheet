require "spec_helper"

describe SimpleStyleSheet::SelectorSpecificity do

  describe "#<=>" do
    subject     { described_class.new(      *abcd) }
    let(:other) { described_class.new(*other_abcd) }

    context "(0,2,0,0) <=> (0,2,0,0)" do
      let(      :abcd) { %W(0 2 0 0) }
      let(:other_abcd) { %W(0 2 0 0) }
      it { (subject <=> other).should == 0 }
    end

    context "(0,0,0,3) <=> (0,0,0,2)" do
      let(      :abcd) { %W(0 0 0 3) }
      let(:other_abcd) { %W(0 0 0 2) }
      it { (subject <=> other).should == 1 }
    end

    context "(0,2,3,4) <=> (1,0,0,0)" do
      let(      :abcd) { %W(0 2 3 4) }
      let(:other_abcd) { %W(1 0 0 0) }
      it { (subject <=> other).should == -1 }
    end
  end

  describe "#+" do
    context "(1,2,3,5) + (3,4,5,6)" do
      subject { described_class.new(1,2,3,4) }
      let(:other) { described_class.new(3,4,5,6) }

      it { (subject + other).should eq(described_class.new(4,6,8,10)) }
      it "should be a new instance" do
        (subject + other).should_not equal(subject)
        (subject + other).should_not equal(other)
      end
    end
  end

  describe "#to_s" do
    context "(4,3,2,1).to_s" do
      it { described_class.new(4,3,2,1).to_s.should == "4,3,2,1" }
    end
  end

  describe "#inspect" do
    context "(4,3,2,1).inspect" do
      it { described_class.new(4,3,2,1).inspect.should == "#<SimpleStyleSheet::SelectorSpecificity \"4,3,2,1\">" }
    end
  end
end
