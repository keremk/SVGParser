//
//  SVGParser.m
//  SVGParser
//
//  Created by Kerem Karatal on 9/26/10.
//  Copyright (c) 2010 Coding Ventures. All rights reserved.
//

#import "SVGParser.h"
#import	<CoreGraphics/CoreGraphics.h>
#import "UIColor-Expanded.h"

typedef enum SVGLineType {
	line,
	horizontal,
	vertical
} SVGLineType;

typedef enum SVGBezierType {
	cubic,
	quad	
} SVGBezierType;

@interface SVGParser()

- (void) initParser;

@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) SVGGroup *currentGroup;

- (void) addMoveToUsingRelative:(BOOL) isRelative toPath:(NSMutableArray *)path usingScanner:(NSScanner *) scanner;
- (void) addLineToOfType:(SVGLineType) lineType 
		   usingRelative:(BOOL) isRelative 
				  toPath:(NSMutableArray *)path 
			usingScanner:(NSScanner *) scanner;
- (void) addBezierCurveWithSharedControlPoint:(BOOL) isShared 
								forBezierType:(SVGBezierType) bezierType
								usingRelative:(BOOL) isRelative 
									   toPath:(NSMutableArray *) path 
								 usingScanner:(NSScanner *)scanner;	
- (void) addEllipticalArcUsingRelative:(BOOL) isRelative 
								toPath:(NSMutableArray *) path 
						  usingScanner:(NSScanner *) scanner;
- (SVGStyle *) handleStyleUsingAttributes:(NSDictionary *) attributes;
- (SVGTransform) handleTransformUsingAttributes:(NSDictionary *) attributes;
- (void) handlePolylinesUsingAttributes:(NSDictionary *) attributes isPolygon:(BOOL) isPolygon;
- (UIColor *) parseColorFromString:(NSString *) colorValue;
@end

@implementation SVGParser
@synthesize xmlParser = xmlParser_;
@synthesize currentGroup = currentGroup_;
@synthesize delegate = delegate_;

- (void) dealloc {
    [xmlParser_ release], xmlParser_ = nil;
    [svgElements_ release], svgElements_ = nil;
    [groups_ release], groups_ = nil;
    [super dealloc];
}


- (id) initWithContentsOfUrl:(NSURL *)url {
	
	self = [super init];
	if (self != nil) {
		xmlParser_ = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
		[self initParser];
	}
	return self;
}

