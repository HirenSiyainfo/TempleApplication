//
//  ASIAuthenticationDialog.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 21/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "ASIAuthenticationDialog.h"
#import "ASIHTTPRequest.h"
#import <QuartzCore/QuartzCore.h>

static ASIAuthenticationDialog *sharedDialog = nil;
BOOL isDismissing = NO;
static NSMutableArray *requestsNeedingAuthentication = nil;

static const NSUInteger kUsernameRow = 0;
static const NSUInteger kUsernameSection = 0;
static const NSUInteger kPasswordRow = 1;
static const NSUInteger kPasswordSection = 0;
static const NSUInteger kDomainRow = 0;
static const NSUInteger kDomainSection = 1;


@implementation ASIAutorotatingViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

@end


@interface ASIAuthenticationDialog ()
- (void)showTitle;
- (void)show;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *requestsRequiringTheseCredentials;
- (void)presentNextDialog;
@property (retain) UITableView *tableView;
@end

@implementation ASIAuthenticationDialog

#pragma mark init / dealloc

+ (void)initialize
{
	if (self == [ASIAuthenticationDialog class]) {
		requestsNeedingAuthentication = [[NSMutableArray array] retain];
	}
}

+ (void)presentAuthenticationDialogForRequest:(ASIHTTPRequest *)request
{
	// No need for a lock here, this will always be called on the main thread
	if (!sharedDialog) {
		sharedDialog = [[self alloc] init];
		sharedDialog.request = request;
		if (request.authenticationNeeded == ASIProxyAuthenticationNeeded) {
			sharedDialog.type = ASIProxyAuthenticationType;
		} else {
			sharedDialog.type = ASIStandardAuthenticationType;
		}
		[sharedDialog show];
	} else {
		[requestsNeedingAuthentication addObject:request];
	}
}

- (instancetype)init
{
	if ((self = [self initWithNibName:nil bundle:nil])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
			if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
				[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
				[self setDidEnableRotationNotifications:YES];
			}
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
		}
#endif
	}
	return self;
}

- (void)dealloc
{
	if (self.didEnableRotationNotifications)
    {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

	[request release];
	[tableView release];
	[presentingController.view removeFromSuperview];
	[presentingController release];
	[super dealloc];
}

#pragma mark keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_2
		NSValue *keyboardBoundsValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
#else
		NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey];
#endif
		CGRect keyboardBounds;
		[keyboardBoundsValue getValue:&keyboardBounds];
		UIEdgeInsets e = UIEdgeInsetsMake(0, 0, keyboardBounds.size.height, 0);
		self.tableView.scrollIndicatorInsets = e;
		self.tableView.contentInset = e;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
	}
#endif
}

// Manually handles orientation changes on iPhone
- (void)orientationChanged:(NSNotification *)notification
{
	[self showTitle];
	
	UIDeviceOrientation o = *(UIDeviceOrientation *)[UIApplication sharedApplication].statusBarOrientation;
	CGFloat angle = 0;
	switch (o) {
		case UIDeviceOrientationLandscapeLeft: angle = 90; break;
		case UIDeviceOrientationLandscapeRight: angle = -90; break;
		case UIDeviceOrientationPortraitUpsideDown: angle = 180; break;
		default: break;
	}

	CGRect f = [UIScreen mainScreen].applicationFrame;

	// Swap the frame height and width if necessary
 	if (UIDeviceOrientationIsLandscape(o)) {
		CGFloat t;
		t = f.size.width;
		f.size.width = f.size.height;
		f.size.height = t;
	}

	CGAffineTransform previousTransform = self.view.layer.affineTransform;
	CGAffineTransform newTransform = CGAffineTransformMakeRotation(angle * M_PI / 180.0);

	// Reset the transform so we can set the size
	self.view.layer.affineTransform = CGAffineTransformIdentity;
	self.view.frame = (CGRect){0,0,f.size};

	// Revert to the previous transform for correct animation
	self.view.layer.affineTransform = previousTransform;

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];

	// Set the new transform
	self.view.layer.affineTransform = newTransform;

	// Fix the view origin
	self.view.frame = (CGRect){f.origin.x,f.origin.y,self.view.frame.size};
    [UIView commitAnimations];
}
		 
#pragma mark utilities

