//
//  SVGStyle.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-06.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

typedef enum SVGStrokeLineJoin {
	LineJoinMiter, 
	LineJoinRound,
	LineJoinBevel
} SVGStrokeLineJoin;

typedef enum SVGStrokeLineCap {
	LineCapButt,
	LineCapRound,
	LineCapSquare
} SVGStrokeLineCap;

typedef enum SVGFillRule {
	FillRuleNonZero,
	FillRuleEvenOdd
} SVGFillRule;

@interface SVGStyle : NSObject {
	UIColor *fillColor;
	SVGFillRule fillRule;
	CGFloat fillOpacity;
	
	UIColor *strokeColor;
	CGFloat strokeWidth;
	CGFloat strokeMiterLimit; 
	CGFloat strokeOpacity;
	SVGStrokeLineJoin strokeLineJoin;
	SVGStrokeLineCap strokeLineCap;
	NSArray *strokeDashArray;

	CGFloat opacity;
}

@property (nonatomic) CGFloat opacity;
@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic) SVGFillRule fillRule;
@property (nonatomic) CGFloat fillOpacity;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) CGFloat strokeMiterLimit;
@property (nonatomic) CGFloat strokeOpacity;
@property (nonatomic) SVGStrokeLineCap strokeLineCap;
@property (nonatomic) SVGStrokeLineJoin strokeLineJoin;
@property (nonatomic, retain) NSArray *strokeDashArray;

@end
