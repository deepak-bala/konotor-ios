//
//  KonotorTextInputOverlay.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 11/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorTextInputOverlay.h"
#import "KonotorFeedbackScreen.h"

static KonotorTextInputOverlay* konotorTextInputBox=nil;
static BOOL promptForPush=YES;

@implementation KonotorTextInputOverlay

@synthesize window,textInputBox,transparentView,originalTextInputRect,sourceViewController;

+(KonotorTextInputOverlay*) sharedInstance
{
    if(konotorTextInputBox==nil)
        konotorTextInputBox=[[KonotorTextInputOverlay alloc] init];
    return konotorTextInputBox;
}

+(BOOL) showInputForViewController:(UIViewController *)viewController
{
    BOOL showingInput=[KonotorTextInputOverlay showInputForView:viewController.view];
    if(konotorTextInputBox!=nil)
        konotorTextInputBox.sourceViewController=viewController;
    return showingInput;
}

+(BOOL) showInputForView:(UIView *)view
{
    if(konotorTextInputBox!=nil)
        return NO;
    konotorTextInputBox=[KonotorTextInputOverlay sharedInstance];
    konotorTextInputBox.window=view;
    [konotorTextInputBox showInputView];
    return YES;
}

- (void) showInputView
{
    
    textInputBox=[[UIView alloc] initWithFrame:CGRectMake(0, window.frame.size.height-15-20-44,  window.frame.size.width, 44)];
    [textInputBox setBackgroundColor:[UIColor whiteColor]];
    textInputBox.layer.borderColor=[[UIColor lightGrayColor] CGColor];
    textInputBox.layer.borderWidth=1.0;
    
   // transparentView=[[UIView alloc] initWithFrame:CGRectMake(0,0, window.frame.size.width, window.frame.size.height-15-20-44)];
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
    {
        transparentView=[[UIView alloc] initWithFrame:CGRectMake(0,0, window.frame.size.height, window.frame.size.width)];
    }
    else{
        transparentView=[[UIView alloc] initWithFrame:CGRectMake(0,0, window.frame.size.width, window.frame.size.height)];
    }
    [transparentView setBackgroundColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.3]];
    UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:[self class] action:@selector(dismissInput)];
    [transparentView addGestureRecognizer:tapGesture];
    
    if(![[KonotorUIParameters sharedInstance] disableTransparentOverlay])
    [window addSubview:transparentView];

    
    KonotorUITextView* input;
#if    (KONOTOR_BUTTONFORSEND==1)
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
        input=[[KonotorUITextView alloc] initWithFrame:CGRectMake(5+35, 5, window.frame.size.height-30-10-50-35+10+29, 44-5-5)];
    else
        input=[[KonotorUITextView alloc] initWithFrame:CGRectMake(5+35, 5, window.frame.size.width-30-10-50-35+10+29, 44-5-5)];

#else
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
        input=[[KonotorUITextView alloc] initWithFrame:CGRectMake(5+35, 5, window.frame.size.height-30-10-50-35+10, 44-5-5)];
    else
        input=[[KonotorUITextView alloc] initWithFrame:CGRectMake(5+35, 5, window.frame.size.width-30-10-50-35+10, 44-5-5)];
