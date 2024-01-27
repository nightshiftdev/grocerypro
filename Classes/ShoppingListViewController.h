//
//  ShoppingListViewController.h
//  GroceryList
//
//  Created by pawel on 8/13/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

#define RENAME_GROCERY_LIST_DIALOG 1

@class GroceryListStateTracker;
@class GroceryListsViewController;

@interface ShoppingListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate> {
	NSMutableDictionary *shoppingItems;
	NSString *groceryListName;
	UITableView *tableView;
	BOOL showPurchased;
	GroceryListStateTracker *tracker;
	GroceryListsViewController *groceryListsController;
	NSMutableDictionary *productsAndCategories;
	NSMutableArray *categories;
}

@property (nonatomic, strong) NSMutableDictionary *shoppingItems;
@property (nonatomic, strong) NSString *groceryListName;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) GroceryListStateTracker *tracker;
@property (nonatomic, strong) GroceryListsViewController *groceryListsController;
@property (nonatomic, strong) NSMutableDictionary *productsAndCategories;
@property (nonatomic, strong) NSMutableArray *categories;
@property BOOL showPurchased;

- (IBAction)showHidePurchasedItems;
- (IBAction)shareShoppingList;
- (IBAction)renameList;
- (void)updateShoppingListItems;
- (void)updateShoppingListItemWithProductName:(NSString *)productName;
- (void)deleteShoppingListItemWithProductName: (NSString *) productName;
- (BOOL)allShoppingListItemsPurchased;
- (void)changeShoppingItemsOwnershipForGroceryList:(NSString *)oldListName withNewName:(NSString *)newListName;
-(void)updateCategories;

@end
