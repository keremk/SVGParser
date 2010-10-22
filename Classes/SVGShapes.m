//
//  SVGShapes.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-05.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGShapes.h"

@implementation SVGPathElement 
@synthesize elementType, initialPoint, toPoint, controlPoint1, controlPoint2, 
			radiusX, radiusY, xAxisRotation, largeArcFlag, sweepFlag;	

@end

@implementation SVGStyleHelper

+ (void) setContext:(CGContextRef) context usingStyle:(NSDictionary *) style {
	
	NSString *fillColorValue = [style objectForKey:@"fill"];
	if (nil != fillColorValue) {
		UIColor *color = [SVGStyleHelper parseColorFromString:fillColorValue];
		CGContextSetFillColorWithColor(context, [color CGColor]);
	}
	NSString *strokeColorValue = [style objectForKey:@"stroke"];
	if (nil != strokeColorValue) {
		UIColor *color = [SVGStyleHelper parseColorFromString:strokeColorValue];
		CGContextSetStrokeColorWithColor(context, [color CGColor]);
	}
	NSString *strokeMiterLimitValue = [style objectForKey:@"stroke-miterlimit"];
	if (nil != strokeMiterLimitValue) {
		CGContextSetMiterLimit(context, [strokeMiterLimitValue floatValue]);
	}
	NSString *strokeWidthValue = [style objectForKey:@"stroke-width"];
	if (nil != strokeWidthValue) {
		CGContextSetLineWidth(context, [strokeWidthValue floatValue]);
	}
	
	NSString *strokeOpacityValue = [style objectForKey:@"opacity"];
	if (nil != strokeOpacityValue) {
		CGContextSetAlpha(context, [strokeOpacityValue floatValue]);		
	}
	
	NSString *strokeLineJoinValue = [style objectForKey:@"stroke-linejoin"];
	if (nil != strokeLineJoinValue) {
		if ([strokeLineJoinValue isEqualToString:@"miter"]) {
			CGContextSetLineJoin(context, kCGLineJoinMiter);
		} else if ([strokeLineJoinValue isEqualToString:@"round"]) {
			CGContextSetLineJoin(context, kCGLineJoinRound);
		} else if ([strokeLineJoinValue isEqualToString:@"bevel"]) {
			CGContextSetLineJoin(context, kCGLineJoinBevel);
		}
	}
	
	NSString *strokeLineCapValue = [style objectForKey:@"stroke-linecap"];
	if (nil != strokeLineCapValue) {
		if ([strokeLineCapValue isEqualToString:@"butt"]) {
			CGContextSetLineCap(context, kCGLineCapButt);
		} else if ([strokeLineCapValue isEqualToString:@"round"]) {
			CGContextSetLineCap(context, kCGLineCapRound);
		} else if ([strokeLineCapValue isEqualToString:@"square"]) {
			CGContextSetLineCap(context, kCGLineCapSquare);
		}
	}
}


+ (UIColor *) parseColorFromString:(NSString *) colorValue {
	UIColor *color;
	NSScanner *scanner = [NSScanner scannerWithString:colorValue];
	if ([scanner scanString:@"none" intoString:NULL]) {
		color = [UIColor clearColor];
	} else {
		color = [UIColor colorWithName:colorValue];
		if (color == nil) {
			color = [UIColor colorWithHexString:colorValue];
		}
	}
	return color;
}

@end

