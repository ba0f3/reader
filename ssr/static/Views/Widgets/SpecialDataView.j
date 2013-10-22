@implementation SpecialDataView : CPView
{
    CPImageView _image;
    CPTextField _text;
    CPTextField _badge;
    id _objectValue;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        _image = [[CPImageView alloc] initWithFrame:CGRectMake(0, 4, 16, 16)];
        [_image setImage:[[CPImage alloc] initWithContentsOfFile:@"static/Resources/MonoFolder.png" size:CGSizeMake(16, 16)]];
        [self addSubview:_image];

        _text = [[CPTextField alloc] initWithFrame:CGRectMake(20.0, 0.0, 130.0, 25.0)];
        [_text setVerticalAlignment:CPCenterVerticalTextAlignment];
        [_text setLineBreakMode:CPLineBreakByTruncatingTail];
        [self addSubview:_text];

        _badge = [[CPTextField alloc] initWithFrame:CGRectMake(195.0, 0.0, 25.0, 25.0)];
        [_badge setVerticalAlignment:CPCenterVerticalTextAlignment];
        [_badge setAlignment:CPCenterTextAlignment];
        [_badge setBackgroundColor:[CPColor colorWithHexString:@"666"]];
        [_badge setTextColor:[CPColor colorWithHexString:@"fff"]];
        _badge._DOMElement.style.borderRadius = "7px";
        [self addSubview:_badge];
    }
    return self;
}

- (void)setStringValue:(CPString)text
{
    [_text setStringValue:text];
}

- (void)setUnread:(int)unread
{
    if (unread != nil && unread != undefined && unread > 0)
    {
        [_badge setStringValue:unread];
        [self showBadge];
    }
    else
    {
        [self hideBadge];
    }
}

- (void)setObjectValue:(id)object
{
    if (_objectValue === object)
        return;
    var image;
    if (object == @"Special")
    {
        [_badge setHidden:YES];
        image = [[CPImage alloc] initWithContentsOfFile:@"static/Resources/smart-folder.png" size:CGSizeMake(16, 16)];
    }
    else if (object == @"All")
        image = [[CPImage alloc] initWithContentsOfFile:@"static/Resources/AllItems.png" size:CGSizeMake(16, 16)];
    else if (object == @"Unread")
        image = [[CPImage alloc] initWithContentsOfFile:@"static/Resources/MonoUnread.png" size:CGSizeMake(16, 16)];
    else if (object == @"Starred")
        image = [[CPImage alloc] initWithContentsOfFile:@"static/Resources/StarredToolbarIcon.png" size:CGSizeMake(16, 16)];
    else if (object == @"Archives")
        image = [[CPImage alloc] initWithContentsOfFile:@"static/Resources/archive.png" size:CGSizeMake(16, 16)];

    if (object != @"Special")
        [_badge setFrame:CGRectMake(180.0, 0.0, 25.0, 25.0)]

    [_image setImage:image];
    [_text setStringValue:object];
}

- (void)onItemUnreadUpdated:(CPNotification)notification
{
    //XXX
}

- (void)showBadge
{
    [_badge setHidden:NO];
}

- (void)hideBadge
{
    [_badge setHidden:YES];
}
@end