- (id) initWithData:(NSData *)data {
	self = [super init];
	if (self != nil) {
		xmlParser_ = [[NSXMLParser alloc] initWithData:data];
    
		[self initParser];
	}
	return self;
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
            NSString *elementHandlerString = [NSString stringWithFormat:@"handle%@UsingAttributes:", [svgElement capitalizedString]];
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

// Attributes for Path
static NSString *d = @"d";

static NSString *pathCharacters = @"MmLlHhVvCcSsQqTtAaz";
static NSString *arcDirCharacters = @"01?";


- (void) handlePathUsingAttributes:(NSDictionary *) attributes {
	SVGStyle *style = [self handleStyleUsingAttributes:attributes];
	SVGTransform transform = [self handleTransformUsingAttributes:attributes];
	NSString *dataString = [attributes objectForKey:d];
	NSUInteger stringLen = [dataString length] + 1;
	
	char *dataStringBuffer = (char *) malloc(sizeof(char) * stringLen);
	BOOL bufOk = [dataString getCString:dataStringBuffer maxLength:stringLen encoding:NSUTF8StringEncoding];
	if (bufOk) {		
		NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:pathCharacters];
		NSArray *pathElementStrings = [dataString componentsSeparatedByCharactersInSet:charSet];
		
		NSMutableCharacterSet *charsToBeSkipped = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet]; 
		[charsToBeSkipped addCharactersInString:@","];

		NSInteger numOfPathElements = [pathElementStrings count];
		NSInteger stringIndex = 0;
		
		NSMutableArray *path = [[NSMutableArray alloc] init];
		
		previousCubicControlPoint_ = CGPointZero;
		previousQuadraticControlPoint_ = CGPointZero;
		curPoint_ = CGPointZero;
		initialPoint_ = CGPointZero;
		isTherePreviousCubicControlPoint_ = NO;
		isTherePreviousQuadraticControlPoint_ = NO;
		for (NSInteger i = 0; i < numOfPathElements - 1; i++) {
			char pathChar = dataStringBuffer[stringIndex];
			NSString *pathElementString = [pathElementStrings objectAtIndex:(i + 1)];
			
			BOOL isRelative = NO;
			NSScanner *scanner = [NSScanner scannerWithString:pathElementString];
			[scanner setCharactersToBeSkipped:charsToBeSkipped];
			SVGLineType lineType;
			BOOL isShared;
			
			switch (pathChar) {
				case 'z':
					;
					SVGPathElement *pathElement = [[SVGPathElement alloc] init];
					pathElement.initialPoint = initialPoint_;
					pathElement.toPoint = curPoint_;
					pathElement.elementType = SVGClosePath;
					
					[path addObject:pathElement];
					[pathElement release];
					break;
				case 'm':
					if (i != 0) {
						// As per SVG spec, if relative moveto is encountered as first element of a path
						// it is treated as an absolute moveto
						isRelative = YES;
					}
				case 'M':
					[self addMoveToUsingRelative:isRelative toPath:path usingScanner:scanner];
					break;
				case 'l':
				case 'h':
				case 'v':
					isRelative = YES;
				case 'L':
				case 'H':
				case 'V': 
					if (pathChar == 'l' || pathChar == 'L') {
						lineType = line;
					} else if (pathChar == 'h' || pathChar == 'H') {
						lineType = horizontal;
					} else if (pathChar == 'v' || pathChar == 'V') {
						lineType = vertical;
					}
					
					[self addLineToOfType:lineType 
							usingRelative:isRelative 
								   toPath:path
							 usingScanner:scanner];
					
					break;
				case 'c':
				case 's':
					isRelative = YES;
				case 'C':
				case 'S':
					isShared = NO;
					if (pathChar == 's' || pathChar == 'S') {
						isShared = YES;
					}
					
					[self addBezierCurveWithSharedControlPoint:isShared 
												 forBezierType:cubic
												 usingRelative:isRelative 
														toPath:path 
												  usingScanner:scanner];
					break;
				case 'q':
				case 't':
					isRelative = YES;
				case 'Q':
				case 'T':
					isShared = NO;
					if (pathChar == 't' || pathChar == 'T') {
						isShared = YES;
					}
					
					[self addBezierCurveWithSharedControlPoint:isShared 
												 forBezierType:quad 
												 usingRelative:isRelative 
														toPath:path 
												  usingScanner:scanner];
					
				case 'a':
					isRelative = YES;
				case 'A':	
					
					[self addEllipticalArcUsingRelative:isRelative 
												 toPath:path 
										   usingScanner:scanner];
					break;
				default:
					break;
			}
			stringIndex += [pathElementString length] + 1; // +1 for the command
			
		}
		[delegate_ parser:self didFoundPath:path usingStyle:style usingTransform:transform];
//		[delegate_ performSelector:@selector(parser:didFoundPath:) withObject:self withObject:path];
		[path release];
		free(dataStringBuffer);
    }
	return;
}

