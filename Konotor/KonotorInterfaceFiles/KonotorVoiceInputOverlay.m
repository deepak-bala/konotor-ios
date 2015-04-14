//
//  KonotorVoiceInputOverlay.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 13/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorVoiceInputOverlay.h"

KonotorVoiceInputOverlay* konotorVoiceInputOverlay=nil;

@implementation KonotorVoiceInputOverlay
@synthesize voiceFeedbackAnimatorView1,voiceFeedbackAnimatorView2,window,playButton,sendButton,stopButton,cancelButton,containerWidget,transparentView,feedbackAnimationTimer,timerLabel;


+(KonotorVoiceInputOverlay*) sharedInstance
{
    if(konotorVoiceInputOverlay==nil)
        konotorVoiceInputOverlay=[[KonotorVoiceInputOverlay alloc] init];
    return konotorVoiceInputOverlay;
}

+(BOOL) showInputForView:(UIView*) view
{
    if(konotorVoiceInputOverlay!=nil)
        return NO;
    konotorVoiceInputOverlay=[KonotorVoiceInputOverlay sharedInstance];
    konotorVoiceInputOverlay.window=view;
    konotorVoiceInputOverlay.isLinearInput=NO;
    [konotorVoiceInputOverlay showInputView];
    return YES;
}

+(BOOL) showInputLinearForView:(UIView*) view
{
    if(konotorVoiceInputOverlay!=nil)
        return NO;
    konotorVoiceInputOverlay=[KonotorVoiceInputOverlay sharedInstance];
    konotorVoiceInputOverlay.window=view;
    konotorVoiceInputOverlay.isLinearInput=YES;
    [konotorVoiceInputOverlay showInputViewLinear];
    return YES;
}

+ (void) rotateToOrientation:(UIInterfaceOrientation) orientation duration:(NSTimeInterval) duration
{
    if(konotorVoiceInputOverlay&&(konotorVoiceInputOverlay.isLinearInput)){
        UIView* transparentView=konotorVoiceInputOverlay.transparentView;
        UIView* containerWidget=konotorVoiceInputOverlay.containerWidget;
        UIView* voiceFeedbackAnimatorView1=konotorVoiceInputOverlay.voiceFeedbackAnimatorView1,*voiceFeedbackAnimatorView2=konotorVoiceInputOverlay.voiceFeedbackAnimatorView2;
        UILabel* timerLabel=konotorVoiceInputOverlay.timerLabel;
        UIButton* cancelButton=konotorVoiceInputOverlay.cancelButton;
        UIButton* sendButton=konotorVoiceInputOverlay.sendButton;
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0)
        if(UIInterfaceOrientationIsLandscape(orientation)&&(!(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))))
#else
        if(NO)
#endif
        {
            [transparentView setFrame:CGRectMake(0, 0, konotorVoiceInputOverlay.window.frame.size.height+20, konotorVoiceInputOverlay.window.frame.size.width-20)];
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                [transparentView setFrame:CGRectMake(0, 0, konotorVoiceInputOverlay.window.frame.size.height, konotorVoiceInputOverlay.window.frame.size.width)];
            }
#endif

        }
        else{
             [transparentView setFrame:CGRectMake(0, 0, konotorVoiceInputOverlay.window.frame.size.width+20, konotorVoiceInputOverlay.window.frame.size.height-20)];
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                [transparentView setFrame:CGRectMake(0, 0, konotorVoiceInputOverlay.window.frame.size.width, konotorVoiceInputOverlay.window.frame.size.height)];
            }
