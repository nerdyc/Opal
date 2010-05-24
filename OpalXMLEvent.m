//
//  OpalXMLEvent.m
//  Opal
//
//  Created by Christian Niles on 5/8/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import "OpalXMLEvent.h"
#import "RegexKitLite.h"

@implementation OpalXMLEvent

@synthesize type;
@synthesize tagName;
@synthesize content;
@synthesize attributes;
@synthesize version;
@synthesize encoding;
@synthesize standalone;

- (void)dealloc
{
	[tagName release];
	[content release];
	[attributes release];
	[version release];
	[encoding release];
	[super dealloc];
}

- (BOOL)isContent
{
	switch (self.type) {
		case OPAL_TEXT_EVENT:
			if ([self isWhitespace]) return NO;
		case OPAL_START_TAG_EVENT:
		case OPAL_END_TAG_EVENT:
			return YES;
		default:
			return NO;
	}
}

// ===== START DOCUMENT ================================================================================================

+ (OpalXMLEvent *)startDocumentEvent
{
	return [[[self alloc] initStartDocumentEvent] autorelease];
}

+ (OpalXMLEvent *)startDocumentEventWithEncoding:(NSString *)encoding
{
	return [[[self alloc] initStartDocumentEventWithEncoding:encoding] autorelease];
}

+ (OpalXMLEvent *)startDocumentEventWithVersion:(NSString *)version encoding:(NSString *)encoding standalone:(BOOL)standalone
{
	return [[[self alloc] initStartDocumentEventWithVersion:version encoding:encoding standalone:standalone] autorelease];	
}

- (id)initStartDocumentEvent
{
	return [self initStartDocumentEventWithVersion:@"1.0" encoding:nil standalone:YES];
}

- (id)initStartDocumentEventWithEncoding:(NSString *)xmlEncoding
{
	return [self initStartDocumentEventWithVersion:@"1.0" encoding:xmlEncoding standalone:YES];
}

- (id)initStartDocumentEventWithVersion:(NSString *)xmlVersion encoding:(NSString *)xmlEncoding standalone:(BOOL)isStandalone
{
	if (self = [super init]) {
		type = OPAL_START_DOCUMENT_EVENT;
		version = xmlVersion;
		encoding = xmlEncoding;
		standalone = isStandalone;
	}
	return self;
}

- (BOOL)isStartDocument
{
	return self.type == OPAL_START_DOCUMENT_EVENT;
}

// ===== END DOCUMENT ==================================================================================================

+ (OpalXMLEvent *)endDocumentEvent
{
	return [[[self alloc] initEndDocumentEvent] autorelease];
}

- (id)initEndDocumentEvent
{
	if (self = [super init]) {
		type = OPAL_END_DOCUMENT_EVENT;
	}
	return self;
}

- (BOOL)isEndDocument
{
	return self.type == OPAL_END_DOCUMENT_EVENT;
}

// ===== START TAG =====================================================================================================

+ (OpalXMLEvent *)startTagEventWithTagName:(NSString *)tagName andAttributes:(NSDictionary *)attributes
{
	return [[[self alloc] initStartTagEventWithTagName:tagName andAttributes:attributes] autorelease];
}

- (id)initStartTagEventWithTagName:(NSString *)startTagName andAttributes:(NSDictionary *)tagAttributes
{
	if (self = [super init]) {
		type = OPAL_START_TAG_EVENT;
		tagName = [startTagName copy];
		attributes = [tagAttributes copy];
	}
	return self;
}

- (BOOL)isStartTag
{
	return self.type == OPAL_START_TAG_EVENT;
}

- (NSString *)valueForAttribute:(NSString *)attributeName
{
	if (attributes) {
		return [attributes objectForKey:attributeName];
	} else {
		return nil;
	}
}

// ===== END TAG =======================================================================================================

+ (OpalXMLEvent *)endTagEventWithTagName:(NSString *)endTagName
{
	return [[[self alloc] initEndTagEventWithTagName:endTagName] autorelease];
}

- (id)initEndTagEventWithTagName:(NSString *)endTagName
{
	if (self = [super init]) {
		type = OPAL_END_TAG_EVENT;
		tagName = [endTagName copy];
	}
	return self;
}

- (BOOL)isEndTag
{
	return self.type == OPAL_END_TAG_EVENT;
}

// ===== TEXT ==========================================================================================================

+ (OpalXMLEvent *)textEventWithContent:(NSString *)textContent
{
	return [[[OpalXMLEvent alloc] initTextEventWithContent:textContent] autorelease];
}

- (id)initTextEventWithContent:(NSString *)textContent
{
	if (self = [super init]) {
		type = OPAL_TEXT_EVENT;
		content = [textContent copy];
	}
	return self;
}

- (BOOL)isText
{
	return self.type == OPAL_TEXT_EVENT;
}

- (BOOL)isWhitespace
{
	return [self isText] && [content isMatchedByRegex:@"^[\\x09\\x0A\\x0D\\x20]*$"];
}

// ===== COMMENTS ======================================================================================================

+ (OpalXMLEvent *)commentEventWithContent:(NSString *)comment
{
	return [[[OpalXMLEvent alloc] initCommentEventWithContent:comment] autorelease];	
}

- (id)initCommentEventWithContent:(NSString *)comment
{
	if (self = [super init]) {
		type = OPAL_COMMENT_EVENT;
		content = [comment copy];
	}
	return self;
}

- (BOOL)isComment
{
	return self.type == OPAL_COMMENT_EVENT;
}


@end
