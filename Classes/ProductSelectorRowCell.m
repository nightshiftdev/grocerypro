//
//  ProductSelectorRowCell.m
//  GroceryList
//
//  Created by pawel on 6/19/11.
//  Copyright 2011 __etcApps__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ProductSelectorRowCell.h"
#import "ProductCell.h"

@implementation ProductSelectorRowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNumberOfCols:(NSUInteger)numOfCols {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	numberOfColums = numOfCols;
	if (self) {
		productCells = [[NSMutableArray alloc] init];
		for (int i=0; i < numOfCols; i++) {
			ProductCell *cell = [[ProductCell alloc] initWithFrame: CGRectMake(CELL_MARGIN + CELL_SIZE * i, 0, CELL_CONENT_SIZE, CELL_CONENT_SIZE)];
			[productCells addObject: cell];
			[self.contentView addSubview:cell];
		}
    }
    return self;
}

- (void)setProducts:(NSArray *)products {
	productItems = [NSArray arrayWithArray:products];
	int itemCount = [products count]; 
	for (NSUInteger colIndex = 0; colIndex < numberOfColums; colIndex++) {
		if (colIndex < itemCount) {
			NSManagedObject *product = [productItems objectAtIndex: colIndex];
			NSString *productName = [product valueForKey:@"productName"];
			UIImage *image = [product valueForKey:@"icon"];
			if (image == nil) {
				NSString *productIconName = [product valueForKey:@"productIconName"];
				image = [UIImage imageNamed:productIconName];
			}
			ProductCell *cell = [productCells objectAtIndex:colIndex];
			cell.icon = image;
			cell.title = productName;
		} else {
			ProductCell *cell = [productCells objectAtIndex:colIndex];
			cell.icon = nil;
			cell.title = nil;
		}
	}
}

- (NSArray *)getProductCells {
	return productCells;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state.
}



@end
