# opal_xml_scanner_spec.rb
# Opal
#
# Created by Christian Niles on 5/4/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


framework "Opal"

describe OpalXMLScanner do
  
  # ===== LOCATION METHODS =============================================================================================
  
  describe "#isAtEnd" do
    it "should return true when at the end of the string" do
      OpalXMLScanner.scannerWithString("").isAtEnd.should.be.true
    end
    
    it "should return false when not at the end of the string" do
      OpalXMLScanner.scannerWithString("<tag>").isAtEnd.should.be.false
    end
  end
  
  # ===== MATCHER METHODS ==============================================================================================

  describe "#isAtString" do
    
    it "should return true when the given string matches the current scan location" do
      OpalXMLScanner.scannerWithString("<tag>").isAtString("<").should.be.true
    end

    it "should return false when the given string doesn't match the current scan location" do
      OpalXMLScanner.scannerWithString("<tag>").isAtString("tag").should.be.false
    end
    
  end
  
  describe "#scanName" do
    describe "when at a tag name" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("tag>text</tag>")
        @result = @scanner.scanName
      end
      
      it "should return the tag name" do
        @result.should.equal("tag")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(3)
      end
    end
    
    describe "when not at a tag name" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&lt;")
        @result = @scanner.scanName
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
  end
  
  # ===== XML DECLARATION ==============================================================================================
  
  describe "#isAtXMLDeclaration" do
  
    it "should be true when the pointer is before an XML declaration" do
      OpalXMLScanner.scannerWithString("<?xml version='1.0' ?>").isAtXMLDeclaration.should.be.true
    end
    
    it "should be false when the pointer is not before an XML declaration" do
      OpalXMLScanner.scannerWithString("<?php echo ?>").isAtXMLDeclaration.should.be.false
    end
    
  end
  
  describe "#scanXMLDeclaration" do
    describe "when at an XML declaration" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("<?xml version='1.0' encoding='UTF8' standalone=\"yes\" ?><document />")
        @result = @scanner.scanXMLDeclaration
      end
      
      it "should return a hash of declaration data" do
        @result.should.equal('version' => '1.0', 'encoding' => 'UTF8', 'standalone' => 'yes')
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(55)
      end
    end
    
    describe "when not at an XML declaration" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("<?php echo ?>")
        @result = @scanner.scanXMLDeclaration
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
  end
  
  # ===== START TAG ====================================================================================================

  describe "#isAtStartTag" do
    
    it "should be true when the pointer is before a start tag" do
      OpalXMLScanner.scannerWithString("<tag>").isAtStartTag.should.be.true
    end
    
    it "should be false when the pointer is not before a start tag" do
      OpalXMLScanner.scannerWithString("</tag>").isAtStartTag.should.be.false
    end
    
  end
  
  # ===== ATTRIBUTES ===================================================================================================
  describe "#scanQuotedValue" do
    describe "when not at a quoted value" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("attr=\"1\">")
        @result = @scanner.scanQuotedValue
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
    describe "when at a single-quoted value" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("'1 or two Things \"> '>")
        @result = @scanner.scanQuotedValue
      end
      
      it "should return the quoted value" do
        @result.should.equal("1 or two Things \"> ")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(21)
      end
    end
    
    describe "when at a double-quoted value" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("\"1 or two Things '> \">")
        @result = @scanner.scanQuotedValue
      end
      
      it "should return the quoted value" do
        @result.should.equal("1 or two Things '> ")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(21)
      end    
    end
    
    describe "when at a quoted value containing entities" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("'1 or two Things &quot;&gt; '>")
        @result = @scanner.scanQuotedValue
      end
      
      it "should return the quoted value, without replacing entities" do
        @result.should.equal("1 or two Things &quot;&gt; ")
      end
      
      it "should advance the scan pointer past the last quote" do
        @scanner.scanLocation.should.equal(29)
      end
    end
  end
  
  describe "#scanAttributeValue" do
    describe "when at an attribute value with entities" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("'1 or two Things &quot;&gt; '>")
        @result = @scanner.scanAttributeValue
      end
      
      it "should return the attribute value, with entities replaced" do
        @result.should.equal("1 or two Things \"> ")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(29)
      end
    end
        
  end
  
  describe "#scanAttributeInto" do
    
    describe "when not at an attribute" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("pi = 3.17 in some countries")
        @attributes = {}
        @result = @scanner.scanAttributeInto(@attributes)
      end
      
      it "should return false" do
        @result.should.be.false
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
      
      it "should not change the attribute hash" do
        @attributes.should.be.empty
      end
    end
    
    describe "when at an attribute" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("ns:name='value'>")
        @attributes = {}
        @result = @scanner.scanAttributeInto(@attributes)
      end
      
      it "should return true" do
        @result.should.be.true
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(15)
      end
      
      it "should insert the value into the hash" do
        @attributes.should.equal('ns:name' => 'value')
      end
    end  
  end

  describe "#scanAttributes" do
    
    describe "when not at an attribute list" do
      it "should return nil" do
        OpalXMLScanner.scannerWithString("<tag>").scanAttributes.should.be.nil
      end
    end
    
    describe "when a single attribute is present" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("name='value'>")
        @result = @scanner.scanAttributes
      end
      
      it "should return the attribute" do
        @result.should.equal('name' => 'value')
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(12)
      end
    end
    
    describe "when mutiple attributes are present" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("name='value' key=\"VALUE\">")
        @result = @scanner.scanAttributes
      end
      
      it "should return the attribute" do
        @result.should.equal('name' => 'value', 'key' => 'VALUE')
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(24)
      end
    end
    
  end
  
  # ===== END TAG ======================================================================================================

  describe "#isAtEndTag" do
    it "should be true when the pointer is before an end tag" do
      OpalXMLScanner.scannerWithString("</tag>").isAtEndTag.should.be.true
    end
    
    it "should be false when the pointer is not before an end tag" do
      OpalXMLScanner.scannerWithString("<tag>").isAtEndTag.should.be.false
    end
  end
  
  # ===== WHITESPACE ===================================================================================================
  
  describe "#isAtWhitespace" do
    it "should return true when at whitespace" do
      OpalXMLScanner.scannerWithString("\n\t\n\t<tag>").isAtWhitespace.should.be.true
    end
    
    it "should return false when not at whitespace" do
      OpalXMLScanner.scannerWithString("&#x0A;\n\t\n\t<tag>").isAtWhitespace.should.be.false
    end
  end
  
  describe "#scanWhitespace" do
    describe "when not at whitespace" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&#x0A;\n\t\n\t<tag>")
        @result = @scanner.scanWhitespace
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
    describe "when at whitespace" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("\n\t\n\t<tag>")
        @result = @scanner.scanWhitespace
      end
      
      it "should return the whitespace" do
        @result.should.equal("\n\t\n\t")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(4)
      end
    end
  end
  
  # ===== REFERENCES ===================================================================================================
  
  describe "#scanReference" do
    describe "when not at a reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("<tag>")
        @result = @scanner.scanReference
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
    describe "when at a reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&lt;")
        @result = @scanner.scanReference
      end
      
      it "should return the reference value" do
        @result.should.equal("<")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(4)
      end
    end
    
    it "should recognize entity references" do
      OpalXMLScanner.scannerWithString("&amp;").scanReference.should.equal("&")
    end
    
    it "should recognize hex character references" do
      OpalXMLScanner.scannerWithString("&#x0A;").scanReference.should.equal("\x0A")
    end

    it "should recognize decimal character references" do
      OpalXMLScanner.scannerWithString("&#10;").scanReference.should.equal(10.chr)
    end
    
  end

  # ----- CHARACTER REFERENCES -----------------------------------------------------------------------------------------
  
  describe "#isAtCharacterReference" do
    it "should be true when the pointer is before a hex character reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtCharacterReference.should.be.true
    end
    
    it "should be true when the pointer is before a decimal character reference" do
      OpalXMLScanner.scannerWithString("&#10;").isAtCharacterReference.should.be.true
    end
    
    it "should be false when the pointer is not before a character reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtCharacterReference.should.be.false
    end
  end
  
  describe "#isAtHexCharacterReference" do
    it "should be true when the pointer is before a hex character reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtHexCharacterReference.should.be.true
    end
    
    it "should be fals when the pointer is before a decimal character reference" do
      OpalXMLScanner.scannerWithString("&#10;").isAtHexCharacterReference.should.be.false
    end
    
    it "should be false when the pointer is not before a character reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtHexCharacterReference.should.be.false
    end
  end
  
  describe "#isAtDecimalCharacterReference" do
    it "should be false when the pointer is before a hex character reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtDecimalCharacterReference.should.be.false
    end
    
    it "should be true when the pointer is before a decimal character reference" do
      OpalXMLScanner.scannerWithString("&#10;").isAtDecimalCharacterReference.should.be.true
    end
    
    it "should be false when the pointer is not before a character reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtDecimalCharacterReference.should.be.false
    end
  end
  
  describe "#scanHexCharacterReference" do
    describe "when not before a hex reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&#10;")
        @result = @scanner.scanHexCharacterReference
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
    describe "when before a hex reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&#xA;")
        @result = @scanner.scanHexCharacterReference
      end
      
      it "should return nil" do
        @result.should.equal("\x0A")
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(5)
      end
    end
    
    it "should recognize 1-digit hex character references" do
      OpalXMLScanner.scannerWithString("&#xA;").scanHexCharacterReference.should.equal("\u000A")
    end

    it "should recognize 2-digit hex character references" do
      OpalXMLScanner.scannerWithString("&#xA2;").scanHexCharacterReference.should.equal("\u00A2")
    end
    
    it "should recognize 3-digit hex character references" do
      OpalXMLScanner.scannerWithString("&#x106;").scanHexCharacterReference.should.equal("\u0106")
    end

    it "should recognize 4-digit hex character references" do
      OpalXMLScanner.scannerWithString("&#x1D01;").scanHexCharacterReference.should.equal("\u1D01")
    end
    
    it "should recognize 5-digit hex character references" do
      OpalXMLScanner.scannerWithString("&#x10300;").scanHexCharacterReference.should.equal("\u{10300}")
    end

    it "should recognize 6-digit hex character references" do
      OpalXMLScanner.scannerWithString("&#x103000;").scanHexCharacterReference.should.equal("\u{103000}")
    end
    
    it "should igore leading zeroes" do
      OpalXMLScanner.scannerWithString("&#x00000000000000000103000;").scanHexCharacterReference.should.equal("\u{103000}")
    end
    
    it "should handle nul character" do
      OpalXMLScanner.scannerWithString("&#x0;").scanHexCharacterReference.should.equal("\u{0000}")
    end
    
  end
  
  describe "#scanDecimalCharacterReference" do
    describe "when not before a decimal reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&#x0A;")
        @result = @scanner.scanDecimalCharacterReference
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
    describe "when before a decimal reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&#10;&#11;")
        @result = @scanner.scanDecimalCharacterReference
      end
      
      it "should return the reference value" do
        @result.should.equal("\x0A")
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(5)
      end
    end
    
    it "should ignore zero-length references" do
      OpalXMLScanner.scannerWithString("&#;").scanDecimalCharacterReference.should.be.nil
    end
    
    it "should handle nul character" do
      OpalXMLScanner.scannerWithString("&#0;").scanDecimalCharacterReference.should.equal("\u{0000}")
    end
    
    it "should handle large characters" do
      OpalXMLScanner.scannerWithString("&#66304;").scanDecimalCharacterReference.should.equal("\u{10300}")
    end
    
    it "should handle really large characters" do
      OpalXMLScanner.scannerWithString("&#1060864;").scanDecimalCharacterReference.should.equal("\u{103000}")
    end
    
    it "should igore leading zeroes" do
      OpalXMLScanner.scannerWithString("&#00000000000000000000010;").scanDecimalCharacterReference.should.equal("\x0A")
    end
    
  end
  
  # ----- ENTITY REFERENCES --------------------------------------------------------------------------------------------

  describe "#isAtEntityReference" do
    it "should be true when the pointer is before an entity reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtEntityReference.should.be.true
    end
    
    it "should be false when the pointer is not before an entity reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtEntityReference.should.be.false
    end
  end
  
  describe "#scanEntityReference" do
    
    describe "when not at an entity reference" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&#x0A;")
        @result = @scanner.scanEntityReference
      end
      
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
    it "should recognize &lt;" do
      OpalXMLScanner.scannerWithString("&lt;").scanEntityReference.should.equal("<")
    end

    it "should recognize &gt;" do
      OpalXMLScanner.scannerWithString("&gt;").scanEntityReference.should.equal(">")
    end
    
    it "should recognize &amp;" do
      OpalXMLScanner.scannerWithString("&amp;").scanEntityReference.should.equal("&")
    end
    
    it "should recognize &apos;" do
      OpalXMLScanner.scannerWithString("&apos;").scanEntityReference.should.equal("'")
    end
    
    it "should recognize &quot;" do
      OpalXMLScanner.scannerWithString("&quot;").scanEntityReference.should.equal("\"")
    end
    
    describe "when at an unrecognized entity" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("&wtf;&lt;")
        @result = @scanner.scanEntityReference
      end
      
      it "should return nil" do
        # FIXME: this should throw a parsing error
        @result.should.be.nil
      end
      
      it "should advance the scan pointer" do
        @scanner.scanLocation.should.equal(5)
      end

    end
  end
  
  describe ".unescapeValue" do
    it "should escape all character and entity references" do
      OpalXMLScanner.unescapeValue("A &lt;tag&gt; v&#xA;lue&#10;").should.equal("A <tag> v\x0Alue\x0A")
    end
  end
  
  # ===== COMMENTS =====================================================================================================
  
  describe "#isAtComment" do
    
    it "should be true when the pointer is before a comment" do
      OpalXMLScanner.scannerWithString("<!-- comment -->").isAtComment.should.be.true
    end
    
    it "should be false when the pointer is not before a comment" do
      OpalXMLScanner.scannerWithString("<!DOCTYPE greeting SYSTEM \"hello.dtd\">").isAtComment.should.be.false
    end
    
  end
  
  describe "#scanComment" do
    
    describe "when at a comment" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("<!-- Comment --> and some other stuff")
        @result = @scanner.scanComment
      end
      
      it "should return the comment body" do
        @result.should.be.equal(" Comment ")
      end
      
      it "should advance the scan pointer to the end of the comment" do
        @scanner.scanLocation.should.equal(16)
      end
      
    end
    
    describe "when not at a comment" do
      before do
        @scanner = OpalXMLScanner.scannerWithString("<!DOCTYPE greeting SYSTEM \"hello.dtd\">")
        @result = @scanner.scanComment
      end
    
      it "should return nil" do
        @result.should.be.nil
      end
      
      it "should not advance the scan pointer" do
        @scanner.scanLocation.should.equal(0)
      end
    end
    
  end
  
end