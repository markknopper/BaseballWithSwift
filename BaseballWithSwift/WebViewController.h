//
//  WebViewController.h
//
//  Copyright 2013-2019 Bulbous Ventures LLC. All rights reserved.
//

@import UIKit;
@import WebKit;

@interface WebViewController : UIViewController <WKUIDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webForward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *webBack;
@property (strong, nonatomic) NSURL *statsURL;

- (IBAction) browseBack: (id) sender;
- (IBAction) browseForward: (id) sender;
- (IBAction) reloadWeb: (id) sender;
- (IBAction) launchSafari: (id) sender;

@end
