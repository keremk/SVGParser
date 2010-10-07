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

@protocol SVGParserDelegate;

@interface SVGParser : NSObject<NSXMLParserDelegate> {
@private    
    NSXMLParser *xmlParser_;
    NSArray *svgElements_;
    NSMutableArray *groups_;
    SVGGroup *currentGroup_;
	id<SVGParserDelegate> delegate_;
	
	CGPoint curPoint_;
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
- (void) parser:(SVGParser *) parser didFoundPath:(NSArray *) path usingStyle:(SVGStyle *) style;
- (void) parser:(SVGParser *) parser didFoundRect:(SVGRect) rect;
@end
