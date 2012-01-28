# encoding: UTF-8
require "#{ File.dirname __FILE__ }/spec_helper"

describe StreamScanner do
  before(:each) do
    @ss = StreamScanner.new
  end

  it 'should parse a message correct' do
    @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
    @ss.tryparse.should == Message.new('/bar/foo', 4, 3, 2, 1)
  end

  it 'should raise exception on half message' do
    @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004".force_encoding("binary")
    lambda { @ss.tryparse }.should raise_exception(DecodeError)
  end

  it 'should parse if rest of message is added' do
    @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004".force_encoding("binary")
    lambda { @ss.tryparse }.should raise_exception(DecodeError)
    @ss << "\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
    @ss.tryparse.should == Message.new('/bar/foo', 4, 3, 2, 1)
  end

  it 'should leave part of second message untouched' do
    @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000".force_encoding("binary")
    @ss << "\000\002\000\000\000\001/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004".force_encoding("binary")
    @ss.tryparse.should == Message.new('/bar/foo', 4, 3, 2, 1)
    @ss << "\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
    @ss.tryparse.should == Message.new('/bar/foo', 4, 3, 2, 1)
  end

  it 'should return only one message at once' do
    @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
    @ss << "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
    @ss.tryparse.should == Message.new('/bar/foo', 4, 3, 2, 1)
    @ss.tryparse.should == Message.new('/bar/foo', 4, 3, 2, 1)
  end
end

