//
//  TextInputDialog.m
//  GroceryList
//
//  Created by pawel on 6/27/11.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import "TableAlertView.h"

@implementation TableAlertView

@synthesize caller;
@synthesize context;
@synthesize data;

-(id)initWithCaller:(id<TableAlertViewDelegate>) _caller
			   data:(NSArray *) _data
			  title:(NSString *) _title andContext:(id) _context {
    
	tableHeight = 0;
	NSMutableString *msgString = [NSMutableString string];
	if ([_data count] >= MAX_VISIBLE_ROWS) {
		tableHeight = 255;
		[msgString setString:@"\n\n\n\n\n\n\n\n\n\n\n\n"];
	} else {
		tableHeight = [_data count] * 50;
		for(id value in _data) {
			[msgString appendString:@"\n\n"];
		}
		if ([_data count] == 1) {
			tableHeight += 5;
		}
		if ([_data count] == MAX_VISIBLE_ROWS - 1) {
			tableHeight -= 15;
		}
	}
	if (self = [super initWithTitle:_title
                            message:msgString
                           delegate:self
                  cancelButtonTitle:@"Cancel" 
                  otherButtonTitles:nil]) {
		self.caller = _caller;
		self.context = _context;
		self.data = _data;
		[self prepare];
	}
	return self;
}

-(void)prepare {
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 38, 255, tableHeight) style:UITableViewStyleGrouped];
	tableView.backgroundColor = [UIColor clearColor];
	if ([data count] < MAX_VISIBLE_ROWS) {
		tableView.scrollEnabled = NO;
	}
	tableView.delegate = self;
	tableView.dataSource = self;
	[self addSubview:tableView];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self dismissWithClickedButtonIndex:0 animated:YES];
	[self.caller didSelectRowAtIndex:indexPath.row withContext:self.context];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellID = @"TableAlertViewCellID";
	UITableViewCell *cell = (UITableViewCell *)[tv dequeueReusableCellWithIdentifier:cellID];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:cellID];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	cell.textLabel.text = [[data objectAtIndex:indexPath.row] valueForKey:@"categoryName"];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [data count];
}

@end
