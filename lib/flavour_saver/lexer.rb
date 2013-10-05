require 'rltk'

module FlavourSaver
  module LexerRules

    def self.included(klass)

      klass.rule /{{{/, :default do
        push_state :expression
        :TEXPRST
      end

      klass.rule /{{/, :default do
        push_state :expression
        :EXPRST
      end

      klass.rule /#/, :expression do
        :HASH
      end

      klass.rule /\//, :expression do
        :FWSL
      end

      klass.rule /&/, :expression do
        :AMP
      end

      klass.rule /\^/, :expression do
        :HAT
      end

      klass.rule /@/, :expression do
        :AT
      end

      klass.rule />/, :expression do
        :GT
      end

      klass.rule /([1-9][0-9]*(\.[0-9]+)?)/, :expression do |n|
        [ :NUMBER, n ]
      end

      klass.rule /true/, :expression do |i|
        [ :BOOL, true ]
      end

      klass.rule /false/, :expression do |i|
        [ :BOOL, false ]
      end

      klass.rule /\!/, :expression do
        push_state :comment
        :BANG
      end

      klass.rule /([^}}]*)/, :comment do |comment|
        pop_state
        [ :COMMENT, comment ]
      end

      klass.rule /else/, :expression do
        :ELSE
      end

      klass.rule /([A-Za-z]\w*)/, :expression do |name|
        [ :IDENT, name ]
      end

      klass.rule /\./, :expression do 
        :DOT
      end

      klass.rule /\=/, :expression do
        :EQ
      end

      klass.rule /"/, :expression do
        push_state :string
      end
      
      klass.rule /(\\"|[^"])*/, :string do |str|
        [ :STRING, str ]
      end

      klass.rule /"/, :string do
        pop_state
      end

      # Handlebars allows methods with hyphens in them. Ruby doesn't, so
      # we'll assume you're trying to index the context with the identifier
      # and call the result.
      klass.rule /([A-Za-z][a-z0-9_-]*[a-z0-9])/, :expression do |str|
        [ :LITERAL, str ]
      end

      klass.rule /\[/, :expression do
        push_state :segment_literal
      end

      klass.rule /([^\]]+)/, :segment_literal do |l|
        [ :LITERAL, l ]
      end

      klass.rule /]/, :segment_literal do
        pop_state
      end

      klass.rule /\s+/, :expression do
        :WHITE
      end

      klass.rule /}}}/, :expression do
        pop_state
        :TEXPRE
      end

      klass.rule /}}/, :expression do
        pop_state
        :EXPRE
      end

      klass.rule /.*?(?={{|\z)/m, :default do |output|
        [ :OUT, output ]
      end
    end
  end
end

# Standard lexer as defined by the handlebars / mustache spec
module FlavourSaver
  class Lexer < RLTK::Lexer
    include LexerRules
  end
end

# A 'safe' lexer that treats all input as safe text, and doesn't
# html encode any replacements
module FlavourSaver
  class SafeLexer < RLTK::Lexer

    rule /{{/, :default do
      push_state :expression
      :TEXPRST
    end

    rule /}}/, :expression do
      pop_state
      :TEXPRE
    end

    include LexerRules
  end
end
