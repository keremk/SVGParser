//
//  SVGParser.h
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright (c) 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGGroup.h"
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
	NSArray *svgContainerElements_;
	NSArray *styleAttributes_;
    NSMutableArray *groups_;
 	id<SVGParserDelegate> delegate_;
	
	CGPoint curPoint_;
	CGPoint initialPoint_;
	BOOL isTherePreviousCubicControlPoint_, isTherePreviousQuadraticControlPoint_;
	CGPoint previousCubicControlPoint_, previousQuadraticControlPoint_;
    
    CGRect boundingBox_;
    CGRect viewBox_;
}

- (id) initWithContentsOfUrl:(NSURL *) url;
- (id) initWithData:(NSData *) data;
- (BOOL) parse;

@property(nonatomic, assign) id<SVGParserDelegate> delegate;
@property (nonatomic) CGRect boundingBox;
@property (nonatomic) CGRect viewBox;

@end

@protocol SVGParserDelegate<NSObject>
@required
- (void) parser:(SVGParser *) parser didBeginGroup:(SVGGroup *) group;
- (void) parser:(SVGParser *) parser didEndGroup:(SVGGroup *) group;
- (void) parser:(SVGParser *) parser didFoundPath:(NSArray *) path 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundRect:(SVGRect) rect 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundCircle:(SVGCircle) circle 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundEllipse:(SVGEllipse) ellipse 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundLine:(SVGLine) line 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundPolyline:(NSArray *) polyline 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
- (void) parser:(SVGParser *) parser didFoundPolygon:(NSArray *) polygon 
	 usingStyle:(NSDictionary *) style 
 usingTransform:(SVGTransform) transform;
@end
