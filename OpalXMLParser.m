//
//  OpalXMLParser.m
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import "OpalXMLParser.h"
#import "OpalXMLScanner.h"
#import "OpalXMLEvent.h"

@interface OpalXMLParser ()

- (OpalXMLEvent *)consumeNextEvent;
- (OpalXMLEvent *)readNextEvent;

@end

@implementation OpalXMLParser

// ===== INIT / DEALLOC ================================================================================================

+ (OpalXMLParser *)parserWithString:(NSString *)xmlString
{
	return [[[OpalXMLParser alloc] initWithString:xmlString] autorelease];
}

- (id)initWithString:(NSString *)xmlString
{
	if (self = [super init]) {
		eventCount = 0;
		elementCount = 0;
		currentEvent = nil;
		eventBuffer = [[NSMutableArray alloc] initWithCapacity:4];
		stack = [[NSMutableArray alloc] initWithCapacity:8];
		scanner = [[OpalXMLScanner scannerWithString:xmlString] retain];
	}
	return self;
}

- (void)dealloc
{
	[eventBuffer release];
	[stack release];
	[scanner release];
	[currentEvent release];
	[super dealloc];
}

// ===== SCANNER =======================================================================================================

@synthesize scanner;
@synthesize eventCount;
@synthesize elementCount;

- (BOOL)isInProlog
{
	return elementCount == 0;
}

- (BOOL)isInElement
{
	return [stack count] > 1;
}

- (NSUInteger)characterPosition
{
	return [scanner scanLocation];
}

// ===== CURRENT EVENT =================================================================================================

@synthesize currentEvent;

- (NSUInteger)currentDepth
{
	return [stack count];
}

// ===== NEXT EVENT ====================================================================================================

- (OpalXMLEvent *)nextEvent
{
	// return nil after we have seen the end of the document
	if (currentEvent && [currentEvent isEndDocument]) return nil;
	
	// consume the next event
	OpalXMLEvent *theNextEvent = [self consumeNextEvent];
	
	// skip whitespace outside of the document element
	if (![self isInElement]) {
		while (theNextEvent != nil && [theNextEvent isWhitespace]) {
			theNextEvent = [self consumeNextEvent];
		}
	}
	
	if (theNextEvent == nil) {
		theNextEvent = [OpalXMLEvent endDocumentEvent];
		// FIXME: theNextEvent should only be nil when an unparsable document is encountered. Riase error?
	}
	
	// insert a default start document event when an XML declaration isn't found
	if (eventCount == 0 && ![theNextEvent isStartDocument]) {
		[eventBuffer addObject:theNextEvent];
		theNextEvent = [OpalXMLEvent startDocumentEvent];
	}
	
	// clear the current event
	[currentEvent release];
	currentEvent = [theNextEvent retain];
	
	if ([theNextEvent isStartTag]) {
		elementCount += 1;
		[stack addObject:currentEvent];
		
		// VALIDATION: What if multiple roots exist in the document?
	} else if ([theNextEvent isEndTag]) {
		OpalXMLEvent *startTag = [stack lastObject];
		if (startTag != nil && [startTag isStartTag]) {
			[stack removeLastObject];
			// VALIDATION: Does end tag match start tag?
		} else {
			// VALIDATION: Unmatched end tag?
		}
	} else if ([theNextEvent isEndDocument]) {
		// pop start document off of stack
		OpalXMLEvent *startDocument = [stack lastObject];
		if (startDocument != nil && [startDocument isStartDocument]) {
			[stack removeLastObject];
		} else {
			// VALIDATION: Unmatched start tag?
		}
	} else if ([theNextEvent isStartDocument]) {
		// add it to the stack
		if ([stack count] == 0) {
			[stack addObject:currentEvent];
		} else {
			// VALIDATION: XML Declaration inside document?
		}			
	}
	
	eventCount += 1;
	return currentEvent;
}

- (OpalXMLEvent *)peek
{
	// return nil after we have seen the end of the document
	if (currentEvent && [currentEvent isEndDocument]) return nil;
	
	OpalXMLEvent *peekedEvent = nil;
	if ([eventBuffer count] > 0) {
		peekedEvent = [eventBuffer objectAtIndex:0];
	} else {
		peekedEvent = [self readNextEvent];
		if (peekedEvent != nil) {
			[eventBuffer addObject:peekedEvent];
		}
	}

	return peekedEvent;
}
			
