//
//  KonotorFeedbackScreenViewController.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 10/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorFeedbackScreenViewController.h"

static NSString *microphoneAccessDenied=@"KonotorMicrophoneAccessDenied";

static KonotorUIParameters* konotorUIParameters=nil;

@interface KonotorFeedbackScreenViewController ()

@end

@implementation KonotorFeedbackScreenViewController

@synthesize textInputBox,transparentView,messagesView;
@synthesize headerContainerView,headerView,closeButton,footerView,messageTableView,voiceInput,input,picInput,poweredByLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if([konotorUIParameters backgroundViewColor])
            [self.view setBackgroundColor:[konotorUIParameters backgroundViewColor]];
        else
            [self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (BOOL) shouldAutorotate{
    return YES;
}


- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    float topPaddingIOS7=0;
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        topPaddingIOS7=20;
    }
#endif
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)

    if(KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
        float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (systemVersion >= 7.0) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
#endif
    
#if KONOTOR_VOICE_INPUT_SUPPORT==0
    [[KonotorUIParameters sharedInstance] setVoiceInputEnabled:NO];
#endif
#if KONOTOR_IMAGE_INPUT_SUPPORT==0
    [[KonotorUIParameters sharedInstance] setImageInputEnabled:NO];
#endif
        
    if([konotorUIParameters headerViewColor])
        [headerView setBackgroundColor:[konotorUIParameters headerViewColor]];
    if([konotorUIParameters titleText]){
        [headerView setText:[konotorUIParameters titleText]];
        [headerView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:22.0]];
        [headerView setTextColor:[UIColor whiteColor]];
        [headerView setTextAlignment:NSTextAlignmentCenter];
    }
    if([konotorUIParameters titleTextColor]){
        [headerView setTextColor:[konotorUIParameters titleTextColor]];
    }
 
 /*   [headerView setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
    [headerView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:26.0]];
    [headerView setText:@"Feedback"];
    [headerView setEditable:NO];
    
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
    if([headerView respondsToSelector:@selector(setSelectable:)])
        [headerView setSelectable:NO];
#endif
    [headerView setScrollEnabled:NO];
    [headerView setTextColor:[UIColor whiteColor]];
    [headerView setTextAlignment:NSTextAlignmentCenter]; */
    
    if(!KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
    /*    CGRect headerRect=headerView.frame;
        headerRect.origin.y=headerRect.origin.y+topPaddingIOS7;
        [headerView setFrame:headerRect];
        CGRect closeButtonRect=closeButton.frame;
        closeButtonRect.origin.y=closeButtonRect.origin.y+topPaddingIOS7;
        [closeButton setFrame:closeButtonRect];*/
        CGRect headerRect=headerContainerView.frame;
        headerRect.origin.y=headerRect.origin.y+topPaddingIOS7;
        [headerContainerView setFrame:headerRect];
    }
    
    //UIButton* closeButton=[UIButton buttonWithType:UIButtonTypeCustom];
  /*  [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"konotor_cross.png"] forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(8,8,28,28)];*/
    
    if([konotorUIParameters closeButtonImage])
       [closeButton setImage:[konotorUIParameters closeButtonImage] forState:UIControlStateNormal];
    [closeButton addTarget:[KonotorFeedbackScreen class] action:@selector(dismissScreen) forControlEvents:UIControlEventTouchUpInside];
    
  //  [headerView addSubview:closeButton];
    
  //  [footerView setBackgroundColor:[UIColor whiteColor]];
    footerView.layer.shadowOffset=CGSizeMake(1,1);
    footerView.layer.shadowColor=[[UIColor grayColor] CGColor];
    footerView.layer.shadowRadius=2.0;
    footerView.layer.shadowOpacity=1.0;
    
    
    
    [input addTarget:self action:@selector(showTextInput) forControlEvents:UIControlEventTouchDown];
    
    [voiceInput setFrame:CGRectMake(footerView.frame.size.width-5-40, 2, 40, 40)];

    if([[KonotorUIParameters sharedInstance] voiceInputEnabled]){
    
    [voiceInput setFrame:CGRectMake(footerView.frame.size.width-5-40, 2, 40, 40)];
   // [voiceInput setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
    voiceInput.layer.cornerRadius=20.0;
    [voiceInput setImage:[UIImage imageNamed:@"konotor_mic.png"] forState:UIControlStateNormal];
    
    [voiceInput addTarget:self action:@selector(showVoiceInput) forControlEvents:UIControlEventTouchDown];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToTextOnlyInput) name:microphoneAccessDenied object:nil];
    }
    else{
    [voiceInput setTitle:@"SEND" forState:UIControlStateNormal];
    [voiceInput setImage:nil forState:UIControlStateNormal];
    [voiceInput setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [voiceInput setFrame:CGRectMake(voiceInput.frame.origin.x-15, voiceInput.frame.origin.y, voiceInput.frame.size.width+20, voiceInput.frame.size.height)];
    [voiceInput setBackgroundColor:[UIColor whiteColor]];
    [voiceInput setUserInteractionEnabled:NO];
    }
    
    if([[KonotorUIParameters sharedInstance] imageInputEnabled])
    [picInput addTarget:self action:@selector(showImageInput) forControlEvents:UIControlEventTouchDown];
    else{
    [picInput setHidden:YES];
    [input setFrame:CGRectMake(input.frame.origin.x-40, input.frame.origin.y, input.frame.size.width+40, input.frame.size.height)];
    }

#if (KONOTOR_DONTSHOWPOWEREDBY==1)
    [messageTableView setFrame:CGRectMake(messageTableView.frame.origin.x, messageTableView.frame.origin.y, messageTableView.frame.size.width, messageTableView.frame.size.height+18)];
    [footerView setFrame:CGRectMake(footerView.frame.origin.x, footerView.frame.origin.y+18, footerView.frame.size.width, footerView.frame.size.height)];
    [poweredByLabel setHidden:YES];
#endif
    
    if((!konotorUIParameters.showInputOptions)&&(!footerView.hidden)){
        [messageTableView setFrame:CGRectMake(messageTableView.frame.origin.x, messageTableView.frame.origin.y, messageTableView.frame.size.width, messageTableView.frame.size.height+footerView.frame.size.height)];
        [footerView setHidden:YES];
    }
    
    messagesView=[[KonotorConversationViewController alloc] init];
    messagesView.view=messageTableView;
    [messageTableView setDelegate:messagesView];
    [messageTableView setDataSource:messagesView];
    
    if(!KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
        CGRect messageRect=messagesView.view.frame;
        messageRect.origin.y=messageRect.origin.y+topPaddingIOS7;
        messageRect.size.height=messageRect.size.height-topPaddingIOS7;
        [messagesView.view setFrame:messageRect];
    }

    [Konotor setDelegate:messagesView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVoiceInputOverlay) name:@"KonotorRecordingStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRecordingFailed) name:@"KonotorRecordingFailed" object:nil];


    // Do any additional setup after loading the view from its nib.

}


