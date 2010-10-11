//
//  SVGParser.h
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright (c) 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGGroup.h"
#import "SVGStyle.h"
#import "SVGShapes.h"

#include "SVGTransform.h"

@protocol SVGParserDelegate;

@interface SVGCommand : NSObject {
	unichar command;
	unichar *coords;
	size_t coordsLength;
}

@property (nonatomic) unichar command;
@property (nonatomic) unichar *coords;
@property (nonatomic) size_t coordsLength;
@end


@interface SVGParser : NSObject<NSXMLParserDelegate> {
@private    
    NSXMLParser *xmlParser_;
    NSArray *svgElements_;
    NSMutableArray *groups_;
    SVGGroup *currentGroup_;
	id<SVGParserDelegate> delegate_;
	
	CGPoint curPoint_;
	CGPoint initialPoint_;
	BOOL isTherePreviousCubicControlPoint_, isTherePreviousQuadraticControlPoint_;
	CGPoint previousCubicControlPoint_, previousQuadraticControlPoint_;
}

- (id) initWithContentsOfUrl:(NSURL *) url;
- (id) initWithData:(NSData *) data;
- (BOOL) parse;

@property(nonatomic, assign) id<SVGParserDelegate> delegate;

@end

@protocol SVGParserDelegate<NSObject>
@required
- (void) parser:(SVGParser *) parser didFoundPath:(NSArray *) path 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundRect:(SVGRect) rect 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundCircle:(SVGCircle) circle 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundEllipse:(SVGEllipse) ellipse 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundLine:(SVGLine) line 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundPolyline:(NSArray *) polyline 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundPolygon:(NSArray *) polygon 
	 usingStyle:(SVGStyle *) style 
 usingTransform:(SVGTransform) transform;
@end
