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
    shared_examples_for 'Encodable Bundle' do
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
    it_should_behave_like 'Encodable Bundle'
  end
  
  describe 'Empty bundle with timetag' do
    before do
      @bundle   = Bundle.new Time.at(1251420949.16959)
      @expected = [35, 98, 117, 110, 100, 108, 101, 0, 206, 65, 169, 149, 43, 106, 64, 0].pack('C*')
    end
    it_should_behave_like 'Encodable Bundle'
  end
  
  describe 'Bundle with timetag and messages' do
    before do
      @bundle   = Bundle.new Time.at(946702800), Message.new('/bar/foo', 4, 3, 2, 1), Message.new('/foo/bar', 1, 2, 3, 4)
      @expected = [35, 98, 117, 110, 100, 108, 101, 0, 188, 24, 8, 80, 0, 0, 0, 0, 0, 0, 0, 36, 47, 98, 97, 114, 47, 102, 111, 111, 0, 0, 0, 0, 44, 105, 105, 105, 105, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0, 0, 2, 0, 0, 0, 1, 0, 0, 0, 36, 47, 102, 111, 111, 47, 98, 97, 114, 0, 0, 0, 0, 44, 105, 105, 105, 105, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0, 4].pack('C*')
    end
    it_should_behave_like 'Encodable Bundle'
  end
  
  describe 'Nested bundles' do
    before do
      @bundle   = Bundle.new( nil, Bundle.new(nil, Message.new('/a')), Message.new('/b') )
      @expected = "#bundle\000\000\000\000\000\000\000\000\001\000\000\000\034#bundle\000\000\000\000\000\000\000\000\001\000\000\000\b/a\000\000,\000\000\000\000\000\000\b/b\000\000,\000\000\000"
    end
    it_should_behave_like 'Encodable Bundle'
  end
  
  describe 'Complex blob' do
    before do
      data      = [ 83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 4, 104, 111, 108, 97, 0, 2, 67, -36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, -1, -1, 0, 0, -1, -1, 0, 1, 2, 0, 0 ].pack('C*')
      @bundle   = Bundle.new nil, Message.new('/d_recv', Blob.new(data), 0)
      @expected = [35, 98, 117, 110, 100, 108, 101, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 76, 47, 100, 95, 114, 101, 99, 118, 0, 44, 98, 105, 0, 0, 0, 0, 56, 83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 4, 104, 111, 108, 97, 0, 2, 67, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, 255, 255, 0, 0, 255, 255, 0, 1, 2, 0, 0, 0, 0, 0, 0].pack('C*')
    end
    it_should_behave_like 'Encodable Bundle'
  end
  
  describe 'Complex blob 2' do
    before do
      data      = [ 83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 2, 97, 109, 0, 7, 0, 0, 0, 0, 63, 0, 0, 0, 63, -128, 0, 0, 64, 0, 0, 0, -62, -58, 0, 0, 64, -96, 0, 0, -64, -128, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 103, 97, 116, 101, 0, 0, 9, 112, 111, 114, 116, 97, 100, 111, 114, 97, 0, 1, 10, 109, 111, 100, 117, 108, 97, 100, 111, 114, 97, 0, 2, 3, 97, 109, 112, 0, 3, 0, 8, 7, 67, 111, 110, 116, 114, 111, 108, 1, 0, 0, 0, 4, 0, 0, 1, 1, 1, 1, 6, 83, 105, 110, 79, 115, 99, 1, 0, 2, 0, 1, 0, 0, 0, 0, 0, 2, -1, -1, 0, 0, 1, 6, 77, 117, 108, 65, 100, 100, 1, 0, 3, 0, 1, 0, 0, 0, 1, 0, 0, -1, -1, 0, 1, -1, -1, 0, 1, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, 0, 0, 0, 1, -1, -1, 0, 0, 2, 12, 66, 105, 110, 97, 114, 121, 79, 112, 85, 71, 101, 110, 2, 0, 2, 0, 1, 0, 2, 0, 3, 0, 0, 0, 2, 0, 0, 2, 6, 69, 110, 118, 71, 101, 110, 1, 0, 17, 0, 1, 0, 0, 0, 0, 0, 0, -1, -1, 0, 2, -1, -1, 0, 0, -1, -1, 0, 2, -1, -1, 0, 3, -1, -1, 0, 0, -1, -1, 0, 3, -1, -1, 0, 2, -1, -1, 0, 4, -1, -1, 0, 2, -1, -1, 0, 3, -1, -1, 0, 5, -1, -1, 0, 6, -1, -1, 0, 0, -1, -1, 0, 3, -1, -1, 0, 5, -1, -1, 0, 6, 1, 12, 66, 105, 110, 97, 114, 121, 79, 112, 85, 71, 101, 110, 2, 0, 2, 0, 1, 0, 2, 0, 4, 0, 0, 0, 5, 0, 0, 2, 3, 79, 117, 116, 2, 0, 2, 0, 0, 0, 0, -1, -1, 0, 0, 0, 6, 0, 0, 0, 0 ].pack('C*')
      @bundle   = Bundle.new nil, Message.new('/d_recv', Blob.new(data), 0)
      @expected = [35, 98, 117, 110, 100, 108, 101, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 124, 47, 100, 95, 114, 101, 99, 118, 0, 44, 98, 105, 0, 0, 0, 1, 101, 83, 67, 103, 102, 0, 0, 0, 1, 0, 1, 2, 97, 109, 0, 7, 0, 0, 0, 0, 63, 0, 0, 0, 63, 128, 0, 0, 64, 0, 0, 0, 194, 198, 0, 0, 64, 160, 0, 0, 192, 128, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 103, 97, 116, 101, 0, 0, 9, 112, 111, 114, 116, 97, 100, 111, 114, 97, 0, 1, 10, 109, 111, 100, 117, 108, 97, 100, 111, 114, 97, 0, 2, 3, 97, 109, 112, 0, 3, 0, 8, 7, 67, 111, 110, 116, 114, 111, 108, 1, 0, 0, 0, 4, 0, 0, 1, 1, 1, 1, 6, 83, 105, 110, 79, 115, 99, 1, 0, 2, 0, 1, 0, 0, 0, 0, 0, 2, 255, 255, 0, 0, 1, 6, 77, 117, 108, 65, 100, 100, 1, 0, 3, 0, 1, 0, 0, 0, 1, 0, 0, 255, 255, 0, 1, 255, 255, 0, 1, 1, 6, 83, 105, 110, 79, 115, 99, 2, 0, 2, 0, 1, 0, 0, 0, 0, 0, 1, 255, 255, 0, 0, 2, 12, 66, 105, 110, 97, 114, 121, 79, 112, 85, 71, 101, 110, 2, 0, 2, 0, 1, 0, 2, 0, 3, 0, 0, 0, 2, 0, 0, 2, 6, 69, 110, 118, 71, 101, 110, 1, 0, 17, 0, 1, 0, 0, 0, 0, 0, 0, 255, 255, 0, 2, 255, 255, 0, 0, 255, 255, 0, 2, 255, 255, 0, 3, 255, 255, 0, 0, 255, 255, 0, 3, 255, 255, 0, 2, 255, 255, 0, 4, 255, 255, 0, 2, 255, 255, 0, 3, 255, 255, 0, 5, 255, 255, 0, 6, 255, 255, 0, 0, 255, 255, 0, 3, 255, 255, 0, 5, 255, 255, 0, 6, 1, 12, 66, 105, 110, 97, 114, 121, 79, 112, 85, 71, 101, 110, 2, 0, 2, 0, 1, 0, 2, 0, 4, 0, 0, 0, 5, 0, 0, 2, 3, 79, 117, 116, 2, 0, 2, 0, 0, 0, 0, 255, 255, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0].pack('C*')
      end
    it_should_behave_like 'Encodable Bundle'
  end
  
  it 'Should raise OSC::DecodeError with bad encoded bundle' do
    bad_data = "#bundle\000\000\000\000\000\000\000\000\001\000\000\000\034#bundle\000\000\000\000\000\001\000\000\000\b/a\000\000,\000\000\000\000\000\000\b/b\000\000,\000\000\000"
    lambda { Bundle.decode bad_data }.should raise_error(DecodeError)
  end
end