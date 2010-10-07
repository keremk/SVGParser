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
	LineJoinMeter, 
	LineJoinRound,
	LineJoinBevel
} SVGStrokeLineJoin;

typedef enum SVGStrokeLineCap {
	LineCapButt,
	LineCapRound,
	LineCapSquare
} SVGStrokeLineCap;

@interface SVGStyle : NSObject {
	UIColor *fillColor;
	UIColor *strokeColor;
	CGFloat strokeWidth;
	CGFloat strokeMiterLimit; 
	SVGStrokeLineJoin strokeLineJoin;
	SVGStrokeLineCap strokeLineCap;
}

@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic) CGFloat strokeMiterLimit;
@property (nonatomic) SVGStrokeLineCap strokeLineCap;
@property (nonatomic) SVGStrokeLineJoin strokeLineJoin;

@end
