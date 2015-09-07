//
//  KonotorConversationViewController.h
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 08/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Konotor.h"
#import "KonotorUI.h"
#import "KonotorImageView.h"
#import <MessageUI/MessageUI.h>


#define KONOTOR_VOICE_INPUT_SUPPORT 1
#define KONOTOR_IMAGE_INPUT_SUPPORT 1
#define KONOTOR_MESSAGE_SHARE_SUPPORT 0
#define KONOTOR_ENABLECAPTIONS 1


/* DO NOT ALTER - THESE ARE FOR REFERENCE OF DEFAULT VALUES FOR CALLOUT PROVIDED */
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET_DEFAULTCALLOUT 25
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET_DEFAULTCALLOUT 25
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET_DEFAULTCALLOUT 28
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET_DEFAULTCALLOUT 28
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING_DEFAULT 20
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_DEFAULT 0
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_PADDING_DEFAULT 20

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET_IMESSAGECALLOUT 16
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET_IMESSAGECALLOUT 14
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET_IMESSAGECALLOUT 28
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET_IMESSAGECALLOUT 36
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_IMESSAGE 10
/* END OF DEFAULT SECTION */

#define KONOTOR_MESSAGETEXT_FONT_DEFAULT ([UIFont systemFontOfSize:16.0 weight:UIFontWeightLight])
#define KONOTOR_BUTTON_DEFAULTACTIONLABEL @"View"
#define KONOTOR_BUTTON_HORIZONTAL_PADDING 16
#define KONOTOR_BUTTON_FONT ([UIFont systemFontOfSize:16.0])

#define KONOTOR_IMAGE_SUPPORT 1

#define TRANSPARENT_COLOR ([UIColor clearColor])
#define WHITE_COLOR ([UIColor whiteColor])
#define KONOTOR_LIGHTGRAY_COLOR ([UIColor colorWithRed:0.9 green:0.9 blue:0.91 alpha:1.0])
#define KONOTOR_CREAM_COLOR ([UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0])

#define KONOTOR_REFRESHINDICATOR_TAG 80
#define KONOTOR_MESSAGETEXTVIEW_TAG 81
#define KONOTOR_CALLOUT_TAG 82
#define KONOTOR_PLAYBUTTON_TAG 83
#define KONOTOR_PROFILEIMAGE_TAG 84
#define KONOTOR_USERNAMEFIELD_TAG 85
#define KONOTOR_TIMEFIELD_TAG 86
#define KONOTOR_UPLOADSTATUS_TAG 87
#define KONOTOR_DURATION_TAG 88
#define KONOTOR_PICTURE_TAG 89
#define KONOTOR_SHAREBUTTON_TAG 90
#define KONOTOR_SHARE_ALERT_TAG 91
#define KONOTOR_ACTIONBUTTON_TAG 92


#define KONOTOR_AUDIOMESSAGE_HEIGHT 42
#define KONOTOR_PROFILEIMAGE_DIMENSION 40
#define KONOTOR_PLAYBUTTON_DIMENSION 40
#define KONOTOR_HORIZONTAL_PADDING 5
#define KONOTOR_VERTICAL_PADDING 2
#define KONOTOR_ENDOFMESSAGE_HORIZONTAL_PADDING 10
#define KONOTOR_USERNAMEFIELD_HEIGHT 18
#define KONOTOR_TIMEFIELD_HEIGHT 16
#define KONOTOR_ACTIONBUTTON_HEIGHT 44

#define KONOTOR_SHOW_TIMESTAMP YES
#define KONOTOR_SHOW_SENDERNAME_DEPRECATED NO
#define KONOTOR_SHOW_DURATION NO
#define KONOTOR_SHOW_UPLOADSTATUS (KONOTOR_SHOW_TIMESTAMP||KONOTOR_SHOW_SENDERNAME)
#define KONOTOR_TEXTMESSAGE_MAXWIDTH 260.0

#define KONOTOR_USERMESSAGE_TEXT_COLOR ([UIColor whiteColor])
#define KONOTOR_OTHERMESSAGE_TEXT_COLOR ([UIColor blackColor])
#define KONOTOR_USERTIMESTAMP_COLOR KONOTOR_LIGHTGRAY_COLOR
#define KONOTOR_OTHERTIMESTAMP_COLOR ([UIColor darkGrayColor])
#define KONOTOR_USERNAME_TEXT_COLOR ([UIColor whiteColor])
#define KONOTOR_OTHERNAME_TEXT_COLOR ([UIColor darkGrayColor])

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_SHOWPROFILEIMAGE_DEPRECATED NO
#define KONOTOR_USESCALLOUTIMAGE YES
#else
#define KONOTOR_SHOWPROFILEIMAGE_DEPRECATED YES
#define KONOTOR_USESCALLOUTIMAGE NO
#endif

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_MESSAGE_BACKGROUND_COLOR TRANSPARENT_COLOR
#define KONOTOR_MESSAGELAYOUT_BACKGROUND_COLOR WHITE_COLOR
#define KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR TRANSPARENT_COLOR
#else
#define KONOTOR_MESSAGE_BACKGROUND_COLOR KONOTOR_LIGHTGRAY_COLOR
#define KONOTOR_MESSAGELAYOUT_BACKGROUND_COLOR WHITE_COLOR
#define KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR KONOTOR_CREAM_COLOR
#endif

#define KONOTOR_IMAGE_MAXHEIGHT 240
#define KONOTOR_IMAGE_MAXWIDTH KONOTOR_TEXTMESSAGE_MAXWIDTH-20
#define KONOTOR_MESSAGESPERPAGE 25


#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_SMART_TIMESTAMP 1
#else
#define KONOTOR_SMART_TIMESTAMP 1
#endif

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET_IMESSAGECALLOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET_IMESSAGECALLOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET_IMESSAGECALLOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET_IMESSAGECALLOUT

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING_DEFAULT

#if KONOTOR_IMESSAGE_LAYOUT
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_IMESSAGE
#else
#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING_DEFAULT
#endif

#define KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_PADDING 12
#define KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME NO
#define KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER NO
#define KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_ME NO
#define KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_OTHER NO


@interface KonotorConversationViewController : UITableViewController <KonotorDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

- (void) refreshView;
- (void) dismissImageView;
@property (strong,nonatomic) KonotorImageView* fullImageView;

@end

@interface TapOnPictureRecognizer : UITapGestureRecognizer
@property (strong, nonatomic) UIImage* image;
@property (strong, nonatomic) NSURL* imageURL;
@property (nonatomic) float height,width;

@end

@interface  KonotorShareButton: UIButton

@property (strong, nonatomic) NSString* messageId;

@end

@interface  KonotorActionButton: UIButton

@property (strong, nonatomic) NSString* actionUrl;

@end
