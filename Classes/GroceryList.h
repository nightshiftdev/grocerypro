//
//  GroceryList.h
//  GroceryList
//
//  Created by pawel on 10/19/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface GroceryList :  NSManagedObject {
}

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *dateModified;

@end

