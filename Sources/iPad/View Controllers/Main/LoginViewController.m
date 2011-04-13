//
//  LoginViewController.m
//  eXoMobile
//
//  Created by Tran Hoai Son on 5/31/10.
//  Copyright 2010 home. All rights reserved.
//

#import "LoginViewController.h"
#import "eXoMobileViewController.h"
#import "Checkbox.h"
#import "defines.h"
#import "Connection.h"
#import "SupportViewController.h"
#import "Configuration.h"
#import "iPadSettingViewController.h"
#import "iPadServerManagerViewController.h"
#import "iPadServerAddingViewController.h"
#import "iPadServerEditingViewController.h"

static NSString *CellIdentifier = @"MyIdentifier";

@implementation LoginViewController

@synthesize _dictLocalize;

// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		_strBSuccessful = [[NSString alloc] init];
		_intSelectedLanguage = 0;
        _intSelectedServer = -1;
        _arrServerList = [[NSMutableArray alloc] init];
		isFirstTimeLogin = YES;
        
        _arrViewOfViewControllers = [[NSMutableArray alloc] init];
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{
	[super loadView];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    _strBSuccessful = @"NO";
    Configuration* configuration = [Configuration sharedInstance];
    _arrServerList = [configuration getServerList];
    
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	_intSelectedLanguage = [[userDefaults objectForKey:EXO_PREFERENCE_LANGUAGE] intValue];
	NSString* filePath;
	if(_intSelectedLanguage == 0)
	{
		filePath = [[NSBundle mainBundle] pathForResource:@"Localize_EN" ofType:@"xml"];
	}	
	else
	{	
		filePath = [[NSBundle mainBundle] pathForResource:@"Localize_FR" ofType:@"xml"];
	}	
	
	_dictLocalize = [[NSDictionary alloc] initWithContentsOfFile:filePath];
	[[self navigationItem] setTitle:[_dictLocalize objectForKey:@"SignInPageTitle"]];	
	
	_intSelectedServer = [[userDefaults objectForKey:EXO_PREFERENCE_SELECTED_SEVER] intValue];
    
	bRememberMe = [[userDefaults objectForKey:EXO_REMEMBER_ME] boolValue];
	bAutoLogin = [[userDefaults objectForKey:EXO_AUTO_LOGIN] boolValue];
    
	_strHost = [userDefaults objectForKey:EXO_PREFERENCE_DOMAIN];
    if (_strHost == nil) 
    {
        ServerObj* tmpServerObj = [_arrServerList objectAtIndex:_intSelectedServer];
        _strHost = tmpServerObj._strServerUrl;
    }
    
	if(bRememberMe || bAutoLogin)
	{
		NSString* username = [userDefaults objectForKey:EXO_PREFERENCE_USERNAME];
		NSString* password = [userDefaults objectForKey:EXO_PREFERENCE_PASSWORD];
		if(username)
		{
			[_txtfUsername setText:username];
		}
		
		if(password)
		{
			[_txtfPassword setText:password];
		}
	}
	else 
	{
		[_txtfUsername setText:@""];
		[_txtfPassword setText:@""];
	}
    
    [_arrViewOfViewControllers addObject:_vLoginView];
    
	[super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationItem setLeftBarButtonItem:nil];
    [self.navigationController.navigationBar setHidden:YES];
}


- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    if (_iPadSettingViewController) 
    {
        [_iPadSettingViewController release];
    }
    if (_iPadServerManagerViewController) 
    {
        [_iPadServerManagerViewController release];
    }
    if (_iPadServerAddingViewController) 
    {
        [_iPadServerAddingViewController release];
    }
    if (_iPadServerEditingViewController) 
    {
        [_iPadServerEditingViewController release];
    }
    [_arrServerList release];
    [_arrViewOfViewControllers release];
    [super dealloc];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _interfaceOrientation = interfaceOrientation;
    return YES;
}

- (void)setDelegate:(id)delegate
{
	_delegate = delegate;
}

- (void)setPreferenceValues
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

	_strUsername = [userDefaults objectForKey:EXO_PREFERENCE_USERNAME]; 
	if(_strUsername)
	{
		[_txtfUsername setText:_strUsername];
		[_txtfUsername resignFirstResponder];
	}
	
	_strPassword = [userDefaults objectForKey:EXO_PREFERENCE_PASSWORD]; 
	if(_strPassword)
	{
		[_txtfPassword setText:_strPassword];
		[_txtfPassword resignFirstResponder];
	}
}

