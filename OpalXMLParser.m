//
//  OpalXMLParser.m
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpalXMLParser.h"
#import "OpalXMLScanner.h"
#import "OpalXMLEvent.h"


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

- (OpalXMLEvent *)nextEvent
{
	NSString *tagName;
	NSDictionary *attributes;
	NSString *content;
	
	if ([scanner isAtStartTag]) {
		[scanner scanStartTagBeginToken];
		tagName = [scanner scanName];
		[scanner scanWhitespace];
		attributes = [scanner scanAttributes];
		[scanner scanWhitespace];
		[scanner scanTagEndToken];
		
		return [OpalXMLEvent startTagEventWithTagName:tagName andAttributes:attributes];
	} else if ([scanner isAtEndTag]) {
		[scanner scanEndTagBeginToken];
		tagName = [scanner scanName];
		[scanner scanWhitespace];
		[scanner scanTagEndToken];
		
		return [OpalXMLEvent endTagEventWithTagName:tagName];
	} else if ([scanner isAtCharacterData]) {
		content = [scanner scanCharacterData];
		return [OpalXMLEvent textEventWithContent:content];
	} else if ([scanner isAtXMLDeclaration]) {
		attributes = [scanner scanXMLDeclaration];
		NSString *encoding = [attributes objectForKey:@"encoding"];
		NSString *version = [attributes objectForKey:@"version"];
		NSString *standaloneValue = [attributes objectForKey:@"standalone"];
		BOOL standalone = YES;
		if (standaloneValue != nil) {
			standalone = [standaloneValue isEqualToString:@"yes"];
		}
		
		return [OpalXMLEvent startDocumentEventWithVersion:version encoding:encoding standalone:standalone];
	} else {
		return nil;
	}
}

- (NSUInteger)characterPosition
{
	return [scanner scanLocation];
}

//- (OpalXMLEventType)next
//{
//	if ([scanner isAtEnd]) {
//		return OPAL_END_DOCUMENT;
//	} else if ([scanner isAtStartTag]) {
//		[scanner scanStartTagBeginToken];
//		self.currentTagName = [scanner scanName];
//		[scanner scanTagEndToken];
//		
//		return OPAL_START_TAG;
//	} else if ([scanner isAtEndTag]) {
//		[scanner scanEndTagBeginToken];
//		self.currentTagName = [scanner scanName];
//		[scanner scanTagEndToken];
//		
//		return OPAL_END_TAG;
//	} else {
//		self.characterData = [scanner scanCharacterData];		
//		return OPAL_TEXT;
//	}
//}

@end
