//
//  CVPath.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGShapes.h"

@interface CVPath : NSObject {
	CGPathRef path_;
	NSDictionary *style_;
}

- (id) initWithPath:(CGPathRef) path style:(NSDictionary *)style;
- (void) renderInContext:(CGContextRef) context;
@property (nonatomic, readonly) CGPathRef path;
@property (nonatomic, readonly) NSDictionary *style;
@end
