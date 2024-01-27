//
//  Product.h
//  GroceryList
//
//  Created by pawel on 1/15/11.
//  Copyright 2011 __etcApps__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Product :  NSManagedObject  {
}

@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSNumber *priority;
@property (nonatomic, strong) NSNumber *isUserCreated;
@property (nonatomic, strong) NSString *productIconName;

@end



