//
//  SVGGroup.h
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGTransform.h"

@interface SVGGroup : NSObject {
	NSDictionary *style_;
	SVGTransform transform_;
	NSString *groupId_;
}

@property (nonatomic, retain) NSDictionary *style;
@property (nonatomic) SVGTransform transform;
@property (nonatomic, retain) NSString *groupId;

@end
