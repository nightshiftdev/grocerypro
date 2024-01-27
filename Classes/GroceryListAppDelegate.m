//
//  GroceryListAppDelegate.m
//  GroceryList
//
//  Created by pawel on 8/10/10.
//  Copyright __etcApps__ 2010. All rights reserved.
//

#import "GroceryListAppDelegate.h"
#import "GroceryListsViewController.h"
#import "CoreDataUtils.h"
#import "UserInfoDialog.h"
#import "GPLogger.h"
#import "Macros.h"


@implementation GroceryListAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize managedObjectContext;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    [self populateDefaults];
	[self populateDefaultCategoriesForExistingProducts];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [CoreDataUtils saveChanges];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    [CoreDataUtils saveChanges];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [CoreDataUtils saveChanges];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        } 
    }
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}



#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil) {
        if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
            NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            moc.mergePolicy = [[NSMergePolicy alloc] 
                               initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
            [moc performBlockAndWait:^{
                [moc setPersistentStoreCoordinator: coordinator];
                
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mergeChangesFrom_iCloud:) name:NSPersistentStoreDidImportUbiquitousContentChangesNotification object:coordinator];
            }];
            managedObjectContext = moc;
        } else {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
        
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
		return managedObjectModel;
	}
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"GroceryLists" ofType:@"momd"];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
	return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSString *storePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"GroceryLists.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    
    NSPersistentStoreCoordinator* psc = persistentStoreCoordinator;
    
    if (IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Migrate datamodel
        NSDictionary *options = nil;
        
        // this needs to match the entitlements and provisioning profile
        NSURL *cloudURL = [fileManager URLForUbiquityContainerIdentifier:@"H8C9FVJMVW.com.etcapps.grocerypro"];
        NSString* coreDataCloudContent = [[cloudURL path] stringByAppendingPathComponent:@"data"];
        NSLog(@"core data cloud content %@", coreDataCloudContent);
        if ([coreDataCloudContent length] != 0) {
            // iCloud is available
            cloudURL = [NSURL fileURLWithPath:coreDataCloudContent];
            
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                       @"GroceryPro.store", NSPersistentStoreUbiquitousContentNameKey,
                       cloudURL, NSPersistentStoreUbiquitousContentURLKey,
                       nil];
        } else {
            // iCloud is not available
            options = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                       [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                       nil];
        }
        
        NSError *error = nil;
        [psc lock];
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [psc unlock];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"asynchronously added persistent store!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefetchAllDatabaseData" object:self userInfo:nil];
        });
    } else {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                                 nil];
        
        NSError *error = nil;
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return persistentStoreCoordinator;
}

- (void)mergeiCloudChanges:(NSNotification*)note forContext:(NSManagedObjectContext*)moc {
    [moc mergeChangesFromContextDidSaveNotification:note]; 
    
    NSNotification* refreshNotification = [NSNotification notificationWithName:@"RefreshAllViews" object:self  userInfo:[note userInfo]];
    
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
}

// NSNotifications are posted synchronously on the caller's thread
// make sure to vector this back to the thread we want, in this case
// the main thread for our views & controller
- (void)mergeChangesFrom_iCloud:(NSNotification *)notification {
    NSLog(@"mergeChangesFrom_iCloud");
    NSManagedObjectContext* moc = [self managedObjectContext];
    
    // this only works if you used NSMainQueueConcurrencyType
    // otherwise use a dispatch_async back to the main thread yourself
    [moc performBlock:^{
        [self mergeiCloudChanges:notification forContext:moc];
    }];
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark -
#pragma mark Core data products

- (BOOL)areProductsPopulated {	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	NSArray *products = [context executeFetchRequest:fetchRequest error:&error];
	
	if ([products count] > 0) {
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)doProductsHaveCategoriesAssigned {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext: context];
	[fetchRequest setEntity:entity];
	NSError *error = nil;
	NSArray *products = [context executeFetchRequest:fetchRequest error:&error];
	
	NSManagedObject *product = [products objectAtIndex: 0];
	NSString *categoryName = [product valueForKey:@"categoryName"];
	if ([categoryName length] == 0) {
		return NO;
	} else {
		return YES;
	}
}

- (void)populateDefaults {
	if (![self areProductsPopulated]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultProducts" ofType:@"plist"];
		NSDictionary *productNamesAndCategories = [[NSDictionary alloc] initWithContentsOfFile: path];
		NSArray *defaultProducts = [productNamesAndCategories allKeys];
		for (NSString *productName in defaultProducts) {
			NSString *category = [productNamesAndCategories valueForKey: productName];
			[self insertNewProductWithName:productName andAssignToCategory: category];
		}
		[self populateDefaultGroceryLists];
		[self populateDefaultCategories];
	} 
}

- (void)populateDefaultCategoriesForExistingProducts {
	if (![self doProductsHaveCategoriesAssigned]) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultProducts" ofType:@"plist"];
		NSDictionary *productNamesAndCategories = [[NSDictionary alloc] initWithContentsOfFile: path];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"productName" ascending:YES];
		NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
		[fetchRequest setSortDescriptors:sortDescriptors];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Product" inManagedObjectContext: context];
		[fetchRequest setEntity:entity];
		NSError *error = nil;
		NSArray *products = [context executeFetchRequest:fetchRequest error:&error];
		for(int productIndex = 0; productIndex < [products count]; productIndex++) {
			NSManagedObject *product = [products objectAtIndex:productIndex];
			NSString *productName = [product valueForKey:@"productName"];
			NSString *category = [productNamesAndCategories valueForKey: productName];
			if ([category length] == 0) {
				category = @"other";
			}
			[product setValue:category forKey:@"categoryName"];
			[CoreDataUtils saveChanges];
		}
		[self populateDefaultCategories];
	} 
}

