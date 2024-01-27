//
//  GroceryListAppDelegate.h
//  GroceryList
//
//  Created by pawel on 8/10/10.
//  Copyright __etcApps__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class GroceryListsViewController;

@interface GroceryListAppDelegate : NSObject <UIApplicationDelegate> {
    
	NSManagedObjectModel* managedObjectModel;
    NSManagedObjectContext* managedObjectContext;	    
    NSPersistentStoreCoordinator* persistentStoreCoordinator;
	
    UIWindow* window;
    UINavigationController* navigationController;
}

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;

- (NSString *)applicationDocumentsDirectory;
- (void)populateDefaults;
- (void)populateDefaultGroceryLists;
- (BOOL)areProductsPopulated;
- (void)insertNewProductWithName: (NSString *) name andAssignToCategory: (NSString *) category;
- (void)insertShoppingListItem:(NSString *)productName withCount:(int)purchaseCount forGroceryList:(NSString *) listName;
- (void)populateDefaultCategoriesForExistingProducts;
- (void) populateDefaultCategories;

@end

