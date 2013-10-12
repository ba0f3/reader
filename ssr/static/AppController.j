@import <Foundation/CPObject.j>
//import <GCKit/GCFontIconView.j>

@import "Constants.j"
@import "Views/ContentView.j"
@import "Views/HeadlineView.j"
@import "Views/NavigationView.j"
@import "Models/User.j"
@import "Controllers/LoginController.j"

var NavigationAreaWidth = 250.0,
    HeadlineAreaWidth = 300.0;


var LogoToolbarItemIdentifier = "LogoToolbarItemIdentifier",
    EntryFilterToolbarIdentifier = "EntryFilterToolbarIdentifier",
    EntryOrderToolbarIdentifier = "EntryOrderToolbarIdentifier",
    SearchControlToolbarIdentifier = "SearchControlToolbarIdentifier";

@implementation AppController : CPObject
{
    User user;
    NavigationView navigationArea;
    HeadlineView headlineArea;
    ContentView contentArea;
    CPView contentView
    CPSplitView verticalSplitter;
    CPWindow theWindow
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserLoggedIn:) name:NOTIFICATION_USER_LOGGED_IN object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserLoggedOut:) name:NOTIFICATION_USER_LOGGED_OUT object:nil];

    [[LoginController sharedLoginController] openSession];

    User = nil;

    theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask];
    contentView = [theWindow contentView];

    var toolbar = [[CPToolbar alloc] initWithIdentifier:"Toolbar"];
    [toolbar setDelegate:self];
    [toolbar setVisible:YES];

    [theWindow setToolbar:toolbar];

    [self createLayout];

    //[theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];

}

- (void)onUserLoggedIn:(CPNotification)notification
{
    CPLog('AppController.onUserLoggedIn:%@', notification);
    user = [notification object];

    [theWindow orderFront:self];
}

- (void)onUserLoggedOut:(CPNotification)notification
{
    CPLog('AppController.onUserLoggedOut:%@', notification);

    [theWindow orderOut:self];
}

- (void)createLayout
{
    navigationArea = [[NavigationView alloc] initWithFrame:CGRectMake(0.0, 0.0, NavigationAreaWidth, CGRectGetHeight([contentView bounds]))];
    [contentView addSubview:navigationArea];

    // +2 => space b/w views
    verticalSplitter = [[CPSplitView alloc] initWithFrame:CGRectMake(NavigationAreaWidth + 2, 0, CGRectGetWidth([contentView bounds]) - NavigationAreaWidth, CGRectGetHeight([contentView bounds]))];
    [verticalSplitter setDelegate:self];
    [verticalSplitter setVertical:YES];
    [verticalSplitter setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable ];
    [contentView addSubview:verticalSplitter];


    headlineArea = [[HeadlineView alloc] initWithFrame:CGRectMake(0, 0, HeadlineAreaWidth, CGRectGetHeight([verticalSplitter bounds]))];

    contentArea = [[ContentView alloc] initWithFrame:CGRectMake(HeadlineAreaWidth, 0.0, CGRectGetWidth([verticalSplitter bounds]) - HeadlineAreaWidth, CGRectGetHeight([verticalSplitter bounds]))];
    [contentArea setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [verticalSplitter addSubview:headlineArea];
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

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [CPToolbarFlexibleSpaceItemIdentifier, LogoToolbarItemIdentifier, SearchControlToolbarIdentifier];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [CPToolbarFlexibleSpaceItemIdentifier, SearchControlToolbarIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
    [toolbarItem setTarget:self];
    if (anItemIdentifier == LogoToolbarItemIdentifier)
    {
        var view = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
        [view setStringValue:@"Doda Reader"];
        [view setFont:[CPFont boldFontWithName:'Fugaz One' size:20]];
        [view setTextColor:[CPColor colorWithHexString:@"ccc"]];
        [view setTextShadowColor:[CPColor colorWithHexString:@"222"]];
        [view setTextShadowOffset:CGSizeMake(0.5, 1.0)];
        [view sizeToFit];
    }
    else if (anItemIdentifier == SearchControlToolbarIdentifier)
    {
        var view = [[CPSearchField alloc] initWithFrame:CGRectMake(0.0, 0.0, 160, 29)];
        [view setPlaceholderString:@"Enter keyword"];
        [toolbarItem setLabel:@"Search"];

    }

    [toolbarItem setView:view];
    [toolbarItem setMinSize:CGSizeMake(CGRectGetWidth([view bounds]), CGRectGetHeight([view bounds]))];
    [toolbarItem setMaxSize:CGSizeMake(CGRectGetWidth([view bounds]), CGRectGetHeight([view bounds]))];
    return toolbarItem;
}
@end
