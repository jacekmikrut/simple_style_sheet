require "spec_helper"

describe SimpleStyleSheet::Handler do

  describe "#populate" do

    STYLE_SHEETS = []
    MAPS = []

    STYLE_SHEETS << {}
    MAPS << {}

    STYLE_SHEETS << {
      "property_a" => :value_a1,

      "tag_a .class" => {
        "property_a" => :value_a2,

        "tag_b" => {
          "property_a" => :value_a3,
          "property_b" => :value_b1,
        },

        "#id" => {
          "property_a" => :value_a4,
          "property_c" => :value_c1,
        },
      }
    }
    MAPS << {
      "property_a" => [
        { :value => :value_a1, :selector => SimpleStyleSheet::Selector.new("") },
        { :value => :value_a2, :selector => SimpleStyleSheet::Selector.new("tag_a .class") },
        { :value => :value_a3, :selector => SimpleStyleSheet::Selector.new("tag_a .class tag_b") },
        { :value => :value_a4, :selector => SimpleStyleSheet::Selector.new("tag_a .class #id") },
      ],
      "property_b" => [
        { :value => :value_b1, :selector => SimpleStyleSheet::Selector.new("tag_a .class tag_b") },
      ],
      "property_c" => [
        { :value => :value_c1, :selector => SimpleStyleSheet::Selector.new("tag_a .class #id") },
      ],
    }

    STYLE_SHEETS.size.times do |index|

      context "for style sheet: #{STYLE_SHEETS[index]}" do
        it "should produce @map: #{MAPS[index]}" do
          SimpleStyleSheet::Handler.new(STYLE_SHEETS[index]).instance_variable_get("@map").should eq(MAPS[index])
        end
      end

    end
  end

  describe "#value_for" do
    subject do
      subject = SimpleStyleSheet::Handler.new({})
      subject.instance_variable_set("@map", {
        "property" => [
          { :value => "value A", :selector => selector_a },
          { :value => "value B", :selector => selector_b },
          { :value => "value C", :selector => selector_c },
          { :value => "value D", :selector => selector_d },
        ],
        "other-property" => [
          { :value => "value E", :selector => selector_e },
        ]
      })
      subject
    end

    let(:tag) { stub(:tag) }

    let(:selector_a) { stub(:selector_a, :specificity => SimpleStyleSheet::SelectorSpecificity.new(0,1,0,0)) }
    let(:selector_b) { stub(:selector_b, :specificity => SimpleStyleSheet::SelectorSpecificity.new(0,0,0,2)) }
    let(:selector_c) { stub(:selector_c, :specificity => SimpleStyleSheet::SelectorSpecificity.new(0,0,1,0)) }
    let(:selector_d) { stub(:selector_d, :specificity => SimpleStyleSheet::SelectorSpecificity.new(0,0,0,1)) }
    let(:selector_e) { stub(:selector_e, :specificity => SimpleStyleSheet::SelectorSpecificity.new(0,2,0,0)) }

    context "when there are many matching selectors" do
      before do
        selector_a.stub(:match?).with(tag).and_return(false)
        selector_b.stub(:match?).with(tag).and_return(true)
        selector_c.stub(:match?).with(tag).and_return(true)
        selector_d.stub(:match?).with(tag).and_return(true)
        selector_e.stub(:match?).with(tag).and_return(true)
      end

      it "should return matching selector of greatest specificity, for given property" do
        subject.value_for(tag, "property").should eq("value C")
      end
    end

    context "when there is no matching selector" do
      before do
        selector_a.stub(:match?).with(tag).and_return(false)
        selector_b.stub(:match?).with(tag).and_return(false)
        selector_c.stub(:match?).with(tag).and_return(false)
        selector_d.stub(:match?).with(tag).and_return(false)
        selector_e.stub(:match?).with(tag).and_return(true)
      end

      it "should return nil" do
        subject.value_for(tag, "property").should be_nil
      end
    end

    context "when there is no such property" do
      it "should return nil" do
        subject.value_for(tag, "unknown-property").should be_nil
      end
    end
  end
end
