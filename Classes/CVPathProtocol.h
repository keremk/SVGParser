/*
 *  CVPathProtocol.h
 *  SVGParser
 *
 *  Created by Kerem Karatal on 11/22/10.
 *  Copyright 2010 Coding Ventures. All rights reserved.
 *
 */

#import "CVPath.h"
@class CVPath;

@protocol CVPathProtocol<NSObject>
- (void) renderInContext:(CGContextRef) context;
- (BOOL) containsPoint:(CGPoint)point;
- (NSArray *) allPathsWhichContainsPoint:(CGPoint) point;
- (CVPath *) topMostPathWhichContainsPoint:(CGPoint) point;
@end