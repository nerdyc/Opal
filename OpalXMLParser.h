//
//  OpalXMLParser.h
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OpalXMLScanner;
@class OpalXMLEvent;

@interface OpalXMLParser : NSObject {
	OpalXMLScanner *scanner;
}

- (id)initWithString:(NSString *)xmlstring;
- (NSUInteger)characterPosition;
- (OpalXMLEvent *)nextEvent;

@end
