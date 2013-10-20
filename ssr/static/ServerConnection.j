@import <Foundation/Foundation.j>
@import "Constants.j"

var _authToken = localStorage.authToken || nil;
@implementation ServerConnection : CPObject
{
    id _delegate;

}

+ (void)setAuthToken:(CPString)authToken
{
    _authToken = authToken;
    //TODO: protect authToken
    localStorage.authToken = _authToken;
}

- (id)delegate
{
    return _delegate;
}

- (void)get:(CPString)url setDelegate:(id)delegate
{
    _delegate = delegate;
    var req = [[CPURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"GET"];
    var conn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)post:(CPString)url setDelegate:(id)delegate
{
    _delegate = delegate;
    var req = [[CPURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    var conn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)postJSON:(CPString)url withObject:(Object)object setDelegate:(id)delegate
{
    _delegate = delegate;

    var req = [[CPURLRequest alloc] initWithURL:url];
    if (_authToken != nil && _authToken != undefined && _authToken != "")
    {
        [req setValue:_authToken forHTTPHeaderField:@"X-Authentication-Token"];
    }
    [req setHTTPMethod:@"POST"];
    if (object != nil)
        [req setHTTPBody:[CPString JSONFromObject:object]];
    [req setValue:"application/json" forHTTPHeaderField:@"Content-Type"];
    var conn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)getJSON:(CPString)url setDelegate:(id)delegate
{
    _delegate = delegate;

    var req = [[CPURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"GET"];
    if (_authToken != nil && _authToken != undefined && _authToken != "")
    {
        [req setValue:_authToken forHTTPHeaderField:@"X-Authentication-Token"];
    }
    [req setValue:"application/json" forHTTPHeaderField:@"Content-Type"];

    var conn = [CPURLConnection connectionWithRequest:req delegate:self];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(id)error
{
    if ([_delegate respondsToSelector:@selector(connection:didFailWithError:)])
        [_delegate connection:connection didFailWithError:error];
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
    if ([_delegate respondsToSelector:@selector(connection:didReceiveData:)])
        [_delegate connection:connection didReceiveData:data];
}

- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
    if ([_delegate respondsToSelector:@selector(connectionDidFinishLoading:)])
        [_delegate connectionDidFinishLoading:connection];
}
@end
