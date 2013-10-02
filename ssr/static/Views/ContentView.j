@import <AppKit/CPView.j>

@implementation ContentView : CPView
{
   CPButtonBar buttonBar;
   CPView welcomeMessage;
   CPScrollView scrollView;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]) - 26.0)];
        [scrollView setAutohidesScrollers:YES];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setHasVerticalScroller:YES]; 
        [scrollView setBackgroundColor:[CPColor colorWithHexString:"222"]];
        [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [self addSubview:scrollView];

        [self showWelcomeMessage];

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

- (void)showWelcomeMessage
{
    if(!welcomeMessage)
    {
        welcomeMessage = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]) - 26)];
        [welcomeMessage setBackgroundColor:[CPColor colorWithHexString:"222"]];
        [welcomeMessage setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [self addSubview:welcomeMessage];

        var first = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight([scrollView bounds])/2 - 50, CGRectGetWidth([scrollView bounds]), 200.0)];
        [first setStringValue:@"Welcome to Doda Reader"];
        [first setAutoresizingMask:CPViewWidthSizable | CPViewMaxXMargin | CPViewMinYMargin];
        [first setFont:[CPFont boldFontWithName:'Titillium Web' size:36 italic:YES]];
        [first setTextColor:[CPColor colorWithHexString:@"333"]];
        [first setTextShadowColor:[CPColor colorWithHexString:@"000"]];
        [first setTextShadowOffset:CGSizeMake(0.0, 1.0)];
        [first setAlignment:CPCenterTextAlignment];
        [welcomeMessage addSubview:first];

        var second = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, CGRectGetHeight([scrollView bounds])/2, CGRectGetWidth([scrollView bounds]), 200.0)];
        [second setStringValue:@"Please select an article to continue"];
        [second setAutoresizingMask:CPViewWidthSizable | CPViewMinXMargin | CPViewMinYMargin];
        [second setFont:[CPFont boldFontWithName:'Open Sans' size:16]];
        [second setTextColor:[CPColor colorWithHexString:@"333"]];
        [second setTextShadowColor:[CPColor colorWithHexString:@"000"]];
        [second setTextShadowOffset:CGSizeMake(1.0, 1.0)];
        [second setAlignment:CPCenterTextAlignment];
        [welcomeMessage addSubview:second];
    }
    [scrollView setHidden:YES];
    [welcomeMessage setHidden:NO];
}
- (void)showArticle
{
    [scrollView setHidden:NO];
    [welcomeMessage setHidden:YES];
}
- (CPButtonBar)getButtonBar
{
    return buttonBar;
}
@end
