@import "../Controllers/CategoryController.j";
@import "../Controllers/FeedController.j";

var sharedFeedDialogInstace;

@implementation FeedDialog : CPWindow
{
    CPTextField header, nameLabel, nameField, urlField, urlLabel, authenticationLabel, passwordField, usernameField, categoryLabel;
    CPButton okButton, cancelButton;
    CPPopUpButton categoryField;
    id _feed;
    BOOL isNew;
}

+ (FeedDialog)sharedFeedDialog
{
    if (!sharedFeedDialogInstace)
        sharedFeedDialogInstace = [[FeedDialog alloc] init];
    return sharedFeedDialogInstace;
}

- (id)init
{
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onFeedAuthRequired:) name:NOTIFICATION_FEED_AUTH_REQUIRED object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onFeedDialogShouldClose:) name:NOTIFICATION_FEED_DIALOG_SHOULD_CLOSE object:nil];

    if (self = [super initWithContentRect:CGRectMake(0, 0, 400, 170) styleMask:CPTitledWindowMask | CPResizableWindowMask])
    {
        [self setMinSize:CGSizeMake(300, 100)];
        [self setMaxSize:CGSizeMake(600, 400)];

        var contentView = [self contentView];
        header = [[CPTextField alloc] initWithFrame:CGRectMake(10, 20, 200, 30)];
        [header setFont:[CPFont boldSystemFontOfSize:14]];
        [contentView addSubview:header]

        urlLabel = [[CPTextField alloc] initWithFrame:CGRectMake(20, 50, 80, 30)];
        [urlLabel setStringValue:@"URL"];
        [urlLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
        [urlLabel setAlignment:CPRightTextAlignment];
        [contentView addSubview:urlLabel];

        urlField = [[CPTextField alloc] initWithFrame:CGRectMake(110, 50, 250, 30)];
        [urlField setPlaceholderString:@"Required"];
        [urlField setEditable:YES];
        [urlField setBezeled:YES];
        [urlField setAutoresizingMask:CPViewWidthSizable];
        [contentView addSubview:urlField];

        categoryLabel = [[CPTextField alloc] initWithFrame:CGRectMake(20, 90, 80, 30)];
        [categoryLabel setHidden:NO];
        [categoryLabel setStringValue:@"Category"];
        [categoryLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
        [categoryLabel setAlignment:CPRightTextAlignment];
        [contentView addSubview:categoryLabel];

        categoryField = [[CPPopUpButton alloc] initWithFrame:CGRectMake(110, 90, 250, 25)];
        var categories = [[CategoryController sharedCategoryController] categories];
        [categoryField addItemWithTitle:@"Choose one"];
        [categoryField addItem:[CPMenuItem separatorItem]];
        [categoryField setSelectedIndex:0];
        for (var i = 0; i < [categories count]; i++)
        {
            var category = [categories objectAtIndex:i],
                item = [[CPMenuItem alloc] init];
            [item setTitle:[category name]];
            [item setTag:[category id]];
            [categoryField addItem:item];
        }
        [contentView addSubview:categoryField];

        authenticationLabel = [[CPTextField alloc] initWithFrame:CGRectMake(20, 130, 80, 30)];
        [authenticationLabel setStringValue:@"Authentication"];
        [authenticationLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
        [authenticationLabel setAlignment:CPRightTextAlignment];
        [authenticationLabel setHidden:YES];
        [contentView addSubview:authenticationLabel];

        usernameField = [[CPTextField alloc] initWithFrame:CGRectMake(110, 130, 125, 30)];
        [usernameField setEditable:YES];
        [usernameField setBezeled:YES];
        [usernameField setAutoresizingMask:CPViewWidthSizable];
        [usernameField setHidden:YES];
        [contentView addSubview:usernameField];

        passwordField = [[CPTextField alloc] initWithFrame:CGRectMake(235, 130, 125, 30)];
        [passwordField setEditable:YES];
        [passwordField setBezeled:YES];
        [passwordField setAutoresizingMask:CPViewWidthSizable];
        [passwordField setHidden:YES];
        [contentView addSubview:passwordField];


        var buttonHeight = [[CPTheme defaultTheme] valueForAttributeWithName:@"min-size" forClass:CPButton].height;
        okButton = [[CPButton alloc] initWithFrame:CGRectMake(300, 130, 50, buttonHeight)];
        [okButton setTitle:"OK"];
        [okButton setTarget:self];
        [okButton setTag:1];
        [okButton setAction:@selector(closeSheet:)];
        [okButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

        cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(220, 130, 70, buttonHeight)];
        [cancelButton setTitle:"Cancel"];
        [cancelButton setTarget:self];
        [cancelButton setTag:0];
        [cancelButton setAction:@selector(closeSheet:)];
        [cancelButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];


        [contentView addSubview:okButton];
        [contentView addSubview:cancelButton];
    }
    return self;
}

- (void)onFeedAuthRequired:(CPNotification)notification
{
    [self showAuthentication];
}

- (void)onFeedDialogShouldClose:(CPNotification)notification
{
    [self closeSheet:nil];
}
- (void)toggleAuthentication
{
    if ([authenticationLabel isHidden])
        [self showAuthentication];
    else
        [self hideAuthentication];
}

- (void)showAuthentication
{
    [authenticationLabel setHidden:NO];
    [usernameField setHidden:NO];
    [passwordField setHidden:NO];
    [self setFrameSize:CGSizeMake(400, 220)];
}

- (voi)hideAuthentication
{
    [authenticationLabel setHidden:YES];
    [usernameField setHidden:YES];
    [passwordField setHidden:YES];
    [self setFrameSize:CGSizeMake(400, 170)];
}

- (void)displaySheet:(id)sender
{
    isNew = YES;
    [header setStringValue:@"Add Subscription:"];
    [nameField setPlaceholderString:@""];
    [nameField setStringValue:@""];
    [okButton setTitle:@"OK"];
    [CPApp beginSheet:self modalForWindow:[CPApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)displaySheet:(id)sender forEdit:(id)feed
{
    [header setStringValue:@"Edit Feed:"];
    isNew = NO;
    _feed = feed;
    [nameField setPlaceholderString:[_feed name]];
    [nameField setStringValue:[_feed name]];
    [okButton setTitle:@"Save"];
    [CPApp beginSheet:self modalForWindow:[CPApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)didEndSheet:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    if (returnCode == CPOKButton)
    {
        if (isNew)
        {
            var category_id = [[categoryField selectedItem] tag],
                url = [urlField stringValue];
            if (category_id < 1 || url == "")
            {
                var alert = [CPAlert alertWithError:@"Required fields are missing"];
                [alert setInformativeText:@"An valid feed URL and Category are required"];
                [alert runModal];
                return;
            }

            [[FeedController sharedFeedController] subscribeFeedWithUrl:url setCategory:category_id];
        }
        else
        {
            /*if ([nameField stringValue] != '' && [nameField stringValue] != [_feed name])
            {
                [[CategoryController sharedCategoryController] updateCategory:_feed withNewName:[nameField stringValue]];
            }*/
        }
    }
    else
        [aSheet orderOut:self];
}

- (void)closeSheet:(id)sender
{
    [CPApp endSheet:self returnCode:[sender tag]];
}

@end
