module SimpleStyleSheet
  class Selector

    def initialize(string=nil)
      @segments = []
      @specificity = SelectorSpecificity.new
      concat(string) unless string.nil?
    end

    attr_reader :specificity

    def concat(string)
      string.scan(/[\w.#]+/).map { |s| SelectorSegment.new(s) }.each do |segment|
        @segments << segment
        @specificity += segment.specificity
      end
      self
    end

    def +(string)
      duplicate.concat(string)
    end

    def match?(tag)
      return true  if @segments.none?
      return false unless @segments.last.match?(tag)

      index = @segments.size - 2
      current_tag = tag

      while index >= 0 && current_tag = current_tag.parent
        if @segments[index].match?(current_tag)
          index -= 1
          next
        end
      end
      index == -1
    end

    def empty?
      @segments.none?
    end

    def to_s
      @segments.map { |segment| segment.to_s }.join(" ")
    end

    def inspect
      "#<#{self.class} #{to_s.inspect}>"
    end

    def ==(other)
      to_s == other.to_s
    end

    def duplicate
      d = dup
      d.instance_variable_set(   "@segments",    @segments.dup)
      d.instance_variable_set("@specificity", @specificity.dup)
      d
    end
  end
end
