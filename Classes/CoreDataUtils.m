//
//  CoreDataUtils.m
//  GroceryList
//
//  Created by pawel on 12/26/10.
//  Copyright 2010 etcApps. All rights reserved.
//

#import "CoreDataUtils.h"
#import <CoreData/CoreData.h>
#import "GroceryListAppDelegate.h"
#import "UserInfoDialog.h"
#import "GPLogger.h"

@implementation CoreDataUtils

+ (void)saveChanges {
	NSError *error = nil;
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	if ([context hasChanges] && ![context save:&error]) {
		DLog(@"Unresolved Core Data Save error %@, %@", error, [error userInfo]);
		exit(-1);
	}
}

+ (void)updateGroceryListDateModified:(NSString*)groceryListName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription * entity = [NSEntityDescription entityForName:@"GroceryList" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSPredicate *predicate = nil;
	predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", groceryListName];
	
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:[NSDate date] forKey:@"dateModified"];
	}
	[CoreDataUtils saveChanges];
}

+ (void)insertGroceryListWithName:(NSString *) groceryListName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSManagedObject * groceryList = [NSEntityDescription
									 insertNewObjectForEntityForName:@"GroceryList" 
									 inManagedObjectContext:context];
	int iconIndex = arc4random() % NUMBER_OF_DEFAULT_GROCERY_LIST_ICONS;
	NSString *iconName = [NSString stringWithFormat:@"default_grocery_list_icon_%d.png", iconIndex];
	UIImage *image = [UIImage imageNamed:iconName];
	[groceryList setValue:image forKey:@"icon"];
	[groceryList setValue:groceryListName forKey:@"name"];
	[groceryList setValue:[NSDate date] forKey:@"dateModified"];
	[CoreDataUtils saveChanges];
}

+ (BOOL)findGroceryList:(NSString *)groceryListName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"GroceryList" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", groceryListName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		return YES;
	}
	return NO;
}

+ (void)deleteGroceryList:(NSString *)groceryListName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"GroceryList" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", groceryListName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[context deleteObject:item];
	}
	[CoreDataUtils saveChanges];
}

+ (NSManagedObject*)findProduct:(NSString *)productName {
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
		return item;
	}
	return nil;
}

+ (NSManagedObject*)findCategory:(NSString *)categoryName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" 
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryName LIKE %@", categoryName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		return item;
	}
	return nil;	
}

+ (void) deleteCategory: (NSString *) categoryName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Category" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryName LIKE %@", categoryName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[context deleteObject:item];
	}
	[CoreDataUtils saveChanges];
}

+ (void) deleteAllCategories {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Category" 
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[context deleteObject:item];
	}
	[CoreDataUtils saveChanges];
}

+ (void) moveProductsFromCategory: (NSString *)oldName toNewCategory: (NSString *) newName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Product" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryName LIKE %@", oldName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:newName forKey:@"categoryName"];
	}
	[CoreDataUtils saveChanges];
}

+ (void) insertNewCategoryWithName:(NSString *) categoryName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSManagedObject *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext: context];
	[category setValue:categoryName forKey:@"categoryName"];
	[CoreDataUtils saveChanges];
	
}

+ (void) renameCategory: (NSString *) categoryName withNewName: (NSString *) newName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Category" 
								   inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryName LIKE %@", categoryName];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
	
	for (NSManagedObject *item in items) {
		[item setValue:newName forKey:@"categoryName"];
	}
	[CoreDataUtils saveChanges];
}

@end
