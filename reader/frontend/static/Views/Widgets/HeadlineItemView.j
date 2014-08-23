@import <AppKit/CPTextField.j>
@import "CPUrlLabel.j"

@implementation HeadlineItemView : CPView
{
    int row;
    CPTextField title;
    CPUrlLabel site;
    CPTextField intro;
    id _headline;
    CPFont fontTitleBold;
    CPFont fontTitle;
    CPFont fontText;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        [self setBackgroundColor:[CPColor colorWithHexString:"B5B5B5"]];

        fontTitleBold = [CPFont boldFontWithName:'Dosis' size:13];
        fontTitle = [CPFont fontWithName:'Dosis' size:13];
        fontText = [CPFont fontWithName:'Dosis' size:12];

        [self setAutoresizingMask:CPViewWidthSizable];
        title = [[CPTextField alloc] initWithFrame:CGRectMake(2.0, 2.0, CGRectGetWidth([self bounds]), 24)];
        [title setAutoresizingMask:CPViewWidthSizable];
        [title setLineBreakMode:CPLineBreakByTruncatingTail];
        [title setTextColor:[CPColor colorWithHexString:@"333"]];
        //[title setTextShadowColor:[CPColor colorWithHexString:@"CCC"]];
        //[title setTextShadowOffset:CGSizeMake(1.0, 0.5)];
        [title setFont:fontTitleBold];

        site = [[CPUrlLabel alloc] initWithFrame:CGRectMake(2.0, 16.0, CGRectGetWidth([self bounds]), 24)];
        [site setAutoresizingMask:CPViewWidthSizable];
        [site setUrl:@""];
        [site sizeToFit];
        [site setFont:fontTitle];

        intro = [[CPTextField alloc] initWithFrame:CGRectMake(2.0, 34.0, CGRectGetWidth([self bounds]), 60)];
        [intro setAutoresizingMask:CPViewWidthSizable];
        [intro setLineBreakMode:CPLineBreakByWordWrapping];
        [intro setFont:fontTitle];


        [self addSubview:title];
        [self addSubview:site];
        [self addSubview:intro];
    }
    return self;
}

- (void)onHeadlineSelected:(CPNotification)notification
{
    _headline = [notification object];
    if ([_headline unread] == NO)
        [title setFont:fontTitle];
    else
        [title setFont:fontTitleBold];

}

- (void)setObjectValue:(id)headline
{
    if (!headline)
        return;
    if (_headline == headline)
        return;

    [[CPNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_HEADLINE_SELECTED object:_headline];
    _headline = headline;
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(onHeadlineSelected:) name:NOTIFICATION_HEADLINE_SELECTED object:_headline];

    [title setStringValue:[headline title]];
    [site setStringValue:[headline site]];
    if ([_headline unread] == NO)
        [title setFont:fontTitle];
    else
        [title setFont:fontTitleBold];
    [site sizeToFit];
    [intro setStringValue:[headline intro]];
}

- (void)setRowIndex:(int)aRow
{
    row = aRow;
}

@end
