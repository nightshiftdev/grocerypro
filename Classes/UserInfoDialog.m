//
//  UserInfoDialog.m
//  GroceryList
//
//  Created by pawel on 11/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserInfoDialog.h"


@implementation UserInfoDialog

+ (void) displayInfoDialogWithTitle: (NSString *) title andMessage: (NSString *) message {
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:nil];
	[dialog setTitle:title];
	[dialog setMessage:message];
	[dialog addButtonWithTitle:@"OK"];
	[dialog show];
}

@end
