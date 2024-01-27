#import "ProductCell.h"
#import "ProductSelectorViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProductCell


- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame: frame];
    if ( self == nil )
        return ( nil );
	
	mTitle = [[UILabel alloc] initWithFrame: CGRectZero];
	mTitle.textColor = [UIColor whiteColor];
	mTitle.highlightedTextColor = [UIColor whiteColor];
    mTitle.font = [UIFont boldSystemFontOfSize: 12.0];
    mTitle.adjustsFontSizeToFitWidth = YES;
    mTitle.minimumFontSize = 10.0;
	
	mCount = [[UILabel alloc] initWithFrame: CGRectZero];
	mCount.textColor = [UIColor blackColor];
	mCount.highlightedTextColor = [UIColor blackColor];
    mCount.font = [UIFont boldSystemFontOfSize: 12.0];
	mCount.adjustsFontSizeToFitWidth = YES;
    mCount.minimumFontSize = 10.0;
	
    mIconView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, CELL_CONENT_SIZE, CELL_CONENT_SIZE)];
    mIconView.backgroundColor = [UIColor clearColor];
    mIconView.opaque = NO;
	mIconView.layer.cornerRadius = 5.0;
	mIconView.layer.masksToBounds = YES;
	mIconView.layer.borderColor = [UIColor clearColor].CGColor;
	mIconView.layer.borderWidth = 1.0;

	
	mCountBkgView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 25, 25)];
    mCountBkgView.backgroundColor = [UIColor clearColor];
    mCountBkgView.opaque = NO;

    [self addSubview: mIconView];
	[self addSubview: mCountBkgView];
	[self addSubview: mTitle];
	[self addSubview: mCount];
    
    self.backgroundColor = [UIColor clearColor];
    
	mTitle.backgroundColor = self.backgroundColor;
	mCount.backgroundColor = self.backgroundColor;
	
    self.opaque = NO;
    
    return (self);
}


- (UIImage *) icon {
    return ( mIconView.image );
}

- (void) setIcon: (UIImage *) aIcon {
    mIconView.image = aIcon;
}

- (UIImage *) countBkgIcon {
    return ( mCountBkgView.image );
}

- (void) setCountBkgIcon: (UIImage *) aIcon {
	mCountBkgView.image = aIcon;
}

- (NSString *) title {
    return ( mTitle.text );
}

- (void) setTitle: (NSString *) aTitle {
    mTitle.text = aTitle;
    [self setNeedsLayout];
}

- (NSString *) count {
	return ( mCount.text );
}

- (void) setCount: (NSString *) aCount {
    mCount.text = aCount;
    [self setNeedsLayout];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
	if (mIconView.image == nil) {
		return;
	}
	
    CGSize imageSize = mIconView.image.size;
    CGRect bounds = CGRectInset( self.bounds, 1.0, 1.0 );
    
    [mTitle sizeToFit];
    CGRect frame = mTitle.frame;
    frame.size.width = MIN(frame.size.width, bounds.size.width);
    frame.origin.y = CGRectGetMaxY(bounds) - frame.size.height;
    frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    mTitle.frame = frame;
    
    // adjust the frame down for the image layout calculation
    bounds.size.height = frame.origin.y - bounds.origin.y;
    
    if ((imageSize.width <= bounds.size.width) &&
        (imageSize.height <= bounds.size.height)) {
        return;
    }
    
    // scale it down to fit
    CGFloat hRatio = bounds.size.width / imageSize.width;
    CGFloat vRatio = bounds.size.height / imageSize.height;
    CGFloat ratio = MIN(hRatio, vRatio);
    
    [mIconView sizeToFit];
    frame = mIconView.frame;
    frame.size.width = floorf(imageSize.width * ratio);
    frame.size.height = floorf(imageSize.height * ratio);
    frame.origin.x = floorf((bounds.size.width - frame.size.width) * 0.5);
    frame.origin.y = floorf((bounds.size.height - frame.size.height) * 0.5);
    mIconView.frame = frame;

	[mCount sizeToFit];
    frame = mCount.frame;
    frame.size.width = MIN(frame.size.width, bounds.size.width);
    frame.origin.y = (mCountBkgView.frame.size.height/2 - frame.size.height/2) + mCountBkgView.frame.origin.y;
    frame.origin.x = (mCountBkgView.frame.size.width/2 - frame.size.width/2) + mCountBkgView.frame.origin.x;
    mCount.frame = frame;
}

@end