#endif
        }
        [containerWidget setFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN, transparentView.frame.size.height-44-KONOTOR_FEEDBACKSCREEN_MARGIN-2-KONOTOR_BOTTOM_EXTRAPADDING, transparentView.frame.size.width-KONOTOR_FEEDBACKSCREEN_MARGIN*2,44)];
        [voiceFeedbackAnimatorView1 setFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50, transparentView.frame.size.height-20-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, 120, 4)];
        [voiceFeedbackAnimatorView2 setFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50, transparentView.frame.size.height-20-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, 120, 4)];
        [timerLabel setFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50, transparentView.frame.size.height-40-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, transparentView.frame.size.width-KONOTOR_FEEDBACKSCREEN_MARGIN*2-100, 20)];
        [cancelButton setFrame:CGRectMake(5+KONOTOR_FEEDBACKSCREEN_MARGIN,transparentView.frame.size.height-42-10+5-3-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN,40,40)];
#if KONOTOR_IOS7_BUTTONSTYLE
        [sendButton setFrame:CGRectMake(transparentView.frame.size.width-45-KONOTOR_FEEDBACKSCREEN_MARGIN-20,transparentView.frame.size.height-42-10+5-3-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN,60,40)];
#else
        [sendButton setFrame:CGRectMake(transparentView.frame.size.width-45-KONOTOR_FEEDBACKSCREEN_MARGIN,transparentView.frame.size.height-42-10+5-3-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN,40,40)];
#endif
    }
}


