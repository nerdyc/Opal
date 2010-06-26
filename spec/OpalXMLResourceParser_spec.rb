#!/usr/bin/env macruby
# OpalXMLResourceParser_spec.rb
# Opal
#
# Created by Christian Niles on 5/22/10.
# Copyright 2010 Christian Niles. All rights reserved.

require File.join(File.dirname(__FILE__), '../spec_helper')

describe "OpalXMLResourceParser" do
  
  describe ".parseResource" do
    
    describe "when provided an untyped resource with text content" do
      before do
        @xml = <<-XML
          <name>
            Tyrannosaurus Rex
          </name>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end

      it "should return a string" do
        @result.should.be.equal('name' => 'Tyrannosaurus Rex')
      end
    end
    
    describe "when provided an untyped resource with text content that contains entities" do
      before do
        @xml = <<-XML
          <name>
            Tyrannosaurus &quot;Rex&quot;
          </name>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end

      it "should return a string with the entities escaped" do
        @result.should.be.equal('name' => 'Tyrannosaurus "Rex"')
      end
    end
    
    describe "when provided an untyped resource with element content" do
      before do
        @xml = <<-XML
          <dinosaur>
            <name>Tyrannosaurus Rex</name>
            <period>Cretaceous</period>
          </dinosaur>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end

      it "should return a Hash" do
        @result.should.be.equal('dinosaur' => {
            'name' => 'Tyrannosaurus Rex',
            'period' => 'Cretaceous'
          })
      end
    end
    
    describe "when provided an untyped resource with complex element content" do
      before do
        @xml = <<-XML
          <dinosaur>
            <name>Tyrannosaurus Rex</name>
            <period>
              <name>Cretaceous</name>
            </period>
          </dinosaur>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end

      it "should return a Hash" do
        @result.should.be.equal('dinosaur' => {
            'name' => 'Tyrannosaurus Rex',
            'period' => { 'name' => 'Cretaceous' }
          })
      end
    end
    
    describe "when provided an complex resource with duplicate members" do
      before do
        @xml = <<-XML
          <dinosaur>
            <name>Tyrannosaurus Rex</name>
            <name>Thunder Lizard</name>
            <period>
              <name>Cretaceous</name>
            </period>
          </dinosaur>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end

      it "should collect the members into an array" do
        @result.should.be.equal('dinosaur' => {
            'name' => ['Tyrannosaurus Rex', 'Thunder Lizard'],
            'period' => { 'name' => 'Cretaceous' }
          })
      end
    end
    
    describe "when provided an 'array' resource" do
      before do
        @xml = <<-XML
          <stories type="array">
            <story>
              <id type="integer">1</id>
            </story>
            <story>
              <id type="integer">2</id>
            </story>
          </stories>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end
      
      it "should return an array" do
        @result.should.be.equal({
          'stories' => [
            { 'id' => 1 },
            { 'id' => 2 }
          ]
        })
      end
      
    end
    
    describe "when provided an 'integer' resource" do
      before do
        @xml = <<-XML
          <error_code type="integer">
            404
          </error_code>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end
      
      it "should return an integer" do
        @result.should.be.equal({
          'error_code' => 404
        })
      end
    end
    
    describe "when provided a 'datetime' resource" do
      before do
        @xml = <<-XML
          <last_activity_at type="datetime">
            2010/02/10 22:27:54 UTC
          </last_activity_at>
        XML
        
        @result = OpalXMLResourceParser.parseResourceFromString(@xml)
      end
      
      it "should return a parsed date" do
        @result.should.be.equal({
          'last_activity_at' => NSDate.dateWithString("2010-02-10 22:27:54 -0000")
        })
      end
    end
    
  end
  
  describe ".writeResource:toXMLString:" do
    describe "when provided a string" do
      it "should write the encoded string to the xmlString" do
        xmlString = ""
        OpalXMLResourceParser.writeResource("<this>&<that>", toXMLString:xmlString)
        xmlString.should.equal("&lt;this>&amp;&lt;that>")
      end
    end
    
    describe "when provided an NSDictionary" do
      it "should write the dictionary to the xmlString" do
        xmlString = ""
        OpalXMLResourceParser.writeResource({name:"value"}, toXMLString:xmlString)
        xmlString.should.equal("<name>value</name>")
      end
    end
    
    describe "when provided an NSArray" do
      it "should write each member to the xmlString" do
        xmlString = ""
        OpalXMLResourceParser.writeResource([{name:"value"}, "text", 1, {:label => "labelV"}], toXMLString:xmlString)
        xmlString.should.equal("<name>value</name>text1<label>labelV</label>")
      end
    end
  end
  
  describe ".writeResourceData:toXMLString:" do
    before do
      @resourceData = {
        "story" => {
          "id" => 2,
          "name" => "Blah <blah> & BLAH.",
          :date => NSDate.dateWithString("2010-01-02 03:45:00 -0800")
        }
      }
      
      @xmlString = ""
      OpalXMLResourceParser.writeResourceData(@resourceData, toXMLString:@xmlString)
    end
    
    it "should encode the data in XML" do
      @xmlString.should.equal([
          "<story>",
            "<id type='integer'>2</id>",
            "<name>Blah &lt;blah> &amp; BLAH.</name>",
            "<date type='datetime'>2010-01-02 03:45:00 -0800</date>",
          "</story>"
        ].join(""))
    end
  end
  
end