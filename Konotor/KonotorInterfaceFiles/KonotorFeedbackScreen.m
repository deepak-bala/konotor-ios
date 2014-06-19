//
//  KonotorFeedbackScreen.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 09/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorFeedbackScreen.h"

static KonotorFeedbackScreen* konotorFeedbackScreen=nil;

@implementation KonotorFeedbackScreen

@synthesize conversationViewController,window;

+ (KonotorFeedbackScreen*) sharedInstance
{
    if(konotorFeedbackScreen==nil){
        konotorFeedbackScreen=[[KonotorFeedbackScreen alloc] init];
    }
    return konotorFeedbackScreen;
}

+(BOOL) isShowingFeedbackScreen
{
    return ((konotorFeedbackScreen==nil)?NO:YES);
}

+ (BOOL) showFeedbackScreenWithViewController:(UIViewController*) viewController
{
    KonotorFeedbackScreen* fbScreen=[KonotorFeedbackScreen sharedInstance];
    if(fbScreen.conversationViewController!=nil)
        return NO;
    else{
        konotorFeedbackScreen.conversationViewController=[[KonotorFeedbackScreenViewController alloc] initWithNibName:@"KonotorFeedbackScreenViewController" bundle:nil];
        
        [konotorFeedbackScreen.conversationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [konotorFeedbackScreen.conversationViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        
        [viewController presentViewController:konotorFeedbackScreen.conversationViewController animated:YES completion:^{
            if([[KonotorUIParameters sharedInstance] autoShowTextInput])
                [konotorFeedbackScreen.conversationViewController performSelector:@selector(showTextInput) withObject:nil afterDelay:0.0];
        }];
    }
    return YES;
}

+ (BOOL) showFeedbackScreen
{
    KonotorFeedbackScreen* fbScreen=[KonotorFeedbackScreen sharedInstance];
    if(fbScreen.conversationViewController!=nil)
        return NO;
    else{
        konotorFeedbackScreen.conversationViewController=[[KonotorFeedbackScreenViewController alloc] initWithNibName:@"KonotorFeedbackScreenViewController" bundle:nil];
        if(KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
            if([[[[[UIApplication sharedApplication] delegate] window] rootViewController] isMemberOfClass:[UINavigationController class]]){
                [(UINavigationController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController] pushViewController:konotorFeedbackScreen.conversationViewController animated:YES];
                
                konotorFeedbackScreen.conversationViewController=nil;
                return YES;
            }
        }
        [konotorFeedbackScreen.conversationViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [konotorFeedbackScreen.conversationViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        
        if(UIInterfaceOrientationIsLandscape(konotorFeedbackScreen.conversationViewController.interfaceOrientation)){
        konotorFeedbackScreen.window=[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        }
        else{
            konotorFeedbackScreen.window=[[UIWindow alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds];
        }

        [konotorFeedbackScreen.window setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7]];
        [konotorFeedbackScreen.window setRootViewController:konotorFeedbackScreen.conversationViewController];
        
        UIViewController *rootViewController=[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if([rootViewController isKindOfClass:[UINavigationController class]])
            rootViewController=[((UINavigationController*)rootViewController) topViewController];
        UIViewController *presentedViewController=[rootViewController presentedViewController];
        while(presentedViewController!=nil){
            rootViewController=presentedViewController;
            presentedViewController=[rootViewController presentedViewController];
        }
        
        [rootViewController presentViewController:konotorFeedbackScreen.conversationViewController animated:YES completion:^{
         //   konotorFeedbackScreen.conversationViewController.view.layer.shouldRasterize = NO;
         //   [KonotorFeedbackScreen refreshMessages];
            if([[KonotorUIParameters sharedInstance] autoShowTextInput])
                [konotorFeedbackScreen.conversationViewController performSelector:@selector(showTextInput) withObject:nil afterDelay:0.0];
        }];
    }
    return YES;
}

+ (void) refreshMessages
{
    [konotorFeedbackScreen.conversationViewController refreshView];
}

+ (void) dismissScreen
{
    [konotorFeedbackScreen.conversationViewController dismissViewControllerAnimated:YES completion:^{
        konotorFeedbackScreen.conversationViewController=nil;
        konotorFeedbackScreen.window=nil;
        konotorFeedbackScreen=nil;
        [Konotor setDelegate:[KonotorEventHandler sharedInstance]];
        [Konotor StopPlayback];

    }];
 
}


@end
