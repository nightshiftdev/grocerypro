//
//  ShoppingListCell.m
//  GroceryList
//
//  Created by pawel on 29/3/12.
//  Copyright 2012 __etcApps__. All rights reserved.
//

#import "GroceryListCell.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreData/CoreData.h>
#import "CoreDataUtils.h"


@implementation GroceryListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		
		self.contentView.backgroundColor = [UIColor clearColor];
		self.backgroundColor = [UIColor clearColor];
		
		iconImage = [[UIImageView alloc] initWithFrame:CGRectZero];
		iconImage.backgroundColor = [UIColor clearColor];
		iconImage.opaque = NO;
		iconImage.layer.masksToBounds = YES;
		[self.contentView addSubview:iconImage];
		
		titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.highlightedTextColor = [UIColor whiteColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
		titleLabel.adjustsFontSizeToFitWidth = NO;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		titleLabel.minimumFontSize = 17.0;
		titleLabel.backgroundColor = self.backgroundColor;
		[self.contentView addSubview:titleLabel];
		
		dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		dateLabel.textColor = [UIColor whiteColor];
		dateLabel.highlightedTextColor = [UIColor whiteColor];
		dateLabel.font = [UIFont italicSystemFontOfSize: 14.0];
		dateLabel.adjustsFontSizeToFitWidth = NO;
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
		dateLabel.minimumFontSize = 10.0;
		dateLabel.backgroundColor = self.backgroundColor;
		[self.contentView addSubview:dateLabel];
    }
    return self;
}

- (void)setGroceryListItemManagedObject:(NSManagedObject *) groceryListItem {
	NSString *listName = [groceryListItem valueForKey:@"name"];
	[titleLabel setText:listName];
	
	UIImage *image = [groceryListItem valueForKey:@"icon"];
	[iconImage setImage: image];
	
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
     
	[dateLabel setText:[dateFormatter stringFromDate:[groceryListItem valueForKey:@"dateModified"]]];
	[self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
	
	float inset = 10.0;
	CGRect bounds = [[self contentView] bounds];
	float w = bounds.size.width;

	[iconImage setFrame: CGRectMake(inset, inset, 48.0, 48.0)];
		
	CGSize listNameTextSize = [[titleLabel text] sizeWithFont:[titleLabel font]];
    CGSize textSize = [[dateLabel text] sizeWithFont:[titleLabel font]];
	
    [titleLabel sizeToFit];
	[titleLabel setFrame:CGRectMake((2 * inset) + iconImage.frame.size.width, inset, w - ((inset * 4) + iconImage.frame.size
                                                                                          .width),  listNameTextSize.height + (2 * inset))];

    
	[dateLabel sizeToFit];
    [dateLabel setFrame:CGRectMake((2 * inset) + iconImage.frame.size.width, inset + listNameTextSize.height, w - (inset * 4),  textSize.height + (2 * inset))];
}


@end
