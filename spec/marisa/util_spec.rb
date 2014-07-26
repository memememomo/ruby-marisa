require 'rspec'
require 'marisa/util'

describe 'Marisa::Util' do
  context '#split_header' do
    it { expect(Marisa::Util.split_header('')).to match_array [] }
    it { expect(Marisa::Util.split_header('foo=b=a=r')).to match_array [%w(foo b=a=r)] }
    it { expect(Marisa::Util.split_header(',,foo,, ,bar')).to match_array [['foo',nil],['bar',nil]] }
    it { expect(Marisa::Util.split_header(';;foo;; ;bar')).to match_array [['foo',nil,'bar',nil]] }
    it { expect(Marisa::Util.split_header('foo=;bar=""')).to match_array [['foo', '', 'bar', '']] }
    it { expect(Marisa::Util.split_header('foo=bar baz=yada')).to match_array [['foo', 'bar', 'baz', 'yada']]}
    it { expect(Marisa::Util.split_header('foo,bar,baz')).to match_array [['foo', nil], ['bar', nil], ['baz', nil]] }
    it { expect(Marisa::Util.split_header('f "o" o , ba r')).to match_array [['f', nil, '"o"', nil, 'o', nil], ['ba', nil, 'r', nil]] }
    it { expect(Marisa::Util.split_header('foo="b,; a\" r\"\\\\"')).to match_array [['foo', 'b,; a" r"\\']] }
    it { expect(Marisa::Util.split_header('foo = "b a\" r\"\\\\"')).to match_array [['foo', 'b a" r"\\']]}
    it {
      header = %q{</foo/bar>; rel="x"; t*=UTF-8'de'a%20b}
      tree = [['</foo/bar>', nil, 'rel', 'x', 't*', 'UTF-8\'de\'a%20b']]
      expect(Marisa::Util.split_header(header)).to match_array tree
    }
    it {
      header = 'a=b c; A=b.c; D=/E; a-b=3; F=Thu, 07 Aug 2008 07:07:59 GMT; Ab;'
      tree = [
          ['a', 'b', 'c', nil, 'A', 'b.c', 'D', '/E', 'a-b', '3', 'F', 'Thu'],
          [
              '07'      , nil, 'Aug', nil, '2008', nil,
              '07:07:59', nil, 'GMT', nil, 'Ab', nil
          ]
      ]
      expect(Marisa::Util.split_header(header)).to match_array tree
    }
  end
end