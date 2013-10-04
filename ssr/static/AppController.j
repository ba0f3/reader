@import <Foundation/CPObject.j>

@import "Constants.j"
@import "Controllers/CategoryController.j"
@import "Controllers/HeadlineController.j"
@import "Views/ContentView.j"
@import "Views/ListView.j"
@import "Views/NavigationView.j"
@import "Models/User.j"
@import "Controllers/LoginController.j"

var NavigationAreaWidth = 200.0,
    ListAreaWidth = 300.0;


var LogoToolbarItemIdentifier = "LogoToolbarItemIdentifier";

@implementation AppController : CPObject
{
    User user;
    NavigationView navigationArea;
    ListView listArea;
    ContentView contentArea;
    CPView contentView
    CPSplitView verticalSplitter;
    CategoryController categoryController @accessors(readonly);
    HeadlineController headlineController @accessors(readonly);

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
    User = [[User alloc] initFromObject:[notification object]];

    [theWindow orderFront:self];

    categoryController = [[CategoryController alloc] init];
    headlineController = [[HeadlineController alloc] init];
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

// Return an array of toolbar item identifier (all the toolbar items that may be present in the toolbar)
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [CPToolbarFlexibleSpaceItemIdentifier, LogoToolbarItemIdentifier];
}

// Return an array of toolbar item identifier (the default toolbar items that are present in the toolbar)
- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return [LogoToolbarItemIdentifier, CPToolbarFlexibleSpaceItemIdentifier];
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
    var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];
    [toolbarItem setTarget:self];
    if (anItemIdentifier == LogoToolbarItemIdentifier)
    {
        var logo = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
        [logo setStringValue:@"Doda Reader"];
        [logo setFont:[CPFont boldFontWithName:'Fugaz One' size:20]];
        [logo setTextColor:[CPColor colorWithHexString:@"ccc"]];
        [logo setTextShadowColor:[CPColor colorWithHexString:@"222"]];
        [logo setTextShadowOffset:CGSizeMake(0.5, 1.0)];
        [logo sizeToFit];
        [toolbarItem setView:logo];
        [toolbarItem setMinSize:CGSizeMake(CGRectGetWidth([logo bounds]), CGRectGetHeight([logo bounds]))];
        [toolbarItem setMaxSize:CGSizeMake(CGRectGetWidth([logo bounds]), CGRectGetHeight([logo bounds]))];
    }
    return toolbarItem;
}
@end
