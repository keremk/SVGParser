//
//  SVGViewController.h
//  SVGParser
//
//  Created by Kerem Karatal on 11/1/10.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGView.h"

@interface SVGViewController : UIViewController <UIScrollViewDelegate>{
    NSURL *svgSourceUrl_;
    SVGView *svgView_;
}

@property (nonatomic, retain) NSURL *svgSourceUrl;
@property (nonatomic, retain) SVGView *svgView;

@end
