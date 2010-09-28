/*
 *  SVGShapes.h
 *  SVGParser
 *
 *  Created by Kerem Karatal on 9/27/10.
 *  Copyright 2010 Coding Ventures. All rights reserved.
 *
 */

#ifndef SVGSHAPES_H_
#define SVGSHAPES_H_

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



#endif
