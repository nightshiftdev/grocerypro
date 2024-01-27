//
//  StrikethroughView.m
//  GroceryList
//
//  Created by pawel on 12/11/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "StrikethroughView.h"


@implementation StrikethroughView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect bounds = [self bounds];
	float h = bounds.size.height;
	float w = bounds.size.width;
	CGContextRef context = UIGraphicsGetCurrentContext();	
	CGFloat color[4];
	color[0] = 0.5;
	color[1] = 0.5;
	color[2] = 0.5;
	color[3] = 1.0;
	CGContextSetStrokeColor(context, color);
	CGContextSetLineWidth(context, 2.0);
	CGContextMoveToPoint(context, 0, h/2 - 3);
	CGContextAddLineToPoint( context, w, h/2 - 3);
	CGContextStrokePath(context);
}

@end
