//
//  SVGStyle.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-06.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGStyle.h"

@implementation SVGStyle
@synthesize 	fillColor, strokeColor, strokeWidth, strokeMiterLimit, strokeLineJoin, strokeLineCap;

- (void) dealloc {
	[fillColor release], fillColor = nil;
	[strokeColor release], strokeColor = nil;
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		self.fillColor = [UIColor clearColor];
		self.strokeColor = [UIColor blackColor];
	}
	return self;
}


@end
