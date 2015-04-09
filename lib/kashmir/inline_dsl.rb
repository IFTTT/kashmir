module Kashmir
  module InlineDsl

    def self.build(&definitions)
      inline_representer = Class.new do
        include Kashmir::Dsl
      end

      inline_representer.class_eval(&definitions) if block_given?
      inline_representer
    end
  end
end
