@import <AppKit/CPView.j>

@implementation ContentView : CPView
{
   CPButtonBar buttonBar; 
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([self bounds]) - 26.0, CGRectGetWidth([self bounds]), 26.0)];
        [buttonBar setHasResizeControl:YES];
        [buttonBar setResizeControlIsLeftAligned:YES];

        [self addSubview:buttonBar];

        var starButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
        [starButton setBordered:NO];
        [starButton setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/star.png" size:CGSizeMake(16, 16)]];
        [starButton setImagePosition:CPImageOnly];
        [starButton setAction:@selector(remove:)];
        [starButton setTarget:self];
        [starButton setEnabled:YES];

        var fullscreenButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
        [fullscreenButton setBordered:NO];
        [fullscreenButton setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/fullscreen.png" size:CGSizeMake(16, 16)]];
        [fullscreenButton setImagePosition:CPImageOnly];
        [fullscreenButton setAction:@selector(remove:)];
        [fullscreenButton setTarget:self];
        [fullscreenButton setEnabled:YES];

        [buttonBar setButtons:[fullscreenButton, starButton]];
        [buttonBar setAutoresizingMask:CPViewWidthSizable | CPViewMinXMargin | CPViewMinYMargin];

    }

    return self;
}

- (CPButtonBar)getButtonBar
{
    return buttonBar;
}
@end
