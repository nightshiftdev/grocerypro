//
//  TextInputViewController.h
//  GroceryList
//
//  Created by pawel on 1/4/11.
//  Copyright 2011 __etcApps__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextInputViewController : UIViewController <UITextFieldDelegate> {
	UITextField *nameTextField;
	id <RecipeAddDelegate> delegate;
}

@end
