require "spec_helper"

describe SimpleStyleSheet::Selector do

  describe "instance" do

    describe ".new('')" do
      subject { described_class.new('') }
      its(:empty?     ) { should be_true }
      its(:to_s       ) { should == ''   }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::Selector "">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,0,0,0)) }
    end

    describe ".new('tag.class')" do
      subject { described_class.new('tag.class') }
      its(:empty?     ) { should be_false       }
      its(:to_s       ) { should == 'tag.class' }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::Selector "tag.class">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,0,1,1)) }
    end

    describe ".new('tag.class #id .class')" do
      subject { described_class.new('tag.class #id .class') }
      its(:empty?     ) { should be_false       }
      its(:to_s       ) { should == 'tag.class #id .class' }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::Selector "tag.class #id .class">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,1,2,1)) }
    end
  end

  describe "#concat" do

    describe 'SimpleStyleSheet::Selector.new("tag#id")' do
      let(:selector) { described_class.new("tag#id") }

      context '.concat(".class")' do
        subject { selector.concat(".class") }

        it("should return itself") { should equal(selector) }
        it { should eq(described_class.new("tag#id .class")) }
      end
    end
  end

  describe "#+" do
    let(:duplicated_selector) { stub(:duplicated_selector) }
    let(:string             ) { stub(:string             ) }

    it "should return the result of #concat called on duplicated resource" do
      subject.should_receive(:duplicate).with(no_args).and_return(duplicated_selector)
      duplicated_selector.should_receive(:concat).with(string)

      subject + string
    end
  end

  describe "#match?" do

    context 'called with tag structure: <tag_a id="a"><tag_b class="b"></tag_b></tag_a>' do
      let(:tag) do
        stub(:tag_a, :name => "tag_b", :id => nil, :class_names => ["b"],
             :parent => stub(:tag_a, :name => "tag_a", :id => "a", :class_names => [], :parent => nil))
      end

      describe '.new("").match?' do
        subject { described_class.new("").match?(tag) }
        it { should be_true }
      end

      describe '.new("tag_b").match?' do
        subject { described_class.new("tag_b").match?(tag) }
        it { should be_true }
      end

      describe '.new(".b").match?' do
        subject { described_class.new(".b").match?(tag) }
        it { should be_true }
      end

      describe '.new("tag_b.b").match?' do
        subject { described_class.new("tag_b.b").match?(tag) }
        it { should be_true }
      end

      describe '.new("tag_a tag_b").match?' do
        subject { described_class.new("tag_a tag_b").match?(tag) }
        it { should be_true }
      end

      describe '.new("#a .b").match?' do
        subject { described_class.new("#a .b").match?(tag) }
        it { should be_true }
      end

      describe '.new("tag_a").match?' do
        subject { described_class.new("tag_a").match?(tag) }
        it { should be_false }
      end

      describe '.new("#a").match?' do
        subject { described_class.new("#a").match?(tag) }
        it { should be_false }
      end

      describe '.new("tag tag_b").match?' do
        subject { described_class.new("tag tag_b").match?(tag) }
        it { should be_false }
      end
    end
  end

  describe "#==" do
    subject { described_class.new("tag_a") }

    context "when self.to_s == other.to_s" do
      let(:other) { stub(:other, :to_s => "tag_a") }
      it { (subject == other).should be_true }
    end

    context "when self.to_s != other.to_s" do
      let(:other) { stub(:other, :to_s => "tag_b") }
      it { (subject == other).should be_false }
    end
  end

  describe "#duplicate" do

    it "should return instance of SimpleStyleSheet::Selector" do
      subject.duplicate.should be_a(SimpleStyleSheet::Selector)
    end

    it "should not return the subject" do
      subject.duplicate.should_not equal(subject)
    end

    describe "duplicated instance's @segments variable" do

      it "should have the same content as the original one" do
        subject.duplicate.instance_variable_get("@segments").should
          eq(subject.instance_variable_get("@segments"))
      end

      it "should not be the original variable" do
        subject.duplicate.instance_variable_get("@segments").should_not
          equal(subject.instance_variable_get("@segments"))
      end
    end

    describe "duplicated instance's @specificity variable" do

      it "should have the same content as the original one" do
        subject.duplicate.instance_variable_get("@specificity").should
          eq(subject.instance_variable_get("@specificity"))
      end

      it "should not be the original variable" do
        subject.duplicate.instance_variable_get("@specificity").should_not
          equal(subject.instance_variable_get("@specificity"))
      end
    end
  end
end
