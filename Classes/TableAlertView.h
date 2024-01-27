//
//  TableAlertView.h
//  GroceryList
//
//  Created by pawel on 6/27/11.
//  Copyright 2011 __etcApps__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_VISIBLE_ROWS 4

@protocol TableAlertViewDelegate
	-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context;
@end

@interface TableAlertView : UIAlertView <UITableViewDelegate, UITableViewDataSource> {
	UITableView *tableView;
	id<TableAlertViewDelegate> caller;
	id	context;
	NSArray *data;
	NSUInteger tableHeight;
}

-(id)initWithCaller:(id<TableAlertViewDelegate>) _caller
			   data:(NSArray *) _data
			  title:(NSString *) _title andContext:(id) _context;
@property (nonatomic, strong) id<TableAlertViewDelegate> caller;
@property (nonatomic, strong) id context;
@property (nonatomic, strong) NSArray *data;

@end

@interface TableAlertView(HIDDEN)
-(void) prepare;
@end
