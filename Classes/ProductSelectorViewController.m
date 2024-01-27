//
//  ProductSelectorViewController.m
//  GroceryList
//
//  Created by pawel on 8/13/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "ProductSelectorViewController.h"
#import "ProductCell.h"
#import "GroceryListAppDelegate.h"
#import "TextInputDialog.h"
#import "TextInputAlert.h"
#import "UserInfoDialog.h"
#import "UserConfirmationDialog.h"
#import "TextUtils.h"
#import "GroceryListStateTracker.h"
#import "CoreDataUtils.h"
#import "ProductSelectorRowCell.h"
#import "Product.h"
#import "CategoryRearrangeView.h"

#pragma mark -
#pragma mark ProductMenuItem


@interface ProductMenuItem : UIMenuItem {
}
@property NSUInteger index;
@end

@implementation ProductMenuItem
@synthesize index;
@end

#pragma mark -
#pragma mark ProductSelectorViewController

@implementation ProductSelectorViewController

@synthesize searchBar;
@synthesize toolbar;
@synthesize productGridView;
@synthesize products;
@synthesize productsAndCategories;
@synthesize shoppingItems;
@synthesize categories;
@synthesize groceryListName;
@synthesize addButton;
@synthesize ascendingPopularitySortOrder;
@synthesize ascendingNameSortOrder;
@synthesize ascendingCategoryNameSortOrder;
@synthesize ascendingSortOrder;
@synthesize sortKey;
@synthesize categorySortKey;
@synthesize originalProductName;
@synthesize originalCategoryName;
@synthesize productToDeleteName;
@synthesize productToChangeIcon;
@synthesize tracker;
@synthesize isShowingCategories;
@synthesize ignoreCategorySortKey;

#pragma mark -
#pragma mark View lifecycle

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad {	
	[super viewDidLoad];
	
	emptyCellIndex = NSNotFound;
    numOfCols = 4;
	
    self.view.autoresizesSubviews = YES;
	
	productGridView.backgroundColor = [UIColor blackColor];
	productGridView.separatorStyle = UITableViewCellSeparatorStyleNone;
	
	categories = [[NSMutableArray alloc] init];
	productsAndCategories = [[NSMutableDictionary alloc] init];
	
	self.addButton = [[UIBarButtonItem alloc]
						initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
						target:self 
						action:@selector(addButtonWasPressed)];
	self.navigationItem.rightBarButtonItem = self.addButton;
	
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	
	self.sortKey = @"productName";
	self.ascendingSortOrder = YES;
	self.ascendingNameSortOrder = self.ascendingSortOrder;
	self.ascendingPopularitySortOrder = self.ascendingSortOrder;
	self.categorySortKey = @"categoryName";
	self.ascendingCategoryNameSortOrder = YES;
	self.isShowingCategories = YES;
	self.ignoreCategorySortKey = YES;
	
	self.originalProductName = nil;
	self.productToDeleteName = nil;
	self.productToChangeIcon = nil;
	self.originalCategoryName = nil;
	
	self.tracker = [[GroceryListStateTracker alloc] init];
	
	[self updateProducts:self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self updateShoppingListItems];
}