- (void) showInputView
{
    //Add a transparent Overlay on top of the current view
    transparentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];

    [transparentView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7]];
    
    UIColor *bgcolor=[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0];
    UIColor *recordingColor=[UIColor colorWithRed:0.3 green:0.1 blue:0.1 alpha:0.8];
    
    //Add a central container and the voice controls around it
    containerWidget=[[UIView alloc] initWithFrame:CGRectMake(transparentView.frame.size.width/2-CONTAINER_RADIUS, transparentView.frame.size.height/2-CONTAINER_RADIUS, CONTAINER_RADIUS*2, CONTAINER_RADIUS*2)];
    containerWidget.layer.cornerRadius=CONTAINER_RADIUS;
    [containerWidget setBackgroundColor:bgcolor];
    [transparentView addSubview:containerWidget];
    
    
    //Add animated view
    voiceFeedbackAnimatorView1=[[UIView alloc] initWithFrame:CGRectMake(transparentView.frame.size.width/2-MINIMUM_RADIUS, transparentView.frame.size.height/2-MINIMUM_RADIUS, MINIMUM_RADIUS*2, MINIMUM_RADIUS*2)];
    voiceFeedbackAnimatorView1.layer.cornerRadius=MINIMUM_RADIUS;
    [voiceFeedbackAnimatorView1 setBackgroundColor:recordingColor];
    [transparentView addSubview:voiceFeedbackAnimatorView1];
    
    voiceFeedbackAnimatorView2=[[UIView alloc] initWithFrame:CGRectMake(transparentView.frame.size.width/2-MINIMUM_RADIUS, transparentView.frame.size.height/2-MINIMUM_RADIUS, MINIMUM_RADIUS*2, MINIMUM_RADIUS*2)];
    voiceFeedbackAnimatorView2.layer.cornerRadius=MINIMUM_RADIUS;
    [voiceFeedbackAnimatorView2 setBackgroundColor:recordingColor];
    [voiceFeedbackAnimatorView2 setHidden:YES];
    [transparentView addSubview:voiceFeedbackAnimatorView2];
    
    
    
    
    //Add center view that shows time
    timerLabel=[[UILabel alloc] initWithFrame:CGRectMake(transparentView.frame.size.width/2-MINIMUM_RADIUS, transparentView.frame.size.height/2-MINIMUM_RADIUS, MINIMUM_RADIUS*2, MINIMUM_RADIUS*2)];
    timerLabel.layer.cornerRadius=MINIMUM_RADIUS;
    [timerLabel setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
    timerLabel.layer.borderColor=[[UIColor colorWithRed:0.7 green:0.3 blue:0.3 alpha:0.7] CGColor];
    [timerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20.0]];
    [timerLabel setTextAlignment:NSTextAlignmentCenter];
    [timerLabel setText:@"0:00"];
    [transparentView addSubview:timerLabel];
    
    //Add a cancel button
    cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(containerWidget.frame.origin.x+CONTAINER_RADIUS-(CONTAINER_RADIUS)*cos(M_PI/3.0)-BUTTON_RADIUS, containerWidget.frame.origin.y+CONTAINER_RADIUS-BUTTON_RADIUS-CONTAINER_RADIUS*sin(M_PI/3.0), BUTTON_RADIUS*2, BUTTON_RADIUS*2)];
    cancelButton.layer.cornerRadius=BUTTON_RADIUS;
    [cancelButton setTitle:@"X" forState:UIControlStateNormal];
    [cancelButton setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
    [cancelButton addTarget:[KonotorVoiceInputOverlay class] action:@selector(dismissVoiceInput) forControlEvents:UIControlEventTouchUpInside];
    [transparentView addSubview:cancelButton];
    
    //Add a send button
    sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setFrame:CGRectMake(containerWidget.frame.origin.x+2*CONTAINER_RADIUS-BUTTON_RADIUS, containerWidget.frame.origin.y+CONTAINER_RADIUS-BUTTON_RADIUS, BUTTON_RADIUS*2, BUTTON_RADIUS*2)];
    sendButton.layer.cornerRadius=BUTTON_RADIUS;
  //  [sendButton setTitle:@"Go" forState:UIControlStateNormal];
    [sendButton setImage:[UIImage imageNamed:@"konotor_send.png"] forState:UIControlStateNormal];
    [sendButton setBackgroundColor:[UIColor colorWithRed:0.3 green:0.5 blue:0.3 alpha:1.0]];
    [sendButton addTarget:[KonotorVoiceInputOverlay class] action:@selector(sendRecording) forControlEvents:UIControlEventTouchUpInside];
    [transparentView addSubview:sendButton];
    
    //Add a stop button
    stopButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton setFrame:CGRectMake(containerWidget.frame.origin.x+CONTAINER_RADIUS-(CONTAINER_RADIUS)*cos(M_PI/3.0)-BUTTON_RADIUS, containerWidget.frame.origin.y+CONTAINER_RADIUS-BUTTON_RADIUS+CONTAINER_RADIUS*sin(M_PI/3.0), BUTTON_RADIUS*2, BUTTON_RADIUS*2)];
    stopButton.layer.cornerRadius=BUTTON_RADIUS;
  //  [stopButton setTitle:@"[ ]" forState:UIControlStateNormal];
    [stopButton setImage:[UIImage imageNamed:@"konotor_stop.png"] forState:UIControlStateNormal];
    [stopButton setBackgroundColor:[UIColor colorWithRed:0.25 green:0.2 blue:0.3 alpha:1.0]];
    [stopButton addTarget:[KonotorVoiceInputOverlay class] action:@selector(stopVoiceRecording) forControlEvents:UIControlEventTouchUpInside];
    [transparentView addSubview:stopButton];
   
    
    //render it all - add to screen
    [window addSubview:transparentView];
    feedbackAnimationTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animateVoiceFeedback) userInfo:nil repeats:YES];
    [feedbackAnimationTimer fire];
  //  [Konotor startRecording];
}

