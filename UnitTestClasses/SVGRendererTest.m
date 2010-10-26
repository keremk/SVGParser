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


// Change the below based on where your project is installed 
//static NSString *basePath = @"/Users/kkaratal/Developer/SVGParser/SVGFiles";
static NSString *basePath = @"/Users/kkaratal/Developer/IPhone/Projects/SVGParser/SVGFiles";

- (void) testRenderPathWithLines {
    NSArray *testFilenames = [NSArray arrayWithObjects:@"Triangle.svg", @"RoundedRect.svg",
							  @"Polyline.svg", @"Polygon.svg", @"Ellipse.svg", @"Bear01.svg", @"TransformsAndGroups.svg", nil];
	
	for (NSInteger i = 0; i < [testFilenames count]; i++) {
		NSString *testSVGFilename = [testFilenames objectAtIndex:i];
		NSURL *svgUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/PathTests/%@", basePath, testSVGFilename]];
//		SVGParser *svgParser = [[SVGParser alloc] initWithContentsOfUrl:svgUrl];
//		SVGRenderer *svgRenderer = [[SVGRenderer alloc] initWithParser:svgParser];
        SVGRenderer *svgRenderer = [[SVGRenderer alloc] initWithContentsOfURL:svgUrl];
		
//		CGContextRef context = CreateBitmapContext(1024, 1024);
		CGContextRef context = CreateBitmapContext(svgRenderer.boundingBox.size.width, svgRenderer.boundingBox.size.height);

		[svgRenderer parseSVG];
		[svgRenderer renderInContext:context];

		NSURL *imageDataUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/PathTests/%@.png", basePath, testSVGFilename]];
		SaveBitmapContextAsFile(context, imageDataUrl);
		
		[svgRenderer release];
//		[svgParser release];
	}
}

- (void) testDebugPaths {
	NSArray *testFilenames = [NSArray arrayWithObjects:@"Polyline.svg", nil];
	
	for (NSInteger i = 0; i < [testFilenames count]; i++) {
		NSString *testSVGFilename = [testFilenames objectAtIndex:i];
		NSURL *svgUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/PathTests/%@", basePath, testSVGFilename]];
//		SVGParser *svgParser = [[SVGParser alloc] initWithContentsOfUrl:svgUrl];
//		SVGRenderer *svgRenderer = [[SVGRenderer alloc] initWithParser:svgParser];
        SVGRenderer *svgRenderer = [[SVGRenderer alloc] initWithContentsOfURL:svgUrl];

		[svgRenderer parseSVG];		
		
		CGContextRef context = CreateBitmapContext(svgRenderer.boundingBox.size.width, svgRenderer.boundingBox.size.height);
		[svgRenderer renderInContext:context];
		
		NSURL *imageDataUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/PathTests/%@.png", basePath, testSVGFilename]];
		SaveBitmapContextAsFile(context, imageDataUrl);
		
		[svgRenderer release];
//		[svgParser release];
	}
}

#endif


@end
