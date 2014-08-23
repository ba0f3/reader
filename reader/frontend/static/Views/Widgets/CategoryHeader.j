@implementation CategoryHeader : CPView
{

}
- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self)
    {
        self._DOMElement.style.background = "url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAAaCAAAAABTb2kNAAAAF0lEQVQIW2M4w/Cf6T8TAxKGkeg0XA0AzfUQ7Z1M4bMAAAAASUVORK5CYII=) repeat-x";

        var fontDosisBold = [CPFont boldFontWithName:'Dosis' size:12],
            text = [[CPTextField alloc] initWithFrame:CGRectMake(10.0, 0.0, CGRectGetWidth([self bounds]), CGRectGetHeight([self bounds]))];
        [text setAutoresizingMask:CPViewWidthSizable];
        [text setTextColor:[CPColor colorWithHexString:@"333"]];
        [text setTextShadowColor:[CPColor colorWithHexString:@"CCC"]];
        [text setTextShadowOffset:CGSizeMake(1.0, 1.0)];
        //[text setFont:fontDosisBold];
        [text setVerticalAlignment:CPCenterVerticalTextAlignment];
        [text setStringValue:@"Categories"];

        [self addSubview:text];

    }

    return self;
}
@end
