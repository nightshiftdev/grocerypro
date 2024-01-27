//
//  ShoppingListCell.h
//  GroceryList
//
//  Created by pawel on 12/5/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObject;
@class StrikethroughView;

@interface ShoppingListCell : UITableViewCell {
    UIImageView *iconImage;
	UIImageView *countBkgImage;
	UILabel *titleLabel;
	UILabel *countLabel;
	StrikethroughView *strikeThroughView;
}

- (void)setShoppingListItemManagedObject:(NSManagedObject *) shoppingListItem;

@end
