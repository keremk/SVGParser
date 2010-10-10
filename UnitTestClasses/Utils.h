/*
 *  Utils.h
 *  SVGParser
 *
 *  Created by Kerem Karatal on 10-10-08.
 *  Copyright 2010 Coding Ventures. All rights reserved.
 *
 */

#ifndef UTILS_H_
#define UTILS_H_

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

#define degreesToRadians(x) (M_PI * x / 180.0)

CGContextRef CreateBitmapContext (int pixelsWide, int pixelsHigh);
void SaveBitmapContextAsFile(CGContextRef context, NSURL *fileUrl);

#endif