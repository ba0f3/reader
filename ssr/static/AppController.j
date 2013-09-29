@import <Foundation/CPObject.j>
@import "Models/Category.j"

@import "Views/ContentView.j"
@import "Views/EntryListView.j"
@import "Views/NavigationView.j"

var NavigationAreaWidth = 200.0,
    ListAreaWidth = 300.0;

@implementation AppController : CPObject
{
    NavigationView navigationArea;
    EntryListView listArea;
    ContentView contentArea;
    CPView contentView
    CPSplitView verticalSplitter;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    contentView = [theWindow contentView];

    [self createLayout];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];
}

- (void)createLayout
{
    navigationArea = [[NavigationView alloc] initWithFrame:CGRectMake(0.0, 0.0, NavigationAreaWidth, CGRectGetHeight([contentView bounds]))];
    [contentView addSubview:navigationArea];

    verticalSplitter = [[CPSplitView alloc] initWithFrame:CGRectMake(NavigationAreaWidth, 0, CGRectGetWidth([contentView bounds]) - NavigationAreaWidth, CGRectGetHeight([contentView bounds]))];
    [verticalSplitter setDelegate:self];
    [verticalSplitter setVertical:YES];
    [verticalSplitter setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable ];
    [contentView addSubview:verticalSplitter];


    listArea = [[EntryListView alloc] initWithFrame:CGRectMake(0, 0, ListAreaWidth, CGRectGetHeight([verticalSplitter bounds]))];

    contentArea = [[ContentView alloc] initWithFrame:CGRectMake(ListAreaWidth, 0.0, CGRectGetWidth([verticalSplitter bounds]) - ListAreaWidth, CGRectGetHeight([verticalSplitter bounds]))];
    [contentArea setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [verticalSplitter addSubview:listArea];
    [verticalSplitter addSubview:contentArea];
    [verticalSplitter setButtonBar:[contentArea getButtonBar] forDividerAtIndex:0];
}

@end
