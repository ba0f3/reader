@import <AppKit/CPView.j>
@import "../Constants.j"
@import "../Controllers/CategoryController.j"
@import "../Controllers/FeedController.j"
@import "CategoryDialog.j"
@import "FeedDialog.j"
@import "Widgets/FolderItemView.j"
@import "Widgets/CategoryHeader.j"
@import "Widgets/CategoryDataView.j"
@import "Widgets/SpecialDataView.j"

var SpecialFoldersViewHeight = 135.0;
@implementation NavigationView : CPView
{
    CPView _scrollDocumentView;
    CPDictionary specialFolders @accessors;
    CPOutlineView _specialFoldersViews;
    CPOutlineView _categoriesViews;
    CPScrollView scrollView;

    CPButtonBar addButton, editButton, removeButton;

    id _selectedItem;
}

- (id)initWithFrame:(CGRect)aFrame
{
    var defaultCenter = [CPNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(onCategoryLoaded:) name:NOTIFICATION_CATEGORY_LOADED object:nil];
    [defaultCenter addObserver:self selector:@selector(onUserLoggedIn:) name:NOTIFICATION_USER_LOGGED_IN object:nil];

    specialFolders = [CPDictionary dictionaryWithObjects:[[@"All", @"Unread", @"Starred", @"Archives"]] forKeys:[@"Special"]];

    self = [super initWithFrame:aFrame];
    if (self)
    {
        self._DOMElement.style.borderRight = "1px solid rgb(184, 178, 178)";
        [self setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

        scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0, CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]) - 26.0)];
        [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
        [scrollView setAutohidesScrollers:YES];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setHasVerticalScroller:YES];
        [scrollView setAutoresizingMask:CPViewHeightSizable];
        [self addSubview:scrollView];

        _scrollDocumentView = [[CPView alloc] initWithFrame:[scrollView _insetBounds]];
        [scrollView setDocumentView:_scrollDocumentView];

        var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"tableColumn"];
        [tableColumn setWidth:CGRectGetWidth([_scrollDocumentView bounds])];

        _specialFoldersViews = [[CPOutlineView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([_scrollDocumentView bounds]), SpecialFoldersViewHeight)];
        [_specialFoldersViews setHeaderView:nil];
        [_specialFoldersViews setCornerView:nil];
        [_specialFoldersViews addTableColumn:tableColumn];
        [_specialFoldersViews setOutlineTableColumn:tableColumn];
        [_specialFoldersViews setBackgroundColor:[CPColor colorWithHexString:@"E0E0E0"]]; // 333333
        [_specialFoldersViews setAutoresizingMask:CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
        [_specialFoldersViews setIndentationMarkerFollowsDataView:NO];
        [_specialFoldersViews setDelegate:self];
        [_specialFoldersViews setDataSource:self];
        [_specialFoldersViews expandItem:@"Special"];
        [_scrollDocumentView addSubview:_specialFoldersViews];

        var categoryHeader = [[CategoryHeader alloc] initWithFrame:CGRectMake(0.0, SpecialFoldersViewHeight, CGRectGetWidth([_scrollDocumentView bounds]), 26.0)];
        [categoryHeader setAutoresizingMask:CPViewWidthSizable | CPViewMinXMargin | CPViewMaxXMargin];
        [_scrollDocumentView addSubview:categoryHeader];

        _categoriesViews = [[CPOutlineView alloc] initWithFrame:CGRectMake(0.0, SpecialFoldersViewHeight + 26, CGRectGetWidth([_scrollDocumentView bounds]), CGRectGetHeight([_scrollDocumentView bounds]) - SpecialFoldersViewHeight- 26 )];
        //[_categoriesViews setIndentationPerLevel:9.0];
        [_categoriesViews setPostsFrameChangedNotifications:YES];
        [_categoriesViews setPostsBoundsChangedNotifications:YES];
        [_categoriesViews setHeaderView:nil];
        [_categoriesViews setCornerView:nil];
        [_categoriesViews addTableColumn:tableColumn];
        [_categoriesViews setOutlineTableColumn:tableColumn];
        [_categoriesViews setBackgroundColor:[CPColor colorWithHexString:@"E0E0E0"]];
        [_categoriesViews setDelegate:self];
        [_categoriesViews setDataSource:self];

        [_scrollDocumentView addSubview:_categoriesViews];

        var buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([self bounds]) - 26.0, CGRectGetWidth([self bounds]), 26.0)]; //you need to use your own frame obviously
        [buttonBar setHasResizeControl:NO];
        //[buttonBar setResizeControlIsLeftAligned:YES];
        [buttonBar setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin | CPViewMinYMargin];
        [self addSubview:buttonBar];


        addButton = [[CPPopUpButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
        [addButton addItemWithTitle:nil];
        [[addButton lastItem] setImage:[[CPTheme defaultTheme] valueForAttributeWithName:@"button-image-plus" forClass:[CPButtonBar class]]];
        [addButton setImagePosition:CPImageOnly];
        [addButton setValue:CGInsetMake(0, 0, 0, 0) forThemeAttribute:"content-inset"];
        [addButton setPullsDown:YES];
        [addButton setTarget:self];
        [addButton setAction:@selector(newItem:)];
        [addButton setEnabled:YES];
        [addButton addItemsWithTitles: [CPArray arrayWithObjects:
                    @"New Category...",
                    @"New Subscription...",
                    nil]
        ];

        removeButton = [CPButtonBar minusButton];
        [removeButton setAction:@selector(removeItem:)];
        [removeButton setTarget:self];
        [removeButton setEnabled:NO];

        editButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
        [editButton setBordered:NO];
        [editButton setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/edit.png" size:CGSizeMake(16, 16)]];
        [editButton setImagePosition:CPImageOnly];
        [editButton setAction:@selector(editItem:)];
        [editButton setTarget:self];
        [editButton setEnabled:NO];

        var refreshButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
        [refreshButton setBordered:NO];
        [refreshButton setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/ReloadIcon.png" size:CGSizeMake(12, 15)]];
        [refreshButton setImagePosition:CPImageOnly];
        [refreshButton setAction:@selector(refresh:)];
        [refreshButton setTarget:self];
        [refreshButton setEnabled:YES];

        [buttonBar setButtons:[addButton, removeButton, editButton, refreshButton]];

        [defaultCenter addObserver:self selector:@selector(categoryOutlineViewFrameChanged:) name:CPViewFrameDidChangeNotification object:_categoriesViews];
       [defaultCenter addObserver:self selector:@selector(categoryOutlineViewFrameChanged:) name:CPViewBoundsDidChangeNotification object:_categoriesViews];
    }

    return self;
}

- (void)newItem:(id)sender
{
    if ([sender selectedIndex] == 1)
        [[CategoryDialog sharedCategoryDialog] displaySheet:self];
    else
        [[FeedDialog sharedFeedDialog] displaySheet:self];

}
- (void)editItem:(id)sender
{
    if (!_selectedItem)
        return;

    if ([_selectedItem className] == 'Category')
    {
        [[CategoryDialog sharedCategoryDialog] displaySheet:self forEdit:_selectedItem];
    }
}

- (void)removeItem:(id)sender
{
    if (!_selectedItem)
        return;

    var message,
        informativeText;
    if ([_selectedItem className] == 'Category')
    {
        if ([[_selectedItem feeds] count] == 0)
            [[CategoryController sharedCategoryController] deleteCategory:_selectedItem];
        else
        {
            message = "Can not remove this category!";
            informativeText = "This category contains one or more feeds, please remove them first."
            var alert = [CPAlert alertWithMessageText:message defaultButton:@"Close" alternateButton:nil otherButton:nil informativeTextWithFormat:informativeText];
            [alert beginSheetModalForWindow:[CPApp mainWindow]];
        }

    }
    else if ([_selectedItem className] == 'Feed')
    {
        message = "Do you want to unsubscribe this feed?";
        informativeText = [CPString stringWithFormat:@"You are going to unsubscribe feed %@ from %@.", _selectedItem.name, _selectedItem.site];
        var alert = [CPAlert alertWithMessageText:message defaultButton:@"Unsubscribe" alternateButton:@"Cancel" otherButton:"Turn off" informativeTextWithFormat:informativeText];
        [alert beginSheetModalForWindow:[CPApp mainWindow] modalDelegate:self didEndSelector:@selector(didEndSheetRemoveItem:returnCode:contextInfo:) contextInfo:nil];
    }
}

- (void)refresh:(id)sender
{
    [[CategoryController sharedCategoryController] fetchCategories];
}

- (void)didEndSheetRemoveItem:(CPWindow)aSheet returnCode:(int)returnCode contextInfo:(id)contextInfo
{
    console.log(returnCode);

    // 0 OK 1 cancel 2 turn off
    if (returnCode == 0)
    {
        [[FeedController sharedFeedController] unsubscribeFeedWithId:[_selectedItem id]];
    }
    else if (returnCode == 2) // turn off feed
    {
        // not implement yet
    }
}

- (voi)onDoubleClick:(id)sender
{
    console.log(sender);
}

- (void)onCategoryLoaded:(CPNotification)notification
{
    CPLog('NavigationView.onCategoryLoaded:%@', notification);
    [_categoriesViews reloadData];
}

- (void)onUserLoggedIn:(CPNotification)notification
{
    CPLog('NavigationView.onUserLoggedIn:%@', notification);
    [[CategoryController sharedCategoryController] fetchCategories];
}

- (void)categoryOutlineViewFrameChanged:(CPNotification)notification
{
    if ([notification object] == _categoriesViews)
    {
        var subviews = [_scrollDocumentView subviews],
            frame = CGRectMakeZero();
        for (var i = 0; i < subviews.length; i++)
        {
            var subview = subviews[i];
            frame = CGRectUnion(frame, [subview frame]);
        }
        [_scrollDocumentView setFrameSize:CGSizeMake(CGRectGetWidth([_scrollDocumentView bounds]), CGRectGetHeight(frame))];
    }
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    CPLog("NavigationView.outlineView:%@ child:%@ ofItem:%@", outlineView, index, item);
    if (outlineView == _specialFoldersViews)
    {
        if (item === nil)
        {
            var keys = [specialFolders allKeys];
            return [keys objectAtIndex:index];
        }
        else
        {
            var values = [specialFolders objectForKey:item];
            return [values objectAtIndex:index];
        }
    }
    else
    {
        if (item === nil)
        {
            var sharedCategoryController = [CategoryController sharedCategoryController],
                keys = [sharedCategoryController categories];
            return [keys objectAtIndex:index];
        }
        else
        {
            return [[item feeds] objectAtIndex:index];
        }
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    CPLog("NavigationView.outlineView:%@ isItemExpandable:%@", outlineView, item);
    if (outlineView == _specialFoldersViews)
    {
        var values = [specialFolders objectForKey:item];
        return ([values count] > 0);
    }
    else
    {
        if ([item className] == 'Category' && [[item feeds] count])
            return YES;
        if ([item className] == 'Feed')
            return NO;
    }
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    CPLog("NavigationView.outlineView:%@ numberOfChildrenOfItem:%@", outlineView, item);
    if (outlineView == _specialFoldersViews)
    {
        if (item === nil)
        {
            return [specialFolders count];
        }
        else
        {
            var values = [specialFolders objectForKey:item];
            return [values count];
        }
    }
    else
    {
        if (item === nil)
        {
            var sharedCategoryController = [CategoryController sharedCategoryController];
            return [[sharedCategoryController categories] count];
        }
        else
        {
            var values = [item feeds];
            return [values count];
        }
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    CPLog("NavigationView.outlineView:%@ objectValueForTableColumn:%@ byItem:%@", outlineView, tableColumn, item);
    return item;
}

- (BOOL)outlineView:(CPOutlineView)outlineView shouldCollapseItem:(id)item
{
    CPLog("NavigationView.outlineView:%@ shouldCollapseItem:%@", outlineView, item);
    if (outlineView == _specialFoldersViews && item == @"Special")
        return NO;
    return YES;
}

- (void)outlineView:(CPOutlineView)outlineView willDisplayView:(id)dataView forTableColumn:(CPTableColumn)tableColumn item:(id)item
{
    CPLog("NavigationView.outlineView:%@ willDisplayView:%@ forTableColumn:%@ item:%@", outlineView, dataView, tableColumn, item);
    if (outlineView == _specialFoldersViews)
    {
    }
    else
    {
        if ([item className] == 'Category')
        {
            [dataView setStringValue:[item name]];
            if ([outlineView isItemExpanded:item])
                [dataView hideBadge];
            else
                [dataView showBadge];
        }
        if ([item className] == 'Feed')
        {
            [dataView setStringValue:[item name]];
        }
    }

}

- (BOOL)outlineView:(CPOutlineView)outlineView shouldSelectItem:(id)item
{
    CPLog("NavigationView.outlineView:%@ shouldSelectItem:%@", outlineView, item);
    if (outlineView == _specialFoldersViews)
    {
        [removeButton setEnabled:NO];
        [editButton setEnabled:NO];

        if (item == @"Special")
            return NO;

        [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SPECIAL_FOLDER_SELECTED object:[item lowercaseString]];

    }
    else
    {
        [removeButton setEnabled:YES];
        [editButton setEnabled:YES];
        if ([item isKindOfClass:Category])
        {
            [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CATEGORY_SELECTED object:item];

        }
        else if ([item isKindOfClass:Feed])
        {
            [[CPNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FEED_SELECTED object:item];
        }
        _selectedItem = item;
    }
    return YES;
}

- (CPView)outlineView:(id)outlineView viewForTableColumn:(CPTableColumn)tableColumn item:(id)item
{
    CPLog("NavigationView.outlineView:%@ viewForTableColumn:%@ item:%@", outlineView, tableColumn, item);
    var dataView;
    if (outlineView == _categoriesViews)
        dataView = [[CategoryDataView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 25.0)];
    else
        dataView = [[SpecialDataView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 25.0)];
    return dataView

}
@end
