require 'minitest/autorun'
require 'minitest/pride'
require 'parslet'

class Parser < Parslet::Parser
  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:sign) { str('+') | str('-') }
  rule(:integer) {
    sign.maybe >> match('[0-9]').repeat(1) >> space?
  }

  rule(:prod_op) {
    match('[*/]') >> space?
  }

  rule(:acc_op) {
    match('[+-]') >> space?
  }

  rule(:lpar) { str('(') >> space? }
  rule(:rpar) { str(')') >> space? }

  rule(:paren) {
    (lpar >> prod_expr >> rpar).as(:paren_expr)
  }

  rule(:primary) {
    paren | integer
  }

  rule(:acc_expr) {
    (primary.as(:left) >> acc_op >> acc_expr.as(:right)).as(:acc_expr) |
    primary
  }

  rule(:prod_expr) {
    (acc_expr.as(:left) >> prod_op >> prod_expr.as(:right)).as(:prod_expr) |
    acc_expr
  }

  rule(:expr) {
    prod_expr
  }

  root(:expr)
end

class ParserTest < MiniTest::Test
  def test_rule_integer
    Parser.new.parse("-1")
    Parser.new.parse("1*1+1")
    Parser.new.parse("1  *1")
    Parser.new.parse("1+1+1")
    Parser.new.parse("(1 + 1) + 1")
    Parser.new.parse("1 + 1 + 1")
    Parser.new.parse("(1 + 1) * 1")
    Parser.new.parse("((1 * 3))")
  end
end
