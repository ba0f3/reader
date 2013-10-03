@import <AppKit/CPView.j>
@import <AppKit/CPScrollView.j>

@implementation CPHtmlView : CPView
{
	Object _container;
	CPString _html;
	BOOL _drawsBackground;

	CPFont _textFont;
	CPColor _textColor;

	Function _loadCallback;
}

- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
    {
        _drawsBackground = YES;
		[self setPostsFrameChangedNotifications:YES];
		//[self setPostsBoundsChangedNotifications:YES];
        [self setBackgroundColor:[CPColor whiteColor]];
        [self _initDOMElement];
    }
    return self;
}

- (void)_initDOMElement
{
	_container = document.createElement('div');
	_container.setAttribute('class', 'CPHtmlView');
    //_container.style.width = "100%";
    //_container.style.height = "auto";

    [self _applyBackgroundColor];

    self._DOMElement.appendChild(_container);

    //[self _updateEffectiveScrollMode];

    _loadCallback = function()
    {
    	/* handle images loading to resize view to correct size */
    	var images = _container.querySelectorAll('img');
    	var count = images.length;
    	var _countImage = function() {
			count--;
			if(count <= 0)
			{
				[self setFrameSize:CGSizeMake(_container.offsetWidth, _container.offsetHeight)];
			}
		}
    	if(images.length > 0)
    	{
    		for(var i = 0; i < images.length; i++)
    		{
    			images[i].addEventListener('load', _countImage, false);
    			images[i].addEventListener('error', _countImage, false);
    		}
    	}
    }
}

- (void)_applyBackgroundColor
{
    if (_container)
    {
        var bgColor = [self backgroundColor] || [CPColor whiteColor];
        _container.style.backgroundColor = _drawsBackground ? [bgColor cssString] : "transparent";
    }
}

- (BOOL)drawsBackground
{
    return _drawsBackground;
}

- (void)setDrawsBackground:(BOOL)drawsBackground
{
    if (drawsBackground == _drawsBackground)
        return;

    _drawsBackground = drawsBackground;

    [self _applyBackgroundColor];
}

- (void)setBackgroundColor:(CPColor)aColor
{
    [super setBackgroundColor:aColor];
    [self _applyBackgroundColor];
}

- (void)setHTMLString:(CPString)html
{
	_html = html;
	_container.innerHTML = html;
	_loadCallback();
	[self setFrameSize:CGSizeMake(_container.offsetWidth, _container.offsetHeight)];
}

- (void)setFont:(CPFont)aFont
{
    _textFont = aFont;
    _container.style.fontFamily = [aFont familyName];
    _container.style.fontSize = [aFont size] + 'px';

}

- (CPFont)font
{
    return _textFont;
}

- (void)setTextColor:(CPColor)aColor
{
	_textColor = aColor;
	_container.style.color = [aColor cssString];
}

- (CPColor)textColor
{
    return _textColor;
}

@end
