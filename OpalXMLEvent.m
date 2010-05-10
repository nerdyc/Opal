//
//  OpalXMLEvent.m
//  Opal
//
//  Created by Christian Niles on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpalXMLEvent.h"


@implementation OpalXMLEvent

@synthesize type;
@synthesize tagName;
@synthesize content;
@synthesize attributes;
@synthesize version;
@synthesize encoding;
@synthesize standalone;

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


@end