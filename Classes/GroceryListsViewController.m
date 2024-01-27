//
//  RootViewController.m
//  GroceryList
//
//  Created by pawel on 8/10/10.
//  Copyright __etcApps__ 2010. All rights reserved.
//

#import "GroceryListsViewController.h"
#import "ShoppingListViewController.h"
#import "ProductSelectorViewController.h"
#import "GroceryListAppDelegate.h"
#import "TextInputDialog.h"
#import "TextInputAlert.h"
#import "TextUtils.h"
#import "UserInfoDialog.h"
#import "CoreDataUtils.h"
#import "UserConfirmationDialog.h"
#import "GroceryListCell.h"

@implementation GroceryListsViewController
@synthesize tableView;
@synthesize addButtonItem;
@synthesize ascendingDateSortOrder;
@synthesize ascendingNameSortOrder;
@synthesize ascendingSortOrder;
@synthesize fetchedGroceryLists;
@synthesize sortKey;
@synthesize listToBeDeleted;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.tableView setSeparatorColor:[UIColor darkGrayColor]];
	
	self.ascendingDateSortOrder = YES;
	
	self.listToBeDeleted = nil;
	
	self.navigationItem.rightBarButtonItem = self.addButtonItem;
	
	self.title = @"Grocery Lists";
	self.sortKey = @"dateModified";
	self.ascendingSortOrder = NO;
	self.ascendingNameSortOrder = self.ascendingSortOrder;
	self.ascendingDateSortOrder = self.ascendingSortOrder;
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
	if (interfaceOrientation == UIInterfaceOrientationPortrait) {
		return YES;
	} else {
		return NO;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[self updateGroceryListsArray: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Add button handler

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		self.addButtonItem = [[UIBarButtonItem alloc]
							   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
							   target:self 
							   action:@selector(addButtonWasPressed)];
	}
	return self;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	switch (alertView.tag) {
		case ADD_GROCERY_LIST_DIALOG: {
			if(buttonIndex==0)
				return;
			
			NSString* groceryListName = [(TextInputAlert *)alertView enteredText];	

			if ([TextUtils isEmpty:groceryListName]) {
				NSString *message = @"List name is empty";
				[TextInputDialog displayInputDialogWithTitle:message andTextFieldValue:groceryListName andLabel:@"Enter list name" andDelegate:self andTag: ADD_GROCERY_LIST_DIALOG];
				return;
			}
			
			groceryListName = [TextUtils trimWhitespace:groceryListName];
			if ([CoreDataUtils findGroceryList:groceryListName]) {
				[TextInputDialog displayInputDialogWithTitle:@"List already exists" andTextFieldValue:groceryListName andLabel:groceryListName andDelegate:self andTag: ADD_GROCERY_LIST_DIALOG];
				return;
			}
			
			groceryListName = [TextUtils trimWhitespace:groceryListName];
			[CoreDataUtils insertGroceryListWithName:groceryListName];
			[self updateGroceryListsArray: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
			ProductSelectorViewController *productSelectorViewController;
			productSelectorViewController = [[ProductSelectorViewController alloc] init];
			productSelectorViewController.title = groceryListName;
			productSelectorViewController.groceryListName = groceryListName;
			[self.navigationController pushViewController:productSelectorViewController animated:YES];
			[self dismissModalViewControllerAnimated:YES];
			break;
	}
		case DELETE_GROCERY_LIST_DIALOG: {
			if(buttonIndex==0) {
				[self changePurchaseStateForGroceryList:self.listToBeDeleted withNewState:NO];
			} else {
				[self deleteGroceryList:self.listToBeDeleted];
				[self deleteAllShoppingListItemsForGroceryList:self.listToBeDeleted];
			}
			self.listToBeDeleted = nil;
			break;
		}
		default:
			break;
	}
} 

- (IBAction)addButtonWasPressed {
	[TextInputDialog displayInputDialogWithTitle:@"Add list" andTextFieldValue:nil andLabel:@"Enter list name" andDelegate:self andTag:ADD_GROCERY_LIST_DIALOG];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedGroceryLists count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    GroceryListCell *cell = (GroceryListCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GroceryListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger index = [indexPath row];
    NSManagedObject *groceryList = [self.fetchedGroceryLists objectAtIndex:index];
    [cell setGroceryListItemManagedObject: groceryList];
	
    return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObject *groceryList = [fetchedGroceryLists objectAtIndex:indexPath.row];
		NSString *groceryListName = [groceryList valueForKey:@"name"];
		[fetchedGroceryLists removeObjectAtIndex:indexPath.row];
		[tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self deleteGroceryList:groceryListName];
		[self deleteAllShoppingListItemsForGroceryList:groceryListName];
	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ShoppingListViewController *shoppingListController = [[ShoppingListViewController alloc] init]; 
	NSUInteger index = [indexPath row];
	NSManagedObject *groceryList = [self.fetchedGroceryLists objectAtIndex:index];
	NSString *listName = [groceryList valueForKey:@"name"];
	shoppingListController.title = listName;
	shoppingListController.groceryListName = listName;
	shoppingListController.groceryListsController = self;
	[self.navigationController pushViewController:shoppingListController animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
	return 70;
}

#pragma mark -
#pragma mark Toolbar button handlers

- (IBAction)sortByDate {
	self.ascendingDateSortOrder = !self.ascendingDateSortOrder;
	self.sortKey = @"dateModified";
	self.ascendingSortOrder = self.ascendingDateSortOrder;
	[self updateGroceryListsArray: self.sortKey andRequestAscendingOrder: self.ascendingSortOrder];
	[self.tableView reloadData];
}

- (IBAction)sortByName {
	self.ascendingNameSortOrder = !self.ascendingNameSortOrder;
	self.sortKey = @"name";
	self.ascendingSortOrder = self.ascendingNameSortOrder;
	[self updateGroceryListsArray: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
	[self.tableView reloadData];
}

- (IBAction)stickyET {
    NSString *stringURL = @"http://itunes.apple.com/us/app/stickyet-for-ipad/id505572404?mt=8";
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        stringURL = @"http://itunes.apple.com/us/app/stickyet/id495076602?mt=8";
    }
	NSURL *url = [NSURL URLWithString:stringURL];
	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark -
#pragma mark Fetched Grocery lists management

- (void)updateGroceryListsArray:(NSString*)sortDescriptorKey andRequestAscendingOrder:(BOOL) sortOrder {
	NSError *error;
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortDescriptorKey ascending:sortOrder];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"GroceryList" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	self.fetchedGroceryLists = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
	[[self tableView] reloadData];
	
	if ([self.fetchedGroceryLists count] > 0) {
		[self.tableView setHidden:NO];
	} else {
		[self.tableView setHidden:YES];
	}
}

- (void)deleteGroceryList:(NSString *)groceryListName {
	[CoreDataUtils deleteGroceryList:groceryListName];
	[self updateGroceryListsArray: self.sortKey andRequestAscendingOrder:self.ascendingSortOrder];
}

- (void)handleAllItemsPurchased:(NSString *)groceryListName {
	UINavigationController *navController = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).navigationController;
	if ([navController visibleViewController] == self) {
		self.listToBeDeleted = groceryListName; 
		NSString *message = [NSString stringWithFormat:@"You purchased all items from \"%@\". Delete?", groceryListName];
		[UserConfirmationDialog displayConfirmationDialogWithTitle:nil andMessage:message andDelegate:self andTag:DELETE_GROCERY_LIST_DIALOG];
	}
}

#pragma mark -
#pragma mark Shopping Items

- (void)changePurchaseStateForGroceryList:(NSString *)groceryListName withNewState:(BOOL)newState {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groceryListName LIKE %@", groceryListName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:[NSNumber numberWithInt:newState] forKey:@"isPurchased"];
	}
	[CoreDataUtils saveChanges];
}

- (void)deleteAllShoppingListItemsForGroceryList:(NSString *)groceryListName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groceryListName LIKE %@", groceryListName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[context deleteObject:item];
	}
	[CoreDataUtils saveChanges];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.tableView = nil;
	self.fetchedGroceryLists = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}



@end

