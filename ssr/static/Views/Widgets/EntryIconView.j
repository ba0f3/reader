@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>

@implementation EntryIconView : CPView
{
    CPImageView icon;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        [self setBackgroundColor:[CPColor colorWithHexString:"C6C6C6"]];

        var image = [[CPImage alloc] initWithContentsOfFile:"static/Resources/rss.png" size:CGSizeMake(16.0, 16.0)];

        icon = [[CPImageView alloc] initWithFrame:CGRectMake(2.0, 5.0, 16.0, 16.0)];

        [icon setImage:image];

        [self addSubview:icon];
    }
    return self;
}

- (void)setObjectValue:(id)anEntry
{
    if (!anEntry)
        return;
    //TODO: set icon
}
@end
