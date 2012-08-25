require "spec_helper"

describe "simple_style_sheet gem" do

  context "when properly set up style sheet handler instance" do
    let(:style_sheet) do
      {
        foreground_color: :white,
        background_color: :blue,

        "#content message.success" => {
          background_color: :green,

          number: {
            foreground_color: :inherit
          }
        }
      }
    end

    let(:style_sheet_handler) { SimpleStyleSheet::Handler.new(style_sheet) }

    before { stub_const("Tag", Struct.new(:name, :id, :class_names, :parent)) }
    let(:content_tag) { Tag.new("section", "content", []         , nil        ) }
    let(:message_tag) { Tag.new("message", nil      , ["success"], content_tag) }
    let(:number_tag ) { Tag.new("number" , nil      , ["high"   ], message_tag) }

    it "should properly find property values for given tags" do
      expect(style_sheet_handler.value_for(content_tag, :foreground_color)).to eq(:white  )
      expect(style_sheet_handler.value_for(content_tag, :background_color)).to eq(:blue   )

      expect(style_sheet_handler.value_for(message_tag, :foreground_color)).to eq(:white  )
      expect(style_sheet_handler.value_for(message_tag, :background_color)).to eq(:green  )

      expect(style_sheet_handler.value_for( number_tag, :foreground_color)).to eq(:inherit)
      expect(style_sheet_handler.value_for( number_tag, :background_color)).to eq(:blue   )
    end

    it "should properly find default (top-level) property value" do
      expect(style_sheet_handler.value_for(:foreground_color)).to eq(:white)
      expect(style_sheet_handler.value_for(:background_color)).to eq(:blue )
    end
  end
end
