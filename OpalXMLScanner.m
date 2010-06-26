//
//  OpalXMLScanner.m
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import "OpalXMLScanner.h"
#import "RegexKitLite.h"

// ===== CONSTANTS =====================================================================================================

NSString *OpalStartTagBeginToken = @"<";
NSString *OpalEndTagBeginToken = @"</";
NSString *OpalTagEndToken = @">";

NSString *OpalStartTagBeginPattern = nil;

NSString *OpalXMLNameStartCharsPattern = @"[:a-z_A-Z\\xC0-\\xD6\\xD8-\\xF6\\xF8-\\x{2FF}\\x{370}-\\x{37D}\\x{37F}-\\x{1FFF}\\x{200C}-\\x{200D}\\x{2070}-\\x{218F}\\x{2C00}-\\x{2FEF}\\x{3001}-\\x{D7FF}\\x{F900}-\\x{FDCF}\\x{FDF0}-\\x{FFFD}\\U00010000-\\U000EFFFF]";
NSString *OpalXMLNameCharsPattern = @"[:a-z_A-Z\\xC0-\\xD6\\xD8-\\xF6\\xF8-\\x{2FF}\\x{370}-\\x{37D}\\x{37F}-\\x{1FFF}\\x{200C}-\\x{200D}\\x{2070}-\\x{218F}\\x{2C00}-\\x{2FEF}\\x{3001}-\\x{D7FF}\\x{F900}-\\x{FDCF}\\x{FDF0}-\\x{FFFD}\\U00010000-\\U000EFFFF\\.\\-0-9\\xB7\\x{0300}-\\x{036F}\\x{203F}-\\x{2040}]";
NSString *OpalXMLNamePattern = nil;

NSString *OpalXMLReferencePattern = nil;
NSString *OpalXMLDecimalCharacterReferencePattern = @"^&#0*([0-9]+);";
NSString *OpalXMLHexCharacterReferencePattern = @"^&#x0*([0-9a-fA-F]+);";
NSString *OpalXMLEntityReferencePattern = nil;

NSDictionary *OpalXMLDefaultEntities = nil;
NSCharacterSet *OpalXMLSymbolCharacterSet = nil;

NSString *OpalCommentBeginToken = @"<!--";
NSString *OpalCommentEndToken = @"-->";
NSString *OpalXMLCommentPattern = @"^<!--([\\x09\\x0A\\x0D\\x20-\\x{D7FF}\\x{E000}-\\x{FFFD}\\U00010000-\\U0010FFFF]*?)-->";
NSString *OpalXMLWhitespacePattern = @"^\\s+";

@implementation OpalXMLScanner

#pragma mark Initialization
// ===== INITIALIZATION ================================================================================================

+(void)initialize
{
  OpalXMLNamePattern = [[NSString alloc] initWithFormat:@"^%@%@*", OpalXMLNameStartCharsPattern, OpalXMLNameCharsPattern, nil];
  OpalXMLEntityReferencePattern = [[NSString alloc] initWithFormat:@"^&(%@%@*);", OpalXMLNameStartCharsPattern, OpalXMLNameCharsPattern, nil];
  OpalXMLSymbolCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"<&"] retain];
  
  OpalStartTagBeginPattern = [[NSString alloc] initWithFormat:@"^<%@%@*[\\s/>]", OpalXMLNameStartCharsPattern, OpalXMLNameCharsPattern, nil];
  
  OpalXMLReferencePattern = [[NSString alloc] initWithFormat:@"&(#x0*([0-9a-fA-F]+)|#0*([0-9]+)|%@%@*);", OpalXMLNameStartCharsPattern, OpalXMLNameCharsPattern, nil];
  
  OpalXMLDefaultEntities = [[NSDictionary dictionaryWithObjectsAndKeys:@"<", @"lt", @">", @"gt", @"&", @"amp", @"'", @"apos", @"\"", @"quot", nil] retain];
}

- (id)initWithString:(NSString *)xmlString
{
  if (self = [super init]) {
    scanner = [[NSScanner alloc] initWithString:xmlString];
    // don't skip any characters
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
  }
  return self;
}

- (void)dealloc
{
  [scanner release];
  [super dealloc];
}

+ (OpalXMLScanner *)scannerWithString:(NSString *)string
{
  return [[[OpalXMLScanner alloc] initWithString:string] autorelease];
}

#pragma mark Location
// ===== LOCATION ======================================================================================================

- (NSUInteger)scanLocation
{
  return [scanner scanLocation];
}

- (NSUInteger)remainingChars
{
  return [[self xmlString] length] - [self scanLocation];
}

