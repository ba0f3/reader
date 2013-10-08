@import <Foundation/CPObject.j>
@import <AppKit/CPWindowController.j>
@import "../Constants.j"
@import "../ServerConnection.j"

var loginControllerSharedInstance = nil,
    loginPath = '/login',
    openSessionPath = '/openSession';
@implementation LoginController : CPWindowController
{
    CPTextField usernameField;
    CPSecureTextField passwordField;
    CPCheckBox rememberSwitcher

    CPButton okButton;

    BOOL isLoginIn @accessors(readonly);
}

+ (LoginController)sharedLoginController
{
    if (loginControllerSharedInstance == nil)
    {
        loginControllerSharedInstance = [[LoginController alloc] init];
    }

    return loginControllerSharedInstance;
}

- (void)showLoginWindow:(id)sender
{
    var sharedLoginController = [LoginController sharedLoginController];
    [sharedLoginController showWindow:sender];
}

- (void)hideLoginWindow:(id)sender
{
    var sharedLoginController = [LoginController sharedLoginController];
    [[sharedLoginController window] orderOut:sender];
}

- (void)toggleLoginWindow:(id)sender
{
    // debugger;
    var sharedLoginController = [LoginController sharedLoginController],
        loginWindow = [sharedLoginController window];

      if ([loginWindow isVisible] == YES)
          [loginWindow orderOut:sender];
      else
        [sharedLoginController showWindow:sender];
}

- (id)init
{
    var theWindow = [[CPPanel alloc] initWithContentRect:CGRectMake(100,100,320,160) styleMask:CPTitledWindowMask];
    self = [super initWithWindow:theWindow];
    if (self)
    {

        // delegate to allow LoginController handle 401 response
        [CPURLConnection setClassDelegate:self];

        [theWindow setTitle:@"Login"];
        [theWindow setLevel:CPModalPanelWindowLevel];
        [theWindow center];

        [theWindow setDelegate:self];

        var contentView = [theWindow contentView];

        // Not login in
        isLoginIn = NO;
        [ServerConnection setAuthToken:nil];

        var textField = [[CPTextField alloc] initWithFrame:CGRectMake(10, 10, 310, 24)];
        [textField setObjectValue:@"Enter your username and password to login."];
        [textField setAlignment:CPCenterTextAlignment];
        [contentView addSubview:textField];

        textField = [[CPTextField alloc] initWithFrame:CGRectMake(30, 120, 70, 25)];
        [textField setObjectValue:@"Remember"];
        [textField setAlignment:CPRightTextAlignment];
        [textField setVerticalAlignment:CPCenterVerticalTextAlignment];
        [contentView addSubview:textField];

        // Add the fields
        usernameField = [[CPTextField alloc] initWithFrame:CGRectMake(10, 40, 300, 35)];
        [usernameField setPlaceholderString:@"user@domain.com"];
        [usernameField setEditable:YES];
        [usernameField setSelectable:YES];
        [usernameField setBezeled:YES];
        [contentView addSubview:usernameField];

        passwordField = [[CPSecureTextField alloc] initWithFrame:CGRectMake(10, 75, 300, 35)];
        [passwordField setPlaceholderString:@"your password"];
        [passwordField setEditable:YES];
        [passwordField setSelectable:YES];
        [passwordField setBezeled:YES];
        [contentView addSubview:passwordField];

        [usernameField setStringValue:@"admin"]
        [passwordField setStringValue:@"s3cret"]

        rememberSwitcher = [[CPCheckBox alloc] initWithFrame:CGRectMake(10, 120, 25, 25)];
        [contentView addSubview:rememberSwitcher];

        okButton = [[CPButton alloc] initWithFrame:CGRectMake(225, 120, 80, 25)];
        [okButton setTitle:"Login"];
        [okButton setAction:@selector(login:)];
        [okButton setTarget:self];
        [okButton setBezelStyle:CPCircularBezelStyle];
        [contentView addSubview:okButton];
    }

    return self;
}

- (void)openSession
{
    [[ServerConnection alloc] postJSON:openSessionPath withObject:nil setDelegate:self];
}

- (void)logout:(id)sender
{
    isLoginIn = NO;
    [ServerConnection setAuthToken:nil];

    [self showLoginWindow:sender];

    [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_OUT object:nil];
}

- (void)login:(id)sender
{
    var username = [usernameField stringValue],
        password = [passwordField stringValue],
        remember = [rememberSwitcher intValue] == 1;

    if (username == nil || username == undefined || username == "")
    {
        var message = @"Please enter your username";
        [self displayAlertWithMessage:message];
        return;
    }

    if ([self checkpasswordFieldLength:6])
    {
        var data = new Object;
        data.username = username;
        data.password = password;
        data.remember = remember;

        [[ServerConnection alloc] postJSON:loginPath withObject:data setDelegate:self];
    }
    else
    {
        // Show an error
        var message = [CPString stringWithFormat:"Password must have more than %d characters", 6];
        [self displayAlertWithMessage:message];
    }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)json
{
    CPLog('LoginController.connection:%@ didReceiveData:%@', connection, json);
    var data = JSON.parse(json);
    if (data.login)
    {
        [ServerConnection setAuthToken:data.authToken];
        [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:[[User alloc] initFromObject:data.user]];
        [self hideLoginWindow:self];
    }
    else if (data.open)
    {
        [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGGED_IN object:[[User alloc] initFromObject:data.user]];
        [self hideLoginWindow:self];
    }
}

- (BOOL)checkpasswordFieldLength:(int)length
{
    var password = [passwordField stringValue];

    return ([password length] >= length);
}

- (void)windowWillClose:(id)aSender
{
    // Update the menu state
}

- (void)connectionDidReceiveAuthenticationChallenge:(id)connection
{
    [self logout:self];
}

@end

@implementation LoginController (Alert)

- (void)displayAlertWithMessage:(CPString)message
{
    var alert = [[CPAlert alloc] init];
    [alert setMessageText:@"Unable to process your request"];
    [alert setInformativeText:message];
    //[alert setShowsHelp:YES];
    //[alert setAlertStyle:CPWarningAlertStyle];
    [alert addButtonWithTitle:@"OK"]
    [alert runModal];
}
@end