- (UIViewController *)presentingController
{
	if (!presentingController) {
		presentingController = [[ASIAutorotatingViewController alloc] initWithNibName:nil bundle:nil];

		// Attach to the window, but don't interfere.
		UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
		[window addSubview:presentingController.view];
		presentingController.view.frame = CGRectZero;
		[presentingController.view setUserInteractionEnabled:NO];
	}

	return presentingController;
}

- (UITextField *)textFieldInRow:(NSUInteger)row section:(NSUInteger)section
{
	return [self.tableView cellForRowAtIndexPath:
			   [NSIndexPath indexPathForRow:row inSection:section]].contentView.subviews.firstObject;
}

- (UITextField *)usernameField
{
	return [self textFieldInRow:kUsernameRow section:kUsernameSection];
}

- (UITextField *)passwordField
{
	return [self textFieldInRow:kPasswordRow section:kPasswordSection];
}

- (UITextField *)domainField
{
	return [self textFieldInRow:kDomainRow section:kDomainSection];
}

#pragma mark show / dismiss

+ (void)dismiss
{
	[sharedDialog.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
	[self retain];
	[sharedDialog release];
	sharedDialog = nil;
	[self presentNextDialog];
	[self release];
}

- (void)dismiss
{
	if (self == sharedDialog) {
		[[self class] dismiss];
	} else {
		[self.parentViewController  dismissViewControllerAnimated:YES completion:nil];
	}
}

- (void)showTitle
{
	UINavigationBar *navigationBar = self.view.subviews.firstObject;
	UINavigationItem *navItem = navigationBar.items.firstObject;
	if (UIInterfaceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
		// Setup the title
		if (self.type == ASIProxyAuthenticationType) {
			navItem.prompt = @"Login to this secure proxy server.";
		} else {
			navItem.prompt = @"Login to this secure server.";
		}
	} else {
		[navItem setPrompt:nil];
	}
	[navigationBar sizeToFit];
	CGRect f = self.view.bounds;
	f.origin.y = navigationBar.frame.size.height;
	f.size.height -= f.origin.y;
	self.tableView.frame = f;
}

- (void)show
{
	// Remove all subviews
	UIView *v;
	while ((v = self.view.subviews.lastObject)) {
		[v removeFromSuperview];
	}

	// Setup toolbar
	UINavigationBar *bar = [[[UINavigationBar alloc] init] autorelease];
	bar.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
	bar.items = @[navItem];

	[self.view addSubview:bar];

	[self showTitle];

	// Setup toolbar buttons
	if (self.type == ASIProxyAuthenticationType) {
		navItem.title = self.request.proxyHost;
	} else {
		navItem.title = self.request.url.host;
	}

	navItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAuthenticationFromDialog:)] autorelease];
	navItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(loginWithCredentialsFromDialog:)] autorelease];

	// We show the login form in a table view, similar to Safari's authentication dialog
	[bar sizeToFit];
	CGRect f = self.view.bounds;
	f.origin.y = bar.frame.size.height;
	f.size.height -= f.origin.y;

	self.tableView = [[[UITableView alloc] initWithFrame:f style:UITableViewStyleGrouped] autorelease];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.tableView];

	// Force reload the table content, and focus the first field to show the keyboard
	[self.tableView reloadData];
	[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].contentView.subviews.firstObject becomeFirstResponder];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.modalPresentationStyle = UIModalPresentationFormSheet;
	}
#endif

	[self.presentingController presentViewController:self animated:YES completion:nil];
}

#pragma mark button callbacks

- (void)cancelAuthenticationFromDialog:(id)sender
{
	for (ASIHTTPRequest *theRequest in self.requestsRequiringTheseCredentials) {
		[theRequest cancelAuthentication];
		[requestsNeedingAuthentication removeObject:theRequest];
	}
	[self dismiss];
}

