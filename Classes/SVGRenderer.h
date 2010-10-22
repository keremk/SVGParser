//
//  SVGRenderer.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-04.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "SVGParser.h"
#import "CVPath.h"
#import "CVPathGroup.h"

@interface SVGRenderer : NSObject<SVGParserDelegate> {
//	CGContextRef context_;
	SVGParser *parser_;
	CVPathGroup *renderTree_;
	NSMutableArray *groupStack_;
}

- (CGMutablePathRef) newPathUsingSVGPath:(NSArray *) path usingTransform:(SVGTransform) transform;
- (CGPathRef) newRectPathUsingSVGRect:(SVGRect) svgRect usingTransform:(SVGTransform) transform;
- (CGPathRef) newCirclePathUsingSVGCircle:(SVGCircle) svgCircle usingTransform:(SVGTransform) transform;
- (CGPathRef) newEllipsePathUsingSVGEllipse:(SVGEllipse) svgEllipse usingTransform:(SVGTransform) transform;
- (CGPathRef) newLinePathUsingSVGLine:(SVGLine) svgLine usingTransform:(SVGTransform) transform;
- (CGPathRef) newPolylinePathUsingSVGPolyline:(NSArray *) svgPolyline usingTransform:(SVGTransform) transform;
- (CGPathRef) newPolygonPathUsingSVGPolygon:(NSArray *) svgPolygon usingTransform:(SVGTransform) transform;

- (void) renderInContext:(CGContextRef) context;
- (id) initWithParser:(SVGParser *)parser;

@property (nonatomic, retain) CVPathGroup *renderTree;
@end
