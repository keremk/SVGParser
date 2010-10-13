//
//  SVGGroup.m
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGGroup.h"


@implementation SVGGroup
@synthesize style = style_;
@synthesize transform = transform_;
@synthesize groupId = groupId_;

- (void) dealloc {
	[groupId_ release], groupId_ = nil;
	[style_ release], style_ = nil;
	[super dealloc];
}

- (id) init {
	self = [super init];
	if (self != nil) {

	}
	return self;
}


@end
