//
//  eXoFilesView.m
//  eXoApp
//
//  Created by Tran Hoai Son on 7/3/09.
//  Copyright 2009 home. All rights reserved.
//

#import "MessengerViewController_iPhone.h"



@implementation MessengerViewController_iPhone

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    chatWindow = [[ChatWindowViewController_iPhone alloc] initWithNibName:@"ChatWindowViewController_iPhone" bundle:nil];
    chatWindow.delegate = self;
    chatWindow.user = [_arrUsers objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:chatWindow animated:YES];
    
}

- (void)receivedChatMessage:(XMPPMessage *)xmppMsg
{
    if([chatWindow respondsToSelector:@selector(receivedChatMessage:)])
    {
        [chatWindow receivedChatMessage:xmppMsg];
    }
}

//Dealloc method.
- (void) dealloc
{
    [super dealloc];
    [chatWindow release];
}

@end