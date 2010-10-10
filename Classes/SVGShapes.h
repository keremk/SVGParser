//
//  SVGShapes.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-05.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <CoreGraphics/CoreGraphics.h>

typedef struct SVGCircle {
    CGPoint center;
    CGFloat radius;
} SVGCircle;

typedef struct SVGRect {
    CGRect rect;
    CGFloat radiusX;
    CGFloat radiusY;
} SVGRect;

typedef struct SVGEllipse {
    CGPoint center;
    CGFloat radiusX;
    CGFloat radiusY;    
} SVGEllipse;

typedef struct SVGLine {
    CGPoint start;
    CGPoint end;
} SVGLine;

typedef enum SVGElementType {
	SVGMoveTo, SVGLineTo, SVGCubicBezier, SVGQuadBezier, SVGArc, SVGClosePath
} SVGElementType;

typedef enum SVGLargeArcFlag {
	largeArcOn,
	largeArcOff,
	largeArcBoth
} SVGLargeArcFlag;

typedef enum SVGSweepFlag {
	sweepOn,
	sweepOff,
	sweepBoth
} SVGSweepFlag;

@interface SVGPathElement : NSObject {
	SVGElementType elementType;
	CGPoint initialPoint;
	CGPoint toPoint;
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGFloat radiusX;
	CGFloat radiusY;
	CGFloat xAxisRotation;
	SVGLargeArcFlag largeArcFlag;
	SVGSweepFlag sweepFlag;	
}

@property (nonatomic) SVGElementType elementType;
@property (nonatomic) CGPoint initialPoint;
@property (nonatomic) CGPoint toPoint;
@property (nonatomic) CGPoint controlPoint1;
@property (nonatomic) CGPoint controlPoint2;
@property (nonatomic) CGFloat xAxisRotation;
@property (nonatomic) CGFloat radiusX;
@property (nonatomic) CGFloat radiusY;
@property (nonatomic) SVGLargeArcFlag largeArcFlag;
@property (nonatomic) SVGSweepFlag sweepFlag;

@end

