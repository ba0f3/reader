@import <AppKit/CPTextField.j>
@import "CPUrlLabel.j"

@implementation EntryItemView : CPView
{
    int row;
    CPTextField title;
    CPUrlLabel site;
    CPTextField intro;
    id entry;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        [self setBackgroundColor:[CPColor colorWithHexString:"B5B5B5"]];

        var fontDosisBold = [CPFont boldFontWithName:'Dosis' size:12];
        var fontDosis = [CPFont fontWithName:'Dosis' size:12];
        var fontOpenSans = [CPFont fontWithName:'Open Sans' size:12];

        [self setAutoresizingMask:CPViewWidthSizable];
        title = [[CPTextField alloc] initWithFrame:CGRectMake(2.0, 2.0, CGRectGetWidth([self bounds]), 24)];
        [title setAutoresizingMask:CPViewWidthSizable];
        [title setLineBreakMode:CPLineBreakByTruncatingTail];
        [title setTextColor:[CPColor colorWithHexString:@"333"]];
        [title setTextShadowColor:[CPColor colorWithHexString:@"CCC"]];
        [title setTextShadowOffset:CGSizeMake(1.0, 1.0)];
        [title setFont:fontDosisBold];

        site = [[CPUrlLabel alloc] initWithFrame:CGRectMake(2.0, 16.0, CGRectGetWidth([self bounds]), 24)];
        [site setAutoresizingMask:CPViewWidthSizable];
        [site setUrl:@""];
        [site sizeToFit];
        [site setFont:fontDosis];

        intro = [[CPTextField alloc] initWithFrame:CGRectMake(2.0, 40.0, CGRectGetWidth([self bounds]), 56)];
        [intro setAutoresizingMask:CPViewWidthSizable];
        [intro setLineBreakMode:CPLineBreakByWordWrapping];
        [intro setFont:fontDosis];


        [self addSubview:title];
        [self addSubview:site];
        [self addSubview:intro];
    }
    return self;
}

- (void)setObjectValue:(id)anEntry
{
    if (!anEntry)
        return;
    entry = anEntry;

    [title setStringValue:[anEntry title]];
    [site setStringValue:[anEntry site]];
    [site sizeToFit];
    [intro setStringValue:[anEntry intro]];
}

- (void)setRowIndex:(int)aRow
{
    row = aRow;
}

@end
