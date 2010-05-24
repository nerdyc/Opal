# OpalXMLEvent_spec.rb
# Opal
#
# Created by Christian Niles on 5/23/10.
# Copyright 2010 Christian Niles. All rights reserved.


framework "Opal"

describe "OpalXMLEvent" do
  
  # ===== START TAGS ===================================================================================================
  
  describe "#valueForAttribute" do
    
    before do
      @start_tag = OpalXMLEvent.startTagEventWithTagName("taggity", andAttributes:{type: 'array'})
      @end_tag = OpalXMLEvent.endTagEventWithTagName("taggity")
    end
    
    it "should return the value of the attribute when present" do
      @start_tag.valueForAttribute('type').should.equal('array')
    end
    
    it "should return nil when not present" do
      @start_tag.valueForAttribute('not-there').should.be.nil
    end
    
    it "should return nil when the event is not a start tag" do
      @end_tag.valueForAttribute('type').should.be.nil
    end
  end
  
  # ===== TEXT =========================================================================================================
  
  describe "#isWhitespace" do
    
    describe "on a text event" do
      describe "containing only whitespace" do
        it "should return true" do
          OpalXMLEvent.textEventWithContent("\r\n\t ").isWhitespace.should.be.true
        end
      end
      
      describe "containing non-whitespace characters" do
        it "should return false" do
          OpalXMLEvent.textEventWithContent("\r\n\t b").isWhitespace.should.be.false
        end
      end
    end
    
    describe "on a non-text event" do
      it "should return false" do
        OpalXMLEvent.startDocumentEvent.isWhitespace.should.be.false
      end
    end
    
  end
  
end