//
//  KonotorTextInputOverlay.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 11/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorTextInputOverlay.h"

static KonotorTextInputOverlay* konotorTextInputBox=nil;

@implementation KonotorTextInputOverlay

@synthesize window,textInputBox,transparentView,originalTextInputRect;

+(KonotorTextInputOverlay*) sharedInstance
{
    if(konotorTextInputBox==nil)
        konotorTextInputBox=[[KonotorTextInputOverlay alloc] init];
    return konotorTextInputBox;
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
    
   // transparentView=[[UIView alloc] initWithFrame:CGRectMake(0,0, window.frame.size.width, window.frame.size.height-15-20-44)];
    if(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))
    {
        transparentView=[[UIView alloc] initWithFrame:CGRectMake(0,0, window.frame.size.height, window.frame.size.width)];
    }
    else{
        transparentView=[[UIView alloc] initWithFrame:CGRectMake(0,0, window.frame.size.width, window.frame.size.height)];
    }
    [transparentView setBackgroundColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:0.3]];
    UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:[self class] action:@selector(dismissInput)];
    [transparentView addGestureRecognizer:tapGesture];
    
    [window addSubview:transparentView];

    
    KonotorUITextView* input=[[KonotorUITextView alloc] initWithFrame:CGRectMake(5+35, 5, window.frame.size.width-30-10-50-35+10, 44-5-5)];
    [input setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
    input.tag=KONOTOR_TEXTINPUT_TEXTVIEW_TAG;
    [input setReturnKeyType:UIReturnKeyDefault];
    
    input.delegate=self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftInput:) name:UIKeyboardWillShowNotification object:nil];
    
    [textInputBox addSubview:input];
    [window addSubview:textInputBox];
    
    
    UIButton *cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(5, 7, 30, 30)];
    [cancelButton setTitle:@"X" forState:UIControlStateNormal];

#if KONOTOR_IOS7_BUTTONSTYLE
    [cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
#else
    [cancelButton setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
    cancelButton.layer.cornerRadius=15.0;
#endif
    
    
    [cancelButton addTarget:[self class] action:@selector(dismissInput) forControlEvents:UIControlEventTouchUpInside];
    
    [textInputBox addSubview:cancelButton];
    
    
    
    UIButton *sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(5+35+window.frame.size.width-30-10-50-35+5+10, 5, 65, 34)];
    
    [sendButton setTitleColor:KONOTOR_UIBUTTON_COLOR forState:UIControlStateNormal];
    [sendButton setTitle:@"SEND" forState:UIControlStateNormal];

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
        float y=(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))?(window.frame.size.width-keyboardEndFrame.size.width):(window.frame.size.height-keyboardEndFrame.size.height);
        y=(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))?keyboardFrame.origin.y:keyboardFrame.origin.y;
        float width=(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))?keyboardEndFrame.size.height:keyboardEndFrame.size.width;
        
        [textInputBox setFrame:CGRectMake(0, y-textInputBox.frame.size.height, width, textInputBox.frame.size.height)];
        [transparentView setFrame:CGRectMake(0, 0, width, window.frame.size.height)];
        
    } else {
        // Keyboard is hidden
        [KonotorTextInputOverlay performSelector:@selector(dismissInput) withObject:nil afterDelay:0.0];

    }
}

- (void) shiftInput:(NSNotification*)note{
    CGRect newFrame;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&newFrame];
    
    float y=(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))?(window.frame.size.width-newFrame.size.width):(window.frame.size.height-newFrame.size.height);
    float width=(UIInterfaceOrientationIsLandscape([[UIDevice currentDevice] orientation]))?newFrame.size.height:newFrame.size.width;
    
    [textInputBox setFrame:CGRectMake(0, y-textInputBox.frame.size.height, width, textInputBox.frame.size.height)];
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
    
    textInputBox.frame=CGRectMake(textInputBox.frame.origin.x, textInputBox.frame.origin.y-(txtSize.height-textBox.frame.size.height), textInputBox.frame.size.width, textInputBox.frame.size.height+(txtSize.height-textBox.frame.size.height));
    
    textBox.frame=CGRectMake(textView.frame.origin.x,textView.frame.origin.y,textView.frame.size.width,txtSize.height);
    
 //   [transparentView setFrame:CGRectMake(0, 0, textInputBox.frame.size.width, textInputBox.frame.origin.y)];
    
    txt=nil;
    
}


@end
