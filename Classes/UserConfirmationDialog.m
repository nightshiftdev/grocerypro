//
//  UserConfirmationDialog.m
//  GroceryList
//
//  Created by pawel on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserConfirmationDialog.h"


@implementation UserConfirmationDialog

+ (void) displayConfirmationDialogWithTitle: (NSString *) title andMessage: (NSString *) message andDelegate: (id) delegate andTag: (int) tag {
	UIAlertView* dialog = [[UIAlertView alloc] init];
	dialog.tag = tag;
	[dialog setDelegate:delegate];
	[dialog setTitle:title];
	[dialog setMessage:message];
	[dialog addButtonWithTitle:@"Cancel"];
	[dialog addButtonWithTitle:@"OK"];
	[dialog show];
}

@end