- (void) addMoveToUsingRelative:(BOOL) isRelative toPath:(NSMutableArray *)path usingScanner:(NSScanner *) scanner{
	CGPoint toPoint;
	NSUInteger iteration = 0;
	while ([scanner isAtEnd] == NO) {
		if ([scanner scanFloat:&toPoint.x] && [scanner scanFloat:&toPoint.y])  {
			if (isRelative) {
				toPoint.x = curPoint_.x + toPoint.x;
				toPoint.y = curPoint_.y + toPoint.y;
			}
			
			SVGPathElement *pathElement = [[SVGPathElement alloc] init];
			// As per SVG spec, if there are additional points following moveto, then they are
			// assumed to be lineto points
			if (iteration > 0) {
				pathElement.elementType = SVGLineTo;
			} else {
				pathElement.elementType = SVGMoveTo;
				initialPoint_ = toPoint;
			}
			pathElement.toPoint = toPoint;
			[path addObject:pathElement];
			[pathElement release];
			curPoint_ = toPoint;
		}
		iteration++;
	}
	isTherePreviousCubicControlPoint_ = NO;
	isTherePreviousQuadraticControlPoint_ = NO;
}

- (void) addLineToOfType:(SVGLineType) lineType usingRelative:(BOOL) isRelative 
				  toPath:(NSMutableArray *)path usingScanner:(NSScanner *) scanner {
	CGPoint toPoint = CGPointZero;
	while ([scanner isAtEnd] == NO) {
		CGPoint offsetPoint = CGPointZero;
		if (isRelative) {
			offsetPoint = curPoint_;
		}
		BOOL isSuccessfullyParsed = NO;
		switch (lineType) {
			case line:
				if ([scanner scanFloat:&toPoint.x] && [scanner scanFloat:&toPoint.y])  {
					toPoint.x = offsetPoint.x + toPoint.x;
					toPoint.y = offsetPoint.y + toPoint.y;
					isSuccessfullyParsed = YES;
				}
				break;
			case horizontal:
				if ([scanner scanFloat:&toPoint.x]) {
					toPoint.x = offsetPoint.x + toPoint.x;
					toPoint.y = curPoint_.y;
					isSuccessfullyParsed = YES;
				}
				break;
			case vertical:
				if ([scanner scanFloat:&toPoint.y]) {
					toPoint.x = curPoint_.x;
					toPoint.y = offsetPoint.x + toPoint.y;
					isSuccessfullyParsed = YES;
				}
				break;
			default:
				break;
		}
		
		if (isSuccessfullyParsed) {			
			SVGPathElement *pathElement = [[SVGPathElement alloc] init];
			pathElement.elementType = SVGLineTo;
			pathElement.toPoint = toPoint;
			[path addObject:pathElement];
			[pathElement release];
			curPoint_ = toPoint;
		}
	}
	isTherePreviousCubicControlPoint_ = NO;
	isTherePreviousQuadraticControlPoint_ = NO;
	
}

