module SimpleStyleSheet
  class SelectorSegment

    def initialize(string)
      @tag_name    = string.lstrip.slice(/^\w+/)
      @id          = string.slice(/(?<=\#)\w+/)
      @class_names = string.scan(/(?<=\.)\w+/)
    end

    attr_reader :tag_name, :id, :class_names

    def specificity
      @specificity ||= SelectorSpecificity.new(
        0,
        id ? 1 : 0,
        class_names.count,
        tag_name ? 1 : 0
      )
    end

    def match?(tag)
      return false if tag_name && tag_name != tag.name
      return false if id       && id       != tag.id
      return false if (class_names - tag.class_names).any?
      true
    end

    def to_s
      "#{tag_name}" +
      (id ? "##{id}" : "") +
      class_names.map { |class_name| ".#{class_name}" }.join
    end

    def inspect
      "#<#{self.class} #{to_s.inspect}>"
    end
  end
end