- (void) viewDidAppear:(BOOL)animated
{
    //
    if(KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
        if([konotorUIParameters titleText])
            [self.navigationItem setTitle:[konotorUIParameters titleText]];
        else
            [self.navigationItem setTitle:@"Feedback"];


      //  self.navigationController.navigationBar.titleTextAttributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(1, 1)], UITextAttributeTextShadowOffset,[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.0],UITextAttributeFont,nil];
        
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if([konotorUIParameters closeButtonImage])
            [button setImage:[konotorUIParameters closeButtonImage] forState:UIControlStateNormal];
        else
            [button setBackgroundImage:[UIImage imageNamed:@"konotor_cross.png"] forState:UIControlStateNormal];
        button.frame=CGRectMake(0,0, 36, 36);
        [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem=backButton;

    }

}



-(IBAction)cancel:(id)sender{
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 0);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [Konotor StopPlayback];
        [self.navigationController popViewControllerAnimated:YES];
    });
  
}


- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [messagesView refreshView];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [KonotorVoiceInputOverlay rotateToOrientation:toInterfaceOrientation duration:duration];
    [KonotorImageInput rotateToOrientation:toInterfaceOrientation duration:duration];
    if(self.messagesView.fullImageView)
        [self.messagesView.fullImageView rotateToOrientation:toInterfaceOrientation duration:duration];
}

- (void) showTextInput
{
    [self.footerView setHidden:YES];
    [KonotorTextInputOverlay showInputForViewController:self];
}

- (void) showVoiceInput
{
    [Konotor startRecording];
}


- (void) showImageInput
{
    [KonotorImageInput showInputOptions:self];

}

- (void) showRecordingFailed
{
    [KonotorUtility showToastWithString:@"Voice recording failed. Try again." forMessageID:nil];
}

- (void) showVoiceInputOverlay
{
    [KonotorVoiceInputOverlay showInputLinearForView:self.view];
}

- (void) switchToTextOnlyInput
{
    [KonotorUtility showToastWithString:@"Change Mic Permissions in Settings" forMessageID:nil];
    [voiceInput setImage:nil forState:UIControlStateNormal];
    [voiceInput setTitle:@"SEND" forState:UIControlStateNormal];
    [voiceInput setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [voiceInput setFrame:CGRectMake(voiceInput.frame.origin.x-15, voiceInput.frame.origin.y, voiceInput.frame.size.width+20, voiceInput.frame.size.height)];
    [voiceInput setBackgroundColor:[UIColor whiteColor]];
    [voiceInput removeTarget:self action:@selector(showVoiceInput) forControlEvents:UIControlEventTouchDown];
    [voiceInput setUserInteractionEnabled:NO];
}

-(void) dismissVoiceInputOverlay
{
    [KonotorVoiceInputOverlay dismissVoiceInputOverlay];
}

- (void) refreshView
{
    [messagesView refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation KonotorUIParameters

@synthesize disableTransparentOverlay,headerViewColor,backgroundViewColor,voiceInputEnabled,imageInputEnabled,closeButtonImage,toastStyle,autoShowTextInput,titleText,toastBGColor,toastTextColor,textInputButtonImage,titleTextColor,showInputOptions;

+ (KonotorUIParameters*) sharedInstance
{
    if(konotorUIParameters==nil){
        konotorUIParameters=[[KonotorUIParameters alloc] init];
        konotorUIParameters.voiceInputEnabled=YES;
        konotorUIParameters.imageInputEnabled=YES;
        konotorUIParameters.toastStyle=KonotorToastStyleDefault;
        konotorUIParameters.toastBGColor=[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        konotorUIParameters.toastTextColor=[UIColor whiteColor];
        konotorUIParameters.titleTextColor=nil;
        konotorUIParameters.showInputOptions=YES;
        konotorUIParameters.textInputButtonImage=nil;
        konotorUIParameters.messageSharingEnabled=NO;

    }
    return konotorUIParameters;
}

- (void) setToastStyle:(enum KonotorToastStyle) style backgroundColor:(UIColor*) bgColor textColor: (UIColor*) textColor
{
    self.toastStyle=style;
    self.toastTextColor=textColor;
    self.toastBGColor=bgColor;
}

- (void) disableMessageSharing{
    self.messageSharingEnabled=NO;
}
- (void) enableMessageSharing{
    self.messageSharingEnabled=YES;
}

@end
