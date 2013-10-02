@import <Foundation/CPObject.j>

@import "Constants.j"
@import "Controllers/CategoryController.j"
@import "Controllers/HeadlineController.j"
@import "Views/ContentView.j"
@import "Views/ListView.j"
@import "Views/NavigationView.j"

var NavigationAreaWidth = 200.0,
    ListAreaWidth = 300.0;

@implementation AppController : CPObject
{
    NavigationView navigationArea;
    ListView listArea;
    ContentView contentArea;
    CPView contentView
    CPSplitView verticalSplitter;
    CategoryController categoryController @accessors(readonly);
    HeadlineController headlineController @accessors(readonly);
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    contentView = [theWindow contentView];

    [self createLayout];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];

    //TODO: xu ly sau khi login
    categoryController = [[CategoryController alloc] init];
    headlineController = [[HeadlineController alloc] init];
}

- (void)createLayout
{
    navigationArea = [[NavigationView alloc] initWithFrame:CGRectMake(0.0, 0.0, NavigationAreaWidth, CGRectGetHeight([contentView bounds]))];
    [contentView addSubview:navigationArea];

    // +2 => space b/w views
    verticalSplitter = [[CPSplitView alloc] initWithFrame:CGRectMake(NavigationAreaWidth+2, 0, CGRectGetWidth([contentView bounds]) - NavigationAreaWidth, CGRectGetHeight([contentView bounds]))];
    [verticalSplitter setDelegate:self];
    [verticalSplitter setVertical:YES];
    [verticalSplitter setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable ];
    [contentView addSubview:verticalSplitter];


    listArea = [[ListView alloc] initWithFrame:CGRectMake(0, 0, ListAreaWidth, CGRectGetHeight([verticalSplitter bounds]))];

    contentArea = [[ContentView alloc] initWithFrame:CGRectMake(ListAreaWidth, 0.0, CGRectGetWidth([verticalSplitter bounds]) - ListAreaWidth, CGRectGetHeight([verticalSplitter bounds]))];
    [contentArea setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [verticalSplitter addSubview:listArea];
    [verticalSplitter addSubview:contentArea];
    [verticalSplitter setButtonBar:[contentArea getButtonBar] forDividerAtIndex:0];
}

+ (void)setState
{

}

- (BOOL)splitView:(CPSplitView)aSplitView canCollapseSubview:(CPView)aSubview
{
    return YES;
}

- (BOOL)splitView:(CPSplitView)aSplitView shouldCollapseSubview:(CPView)aSubview forDoubleClickOnDividerAtIndex:(int)indexOfDivider
{
    return YES;
}
@end