- (void)localize
{
	_dictLocalize = [_delegate getLocalization];
	_intSelectedLanguage = [_delegate getSelectedLanguage];
	/*
	[_lbHostInstruction setText:[_dictLocalize objectForKey:@"DomainHeader"]];
	[_lbHost setText:[_dictLocalize objectForKey:@"DomainCellTitle"]];
	[_lbAccountInstruction setText:[_dictLocalize objectForKey:@"AccountHeader"]];
	[_lbRememberMe setText:[_dictLocalize objectForKey:@"RememberMe"]];
	[_lbAutoSignIn setText:[_dictLocalize objectForKey:@"AutoLogin"]];
	[_btnSignIn setTitle:[_dictLocalize objectForKey:@"SignInButton"] forState:UIControlStateNormal];
	[_btnSetting setTitle:[_dictLocalize objectForKey:@"Language"] forState:UIControlStateNormal];
	[_lbSigningInStatus setText:[_dictLocalize objectForKey:@"SigningIn"]];
						   
	[_settingViewController localize];
    */ 
}

- (void)setSelectedLanguage:(int)languageId
{
	[_delegate setSelectedLanguage:languageId];
}

- (int)getSelectedLanguage
{
	return _intSelectedLanguage;
}

- (NSDictionary*)getLocalization
{
	return _dictLocalize;
}

