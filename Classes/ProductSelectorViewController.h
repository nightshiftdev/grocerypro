//
//  ProductSelectorViewController.h
//  GroceryList
//
//  Created by pawel on 8/13/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TableAlertView.h"
#import "CategoryRearrangeView.h"

#define ADD_NEW_PRODUCT_DIALOG 1
#define RENAME_PRODUCT_DIALOG  2
#define DELETE_PRODUCT_DIALOG  3
#define ADD_NEW_PRODUCT_OR_CATEGORY_DIALOG 4
#define ADD_NEW_CATEGORY_DIALOG 5
#define RENAME_CATEGORY_DIALOG  6

@class GroceryListStateTracker;

@interface ProductSelectorViewController : UIViewController <UITableViewDelegate, 
															 UITableViewDataSource, 
															 UIGestureRecognizerDelegate,
															 NSFetchedResultsControllerDelegate,
															 UISearchBarDelegate,
															 UIActionSheetDelegate,
															 UIImagePickerControllerDelegate,
															 UINavigationControllerDelegate,
															 TableAlertViewDelegate,
															 CategoryRearrangeViewDelegate> {
	UITableView *productGridView;															 
	UIToolbar *toolbar;
	UISearchBar *searchBar;
	NSUInteger emptyCellIndex;
	NSMutableDictionary *productsAndCategories;
    NSArray *products;
	NSArray *shoppingItems;
	NSMutableArray *categories;
    NSString *groceryListName;
    UIBarButtonItem *addButton;
	BOOL ascendingPopularitySortOrder;
	BOOL ascendingNameSortOrder;
	BOOL ascendingCategoryNameSortOrder;
	BOOL ascendingSortOrder;
	NSString *sortKey;
	NSString *categorySortKey;
	NSString *originalProductName;
	NSString *originalCategoryName;
	NSString *productToDeleteName;
	NSString *productToChangeIcon;
    GroceryListStateTracker *tracker;
	NSUInteger numOfCols;
    BOOL isShowingCategories;
}

@property (nonatomic, strong) IBOutlet UITableView *productGridView;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSMutableDictionary *productsAndCategories;
@property (nonatomic, strong) NSArray *shoppingItems;
@property (nonatomic, strong) NSMutableArray *categories;
@property (nonatomic, strong) NSString *groceryListName;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property BOOL ascendingPopularitySortOrder;
@property BOOL ascendingNameSortOrder;
@property BOOL ascendingCategoryNameSortOrder;
@property BOOL ascendingSortOrder;
@property (nonatomic, strong) NSString* sortKey;
@property (nonatomic, strong) NSString* categorySortKey;
@property (nonatomic, strong) NSString* originalProductName;
@property (nonatomic, strong) NSString* originalCategoryName;
@property (nonatomic, strong) NSString* productToDeleteName;
@property (nonatomic, strong) NSString* productToChangeIcon;
@property (nonatomic, strong) GroceryListStateTracker *tracker;
@property BOOL isShowingCategories;
@property BOOL ignoreCategorySortKey;

- (void) updateShoppingListItems;
- (void) insertOrUpdateShoppingListItemWithProductName: (NSString *) productName;
- (NSManagedObject *) findShoppingListItemWithProductName: (NSString *) productName;
- (void) insertNewProductWithName: (NSString *) name andUseDefaultIcon: (BOOL) useDefaultIcon;
- (void) updateProducts:(NSString*)sortDescriptorKey andRequestAscendingOrder:(BOOL) sortOrder;
- (void) updateProductPopularity: (NSString *)productName by: (int) changeInPopularity;
- (void) filterProducts:(NSString*)filterName;
- (void) renameProduct: (NSString *) productName withNewName: (NSString *) newName;
- (void) changeProductIcon: (NSString *) productName withNewIcon: (UIImage *) image;
- (void) showImagePicker:(BOOL)hasCamera;
- (int) indexOfItemInMenuItems:(NSArray*)menuItems title:(NSString*)title;
- (NSManagedObject *) productFromProductAndCategoryIndex: (NSInteger) productAndCategoryIndex;
-(void) clearMenuItems;
- (void) removeShoppingListItemWithProductName: (NSString *) productName andRemoveAll: (BOOL) removeAll andApplyToCurrentListOnly:(BOOL) applyToCurrentListOnly;


- (IBAction)showHideCategories;
- (IBAction)sortByName;
- (IBAction) rearrangeCategories;
- (IBAction) sortCategoriesByUserDefinedOrder;

@end
