@import <AppKit/CPView.j>
@import "EntryTableView.j"
@import "EntryItemView.j"
@import "EntryIconView.j"
@import "../Models/Entry.j"

var EntryItemViewWidth = 200.0,
    EntryItemViewHeight = 100.0;

@implementation EntryListView : CPView
{
    EntryCollectionView entryCollectionView;
    EntryTableView tableView;
    CPArray data;

}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        data = [[CPArray alloc] init];
        for(var i = 1; i <= 1000; i++) {
            var entry = [Entry alloc];
            [entry setTitle:@"Title " + i];
            [entry setLink:@"http://domain.com" + i];
            [entry setIntro:@"Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. At vero eos et accusam et justo duo dolores et ea rebum." + i];
            [data addObject:entry];
        }

        var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]) - 26.0)];
        [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
        [scrollView setAutohidesScrollers:YES];
        [scrollView setHasHorizontalScroller:NO];
        [scrollView setHasVerticalScroller:YES]; 
        [scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

        //entryCollectionView = [[EntryCollectionView alloc] initWithFrame:[scrollView bounds]];
        //[entryCollectionView setContent:locations];

        tableView = [[EntryTableView alloc] initWithFrame:[scrollView bounds]];
        [tableView setHeaderView:nil];
        [tableView setCornerView:nil];
        [tableView setUsesAlternatingRowBackgroundColors:YES];
        [tableView setRowHeight:EntryItemViewHeight];
        //[tableView setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];

        var iconColumn = [[CPTableColumn alloc] initWithIdentifier:@"icon"];
        [[iconColumn headerView] setStringValue:@"Icon"];
        [iconColumn setMinWidth:20];
        [iconColumn setMaxWidth:20];
        [tableView addTableColumn:iconColumn];

        var introColumn = [[CPTableColumn alloc] initWithIdentifier:@"intro"];
        [[introColumn headerView] setStringValue:@"Intro"];
        [introColumn setMinWidth:EntryItemViewWidth];
        [tableView addTableColumn:introColumn];

        [scrollView setDocumentView:tableView];

        [tableView setDataSource:self];
        [tableView setDelegate:self];

        [self addSubview:scrollView];

        var buttonBar = [[CPButtonBar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([self bounds]) - 26.0, CGRectGetWidth([self bounds]), 26.0)];
        [buttonBar setHasResizeControl:NO];
        [buttonBar setResizeControlIsLeftAligned:YES];
        [buttonBar setAutoresizingMask:CPViewWidthSizable | CPViewMinXMargin | CPViewMinYMargin];

        [self addSubview:buttonBar];

        var searchButton = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 35, 25)];
        [searchButton setBordered:NO];
        [searchButton setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/search.png" size:CGSizeMake(16, 16)]];
        [searchButton setImagePosition:CPImageOnly];
        [searchButton setAction:@selector(remove:)];
        [searchButton setTarget:self];
        [searchButton setEnabled:YES];

        [buttonBar setButtons:[searchButton]];

    }

    return self;
}

- (int)numberOfRowsInTableView:(CPTableView)aTableView {
    return [data count];
}

- (id)tableView:(CPTableView)aTableView objectValueForTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex {
    return [data objectAtIndex:rowIndex];
}

- (void)tableView:(CPTableView)aTableView viewForTableColumn:(CPTableColumn)aTableColumn row:(int)aRow
{
    var identifier = [aTableColumn identifier];

    if (identifier == @"multiple")
        identifier = [[[self content] objectAtIndex:aRow] objectForKey:@"identifier"];

    var aView = [aTableView makeViewWithIdentifier:identifier owner:self];

    if (identifier == "intro")
    {
        if (aView == nil)
            aView = [[EntryItemView alloc] initWithFrame:CGRectMake(0, 0, EntryItemViewWidth, EntryItemViewHeight)];
        [aView setRowIndex:aRow];
    }
    else if (identifier == "icon")
    {
        if (aView == nil)
            aView = [[EntryIconView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    }
    return aView;
}

@end
