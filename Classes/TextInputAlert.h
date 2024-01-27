//
//  TextInputAlert.h
//  GroceryList
//
//  Created by pawel on 8/13/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextInputAlert : UIAlertView 
{
	UITextField	*textField;
}
@property (nonatomic, strong) UITextField *textField;
@property (unsafe_unretained, readonly) NSString *enteredText;
- (id)initWithTitle:(NSString *)title 
			message:(NSString *)message 
			  label:(NSString*)label
			   text:(NSString*)text
		   delegate:(id)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
	  okButtonTitle:(NSString *)okButtonTitle;
@end
