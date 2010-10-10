//
//  SVGTransform.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-07.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#ifndef SVGTRANSFORM_H_
#define SVGTRANSFORM_H_

#include <CoreGraphics/CoreGraphics.h>

typedef enum SVGTransformType {
	none,
	matrix,
	translate,
	scale,
	rotate,
	skewX,
	skewY
} SVGTransformType;

typedef struct SVGTransform {
	SVGTransformType transformType;
	CGFloat matrixValues_[6];
	CGFloat translateX, translateY;
	CGFloat scaleX, scaleY;
	CGFloat rotateAngle;
	CGPoint rotateCenter;
	BOOL	rotateAroundOrigin;
	CGFloat skewAngle;
} SVGTransform;

#endif