- (void) showInputViewLinear
{
    //Add a transparent Overlay on top of the current view
    transparentView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    if([KonotorUtility KonotorIsInterfaceLandscape:(((KonotorFeedbackScreen*)[KonotorFeedbackScreen sharedInstance]).conversationViewController)])
    {
        [transparentView setFrame:CGRectMake(0, 0, window.frame.size.height, window.frame.size.width)];
        
    }
    [transparentView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.7]];
    
    UIColor *recordingColor=KONOTOR_UIBUTTON_COLOR;
    
    //Add a central container and the voice controls around it
    containerWidget=[[UIView alloc] initWithFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN, transparentView.frame.size.height-44-KONOTOR_FEEDBACKSCREEN_MARGIN-2-KONOTOR_BOTTOM_EXTRAPADDING, transparentView.frame.size.width-KONOTOR_FEEDBACKSCREEN_MARGIN*2,44)];
    [containerWidget setBackgroundColor:[UIColor whiteColor]];
    containerWidget.layer.shadowOpacity=0.2;
    containerWidget.layer.shadowColor=[[UIColor blackColor] CGColor];
    containerWidget.layer.shadowRadius=2.0;
    containerWidget.layer.shadowOffset=CGSizeMake(1, 1);
    [transparentView addSubview:containerWidget];
    
    
    //Add animated view
    voiceFeedbackAnimatorView1=[[UIView alloc] initWithFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50, transparentView.frame.size.height-20-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, 120, 4)];
    [voiceFeedbackAnimatorView1 setBackgroundColor:recordingColor];
    [transparentView addSubview:voiceFeedbackAnimatorView1];
    
    voiceFeedbackAnimatorView2=[[UIView alloc] initWithFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50, transparentView.frame.size.height-20-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, 120, 4)];
    [voiceFeedbackAnimatorView2 setBackgroundColor:recordingColor];
    [voiceFeedbackAnimatorView2 setHidden:YES];
    [transparentView addSubview:voiceFeedbackAnimatorView2];
    
    
    
    
    //Add center view that shows time
    timerLabel=[[UILabel alloc] initWithFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50, transparentView.frame.size.height-40-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, transparentView.frame.size.width-KONOTOR_FEEDBACKSCREEN_MARGIN*2-100, 20)];
    [timerLabel setBackgroundColor:[UIColor clearColor]];
    [timerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:18.0]];
    [timerLabel setTextAlignment:NSTextAlignmentCenter];
    [timerLabel setText:@"0:00"];
    [transparentView addSubview:timerLabel];
    
    //Add a cancel button
    cancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(5+KONOTOR_FEEDBACKSCREEN_MARGIN,transparentView.frame.size.height-42-10+5-3-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN,40,40)];
    [cancelButton setTitle:@"X" forState:UIControlStateNormal];
#if KONOTOR_IOS7_BUTTONSTYLE
    [cancelButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
#else
    cancelButton.layer.cornerRadius=20;
    [cancelButton setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
#endif
    [cancelButton addTarget:[KonotorVoiceInputOverlay class] action:@selector(dismissVoiceInput) forControlEvents:UIControlEventTouchUpInside];
    [transparentView addSubview:cancelButton];
    
    //Add a send button
    sendButton=[UIButton buttonWithType:UIButtonTypeCustom];
    
#if KONOTOR_IOS7_BUTTONSTYLE
    [sendButton setFrame:CGRectMake(transparentView.frame.size.width-45-KONOTOR_FEEDBACKSCREEN_MARGIN-20,transparentView.frame.size.height-42-10+5-3-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN,60,40)];
    [sendButton setTitleColor:KONOTOR_UIBUTTON_COLOR forState:UIControlStateNormal];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
#else
    [sendButton setFrame:CGRectMake(transparentView.frame.size.width-45-KONOTOR_FEEDBACKSCREEN_MARGIN,transparentView.frame.size.height-42-10+5-3-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN,40,40)];
    sendButton.layer.cornerRadius=20;
    [sendButton setImage:[UIImage imageNamed:@"konotor_send.png"] forState:UIControlStateNormal];
    [sendButton setBackgroundColor:KONOTOR_UIBUTTON_COLOR];

#endif
    [sendButton addTarget:[KonotorVoiceInputOverlay class] action:@selector(sendRecording) forControlEvents:UIControlEventTouchUpInside];
    [transparentView addSubview:sendButton];
    
    //render it all - add to screen
    [window addSubview:transparentView];
    feedbackAnimationTimer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(animateVoiceFeedbackLinear) userInfo:nil repeats:YES];
    [feedbackAnimationTimer fire];
    //  [Konotor startRecording];
}

