//
//  OpalXMLScanner.h
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

// ===== START TAGS ====================================================================================================

- (BOOL)isAtStartTag;
- (BOOL)scanStartTagBeginToken;
- (NSString *)scanTagName;
- (BOOL)scanTagEndToken;

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

// ===== CHARACTER DATA ================================================================================================

- (NSString *)scanCharacterData;

// ===== COMMENTS ======================================================================================================

- (BOOL)isAtComment;
- (NSString *)scanComment;

// ===== SCAN HELPERS ==================================================================================================

- (BOOL)isAtString:(NSString *)matchString;

- (NSString *)scanRegex:(NSString *)regex;
- (NSString *)scanRegex:(NSString *)regex capture:(NSUInteger)capture;

@end
