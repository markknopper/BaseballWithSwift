//
//  WebViewController.m
//
//  Copyright 2013-2018 Bulbous Ventures LLC. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

-(void)viewWillAppear:(BOOL)animated
{
    if (_statsURL) { // if a URL,
        _webBack.enabled = NO; // Turn off back and forward buttons.
        _webForward.enabled = NO;
        // Issue initial URL.
        [_webView loadRequest:[NSURLRequest requestWithURL:_statsURL]];
    }
    // Unhide bottom toolbar.
    [self.navigationController setToolbarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (IBAction) browseBack: (id) sender
{
	if ([_webView canGoBack]){
		[_webView goBack];
	}
}

- (IBAction) browseForward: (id) sender
{
	if ([_webView canGoForward]){
		[_webView goForward];
	}
}

- (IBAction) reloadWeb: (id) sender
{
    // Sometimes 'reload' results in a blank page. So just do another load.
    //[_webView loadRequest:[NSURLRequest requestWithURL:[_webView.request URL]]];
    [_webView reload];
}

-(void)updateBackAndForwardButtons
{
    _webBack.enabled = [_webView canGoBack];
    _webForward.enabled = [_webView canGoForward];
}

- (IBAction) launchSafari: (id) sender{
    UIAlertController *menuSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* safariAction = [UIAlertAction actionWithTitle:@"View in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        // Send URL to system which switches app to Safari. Goodbye for now.
        //[[UIApplication sharedApplication] openURL:[[_webView request] URL] options:@{} completionHandler:nil];
        [[UIApplication sharedApplication] openURL:[_webView URL] options:@{} completionHandler:nil];
    }];
    [menuSheet addAction:safariAction];
    UIAlertAction* copyAction = [UIAlertAction actionWithTitle:@"Copy Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        // Copy Link
        [UIPasteboard generalPasteboard].URL =  [_webView URL];
    }];
    [menuSheet addAction:copyAction];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    [menuSheet addAction:cancelAction];
    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:menuSheet animated:YES completion:nil];
}

#pragma mark UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // starting the load, show the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateBackAndForwardButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.loading) {
        // finished loading, hide the activity indicator in the status bar
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self updateBackAndForwardButtons];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    // load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // *** could give error message to the user, but nah...
    _webBack.enabled = [_webView canGoBack];
    _webForward.enabled = [_webView canGoForward];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_webView stopLoading];	// in case the web view is still loading its content
    _webView.UIDelegate = nil;	// disconnect the delegate as the webview is hidden
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // Hide bottom toolbar on returning.
    [self.navigationController setToolbarHidden:YES];
    [super viewWillDisappear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
