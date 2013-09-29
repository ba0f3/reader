@import <AppKit/CPTableView.j>

@implementation EntryTableView : CPTableView
{

}

- (id)makeViewWithIdentifier:(CPString)anIdentifier owner:(id)anOwner
{
    if (!anIdentifier)
        return nil;

    var view,
        // See if we have some reusable views available
        reusableViews = _cachedDataViews[anIdentifier];

    if (reusableViews && reusableViews.length)
        view = reusableViews.pop();

    return view;
}
@end
