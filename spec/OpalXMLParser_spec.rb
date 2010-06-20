#!/usr/bin/env macruby
# opal_xml_parser_spec.rb
# Opal
#
# Created by Christian Niles on 5/4/10.
# Copyright 2010 Christian Niles. All rights reserved.

require File.join(File.dirname(__FILE__), '../spec_helper')

describe OpalXMLParser do
  
  describe "#initWithString" do
    it "should construct a new OpalXMLParser" do
      parser = OpalXMLParser.alloc.initWithString("<document />")
      parser.class.should.equal OpalXMLParser
    end
  end
  
  # ===== EVENT STREAMING ==============================================================================================
  
  describe "#nextEvent" do
    
    describe "when at an XML declaration" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<?xml version=\"1.0\" encoding=\"utf-8\" standalone='yes' ?><document></document>")
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
      
      it "should store the result as currentEvent" do
        @parser.currentEvent.should.equal(@result)
      end
      
      it "should increment the currentDepth" do
        @parser.currentDepth.should.equal(1)
      end
    end
    
    describe "when at a start tag" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<document></document>")
        @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
        
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

      it "should store the result as currentEvent" do
        @parser.currentEvent.should.equal(@result)
      end
      
      it "should increment currentDepth" do
        @parser.currentDepth.should.equal(2)
      end
    end
    
    describe "when at an end tag" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<container><item></item></container>")
        @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
        @parser.nextEvent.type.should.equal(OPAL_START_TAG_EVENT) # skip container start tag
        @parser.nextEvent.type.should.equal(OPAL_START_TAG_EVENT) # skip item start tag

        @result = @parser.nextEvent # should be 'item' end tag
      end
      
      it "should return END_TAG" do
        @result.type.should.equal(OPAL_END_TAG_EVENT)
      end
      
      it "should update currentTagName" do
        @result.tagName.should.equal("item")
      end
      
      it "should advance the scan pointer to the end of the tag" do
        @parser.characterPosition.should.equal(24)
      end
      
      it "should store the result as currentEvent" do
        @parser.currentEvent.should.equal(@result)
      end
      
      it "should decrement the currentDepth" do
        @parser.currentDepth.should.equal(2)
      end
    end
    
    describe "when at a text" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<content>text &quot;la&#x0A; la </content>")
        @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
        @parser.nextEvent.type.should.equal(OPAL_START_TAG_EVENT) # skip content start tag

        @result = @parser.nextEvent
      end
      
      it "should return TEXT" do
        @result.type.should.equal(OPAL_TEXT_EVENT)
      end
      
      it "should read all text content, including references" do
        @result.content.should == "text \"la\n la "
      end
      
      it "should advance the scan pointer to the end of the text section" do
        @parser.characterPosition.should.equal(32)
      end
      
      it "should store the result as currentEvent" do
        @parser.currentEvent.should.equal(@result)
      end
      
      it "should not affect the current depth" do
        @parser.currentDepth.should.equal(2)
      end
    end
    
    describe "when at a comment" do
      before do
        @parser = OpalXMLParser.alloc.initWithString("<!-- comment --><tag></tag>")
        @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
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

      it "should store the result as currentEvent" do
        @parser.currentEvent.should.equal(@result)
      end
      
      it "should not affect the current depth" do
        @parser.currentDepth.should.equal(1)
      end
    end
    
    describe "when at the end of a document" do
      before do
        @parser = OpalXMLParser.parserWithString("<container></container>")
        @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
        @parser.nextEvent.type.should.equal(OPAL_START_TAG_EVENT) # skip container start tag
        @parser.nextEvent.type.should.equal(OPAL_END_TAG_EVENT) # skip container end tag

        @result = @parser.nextEvent
      end
      
      it "should return END_DOCUMENT" do
        @result.type.should.equal(OPAL_END_DOCUMENT_EVENT)
      end
      
      it "should decrement the currentDepth" do
        @parser.currentDepth.should.equal(0)
      end
    end
    
    
    describe "when after the end of a document" do
      before do
        @parser = OpalXMLParser.parserWithString("<container></container>")
        @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
        @parser.nextEvent.type.should.equal(OPAL_START_TAG_EVENT) # skip container start tag
        @parser.nextEvent.type.should.equal(OPAL_END_TAG_EVENT) # skip container end tag
        @parser.nextEvent.type.should.equal(OPAL_END_DOCUMENT_EVENT) # skip end document
      end
      
      it "should return nil" do
        @parser.nextEvent.should.be.nil
      end

      it "should not affect the currentDepth" do
        @parser.currentDepth.should.equal(0)
      end

    end
  end
  
  # ===== PEEKING ======================================================================================================

  describe "#peek" do
    before do
      @parser = OpalXMLParser.alloc.initWithString("<container><item></item></container>")
      @parser.nextEvent.type.should.equal(OPAL_START_DOCUMENT_EVENT) # skip start document
      
      @current = @parser.nextEvent
      @current.type.should.equal(OPAL_START_TAG_EVENT) # skip container start tag
      @event_count = @parser.eventCount
      @element_count = @parser.elementCount
      
      @result = @parser.peek # should be 'item' start tag
    end
    
    it "should return the next event without advancing" do
      @result.should.not.be.nil
      @result.type.should.equal(OPAL_START_TAG_EVENT)
      @result.tagName.should.equal("item")
      
      @parser.currentEvent.should.equal(@current)
      @parser.elementCount.should.equal(@element_count)
      @parser.eventCount.should.equal(@event_count)
    end
    
    it "should not affect a following call to #nextEvent" do
      @parser.nextEvent.should.equal(@result)
    end
    
  end
  
  # ===== SKIP ELEMENT CONTENT =========================================================================================
  
  describe "#skipElementContent" do
    before do
      @xml = <<-XML
        <?xml version="1.0" ?>
        <!-- OMG! -->
        <stories type="array">
          <story>
            <id type="integer">1</id>
          </story>
          <story>
            <id type="integer">2</id>
          </story>
        </stories>
      XML
      
      @parser = OpalXMLParser.parserWithString(@xml)
      @parser.nextStartTag.tagName.should.equal("stories")
      @result = @parser.skipElementContent
    end
    
    it "should skip all content and return the end tag" do
      @result.should.not.be.nil
      @result.isEndTag.should.be.true
      
      @result.tagName.should.equal("stories")
      @result.should.equal(@parser.currentEvent)
    end
    
  end
  
  # ===== HELPER METHODS ===============================================================================================

  describe "#nextEventOfType" do
    before do
      @xml = <<-XML
        <?xml version="1.0" ?>
        <!-- OMG! -->
        <stories type="array">
          <story>
            <id type="integer">1</id>
          </story>
          <story>
            <id type="integer">2</id>
          </story>
        </stories>
      XML
      
      @parser = OpalXMLParser.alloc.initWithString(@xml)
      @event = @parser.nextEventOfType(OPAL_START_TAG_EVENT)
    end
    
    it "should skip all events up to the type of event requested" do
      @event.should.not.be.nil
      @event.type.should.equal(OPAL_START_TAG_EVENT)
      @event.tagName.should.equal("stories")
    end
  end
  
  # ===== CHARACTER DATA ===============================================================================================

  describe "#readElementText" do
    before do
      @xml = <<-XML
        <tag>
          1
          <tag> 2</tag>
          3
          <tag></tag>
          4
        </tag>
      XML
      @parser = OpalXMLParser.parserWithString(@xml)
      @parser.nextStartTag.should.not.be.nil
      @parser.currentDepth.should.equal(2)
      
      @element_text = @parser.readElementText
    end
    
    it "should return all text content at the current depth" do
      indent = "          "
      @element_text.should.equal(["\n", indent, '1', "\n", indent, " 2", "\n", indent, '3', "\n", indent, "\n", indent, '4', "\n        "].join)
    end
    
    it "should leave currentEvent equal to the stop event (end tag)" do
      @parser.currentEvent.type.should.equal(OPAL_END_TAG_EVENT)
      @parser.currentEvent.tagName.should.equal("tag")
      @parser.currentDepth.should.equal(1)
    end
  end
  
end