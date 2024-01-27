//
//  ProductSelectorRowCell.h
//  GroceryList
//
//  Created by pawel on 6/19/11.
//  Copyright 2011 __etcApps__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_MARGIN 18.0

@interface ProductSelectorRowCell : UITableViewCell {
	NSMutableArray *productCells;
	NSArray *productItems;
	NSUInteger numberOfColums;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNumberOfCols:(NSUInteger)numOfCols;
- (void)setProducts:(NSArray *)products;
- (NSArray *)getProductCells;

@end
