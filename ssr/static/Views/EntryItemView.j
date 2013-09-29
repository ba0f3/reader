@import <AppKit/CPTextField.j>

@implementation EntryItemView : CPView
{
    int row;
    CPTextField title;
    CPTextField link;
    CPTextField intro;
    id entry;
}

- (void)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        var fontBold = [CPFont boldFontWithName:'Roboto' size:12];
        var font = [CPFont fontWithName:'Roboto' size:12];
        [self setAutoresizingMask:CPViewWidthSizable];
        title = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 30)];
        [title setFont:fontBold];
        link = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, 20.0, 300, 20)];
        [link setFont:font];
        intro = [[CPTextField alloc] initWithFrame:CGRectMake(0.0, 40.0, 300, 55)];
        [intro setLineBreakMode:CPLineBreakByWordWrapping];
        [intro setFont:font];
        //[intro sizeToFit];

        [self addSubview:title];
        [self addSubview:link];
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
    [link setStringValue:[anEntry link]];
    [intro setStringValue:[anEntry intro]];
}

- (void)setRowIndex:(int)aRow
{
    row = aRow;
}

@end
