//
//  CVPathGroup.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "CVPathGroup.h"
#import "CVPath.h"

@implementation CVPathGroup
@synthesize style = style_, transform = transform_, pathsAndGroups = pathsAndGroups_;

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
	}
	return self;
}

- (void) renderInContext:(CGContextRef) context {
	CGContextSaveGState(context);
	
	// Do the styling
	[SVGStyleHelper setContext:context usingStyle:style_];
	
	// Do the transform
	CGAffineTransform transform = [SVGTransformHelper transformUsingSVGTransform:transform_];
	CGContextConcatCTM(context, transform);
	
	for (NSInteger i = 0; i < [pathsAndGroups_ count]; i++) {
		NSObject *pathOrGroup = [pathsAndGroups_ objectAtIndex:i];
		
		if ([pathOrGroup isKindOfClass:[CVPathGroup class]]) {
			CVPathGroup *group = (CVPathGroup *) pathOrGroup;
			
			[group renderInContext:context];
		} else if ([pathOrGroup isKindOfClass:[CVPath class]]) {
			CVPath *path = (CVPath *) pathOrGroup;
			
			[path renderInContext:context];
		}
	}
	
	CGContextRestoreGState(context);
}
@end
