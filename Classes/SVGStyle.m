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
//	[propValueHistoryDict_ release], propValueHistoryDict_ = nil;
	[fillColor release], fillColor = nil;
	[strokeColor release], strokeColor = nil;
	[strokeDashArray release], strokeDashArray = nil;
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		// Setup history for all property values:
//		propValueHistoryDict_ = [NSMutableDictionary dictionary];
		
		// Set defaults as per SVG Spec
		self.opacity = 1.0;
		
		self.fillColor = [UIColor blackColor];
		self.fillRule = FillRuleNonZero;
		self.fillOpacity = 1.0f;

		self.strokeColor = [UIColor clearColor];
		self.strokeWidth = 1.0f;
		self.strokeLineCap = LineCapButt;
		self.strokeLineJoin = LineJoinMiter;
		self.strokeMiterLimit = 4.0f;
		self.strokeOpacity = 1.0f;
		self.strokeDashArray = nil;
	}
	return self;
}


//- (void) pushValue:(id) value forKey:(NSString *) key {
//	NSMutableArray *propHistory = [propValueHistoryDict_ valueForKey:key];
//	if (propHistory == nil) {
//		propHistory = [NSMutableArray array];
//		[propHistory addObject:value];
//		[propValueHistoryDict_ setObject:propHistory forKey:key];
//	} else {
//		[propHistory addObject:value];
//	}	
//	
//	[self setValue:value forKey:key];
//}
//
//- (id) popValueForKey:(NSString *) key {
//	id value;
//	NSMutableArray *propHistory = [propValueHistoryDict_ valueForKey:key];
//	if (propHistory == nil) {
//		value = [self valueForKey:key];
//	} else {
//		value = [propHistory lastObject];
//		[self setValue:value forKey:key];
//	}
//
//	return value;
//}

@end
