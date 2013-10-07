@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>

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
        var x = (CGRectGetWidth(aFrame) - 16) / 2,
            y = (CGRectGetHeight(aFrame) - 16) / 2 ;
    	imageView = [[CPImageView alloc] initWithFrame:CGRectMake(x, y, 16.0, 16.0)];
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
