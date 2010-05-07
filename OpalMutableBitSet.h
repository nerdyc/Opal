//
//  OpalMutableBitSet.h
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OpalMutableBitSet : NSObject {
	NSMutableData *bits;
}

@property (readonly) NSMutableData *bits;

- (id)initWithLength:(NSUInteger)lengthInBits;
- (id)initWithData:(NSMutableData *)bitsData;

- (BOOL)bitAtIndex:(NSUInteger)index;
- (void)setBitAtIndex:(NSUInteger)index to:(BOOL)flag;
- (void)setBitsInRange:(NSRange)bitRange to:(BOOL)flag;

@end
