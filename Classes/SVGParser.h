//
//  SVGParser.h
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright (c) 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGGroup.h"

@interface SVGParser : NSObject<NSXMLParserDelegate> {

@private    
    NSXMLParser *xmlParser_;
    NSArray *svgElements_;
    NSMutableArray *groups_;
    SVGGroup *currentGroup_;
}

- (void) initWithContentsOfUrl:(NSURL *) url;
- (void) initWithData:(NSData *) data;

@end
