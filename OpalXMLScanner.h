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

- (id)initWithString:(NSString *)xmlString;
+ (OpalXMLScanner *)scannerWithString:(NSString *)xmlString;

- (NSUInteger)scanLocation;
- (NSRange)scanRange;
- (NSString *)xmlString;
- (NSUInteger)remainingChars;

- (BOOL)isAtEnd;

- (BOOL)isAtString:(NSString *)matchString;
- (BOOL)isAtStartTag;
- (BOOL)isAtEndTag;
- (BOOL)isAtReference;
- (BOOL)isAtCharacterReference;
- (BOOL)isAtHexCharacterReference;
- (BOOL)isAtDecimalCharacterReference;
- (BOOL)isAtEntityReference;


- (BOOL)scanStartTagBeginToken;
- (BOOL)scanEndTagBeginToken;
- (BOOL)scanTagEndToken;

- (NSString *)scanCharacterData;
- (NSString *)scanReference;
- (NSString *)scanCharacterReference;
- (NSString *)scanHexCharacterReference;
- (NSString *)scanDecimalCharacterReference;
- (NSString *)scanEntityReference;
- (NSString *)scanTagName;

- (NSString *)scanRegex:(NSString *)regex;
- (NSString *)scanRegex:(NSString *)regex capture:(NSUInteger)capture;

+ (NSString *)stringFromUnicodeCharacter:(UInt32)unicodeCharacter;

@end