- (void)viewWillAppear:(BOOL)animated {
	[productGridView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([self.tracker isListStateDirty]) {
		[CoreDataUtils updateGroceryListDateModified:self.groceryListName];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		return YES;
	} else {
		return NO;
	}
}


#pragma mark -
#pragma mark UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (isShowingCategories) {
		return [categories count];
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *productsInSection = nil;
	if (isShowingCategories) {
		NSString *categoryName = [[categories objectAtIndex:section] valueForKey:@"categoryName"];
		productsInSection = [productsAndCategories allKeysForObject:categoryName];
	} else {
		productsInSection = [productsAndCategories allKeys];
	}
	
	if ([productsInSection count] > numOfCols) {
		int numOfRows = [productsInSection count]/numOfCols;
		int rest = [productsInSection count]%numOfCols;
		if (rest > 0) {
			numOfRows++;
		}
		return numOfRows;
	} else if([productsInSection count] > 0) {
		return 1;
	} else {
		return 0;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {  
	return CELL_SIZE;
} 

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (isShowingCategories) {
		NSString *sectionTitle = [[categories objectAtIndex:section] valueForKey:@"categoryName"];
		return sectionTitle;
	} else {
		return @"all products";
	}
}

#pragma mark -
#pragma mark GridView Data Source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"CellIdentifier";
	ProductSelectorRowCell *cell = (ProductSelectorRowCell *)[productGridView dequeueReusableCellWithIdentifier: CellIdentifier];
	if ( cell == nil ) {
		cell = [[ProductSelectorRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier andNumberOfCols:numOfCols];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	int section = [indexPath section];
	NSString *categoryName = [[categories objectAtIndex:section] valueForKey:@"categoryName"];
	NSUInteger pos = [indexPath row];
	NSUInteger posIndex = pos * numOfCols;
	NSUInteger count = 0;
	NSArray *productsInSection = nil;
	if (isShowingCategories) {
		productsInSection = [productsAndCategories allKeysForObject:categoryName];
		NSMutableArray *productRowItems = [[NSMutableArray alloc] init];
		while (posIndex + count < [productsInSection count] && count < numOfCols) {
			NSManagedObject *product = [CoreDataUtils findProduct:[productsInSection objectAtIndex:posIndex + count]];
			count++;
			[productRowItems addObject: product];
		}
		[cell setProducts:productRowItems];
	} else {
		NSMutableArray *productRowItems = [[NSMutableArray alloc] init];
		while (posIndex + count < [products count] && count < numOfCols) {
			NSManagedObject *product = [products objectAtIndex:posIndex + count];
			count++;
			[productRowItems addObject: product];
		}
		[cell setProducts:productRowItems];
	}
	
	NSArray *cells = [cell getProductCells];
	for (int i = 0; i < [cells count]; i++) {
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[[cells objectAtIndex:i] addGestureRecognizer:tapRecognizer];
		UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
		[[cells objectAtIndex:i] addGestureRecognizer:longPressRecognizer];        
		ProductCell *productCell = [cells objectAtIndex:i];
		int productIndexAndCategory = (((posIndex + i) << 16) | (section & 0xffff));
		
		productCell.tag = productIndexAndCategory;
		NSManagedObject *item = [self findShoppingListItemWithProductName: productCell.title];
		if (item != nil) {
			UIImage *image = [UIImage imageNamed:@"product_count_bkg.png"];
			productCell.countBkgIcon = image;
			productCell.count = [NSString stringWithFormat: @"%d", [(NSNumber *)[item valueForKey:@"purchaseCount"] intValue]];
		} else {
			productCell.countBkgIcon = nil;
			productCell.count = nil;
		}
	}	
    return cell;	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Products

- (void) insertNewProductWithName: (NSString *) name andUseDefaultIcon: (BOOL) useDefaultIcon  {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSManagedObject *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext: context];
	[product setValue:name forKey:@"productName"];
	[product setValue:@"other" forKey:@"categoryName"];
	NSString *iconName;
	if (!useDefaultIcon) {
		iconName = [NSString stringWithFormat:@"%@.png", name];
		int iconNameLength = [iconName length];
		NSRange range;
		range.location = 0;
		range.length = iconNameLength;
		iconName = [iconName stringByReplacingOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:range];
		[product setValue:[NSNumber numberWithBool:NO] forKey:@"isUserCreated"];
	} else {
		iconName = @"default_product_icon.png";
		[product setValue:[NSNumber numberWithBool:YES] forKey:@"isUserCreated"];
	}
	[product setValue:iconName forKey:@"productIconName"];
	[product setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
	[CoreDataUtils saveChanges];
}

-(void)updateCategories:(NSString*)sortDescriptorKey andRequestAscendingOrder:(BOOL) sortOrder {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	if (self.ignoreCategorySortKey == NO) { 
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortDescriptorKey ascending:sortOrder];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
	}
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	if (self.categories != nil &&
		[self.categories count] > 0) {
		[self.categories removeAllObjects];
	}
	[self.categories addObjectsFromArray:[context executeFetchRequest:fetchRequest error:&error]];
}

- (void) updateProducts:(NSString*)sortDescriptorKey andRequestAscendingOrder:(BOOL) sortOrder {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortDescriptorKey ascending:sortOrder];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	self.products = [context executeFetchRequest:fetchRequest error:&error];
	
	if (self.productsAndCategories != nil &&
		[self.productsAndCategories count] > 0) {
		[self.productsAndCategories removeAllObjects];
	}
	for (int productIndex = 0; productIndex < [self.products count]; productIndex++) {
		NSManagedObject *product = [self.products objectAtIndex: productIndex];
		NSString *productName = [product valueForKey:@"productName"];
		NSString *categoryName = nil;
		if (isShowingCategories) {
			categoryName = [product valueForKey:@"categoryName"];
		} else {
			categoryName = @"all products";
		}
		[self.productsAndCategories setValue:categoryName forKey:productName];
	}
	
	[self updateCategories:self.categorySortKey andRequestAscendingOrder:sortOrder];
	
	if ([self.products count] > 0) {
		[self.productGridView setHidden:NO];
	} else {
		[self.productGridView setHidden:YES];
	}
}

- (void) filterProducts: (NSString*)filterName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext: context];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY productName CONTAINS[c] %@", filterName];
	[fetchRequest setPredicate:predicate];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	self.products = [context executeFetchRequest:fetchRequest error:&error];
	
	if (self.productsAndCategories != nil &&
		[self.productsAndCategories count] > 0) {
		[self.productsAndCategories removeAllObjects];
	}
	for (int productIndex = 0; productIndex < [self.products count]; productIndex++) {
		NSManagedObject *product = [self.products objectAtIndex: productIndex];
		NSString *productName = [product valueForKey:@"productName"];
		NSString *categoryName = [product valueForKey:@"categoryName"];
		[self.productsAndCategories setValue:categoryName forKey:productName];
	}
	
	[self updateCategories:self.categorySortKey andRequestAscendingOrder:self.ascendingCategoryNameSortOrder];
	
	if ([self.products count] <= 0) {
		[self.productGridView setHidden:YES];
	} else {
		[self.productGridView setHidden:NO];
	}
}