- (void)populateDefaultGroceryLists {
	//Weekly
	NSString *weeklyDefaultList = @"Weekly";
	[CoreDataUtils insertGroceryListWithName:weeklyDefaultList];
	[self insertShoppingListItem:@"bread" withCount:2 forGroceryList:weeklyDefaultList];
	[self insertShoppingListItem:@"butter" withCount:1 forGroceryList:weeklyDefaultList];
	[self insertShoppingListItem:@"orange juice" withCount:3 forGroceryList:weeklyDefaultList];
	[self insertShoppingListItem:@"eggs" withCount:24 forGroceryList:weeklyDefaultList];
	[self insertShoppingListItem:@"milk" withCount:2 forGroceryList:weeklyDefaultList];
	//Green Bean Casserole
	NSString *casseroleDefaultList = @"Green Bean Casserole";
	[CoreDataUtils insertGroceryListWithName:casseroleDefaultList];
	[self insertShoppingListItem:@"mushroom soup" withCount:1 forGroceryList:casseroleDefaultList];
	[self insertShoppingListItem:@"peppers" withCount:1 forGroceryList:casseroleDefaultList];
	[self insertShoppingListItem:@"milk" withCount:1 forGroceryList:casseroleDefaultList];
	[self insertShoppingListItem:@"onions" withCount:1 forGroceryList:casseroleDefaultList];
	[self insertShoppingListItem:@"green beans" withCount:1 forGroceryList:casseroleDefaultList];
	//Banana Bread
	NSString *bananaBreadDefaultList = @"Banana Bread";
	[CoreDataUtils insertGroceryListWithName:bananaBreadDefaultList];
	[self insertShoppingListItem:@"flour" withCount:1 forGroceryList:bananaBreadDefaultList];
	[self insertShoppingListItem:@"baking soda" withCount:1 forGroceryList:bananaBreadDefaultList];
	[self insertShoppingListItem:@"salt" withCount:1 forGroceryList:bananaBreadDefaultList];
	[self insertShoppingListItem:@"butter" withCount:1 forGroceryList:bananaBreadDefaultList];
	[self insertShoppingListItem:@"brown sugar" withCount:1 forGroceryList:bananaBreadDefaultList];
	[self insertShoppingListItem:@"eggs" withCount:2 forGroceryList:bananaBreadDefaultList];
	[self insertShoppingListItem:@"bananas" withCount:3 forGroceryList:bananaBreadDefaultList];
}

- (void)insertNewProductWithName: (NSString *) name andAssignToCategory: (NSString *) category {
	NSManagedObjectContext *context = self.managedObjectContext;
	NSManagedObject *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext: context];
	[product setValue:name forKey:@"productName"];
	NSString *iconName;
	iconName = [NSString stringWithFormat:@"%@.png", name];
	int iconNameLength = [iconName length];
	NSRange range;
	range.location = 0;
	range.length = iconNameLength;
	iconName = [iconName stringByReplacingOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:range];
	[product setValue:[NSNumber numberWithBool:NO] forKey:@"isUserCreated"];
	[product setValue:iconName forKey:@"productIconName"];
	[product setValue:[NSNumber numberWithInt:0] forKey:@"priority"];
	NSString * categoryName = @"other";
	if ([category length] != 0) {
		categoryName = category;
	}
	[product setValue:categoryName forKey:@"categoryName"];
	[CoreDataUtils saveChanges];
}

- (void) insertShoppingListItem:(NSString *)productName withCount:(int)purchaseCount forGroceryList:(NSString *) listName {
	NSManagedObjectContext *context = ((GroceryListAppDelegate *)[[UIApplication sharedApplication] delegate]).managedObjectContext;
	NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:@"ShoppingListItem" inManagedObjectContext:context];
	[item setValue:productName forKey:@"productName"];
	[item setValue:listName forKey:@"groceryListName"];
	[item setValue:[NSNumber numberWithBool:NO] forKey:@"isPurchased"];
	[item setValue:[NSNumber numberWithInt:purchaseCount] forKey:@"purchaseCount"];
	[CoreDataUtils saveChanges];
}

- (void) populateDefaultCategories {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultProducts" ofType:@"plist"];
	NSDictionary *productNamesAndCategories = [[NSDictionary alloc] initWithContentsOfFile: path];
	NSArray *allCategories = [productNamesAndCategories allValues];
	NSArray *categoriesNoDups = [[NSSet setWithArray:allCategories] allObjects];
	NSManagedObjectContext *context = self.managedObjectContext;
	for (int categoryIndex = 0; categoryIndex < [categoriesNoDups count]; categoryIndex++) {
		NSManagedObject *category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext: context];
		NSString *categoryName = [categoriesNoDups objectAtIndex:categoryIndex];
		[category setValue:categoryName forKey:@"categoryName"];
		[CoreDataUtils saveChanges];
	}
	NSManagedObject *otherCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext: context];
	NSString *otherCategoryName = @"other";
	[otherCategory setValue:otherCategoryName forKey:@"categoryName"];
	[CoreDataUtils saveChanges];
}

@end

