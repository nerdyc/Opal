//
//  OpalXMLParser.m
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpalXMLParser.h"
#import "OpalXMLScanner.h"


@implementation OpalXMLParser

- (id)initWithString:(NSString *)xmlString
{
	if (self = [super init]) {
		scanner = [[OpalXMLScanner scannerWithString:xmlString] retain];
	}
	return self;
}

- (void)dealloc
{
	[scanner release];
	[super dealloc];
}

- (OpalXMLTokenType)next
{
	if ([scanner isAtEnd]) {
		return OPAL_END_DOCUMENT;
	} else if ([scanner isAtStartTag]) {
		[scanner scanStartTagBeginToken];
		self.currentTagName = [scanner scanTagName];
		[scanner scanTagEndToken];
		
		return OPAL_START_TAG;
	} else if ([scanner isAtEndTag]) {
		[scanner scanEndTagBeginToken];
		self.currentTagName = [scanner scanTagName];
		[scanner scanTagEndToken];
		
		return OPAL_END_TAG;
	} else {
		self.characterData = [scanner scanCharacterData];		
		return OPAL_TEXT;
	}
}

- (NSUInteger)position
{
	return [scanner scanLocation];
}

// ===== TAG NAME (start tag, end tag) =========================================

@synthesize currentTagName;
@synthesize characterData;

@end
