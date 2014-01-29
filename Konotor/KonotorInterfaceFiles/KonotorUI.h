//
//  KonotorUI.h
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 04/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorFeedbackScreen.h"
#import "KonotorUITextView.h"
#import "KonotorTextInputOverlay.h"
#import "KonotorVoiceInputOverlay.h"
#import "KonotorConversationViewController.h"
#import "KonotorMediaUIButton.h"
#import <Availability.h>


#ifndef KonotorSampleApp_KonotorUI_h
#define KonotorSampleApp_KonotorUI_h

#define KONOTOR_UIBUTTON_COLOR_DEFAULT ([UIColor colorWithRed:0.39216 green:0.78824 blue:1.0 alpha:1.0])

#define KONOTOR_UIBUTTON_COLOR KONOTOR_UIBUTTON_COLOR_DEFAULT
//([UIColor blackColor])

#define KONOTOR_IMESSAGE_LAYOUT 1

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_IOS7_BUTTONSTYLE 1
#else
#define KONOTOR_IOS7_BUTTONSTYLE 0
#endif


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#endif
