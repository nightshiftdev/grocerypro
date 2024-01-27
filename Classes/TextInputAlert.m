//
//  TextInputAlert.m
//  GroceryList
//
//  Created by pawel on 8/13/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "TextInputAlert.h"
#import "TextUtils.h"


@implementation TextInputAlert
@synthesize textField;
@synthesize enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message label:(NSString*)label text:(NSString*)text delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle  {

	if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil]) {
		UITextField *textInputField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
		[textInputField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self addSubview:textInputField];
		self.textField = textInputField;
		if ([TextUtils isEmpty:text]) {
			self.textField.placeholder = label;
		} else {
			self.textField.text = text;
		}
		textInputField.borderStyle = UITextBorderStyleRoundedRect;
		CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 11.0); 
		[self setTransform:translate];
	}
	return self;
}

- (void)show {
	[textField becomeFirstResponder];
	[super show];
}

- (NSString *)enteredText {
	return textField.text;
}


@end
