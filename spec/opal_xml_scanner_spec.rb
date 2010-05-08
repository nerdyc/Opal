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
      OpalXMLScanner.scannerWithString("").isAtEnd.should.equal(1)
    end
    
    it "should return false when not at the end of the string" do
      OpalXMLScanner.scannerWithString("<tag>").isAtEnd.should.equal(0)
    end
  end
  
  # ===== MATCHER METHODS ==============================================================================================

  describe "#isAtString" do
    
    it "should return true when the given string matches the current scan location" do
      OpalXMLScanner.scannerWithString("<tag>").isAtString("<").should.equal(1)
    end

    it "should return false when the given string doesn't match the current scan location" do
      OpalXMLScanner.scannerWithString("<tag>").isAtString("tag").should.equal(0)
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
      OpalXMLScanner.scannerWithString("<?xml version='1.0' ?>").isAtXMLDeclaration.should.equal(1)
    end
    
    it "should be false when the pointer is not before an XML declaration" do
      OpalXMLScanner.scannerWithString("<?php echo ?>").isAtXMLDeclaration.should.equal(0)
    end
    
  end

  # ===== START TAG ====================================================================================================

  describe "#isAtStartTag" do
    
    it "should be true when the pointer is before a start tag" do
      OpalXMLScanner.scannerWithString("<tag>").isAtStartTag.should.equal(1)
    end
    
    it "should be false when the pointer is not before a start tag" do
      OpalXMLScanner.scannerWithString("</tag>").isAtStartTag.should.equal(0)
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
  
  # ===== END TAG ======================================================================================================

  describe "#isAtEndTag" do
    it "should be true when the pointer is before an end tag" do
      OpalXMLScanner.scannerWithString("</tag>").isAtEndTag.should.equal(1)
    end
    
    it "should be false when the pointer is not before an end tag" do
      OpalXMLScanner.scannerWithString("<tag>").isAtEndTag.should.equal(0)
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
      OpalXMLScanner.scannerWithString("&#x0A;").isAtCharacterReference.should.equal(1)
    end
    
    it "should be true when the pointer is before a decimal character reference" do
      OpalXMLScanner.scannerWithString("&#10;").isAtCharacterReference.should.equal(1)
    end
    
    it "should be false when the pointer is not before a character reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtCharacterReference.should.equal(0)
    end
  end
  
  describe "#isAtHexCharacterReference" do
    it "should be true when the pointer is before a hex character reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtHexCharacterReference.should.equal(1)
    end
    
    it "should be fals when the pointer is before a decimal character reference" do
      OpalXMLScanner.scannerWithString("&#10;").isAtHexCharacterReference.should.equal(0)
    end
    
    it "should be false when the pointer is not before a character reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtHexCharacterReference.should.equal(0)
    end
  end
  
  describe "#isAtDecimalCharacterReference" do
    it "should be false when the pointer is before a hex character reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtDecimalCharacterReference.should.equal(0)
    end
    
    it "should be true when the pointer is before a decimal character reference" do
      OpalXMLScanner.scannerWithString("&#10;").isAtDecimalCharacterReference.should.equal(1)
    end
    
    it "should be false when the pointer is not before a character reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtDecimalCharacterReference.should.equal(0)
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
      OpalXMLScanner.scannerWithString("&amp;").isAtEntityReference.should.equal(1)
    end
    
    it "should be false when the pointer is not before an entity reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtEntityReference.should.equal(0)
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
      OpalXMLScanner.scannerWithString("<!-- comment -->").isAtComment.should.equal(1)
    end
    
    it "should be false when the pointer is not before a comment" do
      OpalXMLScanner.scannerWithString("<!DOCTYPE greeting SYSTEM \"hello.dtd\">").isAtComment.should.equal(0)
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