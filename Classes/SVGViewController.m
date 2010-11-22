    //
//  SVGViewController.m
//  SVGParser
//
//  Created by Kerem Karatal on 11/1/10.
//  Copyright 2010 Coding Ventures. All rights reserved.
//

#import "SVGViewController.h"
#import "SVGRenderer.h"

@interface SVGViewController()
//@property (nonatomic, retain) UIScrollView *scrollView;
@end


@implementation SVGViewController
@synthesize svgSourceUrl = svgSourceUrl_, svgView = svgView_;

- (void)dealloc {
    [svgSourceUrl_ release], svgSourceUrl_ = nil;
    [svgView_ release], svgView_ = nil;
    [super dealloc];
}

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib./*
- (void)loadView {
    CGRect fullScreenRect = [[UIScreen mainScreen] applicationFrame];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:fullScreenRect];
    scrollView.contentSize = fullScreenRect.size;
    
    // do any further configuration to the scroll view
    // add a view, or views, as a subview of the scroll view.
    if (self.svgSourceUrl != nil) {
        SVGRenderer *renderer = [[SVGRenderer alloc] initWithContentsOfURL:self.svgSourceUrl];
        CGRect svgFrame = CGRectMake(0.0, 0.0, fullScreenRect.size.width, fullScreenRect.size.height);
        svgView_ = [[SVGView alloc] initWithFrame:svgFrame];
        
        [svgView_ loadViewUsingSVGRenderer:renderer];
        [renderer release];  
        [scrollView addSubview:svgView_];
    }        
    
    // release scrollView as self.view retains it
    self.view = scrollView;
    [scrollView release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = (UIScrollView *) self.view;
    
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 6.0;
    scrollView.delegate = self;
    
//    if (self.svgSourceUrl != nil) {
//        SVGRenderer *renderer = [[SVGRenderer alloc] initWithContentsOfURL:self.svgSourceUrl];
//        SVGView *svgView = (SVGView *) [self view];
//        
//        [svgView loadViewUsingSVGRenderer:renderer];
//        [renderer release];  
//    }        
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.svgView;
}


@end
