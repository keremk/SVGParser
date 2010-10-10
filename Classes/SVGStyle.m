//
//  SVGStyle.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-06.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGStyle.h"

@implementation SVGStyle
@synthesize 	opacity, fillColor, fillRule, fillOpacity, strokeColor, strokeWidth, 
				strokeMiterLimit, strokeOpacity, strokeLineJoin, strokeLineCap, strokeDashArray;

- (void) dealloc {
	[fillColor release], fillColor = nil;
	[strokeColor release], strokeColor = nil;
	[strokeDashArray release], strokeDashArray = nil;
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		// Set defaults as per SVG Spec
		self.opacity = 1.0;
		
		self.fillColor = [UIColor clearColor];
		self.fillRule = FillRuleNonZero;
		self.fillOpacity = 1.0f;

		self.strokeColor = [UIColor blackColor];
		self.strokeWidth = 1.0f;
		self.strokeLineCap = LineCapButt;
		self.strokeLineJoin = LineJoinMiter;
		self.strokeMiterLimit = 4.0f;
		self.strokeOpacity = 1.0f;
		self.strokeDashArray = nil;
		
	}
	return self;
}


@end
