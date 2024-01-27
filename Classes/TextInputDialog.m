//
//  TextInputDialog.m
//  GroceryList
//
//  Created by pawel on 11/22/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "TextInputDialog.h"
#import "TextInputAlert.h"


@implementation TextInputDialog

+ (void) displayInputDialogWithTitle:(NSString *) title andTextFieldValue:(NSString *) text andLabel:(NSString *)label andDelegate: (id) delegate andTag: (int) tag {
	TextInputAlert *prompt = [TextInputAlert alloc];
	prompt = [prompt initWithTitle:title message:@"\n\n" label:label text:text delegate:delegate cancelButtonTitle:@"Cancel" okButtonTitle:@"OK"];
	prompt.tag = tag;
	[prompt show];
}

@end
