//
//  KonotorEventHandler.m
//  KonotorDemo
//
//  Created by Srikrishnan Ganesan on 20/08/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorEventHandler.h"

static KonotorEventHandler* eventHandler=nil;

@implementation KonotorEventHandler
@synthesize badgeLabel;

-(void) didEncounterErrorWhileDownloadingConversations
{
//    [KonotorUtility showToastWithString:@"Updating conversations failed." forMessageID:nil];
    [KonotorUtility updateBadgeLabel:badgeLabel];
}

-(BOOL) handleRemoteNotification:(NSDictionary*)userInfo
{
    if(!([(NSString*)[userInfo valueForKey:@"source"] isEqualToString:@"konotor"]))
        return NO;
    
    [Konotor DownloadAllMessages];
    
    [KonotorUtility showToastWithString:@"New message received" forMessageID:@"all"];

    return YES;
}

-(BOOL) handleRemoteNotification:(NSDictionary*)userInfo withShowScreen:(BOOL)showScreen
{
    if(!([(NSString*)[userInfo valueForKey:@"source"] isEqualToString:@"konotor"]))
        return NO;
    [Konotor DownloadAllMessages];
    
    NSString* marketingId=((NSString*)[userInfo objectForKey:@"kon_message_marketingid"]);
    if(marketingId&&([marketingId longLongValue]!=0))
        [Konotor MarkMarketingMessageAsClicked:[NSNumber numberWithLongLong:[marketingId longLongValue]]];
    
    if(showScreen){
        [KonotorFeedbackScreen showFeedbackScreen];
    }
    else
        [KonotorUtility showToastWithString:@"New message received" forMessageID:@"all"];
    
    return YES;
}

- (void) didFinishDownloadingMessages
{
    [KonotorUtility updateBadgeLabel:badgeLabel];
}


+ (KonotorEventHandler*) sharedInstance
{
    if(eventHandler==nil)
        eventHandler=[[KonotorEventHandler alloc] init];
    return eventHandler;
}

@end
