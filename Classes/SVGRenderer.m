//
//  SVGRenderer.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-04.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGRenderer.h"

@interface SVGRenderer()
- (void) fillAndStrokePathUsingStyle:(SVGStyle *) style usingContext:(CGContextRef) context;
- (CGPathRef) newEllipseInRect:(CGRect) rect usingTransform:(SVGTransform) transform;
- (void) renderPath:(CGPathRef) path usingStyle:(SVGStyle *) style usingContext:(CGContextRef) context;
- (CGMutablePathRef) newLines:(NSArray *) lines usingTransform:(SVGTransform) transform;
@end

@implementation SVGRenderer

- (id) init {
	self = [super init];
	if (self != nil) {
		context_ = NULL;
	}
	return self;
}


- (CGPathRef) newPathUsingSVGPath:(NSArray *) path usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGAffineTransform cgTransform = [self transformUsingSVGTransform:transform];
	
	for (NSInteger i = 0; i < [path count]; i++) {
		SVGPathElement *pathElement = [path objectAtIndex:i];
		switch (pathElement.elementType) {
			case SVGMoveTo:
				CGPathMoveToPoint(cgPath, &cgTransform, pathElement.toPoint.x, pathElement.toPoint.y);
				break;
			case SVGLineTo:
				CGPathAddLineToPoint(cgPath, &cgTransform, pathElement.toPoint.x, pathElement.toPoint.y);
				break;
			case SVGCubicBezier:
				CGPathAddCurveToPoint(cgPath, &cgTransform, pathElement.controlPoint1.x, 
									  pathElement.controlPoint1.y,
									  pathElement.controlPoint2.x,
									  pathElement.controlPoint2.y,
									  pathElement.toPoint.x, pathElement.toPoint.y);
				break;
			case SVGQuadBezier:
				CGPathAddQuadCurveToPoint(cgPath, &cgTransform, 
										  pathElement.controlPoint1.x, 
										  pathElement.controlPoint1.y, 
										  pathElement.toPoint.x, pathElement.toPoint.y);
				break;
			case SVGArc:
				
				break;
			case SVGClosePath:
				CGPathCloseSubpath(cgPath);
				break;
			default:
				break;
		}
	}
	return cgPath;
}

- (CGPathRef) newRectPathUsingSVGRect:(SVGRect) svgRect usingTransform:(SVGTransform) transform {
	CGFloat fw, fh;
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGAffineTransform cgTransform = [self transformUsingSVGTransform:transform];
		
	if (svgRect.radiusX	== 0 || svgRect.radiusY == 0) {
		// Not rounded so just add the rectangle
		CGPathAddRect(cgPath, &cgTransform, svgRect.rect);
	} else {
//		CGAffineTransform theTransform = CGAffineTransformMakeTranslation(CGRectGetMinX(svgRect.rect), CGRectGetMinY(svgRect.rect));
		CGAffineTransform theTransform = CGAffineTransformTranslate(cgTransform, CGRectGetMinX(svgRect.rect), CGRectGetMinY(svgRect.rect));
		theTransform = CGAffineTransformScale(theTransform, svgRect.radiusX, svgRect.radiusY);
		
		// Now unscale the width and height of the rectangle
		fw = CGRectGetWidth(svgRect.rect) / svgRect.radiusX;
		fh = CGRectGetHeight(svgRect.rect) / svgRect.radiusY;
		
		CGPathMoveToPoint(cgPath, &theTransform, fw, fh/2);
		
		CGPathAddArcToPoint(cgPath, &theTransform, fw, fh, fw/2, fh, 0.5);
		CGPathAddArcToPoint(cgPath, &theTransform, 0, fh, 0, fh/2, 0.5);
		CGPathAddArcToPoint(cgPath, &theTransform, 0, 0, fw/2, 0, 0.5);
		CGPathAddArcToPoint(cgPath, &theTransform, fw, 0, fw, fh/2, 0.5);
		
		CGPathCloseSubpath(cgPath);
	}
	return cgPath;
}

- (CGPathRef) newCirclePathUsingSVGCircle:(SVGCircle) svgCircle usingTransform:(SVGTransform) transform {
	CGFloat topLeftX = svgCircle.center.x - svgCircle.radius;
	CGFloat topLeftY = svgCircle.center.y - svgCircle.radius;
	CGRect rect = CGRectMake(topLeftX, topLeftY, 2 * svgCircle.radius, 2 * svgCircle.radius);
	return [self newEllipseInRect:rect usingTransform:transform];
}

