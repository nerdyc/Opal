# opal_xml_parser_spec.rb
# Opal
#
# Created by Christian Niles on 5/4/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

framework "Opal"

describe OpalXMLParser do
  
  describe "#initWithString" do
    it "should construct a new OpalXMLParser" do
      parser = OpalXMLParser.alloc.initWithString("<document />")
      parser.class.should.equal OpalXMLParser
    end
  end
  
  describe "#next" do
    
    describe "when at a start tag" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<document></document>")
        @result = @parser.next
      end
      
      it "should return START_TAG" do
        @result.should.equal(OPAL_START_TAG)
      end
      
      it "should update currentTagName" do
        @parser.currentTagName.should.equal("document")
      end
      
      it "should advance the scan pointer to the end of the tag" do
        @parser.position.should.equal(10)
      end
      
    end
    
    describe "when at an end tag" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("</document>")
        @result = @parser.next
      end
      
      it "should return END_TAG" do
        @result.should.equal(OPAL_END_TAG)
      end
      
      it "should update currentTagName" do
        @parser.currentTagName.should.equal("document")
      end
      
      it "should advance the scan pointer to the end of the tag" do
        @parser.position.should.equal(11)
      end
    end
    
    describe "when at a text" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("text la la <tag />")
        @result = @parser.next()

      end
      
      it "should return TEXT" do
        @result.should.equal(OPAL_TEXT)
      end
      
      it "should update the parsed content" do
        @parser.characterData.should == 'text la la '
      end
      
      it "should advance the scan pointer to the end of the text section" do
        @parser.position.should.equal(11)
      end
      
    end
    
  end
  
end