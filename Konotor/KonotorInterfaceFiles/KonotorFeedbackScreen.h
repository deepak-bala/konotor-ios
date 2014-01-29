//
//  KonotorFeedbackScreen.h
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 09/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "KonotorFeedbackScreenViewController.h"
#import "KonotorEventHandler.h"

#ifndef KONOTORFEEDBACKSCREEN_H
#define KONOTORFEEDBACKSCREEN_H

#define KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER NO

@class KonotorFeedbackScreenViewController;

@interface KonotorFeedbackScreen : NSObject

@property (strong, nonatomic)KonotorFeedbackScreenViewController* conversationViewController;
@property (strong, nonatomic) UIWindow* window;

+ (BOOL) showFeedbackScreen;
+ (void) dismissScreen;
+ (KonotorFeedbackScreen*) sharedInstance;
+ (void) refreshMessages;
+ (BOOL) isShowingFeedbackScreen;

@end


#endif

