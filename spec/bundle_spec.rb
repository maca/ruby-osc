require "#{ File.dirname __FILE__ }/spec_helper"

describe Bundle do
  
  it "should accept bundle" do
    Bundle.new( Time.now, Bundle.new ).to_a.should == [Bundle.new]
  end

  it "should accept message" do
    Bundle.new( Time.now, Message.new ).to_a.should == [Message.new]
  end

  it "should rise TypeError if passing passing incorrect type" do
    lambda { Bundle.new Time.now, 1 }.should raise_error(TypeError)
  end
  
  it "should raise TypeError if timetag is not Time" do
    lambda { Bundle.new 1 }.should raise_error(TypeError)
  end
  
  it "should accept nil for timetag" do
    Bundle.new nil
  end

  describe 'Encode/decode' do
    shared_examples_for 'Encodable' do
      it "should encode" do
        @bundle.encode.should == @expected
      end
      
      it "should decode to bundle" do
        Bundle.decode(@expected).should be_a(Bundle)
      end
      
      it "should decode timetag" do
        Bundle.decode(@expected).timetag.should == @bundle.timetag
      end
      
      it "should actually decode" do
        Bundle.decode(@expected).should == @bundle
      end
    end
  end
  
  describe 'Empty bundle nil timetag' do
    before do
      @bundle   = Bundle.new
      @expected = "#bundle\000\000\000\000\000\000\000\000\001"
    end
    it_should_behave_like 'Encodable'
  end
  
  describe 'Empty bundle with timetag' do
    before do
      @bundle   = Bundle.new Time.at(1251420949.16959)
      @expected = [35, 98, 117, 110, 100, 108, 101, 0, 206, 65, 169, 149, 43, 106, 64, 0].pack('C*')
    end
    it_should_behave_like 'Encodable'
  end
  
  describe 'Bundle with timetag and messages' do
    before do
      @bundle   = Bundle.new Time.at(946702800), Message.new('/bar/foo', 4, 3, 2, 1), Message.new('/foo/bar', 1, 2, 3, 4)
      @expected = [35, 98, 117, 110, 100, 108, 101, 0, 188, 24, 8, 80, 0, 0, 0, 0, 0, 0, 0, 36, 47, 98, 97, 114, 47, 102, 111, 111, 0, 0, 0, 0, 44, 105, 105, 105, 105, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 36, 47, 102, 111, 111, 47, 98, 97, 114, 0, 0, 0, 0, 44, 105, 105, 105, 105, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4].pack('C*')
    end
    it_should_behave_like 'Encodable'
  end
  
  describe 'Nested bundles' do
    before do
      @bundle   = Bundle.new( nil, Bundle.new(nil, Message.new('/a')), Message.new('/b') )
      @expected = "#bundle\000\000\000\000\000\000\000\000\001\000\000\000\034#bundle\000\000\000\000\000\000\000\000\001\000\000\000\b/a\000\000,\000\000\000\000\000\000\b/b\000\000,\000\000\000"
    end
    it_should_behave_like 'Encodable'
  end
  
  it 'Should raise OSC::DecodeError whith encoded bundle' do
    bad_data = "#bundle\000\000\000\000\000\000\000\000\001\000\000\000\034#bundle\000\000\000\000\000\001\000\000\000\b/a\000\000,\000\000\000\000\000\000\b/b\000\000,\000\000\000"
    lambda { Bundle.decode bad_data }.should raise_error(DecodeError)
  end

end