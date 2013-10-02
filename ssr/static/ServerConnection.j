@import <Foundation/Foundation.j>

@implementation ServerConnection : CPObject
{
}

+ (void)post:(CPString)url setDelegate:(id)delegate
{
    [ServerConnection load:url withData:nil setDelegate:delegate];
}
+ (void)post:(CPString)url withData:(CPArray)aData setDelegate:(id)delegate
{
    var req = [[CPURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"POST"];
    if(aData != nil)
        [req setHTTPBody:[CPString JSONFromObject:aData]];
    //[req setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    [req setValue:"application/json" forHTTPHeaderField:@"Content-Type"];
    //[req setValue:"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    var conn = [CPURLConnection connectionWithRequest:req delegate:delegate];
    //[conn start];
}

+ (void)get:(CPString)url setDelegate:(id)delegate
{
    var req = [[CPURLRequest alloc] initWithURL:url];
    [req setHTTPMethod:@"GET"];
    [req setValue:"application/json" forHTTPHeaderField:@"Content-Type"];

    var conn = [CPURLConnection connectionWithRequest:req delegate:delegate];
    [conn start];
}
@end
