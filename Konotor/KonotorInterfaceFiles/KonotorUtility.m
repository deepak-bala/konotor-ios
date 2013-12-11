//
//  KonotorUtility.m
//  KonotorDemo
//
//  Created by Srikrishnan Ganesan on 20/08/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorUtility.h"

static UILabel* toastView=nil;
static UITapGestureRecognizer* tapRecognizer=nil;
static NSTimer* timer=nil;

@implementation KonotorUtility

+ (void) showToastWithString:(NSString*) message forMessageID:(NSString*)messageID
{
    CGRect windowFrame=[[UIScreen mainScreen] bounds];
    float toastX=[UIScreen mainScreen].bounds.size.width/2-140;
    float toastY=40;
    float toastWidth=280;
    float toastHeight=40;
    [KonotorUtility dismissToast];
    toastView=[[UILabel alloc] initWithFrame:CGRectMake(toastX, toastY, toastWidth, toastHeight)];
    [toastView setUserInteractionEnabled:YES];
    [toastView setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    [toastView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    [toastView setTextAlignment:NSTextAlignmentCenter];
    [toastView setTextColor:[UIColor whiteColor]];
    [toastView setText:message];
    [toastView setClipsToBounds:NO];
    toastView.layer.shadowColor=[[UIColor blackColor] CGColor];
    toastView.layer.shadowRadius=2.0;
    toastView.layer.shadowOpacity=1.0;
    toastView.layer.shadowOffset=CGSizeMake(2.0, 2.0);
    
    CGPoint centerpoint;
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
        centerpoint=CGPointMake(windowFrame.size.width-40, windowFrame.size.height/2);
        toastView.transform=CGAffineTransformMakeRotation(M_PI/2);
        break;
        case UIDeviceOrientationLandscapeRight:
        centerpoint=CGPointMake(40, windowFrame.size.height/2);
        toastView.transform=CGAffineTransformMakeRotation(-M_PI/2);
        break;
        case UIDeviceOrientationPortraitUpsideDown:
        centerpoint=CGPointMake(windowFrame.size.width/2,windowFrame.size.height-40);
        toastView.transform=CGAffineTransformMakeRotation(M_PI);
        break;
        
        default:
        centerpoint=toastView.center;
        break;
    }
    
    toastView.center=centerpoint;
    toastView.frame=CGRectIntegral(toastView.frame);
    
    if(messageID==nil)
        tapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:[KonotorUtility class] action:@selector(dismissToast:)];
    else
        tapRecognizer=[[UITapGestureRecognizer alloc] initWithTarget:[KonotorUtility class] action:@selector(showFeedback:)];
    [toastView addGestureRecognizer:tapRecognizer];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:toastView];
    
    timer=[NSTimer scheduledTimerWithTimeInterval:4.0 target:[KonotorUtility class] selector:@selector(dismissToast:) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:4.0]];
}

+(void) dismissToast
{
    [toastView removeFromSuperview];
    toastView=nil;
    tapRecognizer=nil;
    [timer invalidate];
    timer=nil;
}
+(void) dismissToast: (UIGestureRecognizer*) gestureRecognizer
{
    [KonotorUtility dismissToast];
}

+(void) showFeedback: (UIGestureRecognizer*) gestureRecognizer
{
    [KonotorUtility dismissToast];
    [KonotorFeedbackScreen showFeedbackScreen];
}

+(void) updateBadgeLabel:(UILabel*) badgeLabel
{
    if(badgeLabel){
        int count=[Konotor getUnreadMessagesCount];
        if(count>0)
        {
            [badgeLabel setText:[NSString stringWithFormat:@"%d",count]];
            [badgeLabel setHidden:NO];
        }
        else
        [badgeLabel setHidden:YES];
    }
}

@end
