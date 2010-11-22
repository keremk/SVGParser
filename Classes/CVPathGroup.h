//
//  CVPathGroup.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-17.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGShapes.h"
#import "SVGTransform.h"
#import "CVPathProtocol.h"
#import "CVPath.h"

@class CVPath;

@interface CVPathGroup : NSObject<CVPathProtocol> {
	NSMutableArray *pathsAndGroups_;
	NSDictionary *style_;
	SVGTransform transform_;
    CGRect boundingBox_;
}

- (id) initWithStyle:(NSDictionary *) style transform:(SVGTransform) transform;
- (void) addCVPath:(CVPath *) cvPath;
- (void) addCVPathGroup:(CVPathGroup *) cvPathGroup;

@property (nonatomic, readonly) NSDictionary *style;
@property (nonatomic, readonly) SVGTransform transform;
@property (nonatomic, readonly) CGRect boundingBox;
//@property (nonatomic, readonly) NSMutableArray *pathsAndGroups;

@end