- (BOOL)isAtEnd
{
  return [self remainingChars] == 0;
}

- (NSString *)xmlString
{
  return [scanner string];
}

- (NSRange)scanRange
{
  return NSMakeRange([self scanLocation], [self remainingChars]);
}

#pragma mark XML Declaration
// ===== XML DECLARATION ===============================================================================================

- (BOOL)isAtXMLDeclaration
{
  return [self matchesRegex:@"<\\?xml\\s+"];
}

- (NSMutableDictionary *)scanXMLDeclaration
{
  NSUInteger originalLocation = [self scanLocation];
  if ([self scanRegex:@"<\\?xml\\s+"]) {
    NSMutableDictionary *declarationData = [self scanAttributes];
    [self scanWhitespace];
    if ([self scanRegex:@"\\?>"]) {
      return declarationData;
    } else {
      // wha? ill formed declaration
      [scanner setScanLocation:originalLocation];
      return nil;
    }
  } else {
    return nil;
  }
}

#pragma mark Start Tag
// ===== START TAG =====================================================================================================

-(BOOL)isAtStartTag
{
  return [self matchesRegex:OpalStartTagBeginPattern];
}

- (BOOL)scanStartTagBeginToken
{
  return [scanner scanString:OpalStartTagBeginToken intoString:NULL];
}

#pragma mark Attributes
// ===== ATTRIBUTES ====================================================================================================

- (NSString *)scanAttributeValue
{
  return [OpalXMLScanner unescapeValue:[self scanQuotedValue]];
}

- (NSString *)scanQuotedValue
{
  NSString *quote = [self scanRegex:@"^['\"]"];
  if (quote != nil) {
    NSString *rawValue = nil;
    [scanner scanUpToString:quote intoString:&rawValue];
    [scanner scanString:quote intoString:NULL];
    return rawValue;
  } else {
    return nil;
  }
}

