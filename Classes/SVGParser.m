//
//  SVGParser.m
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright (c) 2010 Coding Ventures. All rights reserved.
//

#import "SVGParser.h"

@interface SVGParser()

- (void) initParser;

@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) SVGGroup *currentGroup;

@end

@implementation SVGParser
@synthesize xmlParser = xmlParser_;
@synthesize currentGroup = currentGroup_;

- (void) dealloc {
    [xmlParser_ release], xmlParser_ = nil;
    [svgElements_ release], svgElements_ = nil;
    [groups_ release], groups_ = nil;
    [super dealloc];
}

- (void) initWithContentsOfUrl:(NSURL *)url {
    xmlParser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    [self initParser];
}

- (void) initWithData:(NSData *)data {
    xmlParser_ = [[NSXMLParser alloc] initWithData:data];
    
    [self initParser];
}

- (void) initParser {
    [xmlParser_ setDelegate:self];
    svgElements_ = [[NSArray alloc] initWithObjects:@"path", @"circle", @"ellipse", @"line", @"polyline", @"rect", @"polygon", @"image", nil];
    groups_ = [[NSMutableArray alloc] init];            
}

- (BOOL) parse {
    return [xmlParser_ parse]; 
    
}

#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"g"]) {
        SVGGroup *newGroup = [[SVGGroup alloc] init];
        [groups_ addObject:newGroup];
        self.currentGroup = newGroup;
    }
    
    for (NSString *svgElement in svgElements_) {
        if ([elementName isEqualToString:svgElement]) { 
            NSString *elementHandlerString = [NSString stringWithFormat:@"handle%@usingAttributes:", [svgElement capitalizedString]];
            if ([self respondsToSelector:NSSelectorFromString(elementHandlerString)]) {
                [self performSelector:NSSelectorFromString(elementHandlerString) withObject:attributeDict];
            }
            
        }
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"g"]) {
        [groups_ removeLastObject];
        self.currentGroup = [groups_ lastObject];
    }
}

#pragma mark SVG Handlers

- (void) handlePathUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handleCircleUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handleEllipseUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handleLineUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handlePolylineUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handleRectUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handlePolygonUsingAttributes:(NSDictionary *) attributes {
    
}

- (void) handleImageUsingAttributes:(NSDictionary *) attributes {
    
}



@end
