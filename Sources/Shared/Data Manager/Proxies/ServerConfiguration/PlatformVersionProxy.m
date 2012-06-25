//
//  PlatformVersionProxy.m
//  eXo Platform
//
//  Created by Stévan Le Meur on 26/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlatformVersionProxy.h"
#import "ServerPreferencesManager.h"
#import "defines.h"


@implementation PlatformVersionProxy

@synthesize isPlatformCompatibleWithSocialFeatures=_isPlatformCompatibleWithSocialFeatures;
@synthesize delegate = _delegate;


-(id)initWithDelegate:(id<PlatformVersionProxyDelegate>)delegate {
    if ((self = [super init])) {
        _delegate = delegate;
    }
    return self;
}



#pragma mark - helper methods

//Helper to create the base URL
- (NSString *)createBaseURL {  
    NSString *domainName = [[ServerPreferencesManager sharedInstance] selectedDomain];
    return !domainName || [domainName length] == 0 ? nil : [NSString stringWithFormat:@"%@/%@/%@/",domainName, kPortalContainerName, kRestContextName]; 
}



#pragma mark - Call methods

- (void)retrievePlatformInformations {
    // Load the object model via RestKit
    RKObjectManager* manager = [RKObjectManager objectManagerWithBaseURL:[self createBaseURL]];  
    [RKObjectManager setSharedManager:manager];
        
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[PlatformServerVersion class]];
    [mapping mapKeyPathsToAttributes:
     @"platformVersion",@"platformVersion",
     @"platformRevision",@"platformRevision",
     @"platformBuildNumber",@"platformBuildNumber",
     @"isMobileCompliant",@"isMobileCompliant",
     @"platformEdition",@"platformEdition",
     nil];
    
    [manager loadObjectsAtResourcePath:@"platform/info" objectMapping:mapping delegate:self];          
}



#pragma mark - RKObjectLoaderDelegate methods

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    LogTrace(@"Loaded payload: %@", [response bodyAsString]);
}


- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObjects:(NSArray*)objects {
    //NSLog(@"Loaded statuses: %@", objects);    
    //We receive the response from the server
    //We now need to check if the version can run social features or not and set properties
    
    PlatformServerVersion *platformServerVersion = [[objects objectAtIndex:0] retain];

    NSRange aRange = [platformServerVersion.platformVersion rangeOfString:@"3.5"];
    if (aRange.location == NSNotFound) {
        //Version is not compatible with social features
        _isPlatformCompatibleWithSocialFeatures = NO;
    } else {
        //Version is compatible with social features
        _isPlatformCompatibleWithSocialFeatures = YES;
    }
    
    //We need to prevent the caller.
    if (_delegate && [_delegate respondsToSelector:@selector(platformVersionCompatibleWithSocialFeatures:withServerInformation:)]) {
        [_delegate platformVersionCompatibleWithSocialFeatures:_isPlatformCompatibleWithSocialFeatures withServerInformation:platformServerVersion];
    }

}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	// The url doesn't exist, the server is not compatible
    _isPlatformCompatibleWithSocialFeatures = NO;
    
    //We need to prevent the caller
    if (_delegate && [_delegate respondsToSelector:@selector(platformVersionCompatibleWithSocialFeatures:withServerInformation:)]) {
        [_delegate platformVersionCompatibleWithSocialFeatures:_isPlatformCompatibleWithSocialFeatures withServerInformation:nil];
    }

}



- (void) dealloc {
    _delegate = nil;
    [super dealloc];
}






@end
