module Travis
  module Lint
    module DSL
      class Validator < Struct.new(:language, :key, :message, :validator)
        def call(hash)
          if self.validator.call(hash)
            [false, { :key => self.key, :issue => self.message }]
          else
            [true, {}]
          end
        end
      end

      class ValidatorWithDynamicMessage
        attr_accessor :language, :key, :validator, :message_block

        def initialize(language, key, &definition)
          self.language, self.key = language, key
          instance_eval &definition
        end

        def message(&message_block)
          if message_block
            self.message_block = message_block
          else
            self.message_block.call
          end
        end

        def validate(&block)
          @validator = block
        end

        def call(hash)
          return [true, {}] unless self.validator.call(hash)
          [false, { :key => key, :issue => message_block.call(hash) }]
        end
      end
    end
  end
end
