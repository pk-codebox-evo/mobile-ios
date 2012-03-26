//
//  iPadSettingViewController.m
//  eXoMobile
//
//  Created by Tran Hoai Son on 5/31/10.
//  Copyright 2010 home. All rights reserved.
//

#import "iPadSettingViewController.h"
#import "eXoMobileViewController.h"
#import "defines.h"
#import "Connection.h"
#import "LoginViewController.h"
#import "Configuration.h"
#import "iPadServerManagerViewController.h"

static NSString *CellIdentifier = @"MyIdentifier";
#define kTagForCellSubviewTitleLabel 222
#define kTagForCellSubviewImageView 333


@implementation iPadSettingViewController

@synthesize _dictLocalize;
@synthesize tblView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))  
	{
		edit = NO;
		
		rememberMe = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 100, 20)];
		[rememberMe addTarget:self action:@selector(rememberMeAction) forControlEvents:UIControlEventValueChanged];
		autoLogin = [[UISwitch alloc] initWithFrame:CGRectMake(200, 10, 100, 20)];
		[autoLogin addTarget:self action:@selector(autoLoginAction) forControlEvents:UIControlEventValueChanged];
		
		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		_selectedLanguage = [[userDefaults objectForKey:EXO_PREFERENCE_LANGUAGE] intValue];
        bRememberMe = [[userDefaults objectForKey:EXO_REMEMBER_ME] boolValue];
		bAutoLogin = [[userDefaults objectForKey:EXO_AUTO_LOGIN] boolValue];
		
		serverNameStr = [userDefaults objectForKey:EXO_PREFERENCE_DOMAIN]; 
        
        _arrServerList = [[NSMutableArray alloc] init];
        _intSelectedServer = -1;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.title = [_dictLocalize objectForKey:@"Settings"];
	[tblView reloadData];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:YES];    
}

- (void)viewDidDisappear:(BOOL)animated
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:[NSString stringWithFormat:@"%d", rememberMe.on] forKey:EXO_REMEMBER_ME];
	[userDefaults setObject:[NSString stringWithFormat:@"%d", autoLogin.on] forKey:EXO_AUTO_LOGIN];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    _arrServerList = [[Configuration sharedInstance] getServerList];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _intSelectedServer = [[userDefaults objectForKey:EXO_PREFERENCE_SELECTED_SEVER] intValue];
}

- (void)dealloc 
{
    [_arrServerList release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self changeOrientation:interfaceOrientation];
}

- (void)changeOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
	{
        [tblView setFrame:CGRectMake(0, 44, SCR_WIDTH_PRTR_IPAD, SCR_HEIGHT_PRTR_IPAD - 44)];
        [tblView setContentSize:CGSizeMake(SCR_WIDTH_PRTR_IPAD, SCR_HEIGHT_PRTR_IPAD - 44)];
	}
    
    if((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
	{	
        [tblView setFrame:CGRectMake(0, 44, SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD - 44)];
        [tblView setContentSize:CGSizeMake(SCR_WIDTH_LSCP_IPAD, SCR_HEIGHT_LSCP_IPAD - 44)];
	}
    [self.view addSubview:tblView];
    [self.view bringSubviewToFront:tblView];
    _interfaceOrientation = interfaceOrientation;
    [tblView reloadData];
}

- (void)setDelegate:(id)delegate
{
    _delegate = delegate;
    _dictLocalize = [_delegate getLocalization];
}

- (void)localize
{
    _dictLocalize = [_delegate getLocalization];
    [tblView reloadData];
}

- (IBAction)onBtnBack:(id)sender
{
    [_delegate onBackDelegate];
}

- (void)save 
{
	edit = !edit;
	if(edit) 
	{
		rememberMe.enabled = YES;
		autoLogin.enabled = YES;
		self.navigationItem.rightBarButtonItem.title = [_dictLocalize objectForKey:@"Save"];
	}
	else
	{
		rememberMe.enabled = NO;
		autoLogin.enabled = NO;
		self.navigationItem.rightBarButtonItem.title = [_dictLocalize objectForKey:@"Edit"];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:[NSString stringWithFormat:@"%d", _selectedLanguage] forKey:EXO_PREFERENCE_LANGUAGE];		
	}
	[tblView reloadData];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
}