- (void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     _interfaceOrientation = interfaceOrientation;
    
	if((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
	{
	}
	
	if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
	{	
	}
    
    [self moveView];
}



- (IBAction)onSettingBtn:(id)sender
{
	if(_iPadSettingViewController == nil)
    {
        _iPadSettingViewController = [[iPadSettingViewController alloc] initWithNibName:@"iPadSettingViewController" bundle:nil];
        [_iPadSettingViewController setDelegate:self];
        [_iPadSettingViewController setInterfaceOrientation:_interfaceOrientation];
        [self.view addSubview:_iPadSettingViewController.view];
    }
    
    [self pushViewIn:_iPadSettingViewController.view];
}

- (IBAction)onSignInBtn:(id)sender
{
	[_txtfUsername resignFirstResponder];
	[_txtfPassword resignFirstResponder];
	
	if([_txtfUsername.text isEqualToString:@""])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[_dictLocalize objectForKey:@"Authorization"]
														message:[_dictLocalize objectForKey:@"UserNameEmpty"]
													   delegate:self 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	else
	{		
		NSRange range = [_strHost rangeOfString:@"http://"];
		if(range.length == 0)
		{
			_strHost = [NSString stringWithFormat:@"http://%@", _strHost];
		}
		[self doSignIn];
	}
}

- (void)doSignIn
{
	[_btnLogin setHidden:YES];
	[_actiSigningIn setHidden:NO];
	[_lbSigningInStatus setHidden:NO];
	[_actiSigningIn startAnimating];
	[NSThread detachNewThreadSelector:@selector(startSignInProgress) toTarget:self withObject:nil];
}

- (void)startSignInProgress 
{  	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	_strUsername = [_txtfUsername text];
	_strPassword = [_txtfPassword text];
	
	UIAlertView* alert;
	
	NSString* strResult = [[_delegate _connection] sendAuthenticateRequest:_strHost username:_strUsername password:_strPassword];
	
	if(strResult == @"YES")
	{
		[self performSelectorOnMainThread:@selector(signInSuccesfully) withObject:nil waitUntilDone:NO];  
	}
	else if(strResult == @"NO")
	{
		alert = [[UIAlertView alloc] initWithTitle:[_dictLocalize objectForKey:@"Authorization"]
														message:[_dictLocalize objectForKey:@"WrongUserNamePassword"]
													   delegate:self 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self performSelectorOnMainThread:@selector(signInFailed) withObject:nil waitUntilDone:NO];		
		
	}
	else if(strResult == @"ERROR")
	{
		alert = [[UIAlertView alloc] initWithTitle:[_dictLocalize objectForKey:@"NetworkConnection"]
														message:[_dictLocalize objectForKey:@"NetworkConnectionFailed"]
													   delegate:self 
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
		
		[self performSelectorOnMainThread:@selector(signInFailed) withObject:nil waitUntilDone:NO];  
	}

    [pool release];
}

- (void)signInSuccesfully
{
	[_actiSigningIn stopAnimating];
	[_actiSigningIn setHidden:YES];
	[_lbSigningInStatus setHidden:YES];
	[_btnLogin setHidden:NO];
	
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];

	[userDefaults setObject:_strHost forKey:EXO_PREFERENCE_DOMAIN];
	[userDefaults setObject:_strUsername forKey:EXO_PREFERENCE_USERNAME];
	[userDefaults setObject:_strPassword forKey:EXO_PREFERENCE_PASSWORD];

	[_delegate showMainViewController];
}

- (void)signInFailed
{
	[_actiSigningIn stopAnimating];
	[_actiSigningIn setHidden:YES];
	[_lbSigningInStatus setHidden:YES];
	[_btnLogin setHidden:NO];
}

- (IBAction)onBtnAccount:(id)sender
{
    [_btnServerList setBackgroundColor:[UIColor grayColor]];
    [_btnAccount setBackgroundColor:[UIColor blueColor]];
    [_vLoginView bringSubviewToFront:_vAccountView];
}

- (IBAction)onBtnServerList:(id)sender
{
    [_btnServerList setBackgroundColor:[UIColor blueColor]];
    [_btnAccount setBackgroundColor:[UIColor grayColor]];    
    [_vLoginView bringSubviewToFront:_vServerListView];    
    [_tbvlServerList reloadData];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField 
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _txtfUsername) 
    {
        [_txtfPassword becomeFirstResponder];
    }
    else
    {    
        [_txtfPassword resignFirstResponder];
        [self onSignInBtn:nil];
    }    
	return YES;
}

- (void)hitAtView:(UIView*) view
{
	if([view class] != [UITextField class])
	{
		[_txtfUsername resignFirstResponder];
		[_txtfPassword resignFirstResponder];
	}
}

- (void)pushViewIn:(UIView*)view
{
    [_arrViewOfViewControllers addObject:view];
    if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
	{
        [view setFrame:CGRectMake(SCR_WIDTH_PRTR_IPAD, 0, SCR_WIDTH_PRTR_IPAD, SCR_HEIGHT_PRTR_IPAD)];
	}
	
	if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
	{	
        [view setFrame:CGRectMake(SCR_WIDTH_LSCP_IPAD, 0, SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD)];
	}
    
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
    [self moveView];
    [UIView commitAnimations];
}

- (void)pullViewOut:(UIView*)viewController
{
    [self jumpToViewController:[_arrViewOfViewControllers count] - 2]; 
    [_arrViewOfViewControllers removeLastObject];
//    [UIView beginAnimations:nil context:nil];
//	[UIView setAnimationDuration:0.75];
//	[UIView setAnimationDelegate:self];
//    if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
//	{
//        [viewController setFrame:CGRectMake(SCR_WIDTH_PRTR_IPAD, 0, SCR_WIDTH_PRTR_IPAD, SCR_HEIGHT_PRTR_IPAD)];
//	}
//	
//	if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
//	{	
//        [viewController setFrame:CGRectMake(SCR_WIDTH_LSCP_IPAD, 0, SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD)];
//	}
//    [self moveView];
//    [UIView commitAnimations];
}

- (void)jumpToViewController:(int)index
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
    for (int i = 0; i < [_arrViewOfViewControllers count]; i++) 
    {
        UIView* tmpView = [_arrViewOfViewControllers objectAtIndex:i];
        int p = i - index;
//        if (p == 0) 
//        {
//            _intCurrentViewId = i;
//        }
//        [tmpView setFrame:CGRectMake(p*SCR_WIDTH_LSCP_IPAD, 0, SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD)];
        if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
        {
            [tmpView setFrame:CGRectMake(p*SCR_WIDTH_PRTR_IPAD, 0, SCR_WIDTH_PRTR_IPAD, SCR_HEIGHT_PRTR_IPAD)];
        }
        
        if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        {	
            [tmpView setFrame:CGRectMake(p*SCR_WIDTH_LSCP_IPAD, 0, SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD)];
        }
    }
    [UIView commitAnimations];
}



- (void)moveView
{
    for (int i = 0; i < [_arrViewOfViewControllers count]; i++) 
    {
        UIView* tmpView = [_arrViewOfViewControllers objectAtIndex:i];
        [tmpView removeFromSuperview];
        
        int p = i - [_arrViewOfViewControllers count] + 1;
        if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
        {
            [tmpView setFrame:CGRectMake(p*SCR_WIDTH_PRTR_IPAD, 0, SCR_WIDTH_PRTR_IPAD, SCR_HEIGHT_PRTR_IPAD)];
        }
        
        if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
        {	
            [tmpView setFrame:CGRectMake(p*SCR_WIDTH_LSCP_IPAD, 0, SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD)];
        }
        [self.view addSubview:tmpView];
    }
    if (_iPadSettingViewController) 
    {
        [_iPadSettingViewController changeOrientation:_interfaceOrientation];
    }
    if (_iPadServerManagerViewController) 
    {
        [_iPadServerManagerViewController changeOrientation:_interfaceOrientation];
    }
    if (_iPadServerAddingViewController) 
    {
        [_iPadServerAddingViewController changeOrientation:_interfaceOrientation];
    }
    if (_iPadServerEditingViewController) 
    {
        [_iPadServerEditingViewController changeOrientation:_interfaceOrientation];
    }
}

