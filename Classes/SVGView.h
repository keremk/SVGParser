//
//  SVGView.h
//  SVGParser
//
//  Created by Kerem Karatal on 10-10-16.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGRenderer.h"

@interface SVGView : UIView {
    SVGRenderer *renderer_;
    CGFloat scaleX_, scaleY_;
}

- (void) loadViewUsingSVGRenderer:(SVGRenderer *) renderer;

@end