- (void) addBezierCurveWithSharedControlPoint:(BOOL) isShared 
								forBezierType:(SVGBezierType) bezierType
								usingRelative:(BOOL) isRelative 
									   toPath:(NSMutableArray *) path 
								 usingScanner:(NSScanner *)scanner {

	CGPoint controlPoint1, controlPoint2, toPoint;
	while ([scanner isAtEnd] == NO) {
		CGPoint offsetPoint = CGPointZero;
		if (isRelative) {
			offsetPoint = curPoint_;
		}
		BOOL isSuccessfullyParsed = NO;
		if (isShared) {
			// Shared control point is a reflection of the second control point relative to current point
			// If no previous control point, then first control point is coincident with current point
			
			BOOL isTherePreviousControlPoint = (bezierType == cubic) ? isTherePreviousCubicControlPoint_ : isTherePreviousQuadraticControlPoint_;
			CGPoint previousControlPoint = (bezierType == cubic) ? previousCubicControlPoint_ : previousQuadraticControlPoint_;
			
			if (isTherePreviousControlPoint) {
				CGFloat dist = curPoint_.x - previousControlPoint.x;
				controlPoint1.x = curPoint_.x + dist;
				dist = curPoint_.y - previousControlPoint.y;
				controlPoint1.y = curPoint_.y + dist;
			} else {
				controlPoint1.x = curPoint_.x;
				controlPoint1.y = curPoint_.y;
			}			
			isSuccessfullyParsed = YES;
		} else {
			if ([scanner scanFloat:&controlPoint1.x] &&
				[scanner scanFloat:&controlPoint1.y] ) {
				isSuccessfullyParsed = YES;
				controlPoint1.x += offsetPoint.x;
				controlPoint1.y += offsetPoint.y;
				
			}
		}
		
		if (isSuccessfullyParsed) {
			if (bezierType == cubic) {
				isSuccessfullyParsed = NO;
				if ([scanner scanFloat:&controlPoint2.x] &&
					[scanner scanFloat:&controlPoint2.y]) {
					isSuccessfullyParsed = YES;
				} 
			}
			if (isSuccessfullyParsed) {
				if ([scanner scanFloat:&toPoint.x] &&
					[scanner scanFloat:&toPoint.y]) {
					
					controlPoint2.x += offsetPoint.x;
					controlPoint2.y += offsetPoint.y;
					toPoint.x += offsetPoint.x;
					toPoint.y += offsetPoint.y;
					
					SVGPathElement *pathElement = [[SVGPathElement alloc] init];
					pathElement.toPoint = toPoint;
					pathElement.controlPoint1 = controlPoint1;
					if (bezierType == cubic) {
						pathElement.elementType = SVGCubicBezier;
						pathElement.controlPoint2 = controlPoint2;
						previousCubicControlPoint_ = controlPoint2;
						isTherePreviousCubicControlPoint_ = YES;
						isTherePreviousQuadraticControlPoint_ = NO;
					} else {
						pathElement.elementType = SVGQuadBezier;
						isTherePreviousQuadraticControlPoint_ = YES;
						isTherePreviousCubicControlPoint_ = NO;
						previousQuadraticControlPoint_ = controlPoint1;
					}

					[path addObject:pathElement];
					[pathElement release];
					
					curPoint_ = toPoint;
				}
			}
		}
	}	
}

- (void) addEllipticalArcUsingRelative:(BOOL) isRelative 
								toPath:(NSMutableArray *) path 
						  usingScanner:(NSScanner *) scanner {	
	CGFloat radiusX, radiusY;
	CGPoint toPoint;
	CGFloat xAxisRotation;
	NSString *largeArcFlagString;
	NSString *sweepFlagString;
	
	NSCharacterSet *arcDirCharSet = [NSCharacterSet characterSetWithCharactersInString:arcDirCharacters];

	while ([scanner isAtEnd] == NO) {
		CGPoint offsetPoint = CGPointZero;
		if (isRelative) {
			offsetPoint = curPoint_;
		}
		if ([scanner scanFloat:&radiusX] &&
			[scanner scanFloat:&radiusY] &&
			[scanner scanFloat:&xAxisRotation] &&
			[scanner scanCharactersFromSet:arcDirCharSet intoString:&largeArcFlagString] &&
			[scanner scanCharactersFromSet:arcDirCharSet intoString:&sweepFlagString] &&
			[scanner scanFloat:&toPoint.x] && 
			[scanner scanFloat:&toPoint.y] ){
			
			toPoint.x += offsetPoint.x;
			toPoint.y += offsetPoint.y;
			
			SVGLargeArcFlag largeArcFlag;
			if ([largeArcFlagString isEqualToString:@"0"]) {
				largeArcFlag = largeArcOff;
			} else if ([largeArcFlagString isEqualToString:@"1"]) {
				largeArcFlag = largeArcOn;
			} else if ([largeArcFlagString isEqualToString:@"?"]) {
				largeArcFlag = largeArcBoth;
			}
				
			SVGSweepFlag sweepFlag;
			if ([sweepFlagString isEqualToString:@"0"]) {
				sweepFlag = sweepOff;
			} else if ([sweepFlagString isEqualToString:@"1"]){
				sweepFlag = sweepOn;
			} else if ([sweepFlagString isEqualToString:@"?"]) {
				sweepFlag = sweepBoth;
			}
			
			SVGPathElement *pathElement = [[SVGPathElement alloc] init];
			pathElement.toPoint = toPoint;
			pathElement.radiusX = radiusX;
			pathElement.radiusY = radiusY;
			pathElement.xAxisRotation = xAxisRotation;
			pathElement.largeArcFlag = largeArcFlag;
			pathElement.sweepFlag = sweepFlag;
			
//			SVGPathElement pathElement;
//			NSValue *pathElementValue = [NSValue value:&pathElement withObjCType:@encode(pathElement)];
//			
//			SVGPathElement pathElement2;
//			[pathElementValue getValue:&pathElement2];
			
			[path addObject:pathElement];
			[pathElement release];
			
			curPoint_ = toPoint;
		}
	}
	
}

