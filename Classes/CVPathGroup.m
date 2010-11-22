//
//  CVPathGroup.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "CVPathGroup.h"

@interface CVPathGroup()

@end


@implementation CVPathGroup
@synthesize style = style_, transform = transform_, boundingBox = boundingBox_;
//, pathsAndGroups = pathsAndGroups_;

- (void) dealloc {
	[pathsAndGroups_ release], pathsAndGroups_ = nil;
	[style_ release], style_ = nil;
	[super dealloc];
}


- (id) initWithStyle:(NSDictionary *)style transform:(SVGTransform) transform {
	self = [super init];
	if (self != nil) {
		if (style != nil) {
			style_ = style;
			[style_ retain];
		} else {
			style_ = nil;
		}
		transform_ = transform;
		pathsAndGroups_ = [[NSMutableArray alloc] init];
        boundingBox_ = CGRectZero;
	}
	return self;
}


- (void) addCVPath:(CVPath *) cvPath {
    CGRect newBoundingBox = CGPathGetPathBoundingBox(cvPath.path);
    boundingBox_ = CGRectUnion(newBoundingBox, boundingBox_);
    [pathsAndGroups_ addObject:cvPath];
}

- (void) addCVPathGroup:(CVPathGroup *) cvPathGroup {
    boundingBox_ = CGRectUnion(cvPathGroup.boundingBox, boundingBox_);
    [pathsAndGroups_ addObject:cvPathGroup];
}

- (BOOL) containsPoint:(CGPoint) point {
    if (CGRectContainsPoint(boundingBox_, point)) {
        for (NSInteger i = 0; i < [pathsAndGroups_ count]; i++) {
            NSObject<CVPathProtocol> *pathOrGroup = [pathsAndGroups_ objectAtIndex:i];
            
            BOOL containsPoint = [pathOrGroup containsPoint:point];
            if (containsPoint) {
                // Exit the loop quick
                return YES;
            }
        }
    } 
    
    return NO;
}
                                     
                
- (NSArray *) allPathsWhichContainsPoint:(CGPoint) point {
    NSMutableArray *allPaths = [NSMutableArray array];
    if (CGRectContainsPoint(boundingBox_, point)) {
        for (NSInteger i = 0; i < [pathsAndGroups_ count]; i++) {
            NSObject<CVPathProtocol> *pathOrGroup = [pathsAndGroups_ objectAtIndex:i];
            
            NSArray *paths = [pathOrGroup allPathsWhichContainsPoint:point];
            [allPaths addObjectsFromArray:paths];
        }        
    }
    
    return allPaths;
}

- (CVPath *) topMostPathWhichContainsPoint:(CGPoint) point {
    // Assume the XML order and subsequently array order is the order of drawing -> painters model
    
    if (CGRectContainsPoint(boundingBox_, point)) {
        NSInteger startingCount = [pathsAndGroups_ count] - 1;
        for (NSInteger i = startingCount; i >= 0  ; i--) {
            NSObject<CVPathProtocol> *pathOrGroup = [pathsAndGroups_ objectAtIndex:i];
            
            CVPath *path = [pathOrGroup topMostPathWhichContainsPoint:point];
            if (nil != path) {
                return path;
            }
        }
    }
    return nil;
}

- (void) renderInContext:(CGContextRef) context {
	CGContextSaveGState(context);
	
	// Do the styling
	[SVGStyleHelper setContext:context usingStyle:style_];
	
	// Do the transform
	CGAffineTransform transform = [SVGTransformHelper transformUsingSVGTransform:transform_];
	CGContextConcatCTM(context, transform);
	
	for (NSInteger i = 0; i < [pathsAndGroups_ count]; i++) {
		NSObject<CVPathProtocol> *pathOrGroup = [pathsAndGroups_ objectAtIndex:i];
        
        [pathOrGroup renderInContext:context];
		
	}
	
	CGContextRestoreGState(context);
}
@end
