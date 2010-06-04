//
//  OpalXMLResourceParser.h
//  Opal
//
//  Created by Christian Niles on 5/22/10.
//  Copyright 2010 Christian Niles. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OpalXMLParser;

@interface OpalXMLResourceParser : NSObject {

}
+ (NSDictionary *)parseResourceFromString:(NSString *)resourceXML;
+ (NSDictionary *)parseResource:(OpalXMLParser *)parser;

+ (id)parseResourceValue:(OpalXMLParser *)parser;
+ (NSNumber *)parseIntegerValue:(OpalXMLParser *)parser;
+ (NSMutableArray *)parseArrayValue:(OpalXMLParser *)parser;
+ (NSDate *)parseDateValue:(OpalXMLParser *)parser;

+ (id)parseUntypedValue:(OpalXMLParser *)parser;

@end