- (void) handleRectUsingAttributes:(NSDictionary *) attributes {
	SVGStyle *style = [self handleStyleUsingAttributes:attributes];
	SVGTransform transform = [self handleTransformUsingAttributes:attributes];
    	
	CGFloat xCoord = [[attributes objectForKey:@"x"] floatValue];
	CGFloat yCoord = [[attributes objectForKey:@"y"] floatValue];
	CGFloat width = [[attributes objectForKey:@"width"] floatValue];
	CGFloat height = [[attributes objectForKey:@"height"] floatValue];

	SVGRect svgRect;
	svgRect.rect = CGRectMake(xCoord, yCoord, width, height);;

	NSString *radiusString = [attributes objectForKey:@"rx"];
	if (nil == radiusString) {
		svgRect.radiusX = 0.0f;
	} else {
		svgRect.radiusX = [radiusString floatValue];
	}
	radiusString = [attributes objectForKey:@"ry"];
	if (nil == radiusString) {
		svgRect.radiusY	= 0.0f;
	} else {
		svgRect.radiusY = [radiusString floatValue];
	}

	[delegate_ parser:self didFoundRect:svgRect usingStyle:style usingTransform:transform];
}

- (void) handleCircleUsingAttributes:(NSDictionary *) attributes {
	SVGStyle *style = [self handleStyleUsingAttributes:attributes];
	SVGTransform transform = [self handleTransformUsingAttributes:attributes];
   
	CGFloat centerX = [[attributes objectForKey:@"cx"] floatValue];
	CGFloat centerY = [[attributes objectForKey:@"cy"] floatValue];

	SVGCircle svgCircle;
	svgCircle.center = CGPointMake(centerX, centerY);
	svgCircle.radius = [[attributes objectForKey:@"r"] floatValue];
	
	[delegate_ parser:self didFoundCircle:svgCircle usingStyle:style usingTransform:transform];
}

- (void) handleEllipseUsingAttributes:(NSDictionary *) attributes {
	SVGStyle *style = [self handleStyleUsingAttributes:attributes];
	SVGTransform transform = [self handleTransformUsingAttributes:attributes];

	CGFloat centerX = [[attributes objectForKey:@"cx"] floatValue];
	CGFloat centerY = [[attributes objectForKey:@"cy"] floatValue];

	SVGEllipse svgEllipse;
	svgEllipse.center = CGPointMake(centerX, centerY);
	svgEllipse.radiusX = [[attributes objectForKey:@"rx"] floatValue];
	svgEllipse.radiusX = [[attributes objectForKey:@"ry"] floatValue];

	[delegate_ parser:self didFoundEllipse:svgEllipse usingStyle:style usingTransform:transform];		
}

- (void) handleLineUsingAttributes:(NSDictionary *) attributes {
	SVGStyle *style = [self handleStyleUsingAttributes:attributes];
	SVGTransform transform = [self handleTransformUsingAttributes:attributes];

	CGFloat startX = [[attributes objectForKey:@"x1"] floatValue];
	CGFloat startY = [[attributes objectForKey:@"y1"] floatValue];
	CGFloat endX = [[attributes objectForKey:@"x2"] floatValue];
	CGFloat endY = [[attributes objectForKey:@"y2"] floatValue];
	
	SVGLine svgLine;
	svgLine.start = CGPointMake(startX, startY);
	svgLine.end = CGPointMake(endX, endY);
	
	[delegate_ parser:self didFoundLine:svgLine usingStyle:style usingTransform:transform];		
}