- (void) animateVoiceFeedbackLinear
{
    float radius;//=rand()%((int)transparentView.frame.size.width-100-KONOTOR_FEEDBACKSCREEN_MARGIN*2-20);
    //    radius=[Konotor getDecibelLevel];
    radius=[Konotor getDecibelLevel];
    radius=(radius-20)*((int)transparentView.frame.size.width-100-KONOTOR_FEEDBACKSCREEN_MARGIN*2-20)/55;
    if(radius<0) radius=0.0;
    
    UIView* toShow,*toHide;
    if(voiceFeedbackAnimatorView1.isHidden){
        toShow=voiceFeedbackAnimatorView1;
        toHide=voiceFeedbackAnimatorView2;
    }
    else{
        toShow=voiceFeedbackAnimatorView2;
        toHide=voiceFeedbackAnimatorView1;
    }
    [toHide setHidden:YES];
    
    [toShow setFrame:CGRectMake(KONOTOR_FEEDBACKSCREEN_MARGIN+50+10, transparentView.frame.size.height-20-10+5-KONOTOR_BOTTOM_EXTRAPADDING+6-KONOTOR_FEEDBACKSCREEN_MARGIN, radius, 4)];
    [toShow setHidden:NO];
    [timerLabel setText:[NSString stringWithFormat:@"%02d:%02d",(int)[Konotor getTimeElapsedSinceStartOfRecording]/(int)60,(int)[Konotor getTimeElapsedSinceStartOfRecording]%(int)60]];
}


- (void) animateVoiceFeedback
{
    float radius=MINIMUM_RADIUS+rand()%((int)MAXIMUM_RADIUS-(int)MINIMUM_RADIUS);
//    radius=[Konotor getDecibelLevel];
    float temp=[Konotor getDecibelLevel];
    NSLog(@"%f,",temp);
    UIView* toShow,*toHide;
    if(voiceFeedbackAnimatorView1.isHidden){
        toShow=voiceFeedbackAnimatorView1;
        toHide=voiceFeedbackAnimatorView2;
    }
    else{
        toShow=voiceFeedbackAnimatorView2;
        toHide=voiceFeedbackAnimatorView1;
    }
    [toHide setHidden:YES];
    
    [toShow setFrame:CGRectMake(transparentView.frame.size.width/2-radius, transparentView.frame.size.height/2-radius, radius*2, radius*2)];
    toShow.layer.cornerRadius=radius;
    [toShow setHidden:NO];
}

+(void) stopVoiceRecording
{
    NSString* messageID=[Konotor stopRecording];
    [Konotor playMessageWithMessageID:messageID];
}

+ (void) sendRecording
{
    NSString* messageID=[Konotor stopRecording];
    [Konotor uploadVoiceRecordingWithMessageID:messageID];
    
    /*   int count=[[Konotor getAllMessagesForDefaultConversation] count];
    NSString* messagesDownloadedAlertText=[NSString stringWithFormat:@"%d messages in this conversation", count];
    UIAlertView* konotorAlert=[[UIAlertView alloc] initWithTitle:@"Finished loading messages" message:messagesDownloadedAlertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [konotorAlert show];*/
    [KonotorVoiceInputOverlay dismissVoiceInputOverlay];
    [KonotorFeedbackScreen refreshMessages];
}

+(void) dismissVoiceInput
{
    if(konotorVoiceInputOverlay){
        [Konotor stopRecording];
        [konotorVoiceInputOverlay.transparentView removeFromSuperview];
        konotorVoiceInputOverlay.transparentView=nil;
        [konotorVoiceInputOverlay.feedbackAnimationTimer invalidate];
        konotorVoiceInputOverlay=nil;
    }
}

+(void) dismissVoiceInputOverlay
{
    [konotorVoiceInputOverlay.transparentView removeFromSuperview];
    konotorVoiceInputOverlay.transparentView=nil;
    [konotorVoiceInputOverlay.feedbackAnimationTimer invalidate];
    konotorVoiceInputOverlay=nil;
    [KonotorFeedbackScreen refreshMessages];
}

@end
