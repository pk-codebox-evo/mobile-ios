//
// Copyright (C) 2003-2014 eXo Platform SAS.
//
// This is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as
// published by the Free Software Foundation; either version 3 of
// the License, or (at your option) any later version.
//
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this software; if not, write to the Free
// Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
// 02110-1301 USA, or see the FSF site: http://www.fsf.org.
//

#import "AppDelegate_iPhone.h"

#import "defines.h"
#import "FilesProxy.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "UserPreferencesManager.h"
#import "WelcomeViewController_iPhone.h"
#import "UINavigationBar+ BackButtonDisplayFix.h"


@implementation AppDelegate_iPhone

@synthesize window;
@synthesize authenticateViewController = _authenticateViewController;
@synthesize navigationController;
@synthesize isCompatibleWithSocial = _isCompatibleWithSocial;
@synthesize homeSidebarViewController_iPhone = _homeSidebarViewController_iPhone;

+ (AppDelegate_iPhone *) instance {
    return (AppDelegate_iPhone *) [[UIApplication sharedApplication] delegate];    
}

- (instancetype)init {
	if ((self = [super init])) {
	}
	return self;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    //Add Crashlytics
    
    [Fabric with:@[CrashlyticsKit]];
    application.statusBarHidden = YES;
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3    
    //Configuring the Navigation Bar for iOS 5
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavbarBg.png"] 
                                           forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        UIImage *barButton = [UIImage imageNamed:@"NavbarBackButton.png" ];
        barButton = [barButton stretchableImageWithLeftCapWidth:barButton.size.width / 2 topCapHeight:0];
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        
        UIImage *barActionButton = [UIImage imageNamed:@"NavbarActionButton.png"];
        barActionButton = [barActionButton stretchableImageWithLeftCapWidth:barButton.size.width / 2 topCapHeight:0];
        [[UIBarButtonItem appearance] setBackgroundImage:barActionButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [[UINavigationBar appearance] setBackIndicatorImage:nil];
        
    }
    if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
        [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"NavbarBg.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
#endif
    
    BOOL accountConfigured = [[NSUserDefaults standardUserDefaults] boolForKey:EXO_CLOUD_ACCOUNT_CONFIGURED];
    
    if([[ApplicationPreferencesManager sharedInstance].serverList count] > 0) {
        accountConfigured = YES; // case upgrade, there were already servers
    }
    
    if(!accountConfigured) {
        WelcomeViewController_iPhone *welcomeVC = [[WelcomeViewController_iPhone alloc] initWithNibName:@"WelcomeViewController_iPhone" bundle:nil];
        navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeVC];
    }
    
    navigationController.navigationBarHidden = YES;

    window.rootViewController = navigationController;

	[window makeKeyAndVisible];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOption {
    [super application:application didFinishLaunchingWithOptions:launchOption];
    [self applicationDidFinishLaunching:application];
    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    [super application:application handleOpenURL:url];
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:_authenticateViewController]; //display authenticate screen
    [self.authenticateViewController showHideSwitcherTab];
    
    window.rootViewController = navigationController;
    return YES;
}

- (void)showHomeSidebarViewController {
    // Login is successfully
    [[FilesProxy sharedInstance] creatUserRepositoryHomeUrl];
    [[SocialRestConfiguration sharedInstance] updateDatas];
    
    
    [UserPreferencesManager sharedInstance].isUserLogged = YES;
    
    _homeSidebarViewController_iPhone = [[HomeSidebarViewController_iPhone alloc] initWithNibName:nil bundle:nil];
    
    window.rootViewController = _homeSidebarViewController_iPhone;
}



- (void)showHomeViewController {
    // Login is successfully
    
    [[FilesProxy sharedInstance] creatUserRepositoryHomeUrl];
    [[SocialRestConfiguration sharedInstance] updateDatas];
    
    
    [UserPreferencesManager sharedInstance].isUserLogged = YES;
    
}

- (void)onBtnSigtOutDelegate {
    
    // Disable Auto Login so user won't be signed in automatically after
    if(![UserPreferencesManager sharedInstance].rememberMe) {
        [_authenticateViewController disableAutoLogin:YES];
    }
    [_authenticateViewController updateAfterLogOut];
    [_authenticateViewController autoFillCredentials];
    navigationController = [[UINavigationController alloc] initWithRootViewController:_authenticateViewController];
    window.rootViewController = navigationController;
    
    [UserPreferencesManager sharedInstance].isUserLogged = NO;
    
    [LoginProxy doLogout];
}

@end
