//
//  TextUtils.m
//  GroceryList
//
//  Created by pawel on 11/30/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "TextUtils.h"


@implementation TextUtils

+ (BOOL)isEmpty:(NSString *)string {
	if (string == nil) {
		return YES;
	}
	
	NSString *trimmedString = [TextUtils trimWhitespace: string];
	if ([trimmedString length] == 0) {
		return YES;
	}
	
	return NO;
}

+ (NSString *)trimWhitespace:(NSString *)string {
	return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
