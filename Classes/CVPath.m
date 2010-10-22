//
//  CVPath.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "CVPath.h"

@interface CVPath()
- (void) fillAndStrokePathUsingStyle:(NSDictionary *) style usingContext:(CGContextRef) context;
@end


@implementation CVPath
@synthesize path = path_, style = style_;

- (void) dealloc {
	if (path_ != NULL) {
		CGPathRelease(path_);
		path_ = NULL;
	}
	
	[style_ release], style_ = nil;
	[super dealloc];
}


- (id) initWithPath:(CGPathRef) path style:(NSDictionary *)style {
	self = [super init];
	if (self != nil) {
		if (path != NULL) {
			path_ = path;
			CGPathRetain(path_);
		} else {
			path = NULL;
		}
		
		if (style != nil) {
			style_ = style;
			[style_ retain];
		} else {
			style_ = nil;
		}
		
	}
	return self;
}

- (void) renderInContext:(CGContextRef) context {
	CGContextSaveGState(context);
	[SVGStyleHelper setContext:context usingStyle:style_];
	CGContextAddPath(context, path_);
	[self fillAndStrokePathUsingStyle:style_ usingContext:context];
	CGContextRestoreGState(context);	
}

- (void) fillAndStrokePathUsingStyle:(NSDictionary *) style usingContext:(CGContextRef) context {
	NSString *fillRule = [style objectForKey:@"fill-rule"];
	
	if (nil == fillRule) {
		fillRule = @"nonzero";
	}
	if ([fillRule isEqualToString:@"nonzero"]) {
		CGContextDrawPath(context, kCGPathFillStroke);
	} else if ([fillRule isEqualToString:@"evenodd"]) {
		CGContextDrawPath(context, kCGPathEOFillStroke);
	}
}


@end
