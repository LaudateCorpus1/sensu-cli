require 'sensu-cli/pretty'
require 'json'

describe 'SensuCli::Pretty' do
  include Helpers

  describe 'pretty text' do
    it 'can pretty empty response' do
      res = []
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[36mno values for this request\e[0m\n"
    end

    it 'can pretty a hash' do
      res = [{ :test => 'value' }]
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[33m-------\e[0m\n\e[36mtest:  \e[0m\e[32mvalue\e[0m\n"
    end

    it 'can pretty an array' do
      res = %w(test test1)
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[33m-------\e[0m\n\e[36mtest\e[0m\n\e[33m-------\e[0m\n\e[36mtest1\e[0m\n"
    end

    it 'can pretty a hash inside an array' do
      res = [{ :test => 'value', :test1 => 'value1' }]
      output = capture_stdout { SensuCli::Pretty.print(res) }
      output.should == "\e[33m-------\e[0m\n\e[36mtest:  \e[0m\e[32mvalue\e[0m\n\e[36mtest1:  \e[0m\e[32mvalue1\e[0m\n"
    end
  end

  describe 'pretty single line' do
    it 'can table an empty response' do
      res = []
      output = capture_stdout { SensuCli::Pretty.single(res) }
      output.should == "\e[36mno values for this request\e[0m\n"
    end

    it 'can table a hash inside an array' do
      res = [{ :test => 'value', :test1 => 'value1' }]
      output = capture_stdout { SensuCli::Pretty.single(res) }
      output.should == "test  test1 \nvalue value1\n"
    end
  end

  describe 'pretty single table' do
    it 'can table an empty response' do
      res = []
      output = capture_stdout { SensuCli::Pretty.table(res, 'events') }
      output.should == "\e[36mno values for this request\e[0m\n"
    end

    it 'can table a hash inside an array' do
      res = [{ :test => 'value', :test1 => 'value1' }]
      output = capture_stdout { SensuCli::Pretty.table(res, 'test') }
      output.should == "+-------+--------+\n| test  | test1  |\n+-------+--------+\n| value | value1 |\n+-------+--------+\n1 row in set\n"
    end
  end

  describe 'count response' do
    it 'can count a hash' do
      res = { :test => 'value', :test1 => 'value1' }
      output = capture_stdout { SensuCli::Pretty.count(res) }
      output.should == "\e[33m2 total items\e[0m\n"
    end

    it 'can count an array' do
      res = %w(test test2)
      output = capture_stdout { SensuCli::Pretty.count(res) }
      output.should == "\e[33m2 total items\e[0m\n"
    end
  end
end
