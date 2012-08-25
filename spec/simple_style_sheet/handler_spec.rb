require "spec_helper"

describe SimpleStyleSheet::Handler do

  describe "#populate" do

    STYLE_SHEETS = []
    MAPS = []

    STYLE_SHEETS << {}
    MAPS << {}

    STYLE_SHEETS << {
      :"tag .class" => {
        "property" => :value
      }
    }
    MAPS << {
      "property" => [
        { :value => :value, :selector => SimpleSelector.new("tag .class") }
      ]
    }

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
        { :value => :value_a1, :selector => SimpleSelector.new("") },
        { :value => :value_a2, :selector => SimpleSelector.new("tag_a .class") },
        { :value => :value_a3, :selector => SimpleSelector.new("tag_a .class tag_b") },
        { :value => :value_a4, :selector => SimpleSelector.new("tag_a .class #id") },
      ],
      "property_b" => [
        { :value => :value_b1, :selector => SimpleSelector.new("tag_a .class tag_b") },
      ],
      "property_c" => [
        { :value => :value_c1, :selector => SimpleSelector.new("tag_a .class #id") },
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

    context "when called with a tag" do
      let(:tag) { stub(:tag) }

      let(:selector_a) { stub(:selector_a, :specificity => SimpleSelector::Specificity.new(0,1,0,0)) }
      let(:selector_b) { stub(:selector_b, :specificity => SimpleSelector::Specificity.new(0,0,0,2)) }
      let(:selector_c) { stub(:selector_c, :specificity => SimpleSelector::Specificity.new(0,0,1,0)) }
      let(:selector_d) { stub(:selector_d, :specificity => SimpleSelector::Specificity.new(0,0,0,1)) }
      let(:selector_e) { stub(:selector_e, :specificity => SimpleSelector::Specificity.new(0,2,0,0)) }

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

    context "when called without a tag" do
      let(:selector_a) { stub(:selector_a, :empty? => true ) }
      let(:selector_b) { stub(:selector_b, :empty? => true ) }
      let(:selector_c) { stub(:selector_c, :empty? => false) }
      let(:selector_d) { stub(:selector_d, :empty? => false) }
      let(:selector_e) { stub(:selector_e, :empty? => true ) }

      it "should return the value pointed by the last empty selector for given property name" do
        subject.value_for("property").should eq("value B")
      end
    end
  end

  describe "with property_name_translator" do
    let(:style_sheet) do
      {
        "property_a" => "value a",

        "tag.class" => {
          "property_b" => "value b"
        }
      }
    end

    let(:property_name_translator) do
      translator = stub(:property_name_translator)
      translator.stub(:translate).with("property_a").and_return("translated_property_a")
      translator.stub(:translate).with("property_b").and_return("translated_property_b")
      translator
    end

    subject { described_class.new(style_sheet, property_name_translator) }

    describe "during initialization" do

      it "should populate @map with translated property names" do
        subject.instance_variable_get("@map").keys.should eq(["translated_property_a", "translated_property_b"])
      end
    end

    describe "when calling #value_for" do
      let(:tag) { stub(:tag, :name => "tag", :id => nil, :class_names => ["class"]) }

      it "should use translated property name when searching for matching selectors" do
        subject.value_for(tag, "property_b").should eq("value b")
      end
    end
  end
end
