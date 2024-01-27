//
//  ShoppingListCell.m
//  GroceryList
//
//  Created by pawel on 12/5/10.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "ShoppingListCell.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "StrikethroughView.h"
#import "CoreDataUtils.h"


@implementation ShoppingListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.contentView.backgroundColor = [UIColor clearColor];
		self.backgroundColor = [UIColor clearColor];
		
		iconImage = [[UIImageView alloc] initWithFrame:CGRectZero];
		iconImage.backgroundColor = [UIColor clearColor];
		iconImage.opaque = NO;
		iconImage.layer.cornerRadius = 5.0;
		iconImage.layer.masksToBounds = YES;
		iconImage.layer.borderColor = [UIColor clearColor].CGColor;
		iconImage.layer.borderWidth = 1.0;
		[self.contentView addSubview:iconImage];
		
		countBkgImage = [[UIImageView alloc] initWithFrame:CGRectZero];
		countBkgImage.backgroundColor = [UIColor clearColor];
		countBkgImage.opaque = NO;
		[self.contentView addSubview:countBkgImage];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.textColor = [UIColor blackColor];
		titleLabel.highlightedTextColor = [UIColor blackColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		titleLabel.adjustsFontSizeToFitWidth = YES;
		titleLabel.minimumFontSize = 17.0;
		titleLabel.backgroundColor = self.backgroundColor;
		[self.contentView addSubview:titleLabel];
		
		countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		countLabel.textColor = [UIColor blackColor];
		countLabel.highlightedTextColor = [UIColor blackColor];
		countLabel.font = [UIFont boldSystemFontOfSize: 12.0];
		countLabel.adjustsFontSizeToFitWidth = YES;
		countLabel.minimumFontSize = 10.0;
		countLabel.backgroundColor = self.backgroundColor;
		[self.contentView addSubview:countLabel];
		
		strikeThroughView = [[StrikethroughView alloc] initWithFrame:CGRectZero];
		strikeThroughView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setShoppingListItemManagedObject:(NSManagedObject *) shoppingListItem {
	NSString *productName = [shoppingListItem valueForKey:@"productName"];
	[titleLabel setText:productName];
	
	NSManagedObject *product = [CoreDataUtils findProduct:productName];
	UIImage *image = [product valueForKey:@"icon"];
	if (image == nil) {
		NSString *iconName = [NSString stringWithFormat:@"%@.png", [product valueForKey:@"productIconName"]];
		NSRange range;
		range.location = 0;
		range.length = [iconName length];
		iconName = [iconName stringByReplacingOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:range];
		image = [UIImage imageNamed:iconName];
		if (image == nil) {
			image = [UIImage imageNamed:@"default_product_icon.png"];
		}
	}
	[iconImage setImage:image];
	
	UIImage *bkgImage = [UIImage imageNamed:@"product_count_bkg.png"];
	[countBkgImage setImage:bkgImage];
	
	
	NSString *countText = [NSString stringWithFormat: @"%d", [(NSNumber *)[shoppingListItem valueForKey:@"purchaseCount"] intValue]];
	[countLabel setText:countText];
	
	if ([(NSNumber *)[shoppingListItem valueForKey:@"isPurchased"] boolValue]) {
		titleLabel.textColor = [UIColor grayColor];
		[self.contentView addSubview:strikeThroughView];
	} else {
		titleLabel.textColor = [UIColor whiteColor];
		[strikeThroughView removeFromSuperview];
	}
	[strikeThroughView setNeedsDisplay];
	[self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
	
	float inset = 5.0;
	CGRect bounds = [[self contentView] bounds];
	float h = bounds.size.height;
	float w = bounds.size.width;
	float valueWidth = 40.0;
	
	CGRect innerFrame = CGRectMake(inset, inset, h, h - inset * 2.0);
	[iconImage setFrame:innerFrame];
	
	innerFrame.origin.x += innerFrame.size.width + inset;
	innerFrame.size.width = w - (h + valueWidth + inset * 4);
	[titleLabel setFrame:innerFrame];
	
	CGSize textSize = [[titleLabel text] sizeWithFont:[titleLabel font]];
	[strikeThroughView setFrame:CGRectMake(innerFrame.origin.x, innerFrame.origin.y, textSize.width, h)];

	
	CGSize imageSize = countBkgImage.image.size;
	CGRect countBounds = CGRectMake(0, 0, 25, 25);
    float hRatio = countBounds.size.width / imageSize.width;
    float vRatio = countBounds.size.height / imageSize.height;
    float ratio = MIN(hRatio, vRatio);
	[countBkgImage sizeToFit];
    CGRect frame = countBkgImage.frame;
    frame.size.width = floorf(imageSize.width * ratio);
    frame.size.height = floorf(imageSize.height * ratio);
    frame.origin.x = inset;
    frame.origin.y = inset;
    [countBkgImage setFrame:frame];
	
	[countLabel sizeToFit];
    frame = countLabel.frame;
    frame.size.width = MIN(frame.size.width, bounds.size.width);
    frame.origin.y = (countBkgImage.frame.size.height/2 - frame.size.height/2) + countBkgImage.frame.origin.y;
    frame.origin.x = (countBkgImage.frame.size.width/2 - frame.size.width/2) + countBkgImage.frame.origin.x;
    [countLabel setFrame:frame];
}


@end