- (void) updateProductPopularity: (NSString *)productName by: (int) changeInPopularity {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Product" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productName LIKE %@", productName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		int popularity = [(NSNumber *)[item valueForKey:@"priority"] intValue];
		popularity = popularity + changeInPopularity;
		[item setValue:[NSNumber numberWithInt:popularity] forKey:@"priority"];
	}
	[CoreDataUtils saveChanges];
}

- (void) renameProduct: (NSString *) productName withNewName: (NSString *) newName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Product" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productName LIKE %@", productName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:newName forKey:@"productName"];
	}
	[CoreDataUtils saveChanges];
}

- (void) deleteProduct: (NSString *) productName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Product" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productName LIKE %@", productName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[context deleteObject:item];
	}
	[CoreDataUtils saveChanges];
}

- (NSManagedObject *) productFromProductAndCategoryIndex: (NSInteger) productAndCategoryIndex {
	int categoryIndex = productAndCategoryIndex & 0x0000ffff;
	int productIndex = (productAndCategoryIndex & 0xffff0000) >> 16;
	if (isShowingCategories) {
		NSString *categoryName = [[categories objectAtIndex:categoryIndex] valueForKey:@"categoryName"];
		NSArray *productsInSection = [productsAndCategories allKeysForObject:categoryName];
		if (productIndex < [productsInSection count]) {
			return [CoreDataUtils findProduct:[productsInSection objectAtIndex:productIndex]];
		} else {
			return nil;
		}

	} else {
		if (productIndex < [products count]) {
			return [products objectAtIndex:productIndex];
		} else {
			return nil;
		}
	}
}

- (void) changeProductIcon: (NSString *) productName withNewIcon: (UIImage *) image {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Product" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productName LIKE %@", productName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:image forKey:@"icon"];
	}
	[CoreDataUtils saveChanges];
}

#pragma mark -
#pragma mark Shopping Items

- (void) updateShoppingListItems {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groceryListName LIKE %@", self.groceryListName];
	[fetchRequest setPredicate:predicate];
	
	NSError * error = nil;
	self.shoppingItems = [context executeFetchRequest:fetchRequest error:&error];
	
}

- (void) insertOrUpdateShoppingListItemWithProductName: (NSString *) productName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSManagedObject *existingItem = [self findShoppingListItemWithProductName: productName];
	if (existingItem == nil) {
		NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:@"ShoppingListItem" inManagedObjectContext:context];
		[item setValue:productName forKey:@"productName"];
		[item setValue:self.groceryListName forKey:@"groceryListName"];
		[item setValue:[NSNumber numberWithBool:NO] forKey:@"isPurchased"];
		[item setValue:[NSNumber numberWithInt:1] forKey:@"purchaseCount"];
	} else {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		
		NSEntityDescription *entity = [NSEntityDescription 
									   entityForName:@"ShoppingListItem" 
									   inManagedObjectContext: context];
		[fetchRequest setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groceryListName LIKE %@) AND (productName LIKE %@)", self.groceryListName, productName];
		[fetchRequest setPredicate:predicate];
		
		NSError *error;
		NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
		
		for (NSManagedObject *item in items) {
			int purchaseCount = [(NSNumber *)[item valueForKey:@"purchaseCount"] intValue];
			purchaseCount++;
			[item setValue:[NSNumber numberWithInt:purchaseCount] forKey:@"purchaseCount"];
		}
	}
	[self.tracker updateListStateForProductName:productName byStateCount:1];
	[CoreDataUtils saveChanges];
}

