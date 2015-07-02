/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "MTCordovaSampleAppViewController.h"

@implementation MTCordovaSampleAppViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark UIWebDelegate implementation

// External links (http) will open in Safari instead of the project's UIWebView
// http://stackoverflow.com/questions/9746260/how-can-i-open-an-external-link-in-safari-not-the-apps-uiwebview
- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    // forward http[s] requests to Safari
    if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"]) {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    // if not http, send to Cordova webview
    else {
        return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];

    return [super webViewDidFinishLoad:theWebView];
}
@end

#pragma mark CDVCommandDelegate implementation
@implementation MainCommandDelegate
/* To override the methods, uncomment the line in the init function(s)
   in MTCordovaSampleAppViewController.m
 */
- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}
@end

#pragma mark CDVCommandDelegate implementation
@implementation MainCommandQueue
/* To override, uncomment the line in the init function(s)
   in MTCordovaSampleAppViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}
@end
