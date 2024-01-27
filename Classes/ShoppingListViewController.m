//
//  ShoppingListViewController.m
//  GroceryList
//
//  Created by pawel on 8/13/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "ShoppingListViewController.h"
#import "ProductSelectorViewController.h"
#import "GroceryListAppDelegate.h"
#import "ShoppingListCell.h"
#import "UserInfoDialog.h"
#import "GroceryListStateTracker.h"
#import "CoreDataUtils.h"
#import "GroceryListsViewController.h"
#import "TextInputDialog.h"
#import "TextInputAlert.h"
#import "TextUtils.h"

@implementation ShoppingListViewController
@synthesize shoppingItems;
@synthesize groceryListName;
@synthesize tableView;
@synthesize showPurchased;
@synthesize tracker;
@synthesize groceryListsController;
@synthesize productsAndCategories;
@synthesize categories;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	self.showPurchased = YES;
	[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
	//[self.tableView setBounces:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonWasPressed)];
	self.tracker = [[GroceryListStateTracker alloc] init];
	productsAndCategories = [[NSMutableDictionary alloc] init];
	categories = [[NSMutableArray alloc] init];
	shoppingItems = [[NSMutableDictionary alloc] init];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		return YES;
	} else {
		return NO;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self updateShoppingListItems];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if ([self.tracker isListStateDirty]) {
		[CoreDataUtils updateGroceryListDateModified:self.groceryListName];
	}
	if ([self allShoppingListItemsPurchased]) {
		[groceryListsController handleAllItemsPurchased:self.groceryListName];
	}
}

- (IBAction)editButtonWasPressed {
	ProductSelectorViewController *productSelectorViewController;
	productSelectorViewController = [[ProductSelectorViewController alloc] init];
	productSelectorViewController.title = self.title;
	productSelectorViewController.groceryListName = self.title;
	[self.navigationController pushViewController:productSelectorViewController animated:YES];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [categories count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *sectionTitle = [categories objectAtIndex:section];
	return sectionTitle;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *categoryName = [categories objectAtIndex:section];
	NSArray *productsInSection = [productsAndCategories allKeysForObject:categoryName];
	return [productsInSection count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ShoppingListCell *cell = (ShoppingListCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ShoppingListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	int section = [indexPath section];
	NSString *categoryName = [categories objectAtIndex:section];
	NSArray *productsInSection = [productsAndCategories allKeysForObject:categoryName];
	NSString *productKey = [productsInSection objectAtIndex:indexPath.row];
	NSManagedObject *item = [self.shoppingItems objectForKey:productKey];
	[cell setShoppingListItemManagedObject:item];
    return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		int section = [indexPath section];
		NSString *categoryName = [categories objectAtIndex:section];
		NSArray *productsInSection = [productsAndCategories allKeysForObject:categoryName];
		NSString *productKey = [productsInSection objectAtIndex:indexPath.row];
        [shoppingItems removeObjectForKey:productKey];
        [productsAndCategories removeObjectForKey:productKey];
		[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self deleteShoppingListItemWithProductName:productKey];
		[self updateShoppingListItems];
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	int section = [indexPath section];
	NSString *categoryName = [categories objectAtIndex:section];
	NSArray *productsInSection = [productsAndCategories allKeysForObject:categoryName];
	NSString *productName = [productsInSection objectAtIndex:indexPath.row];
	[self updateShoppingListItemWithProductName:productName];
	[self updateShoppingListItems];
	[self.tableView reloadData];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
	return 70;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.shoppingItems = nil;
	self.tableView = nil;
	self.tracker = nil;
	self.productsAndCategories = nil;
	self.categories = nil;
	[super viewDidUnload];
}


#pragma mark -
#pragma mark Shopping Items

-(void)updateCategories {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	if (self.categories != nil &&
		[self.categories count] > 0) {
		[self.categories removeAllObjects];
	}

	NSArray *tmpCategories = [context executeFetchRequest:fetchRequest error:&error];
	NSArray *allCategoriesInThisList = [[NSSet setWithArray:[productsAndCategories allValues]] allObjects];
	for (int categoryIndex = 0; categoryIndex < [tmpCategories count]; ++categoryIndex) {
		NSString *categoryName = [[tmpCategories objectAtIndex:categoryIndex] valueForKey:@"categoryName"];
		if ([allCategoriesInThisList indexOfObject:categoryName] != NSNotFound) {
			[self.categories addObject:categoryName];
		}
	}
	
}

- (void) updateShoppingListItems {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = nil;
	if (self.showPurchased) {
		predicate = [NSPredicate predicateWithFormat:@"groceryListName LIKE %@", self.groceryListName];
	} else {
		predicate = [NSPredicate predicateWithFormat:@"(groceryListName LIKE %@) AND (isPurchased == %@)", self.groceryListName, [NSNumber numberWithBool:self.showPurchased]];
	}

	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *tmpFetchedShoppingItems = [context executeFetchRequest:fetchRequest error:&error];
	
	if (self.productsAndCategories != nil &&
		[self.productsAndCategories count] > 0) {
		[self.productsAndCategories removeAllObjects];
	}
	
	if (self.shoppingItems != nil &&
		[self.shoppingItems count] > 0) {
		[self.shoppingItems removeAllObjects];
	}
	
	for (int productIndex = 0; productIndex < [tmpFetchedShoppingItems count]; productIndex++) {
		NSManagedObject *product = [CoreDataUtils findProduct:[[tmpFetchedShoppingItems objectAtIndex:productIndex] valueForKey:@"productName"]];
        if (product != nil) {
            NSString *productName = [product valueForKey:@"productName"];
            NSString *categoryName = [product valueForKey:@"categoryName"];
            [self.productsAndCategories setValue:categoryName forKey:productName];
            [self.shoppingItems setValue:[tmpFetchedShoppingItems objectAtIndex:productIndex] forKey:productName];
        }
	}
	
	[self updateCategories];
	
	if ([tmpFetchedShoppingItems count] > 0) {
		[self.tableView setHidden:NO];
	} else {
		[self.tableView setHidden:YES];
	}
}

- (void) updateShoppingListItemWithProductName: (NSString *) productName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;

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
		BOOL isPurchased = [(NSNumber *)[item valueForKey:@"isPurchased"] boolValue];
		isPurchased = !isPurchased;
		[item setValue:[NSNumber numberWithInt:isPurchased] forKey:@"isPurchased"];
		if (isPurchased) {
			[self.tracker updateListStateForProductName:[item valueForKey:@"productName"] byStateCount:-1];
		} else {
			[self.tracker updateListStateForProductName:[item valueForKey:@"productName"] byStateCount:1];
		}

	}
	[CoreDataUtils saveChanges];
}

- (void) deleteShoppingListItemWithProductName: (NSString *) productName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(groceryListName LIKE %@) AND (productName LIKE %@)", self.groceryListName, productName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[self.tracker updateListStateForProductName:[item valueForKey:@"productName"] byStateCount:-2];
		[context deleteObject:item];
	}
	[CoreDataUtils saveChanges];
}

