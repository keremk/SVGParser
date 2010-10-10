//
//  SVGRendererTest.m
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-08.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGRendererTest.h"
#import "SVGParser.h"
#import "SVGRenderer.h"
#import <CoreGraphics/CoreGraphics.h>

#import "Utils.h"

@implementation SVGRendererTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

static NSString *basePath = @"/Users/kkaratal/Developer/SVGParser/SVGFiles";

- (void) testRenderPathWithLines {
	NSArray *testFilenames = [NSArray arrayWithObjects:@"Triangle.svg", @"RoundedRect.svg",
							  @"Polyline.svg", nil];
	
	for (NSInteger i = 0; i < [testFilenames count]; i++) {
		NSString *testSVGFilename = [testFilenames objectAtIndex:i];
		NSURL *svgUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/PathTests/%@", basePath, testSVGFilename]];
		SVGParser *svgParser = [[SVGParser alloc] initWithContentsOfUrl:svgUrl];
		SVGRenderer *svgRenderer = [[SVGRenderer alloc] init];
		
		CGContextRef context = CreateBitmapContext(1024, 1024);
		
		[svgRenderer renderSVGUsingParser:svgParser inContext:context];

		NSURL *imageDataUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/PathTests/%@.png", basePath, testSVGFilename]];
		SaveBitmapContextAsFile(context, imageDataUrl);
		
		[svgRenderer release];
		[svgParser release];
	}
}

#endif


@end
