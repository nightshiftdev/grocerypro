#import <UIKit/UIKit.h>

#define CELL_CONENT_SIZE 60.0
#define CELL_SIZE 72.0

@interface ProductCell : UIView {
    UIImageView * mIconView;
	UIImageView * mCountBkgView;
	UILabel * mTitle;
	UILabel * mCount;
}
@property (nonatomic, strong) UIImage * icon;
@property (nonatomic, strong) UIImage * countBkgIcon;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * count;
@end