- (NSMutableDictionary *)scanAttributes
{
  NSMutableDictionary *attributes = nil;
  NSUInteger finalScanLocation = [self scanLocation];
  if ([self isAtName]) {
    attributes = [NSMutableDictionary dictionaryWithCapacity:1];    
    while ([self scanAttributeInto:attributes]) {
      finalScanLocation = [self scanLocation];
      [self scanWhitespace]; // skip whitespace
    }
    
    
    if ([attributes count] > 0) {
      [scanner setScanLocation:finalScanLocation];
      return attributes;
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

- (BOOL)scanAttributeInto:(NSMutableDictionary *)dictionary
{
  NSUInteger originalScanLocation = [self scanLocation];
  NSString *attributeName = nil;
  NSString *attributeValue = nil;
  
  attributeName = [self scanName];
  if (attributeName != nil) {
    if ([self scanEquals] != nil) {
      attributeValue = [self scanAttributeValue];
      if (attributeValue != nil) {
        [dictionary setObject:attributeValue forKey:attributeName];
        return YES;
      }
    }
  }
  
  // not found. Reset the scan pointer and return NO
  [scanner setScanLocation:originalScanLocation];
  return NO;
}

#pragma mark End Tag
// ===== END TAG =======================================================================================================

- (BOOL)isAtEndTag
{
  return [self isAtString:OpalEndTagBeginToken];
}

- (BOOL)scanEndTagBeginToken
{
  return [scanner scanString:OpalEndTagBeginToken intoString:NULL];
}

- (BOOL)scanTagEndToken
{
  return [scanner scanString:OpalTagEndToken intoString:NULL];
}

#pragma mark Text
// ===== TEXT ==========================================================================================================

- (BOOL)isAtText
{
  return [self isAtCharacterData] || [self isAtReference];
}

- (NSString *)scanText
{
  if (![self isAtText]) return nil;
  
  NSMutableString *string = [[[NSMutableString alloc] initWithCapacity:0] autorelease];
  while (YES) {
    if ([self isAtReference]) {
      [string appendString:[self scanReference]];
    } else if ([self isAtCharacterData]) {
      [string appendString:[self scanCharacterData]];
    } else {
      return string;
    }
  };
}

#pragma mark References
// ===== REFERENCES ====================================================================================================

- (BOOL)isAtReference
{
  return ([self isAtCharacterReference] || [self isAtEntityReference]);
}

- (NSString *)scanReference
{
  NSString *refValue = [self scanCharacterReference];
  if (refValue == nil) {
    refValue = [self scanEntityReference];
  }
  return refValue;
}

#pragma mark Character References
// ----- CHARACTER REFERENCES ------------------------------------------------------------------------------------------

- (BOOL)isAtCharacterReference
{
  return([self isAtHexCharacterReference] || [self isAtDecimalCharacterReference]);
}

- (NSString *)scanCharacterReference
{
  NSString *charRef = [self scanHexCharacterReference];
  if (charRef == nil) {
    charRef = [self scanDecimalCharacterReference];
  }
  return charRef;
}


- (BOOL)isAtHexCharacterReference
{
  return [[self xmlString] isMatchedByRegex:OpalXMLHexCharacterReferencePattern inRange:[self scanRange]];
}

- (NSString *)scanHexCharacterReference
{
  NSString *hexString = [self scanRegex:OpalXMLHexCharacterReferencePattern capture:1];
  return [OpalXMLScanner unescapeHexString:hexString];
}

- (BOOL)isAtDecimalCharacterReference
{
  return [[self xmlString] isMatchedByRegex:OpalXMLDecimalCharacterReferencePattern inRange:[self scanRange]];
}

- (NSString *)scanDecimalCharacterReference
{
  NSString *decimalString = [self scanRegex:OpalXMLDecimalCharacterReferencePattern capture:1];
  return [OpalXMLScanner unescapeDecimalString:decimalString];
}

+ (NSString *)stringFromUnicodeCharacter:(UInt32)unicodeCharacter
{
  UInt32 stringBuffer[] = { unicodeCharacter };
  NSData* stringData = [NSData dataWithBytes:stringBuffer length:sizeof(UInt32)];
  
  NSStringEncoding encoding;
  if (CFByteOrderGetCurrent() == CFByteOrderBigEndian) {
    encoding = NSUTF32BigEndianStringEncoding;
  } else {
    encoding = NSUTF32LittleEndianStringEncoding;
  }
  
  return [[[NSString alloc] initWithData:stringData encoding:encoding] autorelease];
}

+ (NSString *)unescapeValue:(NSString *)stringValue
{
  if (stringValue == nil || [stringValue length] == 0) return stringValue;
  
  // keep track of the position in the search string, as well as the unescaped string
  NSUInteger searchPosition = 0;
  NSUInteger replacePosition = 0;
  NSMutableString *unescapedString = nil;
  while (true) {
    NSRange searchRange = NSMakeRange(searchPosition, [stringValue length] - searchPosition);
    NSRange matchRange = [stringValue rangeOfRegex:OpalXMLReferencePattern
                                           inRange:searchRange];
    if (matchRange.location == NSNotFound) {
      break;
    } else {
      // update search and replace positions to point to the same relative position in the string
      replacePosition += (matchRange.location - searchPosition);
      searchPosition = matchRange.location + matchRange.length;
      
      // unescape the reference...
      NSString *matchedString = [stringValue substringWithRange:matchRange];
      NSString *replacementString;
      if ([matchedString hasPrefix:@"&#x"]) {
        NSString *hexMatch = [stringValue substringWithRange:NSMakeRange(matchRange.location+3, matchRange.length-4)];
        replacementString = [self unescapeHexString:hexMatch];
      } else if ([matchedString hasPrefix:@"&#"]) {
        NSString *decimalMatch = [stringValue substringWithRange:NSMakeRange(matchRange.location+2, matchRange.length-3)];
        replacementString = [self unescapeDecimalString:decimalMatch];
      } else {
        // entity reference
        NSString *entityMatch = [stringValue substringWithRange:NSMakeRange(matchRange.location+1, matchRange.length-2)];
        replacementString = [self translateEntityReference:entityMatch];
      }
      
      // ...and replace it with the value
      if (unescapedString == nil) {
        unescapedString = [NSMutableString stringWithString:stringValue];
      }
      
      NSRange replacementRange = NSMakeRange(replacePosition, matchRange.length);
      [unescapedString replaceCharactersInRange:replacementRange withString:replacementString];
      
      // update the replacement position to point to after the replacement string
      replacePosition += [replacementString length];
    }
  }
  
  if (unescapedString == nil) {
    return stringValue;
  } else {
    return unescapedString;
  }
}

+ (NSString *)unescapeHexString:(NSString *)hexString
{
  if (hexString != nil && [hexString length] <= 8) {
    NSScanner *hexScanner = [NSScanner scannerWithString:hexString];
    unsigned charInt = 0;
    if ([hexScanner scanHexInt:&charInt]) {
      // convert int to unicode character
      return [OpalXMLScanner stringFromUnicodeCharacter:charInt];
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

+ (NSString *)unescapeDecimalString:(NSString *)decimalString
{
  if (decimalString != nil && [decimalString length] <= 8) {
    NSScanner *decimalScanner = [NSScanner scannerWithString:decimalString];
    long long charValue = 0;
    if ([decimalScanner scanLongLong:&charValue]) {
      if (charValue >= 0 && charValue < 0x1000000) {
        // convert int to unicode character
        return [OpalXMLScanner stringFromUnicodeCharacter:(UInt32)charValue];
      } else {
        return nil;
      }
    } else {
      return nil;
    }
  } else {
    return nil;
  }
}

+ (NSString *)escapeString:(NSString *)string
{
  if (string == nil) return nil;
  
  NSCharacterSet *xmlControlSet = [NSCharacterSet characterSetWithCharactersInString:@"&<"];
  NSRange foundRange = [string rangeOfCharacterFromSet:xmlControlSet];
  if (foundRange.location == NSNotFound) {
    return string;
  } else {
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    [self escapeStringInline:mutableString];
    return mutableString;
  }
}

+ (void)escapeStringInline:(NSMutableString *)mutableString
{
  [mutableString replaceOccurrencesOfString:@"&"
                                 withString:@"&amp;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [mutableString length])];
  
  
  [mutableString replaceOccurrencesOfString:@"<"
                                 withString:@"&lt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [mutableString length])];
}

#pragma mark Entity References
// ----- ENTITY REFERENCES ---------------------------------------------------------------------------------------------

- (BOOL)isAtEntityReference
{
  return [[self xmlString] isMatchedByRegex:OpalXMLEntityReferencePattern inRange:[self scanRange]];
}

- (NSString *)scanEntityReference
{
  NSString *entityRef = [self scanRegex:OpalXMLEntityReferencePattern capture:1];
  return [OpalXMLScanner translateEntityReference:entityRef];
}

+ (NSString *)translateEntityReference:(NSString *)entityRef
{
  return [OpalXMLDefaultEntities objectForKey:entityRef];
}

#pragma mark Character Data
// ===== CHARACTER DATA ================================================================================================

- (BOOL)isAtCharacterData
{
  return [self matchesRegex:@"^[^<&]"];
}

- (NSString *)scanCharacterData
{
  NSString *text = nil;
  [scanner scanUpToCharactersFromSet:OpalXMLSymbolCharacterSet intoString:&text];
  return text;
}

#pragma mark Whitespace
// ===== WHITESPACE ====================================================================================================

- (BOOL)isAtWhitespace
{
  return [self matchesRegex:OpalXMLWhitespacePattern];
}

- (NSString *)scanWhitespace
{
  return [self scanRegex:OpalXMLWhitespacePattern];
}

#pragma mark Comments
// ===== COMMENTS ======================================================================================================

- (BOOL)isAtComment
{
  return [self matchesRegex:OpalXMLCommentPattern];
}

- (NSString *)scanComment
{
  return [self scanRegex:OpalXMLCommentPattern capture:1];
}

#pragma mark Scan Helpers
// ===== SCAN HELPERS ==================================================================================================

- (BOOL)isAtName
{
  return [self matchesRegex:OpalXMLNamePattern];
}

- (NSString *)scanName
{
  return [self scanRegex:OpalXMLNamePattern];
}

- (BOOL)isAtEquals
{
  return [self matchesRegex:@"^\\s*=\\s*"];
}

- (NSString *)scanEquals
{
  return [self scanRegex:@"^\\s*=\\s*"];
}

- (BOOL)isAtString:(NSString *)matchString
{
  NSUInteger currLocation = [scanner scanLocation];
  BOOL result = [scanner scanString:matchString intoString:NULL];
  [scanner setScanLocation:currLocation];
  return result;
}

- (BOOL)matchesRegex:(NSString *)pattern
{
  return [[self xmlString] isMatchedByRegex:pattern inRange:[self scanRange]];
}

- (NSString *)scanRegex:(NSString *)pattern
{
  NSString *tagName = [[scanner string] stringByMatching:pattern inRange:[self scanRange]];
  if (tagName != nil && ![tagName isEqualToString:@""]) {
    [scanner setScanLocation:([self scanLocation] + [tagName length])];
    return tagName;
  } else {
    return nil;
  }
}

- (NSString *)scanRegex:(NSString *)pattern capture:(NSUInteger)capture
{
  NSString *match = [self scanRegex:pattern];
  if (match != nil && ![match isEqualToString:@""]) {
    NSString *component = [match stringByMatching:pattern
                        options:RKLNoOptions
                        inRange:NSMakeRange(0, [match length])
                        capture:capture
                        error:NULL];
    return component;
  } else {
    return nil;
  }
}

@end
