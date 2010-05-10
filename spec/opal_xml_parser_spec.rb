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
  
  describe "#nextEvent" do
    
    describe "when at an XML declaration" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<?xml version=\"1.0\" encoding=\"utf-8\" standalone='yes' ?><document />")
        @result = @parser.nextEvent
      end
      
      it "should return START_DOCUMENT" do
        @result.type.should.equal(OPAL_START_DOCUMENT_EVENT)
      end
      
      it "should set version" do
        @result.version.should.equal("1.0")
      end
      
      it "should set encoding" do
        @result.encoding.should.equal("utf-8")
      end
      
      it "should set standalone" do
        @result.standalone.should.be.true
      end
      
      it "should advance the scan pointer" do
        @parser.characterPosition.should.equal(56)
      end
      
    end
    
    describe "when at a start tag" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<document></document>")
        @result = @parser.nextEvent
      end
      
      it "should return START_TAG" do
        @result.type.should.equal(OPAL_START_TAG_EVENT)
      end
      
      it "should update currentTagName" do
        @result.tagName.should.equal("document")
      end
      
      it "should advance the scan pointer to the end of the tag" do
        @parser.characterPosition.should.equal(10)
      end
      
    end
    
    describe "when at an end tag" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("</document><tag></tag>")
        @result = @parser.nextEvent
      end
      
      it "should return END_TAG" do
        @result.type.should.equal(OPAL_END_TAG_EVENT)
      end
      
      it "should update currentTagName" do
        @result.tagName.should.equal("document")
      end
      
      it "should advance the scan pointer to the end of the tag" do
        @parser.characterPosition.should.equal(11)
      end
    end
    
    describe "when at a text" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("text la la <tag />")
        @result = @parser.nextEvent
      end
      
      it "should return TEXT" do
        @result.type.should.equal(OPAL_TEXT_EVENT)
      end
      
      it "should update the parsed content" do
        @result.content.should == 'text la la '
      end
      
      it "should advance the scan pointer to the end of the text section" do
        @parser.characterPosition.should.equal(11)
      end
      
    end
    
    describe "when at a comment" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<!-- comment --> text la la <tag />")
        @result = @parser.nextEvent
      end
      
      it "should return COMMENT" do
        @result.type.should.equal(OPAL_COMMENT_EVENT)
      end
      
      it "should include the comment text" do
        @result.content.should == ' comment '
      end
      
      it "should advance the scan pointer to the end of the text section" do
        @parser.characterPosition.should.equal(16)
      end
      
    end
    
  end
  
end