- (void)onBackDelegate
{
    [self pullViewOut:[_arrViewOfViewControllers lastObject]];
}


- (void)showiPadServerManagerViewController
{
    if (_iPadServerManagerViewController == nil) 
    {
        _iPadServerManagerViewController = [[iPadServerManagerViewController alloc] initWithNibName:@"iPadServerManagerViewController" bundle:nil];
        [_iPadServerManagerViewController setDelegate:self];
        [_iPadServerManagerViewController setInterfaceOrientation:_interfaceOrientation];
        [self.view addSubview:_iPadServerManagerViewController.view];
    }
    [self pushViewIn:_iPadServerManagerViewController.view];
}


- (void)showiPadServerAddingViewController
{
    if (_iPadServerAddingViewController == nil) 
    {
        _iPadServerAddingViewController = [[iPadServerAddingViewController alloc] initWithNibName:@"iPadServerAddingViewController" bundle:nil];
        [_iPadServerAddingViewController setDelegate:self];
        [_iPadServerAddingViewController setInterfaceOrientation:_interfaceOrientation];
        [self.view addSubview:_iPadServerAddingViewController.view];
    }
    [self pushViewIn:_iPadServerAddingViewController.view];
}

- (void)showiPadServerEditingViewControllerWithServerObj:(ServerObj*)serverObj andIndex:(int)index
{
    if (_iPadServerEditingViewController == nil) 
    {
        _iPadServerEditingViewController = [[iPadServerEditingViewController alloc] initWithNibName:@"iPadServerEditingViewController" bundle:nil];
        [_iPadServerEditingViewController setDelegate:self];
        [_iPadServerEditingViewController setInterfaceOrientation:_interfaceOrientation];
        [self.view addSubview:_iPadServerEditingViewController.view];
    }
    [_iPadServerEditingViewController setServerObj:serverObj andIndex:index];
    [self pushViewIn:_iPadServerEditingViewController.view];
}

- (void)editServerObjAtIndex:(int)intIndex withSeverName:(NSString*)strServerName andServerUrl:(NSString*)strServerUrl
{
    if (_iPadServerManagerViewController) 
    {
        [_iPadServerManagerViewController editServerObjAtIndex:intIndex withSeverName:strServerName andServerUrl:strServerUrl];
        [self pullViewOut:[_arrViewOfViewControllers lastObject]];
    }
}

- (void)deleteServerObjAtIndex:(int)intIndex
{
    if (_iPadServerManagerViewController) 
    {
        [_iPadServerManagerViewController deleteServerObjAtIndex:intIndex];
    }
}

- (void)addServerObjWithServerName:(NSString*)strServerName andServerUrl:(NSString*)strServerUrl
{
    if(_iPadServerManagerViewController)
    {
        [_iPadServerManagerViewController addServerObjWithServerName:strServerName andServerUrl:strServerUrl]; 
        [self pullViewOut:[_arrViewOfViewControllers lastObject]];
    }    
}
#pragma UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{	
    return [_arrServerList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == _intSelectedServer) 
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	ServerObj* tmpServerObj = [_arrServerList objectAtIndex:indexPath.row];
    
    UILabel* lbServerName = [[UILabel alloc] initWithFrame:CGRectMake(2, 5, 150, 30)];
    lbServerName.text = tmpServerObj._strServerName;
    lbServerName.textColor = [UIColor brownColor];
    [cell addSubview:lbServerName];
    [lbServerName release];
    
    UILabel* lbServerUrl = [[UILabel alloc] initWithFrame:CGRectMake(155, 5, 120, 30)];
    lbServerUrl.text = tmpServerObj._strServerUrl;
    [cell addSubview:lbServerUrl];
    [lbServerUrl release];
    
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerObj* tmpServerObj = [_arrServerList objectAtIndex:indexPath.row];
    _strHost = [tmpServerObj._strServerUrl retain];
    _intSelectedServer = indexPath.row;
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_strHost forKey:EXO_PREFERENCE_DOMAIN];
	[userDefaults setObject:[NSString stringWithFormat:@"%d",_intSelectedServer] forKey:EXO_PREFERENCE_SELECTED_SEVER];
    [_tbvlServerList reloadData];
}

@end