- (void) removeShoppingListItemWithProductName: (NSString *) productName andRemoveAll: (BOOL) removeAll andApplyToCurrentListOnly:(BOOL) applyToCurrentListOnly {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"ShoppingListItem" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = nil;
	if (applyToCurrentListOnly) {
		predicate = [NSPredicate predicateWithFormat:@"(groceryListName LIKE %@) AND (productName LIKE %@)", self.groceryListName, productName];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"(productName LIKE %@)", productName];
	}
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		int purchaseCount = [(NSNumber *)[item valueForKey:@"purchaseCount"] intValue];
		if (removeAll) {
			[context deleteObject:item];
			[self updateProductPopularity: productName by: (-1)*purchaseCount];
			[self.tracker updateListStateForProductName:productName byStateCount:(-1)*purchaseCount];
		} else {
			if (purchaseCount > 1) {
				purchaseCount--;
				[item setValue:[NSNumber numberWithInt:purchaseCount] forKey:@"purchaseCount"];
				[self updateProductPopularity: productName by: -1];
			} else {
				[context deleteObject:item];
			}
			[self.tracker updateListStateForProductName:productName byStateCount:-1];
		}
	}
	[CoreDataUtils saveChanges];
}

- (void) renameShoppingListItemWithProductName: (NSString *) productName withNewName: (NSString *) newName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"ShoppingListItem" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(productName LIKE %@)", productName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:newName forKey:@"productName"];
	}
	[CoreDataUtils saveChanges];

}

- (NSManagedObject *) findShoppingListItemWithProductName: (NSString *) productName {
	for (NSManagedObject *item in self.shoppingItems) {
		if ([[item valueForKey:@"productName"] isEqualToString:productName]) {
			return item;
		}
	}
	return nil;
}

#pragma mark -
#pragma mark Text input dialog handlers

