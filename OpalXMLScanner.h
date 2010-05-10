//
//  OpalXMLScanner.h
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpalXMLScanner : NSObject {
	NSScanner *scanner;
}

// ===== INITIALIZATION ================================================================================================

- (id)initWithString:(NSString *)xmlString;
+ (OpalXMLScanner *)scannerWithString:(NSString *)xmlString;

// ===== LOCATION ======================================================================================================

- (NSUInteger)scanLocation;
- (NSRange)scanRange;
- (NSString *)xmlString;
- (NSUInteger)remainingChars;

- (BOOL)isAtEnd;

// ===== XML Declaration ===============================================================================================

- (BOOL)isAtXMLDeclaration;

// ===== START TAGS ====================================================================================================

- (BOOL)isAtStartTag;
- (BOOL)scanStartTagBeginToken;
- (BOOL)scanTagEndToken;

// ===== ATTRIBUTES ====================================================================================================

- (NSString *)scanQuotedValue;
- (NSString *)scanAttributeValue;
- (NSMutableDictionary *)scanAttributes;
- (BOOL)scanAttributeInto:(NSMutableDictionary *)dictionary;

// ===== END TAGS ======================================================================================================

- (BOOL)isAtEndTag;
- (BOOL)scanEndTagBeginToken;

// ===== REFERENCES ====================================================================================================

- (BOOL)isAtReference;
- (NSString *)scanReference;

- (BOOL)isAtCharacterReference;
- (NSString *)scanCharacterReference;

- (BOOL)isAtHexCharacterReference;
- (NSString *)scanHexCharacterReference;

- (BOOL)isAtDecimalCharacterReference;
- (NSString *)scanDecimalCharacterReference;

- (BOOL)isAtEntityReference;
- (NSString *)scanEntityReference;

+ (NSString *)stringFromUnicodeCharacter:(UInt32)unicodeCharacter;
+ (NSString *)unescapeValue:(NSString *)stringValue;
+ (NSString *)unescapeHexString:(NSString *)hexString;
+ (NSString *)unescapeDecimalString:(NSString *)decimalString;
+ (NSString *)translateEntityReference:(NSString *)entityRef;

// ===== CHARACTER DATA ================================================================================================

- (NSString *)scanCharacterData;

// ===== WHITESPACE ====================================================================================================

- (BOOL)isAtWhitespace;
- (NSString *)scanWhitespace;

// ===== COMMENTS ======================================================================================================

- (BOOL)isAtComment;
- (NSString *)scanComment;

// ===== SCAN HELPERS ==================================================================================================

- (BOOL)isAtString:(NSString *)matchString;
- (BOOL)matchesRegex:(NSString *)pattern;

- (BOOL)isAtName;
- (NSString *)scanName;

- (BOOL)isAtEquals;
- (NSString *)scanEquals;

- (NSString *)scanRegex:(NSString *)regex;
- (NSString *)scanRegex:(NSString *)regex capture:(NSUInteger)capture;

@end