#endif

    [input setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    input.tag=KONOTOR_TEXTINPUT_TEXTVIEW_TAG;
    [input setReturnKeyType:UIReturnKeyDefault];
    
    input.delegate=self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftInput:) name:UIKeyboardWillShowNotification object:nil];
    
    [textInputBox addSubview:input];
    [window addSubview:textInputBox];
    
    
    UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(5, 7, 30, 30)];

    [cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    if([[KonotorUIParameters sharedInstance] autoShowTextInput]&&[[KonotorUIParameters sharedInstance] imageInputEnabled]){
        [cancelButton setImage:[UIImage imageNamed:@"konotor_cam"] forState:UIControlStateNormal];
        [cancelButton setFrame:CGRectMake(4, 2, 40, 40)];
        [input setFrame:CGRectMake(input.frame.origin.x+5, input.frame.origin.y, input.frame.size.width-5, input.frame.size.height)];

      //  [cancelButton addTarget:[self class] action:@selector(dismissInput) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton addTarget:self.sourceViewController action:@selector(showImageInput) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        [cancelButton setTitle:@"X" forState:UIControlStateNormal];
        [cancelButton addTarget:[self class] action:@selector(dismissInput) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [textInputBox addSubview:cancelButton];

    
    UIButton *sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
#if (KONOTOR_BUTTONFORSEND==1)
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
        [sendButton setFrame:CGRectMake(5+35+window.frame.size.height-30-10-50-35+5+10+29, 4, 36, 36)];
    else
        [sendButton setFrame:CGRectMake(5+35+window.frame.size.width-30-10-50-35+5+10+29, 4, 36, 36)];
    
    
    [sendButton setImage:[UIImage imageNamed:@"konotor_send.png"] forState:UIControlStateNormal];
#else
    
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
        [sendButton setFrame:CGRectMake(5+35+window.frame.size.height-30-10-50-35+5+10, 5, 65, 34)];
    else
        [sendButton setFrame:CGRectMake(5+35+window.frame.size.width-30-10-50-35+5+10, 5, 65, 34)];

    
    [sendButton setTitleColor:KONOTOR_UIBUTTON_COLOR forState:UIControlStateNormal];
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];
#endif
    
    [sendButton setTag:KONOTOR_TEXTINPUT_SENDBUTTON_TAG];

    [sendButton addTarget:self action:@selector(sendText) forControlEvents:UIControlEventTouchUpInside];
    [textInputBox addSubview:sendButton];
    
   [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
  
    [input performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.0];

    
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification
{
    CGRect keyboardEndFrame;
    [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    CGRect keyboardFrame = [window convertRect:keyboardEndFrame fromView:nil];
    
    if (CGRectIntersectsRect(keyboardFrame, window.frame)) {
        
        // Keyboard is visible
        float y=([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])?(window.frame.size.width-keyboardEndFrame.size.width):(window.frame.size.height-keyboardEndFrame.size.height);
        y=([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])?keyboardFrame.origin.y:keyboardFrame.origin.y;
        float width=([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])?keyboardEndFrame.size.height:keyboardEndFrame.size.width;
        
        [textInputBox setFrame:CGRectMake(0, y-textInputBox.frame.size.height, width, textInputBox.frame.size.height)];
        [transparentView setFrame:CGRectMake(0, 0, width, window.frame.size.height)];
        
      
        
    } else {
        // Keyboard is hidden
  //      [KonotorTextInputOverlay performSelector:@selector(dismissInput) withObject:nil afterDelay:0.0];

    }
}

- (void) shiftInput:(NSNotification*)note{
    CGRect newFrame;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&newFrame];
    
    float y=([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])?(window.frame.size.width-newFrame.size.width):(window.frame.size.height-newFrame.size.height);
    float width=([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])?newFrame.size.height:newFrame.size.width;
    
    KonotorUITextView* input=(KonotorUITextView*)[self.textInputBox viewWithTag:KONOTOR_TEXTINPUT_TEXTVIEW_TAG];
    
    UIButton* sendButton = (UIButton*)[self.textInputBox viewWithTag:KONOTOR_TEXTINPUT_SENDBUTTON_TAG];
    
#if (KONOTOR_BUTTONFORSEND==1)
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
        [sendButton setFrame:CGRectMake(5+35+self.window.frame.size.height-30-10-50-35+5+10+29, 5, 36, 36)];
    else
        [sendButton setFrame:CGRectMake(5+35+self.window.frame.size.width-30-10-50-35+5+10+29, 5, 36, 36)];
    
    float txtWidth;
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController.messagesView)])
        txtWidth=self.window.frame.size.height-30-10-50-35+10+29;
    else
        txtWidth=self.window.frame.size.width-30-10-50-35+10+29;
#else
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
        [sendButton setFrame:CGRectMake(5+35+self.window.frame.size.height-30-10-50-35+5+10, 5, 65, 34)];
    else
        [sendButton setFrame:CGRectMake(5+35+self.window.frame.size.width-30-10-50-35+5+10, 5, 65, 34)];
    
    float txtWidth;
     if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController.messagesView)])
        txtWidth=self.window.frame.size.height-30-10-50-35+10;
    else
        txtWidth=self.window.frame.size.width-30-10-50-35+10;
