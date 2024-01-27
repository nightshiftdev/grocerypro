//
//  UserConfirmationDialog.h
//  GroceryList
//
//  Created by pawel on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserConfirmationDialog : NSObject {
}

+ (void) displayConfirmationDialogWithTitle: (NSString *) title
								 andMessage: (NSString *) message
						        andDelegate: (id) delegate 
							         andTag: (int) tag;

@end
