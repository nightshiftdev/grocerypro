//
//  CoreDataUtils.h
//  GroceryList
//
//  Created by pawel on 12/26/10.
//  Copyright 2010 etcApps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NUMBER_OF_DEFAULT_GROCERY_LIST_ICONS 4

@class NSManagedObject;

@interface CoreDataUtils : NSObject {
}

+ (void)saveChanges;
+ (void)updateGroceryListDateModified:(NSString*)groceryListName;
+ (void)insertGroceryListWithName:(NSString *) groceryListName;
+ (BOOL)findGroceryList:(NSString *)groceryListName;
+ (void)deleteGroceryList:(NSString *)groceryListName;
+ (NSManagedObject*)findProduct:(NSString *)productName;
+ (NSManagedObject*)findCategory:(NSString *)categoryName;
+ (void) deleteCategory: (NSString *) categoryName;
+ (void) deleteAllCategories;
+ (void) moveProductsFromCategory: (NSString *)oldName toNewCategory: (NSString *) newName;
+ (void) insertNewCategoryWithName:(NSString *) categoryName;
+ (void) renameCategory: (NSString *) categoryName withNewName: (NSString *) newName;

@end
