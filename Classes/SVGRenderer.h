//
//  SVGRenderer.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-04.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SVGParser.h"

@interface SVGRenderer : NSObject<SVGParserDelegate> {
	CGContextRef context_;
}

- (CGMutablePathRef) newPathUsingSVGPath:(NSArray *) path usingTransform:(SVGTransform) transform;
- (CGPathRef) newRectPathUsingSVGRect:(SVGRect) svgRect usingTransform:(SVGTransform) transform;
- (CGPathRef) newCirclePathUsingSVGCircle:(SVGCircle) svgCircle usingTransform:(SVGTransform) transform;
- (CGPathRef) newEllipsePathUsingSVGEllipse:(SVGEllipse) svgEllipse usingTransform:(SVGTransform) transform;
- (CGPathRef) newLinePathUsingSVGLine:(SVGLine) svgLine usingTransform:(SVGTransform) transform;
- (CGPathRef) newPolylinePathUsingSVGPolyline:(NSArray *) svgPolyline usingTransform:(SVGTransform) transform;
- (CGPathRef) newPolygonPathUsingSVGPolygon:(NSArray *) svgPolygon usingTransform:(SVGTransform) transform;

- (void) renderSVGUsingParser:(SVGParser *) parser inContext:(CGContextRef) context;
- (void) renderSVGPath:(NSArray *) path 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context;
- (void) renderSVGRect:(SVGRect) rect 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context;
- (void) renderSVGCircle:(SVGCircle) circle 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context;
- (void) renderSVGEllipse:(SVGEllipse) ellipse 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context;
- (void) renderSVGLine:(SVGLine) line 
			   usingStyle:(SVGStyle *) style 
		   usingTransform:(SVGTransform) transform 
				inContext:(CGContextRef) context;
- (void) renderSVGPolyline:(NSArray *) polyline 
			usingStyle:(SVGStyle *) style 
		usingTransform:(SVGTransform) transform 
			 inContext:(CGContextRef) context;
- (void) renderSVGPolygon:(NSArray *) polygon 
				usingStyle:(SVGStyle *) style 
			usingTransform:(SVGTransform) transform 
				 inContext:(CGContextRef) context;

- (void) setContext:(CGContextRef) context usingStyle:(SVGStyle *) style;
- (CGAffineTransform) transformUsingSVGTransform:(SVGTransform) transform;

@end
