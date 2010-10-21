//
//  SVGTransform.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-16.
//  Copyright 2010 Coding Ventures. All rights reserved.
//
#import "SVGTransform.h"

@implementation SVGTransformHelper

+ (CGAffineTransform) transformUsingSVGTransform:(SVGTransform) transform {
	CGAffineTransform cgTransform = CGAffineTransformIdentity;	
	
	switch (transform.transformType) {
		case none:
			cgTransform = CGAffineTransformIdentity;
			break;
		case matrix:
			cgTransform = CGAffineTransformMake(transform.matrixValues_[0], 
												transform.matrixValues_[1], 
												transform.matrixValues_[2],
												transform.matrixValues_[3],
												transform.matrixValues_[4],
												transform.matrixValues_[5]);
			break;
		case rotate:
			cgTransform = CGAffineTransformMakeRotation(transform.rotateAngle);
			break;
		case scale:
			cgTransform = CGAffineTransformMakeScale(transform.scaleX, transform.scaleY);
			break;
		case translate:
			cgTransform = CGAffineTransformMakeTranslation(transform.translateX, transform.translateY);
			break;
		case skewX:
			cgTransform = CGAffineTransformMake(1.0f, 0.0f, tan(transform.skewAngle), 1.0f, 0.0f, 0.0f);
			break;
		case skewY:
			cgTransform = CGAffineTransformMake(1.0f, tan(transform.skewAngle), 0.0f, 1.0f, 0.0f, 0.0f);
			break;
		default:
			break;
	}
	return cgTransform;
}

@end
