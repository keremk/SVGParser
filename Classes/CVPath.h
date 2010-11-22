//
//  CVPath.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGShapes.h"
#import "CVPathGroup.h"
#import "CVPathProtocol.h"

@protocol CVPathProtocol;



@interface CVPath : NSObject<CVPathProtocol> {
	CGPathRef path_;
	NSDictionary *style_;
}

- (id) initWithPath:(CGPathRef) path style:(NSDictionary *)style;
@property (nonatomic, readonly) CGPathRef path;
@property (nonatomic, readonly) NSDictionary *style;
@end
