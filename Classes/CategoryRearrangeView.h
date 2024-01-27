//
//  CategoryRearrangeView.h
//  GroceryList
//
//  Created by pawel on 7/3/11.
//  Copyright 2011 __etcApps__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_VISIBLE_ROWS 4

@protocol CategoryRearrangeViewDelegate
-(void)rearrangedCategories:(id)context;
-(void)deletedCategory:(id)context;
-(void)renamedCategory:(id)context;
@end

@interface CategoryRearrangeView : UIAlertView <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
	id<CategoryRearrangeViewDelegate> caller;
	id	context;
	NSMutableArray *data;
	NSUInteger tableHeight;
}

-(id)initWithCaller:(id<CategoryRearrangeViewDelegate>) _caller
			   data:(NSArray *) _data
			  title:(NSString *) _title andContext:(id) _context;
@property (nonatomic, strong) id<CategoryRearrangeViewDelegate> caller;
@property (nonatomic, strong) id context;
@property (nonatomic, strong) NSMutableArray *data;

@end

@interface CategoryRearrangeView(HIDDEN)
-(void) prepare;
@end
