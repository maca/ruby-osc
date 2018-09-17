# encoding: UTF-8
require "#{ File.dirname __FILE__ }/spec_helper"

describe Message do
  it "should raise TypeError if passing wrong type" do
    expect { Message.new("address", Class) }.to raise_error(TypeError)
  end

  it "should raise TypeError if not passing a string for address" do
    expect { Message.new(OSC) }.to raise_error(TypeError)
  end

  it "should have address" do
    expect(Message.new("/foo/bar").address).to eq("/foo/bar")
  end

  it "should accept utf8 address" do
    expect(Message.new("/foo/bär").address).to eq("/foo/bär")
  end

  it "should collect args" do
    expect(Message.new("/foo/bar", 1, 2, 3, 4).args.size).to eq(4)
  end

  it "should accept integer" do
    expect(Message.new("/foo/bar", 1).args).to eq([1])
  end

  it "should should accept float" do
    expect(Message.new("/foo/bar", 1.0).args).to eq([1.0])
  end

  it "should accept string" do
    expect(Message.new("/foo/bar", "string").args).to eq(["string"])
  end

  it "should accept Blob" do
    expect(Message.new("/foo/bar", Blob.new("blob")).args).to eq([Blob.new("blob")])
  end

  it "should convert to array" do
    expect(Message.new("/foo/bar", 1, 2, 3, 4).to_a).to eq(["/foo/bar", 1, 2, 3, 4])
  end

  describe "Custom argument coercion" do
    before do
      TrueClass.send(:include, OSCArgument)
      TrueClass.send( :define_method, :to_osc_type){ 1 }
      FalseClass.send(:include, OSCArgument)
      FalseClass.send( :define_method, :to_osc_type){ 0 }
      Hash.send(:include, OSCArgument)
      Hash.send( :define_method, :to_osc_type) do
        to_a.collect{ |pair| pair.collect{ |a| OSC.coerce_argument a } }
      end
    end

    it "should accept true" do
      expect(Message.new("/foo/bar", true).args).to eq([1])
    end

    it "should accept false" do
      expect(Message.new("/foo/bar", false).args).to eq([0])
    end

    it "should accept hash" do
      expect(Message.new("/foo/bar", a: :b).args).to eq(%w(a b))
    end
  end

  describe "Encode/decode" do
    shared_examples_for "Encodable Message" do
      it "should encode" do
        expect(@message.encode).to eq(@expected)
      end

      it "should decode to message" do
        expect(Message.decode(@expected)).to be_a(Message)
      end

      it "should decode address" do
        expect(Message.decode(@expected).address).to eq(@message.address)
      end

      it "should actually decode" do
        expect(Message.decode(@expected).to_a.inspect).to eq(@message.to_a.inspect.to_s) # Problem with float comparing
      end
    end

    describe "Address" do
      before do
        @message  = Message.new("/foo/bar/long/very/long/long/long/address")
        @expected = "/foo/bar/long/very/long/long/long/address\000\000\000,\000\000\000".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Integer" do
      before do
        @message  = Message.new("/foo/barz", 2)
        @expected = "/foo/barz\000\000\000,i\000\000\000\000\000\002".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Negative Integer" do
      before do
        @message  = Message.new("/foo/barz", -2)
        @expected = "/foo/barz\000\000\000,i\000\000\377\377\377\376".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Float" do
      before do
        @message  = Message.new("/foo/bar", 1.100000023841858)
        @expected = [47, 102, 111, 111, 47, 98, 97, 114, 0, 0, 0, 0, 44, 102, 0, 0, 63, 140, 204, 205].pack("C*")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Negative Float" do
      before do
        @message  = Message.new("/foo/bar", -1.100000023841858)
        @expected = [47, 102, 111, 111, 47, 98, 97, 114, 0, 0, 0, 0, 44, 102, 0, 0, 191, 140, 204, 205].pack("C*")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "String" do
      before do
        @message  = Message.new("/foo/bar", "a string to encode")
        @expected = "/foo/bar\000\000\000\000,s\000\000a string to encode\000\000".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "UTF8 String" do
      before do
        @message  = Message.new("/foo/bar", "a string to äncode")
        @expected = "/foo/bar\000\000\000\000,s\000\000a string to äncode\000".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Multiple types" do
      before do
        @message  = Message.new("/foo/barzzz", 2, 1.440000057220459, "basho")
        @expected = [47, 102, 111, 111, 47, 98, 97, 114, 122, 122, 122, 0, 44, 105, 102, 115, 0, 0, 0, 0, 0, 0, 0, 2, 63, 184, 81, 236, 98, 97, 115, 104, 111, 0, 0, 0].pack("C*")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Blob" do
      before do
        @message  = Message.new("/foo/bar", Blob.new("test blob"))
        @expected = "/foo/bar\000\000\000\000,b\000\000\000\000\000\ttest blob\000\000\000".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"

      it "should raise if size doesn't correspond and return empty message" do
        expect do
          Message.decode("/foo/bar\000\000\000\000,b\000\000\000\000\000\020test blob\000\000\000".force_encoding("binary"))
        end.to raise_error(OSC::DecodeError)
      end
    end

    describe "Lots of ints" do
      before do
        @message  = Message.new("/bar/foo", 4, 3, 2, 1)
        @expected = "/bar/foo\000\000\000\000,iiii\000\000\000\000\000\000\004\000\000\000\003\000\000\000\002\000\000\000\001".force_encoding("binary")
      end
      it_should_behave_like "Encodable Message"
    end

    describe "Invalid message" do
      it "should raise if invalid tag is used" do
        expect do
          Message.decode("/foo/bar\000\000\000\000,k\000\000\000\000\000\020test blob\000\000\000".force_encoding("binary"))
        end.to raise_exception(DecodeError)
      end
    end
  end
end
