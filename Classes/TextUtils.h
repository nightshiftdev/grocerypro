//
//  TextUtils.h
//  GroceryList
//
//  Created by pawel on 11/30/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextUtils : NSObject {

}

+ (BOOL)isEmpty:(NSString *)string;
+ (NSString *)trimWhitespace:(NSString *)string;

@end
