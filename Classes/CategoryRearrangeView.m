//
//  CategoryRearrangeView.m
//  GroceryList
//
//  Created by pawel on 6/27/11.
//  Copyright 2010 __etcApps__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CategoryRearrangeView.h"
#import "CoreDataUtils.h"
#import "TextInputDialog.h"

@implementation CategoryRearrangeView

@synthesize caller;
@synthesize context;
@synthesize data;

-(id)initWithCaller:(id<CategoryRearrangeViewDelegate>) _caller
			   data:(NSMutableArray *) _data
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
                  otherButtonTitles:@"Save", nil]) {
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
	tableView.allowsSelectionDuringEditing = YES;
	[tableView setEditing:YES animated:YES];
	[self addSubview:tableView];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[CoreDataUtils deleteAllCategories];
		for (int index = 0; index < [data count]; index++) {
			 NSString *categoryName = [data objectAtIndex:index];
			[CoreDataUtils insertNewCategoryWithName:categoryName];
		}
		[self.caller rearrangedCategories:nil];
	}
}	

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *currentName = [data objectAtIndex:indexPath.row];
	if( [currentName caseInsensitiveCompare:@"other"] == NSOrderedSame ) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		return;
	}
	[self.caller renamedCategory:currentName];
	[self dismissWithClickedButtonIndex:0 animated:YES];
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
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.textLabel.text = [data objectAtIndex:indexPath.row];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [data count];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *categoryName = [data objectAtIndex:indexPath.row];
	if (![categoryName isEqual:@"other"]) {
		return YES;
	} else {
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSString *categoryName = [data objectAtIndex:indexPath.row];
		[self.caller deletedCategory:categoryName];
		[self dismissWithClickedButtonIndex:0 animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSString *item = [data objectAtIndex:fromIndexPath.row];
	[data removeObjectAtIndex:fromIndexPath.row];
	[data insertObject:item atIndex:toIndexPath.row];
}

@end