- (CGPathRef) newEllipsePathUsingSVGEllipse:(SVGEllipse) svgEllipse usingTransform:(SVGTransform) transform {
	CGFloat topLeftX = svgEllipse.center.x - svgEllipse.radiusX;
	CGFloat topLeftY = svgEllipse.center.y - svgEllipse.radiusY;
	CGRect rect = CGRectMake(topLeftX, topLeftY, 2 * svgEllipse.radiusX, 2 * svgEllipse.radiusY);
	return [self newEllipseInRect:rect usingTransform:transform];
}

- (CGPathRef) newLinePathUsingSVGLine:(SVGLine) svgLine usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGAffineTransform cgTransform = [self transformUsingSVGTransform:transform];
	CGPathMoveToPoint(cgPath, &cgTransform, svgLine.start.x, svgLine.start.y);
	CGPathAddLineToPoint(cgPath, &cgTransform, svgLine.end.x, svgLine.end.y);	
	return cgPath;
}

- (CGPathRef) newPolylinePathUsingSVGPolyline:(NSArray *) svgPolyline usingTransform:(SVGTransform) transform {
	return [self newLines:svgPolyline usingTransform:transform];
}

- (CGPathRef) newPolygonPathUsingSVGPolygon:(NSArray *) svgPolygon usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = [self newLines:svgPolygon usingTransform:transform];
	CGPathCloseSubpath(cgPath);
	return cgPath;	
}

- (void) renderSVGUsingParser:(SVGParser *) parser inContext:(CGContextRef) context {
	context_ = context;
	[parser setDelegate:self];
	[parser parse];
}

- (void) renderSVGPath:(NSArray *) path 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context {
	CGPathRef cgPath = [self newPathUsingSVGPath:path usingTransform:transform];
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);
}

- (void) renderSVGRect:(SVGRect) svgRect 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context {
//	CGContextBeginPath(context);
//	if (svgRect.radiusX == 0.0 || svgRect.radiusY == 0.0) {
//        // Not rounded so just add the rectangle
//        CGContextAddRect(context, svgRect.rect);
//    } else {
//        CGContextSaveGState(context);
//        
//        // Translate the below to lower-left corner of the rectangle, so that origin is at 0,0 and we can work
//        // with the width and height of the rectangle only.
//        CGContextTranslateCTM(context, CGRectGetMinX(svgRect.rect), CGRectGetMinY(svgRect.rect));
//        
//        // Do the below scaling so that if ovalWidth != ovalHeight, we create a normalized
//        // system where they are equal and can use the CGContextAddArcToPoint which expects a circle not oval.
//        // At this point ovalWidth and ovalHeight are normalized to 1.0 and hence the radius is 0.5
//        CGContextScaleCTM(context, svgRect.radiusX, svgRect.radiusY);
//        
//        // Now unscale the width and height of the rectangle
//        CGFloat fw = CGRectGetWidth(svgRect.rect) / svgRect.radiusX;
//        CGFloat fh = CGRectGetHeight(svgRect.rect) / svgRect.radiusY;
//        
//        // Start at the right side of rectangle half point of the height and go counterclockwise
//        CGContextMoveToPoint(context, fw, fh/2);
//        
//        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 0.5);
//        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 0.5);
//        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 0.5);
//        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 0.5);
//		
//        CGContextClosePath(context);
//        
//        CGContextRestoreGState(context);
//    }
	CGPathRef cgPath = [self newRectPathUsingSVGRect:svgRect usingTransform:transform];
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);
}

- (void) renderSVGCircle:(SVGCircle) circle 
			  usingStyle:(SVGStyle *) style 
		  usingTransform:(SVGTransform) transform 
			   inContext:(CGContextRef) context {
	CGPathRef cgPath = [self newCirclePathUsingSVGCircle:circle usingTransform:transform]; 
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);
}

- (void) renderSVGEllipse:(SVGEllipse) ellipse 
			   usingStyle:(SVGStyle *) style 
		   usingTransform:(SVGTransform) transform 
				inContext:(CGContextRef) context {
	CGPathRef cgPath = [self newEllipsePathUsingSVGEllipse:ellipse usingTransform:transform];
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);
}

- (void) renderSVGLine:(SVGLine) line 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context {
	CGPathRef cgPath = [self newLinePathUsingSVGLine:line usingTransform:transform];
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);
}

- (void) renderSVGPolyline:(NSArray *) polyline 
				usingStyle:(SVGStyle *) style 
			usingTransform:(SVGTransform) transform 
				 inContext:(CGContextRef) context {
	CGPathRef cgPath = [self newPolylinePathUsingSVGPolyline:polyline usingTransform:transform];
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);
}