- (NSArray *)requestsRequiringTheseCredentials
{
	NSMutableArray *requestsRequiringTheseCredentials = [NSMutableArray array];
	NSURL *requestURL = self.request.url;
	for (ASIHTTPRequest *otherRequest in requestsNeedingAuthentication) {
		NSURL *theURL = otherRequest.url;
		if ((otherRequest.authenticationNeeded == self.request.authenticationNeeded) && [theURL.host isEqualToString:requestURL.host] && (theURL.port == requestURL.port || (requestURL.port && [theURL.port isEqualToNumber:requestURL.port])) && [theURL.scheme isEqualToString:requestURL.scheme] && ((!otherRequest.authenticationRealm && !self.request.authenticationRealm) || (otherRequest.authenticationRealm && self.request.authenticationRealm && [self.request.authenticationRealm isEqualToString:otherRequest.authenticationRealm]))) {
			[requestsRequiringTheseCredentials addObject:otherRequest];
		}
	}
	[requestsRequiringTheseCredentials addObject:self.request];
	return requestsRequiringTheseCredentials;
}

- (void)presentNextDialog
{
	if (requestsNeedingAuthentication.count) {
		ASIHTTPRequest *nextRequest = requestsNeedingAuthentication.firstObject;
		[requestsNeedingAuthentication removeObjectAtIndex:0];
		[[self class] presentAuthenticationDialogForRequest:nextRequest];
	}
}


- (void)loginWithCredentialsFromDialog:(id)sender
{
	for (ASIHTTPRequest *theRequest in self.requestsRequiringTheseCredentials) {

		NSString *username = [self usernameField].text;
		NSString *password = [self passwordField].text;

		if (username == nil) { username = @""; }
		if (password == nil) { password = @""; }

		if (self.type == ASIProxyAuthenticationType) {
			theRequest.proxyUsername = username;
			theRequest.proxyPassword = password;
		} else {
			theRequest.username = username;
			theRequest.password = password;
		}

		// Handle NTLM domains
		NSString *scheme = (self.type == ASIStandardAuthenticationType) ? self.request.authenticationScheme : self.request.proxyAuthenticationScheme;
		if ([scheme isEqualToString:(NSString *)kCFHTTPAuthenticationSchemeNTLM]) {
			NSString *domain = [self domainField].text;
			if (self.type == ASIProxyAuthenticationType) {
				theRequest.proxyDomain = domain;
			} else {
				theRequest.domain = domain;
			}
		}

		[theRequest retryUsingSuppliedCredentials];
		[requestsNeedingAuthentication removeObject:theRequest];
	}
	[self dismiss];
}

#pragma mark table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
	NSString *scheme = (self.type == ASIStandardAuthenticationType) ? self.request.authenticationScheme : self.request.proxyAuthenticationScheme;
	if ([scheme isEqualToString:(NSString *)kCFHTTPAuthenticationSchemeNTLM]) {
		return 2;
	}
	return 1;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
	if (section == [self numberOfSectionsInTableView:aTableView]-1) {
		return 30;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			return 54;
		}
#endif
		return 30;
	}
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 0) {
		return self.request.authenticationRealm;
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_3_0
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
#else
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:nil] autorelease];
#endif

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	CGRect f = CGRectInset(cell.bounds, 10, 10);
	UITextField *textField = [[[UITextField alloc] initWithFrame:f] autorelease];
	textField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.autocorrectionType = UITextAutocorrectionTypeNo;

	NSUInteger s = indexPath.section;
	NSUInteger r = indexPath.row;

	if (s == kUsernameSection && r == kUsernameRow) {
		textField.placeholder = @"User";
	} else if (s == kPasswordSection && r == kPasswordRow) {
		textField.placeholder = @"Password";
		[textField setSecureTextEntry:YES];
	} else if (s == kDomainSection && r == kDomainRow) {
		textField.placeholder = @"Domain";
	}
	[cell.contentView addSubview:textField];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return 2;
	} else {
		return 1;
	}
}

- (NSString *)tableView:(UITableView *)aTableView titleForFooterInSection:(NSInteger)section
{
	if (section == [self numberOfSectionsInTableView:aTableView]-1) {
		// If we're using Basic authentication and the connection is not using SSL, we'll show the plain text message
		if ([self.request.authenticationScheme isEqualToString:(NSString *)kCFHTTPAuthenticationSchemeBasic] && ![self.request.url.scheme isEqualToString:@"https"]) {
			return @"Password will be sent in the clear.";
		// We are using Digest, NTLM, or any scheme over SSL
		} else {
			return @"Password will be sent securely.";
		}
	}
	return nil;
}

#pragma mark -

@synthesize request;
@synthesize type;
@synthesize tableView;
@synthesize didEnableRotationNotifications;
@synthesize presentingController;
@end
