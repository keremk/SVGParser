//
//  CVPathGroup.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGShapes.h"
#import "SVGTransform.h"

@interface CVPathGroup : NSObject {
	NSMutableArray *pathsAndGroups_;
	NSDictionary *style_;
	SVGTransform transform_;
}

- (id) initWithStyle:(NSDictionary *) style transform:(SVGTransform) transform;
- (void) renderInContext:(CGContextRef) context;
@property (nonatomic, readonly) NSDictionary *style;
@property (nonatomic, readonly) SVGTransform transform;
@property (nonatomic, readonly) NSMutableArray *pathsAndGroups;

@end
