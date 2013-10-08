@import "CPFaviconView.j"

var CategoryDataViewImage = 1,
    CategoryDataViewText = 2,
    CategoryDataViewBadge = 3;
@implementation CategoryDataView : CPView
{
    CPFaviconView _image;
    CPTextField _text;
    CPTextField _badge;
    id _objectValue;
    CPString _stringValue;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        _image = [[CPFaviconView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
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
    _stringValue = text;
    [_text setStringValue:text];
}

- (void)setUnread:(int)unread
{
    if (unread)
    {
        [_badge setHidden:NO];
        [_badge setStringValue:unread];
    }
    else
    {
        [_badge setHidden:YES];
    }
}

- (void)setObjectValue:(id)object
{
    CPLog("CategoryDataView.setObjectValue:%@", object);
    _objectValue = object;
    if ([object className] == 'Feed')
    {
        [_image setObjectValue:object];
        [_badge setFrame:CGRectMake(180.0, 0.0, 25.0, 25.0)]
    }
    else
    {
        [_text setFrame:CGRectMake(0.0, 0.0, 160.0, 25.0)];
        [_image setHidden:YES];
    }
    [self setUnread:[object unread]];
}
@end
