//
//  SVGRenderer.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-04.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGRenderer.h"
#import "UIColor-Expanded.h"


@interface SVGRenderer()
- (CGPathRef) newEllipseInRect:(CGRect) rect usingTransform:(SVGTransform) transform;
- (CGMutablePathRef) newLines:(NSArray *) lines usingTransform:(SVGTransform) transform;
- (void) setSVGStyleDefaultsInContext:(CGContextRef) context;

@property (nonatomic, retain) SVGParser *parser;
@end

@implementation SVGRenderer

@synthesize renderTree = renderTree_, parser = parser_;

- (void) dealloc {
	[parser_ release], parser_ = nil;
	[renderTree_ release], renderTree_ = nil;
	[groupStack_ release], groupStack_ = nil;
	[super dealloc];
}

- (id) initWithParser:(SVGParser *) parser {
	self = [super init];
	if (self != nil) {
		self.parser = parser;
		[parser setDelegate:self];
		renderTree_ = nil;
		groupStack_ = nil;
	}
	return self;
}

- (id) initWithContentsOfURL:(NSURL *) url {
	self = [super init];
	if (self != nil) {
		self.parser = [[SVGParser alloc] initWithContentsOfUrl:url];
		[self.parser setDelegate:self];
		renderTree_ = nil;
		groupStack_ = nil;
	}
	return self;
}

- (CGRect) boundingBox {
    return parser_.boundingBox;
}

- (CGRect) viewBox {
    return parser_.viewBox;
}

- (CGPathRef) newPathUsingSVGPath:(NSArray *) path usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGAffineTransform cgTransform = [SVGTransformHelper transformUsingSVGTransform:transform];
	
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
	CGAffineTransform cgTransform = [SVGTransformHelper transformUsingSVGTransform:transform];
		
	if (svgRect.radiusX	== 0 || svgRect.radiusY == 0) {
		// Not rounded so just add the rectangle
		CGPathAddRect(cgPath, &cgTransform, svgRect.rect);
	} else {
        // Translate the below to lower-left corner of the rectangle, so that origin is at 0,0 and we can work
        // with the width and height of the rectangle only.
		CGAffineTransform theTransform = CGAffineTransformTranslate(cgTransform, CGRectGetMinX(svgRect.rect), CGRectGetMinY(svgRect.rect));

        // Do the below scaling so that if ovalWidth != ovalHeight, we create a normalized
        // system where they are equal and can use the CGContextAddArcToPoint which expects a circle not oval.
        // At this point ovalWidth and ovalHeight are normalized to 1.0 and hence the radius is 0.5
		
		theTransform = CGAffineTransformScale(theTransform, svgRect.radiusX, svgRect.radiusY);
		
		// Now unscale the width and height of the rectangle
		fw = CGRectGetWidth(svgRect.rect) / svgRect.radiusX;
		fh = CGRectGetHeight(svgRect.rect) / svgRect.radiusY;

		// Start at the right side of rectangle half point of the height and go counterclockwise
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
	CGAffineTransform cgTransform = [SVGTransformHelper transformUsingSVGTransform:transform];
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

- (void) parseSVG {
    if (nil == renderTree_) {
        [self.parser parse];
    }
}

- (void) renderInContext:(CGContextRef) context {
	if (nil != renderTree_) {
        [self setSVGStyleDefaultsInContext:context];
        [renderTree_ renderInContext:context];
	}
}


- (void) setSVGStyleDefaultsInContext:(CGContextRef) context {	
	CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
	CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
	CGContextSetAlpha(context, 1.0f);
	CGContextSetMiterLimit(context, 4.0f);
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetLineCap(context, kCGLineCapButt);
	CGContextSetLineJoin(context, kCGLineJoinMiter);
}


#pragma mark Internal Util methods

- (CGPathRef) newEllipseInRect:(CGRect) rect usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	CGAffineTransform cgTransform = [SVGTransformHelper transformUsingSVGTransform:transform];
	CGPathAddEllipseInRect(cgPath, &cgTransform, rect);
	
	return cgPath;
}

- (CGMutablePathRef) newLines:(NSArray *) lines usingTransform:(SVGTransform) transform {
	CGMutablePathRef cgPath = CGPathCreateMutable();
	if (lines == nil || ([lines count] == 0)) {
		return cgPath;
	}
	CGAffineTransform cgTransform = [SVGTransformHelper transformUsingSVGTransform:transform];
	
	CGPoint start = [[lines objectAtIndex:0] CGPointValue];
	CGPathMoveToPoint(cgPath, &cgTransform, start.x, start.y);
	for (NSInteger i = 1; i < [lines count]; i++) {
		CGPoint pointTo = [[lines objectAtIndex:i] CGPointValue];
		CGPathAddLineToPoint(cgPath, &cgTransform, pointTo.x, pointTo.y);
	}
	
	return cgPath;
}

#pragma mark SVGParserDelegate methods

- (void) parser:(SVGParser *) parser didBeginGroup:(SVGGroup *) group {
	if (nil == renderTree_) {
		renderTree_ = [[CVPathGroup alloc] initWithStyle:group.style transform:group.transform];
		groupStack_ = [[NSMutableArray alloc] init];
		[groupStack_ addObject:renderTree_];
	} else {
		CVPathGroup *newPathGroup = [[CVPathGroup alloc] initWithStyle:group.style transform:group.transform];		
		[[[groupStack_ lastObject] pathsAndGroups] addObject:newPathGroup];
		[groupStack_ addObject:newPathGroup];
		[newPathGroup release];
	}
}

- (void) parser:(SVGParser *)parser didEndGroup:(SVGGroup *)group {
	[groupStack_ removeLastObject];
}

- (void) convertToCVPathUsingStyle: (NSDictionary *) style fromCGPath: (CGPathRef) cgPath  {
	CVPath *cvPath = [[CVPath alloc] initWithPath:cgPath style:style];	
	[[[groupStack_ lastObject] pathsAndGroups] addObject:cvPath];
	[cvPath release];
}

- (void) parser:(SVGParser *) parser didFoundPath:(NSArray *) path 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {
	CGPathRef cgPath = [self newPathUsingSVGPath:path usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}

- (void) parser:(SVGParser *) parser didFoundRect:(SVGRect) rect 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {
	CGPathRef cgPath = [self newRectPathUsingSVGRect:rect usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}

- (void) parser:(SVGParser *) parser didFoundCircle:(SVGCircle) circle 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {
	CGPathRef cgPath = [self newCirclePathUsingSVGCircle:circle usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}

- (void) parser:(SVGParser *) parser didFoundEllipse:(SVGEllipse) ellipse 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {
	CGPathRef cgPath = [self newEllipsePathUsingSVGEllipse:ellipse usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}

- (void) parser:(SVGParser *) parser didFoundLine:(SVGLine) line 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {

	CGPathRef cgPath = [self newLinePathUsingSVGLine:line usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}
	
- (void) parser:(SVGParser *) parser didFoundPolyline:(NSArray *) polyline 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {
	CGPathRef cgPath = [self newPolylinePathUsingSVGPolyline:polyline usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}

- (void) parser:(SVGParser *) parser didFoundPolygon:(NSArray *) polygon 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform {
	
	CGPathRef cgPath = [self newPolygonPathUsingSVGPolygon:polygon usingTransform:transform];
	[self convertToCVPathUsingStyle:style fromCGPath:cgPath];
	CGPathRelease(cgPath);
}

@end
