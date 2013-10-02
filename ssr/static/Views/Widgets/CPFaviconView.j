@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>
@import "EntryIconView.j"

var GETFV_SERVICE = @"http://g.etfv.co/"
@implementation CPFaviconView : CPView
{
	CPString url;
	CPImage image;
	CPImageView imageView
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
    	imageView = [[CPImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]))];
    	[self addSubview:imageView]
	}
	return self;
}

- (void)setObjectValue:(id)anEntry
{
	url = [anEntry site];
    image = [[CPImage alloc] initWithContentsOfFile:(GETFV_SERVICE + url) size:CGSizeMake(16.0, 16.0)];
    [imageView setImage:image];
}
@end
