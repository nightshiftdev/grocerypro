//
//  GroceryListStateTracker.h
//  GroceryList
//
//  Created by pawel on 12/26/10.
//  Copyright 2010 etcApps. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GroceryListStateTracker : NSObject {
	NSMutableDictionary *stateTracker;
}

- (id)init;
- (BOOL)isListStateDirty;
- (void)updateListStateForProductName:(NSString *)productNameKey byStateCount:(int)stateCount;

@end
