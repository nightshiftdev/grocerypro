//
//  GroceryListsViewController.h
//  GroceryList
//
//  Created by pawel on 8/10/10.
//  Copyright __etcApps__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ADD_GROCERY_LIST_DIALOG 1
#define DELETE_GROCERY_LIST_DIALOG 2

@interface GroceryListsViewController : UIViewController <UITableViewDelegate, 
														  UITableViewDataSource> {
	UIBarButtonItem *addButtonItem;
	UITableView *tableView;
	BOOL ascendingDateSortOrder;
	BOOL ascendingNameSortOrder;
	BOOL ascendingSortOrder;
	UITextField *nameField;
	NSMutableArray *fetchedGroceryLists;
	NSString *sortKey;
    NSString *listToBeDeleted;
}
@property (nonatomic, strong) NSMutableArray *fetchedGroceryLists;
@property (nonatomic, strong) UIBarButtonItem *addButtonItem;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property BOOL ascendingDateSortOrder;
@property BOOL ascendingNameSortOrder;
@property BOOL ascendingSortOrder;
@property (nonatomic, strong) NSString* sortKey;
@property (nonatomic, strong) NSString* listToBeDeleted;

- (IBAction)sortByDate;
- (IBAction)sortByName;
- (IBAction)stickyET;
- (void)updateGroceryListsArray:(NSString*)sortDescriptorKey andRequestAscendingOrder:(BOOL) ascendingSortOrder;
- (void)deleteGroceryList: (NSString *) groceryListName;
- (void)deleteAllShoppingListItemsForGroceryList:(NSString *)groceryListName;
- (void)handleAllItemsPurchased:(NSString *)groceryListName;
- (void)changePurchaseStateForGroceryList:(NSString *)groceryListName withNewState:(BOOL)newState;

@end