- (void) handlePolylineUsingAttributes:(NSDictionary *) attributes {
	[self handlePolylinesUsingAttributes:attributes isPolygon:NO];
}

- (void) handlePolygonUsingAttributes:(NSDictionary *) attributes {
	[self handlePolylinesUsingAttributes:attributes isPolygon:YES];
}

- (void) handlePolylinesUsingAttributes:(NSDictionary *) attributes isPolygon:(BOOL) isPolygon {
	SVGStyle *style = [self handleStyleUsingAttributes:attributes];
	SVGTransform transform = [self handleTransformUsingAttributes:attributes];
	NSMutableArray *polyline = [NSMutableArray array];
	
	NSString *pointsString = [attributes objectForKey:@"points"];
	NSScanner *scanner = [NSScanner scannerWithString:pointsString];
	NSMutableCharacterSet *charsToBeSkipped = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet]; 
	[charsToBeSkipped addCharactersInString:@","];
	[scanner setCharactersToBeSkipped:charsToBeSkipped];
	
	CGPoint point = CGPointZero;
	while ([scanner isAtEnd] == NO) {
		if ([scanner scanFloat:&point.x] && [scanner scanFloat:&point.y])  {
			NSValue *pointValue = [NSValue valueWithCGPoint:point];
			[polyline addObject:pointValue];
		}
	}
	
	if (isPolygon) {
		[delegate_ parser:self didFoundPolygon:polyline usingStyle:style usingTransform:transform];			
	} else {
		[delegate_ parser:self didFoundPolyline:polyline usingStyle:style usingTransform:transform];					
	}
}

- (void) handleImageUsingAttributes:(NSDictionary *) attributes {
    
}

- (SVGStyle *) handleStyleUsingAttributes:(NSDictionary *) attributes {
	NSMutableArray *styleValues;
	NSMutableArray *styleAttributes;
	NSString *notFound = @"not-found";
	SVGStyle *style = [[[SVGStyle alloc] init] autorelease];

	NSString *styleString = [attributes objectForKey:@"style"];
	if (styleString == nil) {
		styleAttributes = [NSArray arrayWithObjects:@"fill", @"stroke", 
						   @"stroke-width", @"stroke-linecap", @"stroke-linejoin", 
						   @"stroke-miterlimit", nil];		
		styleValues = [attributes objectsForKeys:styleAttributes notFoundMarker:notFound];
	} else {
		styleValues = [NSMutableArray array];
		styleAttributes = [NSMutableArray array];
		NSArray *stylesMentionedInString = [styleString componentsSeparatedByString:@";"];
		for (NSString *styleString in stylesMentionedInString) {
			NSArray *comps = [styleString componentsSeparatedByString:@":"];
			if ([comps count] == 2) {
				[styleAttributes addObject:[comps objectAtIndex:0]];
				[styleValues addObject:[comps objectAtIndex:1]];
			}
		}
	}

	NSUInteger count = [styleAttributes count];
	for (NSInteger i = 0; i < count; i++) {
		NSString *styleName = [styleAttributes objectAtIndex:i];
		NSString *styleValue = [styleValues objectAtIndex:i];
		
		if (![styleValue isEqualToString:notFound]) { 
			if ([styleName isEqualToString:@"fill"]) {
				style.fillColor = [self parseColorFromString:styleValue];
			} else if ([styleName isEqualToString:@"stroke"]) {
				style.strokeColor = [self parseColorFromString:styleValue];
			} else if ([styleName isEqualToString:@"stroke-width"]) {
				style.strokeWidth = [styleValue floatValue];
			} else if ([styleName isEqualToString:@"stroke-linecap"]) {
				if ([styleValue isEqualToString:@"butt"]) {
					style.strokeLineCap = LineCapButt;
				} else if ([styleValue isEqualToString:@"round"]) {
					style.strokeLineCap = LineCapRound;
				} else if ([styleValue isEqualToString:@"square"]) {
					style.strokeLineCap	= LineCapSquare;
				}
			} else if ([styleName isEqualToString:@"stroke-linejoin"]) {
				if ([styleValue isEqualToString:@"miter"]) {
					style.strokeLineJoin = LineJoinMiter;
				} else if ([styleValue isEqualToString:@"round"]) {
					style.strokeLineJoin = LineJoinRound;
				} else if ([styleValue isEqualToString:@"bevel"]) {
					style.strokeLineJoin = LineJoinBevel;
				}				
			} else if ([styleName isEqualToString:@"stroke-miterlimit"]) {
				style.strokeMiterLimit = [styleValue floatValue];
			}	
		}
	}
	
	return style;
}

