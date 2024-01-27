//
//  GroceryListStateTracker.m
//  GroceryList
//
//  Created by pawel on 12/26/10.
//  Copyright 2010 etcApps. All rights reserved.
//

#import "GroceryListStateTracker.h"


@implementation GroceryListStateTracker

- (id)init {
	self = [super init];
	if (self) {
		stateTracker = [[NSMutableDictionary alloc] init];
	}
	return self;
}


- (BOOL)isListStateDirty {
	BOOL isListDirty = NO;
	for (NSString* key in stateTracker) {
		NSNumber* value = [stateTracker objectForKey:key];
		if ([value intValue] != 0) {
			isListDirty = YES;
			break;
		}
	}
	return isListDirty;
}

- (void)updateListStateForProductName:(NSString *)productNameKey byStateCount:(int)stateCount {
	NSNumber* value = [stateTracker objectForKey:productNameKey];
	if (value != nil) {
		[stateTracker setObject:[NSNumber numberWithInt:[value intValue] + stateCount] forKey:productNameKey];
	} else {
		[stateTracker setObject:[NSNumber numberWithInt:stateCount] forKey:productNameKey];
	}
}

@end