#endif
    
    CGSize txtSize;
    
    float cameraAdjustment=0.0;
    if([[KonotorUIParameters sharedInstance] autoShowTextInput]&&[[KonotorUIParameters sharedInstance] imageInputEnabled])
        cameraAdjustment=5;
    
    txtSize = [input sizeThatFits:CGSizeMake(txtWidth-cameraAdjustment, 140)];
    
    if(txtSize.height>100)
        txtSize.height=100;
    
    [textInputBox setFrame:CGRectMake(0, y-txtSize.height-10, width, txtSize.height+10)];
    
    input.frame=CGRectMake(5+35+cameraAdjustment,5,txtWidth-cameraAdjustment,txtSize.height);

    [transparentView setFrame:CGRectMake(0, 0, width, textInputBox.frame.origin.y)];
    
}

- (BOOL) shouldAutorotate{
    return YES;
}

- (void) sendText
{
    NSString* toSend=[((KonotorUITextView*)[textInputBox viewWithTag:KONOTOR_TEXTINPUT_TEXTVIEW_TAG]).text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([toSend isEqualToString:@""]){
        UIAlertView* alertNilString=[[UIAlertView alloc] initWithTitle:@"Empty Message" message:@"You cannot send an empty message. Please type a message to send." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertNilString show];
    }
    else{
        [Konotor uploadTextFeedback:toSend];
        
        BOOL notificationEnabled=NO;
        
#if(__IPHONE_OS_VERSION_MAX_ALLOWED >=80000)
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
            notificationEnabled=[[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
        }
        else
#endif
        {
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0)
            UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
            if(types != UIRemoteNotificationTypeNone) notificationEnabled=YES;
#endif
        }

        
 /*       if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
#if(__IPHONE_OS_VERSION_MAX_ALLOWED >=80000)
            notificationEnabled=[[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
#endif
        }
        else{
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0)
            UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
            if(types != UIRemoteNotificationTypeNone) notificationEnabled=YES;
#endif
        }*/

        
        if (!notificationEnabled) {
            if(promptForPush){
                UIAlertView* pushDisabledAlert=[[UIAlertView alloc] initWithTitle:@"Modify Push Setting" message:@"To be notified of responses even when out of this chat, enable push notifications for this app via the Settings->Notification Center" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [pushDisabledAlert show];
                promptForPush=NO;
            }
        }
      /*  if(![Konotor isPushEnabled]){
            if(promptForPush){
                UIAlertView* pushDisabledAlert=[[UIAlertView alloc] initWithTitle:@"Modify Push Setting" message:@"To get real-time response to your message, please enable push notifications for this app via the Settings->Notification Center" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [pushDisabledAlert show];
                promptForPush=NO;
            }
        }*/
    }
    [KonotorTextInputOverlay performSelector:@selector(dismissInput) withObject:nil afterDelay:0.0];
}

+ (void) dismissInput
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:konotorTextInputBox];
    [konotorTextInputBox.transparentView removeFromSuperview];
    [konotorTextInputBox.textInputBox removeFromSuperview];
    konotorTextInputBox.textInputBox=nil;
    konotorTextInputBox.transparentView=nil;
    ((KonotorFeedbackScreenViewController*)konotorTextInputBox.sourceViewController).footerView.hidden=NO;
    konotorTextInputBox=nil;
    [KonotorFeedbackScreen refreshMessages];
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    [KonotorTextInputOverlay performSelector:@selector(dismissInput) withObject:nil afterDelay:0.0];
}

- (void) textViewDidChange:(UITextView *)textView
{
    KonotorUITextView* textBox=(KonotorUITextView*)textView;
    NSString *txt=textBox.text;
    if((txt==nil)||([txt isEqualToString:@""]))
        txt=@"1";
    CGSize txtSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, 140)];
    if(txtSize.height>100)
        txtSize.height=100;
    
    textInputBox.frame=CGRectMake(textInputBox.frame.origin.x, textInputBox.frame.origin.y-(txtSize.height-textBox.frame.size.height), textInputBox.frame.size.width, textInputBox.frame.size.height+(txtSize.height-textBox.frame.size.height));
    
    textBox.frame=CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,txtSize.height);
    
    
    txt=nil;
    
}



@end
