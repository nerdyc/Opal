# opal_xml_scanner_spec.rb
# Opal
#
# Created by Christian Niles on 5/4/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


framework "Opal"

describe OpalXMLScanner do
  
  
  describe "#isAtEnd" do
    it "should return true when at the end of the string" do
      OpalXMLScanner.scannerWithString("").isAtEnd.should.equal(1)
    end
    
    it "should return false when not at the end of the string" do
      OpalXMLScanner.scannerWithString("<tag>").isAtEnd.should.equal(0)
    end
  end
  
  describe "#isAtString" do
    
    it "should return true when the given string matches the current scan location" do
      OpalXMLScanner.scannerWithString("<tag>").isAtString("<").should.equal(1)
    end

    it "should return false when the given string doesn't match the current scan location" do
      OpalXMLScanner.scannerWithString("<tag>").isAtString("tag").should.equal(0)
    end
    
  end
  
  describe "#isAtStartTag" do
    
    it "should be true when the pointer is before a start tag" do
      OpalXMLScanner.scannerWithString("<tag>").isAtStartTag.should.equal(1)
    end
    
    it "should be false when the pointer is not before a start tag" do
      OpalXMLScanner.scannerWithString("</tag>").isAtStartTag.should.equal(0)
    end
    
  end
  
  describe "#isAtEndTag" do
    it "should be true when the pointer is before an end tag" do
      OpalXMLScanner.scannerWithString("</tag>").isAtEndTag.should.equal(1)
    end
    
    it "should be false when the pointer is not before an end tag" do
      OpalXMLScanner.scannerWithString("<tag>").isAtEndTag.should.equal(0)
    end
  end
  
  describe "#scanTagName" do
    
    it "should return the tag name when found" do
      OpalXMLScanner.scannerWithString("tag>text</tag>").scanTagName.should.equal("tag")
    end
    
    it "should return nil when not at a tag name" do
      OpalXMLScanner.scannerWithString("&lt;").scanTagName.should.be.nil
    end
    
  end

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

  
  describe "#isAtEntityReference" do
    it "should be true when the pointer is before an entity reference" do
      OpalXMLScanner.scannerWithString("&amp;").isAtEntityReference.should.equal(1)
    end
    
    it "should be false when the pointer is not before an entity reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").isAtEntityReference.should.equal(0)
    end
  end

  describe "#scanReference" do

    it "should recognize &lt;" do
      OpalXMLScanner.scannerWithString("&lt;").scanReference.should.equal("<")
    end

    it "should recognize &gt;" do
      OpalXMLScanner.scannerWithString("&gt;").scanReference.should.equal(">")
    end
    
    it "should recognize &amp;" do
      OpalXMLScanner.scannerWithString("&amp;").scanReference.should.equal("&")
    end
    
    it "should recognize &apos;" do
      OpalXMLScanner.scannerWithString("&apos;").scanReference.should.equal("'")
    end
    
    it "should recognize &quot;" do
      OpalXMLScanner.scannerWithString("&quot;").scanReference.should.equal("\"")
    end
    
    it "should recognize hex character references" do
      OpalXMLScanner.scannerWithString("&#x0A;").scanReference.should.equal("\x0A")
    end

    it "should recognize decimal character references" do
      OpalXMLScanner.scannerWithString("&#10;").scanReference.should.equal(10.chr)
    end
    
  end
  
  describe "#scanHexCharacterReference" do
    it "should return nil when not before a hex reference" do
      OpalXMLScanner.scannerWithString("&#10;").scanHexCharacterReference.should.be.nil
    end
    
    it "should ignore zero-length references" do
      OpalXMLScanner.scannerWithString("&#x;").scanHexCharacterReference.should.be.nil
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
    it "should return nil when not before a decimal reference" do
      OpalXMLScanner.scannerWithString("&#x0A;").scanDecimalCharacterReference.should.be.nil
    end
    
    it "should ignore zero-length references" do
      OpalXMLScanner.scannerWithString("&#;").scanDecimalCharacterReference.should.be.nil
    end
    
    it "should handle nul character" do
      OpalXMLScanner.scannerWithString("&#0;").scanDecimalCharacterReference.should.equal("\u{0000}")
    end
    
    it "should handle ascii characters" do
      OpalXMLScanner.scannerWithString("&#10;").scanDecimalCharacterReference.should.equal("\u{000A}")
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
  
end