- (UIColor *) parseColorFromString:(NSString *) colorValue {
	UIColor *color;
	NSScanner *scanner = [NSScanner scannerWithString:colorValue];
	if ([scanner scanString:@"none" intoString:NULL]) {
		color = [UIColor clearColor];
	} else {
		color = [UIColor colorWithName:colorValue];
		if (color == nil) {
			color = [UIColor colorWithHexString:colorValue];
		}
	}
	return color;
}

#define NUM_MATRIX_ELEMS 6

- (SVGTransform) handleTransformUsingAttributes:(NSDictionary *) attributes {
	SVGTransform transform;
	transform.transformType = none;
	BOOL parsingError = NO;

	NSString *transformString = [attributes objectForKey:@"transform"];
	if (nil != transformString) {
		NSScanner *scanner = [NSScanner scannerWithString:transformString];
		NSMutableCharacterSet *charsToBeSkipped = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet]; 
		[charsToBeSkipped addCharactersInString:@",()"];
		[scanner setCharactersToBeSkipped:charsToBeSkipped];
		if ([scanner scanString:@"matrix" intoString:NULL]) {
			for (NSInteger i = 0; i < NUM_MATRIX_ELEMS; i++) {
				transform.transformType = matrix;
				if (![scanner scanFloat:&transform.matrixValues_[i]]) {
					parsingError = YES;
				}
			}
		} else if ([scanner scanString:@"translate" intoString:NULL]){
			if (![scanner scanFloat:&transform.translateX]) {
				parsingError = YES;
			}
			if (![scanner scanFloat:&transform.translateY]) {
				transform.translateY = 0.0f;
			}			
			transform.transformType = translate;
		} else if ([scanner scanString:@"scale" intoString:NULL]){
			if (![scanner scanFloat:&transform.scaleX]) {
				parsingError = YES;
			}
			if (![scanner scanFloat:&transform.scaleY]) {
				transform.scaleY = transform.scaleX;
			}			
			transform.transformType = scale;
		} else if ([scanner scanString:@"rotate" intoString:NULL]) {
			if (![scanner scanFloat:&transform.rotateAngle]) {
				parsingError = YES;
			}
			transform.rotateAroundOrigin = NO;
			if (!([scanner scanFloat:&transform.rotateCenter.x] && [scanner scanFloat:&transform.rotateCenter.y])) {
				transform.rotateAroundOrigin = YES;
			}			
			transform.transformType = rotate;
		} else if ([scanner scanString:@"skewX" intoString:NULL]) {
			if (![scanner scanFloat:&transform.skewAngle]) {
				parsingError = YES;
			}
			transform.transformType = skewX;
		} else if ([scanner scanString:@"skewY" intoString:NULL]) {
			if (![scanner scanFloat:&transform.skewAngle]) {
				parsingError = YES;
			}
			transform.transformType = skewY;
		} 


	}
	if (parsingError) {
		transform.transformType = none;
	}
	return transform;
}

@end
