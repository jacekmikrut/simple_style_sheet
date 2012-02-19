require "spec_helper"

describe SimpleStyleSheet::SelectorSegment do

  describe "instance" do

    describe ".new('tag')" do
      subject { described_class.new('tag') }
      its(:tag_name   ) { should == 'tag' }
      its(:id         ) { should be_nil   }
      its(:class_names) { should == []    }
      its(:to_s       ) { should == 'tag' }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::SelectorSegment "tag">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,0,0,1)) }
    end

    describe ".new('#the_id')" do
      subject { described_class.new('#the_id') }
      its(:tag_name   ) { should be_nil       }
      its(:id         ) { should == 'the_id'  }
      its(:class_names) { should == []        }
      its(:to_s       ) { should == '#the_id' }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::SelectorSegment "#the_id">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,1,0,0)) }
    end

    describe ".new('.class_name')" do
      subject { described_class.new('.class_name') }
      its(:tag_name   ) { should be_nil            }
      its(:id         ) { should be_nil            }
      its(:class_names) { should == ['class_name'] }
      its(:to_s       ) { should == '.class_name'  }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::SelectorSegment ".class_name">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,0,1,0)) }
    end

    describe ".new('tag#the_id.class_name_1.class_name_2')" do
      subject { described_class.new('tag#the_id.class_name_1.class_name_2') }
      its(:tag_name   ) { should == 'tag'                                   }
      its(:id         ) { should == 'the_id'                                }
      its(:class_names) { should == ['class_name_1', 'class_name_2']        }
      its(:to_s       ) { should == 'tag#the_id.class_name_1.class_name_2'  }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::SelectorSegment "tag#the_id.class_name_1.class_name_2">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,1,2,1)) }
    end

    describe ".new('tag.class_name_1.class_name_2#the_id')" do
      subject { described_class.new('tag.class_name_1.class_name_2#the_id') }
      its(:tag_name   ) { should == 'tag'                                   }
      its(:id         ) { should == 'the_id'                                }
      its(:class_names) { should == ['class_name_1', 'class_name_2']        }
      its(:to_s       ) { should == 'tag#the_id.class_name_1.class_name_2'  }
      its(:inspect    ) { should == %Q{#<SimpleStyleSheet::SelectorSegment "tag#the_id.class_name_1.class_name_2">} }
      its(:specificity) { should eq(SimpleStyleSheet::SelectorSpecificity.new(0,1,2,1)) }
    end
  end

  describe "#match?" do
    subject { selector_segment.match?(tag) }

    context '.new("")' do
      let(:selector_segment) { described_class.new("") }

      context 'match? tag with name "tag", no id, no class names' do
        let(:tag) { stub(:tag, :name => "tag", :id => nil, :class_names => []) }
        it { should be_true }
      end

      context 'match? tag with name "tag", "id" id, "class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["class"]) }
        it { should be_true }
      end
    end

    context '.new("tag")' do
      let(:selector_segment) { described_class.new("tag") }

      context 'match? tag with name "tag", "id" id, "class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["class"]) }
        it { should be_true }
      end

      context 'match? tag with name "different_tag", "id" id, "class" class name' do
        let(:tag) { stub(:tag, :name => "different_tag", :id => "id", :class_names => ["class"]) }
        it { should be_false }
      end
    end

    context '.new("#id")' do
      let(:selector_segment) { described_class.new("#id") }

      context 'match? tag with name "tag", no id, "class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => nil, :class_names => ["class"]) }
        it { should be_false }
      end

      context 'match? tag with name "tag", "different_id" id, "class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "different_id", :class_names => ["class"]) }
        it { should be_false }
      end

      context 'match? tag with name "tag", "id" id, "class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["class"]) }
        it { should be_true }
      end
    end

    context '.new(".class")' do
      let(:selector_segment) { described_class.new(".class") }

      context 'match? tag with name "tag", "id" id, no class names' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => []) }
        it { should be_false }
      end

      context 'match? tag with name "tag", "id" id, "some_class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["some_class"]) }
        it { should be_false }
      end

      context 'match? tag with name "tag", "id" id, "class" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["class"]) }
        it { should be_true }
      end

      context 'match? tag with name "tag", "id" id, "other_class" and "class" class names' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["other_class", "class"]) }
        it { should be_true }
      end
    end

    context '.new("tag#id.class_a.class_b")' do
      let(:selector_segment) { described_class.new("tag#id.class_a.class_b") }

      context 'match? tag with name "tag", "id" id, "class_a" class name' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["class_a"]) }
        it { should be_false }
      end

      context 'match? tag with name "tag", no id, "class_a" and "class_b" class names' do
        let(:tag) { stub(:tag, :name => "tag", :id => nil, :class_names => ["class_a", "class_b"]) }
        it { should be_false }
      end

      context 'match? tag with name "different_tag", "id" id, "class_a" and "class_b" class names' do
        let(:tag) { stub(:tag, :name => "different_tag", :id => "id", :class_names => ["class_a", "class_b"]) }
        it { should be_false }
      end

      context 'match? tag with name "tag", "id" id, "class_a" and "class_b" class names' do
        let(:tag) { stub(:tag, :name => "tag", :id => "id", :class_names => ["class_a", "class_b"]) }
        it { should be_true }
      end
    end
  end
end
