//
//  DocumentsViewController.h
//  eXo Platform
//
//  Created by Stévan Le Meur on 29/08/11.
//  Copyright 2011 eXo Platform. All rights reserved.
//

#import "FilesProxy.h"
#import "ATMHud.h"
#import "ATMHudDelegate.h"
#import "FileActionsViewController.h"
#import "FileFolderActionsViewController.h"



@interface DocumentsViewController : UITableViewController <FileActionsProtocol, FileFolderActionsProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, ATMHudDelegate> {
    
    File *_rootFile;
    
    NSArray *_arrayContentOfRootFile;
    
    FilesProxy *_filesProxy;
    
    ATMHud *_hudFolder;//Heads up display
        
    NSString *_stringForUploadPhoto;
    
    FileFolderActionsViewController *_fileFolderActionsController;
    
}


//Use this method to init the Controller with a root file
- (id) initWithRootFile:(File *)rootFile; 


@end