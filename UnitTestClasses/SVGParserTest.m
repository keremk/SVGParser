//
//  SVGParserTest.m
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGParserTest.h"
#import "SVGParser.h"

@implementation SVGParserTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#else                           // all code under test must be linked into the Unit Test bundle

static NSString *basePath = @"/Users/kkaratal/Developer/SVGParser/SVGFiles";

- (void) testLoadSVG {
	NSString *testSVGFilename = @"Bear01.svg";
	NSURL *svgUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", basePath, testSVGFilename]];
	SVGParser *svgParser = [[SVGParser alloc] initWithContentsOfUrl:svgUrl];
	[svgParser parse];
	
	[svgParser release];
}

- (void) testMath {
    
    STAssertTrue((1+1)==2, @"Compiler isn't feeling well today :-(" );
    
}


#endif


@end
