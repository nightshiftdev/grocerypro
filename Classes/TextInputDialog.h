//
//  TextInputDialog.h
//  GroceryList
//
//  Created by pawel on 11/22/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextInputDialog : NSObject {
}

+ (void) displayInputDialogWithTitle: (NSString *) title 
				   andTextFieldValue: (NSString *) text 
				   andLabel: (NSString *) label 
				   andDelegate: (id) delegate 
				   andTag: (int) tag;

@end
