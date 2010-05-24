//
//  OpalXMLResourceParser.m
//  Opal
//
//  Created by Christian Niles on 5/22/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import "OpalXMLResourceParser.h"
#import "OpalXMLScanner.h"
#import "OpalXMLParser.h"
#import "OpalXMLEvent.h"
#import "RegexKitLite.h"

@implementation OpalXMLResourceParser

+ (NSDictionary *)parseResourceFromString:(NSString *)resourceXML
{
	OpalXMLParser *parser = [OpalXMLParser parserWithString:resourceXML];
	return [self parseResource:parser];
}

+ (NSDictionary *)parseResource:(OpalXMLParser *)parser
{
	OpalXMLEvent *event = [parser nextStartTag];
	if (event != nil) {
		id value = [self parseResourceValue:parser];
		return [NSDictionary dictionaryWithObject:value forKey:event.tagName];
	} else {
		return [NSDictionary dictionary];
	}
}

+ (id)parseResourceValue:(OpalXMLParser *)parser
{
	OpalXMLEvent *startTag = [parser currentEvent];
	if (![startTag isStartTag]) return [NSNull null];
	
	id value = [NSNull null];
	NSString *type = [startTag valueForAttribute:@"type"];
	if (type && [type caseInsensitiveCompare:@"integer"] == NSOrderedSame) {
		value = [self parseIntegerValue:parser];
	} else if (type && [type caseInsensitiveCompare:@"array"] == NSOrderedSame) {
		value = [self parseArrayValue:parser];
	} else {
		value = [self parseUntypedValue:parser];
	}
	
	if (value == nil) value = [NSNull null];
	return value;
}

+ (NSNumber *)parseIntegerValue:(OpalXMLParser *)parser
{
	// get the start tag's text value, then convert it to an integer
	NSMutableString *content = [parser readElementText];
	NSString *numberText = [content stringByMatching:@"\\d+"];
	if (numberText) {
		long long integer = [numberText longLongValue];
		return [NSNumber numberWithLongLong:integer];
	} else {
		return nil;
	}
}

+ (NSMutableArray *)parseArrayValue:(OpalXMLParser *)parser
{
	// parse each item into an array
	NSMutableArray *arrayContent = [NSMutableArray arrayWithCapacity:1];
	OpalXMLEvent *item;
	do {
		item = [parser nextContentEvent];
		if ([item isStartTag]) {
			[arrayContent addObject:[self parseResourceValue:parser]];
		}
	} while (![item isEndTag]);
	return arrayContent;	
}


+ (id)parseUntypedValue:(OpalXMLParser *)parser
{
	// examine the content, look for simple or complex content
	OpalXMLEvent *contentEvent = [parser nextContentEvent];
	if ([contentEvent isEndTag]) {
		return nil;
	} else if ([contentEvent isText]) {
		NSString *simpleContent;
		if ([[parser peek] isEndTag]) {
			simpleContent = [contentEvent content];
			[parser nextEvent];
		} else {
			// multiple values?
			NSMutableString *mutableContent = [parser readElementText];
			[mutableContent insertString:[contentEvent content] atIndex:0];
			simpleContent = mutableContent;
		}
		return [simpleContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	} else {
		// start tag
		NSMutableDictionary *complexContent = [NSMutableDictionary dictionaryWithCapacity:1];
		do {
			NSString *fieldName = [contentEvent tagName];
			id fieldValue = [self parseResourceValue:parser];
			
			id existingValue = [complexContent objectForKey:fieldName];
			if (existingValue == nil) {
				// this is the first value, so create the key
				[complexContent setObject:fieldValue forKey:[contentEvent tagName]];
			} else if ([existingValue isKindOfClass:[NSMutableArray class]]) {
				// this is the 3+ value, so append to the existing array
				[existingValue addObject:fieldValue];
			} else {
				// this is the second value, so create an array
				NSMutableArray *multipleValues = [NSMutableArray arrayWithCapacity:2];
				[multipleValues addObject:existingValue];
				[multipleValues addObject:fieldValue];
				[complexContent setObject:multipleValues forKey:fieldName];
			}
			contentEvent = [parser nextContentEvent];
		} while (![contentEvent isEndTag]);
		return complexContent;
	}
}

@end
