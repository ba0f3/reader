@import <AppKit/CPImage.j>
@import <AppKit/CPImageView.j>
@import "CPFaviconView.j"

@implementation FolderItemView : CPView
{
    CPFaviconView icon;
    CPTextField name;
    CPTextField unread;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        icon = [[CPFaviconView alloc] initWithFrame:CGRectMake(0, 2.0, 20, 20)];
        name = [[CPTextField alloc] initWithFrame:CGRectMake(20.0, 0.0, CGRectGetWidth([self bounds]) - 20.0, 24)];
        [name setAutoresizingMask:CPViewWidthSizable];
        [name setLineBreakMode:CPLineBreakByTruncatingTail];

        [self addSubview:icon];
        [self addSubview:name];
    }
    return self;
}

- (BOOL)setThemeState:(ThemeState)aState
{
    if (aState == CPThemeStateGroupRow || aState == "CPThemeStateGroupRow")
        [icon removeFromSuperview];
    return [super setThemeState:aState];
}

//hasThemeState
- (void)setObjectValue:(id)anEntry
{
    CPLog('setObjectValue:%@', anEntry);

    if (!anEntry)
        return;

    if ([self hasThemeState:CPThemeStateGroupRow])
        CPLog('CPThemeStateGroupRow');
    else
        CPLog('CPThemeStateTableDataView');

    [name setStringValue:anEntry];
}
@end
