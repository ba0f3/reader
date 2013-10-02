@import <AppKit/CPView.j>
@import "Widgets/FolderItemView.j"
@import "../Constants.j"

@implementation NavigationView : CPView
{
	CPDictionary items @accessors;
	CPOutlineView _outlineView;
}

- (void)initWithFrame:(CGRect)aFrame
{
	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onCategoryLoaded:) name:NOTIFICATION_CATEGORY_LOADED object:nil];

	items = [CPDictionary dictionaryWithObjects:[[@"Android", @"Ubuntu", @"Linux"], [@"Unread", @"Favorites", @"Archives"]] forKeys:[@"Labels", @"All Feeds"]];
	self = [super initWithFrame:aFrame];
    if (self)
    {
    	//self._DOMElement.style.boxShadow="5px 5px 1px #888888";
    	self._DOMElement.style.borderRight="1px solid rgb(184, 178, 178)";
    	[self setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

		var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, CGRectGetHeight([self bounds]) - 26.0)];
	    [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
	    [scrollView setAutohidesScrollers:YES];
	    [scrollView setHasHorizontalScroller:NO];
	    [scrollView setHasVerticalScroller:YES]; 
	    [scrollView setAutoresizingMask:CPViewHeightSizable];

	    _outlineView = [[CPOutlineView alloc] initWithFrame:[scrollView bounds]];
	    var tableColumn = [[CPTableColumn alloc] initWithIdentifier:@"tableColumn"];
	    [tableColumn setWidth:200.0];

	    //TODO custom dataView for Folder
	    //var dataView  = [[FolderItemView alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
	    //[tableColumn setDataView:dataView];

	    [_outlineView setHeaderView:nil];
	    [_outlineView setCornerView:nil];
	    [_outlineView addTableColumn:tableColumn];
	    [_outlineView setOutlineTableColumn:tableColumn];
	    [_outlineView setBackgroundColor:[CPColor colorWithHexString:@"E0E0E0"]]; // 333333

	    //[_outlineView setAutoresizingMask:CPViewHeightSizable];

	    [scrollView setDocumentView:_outlineView];

	    [self addSubview:scrollView];

		[_outlineView setDelegate:self];
	    [_outlineView setDataSource:self];

	    var buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([self bounds]) - 26.0, CGRectGetWidth([self bounds]), 26.0)]; //you need to use your own frame obviously
	    [buttonBar setHasResizeControl:NO];
	    //[buttonBar setResizeControlIsLeftAligned:YES];
	    [buttonBar setAutoresizingMask:CPViewWidthSizable | CPViewMaxYMargin | CPViewMinYMargin];
	    [self addSubview:buttonBar];


	    var addButton = [CPButtonBar plusButton];
	    [addButton setAction:@selector(showSubscribePopup:)];
	    [addButton setTarget:self];
	    [addButton setEnabled:YES];

	    var minusButton = [CPButtonBar minusButton];
	    [minusButton setAction:@selector(remove:)];
	    [minusButton setTarget:self];
	    [minusButton setEnabled:YES];

	    var popUpButton = [CPButtonBar actionPopupButton];
	    [popUpButton setTarget:self];
	    [popUpButton setEnabled:YES];
	    [popUpButton addItemsWithTitles: [CPArray arrayWithObjects:
	                @"Choose an action:",
	                nil]
	    ];
	    [popUpButton setAutoresizingMask:CPViewMaxYMargin];
	    //[popUpButton sizeToFit];

	    var refreshButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
	    [refreshButton setBordered:NO];
	    [refreshButton setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/refresh.png" size:CGSizeMake(16, 16)]];
	    [refreshButton setImagePosition:CPImageOnly];
	    [refreshButton setAction:@selector(remove:)];
	    [refreshButton setTarget:self];
	    [refreshButton setEnabled:YES];

	    [buttonBar setButtons:[addButton, minusButton, popUpButton, refreshButton]];
	}

    return self;
}

- (void)onCategoryLoaded:(CPNotification)notification
{
    CPLog('onCategoryLoaded:%@', notification);
    var categories = [notification object];
    for(var i = 0; i < categories.length; i ++)
    {
    	var category = categories[i];
    	[items setObject:[category feeds] forKey:[category name]]
    }
    [_outlineView reloadData];

}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    CPLog("outlineView:%@ child:%@ ofItem:%@", outlineView, index, item);

    if (item === nil)
    {
        var keys = [items allKeys];
        return [keys objectAtIndex:index];
    }
    else
    {
        var values = [items objectForKey:item];
        return [values objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    CPLog("outlineView:%@ isItemExpandable:%@", outlineView, item);

    var values = [items objectForKey:item];
    return ([values count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    CPLog("outlineView:%@ numberOfChildrenOfItem:%@", outlineView, item);

    if (item === nil)
    {
        return [items count];
    }
    else
    {
        var values = [items objectForKey:item];
        return [values count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    CPLog("outlineView:%@ objectValueForTableColumn:%@ byItem:%@", outlineView, tableColumn, item);
    return item;
}

- (BOOL)outlineView:(CPOutlineView)outlineView shouldExpandItem:(id)item
{
	CPLog("outlineView:%@ shouldExpandItem:%@", outlineView, item);
	return YES;
}

- (void)outlineView:(CPOutlineView)outlineView willDisplayView:(id)dataView forTableColumn:(CPTableColumn)tableColumn item:(id)item
{
	CPLog("outlineView:%@ willDisplayView:%@ forTableColumn:%@ item:%@", outlineView, dataView, tableColumn, item);
	if([item className] == 'Feed')
	{
		[dataView setStringValue:[item name]];
	}
}

//[items setValue:[] forKey:@"Test"];
@end