- (OpalXMLEvent *)consumeNextEvent
{
	if ([eventBuffer count] != 0) {
		OpalXMLEvent *e = [eventBuffer objectAtIndex:0];
		[eventBuffer removeObjectAtIndex:0];
		return e;
	} else {
		return [self readNextEvent];
	}
}

- (OpalXMLEvent *)readNextEvent
{
	OpalXMLEvent *nextEvent = nil;
	[self readNextEventInto:&nextEvent];
	return nextEvent;
}

- (BOOL)readNextEventInto:(OpalXMLEvent **)theNextEvent
{
	NSString *tagName;
	NSDictionary *attributes;
	
	if ([scanner isAtEnd]) {
		if (theNextEvent != NULL) {
			*theNextEvent = [OpalXMLEvent endDocumentEvent];
		}
	} else if ([scanner isAtStartTag]) {
		[scanner scanStartTagBeginToken];
		tagName = [scanner scanName];
		[scanner scanWhitespace];
		attributes = [scanner scanAttributes];
		[scanner scanWhitespace];
		[scanner scanTagEndToken];
		
		if (theNextEvent != NULL) {
			*theNextEvent = [OpalXMLEvent startTagEventWithTagName:tagName andAttributes:attributes];
		}
	} else if ([scanner isAtEndTag]) {
		[scanner scanEndTagBeginToken];
		tagName = [scanner scanName];
		[scanner scanWhitespace];
		[scanner scanTagEndToken];
		
		if (theNextEvent != NULL) {
			*theNextEvent = [OpalXMLEvent endTagEventWithTagName:tagName];
		}
	} else if ([scanner isAtText]) {
		NSString *content = [scanner scanText];
		if (theNextEvent != NULL) {
			*theNextEvent = [OpalXMLEvent textEventWithContent:content];
		}
	} else if ([scanner isAtComment]) {
		NSString *comment = [scanner scanComment];
		if (theNextEvent != NULL) {
			*theNextEvent = [OpalXMLEvent commentEventWithContent:comment];
		}
	} else if ([scanner isAtXMLDeclaration]) {
		attributes = [scanner scanXMLDeclaration];
		if (theNextEvent != NULL) {
			NSString *encoding = [attributes objectForKey:@"encoding"];
			NSString *version = [attributes objectForKey:@"version"];
			NSString *standaloneValue = [attributes objectForKey:@"standalone"];
			BOOL standalone = YES;
			if (standaloneValue != nil) {
				standalone = [standaloneValue isEqualToString:@"yes"];
			}
			
			*theNextEvent = [OpalXMLEvent startDocumentEventWithVersion:version encoding:encoding standalone:standalone];
		}
	} else {
		return NO;
	}
	
	return YES;
}

- (OpalXMLEvent *)nextEventOfType:(OpalXMLEventType)eventType
{
	OpalXMLEvent *nextEvent;
	do {
		nextEvent = [self nextEvent];
	} while (nextEvent != nil && nextEvent.type != eventType);
	
	return nextEvent;
}

// ===== TAGS ==========================================================================================================

- (OpalXMLEvent *)nextStartTag
{
	return [self nextEventOfType:OPAL_START_TAG_EVENT];
}
- (OpalXMLEvent *)skipElementContent
{
	if ([self isInElement]) {
		NSUInteger startDepth = [self currentDepth];
		do {
			[self nextEvent];
		} while ([self currentDepth] >= startDepth);
		return currentEvent;
	} else {
		return nil;
	}
}

// ===== CHARACTER DATA ================================================================================================

- (OpalXMLEvent *)nextContentEvent
{
	do { [self nextEvent]; } while (![currentEvent isContent]);
	
	return currentEvent;
}

- (NSMutableString *)readElementText
{
	if (![self isInElement]) return nil;
	
	NSMutableString *elementText = [NSMutableString stringWithCapacity:0];
	
	NSUInteger startDepth = self.currentDepth;
	OpalXMLEvent *event;
	do {
		event = [self nextEvent];
		if ([event isText]) [elementText appendString:[event content]];
	} while (self.currentDepth >= startDepth);
	
	return elementText;
}


@end
