//
//  KonotorFeedbackScreenViewController.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 10/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorFeedbackScreenViewController.h"

@interface KonotorFeedbackScreenViewController ()

@end

@implementation KonotorFeedbackScreenViewController

@synthesize textInputBox,transparentView,messagesView;
@synthesize headerView,footerView,messageTableView,voiceInput,input;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.6]];
    }
    return self;
}

- (BOOL) shouldAutorotate{
    return YES;
}


- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    
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

    [headerView setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
    [headerView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:26.0]];
    [headerView setText:@"Feedback"];
    [headerView setEditable:NO];
    
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
    if([headerView respondsToSelector:@selector(setSelectable:)])
        [headerView setSelectable:NO];
#endif
    [headerView setScrollEnabled:NO];
    [headerView setTextColor:[UIColor whiteColor]];
    [headerView setTextAlignment:NSTextAlignmentCenter];
    
    if(!KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
        CGRect headerRect=headerView.frame;
        headerRect.origin.y=headerRect.origin.y+topPaddingIOS7;
        [headerView setFrame:headerRect];
    }
    
    UIButton* closeButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setBackgroundColor:[UIColor clearColor]];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
   // [closeButton setBackgroundImage:[UIImage imageNamed:@"konotor_cross.png"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"konotor_cross.png"] forState:UIControlStateNormal];
   // [closeButton setTitle:@"X" forState:UIControlStateNormal];
    [closeButton setFrame:CGRectMake(8,8,28,28)];
    [closeButton addTarget:[KonotorFeedbackScreen class] action:@selector(dismissScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:closeButton];
    
    [footerView setBackgroundColor:[UIColor whiteColor]];
    footerView.layer.shadowOffset=CGSizeMake(1,1);
    footerView.layer.shadowColor=[[UIColor grayColor] CGColor];
    footerView.layer.shadowRadius=2.0;
    footerView.layer.shadowOpacity=1.0;
    
    
    
    [input addTarget:self action:@selector(showTextInput) forControlEvents:UIControlEventTouchDown];
    
    
    [voiceInput setFrame:CGRectMake(footerView.frame.size.width-5-40, 2, 40, 40)];
    [voiceInput setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
    voiceInput.layer.cornerRadius=20.0;
    [voiceInput setImage:[UIImage imageNamed:@"konotor_mic.png"] forState:UIControlStateNormal];
    
    [voiceInput addTarget:self action:@selector(showVoiceInput) forControlEvents:UIControlEventTouchDown];
    

    
    
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



    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    //
    if(KONOTOR_PUSH_ON_NAVIGATIONCONTROLLER){
        [self.navigationItem setTitle:@"Feedback"];
        self.navigationController.navigationBar.titleTextAttributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor,[NSValue valueWithUIOffset:UIOffsetMake(1, 1)], UITextAttributeTextShadowOffset,[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.0],UITextAttributeFont,nil];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
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
}

- (void) showTextInput
{
    [KonotorTextInputOverlay showInputForView:self.view];
}

- (void) showVoiceInput
{
    BOOL recording=[Konotor startRecording];
    if(recording)
        [KonotorVoiceInputOverlay showInputLinearForView:self.view];
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