- (void) renderSVGPolygon:(NSArray *) polygon 
			   usingStyle:(SVGStyle *) style 
		   usingTransform:(SVGTransform) transform 
				inContext:(CGContextRef) context {
	CGPathRef cgPath = [self newPolygonPathUsingSVGPolygon:polygon usingTransform:transform];
	[self renderPath:cgPath usingStyle:style usingContext:context];
	CGPathRelease(cgPath);	
}

- (void) setContext:(CGContextRef) context usingStyle:(SVGStyle *) style {
	CGContextSetFillColorWithColor(context, [style.fillColor CGColor]);
	CGContextSetStrokeColorWithColor(context, [style.strokeColor CGColor]);
	CGContextSetMiterLimit(context, style.strokeMiterLimit);
	CGContextSetLineWidth(context, style.strokeWidth);
	CGContextSetLineJoin(context, style.strokeLineJoin);
	CGContextSetLineCap(context, style.strokeLineCap);
	CGContextSetAlpha(context, style.strokeOpacity);
}

- (CGAffineTransform) transformUsingSVGTransform:(SVGTransform) transform {
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

#pragma mark Internal Util methods

- (CGPathRef) newEllipseInRect:(CGRect) rect usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGAffineTransform cgTransform = [self transformUsingSVGTransform:transform];
	CGPathAddEllipseInRect(cgPath, &cgTransform, rect);
	
	return cgPath;
}

- (CGMutablePathRef) newLines:(NSArray *) lines usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	if (lines == nil || ([lines count] == 0)) {
		return cgPath;
	}
	CGAffineTransform cgTransform = [self transformUsingSVGTransform:transform];
	
	CGPoint start = [[lines objectAtIndex:0] CGPointValue];
	CGPathMoveToPoint(cgPath, &cgTransform, start.x, start.y);
	for (NSInteger i = 1; i < [lines count]; i++) {
		CGPoint pointTo = [[lines objectAtIndex:i] CGPointValue];
		CGPathAddLineToPoint(cgPath, &cgTransform, pointTo.x, pointTo.y);
	}
	
	return cgPath;
}

- (void) renderPath:(CGPathRef) path usingStyle:(SVGStyle *) style usingContext:(CGContextRef) context {
	CGContextSaveGState(context);
	[self setContext:context usingStyle:style];
	CGContextAddPath(context, path);
	[self fillAndStrokePathUsingStyle:style usingContext:context];
//	CGPathRelease(path);
	CGContextRestoreGState(context);
}

- (void) fillAndStrokePathUsingStyle:(SVGStyle *) style usingContext:(CGContextRef) context {
	switch (style.fillRule) {
		case FillRuleEvenOdd:
			CGContextDrawPath(context, kCGPathEOFillStroke);
			break;
		case FillRuleNonZero:
			CGContextDrawPath(context, kCGPathFillStroke);
			break;
		default:
			break;
	}
}

#pragma mark SVGParserDelegate methods

- (void) parser:(SVGParser *) parser didFoundPath:(NSArray *) path 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	
	if (NULL != context_) {
		[self renderSVGPath:path usingStyle:style usingTransform:transform inContext:context_];
	} 
}

- (void) parser:(SVGParser *) parser didFoundRect:(SVGRect) rect 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	
	if (NULL != context_) {
		[self renderSVGRect:rect usingStyle:style usingTransform:transform inContext:context_];
	}
}

- (void) parser:(SVGParser *) parser didFoundCircle:(SVGCircle) circle 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	
	if (NULL != context_) {
		[self renderSVGCircle:circle usingStyle:style usingTransform:transform inContext:context_];
	}
	
}

- (void) parser:(SVGParser *) parser didFoundEllipse:(SVGEllipse) ellipse 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	
	if (NULL != context_) {
		[self renderSVGEllipse:ellipse usingStyle:style usingTransform:transform inContext:context_];
	}
}

- (void) parser:(SVGParser *) parser didFoundLine:(SVGLine) line 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	
	if (NULL != context_) {
		[self renderSVGLine:line usingStyle:style usingTransform:transform inContext:context_];
	}
}
	
- (void) parser:(SVGParser *) parser didFoundPolyline:(NSArray *) polyline 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	if (NULL != context_) {
		[self renderSVGPolyline:polyline usingStyle:style usingTransform:transform inContext:context_];
	}
}

- (void) parser:(SVGParser *) parser didFoundPolygon:(NSArray *) polygon 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform {
	if (NULL != context_) {
		[self renderSVGPolygon:polygon usingStyle:style usingTransform:transform inContext:context_];
	}	
	
}

@end
