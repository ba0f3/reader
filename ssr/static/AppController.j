/*
 * AppController.j
 * frontend
 *
 * Created by You on September 28, 2013.
 * Copyright 2013, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>


@implementation AppController : CPObject
{
    CPView navigationArea, metaDataArea, contentArea;
    CPDictionary items;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    [self createLayout:contentView];
    [self createNavigator:contentView];

    [theWindow orderFront:self];

    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];
}

- (void)createLayout:(CPView)contentView
{
    navigationArea = [[CPView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, CGRectGetHeight([contentView bounds]) - 150.0)];

    // This view will grow in height, but stay fixed width attached to the left side of the screen.
    [navigationArea setAutoresizingMask:CPViewHeightSizable | CPViewMaxXMargin];

    [contentView addSubview:navigationArea];

    metaDataArea = [[CPView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([navigationArea frame]), 200.0, 150.0)];

    [metaDataArea setBackgroundColor:[CPColor greenColor]];

    // This view will stay the same size in both directions, and fixed to the lower left corner.
    [metaDataArea setAutoresizingMask:CPViewMinYMargin | CPViewMaxXMargin];

    [contentView addSubview:metaDataArea];

    contentArea = [[CPView alloc] initWithFrame:CGRectMake(200.0, 0.0, CGRectGetWidth([contentView bounds]) - 200.0, CGRectGetHeight([contentView bounds]))];

    [contentArea setBackgroundColor:[CPColor blueColor]];

    // This view will grow in both height an width.
    [contentArea setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [contentView addSubview:contentArea];
}

- (void)createNavigator:(CPView)contentView
{
    var scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, CGRectGetHeight([navigationArea bounds]))];
    [scrollView setBackgroundColor:[CPColor colorWithHexString:@"e0ecfa"]];
    [scrollView setAutohidesScrollers:YES];

    var outlineView = [[CPOutlineView alloc] initWithFrame:[[scrollView contentView] bounds]];
    var textColumn = [[CPTableColumn alloc] initWithIdentifier:@"TextColumn"];

    [textColumn setWidth:200.0];

    [outlineView setHeaderView:nil];
    [outlineView setCornerView:nil];
    [outlineView addTableColumn:textColumn];
    [outlineView setOutlineTableColumn:textColumn];

    [scrollView setDocumentView:outlineView];

    [navigationArea addSubview:scrollView];

    items = [CPDictionary dictionaryWithObjects:[[@"glossary 1"], [@"proj 1", @"proj 2", @"proj 3"]] forKeys:[@"Glossaries", @"Projects"]];
    [outlineView setDataSource:self];
}

- (id)outlineView:(CPOutlineView)outlineView child:(int)index ofItem:(id)item
{
    CPLog("outlineView:%@ child:%@ ofItem:%@", outlineView, index, item);

    if (item === nil)
    {
        var keys = [items allKeys];
        console.log([keys objectAtIndex:index]);
        return [keys objectAtIndex:index];
    }
    else
    {
        var values = [items objectForKey:item];
        console.log([values objectAtIndex:index]);
        return [values objectAtIndex:index];
    }
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
    CPLog("outlineView:%@ isItemExpandable:%@", outlineView, item);

    var values = [items objectForKey:item];
    console.log(([values count] > 0));
    return ([values count] > 0);
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
    CPLog("outlineView:%@ numberOfChildrenOfItem:%@", outlineView, item);

    if (item === nil)
    {
        console.log([items count]);
        return [items count];
    }
    else
    {
        var values = [items objectForKey:item];
        console.log([values count]);
        return [values count];
    }
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
    CPLog("outlineView:%@ objectValueForTableColumn:%@ byItem:%@", outlineView, tableColumn, item);

    console.log(item);

    return item;
}

@end
