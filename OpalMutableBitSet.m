//
//  OpalBitSet.m
//  Opal
//
//  Created by Christian Niles on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OpalMutableBitSet.h"

@implementation OpalMutableBitSet

- (id)initWithLength:(NSUInteger)lengthInBits
{
	NSMutableData *emptyBits = [[[NSMutableData alloc] initWithLength:(lengthInBits / 8)] autorelease];
	return [self initWithData:emptyBits];
}
- (id)initWithData:(NSMutableData *)bitsData
{
	if (self = [super init]) {
		bits = [bitsData retain];
	}
	return self;
}

- (void)dealloc
{
	[bits release];
	[super dealloc];
}

@synthesize bits;

- (BOOL)bitAtIndex:(NSUInteger)index
{
	NSUInteger byteIndex = index / 8;
	NSUInteger bitIndex = index % 8;
	unsigned char byte = ((unsigned char *)[bits mutableBytes])[byteIndex];
	unsigned char bitMask = (1 << bitIndex);
	
	return (byte & bitMask ? YES : NO);
}

- (void)setBitAtIndex:(NSUInteger)index
				   to:(BOOL)bitFlag
{
	NSUInteger byteIndex = index / 8;
	NSUInteger bitIndex = index % 8;
	unsigned char *bytes = [bits mutableBytes];
	unsigned char byte = bytes[byteIndex];
	unsigned char bitMask = (1 << bitIndex);
	
	if (bitFlag) {
		// OR the byte to set it
		byte = byte | bitMask;
	} else if (byte & bitMask != 0) {
		// the bit is set, and needs to be unset
		byte = byte & (255 ^ bitMask);
	} // else the bit is already set to the right value
	
	bytes[byteIndex] = byte;
}

- (void)setBitsInRange:(NSRange)bitRange to:(BOOL)flag
{
	for (NSUInteger i = 0; i < bitRange.length; i++) {
		[self setBitAtIndex:(bitRange.location+i) to:flag];
	}
}


@end
