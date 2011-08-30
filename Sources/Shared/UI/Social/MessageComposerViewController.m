//
//  MessageComposerViewController.m
//  eXo Platform
//
//  Created by Tran Hoai Son on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageComposerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SocialPostActivity.h"
#import "SocialPostCommentProxy.h"
#import "ActivityStreamBrowseViewController.h"
#import "FilesProxy.h"

@implementation MessageComposerViewController

@synthesize isPostMessage=_isPostMessage, strActivityID=_strActivityID, delegate, tblvActivityDetail=_tblvActivityDetail;
@synthesize _popoverPhotoLibraryController, _btnSend, _btnCancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_hudMessageComposer release];
    _hudMessageComposer = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add the loader
    _hudMessageComposer = [[ATMHud alloc] initWithDelegate:self];
    [_hudMessageComposer setAllowSuperviewInteraction:NO];
    
    //Set the position of the loader 
    [self setHudPosition];
    
	[self.view addSubview:_hudMessageComposer.view];
    
    UIImage *strechBg = [[UIImage imageNamed:@"SocialActivityDetailCommentBg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    [_imgvBackground setImage:strechBg];
    
    UIImage *strechTextViewBg = [[UIImage imageNamed:@"MessageComposerTextfieldBackground.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:50];
    [_imgvTextViewBg setImage:strechTextViewBg];
    
    UIImage *strechSendBg = [[UIImage imageNamed:@"MessageComposerButtonSendBackground.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:13];
    
    UIImage *strechSendBgSelected = [[UIImage imageNamed:@"MessageComposerButtonSendBackgroundSelected.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:13];
    
    [_btnSend setBackgroundImage:strechSendBg forState:UIControlStateNormal];
    [_btnSend setBackgroundImage:strechSendBgSelected forState:UIControlStateHighlighted];
    
    UIImage *strechCancelBg = [[UIImage imageNamed:@"MessageComposerButtonCancelBackground.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:13];
    
    UIImage *strechCancelBgSelected = [[UIImage imageNamed:@"MessageComposerButtonCancelBackgroundSelected.png"] stretchableImageWithLeftCapWidth:3 topCapHeight:13];
    
    [_btnCancel setBackgroundImage:strechCancelBg forState:UIControlStateNormal];
    [_btnCancel setBackgroundImage:strechCancelBgSelected forState:UIControlStateHighlighted];
    
    UIBarButtonItem* bbtnSend = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(onBtnSend:)];
    [bbtnSend setCustomView:_btnSend];
     self.navigationItem.rightBarButtonItem = bbtnSend;
    
    UIBarButtonItem* bbtnCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(onBtnCancel:)];
    [bbtnCancel setCustomView:_btnCancel];
    self.navigationItem.leftBarButtonItem = bbtnCancel;
    
    //[_txtvMessageComposer becomeFirstResponder];
    [_txtvMessageComposer setBackgroundColor:[UIColor clearColor]];
    [_txtvMessageComposer setText:@""];
    
    
    if (_isPostMessage) 
    {
        _strTitle = @"Post status";
        [_btnAttach setHidden:YES];
    }
    else
    {
        _strTitle = @"Post comment";
        [_btnAttach setHidden:NO];        
    }
    
    [self setTitle:_strTitle];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Loader Management
- (void)setHudPosition {
    //Default implementation
    //Nothing keep the default position of the HUD
}

- (void)showLoaderForSendingStatus {
    [_hudMessageComposer setCaption:@"Posting the new status"];
    [_hudMessageComposer setActivity:YES];
    [_hudMessageComposer show];
}

- (void)showLoaderForSendingComment {
    [_hudMessageComposer setCaption:@"Posting the new comment"];
    [_hudMessageComposer setActivity:YES];
    [_hudMessageComposer show];
}



- (void)hideLoader {
    //Now update the HUD
    //TODO Localize this string
    [_hudMessageComposer setCaption:@"Posted !"];
    [_hudMessageComposer setActivity:NO];
    [_hudMessageComposer setImage:[UIImage imageNamed:@"19-check"]];
    [_hudMessageComposer update];
    [_hudMessageComposer hideAfter:0.5];
}



- (IBAction)onBtnSend:(id)sender
{
    
    if([self.navigationItem.title isEqualToString:@"Attached photo"])
    {
        [self deleteAttachedPhoto];
        [self.navigationItem setTitle:_strTitle];
        
        return;
    }
    
    if([_txtvMessageComposer.text length] > 0)
    {
        UIImageView *imgView = (UIImageView *)[self.view viewWithTag:1];
        if(imgView)
        {
            FilesProxy *fileProxy = [FilesProxy sharedInstance];
            
            BOOL storageFolder = [fileProxy createNewFolderWithURL:[NSString stringWithFormat:@"%@/Public", fileProxy._strUserRepository] folderName:@"Mobile"];
            
            if(storageFolder)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MM-yyy-HH-mm-ss"];
                NSString* fileName = [dateFormatter stringFromDate:[NSDate date]];
                
                //release the date formatter because, not needed after that piece of code
                [dateFormatter release];
                fileName = [fileName stringByAppendingFormat:@".png"];
                
                NSString *directory = [NSString stringWithFormat:@"%@/Public/Mobile/%@", fileProxy._strUserRepository, fileName];
                
                NSData *imageData = UIImagePNGRepresentation(imgView.image);
                
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                            [fileProxy methodSignatureForSelector:@selector(sendImageInBackgroundForDirectory:data:)]];
                [invocation setTarget:fileProxy];
                [invocation setSelector:@selector(sendImageInBackgroundForDirectory:data:)];
                [invocation setArgument:&directory atIndex:2];
                [invocation setArgument:&imageData atIndex:3];
                [NSTimer scheduledTimerWithTimeInterval:0.1f invocation:invocation repeats:NO];
                
//                [fileProxy fileAction:kFileProtocolForUpload source:directory destination:nil data:imageData];
            }
        }
        
        
        if(_isPostMessage)
        {
            [self showLoaderForSendingStatus];
            
            SocialPostActivity* actPost = [[SocialPostActivity alloc] init];
            actPost.delegate = self;
            [actPost postActivity:_txtvMessageComposer.text];
        }
        else
        {
            [self showLoaderForSendingComment];
            
            SocialPostCommentProxy *actComment = [[SocialPostCommentProxy alloc] init];
            [actComment postComment:_txtvMessageComposer.text forActivity:_strActivityID];
            actComment.delegate = self;
        }

    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Composer" message:@"There is no message for comment" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        if(_isPostMessage)
            alert.message = @"There is no message for posting";
        
        [alert release];
    }
    
}

- (IBAction)onBtnCancel:(id)sender
{
    
    if([self.navigationItem.title isEqualToString:@"Attached photo"])
    {
        [self cancelDisplayAttachedPhoto];
        [self.navigationItem setTitle:_strTitle];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];    
    }
    
}

//- (void)showPhotoAttachment
- (IBAction)onBtnAttachment:(id)sender
{
    [self showActionSheetForPhotoAttachment];
}

- (void)showActionSheetForPhotoAttachment
{
    
}

- (void)showPhotoLibrary
{
    
}

- (void)addPhotoToView:(UIImage *)image
{
    
}

#pragma -
#pragma mark Proxies Delegate Methods

- (void)proxyDidFinishLoading:(SocialProxy *)proxy {

    [self hideLoader];
    
    if (delegate && ([delegate respondsToSelector:@selector(messageComposerDidSendData)])) {
        [delegate messageComposerDidSendData];
        [self dismissModalViewControllerAnimated:YES];    
    }
    
}

-(void)proxy:(SocialProxy *)proxy didFailWithError:(NSError *)error
{
    
}



#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex < 2)
    {
        UIImagePickerController *thePicker = [[UIImagePickerController alloc] init];
        thePicker.delegate = self;
        
        if(buttonIndex == 0)//Take a photo
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) 
            {  
                thePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                thePicker.allowsEditing = YES;
                [self presentModalViewController:thePicker animated:YES];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Take a picture" message:@"Camera is not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
            }
        }
        else
        {
            /*
            thePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            thePicker.allowsEditing = YES;
            [self presentModalViewController:thePicker animated:YES];
             */
            [self showPhotoLibrary];
        }
        [thePicker release];
    }
    
}

#pragma mark - ActionSheet Delegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    [self addPhotoToView:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    
//    if (_popoverPhotoLibraryController) 
//    {
//        [_popoverPhotoLibraryController dismissPopoverAnimated:YES];
//    }
    
}


#pragma mark - TextView Delegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}


@end
