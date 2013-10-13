@import "../Controllers/CategoryController.j";
@import "../Models/Category.j";

var sharedCategoryDialogInstace;

@implementation CategoryDialog : CPWindow
{
    CPTextField nameLabel, nameField;
    BOOL isNew;
    Category _category
}

+ (CategoryDialog)sharedCategoryDialog
{
    if (!sharedCategoryDialogInstace)
        sharedCategoryDialog = [[CategoryDialog alloc] init];
    return sharedCategoryDialog;
}

- (id)init
{
    if (self = [super initWithContentRect:CGRectMake(0, 0, 400, 150) styleMask:CPTitledWindowMask | CPResizableWindowMask])
    {
        isNew = YES;
        [self setToolbar:nil];

        [self setMinSize:CGSizeMake(300, 100)];
        [self setMaxSize:CGSizeMake(600, 400)];

        var contentView = [self contentView],
            header = [[CPTextField alloc] initWithFrame:CGRectMake(10, 20, 200, 30)];
        if (isNew)
            [header setStringValue:@"Create New Category"];
        else
            [header setStringValue:@"Rename Category"];

        [header setFont:[CPFont boldSystemFontOfSize:14]];
        [contentView addSubview:header]

        nameLabel = [[CPTextField alloc] initWithFrame:CGRectMake(10, 50, 80, 30)];
        [nameLabel setStringValue:@"Name"];
        [nameLabel setVerticalAlignment:CPCenterVerticalTextAlignment];
        [nameLabel setAlignment:CPRightTextAlignment];
        [contentView addSubview:nameLabel];

        nameField = [[CPTextField alloc] initWithFrame:CGRectMake(90, 50, 250, 30)];
        [nameField setEditable:YES];
        [nameField setBezeled:YES];
        [nameField setAutoresizingMask:CPViewWidthSizable];
        if (!isNew)
            [nameField setPlaceholderString:[_category name]];
        [contentView addSubview:nameField];

        var buttonHeight = [[CPTheme defaultTheme] valueForAttributeWithName:@"min-size" forClass:CPButton].height,
            okButton = [[CPButton alloc] initWithFrame:CGRectMake(270, 110, 70, buttonHeight)];
        [okButton setTitle:"Create"];
        [okButton setTarget:self];
        [okButton setTag:1];
        [okButton setAction:@selector(closeSheet:)];
        [okButton setAutoresizingMask:CPViewMinXMargin | CPViewMinYMargin];

        var cancelButton = [[CPButton alloc] initWithFrame:CGRectMake(190, 110, 70, buttonHeight)];
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

- (void)displaySheet:(id)sender
{
    isNew = YES;
    [CPApp beginSheet:self modalForWindow:[CPApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)displaySheet:(id)sender forEdit:(id)category
{
    isNew = NO;
    _category = category;
    [CPApp beginSheet:self modalForWindow:[CPApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (void)closeCategorySheet:(id)sender
{
    [CPApp endSheet:self returnCode:[sender tag]];
}

- (void)didEndSheet:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    if (returnCode == CPOKButton)
    {
        if (isNew)
        {
            [[CategoryController sharedCategoryController] createCategoryWithName:[nameField stringValue]];
        }
        else
        {
            if ([nameField stringValue] != [_category name])
            {
                [[CategoryController sharedCategoryController] updateCategoryWithNewName:[nameField stringValue]];
            }
        }
    }
    [aSheet orderOut:self];
}

- (void)closeSheet:(id)sender
{
    [CPApp endSheet:self returnCode:[sender tag]];
}
@end
