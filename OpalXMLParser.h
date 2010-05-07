//
//  OpalXMLParser.h
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OpalXMLScanner;

enum OpalXMLTokenType {
  OPAL_START_DOCUMENT = 1,
  OPAL_END_DOCUMENT,
  OPAL_START_TAG,
  OPAL_END_TAG,
  OPAL_TEXT
};
typedef enum OpalXMLTokenType OpalXMLTokenType;

@interface OpalXMLParser : NSObject {
  OpalXMLScanner *scanner;
  NSString *currentTagName;
  NSString *characterData;
}

- (id)initWithString:(NSString *)xmlstring;

- (NSUInteger)position;
- (OpalXMLTokenType)next;

@property (copy) NSString *currentTagName;
@property (copy) NSString *characterData;

@end