- (BOOL)allShoppingListItemsPurchased {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = nil;
	predicate = [NSPredicate predicateWithFormat:@"(groceryListName LIKE %@) AND (isPurchased == %@)", self.groceryListName, [NSNumber numberWithBool:NO]];
	
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([items count] > 0) {
		return NO;
	} else {
		return YES;
	}
}

- (void)changeShoppingItemsOwnershipForGroceryList:(NSString *)oldListName withNewName:(NSString *)newListName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groceryListName LIKE %@", oldListName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:newListName forKey:@"groceryListName"];
	}
	[CoreDataUtils saveChanges];
}

#pragma mark -
#pragma mark Toolbar button handlers

- (IBAction)showHidePurchasedItems {
	self.showPurchased = !self.showPurchased;
	[self updateShoppingListItems];
	[self.tableView reloadData];
}

- (IBAction)shareShoppingList {
	if (![MFMailComposeViewController canSendMail]) {
		[UserInfoDialog displayInfoDialogWithTitle:nil andMessage:@"Your phone cannot send emails. Setup your email account."];
		return;
	}
	
	MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
		
	controller.mailComposeDelegate = self;
	
	
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groceryListName LIKE %@", self.groceryListName];	
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([items count] <= 0) {
		return;
	}
	
	NSMutableString *body = [[NSMutableString alloc] initWithString:@"Please buy following items:\n"];
	int index = 1;
	for (NSManagedObject *shoppingListItem in items) {
		NSString *productName = [shoppingListItem valueForKey:@"productName"];
		NSString *countText = [NSString stringWithFormat: @"%d", [(NSNumber *)[shoppingListItem valueForKey:@"purchaseCount"] intValue]];
		NSString *indexText = [NSString stringWithFormat: @"%d", index];
		[body appendFormat:@"%@. %@ x%@\n", indexText, productName, countText];
		index++;
	}
	
	NSString *subject = [NSString stringWithFormat:@"Grocery list: %@", self.groceryListName];
	[controller setSubject:subject];
	[controller setMessageBody:body isHTML:NO];
	[self presentModalViewController:controller animated:YES];
}

- (IBAction)renameList {
	[TextInputDialog displayInputDialogWithTitle:@"Rename list" andTextFieldValue:self.groceryListName andLabel:self.groceryListName andDelegate:self andTag:RENAME_GROCERY_LIST_DIALOG];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Dialog handler

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	switch (alertView.tag) {
		case RENAME_GROCERY_LIST_DIALOG: {
			if(buttonIndex==0)
				return;
			
			NSString* newListName = [(TextInputAlert *)alertView enteredText];			
			
			if ([TextUtils isEmpty:newListName]) {
				NSString *message = @"List name is empty";
				[TextInputDialog displayInputDialogWithTitle:message andTextFieldValue:newListName andLabel:@"Enter list name" andDelegate:self andTag: ADD_GROCERY_LIST_DIALOG];
				return;
			}
			
			newListName = [TextUtils trimWhitespace:newListName];
			if ([CoreDataUtils findGroceryList:newListName]) {
				[TextInputDialog displayInputDialogWithTitle:@"List already exists" andTextFieldValue:newListName andLabel:newListName andDelegate:self andTag: ADD_GROCERY_LIST_DIALOG];
				return;
			}
			
			[CoreDataUtils insertGroceryListWithName:newListName];
			[self changeShoppingItemsOwnershipForGroceryList:self.groceryListName withNewName:newListName];
			[CoreDataUtils deleteGroceryList:self.groceryListName];
			self.groceryListName = newListName;
			self.title = newListName;
			[self updateShoppingListItems];
			break;
		}
		default:
			break;
	}
} 


@end
