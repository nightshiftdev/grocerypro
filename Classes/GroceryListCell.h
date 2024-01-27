//
//  GroceryListCell.h
//  GroceryList
//
//  Created by pawel on 29/3/12.
//  Copyright 2012 __etcApps__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObject;

@interface GroceryListCell : UITableViewCell {
    UIImageView *iconImage;
	UILabel *titleLabel;
	UILabel *dateLabel;
}

- (void)setGroceryListItemManagedObject:(NSManagedObject *) groceryListItem;

@end