- (IBAction) addButtonWasPressed {
	UIAlertView *addItemSelectorView = [[UIAlertView alloc] initWithTitle:@"Add..." message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Product", @"Category", nil];
	addItemSelectorView.tag = ADD_NEW_PRODUCT_OR_CATEGORY_DIALOG;
	[addItemSelectorView show];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(buttonIndex==0) {
		[self.searchBar resignFirstResponder];
		return;
	}
	switch (alertView.tag) {
		case ADD_NEW_PRODUCT_DIALOG: {
			NSString* productName = [(TextInputAlert *)alertView enteredText];
			if ([TextUtils isEmpty:productName]) {
				NSString *message = @"Product name is empty";
				[TextInputDialog displayInputDialogWithTitle:message andTextFieldValue:nil andLabel:@"Enter product name" andDelegate:self andTag: ADD_NEW_PRODUCT_DIALOG];
				return;
			}
			productName = [TextUtils trimWhitespace:productName];
			productName = [productName lowercaseString];
			NSManagedObject *product = [CoreDataUtils findProduct:productName];
			if (product == nil) {
				[self insertNewProductWithName:productName andUseDefaultIcon: YES];
				self.searchBar.text = productName;
				NSString *searchString = [self.searchBar text];
				if(![TextUtils isEmpty:searchString]) {
					[self filterProducts:searchString];
				} else {
					[self updateProducts:self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
				}
				[self.productGridView reloadData];
			} else {
				[TextInputDialog displayInputDialogWithTitle:@"Product already exists" andTextFieldValue:productName andLabel:productName andDelegate:self andTag: ADD_NEW_PRODUCT_DIALOG];
			}
			break;
		}
		case RENAME_PRODUCT_DIALOG: {
			NSString* newProductName = [(TextInputAlert *)alertView enteredText];
			if ([TextUtils isEmpty:newProductName]) {
				NSString *message = @"Product name is empty";
				[TextInputDialog displayInputDialogWithTitle:message andTextFieldValue:nil andLabel:@"Enter product name" andDelegate:self andTag: ADD_NEW_PRODUCT_DIALOG];
				return;
			}
			newProductName = [TextUtils trimWhitespace:newProductName];
			newProductName = [newProductName lowercaseString];
			NSManagedObject *product = [CoreDataUtils findProduct:newProductName];
			if (product == nil) {
				[self renameProduct: self.originalProductName withNewName: newProductName];
				[self renameShoppingListItemWithProductName: self.originalProductName withNewName: newProductName];
				self.originalProductName = nil;
				self.searchBar.text = newProductName;
				NSString *searchString = [self.searchBar text];
				if(![TextUtils isEmpty:searchString]) {
					[self filterProducts:searchString];
				}
				[self.productGridView reloadData];
			} else {
				[TextInputDialog displayInputDialogWithTitle:@"Product already exists" andTextFieldValue:newProductName andLabel:newProductName andDelegate:self andTag: RENAME_PRODUCT_DIALOG];
				return;
			}
			break;
		}
		case DELETE_PRODUCT_DIALOG: {
			NSString * productName = self.productToDeleteName;
			[self deleteProduct:productName];
			[self removeShoppingListItemWithProductName:productName andRemoveAll:YES andApplyToCurrentListOnly:NO];
			self.productToDeleteName = nil;
			[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
			[self updateShoppingListItems];
			[self.productGridView reloadData];
			break;
		}
		case ADD_NEW_PRODUCT_OR_CATEGORY_DIALOG: {
			switch (buttonIndex) {
				case 1: {
					NSString *searchString = [self.searchBar text];
					if(![TextUtils isEmpty:searchString]) {
						[TextInputDialog displayInputDialogWithTitle:@"Add new product" andTextFieldValue:searchString andLabel:@"Enter product name" andDelegate:self andTag:ADD_NEW_PRODUCT_DIALOG];
						return;
					} else {
						[TextInputDialog displayInputDialogWithTitle:@"Add new product" andTextFieldValue:nil andLabel:@"Enter product name" andDelegate:self andTag:ADD_NEW_PRODUCT_DIALOG];
						break;
					}
					break;
				}
				case 2: {
					[TextInputDialog displayInputDialogWithTitle:@"Add new category" andTextFieldValue:nil andLabel:@"Enter category name" andDelegate:self andTag:ADD_NEW_CATEGORY_DIALOG];
					break;
				}
				default:
					break;
			}
			break;
		}
		case ADD_NEW_CATEGORY_DIALOG: {
			NSString* categoryName = [(TextInputAlert *)alertView enteredText];
			if ([TextUtils isEmpty:categoryName]) {
				NSString *message = @"Category name is empty";
				[TextInputDialog displayInputDialogWithTitle:message andTextFieldValue:nil andLabel:@"Enter category name" andDelegate:self andTag: ADD_NEW_CATEGORY_DIALOG];
				return;
			}
			categoryName = [TextUtils trimWhitespace:categoryName];
			categoryName = [categoryName lowercaseString];
			NSManagedObject *category = [CoreDataUtils findCategory:categoryName];
			if (category == nil) {
				self.isShowingCategories = YES;
				searchBar.text = @"";
				[CoreDataUtils insertNewCategoryWithName:categoryName];
				[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
				[self.productGridView reloadData];
			} else {
				[TextInputDialog displayInputDialogWithTitle:@"Category already exists" andTextFieldValue:categoryName andLabel:categoryName andDelegate:self andTag: ADD_NEW_CATEGORY_DIALOG];
			}
			break;
		}
		case RENAME_CATEGORY_DIALOG: {
			NSString* newCategoryName = [(TextInputAlert *)alertView enteredText];
			if ([TextUtils isEmpty:newCategoryName]) {
				NSString *message = @"Category name is empty";
				[TextInputDialog displayInputDialogWithTitle:message andTextFieldValue:nil andLabel:@"Enter category name" andDelegate:self andTag: RENAME_CATEGORY_DIALOG];
				return;
			}
			newCategoryName = [TextUtils trimWhitespace:newCategoryName];
			newCategoryName = [newCategoryName lowercaseString];
			NSManagedObject *category = [CoreDataUtils findCategory:newCategoryName];
			if (category == nil) {
				self.isShowingCategories = YES;
				[CoreDataUtils renameCategory:self.originalCategoryName withNewName:newCategoryName];
				[CoreDataUtils moveProductsFromCategory:self.originalCategoryName toNewCategory:newCategoryName];
				self.originalCategoryName = nil;
				[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
				[self.productGridView reloadData];
			} else {
				[TextInputDialog displayInputDialogWithTitle:@"Category already exists" andTextFieldValue:newCategoryName andLabel:newCategoryName andDelegate:self andTag: RENAME_CATEGORY_DIALOG];
				return;
			}
			break;
		}
		default:
			break;
	}
}

#pragma mark -
#pragma mark Toolbar button handlers

- (IBAction) showHideCategories {
	searchBar.text = @"";
	self.isShowingCategories = !self.isShowingCategories;
	[self updateProducts: self.sortKey andRequestAscendingOrder: self.ascendingSortOrder];
	[self.productGridView reloadData];
}

- (IBAction) sortByName {
	searchBar.text = @"";
	self.ignoreCategorySortKey = NO;
	self.ascendingNameSortOrder = !self.ascendingNameSortOrder;
	self.sortKey = @"productName";
	self.ascendingSortOrder = self.ascendingNameSortOrder;
	[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.productGridView reloadData];
}

- (IBAction) rearrangeCategories {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	for (int index = 0; index < [categories count]; index++) {
		[data addObject:[[categories objectAtIndex:index] valueForKey:@"categoryName"]];
	}
	CategoryRearrangeView *alert = [[CategoryRearrangeView alloc] initWithCaller: self 
																			 data: data
																	 title:@"Edit Categories" 
																andContext:nil];
	[alert show];
}

- (IBAction) sortCategoriesByUserDefinedOrder {
	searchBar.text = @"";
	self.isShowingCategories = YES;
	self.ignoreCategorySortKey = YES;
	[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.productGridView reloadData];	
}

#pragma mark -
#pragma mark CategoryRearrangeViewDelegate 

-(void)rearrangedCategories:(id)context {
	self.isShowingCategories = YES;
	self.ignoreCategorySortKey = YES;
	searchBar.text = @"";
	[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.productGridView reloadData];
}

-(void)deletedCategory:(id)context {
	self.isShowingCategories = YES;
	NSString *categoryName = context;
	searchBar.text = @"";
	[CoreDataUtils moveProductsFromCategory:categoryName toNewCategory:@"other"];
	[CoreDataUtils deleteCategory:categoryName];
	[self updateProducts: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.productGridView reloadData];
}

-(void)renamedCategory:(id)context {
	self.isShowingCategories = YES;
	self.originalCategoryName = context;
	searchBar.text = @"";
	[TextInputDialog displayInputDialogWithTitle:@"Change category name" andTextFieldValue:self.originalCategoryName andLabel:self.originalCategoryName andDelegate:self andTag:RENAME_CATEGORY_DIALOG];
}

#pragma mark -
#pragma mark Search bar delegate methods

- (void) searchBar:(UISearchBar *)sb textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
		[self updateProducts:self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
		[self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:sb afterDelay:0];
	} else {
		self.isShowingCategories = NO;
		[self filterProducts: searchText];
	}
	[self.productGridView reloadData];
}

- (void)hideKeyboardWithSearchBar:(UISearchBar *)sb {   
    [sb resignFirstResponder];   
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)sb {
	NSString *searchString = [searchBar text];
	[sb resignFirstResponder];
	[self filterProducts: searchString];
	[self.productGridView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)sb {
	searchBar.text = @"";
	[sb resignFirstResponder];
	[self updateProducts:self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.productGridView reloadData];
}

#pragma mark UIGestureRecognizer

- (void) handleTap: (UITapGestureRecognizer*)tapRecognizer {
	[self clearMenuItems];
	NSManagedObject *product = [self productFromProductAndCategoryIndex: [tapRecognizer.view tag]];
	if (product == nil) {
		return;
	}
	NSString *productName = [product valueForKey:@"productName"];
	[self insertOrUpdateShoppingListItemWithProductName: productName];
	[self updateProductPopularity: productName by: 1];
	[self updateShoppingListItems];
	[productGridView reloadData];
}

- (void) handleLongPress: (UILongPressGestureRecognizer*)longPressRecognizer {
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		[self clearMenuItems];
		int pressedItemIndex = [longPressRecognizer.view tag];
		[self becomeFirstResponder];
		NSManagedObject *product = [self productFromProductAndCategoryIndex:[longPressRecognizer.view tag]];
		if (product == nil) {
			return;
		}
		BOOL isProductUserCreated = [(NSNumber *)[product valueForKey:@"isUserCreated"] boolValue];
		NSString *productName = [product valueForKey:@"productName"];
		NSManagedObject *shoppingItem = [self findShoppingListItemWithProductName: productName];
		
		UIMenuController *menuController = [UIMenuController sharedMenuController];
		if (isProductUserCreated) {
			if (shoppingItem != nil) {
				ProductMenuItem *removeOneItem = [[ProductMenuItem alloc] initWithTitle:@"Remove one" action:@selector(removeOneButtonPressed:)];
				removeOneItem.index = pressedItemIndex;
				ProductMenuItem *removeAllItem = [[ProductMenuItem alloc] initWithTitle:@"Remove all" action:@selector(removeAllButtonPressed:)];
				removeAllItem.index = pressedItemIndex;
				ProductMenuItem *renameItem = [[ProductMenuItem alloc] initWithTitle:@"Rename" action:@selector(renameButtonPressed:)];
				renameItem.index = pressedItemIndex;
				ProductMenuItem *deleteItem = [[ProductMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteButtonPressed:)];
				deleteItem.index = pressedItemIndex;
				ProductMenuItem *changeIconItem = [[ProductMenuItem alloc] initWithTitle:@"Icon" action:@selector(changeIconButtonPressed:)];
				changeIconItem.index = pressedItemIndex;
				ProductMenuItem *assignToCategoryIconItem = [[ProductMenuItem alloc] initWithTitle:@"Assign" action:@selector(assignToCategoryButtonPressed:)];
				assignToCategoryIconItem.index = pressedItemIndex;
				menuController.menuItems = [NSArray arrayWithObjects:removeOneItem, removeAllItem, renameItem, deleteItem, changeIconItem, assignToCategoryIconItem, nil];
			} else {
				ProductMenuItem *renameItem = [[ProductMenuItem alloc] initWithTitle:@"Rename" action:@selector(renameButtonPressed:)];
				renameItem.index = pressedItemIndex;
				ProductMenuItem *deleteItem = [[ProductMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteButtonPressed:)];
				deleteItem.index = pressedItemIndex;
				ProductMenuItem *changeIconItem = [[ProductMenuItem alloc] initWithTitle:@"Icon" action:@selector(changeIconButtonPressed:)];
				changeIconItem.index = pressedItemIndex;
				ProductMenuItem *assignToCategoryIconItem = [[ProductMenuItem alloc] initWithTitle:@"Assign" action:@selector(assignToCategoryButtonPressed:)];
				assignToCategoryIconItem.index = pressedItemIndex;
				menuController.menuItems = [NSArray arrayWithObjects: renameItem, deleteItem, changeIconItem, assignToCategoryIconItem, nil];
			}
			
		} else {
			if (shoppingItem != nil) {
				UIMenuController *menuController = [UIMenuController sharedMenuController];
				ProductMenuItem *removeOneItem = [[ProductMenuItem alloc] initWithTitle:@"Remove one" action:@selector(removeOneButtonPressed:)];
				removeOneItem.index = pressedItemIndex;
				ProductMenuItem *removeAllItem = [[ProductMenuItem alloc] initWithTitle:@"Remove all" action:@selector(removeAllButtonPressed:)];
				removeAllItem.index = pressedItemIndex;
				ProductMenuItem *renameItem = [[ProductMenuItem alloc] initWithTitle:@"Rename" action:@selector(renameButtonPressed:)];
				renameItem.index = pressedItemIndex;
				ProductMenuItem *assignToCategoryIconItem = [[ProductMenuItem alloc] initWithTitle:@"Assign" action:@selector(assignToCategoryButtonPressed:)];
				assignToCategoryIconItem.index = pressedItemIndex;
				menuController.menuItems = [NSArray arrayWithObjects:removeOneItem, removeAllItem, renameItem, assignToCategoryIconItem, nil];
			} else {
				ProductMenuItem *renameItem = [[ProductMenuItem alloc] initWithTitle:@"Rename" action:@selector(renameButtonPressed:)];
				renameItem.index = pressedItemIndex;
				ProductMenuItem *assignToCategoryIconItem = [[ProductMenuItem alloc] initWithTitle:@"Assign" action:@selector(assignToCategoryButtonPressed:)];
				assignToCategoryIconItem.index = pressedItemIndex;
				menuController.menuItems = [NSArray arrayWithObjects:renameItem, assignToCategoryIconItem, nil];
			}
		}
		CGPoint location = [longPressRecognizer locationOfTouch:0 inView:productGridView]; 
		CGRect cellRect = CGRectMake(location.x - CELL_SIZE/2, location.y - CELL_SIZE/2, CELL_SIZE, CELL_SIZE);
		[menuController setTargetRect: cellRect inView:self.productGridView];
		[menuController setMenuVisible:YES animated:YES];
    }
}

- (void) removeOneButtonPressed:(UIMenuController*)menuController {
	NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
	int index = [self indexOfItemInMenuItems:menuItems title:@"Remove one"];
	if (index == -1) {
		return;
	}
	ProductMenuItem *removeOneItem = [menuItems objectAtIndex: index];
	if (removeOneItem.index != NSNotFound) {
		NSManagedObject *product = [self productFromProductAndCategoryIndex:removeOneItem.index];
		NSString *productName = [product valueForKey:@"productName"];
		[self removeShoppingListItemWithProductName:productName andRemoveAll:NO andApplyToCurrentListOnly:YES];
		[self updateShoppingListItems];
		[self.productGridView reloadData];
		[self clearMenuItems];
	}
}

- (void) removeAllButtonPressed:(UIMenuController*)menuController {
	NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
	int index = [self indexOfItemInMenuItems:menuItems title:@"Remove all"];
	if (index == -1) {
		return;
	}
	ProductMenuItem *removeAllItem = [menuItems objectAtIndex: index];
	if (removeAllItem.index != NSNotFound) {
		NSManagedObject *product = [self productFromProductAndCategoryIndex:removeAllItem.index];
		NSString *productName = [product valueForKey:@"productName"];
		[self removeShoppingListItemWithProductName:productName andRemoveAll:YES andApplyToCurrentListOnly:YES];
		[self updateShoppingListItems];
		[self.productGridView reloadData];
		[self clearMenuItems];
	}
}

- (void) renameButtonPressed:(UIMenuController*)menuController {
	NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
	int index = [self indexOfItemInMenuItems:menuItems title:@"Rename"];
	if (index == -1) {
		return;
	}
	ProductMenuItem *renameItem = [menuItems objectAtIndex: index];
	if (renameItem.index != NSNotFound) {
		NSManagedObject *product = [self productFromProductAndCategoryIndex:renameItem.index];
		self.originalProductName = [product valueForKey:@"productName"];
		[self clearMenuItems];
		[TextInputDialog displayInputDialogWithTitle:@"Change product name" andTextFieldValue:self.originalProductName andLabel:self.originalProductName andDelegate:self andTag:RENAME_PRODUCT_DIALOG];
	}
}

- (void) deleteButtonPressed:(UIMenuController*)menuController {
	NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
	int index = [self indexOfItemInMenuItems:menuItems title:@"Delete"];
	if (index == -1) {
		return;
	}
	ProductMenuItem *deleteItem = [menuItems objectAtIndex:index];
	if (deleteItem.index != NSNotFound) {
		NSManagedObject *product = [self productFromProductAndCategoryIndex:deleteItem.index];
		if (product != nil) {
			self.productToDeleteName = [product valueForKey:@"productName"];
			NSString *message = [NSString stringWithFormat:@"\"%@\" is going to be removed from product database.", self.productToDeleteName];
			[self clearMenuItems];
			[UserConfirmationDialog displayConfirmationDialogWithTitle:nil andMessage:message andDelegate:self andTag:DELETE_PRODUCT_DIALOG];
		}		
	}
}

- (void) changeIconButtonPressed:(UIMenuController*)menuController {
	NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
	int index = [self indexOfItemInMenuItems:menuItems title:@"Icon"];
	if (index == -1) {
		return;
	}
	ProductMenuItem *changeIconItem = [menuItems objectAtIndex:index];
	if (changeIconItem.index != NSNotFound) {
		NSManagedObject *product = [self productFromProductAndCategoryIndex:changeIconItem.index];
		if (product != nil) {
			self.productToChangeIcon = [product valueForKey:@"productName"];
			[self clearMenuItems];
		}		
		
		BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
		
		UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil
														delegate:self
											   cancelButtonTitle:nil
										  destructiveButtonTitle:nil
											   otherButtonTitles:nil];
		
		if (hasCamera) {
			[as addButtonWithTitle:@"Take Photo"];
		}
		
		[as addButtonWithTitle:@"Choose Existing Photo"];
		[as addButtonWithTitle:@"Cancel"];
		as.cancelButtonIndex = [as numberOfButtons] - 1;
		
		GroceryListAppDelegate *appDelegate = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]);
		[as showInView:appDelegate.window];
	}
}

- (void) assignToCategoryButtonPressed:(UIMenuController*)menuController {
	NSArray *menuItems = [[UIMenuController sharedMenuController] menuItems];
	int index = [self indexOfItemInMenuItems:menuItems title:@"Assign"];
	if (index == -1) {
		return;
	}
	ProductMenuItem *assignItem = [menuItems objectAtIndex: index];
	if (assignItem.index != NSNotFound) {
		NSManagedObject *product = [self productFromProductAndCategoryIndex:assignItem.index];
		self.originalProductName = [product valueForKey:@"productName"];
		[self clearMenuItems];
		TableAlertView *alert = [[TableAlertView alloc] initWithCaller: self data: categories
																  title:@"Categories" 
															 andContext:product];
		[alert show];
	}
}

- (int)indexOfItemInMenuItems:(NSArray*)menuItems title:(NSString*)title {
	int index = 0;
	for (; index < [menuItems count]; index++) {
		if ([[[menuItems objectAtIndex:index] title] isEqualToString:title]) {
			return index;
		}
	}
	return -1;
}

-(void) clearMenuItems {
	UIMenuController *menuController = [UIMenuController sharedMenuController];
	menuController.menuItems = nil;
}

#pragma mark -
#pragma mark TableAlertViewDelegate

-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context {
	if (context != nil) {
		searchBar.text = @"";
		Product *product = context;
		[product setCategoryName:[[categories objectAtIndex:row] valueForKey:@"categoryName"]];
		[CoreDataUtils saveChanges];
		self.isShowingCategories = YES;
		[self updateProducts:self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
		[productGridView reloadData];
	}
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet *)as clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (as.cancelButtonIndex == buttonIndex) {
        return;
    }
   	
    NSString *title = [as buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Take Photo"]) {
        [self showImagePicker:true];
    }	
    else {
		[self showImagePicker:false];
    }
}

#pragma mark -
#pragma mark Icon management

- (void) showImagePicker:(BOOL)hasCamera {
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.allowsEditing = YES;
	picker.delegate = self;
	if (hasCamera) {
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	}
	[self presentModalViewController:picker animated:YES];
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate protocol methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
	if (picker != nil && editingInfo != nil) {
		[self changeProductIcon:self.productToChangeIcon withNewIcon:image];
		NSString *filter = [[NSString alloc] initWithString:self.productToChangeIcon];
		[self.searchBar setText:filter];
		if(![TextUtils isEmpty:filter]) {
			[self filterProducts:filter];
		} else {
			[self updateProducts:self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
		}
		[self.productGridView reloadData];
		[self dismissModalViewControllerAnimated:YES];
		self.productToChangeIcon = nil;
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {	
	if (picker != nil) {
		[self dismissModalViewControllerAnimated:YES];
		self.productToChangeIcon = nil;
	}
}

@end