- (void)rememberMeAction 
{
	NSString *str = @"NO";
	bRememberMe = rememberMe.on;
	if(bRememberMe)
    {
		str = @"YES";
    }
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:str forKey:EXO_REMEMBER_ME];
}

- (void)autoLoginAction 
{
	NSString *str = @"NO";
	bAutoLogin = autoLogin.on;
	if(bAutoLogin)
    {
		str = @"YES";
    }
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:str forKey:EXO_AUTO_LOGIN];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString* tmpStr = @"";
	switch (section) 
	{
		case 0:
		{
			tmpStr = [_dictLocalize objectForKey:@"SignInButton"];
			break;
		}
			
		case 1:
		{
			tmpStr = [_dictLocalize objectForKey:@"Language"];
			break;
		}
			
		case 2:
		{
			tmpStr = [_dictLocalize objectForKey:@"ServerList"];
			break;
		}
            
		case 3:
		{
			tmpStr = [_dictLocalize objectForKey:@"UserGuide"];
			break;
		}
			
		default:
			break;
	}
	
	return tmpStr;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int numofRows = 0;
	if(section == 0)
	{
		numofRows = 2;
	}	
	if(section == 1)
	{	
		numofRows = 2;
	}	
	if(section == 2)
	{	
		numofRows = [_arrServerList count] + 1;
	}
    if(section == 3)
	{	
		numofRows = 1;
	}
    
	return numofRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float fWidth = 0;
    if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
    {
        fWidth = 450;
    }
    
    if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
    {
        fWidth = 700;
    }
    
    float fHeight = 44.0;
    if(indexPath.section == 2)
	{
        if (indexPath.row < [_arrServerList count]) 
        {
            ServerObj* tmpServerObj = [_arrServerList objectAtIndex:indexPath.row];
            NSString* text = tmpServerObj._strServerUrl; 
            CGSize theSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(fWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
            fHeight = 44*((int)theSize.height/44 + 1);
        }
    }
    return fHeight;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if(cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch (indexPath.section) 
    {
        case 0:
        {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];  
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
            {
                [rememberMe setFrame:CGRectMake(614, 10, 94, 27)];
                [autoLogin setFrame:CGRectMake(614, 10, 94, 27)];
            }
            
            if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
            {	
                [rememberMe setFrame:CGRectMake(870, 10, 94, 27)];
                [autoLogin setFrame:CGRectMake(870, 10, 94, 27)];
            }
            
            if(indexPath.row == 0)
            {
                cell.textLabel.text = [_dictLocalize objectForKey:@"RememberMe"];
                rememberMe.on = bRememberMe;
                [cell addSubview:rememberMe];
            }
            else 
            {
                cell.textLabel.text = [_dictLocalize objectForKey:@"AutoLogin"];
                autoLogin.on = bAutoLogin;
                [cell addSubview:autoLogin];
            }
            break;
        }
            
        case 1: 
        {
            UIImageView* imgV;
            UILabel* titleLabel;
            if(indexPath.row == 0)
            {
                imgV = [[UIImageView alloc] initWithFrame:CGRectMake(55.0, 14.0, 27, 17)];
                imgV.image = [UIImage imageNamed:@"EN.gif"];
                [cell addSubview:imgV];
                
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 13.0, 250.0, 20.0)];
                titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
                titleLabel.text = [_dictLocalize objectForKey:@"English"];
                [cell addSubview:titleLabel];
            }
            else
            {
                imgV = [[UIImageView alloc] initWithFrame:CGRectMake(55.0, 14.0, 27, 17)];
                imgV.image = [UIImage imageNamed:@"FR.gif"];
                [cell addSubview:imgV];	
                
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 13.0, 250.0, 20.0)];
                titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
                titleLabel.text = [_dictLocalize objectForKey:@"French"];
                [cell addSubview:titleLabel];	
            }
            [imgV release];
            [titleLabel release];
            
            if(indexPath.row == _selectedLanguage)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } 
            else
            {            
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
            
        case 2:
        {
            if (indexPath.row < [_arrServerList count]) 
            {
                ServerObj* tmpServerObj = [_arrServerList objectAtIndex:indexPath.row];
                
                UILabel* lbServerName = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 150, 30)];
                lbServerName.text = tmpServerObj._strServerName;
                lbServerName.textColor = [UIColor brownColor];
                [cell addSubview:lbServerName];
                [lbServerName release];
                
                float fWidth = 0;
                if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
                {
                    fWidth = 450;
                }
                
                if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
                {
                    fWidth = 700;
                }
                
                UILabel* lbServerUrl = [[UILabel alloc] initWithFrame:CGRectMake(220, 5, 400, 30)];
                NSString* text = tmpServerObj._strServerUrl; 
                CGSize theSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:18.0f] constrainedToSize:CGSizeMake(fWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
                [lbServerUrl setFrame:CGRectMake(220, 5, fWidth, 44*((int)theSize.height/44 + 1) - 10)];
                [lbServerUrl setNumberOfLines:(int)theSize.height/44 + 1];
                
                lbServerUrl.text = tmpServerObj._strServerUrl;
                [cell addSubview:lbServerUrl];
                [lbServerUrl release];
                
                if (indexPath.row == _intSelectedServer) 
                {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            else
            {                                
                UILabel* lbModify = [[UILabel alloc] init];
                if((_interfaceOrientation == UIInterfaceOrientationPortrait) || (_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
                {
                    [lbModify setFrame:CGRectMake(55, 5, 650, 30)];
                }
                
                if((_interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (_interfaceOrientation == UIInterfaceOrientationLandscapeRight))
                {	
                    [lbModify setFrame:CGRectMake(55, 5, 900, 30)];
                }
                
                [lbModify setTextAlignment:UITextAlignmentCenter];
                lbModify.textColor = [UIColor redColor];
                [lbModify setText:[_dictLocalize objectForKey:@"ServerModify"]];
                [cell addSubview:lbModify];
                [lbModify release];
            }
            break;
        }
            
        case 3:
        {
            cell.textLabel.text = [_dictLocalize objectForKey:@"UserGuide"];				
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];			
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
            
        default:
            break;
    }
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if(indexPath.section == 1)
	{
		_selectedLanguage = indexPath.row;
		[[self.navigationController.tabBarController.viewControllers objectAtIndex:0] 
         setTitle:[_dictLocalize objectForKey:@"ApplicationsTitle"]];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:[NSString stringWithFormat:@"%d", rememberMe.on] forKey:EXO_REMEMBER_ME];
		[userDefaults setObject:[NSString stringWithFormat:@"%d", autoLogin.on] forKey:EXO_AUTO_LOGIN];
		[userDefaults setObject:[NSString stringWithFormat:@"%d", _selectedLanguage] forKey:EXO_PREFERENCE_LANGUAGE];
		
		[_delegate setSelectedLanguage:_selectedLanguage];
	}
	else if(indexPath.section == 2)
	{
        if (indexPath.row < [_arrServerList count]) 
        {
            ServerObj* tmpServerObj = [_arrServerList objectAtIndex:indexPath.row];
            _intSelectedServer = indexPath.row;
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:tmpServerObj._strServerUrl forKey:EXO_PREFERENCE_DOMAIN];
            [userDefaults setObject:[NSString stringWithFormat:@"%d",_intSelectedServer] forKey:EXO_PREFERENCE_SELECTED_SEVER];
            [tableView reloadData];
        }
        else
        {
            [_delegate showiPadServerManagerViewController];
            [tblView deselectRowAtIndexPath:indexPath animated:YES];
        }
	}
	else if(indexPath.section == 3)
    {
        /*
		eXoWebViewController *userGuideController = [[eXoWebViewController alloc] initWithNibAndUrl:@"eXoWebViewController" bundle:nil url:nil];
		userGuideController._delegate = _delegate;
		[self.navigationController pushViewController:userGuideController animated:YES];
        */ 
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:txtfDomainName.text forKey:EXO_PREFERENCE_DOMAIN];
	[textField resignFirstResponder];
	return YES;
}


@end
