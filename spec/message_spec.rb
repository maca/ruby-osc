require "#{ File.dirname __FILE__ }/spec_helper"

describe Message do
  
  it "should raise TypeError if passing wrong type" do
    lambda { Message.new('address', Class) }.should raise_error(TypeError)
  end
  
  it "should raise TypeError if not passing a string for address" do
    lambda { Message.new(OSC) }.should raise_error(TypeError)
  end
  
  it "should have address" do
    Message.new('/foo/bar').address.should == '/foo/bar'
  end
  
  it "should collect args" do
    Message.new('/foo/bar', 1, 2, 3, 4).args.size.should == 4
  end
  
  it "should accept integer" do
    Message.new('/foo/bar', 1).args.should == [1]
  end
  
  it "should should accept float" do
    Message.new('/foo/bar', 1.0).args.should == [1.0]
  end
  
  it "should accept string" do
    Message.new('/foo/bar', 'string').args.should == ['string']
  end
  
  it "should accept Blob" do
    Message.new('/foo/bar', Blob.new('blob')).args.should == [Blob.new('blob')]
  end
  
  it "should convert to array" do
    Message.new('/foo/bar', 1, 2, 3, 4).to_a.should == ['/foo/bar', 1, 2, 3, 4]
  end
  
  describe 'Custom argument coercion' do
    
    before do
      TrueClass.send(:include, OSCArgument)
      TrueClass.send( :define_method, :to_osc_type){ 1 }
      FalseClass.send(:include, OSCArgument)
      FalseClass.send( :define_method, :to_osc_type){ 0 }
      Hash.send(:include, OSCArgument)
      Hash.send( :define_method, :to_osc_type) do 
        self.to_a.collect{ |pair| pair.collect{ |a| OSC.coerce_argument a } }
      end
    end
    
    it "should accept true" do
      Message.new('/foo/bar', true).args.should == [1]
    end

    it "should accept false" do
      Message.new('/foo/bar', false).args.should == [0]
    end

    it "should accept hash" do
      Message.new('/foo/bar', {:a => :b}).args.should == ["a", "b"]
    end
  end
  
  describe 'Encode/decode' do
    shared_examples_for 'Encodable Message' do
      it "should encode" do
        @message.encode.should == @expected
      end
      
      it "should decode to message" do
        Message.decode(@expected).should be_a(Message)
      end
      
      it "should decode address" do
        Message.decode(@expected).address.should == @message.address
      end
      
      it "should actually decode" do
        Message.decode(@expected).to_a.inspect.should == @message.to_a.inspect.to_s # Problem with float comparing
      end
    end
    
    describe 'Address' do
      before do
        @message  = Message.new('/foo/bar/long/very/long/long/long/address')
        @expected = "/foo/bar/long/very/long/long/long/address\000\000\000,\000\000\000"
      end
      it_should_behave_like 'Encodable Message'
    end
    
    describe 'Integer' do
      before do
        @message  = Message.new('/foo/barz', 2)
        @expected = "/foo/barz\000\000\000,i\000\000\000\000\000\002"
      end
      it_should_behave_like 'Encodable Message'
    end
    
    describe 'Negative Integer' do
      before do
        @message  = Message.new('/foo/barz', -2)
        @expected = "/foo/barz\000\000\000,i\000\000\377\377\377\376"
      end
      it_should_behave_like 'Encodable Message'
    end
    
    describe 'Float' do
      before do
        @message  = Message.new('/foo/bar', 1.10000002384186)
        @expected = [47, 102, 111, 111, 47, 98, 97, 114, 0, 0, 0, 0, 44, 102, 0, 0, 63, 140, 204, 205].pack('C*')
      end
      it_should_behave_like 'Encodable Message'
    end
    
    describe 'Negative Float' do
      before do
        @message  = Message.new('/foo/bar', -1.10000002384186)
        @expected = [47, 102, 111, 111, 47, 98, 97, 114, 0, 0, 0, 0, 44, 102, 0, 0, 191, 140, 204, 205].pack('C*')
      end
      it_should_behave_like 'Encodable Message'
    end
    
    describe 'String' do
      before do
        @message  = Message.new('/foo/bar', 'a string to encode')
        @expected = "/foo/bar\000\000\000\000,s\000\000a string to encode\000\000"
      end
      it_should_behave_like 'Encodable Message'
    end

    describe 'Multiple types' do
      before do
        @message  = Message.new('/foo/barzzz', 2, 1.44000005722046, 'basho')
        @expected = [47, 102, 111, 111, 47, 98, 97, 114, 122, 122, 122, 0, 44, 105, 102, 115, 0, 0, 0, 0, 0, 0, 0, 2, 63, 184, 81, 236, 98, 97, 115, 104, 111, 0, 0, 0].pack('C*')
      end
      it_should_behave_like 'Encodable Message'
    end
    
    describe 'Blob' do
      before do
        @message  = Message.new('/foo/bar', Blob.new('test blob'))
        @expected = "/foo/bar\000\000\000\000,b\000\000\000\000\000\ttest blob\000\000\000"
      end
      it_should_behave_like 'Encodable Message'
      
      it "should raise if size doesn't correspond and return empty message" do
        lambda do
          Message.decode("/foo/bar\000\000\000\000,b\000\000\000\000\000\020test blob\000\000\000")
        end.should raise_error
      end
    end
    
    describe 'Lots of ints' do
      before do
        @message  = Message.new('/bar/foo', 4, 3, 2, 1)
        @expected = "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001" 
      end
      it_should_behave_like 'Encodable Message'
    end
  end    
end