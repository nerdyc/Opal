//
//  OpalXMLScanner.m
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpalXMLScanner.h"
#import "OpalMutableBitSet.h"
#import "RegexKitLite.h"

// ===== CONSTANTS =====================================================================================================

NSString *OpalStartTagBeginToken = @"<";
NSString *OpalEndTagBeginToken = @"</";
NSString *OpalTagEndToken = @">";

NSString *OpalXMLNameStartCharsPattern = @"[:a-z_A-Z\\xC0-\\xD6\\xD8-\\xF6\\xF8-\\x{2FF}\\x{370}-\\x{37D}\\x{37F}-\\x{1FFF}\\x{200C}-\\x{200D}\\x{2070}-\\x{218F}\\x{2C00}-\\x{2FEF}\\x{3001}-\\x{D7FF}\\x{F900}-\\x{FDCF}\\x{FDF0}-\\x{FFFD}\\U00010000-\\U000EFFFF]";
NSString *OpalXMLNameCharsPattern = @"[:a-z_A-Z\\xC0-\\xD6\\xD8-\\xF6\\xF8-\\x{2FF}\\x{370}-\\x{37D}\\x{37F}-\\x{1FFF}\\x{200C}-\\x{200D}\\x{2070}-\\x{218F}\\x{2C00}-\\x{2FEF}\\x{3001}-\\x{D7FF}\\x{F900}-\\x{FDCF}\\x{FDF0}-\\x{FFFD}\\U00010000-\\U000EFFFF\\.\\-0-9\\xB7\\x{0300}-\\x{036F}\\x{203F}-\\x{2040}]";
NSString *OpalXMLNamePattern = nil;
NSString *OpalXMLDecimalCharacterReferencePattern = @"^&#0*([0-9]+);";
NSString *OpalXMLHexCharacterReferencePattern = @"^&#x0*([0-9a-fA-F]+);";
NSString *OpalXMLEntityReferencePattern = nil;

NSDictionary *OpalXMLDefaultEntities = nil;
NSCharacterSet *OpalXMLSymbolCharacterSet = nil;

NSString *OpalCommentBeginToken = @"<!--";
NSString *OpalCommentEndToken = @"-->";
NSString *OpalXMLCommentPattern = @"<!--([\\x09\\x0A\\x0D\\x20-\\x{D7FF}\\x{E000}-\\x{FFFD}\\U00010000-\\U0010FFFF]*?)-->";

@implementation OpalXMLScanner

#pragma mark Initialization
// ===== INITIALIZATION ================================================================================================

+(void)initialize
{
	OpalXMLNamePattern = [[NSString alloc] initWithFormat:@"^%@%@*", OpalXMLNameStartCharsPattern, OpalXMLNameCharsPattern, nil];
	OpalXMLEntityReferencePattern = [[NSString alloc] initWithFormat:@"^&(%@%@*);", OpalXMLNameStartCharsPattern, OpalXMLNameCharsPattern, nil];
	OpalXMLSymbolCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"<&"] retain];
	
	OpalXMLDefaultEntities = [[NSDictionary dictionaryWithObjectsAndKeys:@"<", @"lt", @">", @"gt", @"&", @"amp", @"'", @"apos", @"\"", @"quot", nil] retain];
}

- (id)initWithString:(NSString *)xmlString
{
	if (self = [super init]) {
		scanner = [[NSScanner alloc] initWithString:xmlString];
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

#pragma mark Start Tag
// ===== START TAG =====================================================================================================

-(BOOL)isAtStartTag
{
	return [self isAtString:OpalStartTagBeginToken] && ![self isAtString:OpalEndTagBeginToken];
}

- (BOOL)scanStartTagBeginToken
{
	return [scanner scanString:OpalStartTagBeginToken intoString:NULL];
}

#pragma mark End Tag
// ===== START TAG =====================================================================================================

- (BOOL)isAtEndTag
{
	return [self isAtString:OpalEndTagBeginToken];
}

- (BOOL)scanEndTagBeginToken
{
	return [scanner scanString:OpalEndTagBeginToken intoString:NULL];
}

- (NSString *)scanTagName
{
	return [self scanRegex:OpalXMLNamePattern];
}


- (BOOL)scanTagEndToken
{
	return [scanner scanString:OpalTagEndToken intoString:NULL];
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

- (BOOL)isAtDecimalCharacterReference
{
	return [[self xmlString] isMatchedByRegex:OpalXMLDecimalCharacterReferencePattern inRange:[self scanRange]];
}

- (NSString *)scanDecimalCharacterReference
{
	NSString *decimalString = [self scanRegex:OpalXMLDecimalCharacterReferencePattern capture:1];
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
	return nil;
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

#pragma mark Entity References
// ----- ENTITY REFERENCES ---------------------------------------------------------------------------------------------

- (BOOL)isAtEntityReference
{
	return [[self xmlString] isMatchedByRegex:OpalXMLEntityReferencePattern inRange:[self scanRange]];
}

- (NSString *)scanEntityReference
{
	NSString *entityRef = [self scanRegex:OpalXMLEntityReferencePattern capture:1];
	NSString *value = [OpalXMLDefaultEntities objectForKey:entityRef];
	return value;
}

#pragma mark Character Data
// ===== CHARACTER DATA ================================================================================================

- (NSString *)scanCharacterData
{
	NSMutableString *scannedText = [[NSMutableString alloc] initWithString:@""];
	while (![self isAtEnd] && ![self isAtStartTag] && ![self isAtEndTag]) {
		NSString *text = [self scanReference];
		if (text == nil) {
			[scanner scanUpToCharactersFromSet:OpalXMLSymbolCharacterSet intoString:&scannedText];
		}
		
		// append the result
		if (text == nil || [text isEqualToString:@""]) {
			break;
		} else {
			[scannedText appendString:text];
		}
	}
	
	return [scannedText autorelease];
}

#pragma mark Comments
// ===== COMMENTS ======================================================================================================

- (BOOL)isAtComment
{
	return [self isAtString:OpalCommentBeginToken];
}

- (NSString *)scanComment
{
	return [self scanRegex:OpalXMLCommentPattern capture:1];
}

#pragma mark Scan Helpers
// ===== SCAN HELPERS ==================================================================================================

- (BOOL)isAtString:(NSString *)matchString
{
	NSUInteger currLocation = [scanner scanLocation];
	BOOL result = [scanner scanString:matchString intoString:NULL];
	[scanner setScanLocation:currLocation];
	return result;
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
