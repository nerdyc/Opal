//
//  OpalXMLParser.h
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpalXMLEvent.h"

@class OpalXMLScanner;

@interface OpalXMLParser : NSObject {
	OpalXMLScanner *scanner;
	OpalXMLEvent *currentEvent;
	NSUInteger eventCount;
	NSUInteger elementCount;
	
	// used to buffer events as needed
	NSMutableArray *eventBuffer;
	
	// the stack is used to store start tags, keeping track of the current depth, namespaces, and validity
	NSMutableArray *stack;
}

// ===== INITIALIZATION ================================================================================================

- (id)initWithString:(NSString *)xmlstring;
+ (OpalXMLParser *)parserWithString:(NSString *)xmlString;

// ===== STATUS ========================================================================================================

@property (readonly) OpalXMLScanner *scanner;
@property (readonly) OpalXMLEvent *currentEvent;
@property (readonly) NSUInteger eventCount;
@property (readonly) NSUInteger elementCount;

- (BOOL)isInProlog;
- (BOOL)isInElement;

- (NSUInteger)characterPosition;
- (NSUInteger)currentDepth;

// ===== CORE ITERATION METHODS ========================================================================================

- (OpalXMLEvent *)nextEvent;
- (OpalXMLEvent *)nextEventOfType:(OpalXMLEventType)eventType;
- (BOOL)readNextEventInto:(OpalXMLEvent **)theNextEvent;

- (OpalXMLEvent *)peek;
- (OpalXMLEvent *)nextContentEvent;
- (OpalXMLEvent *)nextStartTag;
- (OpalXMLEvent *)skipElementContent;

// ===== CHARACTER DATA ================================================================================================

- (NSMutableString *)readElementText;

@end
