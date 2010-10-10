/*
 *  Utils.c
 *  SVGParser
 *
 *  Created by Kerem Karatal on 10-10-08.
 *  Copyright 2010 Coding Ventures. All rights reserved.
 *
 */
#import "Utils.h"
#import <UIKit/UIKit.h>

CGContextRef CreateBitmapContext (int pixelsWide, int pixelsHigh) {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);// 1
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();// 2
    bitmapData = malloc( bitmapByteCount );// 3
    if (bitmapData == NULL) {
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,// 4
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
    if (context== NULL) {
        free (bitmapData);// 5
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );// 6
	
	// Rotate the context so that it is flipped.
	// In SVG top-left is 0,0; in Quartz bottom-left is 0.0, in iOS top-left is 0,0
	CGContextTranslateCTM(context, 0.0f, pixelsHigh);
	CGContextScaleCTM(context, 1.0f, -1.0f);
		
    return context;// 7
}

void SaveBitmapContextAsFile(CGContextRef context, NSURL *fileUrl) {
	CGImageRef cgImage;
	cgImage = CGBitmapContextCreateImage (context);
	UIImage *image = [UIImage imageWithCGImage:cgImage];
	NSData *imageData = UIImagePNGRepresentation(image);
	
	[imageData writeToURL:fileUrl atomically:YES];
}