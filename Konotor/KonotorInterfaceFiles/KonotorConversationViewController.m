//
//  KonotorConversationViewController.m
//  KonotorSampleApp
//
//  Created by Srikrishnan Ganesan on 08/07/13.
//  Copyright (c) 2013 Demach. All rights reserved.
//

#import "KonotorConversationViewController.h"

@interface KonotorConversationViewController ()

@end

static int messageCount=0;
static NSArray* messages=nil;
static BOOL loading=NO;
static BOOL showingAlert=NO;
static NSString* copiedText=@"";
static NSData* copiedContent=nil;
static NSString* copiedMessageId=@"";
#if KONOTOR_MESSAGE_SHARE_SUPPORT
static enum KonotorMessageType copiedMessageType=KonotorMessageTypeText;
#endif
static NSString* copiedMimeType=@"";

static int numberOfMessagesShown=KONOTOR_MESSAGESPERPAGE;
static int loadMore=KONOTOR_MESSAGESPERPAGE;

NSMutableDictionary *messageHeights=nil;

#if KONOTOR_MESSAGE_SHARE_SUPPORT
MFMailComposeViewController* mailComposer=nil;
#endif

UIImage* meImage=nil,*otherImage=nil,*sendingImage=nil,*sentImage=nil;

@implementation TapOnPictureRecognizer

@synthesize height,width,image,imageURL;

@end

@implementation KonotorShareButton

@synthesize messageId;

@end

@implementation KonotorConversationViewController
@synthesize fullImageView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView setSeparatorColor:[UIColor clearColor]];
        [self.tableView setBackgroundColor:KONOTOR_MESSAGELAYOUT_BACKGROUND_COLOR];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#if KONOTOR_MESSAGE_SHARE_SUPPORT
    mailComposer=[[MFMailComposeViewController alloc] init];
    [mailComposer setMailComposeDelegate:self];
#endif
    if(messageHeights==nil)
        messageHeights=[[NSMutableDictionary alloc] init];
    numberOfMessagesShown=KONOTOR_MESSAGESPERPAGE;
    
    messages=[Konotor getAllMessagesForDefaultConversation];
    
    loading=YES;
    if(![Konotor areConversationsDownloading])
        [Konotor DownloadAllMessages];
    
    if(YES){
        meImage=[UIImage imageNamed:@"konotor_profile.png"];
        otherImage=[UIImage imageNamed:@"konotor_supportprofile.png"];
    }
    sendingImage=[UIImage imageNamed:@"konotor_uploading.png"];
    sentImage=[UIImage imageNamed:@"konotor_sent.png"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // [self.tableView scrollRectToVisible:CGRectMake(0,self.tableView.contentSize.height-50, 2, 50) animated:YES];
    [Konotor MarkAllMessagesAsRead];
    [self registerForKeyboardNotifications];

}

- (void) animateAndDisplayView
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSSortDescriptor* desc=[[NSSortDescriptor alloc] initWithKey:@"createdMillis" ascending:YES];
    messages=[[Konotor getAllMessagesForDefaultConversation] sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    messageCount=(int)[messages count];
    if((numberOfMessagesShown>messageCount)||(messageCount<=KONOTOR_MESSAGESPERPAGE)||((messageCount-numberOfMessagesShown)<3))
        numberOfMessagesShown=messageCount;
    if(!loading)
        return numberOfMessagesShown;
    else
        return numberOfMessagesShown+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((loading)&&(indexPath.row==numberOfMessagesShown))
    {
        static NSString *CellIdentifier = @"KonotorRefreshCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UIActivityIndicatorView* refreshIndicator=(UIActivityIndicatorView*)[cell viewWithTag:KONOTOR_REFRESHINDICATOR_TAG];
        if(refreshIndicator==nil){
            refreshIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [refreshIndicator setFrame:CGRectMake(self.view.frame.size.width/2-10, cell.contentView.frame.size.height/2-10, 20, 20)];
            refreshIndicator.tag=KONOTOR_REFRESHINDICATOR_TAG;
            [cell.contentView addSubview:refreshIndicator];
        }
        if(![refreshIndicator isAnimating])
            [refreshIndicator startAnimating];
        
        return cell;
        
    }
    else if(indexPath.row==numberOfMessagesShown){
        static NSString *CellIdentifier = @"KonotorBlankCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    else if((indexPath.row==0)&&(numberOfMessagesShown<messageCount)){
        static NSString *CellIdentifier = @"KonotorRefreshCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        UIActivityIndicatorView* refreshIndicator=(UIActivityIndicatorView*)[cell viewWithTag:KONOTOR_REFRESHINDICATOR_TAG];
        if(refreshIndicator==nil){
            refreshIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [refreshIndicator setFrame:CGRectMake(self.view.frame.size.width/2-10, cell.contentView.frame.size.height/2-10, 20, 20)];
            refreshIndicator.tag=KONOTOR_REFRESHINDICATOR_TAG;
            [cell.contentView addSubview:refreshIndicator];
        }
        if(![refreshIndicator isAnimating])
            [refreshIndicator startAnimating];
        int oldnumber=numberOfMessagesShown;
        numberOfMessagesShown+=loadMore;
        if(numberOfMessagesShown>messageCount) numberOfMessagesShown=messageCount;
        [self performSelector:@selector(refreshView:) withObject:[NSNumber numberWithInt:oldnumber] afterDelay:0];
        return cell;
    }
    KonotorMessageData* currentMessage=(KonotorMessageData*)[messages objectAtIndex:(messageCount-numberOfMessagesShown+indexPath.row)];
    
    BOOL isSenderOther=([Konotor isUserMe:currentMessage.messageUserId])?NO:YES;
    BOOL showsProfile=KONOTOR_SHOWPROFILEIMAGE;
    float profileX=0.0, profileY=0.0, messageContentViewX=0.0, messageContentViewY=0.0, messageTextBoxX=0.0, messageTextBoxY=0.0,messageContentViewWidth=0.0,messageTextBoxWidth=0.0;
    
    
    
    messageContentViewWidth = KONOTOR_TEXTMESSAGE_MAXWIDTH;
    if([currentMessage messageType].integerValue==KonotorMessageTypeText){
        CGSize sizer = [self getSizeOfTextViewWidth:KONOTOR_TEXTMESSAGE_MAXWIDTH text:currentMessage.text withFont:KONOTOR_MESSAGETEXT_FONT];
        int numLines = sizer.height / ([self getTextViewLineHeight:KONOTOR_TEXTMESSAGE_MAXWIDTH text:currentMessage.text withFont:KONOTOR_MESSAGETEXT_FONT]);
        if (numLines == 1)
        {
            CGSize txtSize =[currentMessage.text sizeWithAttributes:
                             @{NSFontAttributeName:
                                   KONOTOR_MESSAGETEXT_FONT}];
            
            NSDate* date=[NSDate dateWithTimeIntervalSince1970:currentMessage.createdMillis.longLongValue/1000];
            NSString *strDate = [KonotorConversationViewController stringRepresentationForDate:date];
            CGSize txtTimeSize =[strDate sizeWithAttributes:
                                 @{NSFontAttributeName:
                                       [UIFont fontWithName:@"HelveticaNeue" size:11]}];
            
            CGFloat msgWidth = txtSize.width + 16 + 3 * KONOTOR_HORIZONTAL_PADDING;
            CGFloat timeWidth = (txtTimeSize.width + 16 +  5 * KONOTOR_HORIZONTAL_PADDING);
            
            if ( msgWidth < timeWidth)
            {
                messageContentViewWidth = timeWidth;
            }
            else
            {
                messageContentViewWidth = msgWidth;
                
            }
        }
    }
    
    
    // get the length of the textview if one line and calculate page sides
    
    float messageDisplayWidth=self.view.frame.size.width;
    
    
    if(showsProfile){
        profileX=isSenderOther?KONOTOR_HORIZONTAL_PADDING:(messageDisplayWidth-KONOTOR_HORIZONTAL_PADDING-KONOTOR_PROFILEIMAGE_DIMENSION);
        profileY=KONOTOR_VERTICAL_PADDING;
        messageContentViewY=KONOTOR_VERTICAL_PADDING;
        messageContentViewWidth=MIN(messageDisplayWidth-KONOTOR_PROFILEIMAGE_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING,KONOTOR_TEXTMESSAGE_MAXWIDTH);
        messageContentViewX=isSenderOther?(profileX+KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_HORIZONTAL_PADDING):(messageDisplayWidth-KONOTOR_HORIZONTAL_PADDING-KONOTOR_PROFILEIMAGE_DIMENSION-KONOTOR_HORIZONTAL_PADDING-messageContentViewWidth);
        
        messageTextBoxWidth=messageContentViewWidth-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING;
        messageTextBoxX=isSenderOther?(messageContentViewX+KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING):(messageContentViewX+KONOTOR_HORIZONTAL_PADDING);
        
        messageTextBoxY=isSenderOther?(messageContentViewY+(KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?(KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING):0)):(messageContentViewY+(KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?(KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING):0));
    }
    else{
        
        messageContentViewY=KONOTOR_VERTICAL_PADDING;
        messageContentViewWidth= MIN(messageDisplayWidth-8*KONOTOR_HORIZONTAL_PADDING,messageContentViewWidth);
        messageContentViewX=isSenderOther?(KONOTOR_HORIZONTAL_PADDING*2):(messageDisplayWidth-2*KONOTOR_HORIZONTAL_PADDING-messageContentViewWidth);
        messageTextBoxWidth=messageContentViewWidth-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING;
        messageTextBoxX=isSenderOther?(messageContentViewX+KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING):(messageContentViewX+KONOTOR_HORIZONTAL_PADDING);
        messageTextBoxY=isSenderOther?(messageContentViewY+(KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?(KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING):0)):(messageContentViewY+(KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?(KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING):0));
    }
    
    static NSString *CellIdentifier = @"KonotorMessagesTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        
        if(KONOTOR_USESCALLOUTIMAGE==YES){
            
            UIImageView *messageBackground=[[UIImageView alloc] initWithFrame:CGRectMake((KONOTOR_SHOWPROFILEIMAGE?1:0)*(KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_HORIZONTAL_PADDING)+KONOTOR_HORIZONTAL_PADDING, KONOTOR_VERTICAL_PADDING, 1, 1)];
            UIEdgeInsets insets=UIEdgeInsetsMake(KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET, KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET, KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET, KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET);
            [messageBackground setImage:[[UIImage imageNamed:@"konotor_chatbubble_ios7_other.png"] resizableImageWithCapInsets:insets]];
            messageBackground.tag=KONOTOR_CALLOUT_TAG;
            [cell.contentView addSubview:messageBackground];
            
        }
        
        UITextView *userNameField=[[UITextView alloc] initWithFrame:CGRectMake(messageTextBoxX, messageTextBoxY, messageTextBoxWidth, KONOTOR_USERNAMEFIELD_HEIGHT)];
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        
        if([userNameField respondsToSelector:@selector(textContainerInset)])
            [userNameField setTextContainerInset:UIEdgeInsetsMake(4, 0, 0, 0)];
        else
#endif
            userNameField.contentInset=UIEdgeInsetsMake(-4, 0,-4,0);
        [userNameField setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
        [userNameField setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        
        [userNameField setTextAlignment:NSTextAlignmentLeft];
        if(isSenderOther)
            [userNameField setTextColor:[UIColor darkGrayColor]];
        else
            [userNameField setTextColor:KONOTOR_UIBUTTON_COLOR];
        [userNameField setEditable:NO];
        [userNameField setScrollEnabled:NO];
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        if([userNameField respondsToSelector:@selector(setSelectable:)])
            [userNameField setSelectable:NO];
#endif
        //   [userNameField setContentOffset:CGPointMake(0,-4)];
        // [userNameField setContentSize:CGSizeMake(messageTextBoxWidth, KONOTOR_USERNAMEFIELD_HEIGHT)];
        userNameField.tag=KONOTOR_USERNAMEFIELD_TAG;
        if(KONOTOR_SHOW_SENDERNAME)
            [cell.contentView addSubview:userNameField];
        
        UITextView *timeField=[[UITextView alloc] initWithFrame:CGRectMake(messageTextBoxX, messageTextBoxY+((KONOTOR_SHOW_SENDERNAME)?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING), messageTextBoxWidth, KONOTOR_TIMEFIELD_HEIGHT)];
        [timeField setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
        [timeField setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [timeField setTextAlignment:NSTextAlignmentLeft];
        [timeField setTextColor:[UIColor darkGrayColor]];
        [timeField setEditable:NO];
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        if([timeField respondsToSelector:@selector(setSelectable:)])
            [timeField setSelectable:NO];
#endif
        [timeField setScrollEnabled:NO];
        timeField.tag=KONOTOR_TIMEFIELD_TAG;
        if(KONOTOR_SHOW_TIMESTAMP)
            [cell.contentView addSubview:timeField];
        
        if(KONOTOR_SHOW_DURATION&&KONOTOR_SHOW_SENDERNAME&&KONOTOR_SHOW_TIMESTAMP)
        {
            UITextView *durationField=[[UITextView alloc] initWithFrame:CGRectMake(messageTextBoxX, messageTextBoxY+((KONOTOR_SHOW_SENDERNAME)?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING), messageTextBoxWidth, KONOTOR_TIMEFIELD_HEIGHT)];
            [durationField setFont:[UIFont fontWithName:@"HelveticaNeue" size:11]];
            [durationField setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
            [durationField setTextAlignment:NSTextAlignmentRight];
            [durationField setTextColor:[UIColor darkGrayColor]];
            [durationField setEditable:NO];
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
            if([durationField respondsToSelector:@selector(setSelectable:)])
                [durationField setSelectable:NO];
#endif
            [durationField setScrollEnabled:NO];
            durationField.tag=KONOTOR_DURATION_TAG;
            [cell.contentView addSubview:durationField];
        }
        
        
        UITextView* messageText=[[UITextView alloc] initWithFrame:CGRectMake((KONOTOR_SHOWPROFILEIMAGE?1:0)*(KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_HORIZONTAL_PADDING)+KONOTOR_HORIZONTAL_PADDING, KONOTOR_VERTICAL_PADDING+KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING, self.view.frame.size.width-(KONOTOR_SHOWPROFILEIMAGE?1:0)*(KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_HORIZONTAL_PADDING)-30, 10)];
        [messageText setFont:KONOTOR_MESSAGETEXT_FONT];
        [messageText setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [messageText setDataDetectorTypes:UIDataDetectorTypeLink];
        [messageText setTextAlignment:NSTextAlignmentLeft];
        [messageText setTextColor:[UIColor blackColor]];
        [messageText setEditable:NO];
        [messageText setScrollEnabled:NO];
        messageText.scrollsToTop=NO;
        messageText.tag=KONOTOR_MESSAGETEXTVIEW_TAG;
        
        
        
        KonotorMediaUIButton *playButton=[[KonotorMediaUIButton alloc] initWithFrame:CGRectMake(messageTextBoxWidth-KONOTOR_HORIZONTAL_PADDING-KONOTOR_PLAYBUTTON_DIMENSION,KONOTOR_AUDIOMESSAGE_HEIGHT/2-KONOTOR_PLAYBUTTON_DIMENSION/2,KONOTOR_PLAYBUTTON_DIMENSION,KONOTOR_PLAYBUTTON_DIMENSION)];
        [playButton setImage:[UIImage imageNamed:@"konotor_play.png"] forState:UIControlStateNormal];
        [playButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [playButton setBackgroundColor:KONOTOR_UIBUTTON_COLOR];
        playButton.layer.cornerRadius=KONOTOR_PLAYBUTTON_DIMENSION/2;
        [playButton addTarget:self action:@selector(playMedia:) forControlEvents:UIControlEventTouchUpInside];
        playButton.tag=KONOTOR_PLAYBUTTON_TAG;
        
        [messageText addSubview:playButton];
        
        playButton.mediaProgressBar=[[UISlider alloc] initWithFrame:CGRectMake(KONOTOR_HORIZONTAL_PADDING, KONOTOR_AUDIOMESSAGE_HEIGHT/2-2, messageDisplayWidth-KONOTOR_PLAYBUTTON_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING, 4)];
        playButton.mediaProgressBar.frame=CGRectMake(KONOTOR_HORIZONTAL_PADDING, KONOTOR_AUDIOMESSAGE_HEIGHT/2-playButton.mediaProgressBar.currentThumbImage.size.height/2, messageTextBoxWidth-KONOTOR_PLAYBUTTON_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING, playButton.mediaProgressBar.currentThumbImage.size.height);
        playButton.mediaProgressBar.frame=CGRectMake(KONOTOR_HORIZONTAL_PADDING, KONOTOR_AUDIOMESSAGE_HEIGHT/2-playButton.mediaProgressBar.bounds.size.height/2, messageTextBoxWidth-KONOTOR_PLAYBUTTON_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING, playButton.mediaProgressBar.bounds.size.height);
        [playButton.mediaProgressBar setMinimumTrackImage:[UIImage imageNamed:@"konotor_progress_blue.png"] forState:UIControlStateNormal];
        [playButton.mediaProgressBar setMaximumTrackImage:[UIImage imageNamed:@"konotor_progress_black.png"] forState:UIControlStateNormal];
        
        [messageText addSubview:playButton.mediaProgressBar];
        
        
        [cell.contentView addSubview:messageText];
        
        UIImageView* profileImage=[[UIImageView alloc] initWithFrame:CGRectMake(profileX, profileY, KONOTOR_PROFILEIMAGE_DIMENSION, KONOTOR_PROFILEIMAGE_DIMENSION)];
        profileImage.tag=KONOTOR_PROFILEIMAGE_TAG;
        [cell.contentView addSubview:profileImage];
        
        UIImageView* uploadStatus=[[UIImageView alloc] initWithFrame:CGRectMake(messageTextBoxX+messageTextBoxWidth-15-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING, KONOTOR_VERTICAL_PADDING+6+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0))), 15, 15)];
        [uploadStatus setImage:sentImage];
        uploadStatus.tag=KONOTOR_UPLOADSTATUS_TAG;
        if(KONOTOR_SHOW_UPLOADSTATUS)
            [cell.contentView addSubview:uploadStatus];
#if KONOTOR_IMAGE_SUPPORT
        UIImageView* picView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KONOTOR_TEXTMESSAGE_MAXWIDTH, 0)];
        picView.tag=KONOTOR_PICTURE_TAG;
        [messageText addSubview:picView];
#endif
        
#if KONOTOR_MESSAGE_SHARE_SUPPORT
        KonotorShareButton* shareButton=[KonotorShareButton buttonWithType:UIButtonTypeCustom];
        [shareButton setImage:[UIImage imageNamed:@"konotor_share.png"] forState:UIControlStateNormal];
        [shareButton setFrame:CGRectMake(0, 0, 36, 36)];
        [shareButton setHidden:YES];
        shareButton.tag=KONOTOR_SHAREBUTTON_TAG;
        [shareButton addTarget:self action:@selector(showMessageActions:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setMessageId:currentMessage.messageId];
        [cell.contentView addSubview:shareButton];
        
#endif
    }
    else{
        KonotorMediaUIButton* playButton=(KonotorMediaUIButton*)[cell.contentView viewWithTag:KONOTOR_PLAYBUTTON_TAG];
        playButton.frame=CGRectMake(messageTextBoxWidth-KONOTOR_HORIZONTAL_PADDING-KONOTOR_PLAYBUTTON_DIMENSION,KONOTOR_AUDIOMESSAGE_HEIGHT/2-KONOTOR_PLAYBUTTON_DIMENSION/2,KONOTOR_PLAYBUTTON_DIMENSION,KONOTOR_PLAYBUTTON_DIMENSION);
        playButton.mediaProgressBar.frame=CGRectMake(KONOTOR_HORIZONTAL_PADDING, KONOTOR_AUDIOMESSAGE_HEIGHT/2-playButton.mediaProgressBar.currentThumbImage.size.height/2, messageTextBoxWidth-KONOTOR_PLAYBUTTON_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING, playButton.mediaProgressBar.currentThumbImage.size.height);
        playButton.mediaProgressBar.frame=CGRectMake(KONOTOR_HORIZONTAL_PADDING, KONOTOR_AUDIOMESSAGE_HEIGHT/2-playButton.mediaProgressBar.bounds.size.height/2, messageTextBoxWidth-KONOTOR_PLAYBUTTON_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING, playButton.mediaProgressBar.bounds.size.height);
        
    }
    
    // Configure the cell...
    
    UITextView* messageText=(UITextView*)[cell.contentView viewWithTag:KONOTOR_MESSAGETEXTVIEW_TAG];
    UIImageView* messageBackground=(UIImageView*)[cell.contentView viewWithTag:KONOTOR_CALLOUT_TAG];
    KonotorMediaUIButton* playButton=(KonotorMediaUIButton*)[cell.contentView viewWithTag:KONOTOR_PLAYBUTTON_TAG];
    [playButton stopAnimating];
    
    UITextView* userNameField=(UITextView*)[cell.contentView viewWithTag:KONOTOR_USERNAMEFIELD_TAG];
    UITextView* timeField=(UITextView*)[cell.contentView viewWithTag:KONOTOR_TIMEFIELD_TAG];
    UITextView* durationField=(UITextView*)[cell.contentView viewWithTag:KONOTOR_DURATION_TAG];
    
    [userNameField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY, messageTextBoxWidth, KONOTOR_USERNAMEFIELD_HEIGHT)];
    
    UIImageView* uploadStatus=(UIImageView*)[cell.contentView viewWithTag:KONOTOR_UPLOADSTATUS_TAG];
    [uploadStatus setFrame:CGRectMake(messageTextBoxX+messageTextBoxWidth-15-6, KONOTOR_VERTICAL_PADDING+6+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0))), 15, 15)];
    if([currentMessage uploadStatus].integerValue==MessageUploaded)
        [uploadStatus setImage:sentImage];
    else
        [uploadStatus setImage:sendingImage];
#if KONOTOR_IMAGE_SUPPORT
    UIImageView* picView=(UIImageView*)[messageText viewWithTag:KONOTOR_PICTURE_TAG];
#endif
    
    UIEdgeInsets insets=UIEdgeInsetsMake(KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_INSET, KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET, KONOTOR_MESSAGE_BACKGROUND_IMAGE_BOTTOM_INSET, KONOTOR_MESSAGE_BACKGROUND_IMAGE_RIGHT_INSET);
    
    if(isSenderOther){
        [userNameField setText:@"Support"];
        [uploadStatus setImage:nil];
        [userNameField setBackgroundColor:KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR];
        [timeField setBackgroundColor:KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR];
        [messageText setBackgroundColor:KONOTOR_SUPPORTMESSAGE_BACKGROUND_COLOR];
        [messageBackground setImage:[[UIImage imageNamed:@"konotor_chatbubble_ios7_other.png"] resizableImageWithCapInsets:insets]];
        [userNameField setTextColor:KONOTOR_OTHERNAME_TEXT_COLOR];
        [messageText setTextColor:KONOTOR_OTHERMESSAGE_TEXT_COLOR];
        [timeField setTextColor:KONOTOR_OTHERTIMESTAMP_COLOR];
    }
    else{
        [userNameField setText:@"You"];
        [userNameField setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [timeField setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [messageText setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [messageBackground setImage:[[UIImage imageNamed:@"konotor_chatbubble_ios7_you.png"] resizableImageWithCapInsets:insets]];
        [userNameField setTextColor:KONOTOR_USERNAME_TEXT_COLOR];
        [messageText setTextColor:KONOTOR_USERMESSAGE_TEXT_COLOR];
        [timeField setTextColor:KONOTOR_USERTIMESTAMP_COLOR];
        [durationField setHidden:NO];
        [durationField setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [durationField setTextColor:KONOTOR_USERTIMESTAMP_COLOR];

    }
    
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:currentMessage.createdMillis.longLongValue/1000];
    [timeField setText:[KonotorConversationViewController stringRepresentationForDate:date]];
    
#if KONOTOR_MESSAGE_SHARE_SUPPORT
    UIButton* shareButton=(UIButton*)[cell.contentView viewWithTag:KONOTOR_SHAREBUTTON_TAG];
    [shareButton setFrame:CGRectMake(isSenderOther?messageTextBoxWidth+4+messageTextBoxX:4,messageTextBoxY , 36, 36)];
    if(isSenderOther)
        [shareButton setHidden:(![[KonotorUIParameters sharedInstance] messageSharingEnabled])];
    else
        [shareButton setHidden:(![[KonotorUIParameters sharedInstance] messageSharingEnabled])];
#endif
    
    if(showsProfile){
        UIImageView* profileImage=(UIImageView*)[cell.contentView viewWithTag:KONOTOR_PROFILEIMAGE_TAG];
        if(isSenderOther)
            [profileImage setImage:otherImage];
        else
            [profileImage setImage:meImage];
        [profileImage setFrame:CGRectMake(profileX, profileY, KONOTOR_PROFILEIMAGE_DIMENSION, KONOTOR_PROFILEIMAGE_DIMENSION)];
    }
    
    if([messageText respondsToSelector:@selector(setTextContainerInset:)])
        [messageText setTextContainerInset:UIEdgeInsetsMake(6, 0, 8, 0)];

    if([currentMessage messageType].integerValue==KonotorMessageTypeText)
    {
        [playButton.mediaProgressBar setHidden:YES];
        [playButton setHidden:YES];
        
        CGSize txtSize =[timeField.text sizeWithAttributes:
                         @{NSFontAttributeName:
                               [UIFont fontWithName:@"HelveticaNeue" size:11]}];
        
        [timeField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING), txtSize.width + 16, KONOTOR_TIMEFIELD_HEIGHT+4)];
        // timeField.contentInset=UIEdgeInsetsMake(-4, 0,0,0);
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        
        if([timeField respondsToSelector:@selector(textContainerInset)])
            timeField.textContainerInset=UIEdgeInsetsMake(4, 0, 0, 0);
        else
#endif
            [timeField setContentOffset:CGPointMake(0, 4)];
        
        [durationField setHidden:YES];
        
        [messageText setText:nil];
        [messageText setDataDetectorTypes:UIDataDetectorTypeNone];
        [messageText setText:currentMessage.text];
        [messageText setDataDetectorTypes:UIDataDetectorTypeLink];
        
        CGRect txtMsgFrame=messageText.frame;
        
        txtMsgFrame.origin.x=messageTextBoxX;
        txtMsgFrame.origin.y=messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.size.width=messageTextBoxWidth;
//        CGSize sizer=[messageText sizeThatFits:CGSizeMake(messageTextBoxWidth, 1000)];
        CGSize sizer = [self getSizeOfTextViewWidth:messageTextBoxWidth text:currentMessage.text withFont:KONOTOR_MESSAGETEXT_FONT];
        
        txtMsgFrame.size.height=sizer.height;
        
        messageText.frame=txtMsgFrame;

        txtMsgFrame.size.height=sizer.height+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0)+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)));
        txtMsgFrame.origin.y=messageText.frame.origin.y-KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING;
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;
#if KONOTOR_IMAGE_SUPPORT
        [picView setHidden:YES];
#endif
        
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypeAudio){
        [messageText setText:@""];
        
        [timeField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?(KONOTOR_USERNAMEFIELD_HEIGHT+KONOTOR_AUDIOMESSAGE_HEIGHT):KONOTOR_VERTICAL_PADDING), messageTextBoxWidth, KONOTOR_TIMEFIELD_HEIGHT)];
        // timeField.contentInset=UIEdgeInsetsMake(-10, 0, 0,0);
        if((KONOTOR_SHOW_TIMESTAMP)&&(KONOTOR_SHOW_SENDERNAME))
        {
#if(__IPHONE_OS_VERSION_MAX_ALLOWED >=70000)
            
            if([timeField respondsToSelector:@selector(textContainerInset)])
                [timeField setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            else
#endif
                [timeField setContentOffset:CGPointMake(0, 10)];
        }
        else{
#if(__IPHONE_OS_VERSION_MAX_ALLOWED >=70000)
            
            if([timeField respondsToSelector:@selector(textContainerInset)])
                [timeField setTextContainerInset:UIEdgeInsetsMake(4, 0, 0, 0)];
            else
#endif
                [timeField setContentOffset:CGPointMake(0, 4)];
        }
        
        if(KONOTOR_SHOW_DURATION){
            [durationField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?(KONOTOR_USERNAMEFIELD_HEIGHT+KONOTOR_AUDIOMESSAGE_HEIGHT):KONOTOR_VERTICAL_PADDING), messageTextBoxWidth-KONOTOR_HORIZONTAL_PADDING, KONOTOR_TIMEFIELD_HEIGHT)];
            if((KONOTOR_SHOW_TIMESTAMP)&&(KONOTOR_SHOW_SENDERNAME))
            {
#if(__IPHONE_OS_VERSION_MAX_ALLOWED >=70000)
                
                if([durationField respondsToSelector:@selector(textContainerInset)])
                    [durationField setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                else
#endif
                    [durationField setContentOffset:CGPointMake(0, 10)];
            }
            else{
#if(__IPHONE_OS_VERSION_MAX_ALLOWED >=70000)
                
                if([durationField respondsToSelector:@selector(textContainerInset)])
                    [durationField setTextContainerInset:UIEdgeInsetsMake(4, 0, 0, 0)];
                else
#endif
                    [durationField setContentOffset:CGPointMake(0, 4)];
                
            }
            
            if(isSenderOther)
                [durationField setHidden:YES];
            else{
                [durationField setHidden:NO];
                [durationField setText:[NSString stringWithFormat:@"%@ secs",[currentMessage durationInSecs]]];
            }
        }
        
        CGRect txtMsgFrame=messageText.frame;
        txtMsgFrame.size.height=KONOTOR_AUDIOMESSAGE_HEIGHT;
        txtMsgFrame.origin.x=messageTextBoxX;
        txtMsgFrame.origin.y=messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:(KONOTOR_SHOW_TIMESTAMP?(KONOTOR_TIMEFIELD_HEIGHT+KONOTOR_VERTICAL_PADDING):KONOTOR_VERTICAL_PADDING));
        txtMsgFrame.size.width=messageTextBoxWidth;
        messageText.frame=txtMsgFrame;
        
        txtMsgFrame.size.height=KONOTOR_AUDIOMESSAGE_HEIGHT+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?KONOTOR_VERTICAL_PADDING:0));
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;
        
        [playButton.mediaProgressBar setHidden:NO];
        [playButton setHidden:NO];
        
        playButton.messageID=[currentMessage messageId];
        playButton.message=currentMessage;
        
        [playButton.mediaProgressBar setValue:0.0 animated:NO];
        [playButton.mediaProgressBar setMaximumValue:currentMessage.durationInSecs.floatValue];
        if([[Konotor getCurrentPlayingMessageID] isEqualToString:[currentMessage messageId]])
            [playButton startAnimating];
#if KONOTOR_IMAGE_SUPPORT
        [picView setHidden:YES];
#endif
        
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypePicture){
        if((![currentMessage picData])&&(([[currentMessage picUrl] isEqualToString:@""])|| ([currentMessage picUrl]==nil)))
            [messageText setText:@"Image Not Found"];
        else
            [messageText setText:@""];
        
        float height=MIN([[currentMessage picThumbHeight] floatValue],KONOTOR_IMAGE_MAXHEIGHT);
        float imgwidth=[[currentMessage picThumbWidth] floatValue];
        if(height!=[[currentMessage picThumbHeight] floatValue]){
            imgwidth=[[currentMessage picThumbWidth] floatValue]*(height/[[currentMessage picThumbHeight] floatValue]);
        }
        if(imgwidth>KONOTOR_IMAGE_MAXWIDTH)
        {
            imgwidth=KONOTOR_IMAGE_MAXWIDTH;
            height=[[currentMessage picThumbHeight] floatValue]*(imgwidth/[[currentMessage picThumbWidth] floatValue]);
        }

        [timeField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING), messageTextBoxWidth, KONOTOR_TIMEFIELD_HEIGHT+4)];
        // timeField.contentInset=UIEdgeInsetsMake(-4, 0,0,0);
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        
        if([timeField respondsToSelector:@selector(textContainerInset)])
            timeField.textContainerInset=UIEdgeInsetsMake(4, 0, 0, 0);
        else
#endif
            [timeField setContentOffset:CGPointMake(0, 4)];
        float txtheight=0.0;
        
#if KONOTOR_ENABLECAPTIONS
        
        if((currentMessage.picCaption)&&(![currentMessage.picCaption isEqualToString:@""])){
            NSString *htmlString = currentMessage.picCaption;
            NSDictionary* fontDict=[[NSDictionary alloc] initWithObjectsAndKeys:messageText.font,NSFontAttributeName,nil];
            NSMutableAttributedString* attributedString=nil;
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                attributedString=[[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            }
            else{
                attributedString=[[NSMutableAttributedString alloc] initWithString:htmlString];
            }
            [attributedString addAttributes:fontDict range:NSMakeRange(0, [attributedString length])];
            if(isSenderOther){
                [attributedString addAttribute:NSForegroundColorAttributeName value:KONOTOR_OTHERMESSAGE_TEXT_COLOR range:NSMakeRange(0, [attributedString length])];
            }
            else{
                [attributedString addAttribute:NSForegroundColorAttributeName value:KONOTOR_USERMESSAGE_TEXT_COLOR range:NSMakeRange(0, [attributedString length])];
            }

            if([messageText respondsToSelector:@selector(setAttributedText:)])
                messageText.attributedText = attributedString;
            else
                [messageText setText:[attributedString string]];
            
            txtheight=[messageText sizeThatFits:CGSizeMake(messageTextBoxWidth, 1000)].height-16;
            
            if([messageText respondsToSelector:@selector(setTextContainerInset:)]){
                [messageText setTextContainerInset:UIEdgeInsetsMake(height+10, 0, 0, 0)];
            }
            
        }
        
#endif
        
        CGRect txtMsgFrame=messageText.frame;
        txtMsgFrame.size.height=16+height+txtheight;
        txtMsgFrame.origin.x=messageTextBoxX;
        txtMsgFrame.origin.y=messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.size.width=messageTextBoxWidth;
        messageText.frame=txtMsgFrame;
        
        txtMsgFrame.size.height=16+height+txtheight+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?KONOTOR_VERTICAL_PADDING:0));
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;
        
        [playButton.mediaProgressBar setHidden:YES];
        [playButton setHidden:YES];
#if KONOTOR_IMAGE_SUPPORT
        [picView setHidden:NO];
        if([currentMessage picThumbData]){
            UIImage *picture=[UIImage imageWithData:[currentMessage picThumbData]];
        if(KONOTOR_ENABLECAPTIONS&&!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            [picView setFrame:CGRectMake((KONOTOR_TEXTMESSAGE_MAXWIDTH-imgwidth)/2-KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET/2, 8+txtheight-2, imgwidth, height)];
        else
             [picView setFrame:CGRectMake((KONOTOR_TEXTMESSAGE_MAXWIDTH-imgwidth)/2-KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET/2, 8, imgwidth, height)];
            [picView setImage:picture];
        }
        else{
            if(height>100)
                [picView setFrame:CGRectMake((KONOTOR_TEXTMESSAGE_MAXWIDTH-110)/2-KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET/2, (height-100)/2, 110, 100)];
            else{
                [picView setFrame:CGRectMake((KONOTOR_TEXTMESSAGE_MAXWIDTH-height*110/100)/2-KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET/2, 8, height*110/100, height)];
            }
            [picView setImage:[UIImage imageNamed:@"konotor_placeholder"]];

            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                /* Fetch the image from the server... */
                NSData *thumbData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[currentMessage picThumbUrl]]];
                [Konotor setBinaryImageThumbnail:thumbData forMessageId:[currentMessage messageId]];
                UIImage *img = [[UIImage alloc] initWithData:thumbData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* This is the main thread again, where we set the image to
                     be what we just fetched. */
                    [picView setFrame:CGRectMake((KONOTOR_TEXTMESSAGE_MAXWIDTH-imgwidth)/2-KONOTOR_MESSAGE_BACKGROUND_IMAGE_LEFT_INSET/2, 8, imgwidth, height)];
                    [picView setImage:img];
                });
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[currentMessage picUrl]]];
                [Konotor setBinaryImage:data forMessageId:[currentMessage messageId]];
                
            });
        }
        picView.layer.cornerRadius=10.0;
        picView.layer.masksToBounds=YES;
        picView.tag=KONOTOR_PICTURE_TAG;
        TapOnPictureRecognizer* tapGesture=[[TapOnPictureRecognizer alloc] initWithTarget:self action:@selector(tappedOnPicture:)];
        tapGesture.numberOfTapsRequired=1;
        if([currentMessage picData])
            tapGesture.image=picView.image;
        else{
            tapGesture.imageURL=[NSURL URLWithString:[currentMessage picUrl]];
            tapGesture.image=nil;
        }
        tapGesture.height=[[currentMessage picHeight] floatValue];
        tapGesture.width=[[currentMessage picWidth] floatValue];
        picView.userInteractionEnabled=YES;
        [picView addGestureRecognizer:tapGesture];
#endif
        
        
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypeHTML)
    {
        [playButton.mediaProgressBar setHidden:YES];
        [playButton setHidden:YES];
        
        [timeField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING), messageTextBoxWidth, KONOTOR_TIMEFIELD_HEIGHT+4)];
        // timeField.contentInset=UIEdgeInsetsMake(-4, 0,0,0);
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        
        if([timeField respondsToSelector:@selector(textContainerInset)])
            timeField.textContainerInset=UIEdgeInsetsMake(4, 0, 0, 0);
        else
#endif
            [timeField setContentOffset:CGPointMake(0, 4)];
        
        [durationField setHidden:YES];
        
        NSString *htmlString = currentMessage.text;
        NSDictionary* fontDict=[[NSDictionary alloc] initWithObjectsAndKeys:messageText.font,NSFontAttributeName,nil];
        NSMutableAttributedString* attributedString=nil;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            attributedString=[[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        }
        else{
            attributedString=[[NSMutableAttributedString alloc] initWithString:htmlString];
        }
        [attributedString addAttributes:fontDict range:NSMakeRange(0, [attributedString length])];
        
        if([messageText respondsToSelector:@selector(setAttributedText:)])
            messageText.attributedText = attributedString;
        else
            [messageText setText:[attributedString string]];
        
        CGRect txtMsgFrame=messageText.frame;
        
        txtMsgFrame.origin.x=messageTextBoxX;
        txtMsgFrame.origin.y=messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.size.width=messageTextBoxWidth;
        CGSize sizer=[messageText sizeThatFits:CGSizeMake(messageTextBoxWidth, 1000)];
        txtMsgFrame.size.height=sizer.height;
        
        messageText.frame=txtMsgFrame;
        
        txtMsgFrame.size.height=sizer.height+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0)+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)));
        txtMsgFrame.origin.y=messageText.frame.origin.y-KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING;
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;
#if KONOTOR_IMAGE_SUPPORT
        [picView setHidden:YES];
#endif
        
    }

    else
    {
        [playButton.mediaProgressBar setHidden:YES];
        [playButton setHidden:YES];
#if KONOTOR_IMAGE_SUPPORT
        [picView setHidden:YES];
#endif
        [timeField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING), messageTextBoxWidth, KONOTOR_TIMEFIELD_HEIGHT+4)];
        // timeField.contentInset=UIEdgeInsetsMake(-4, 0,0,0);
#if(__IPHONE_OS_VERSION_MAX_ALLOWED>=70000)
        
        if([timeField respondsToSelector:@selector(textContainerInset)])
            timeField.textContainerInset=UIEdgeInsetsMake(4, 0, 0, 0);
        else
#endif
            [timeField setContentOffset:CGPointMake(0, 4)];
        
        [durationField setHidden:YES];
        
        if(([currentMessage text]!=nil)&&(![[currentMessage text] isEqualToString:@""]))
            [messageText setText:currentMessage.text];
        else
            [messageText setText:@"Message cannot be displayed. Please upgrade your app to view this message."];
        
        CGRect txtMsgFrame=messageText.frame;
        
        txtMsgFrame.origin.x=messageTextBoxX;
        txtMsgFrame.origin.y=messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.size.width=messageTextBoxWidth;
        CGSize sizer=[messageText sizeThatFits:CGSizeMake(messageTextBoxWidth, 1000)];
        txtMsgFrame.size.height=sizer.height;
        
        messageText.frame=txtMsgFrame;
        
        txtMsgFrame.size.height=sizer.height+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0)+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)));
        txtMsgFrame.origin.y=messageText.frame.origin.y-KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING;
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;
        
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.contentView setClipsToBounds:YES];
    cell.tag=[currentMessage.messageId hash];
    
    return cell;
    
}

- (void) tappedOnPicture:(id) sender
{
    TapOnPictureRecognizer* picView=(TapOnPictureRecognizer*)sender;
    fullImageView=[[KonotorImageView alloc] init];
    fullImageView.img=picView.image;
    fullImageView.imgHeight=picView.height;
    fullImageView.imgWidth=picView.width;
    fullImageView.imgURL=picView.imageURL;
    fullImageView.sourceViewController=self;
    [fullImageView showImageView];
    
}

- (void) dismissImageView{
    [fullImageView removeFromSuperview];
    fullImageView=nil;
}

 - (void) viewWillAppear:(BOOL)animated
{
    
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height-20), 0.0);
    } else {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.width-20), 0.0);
    }
    
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    
    int lastSpot=loading?numberOfMessagesShown:(numberOfMessagesShown-1);
    if(lastSpot<0) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:lastSpot inSection:0];
    
    @try {
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception ) {
        indexPath=[NSIndexPath indexPathForRow:(indexPath.row-1) inSection:0];
        @try{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        @catch(NSException *exception){
            
        }
    }
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    /*   CGRect aRect = self.view.frame;
     aRect.size.height -= kbSize.height;
     if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
     [self.messagesView.tableView scrollRectToVisible:activeField.frame animated:YES];
     }*/
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    int lastSpot=loading?numberOfMessagesShown:(numberOfMessagesShown-1);
    if(lastSpot<0) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:lastSpot inSection:0];
    @try {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception ) {
        indexPath=[NSIndexPath indexPathForRow:(indexPath.row-1) inSection:0];
        @try{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        @catch(NSException *exception){
            
        }

    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==numberOfMessagesShown)
        return 40;
    else if((indexPath.row==0)&&(numberOfMessagesShown<messageCount))
        return 40;

    KonotorMessageData* currentMessage=(KonotorMessageData*)[messages objectAtIndex:(messageCount-numberOfMessagesShown+indexPath.row)];
    BOOL isSenderOther;
    isSenderOther=[Konotor isUserMe:[currentMessage messageUserId]];
    
    float width=MIN((KONOTOR_SHOWPROFILEIMAGE)?(self.view.frame.size.width-KONOTOR_PROFILEIMAGE_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING):(self.view.frame.size.width-8*KONOTOR_HORIZONTAL_PADDING-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING),KONOTOR_TEXTMESSAGE_MAXWIDTH-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING);
    
    if([messageHeights valueForKey:currentMessage.messageId]!=nil)
    {
        return [(NSNumber*)[messageHeights valueForKey:currentMessage.messageId] floatValue];
    }
    
    if([currentMessage messageType].integerValue==KonotorMessageTypeText){
        UITextView* txtView=[[UITextView alloc] init];
        [txtView setFont:KONOTOR_MESSAGETEXT_FONT];
        [txtView setText:[currentMessage text]];
        float height=0.0;
        height=[txtView sizeThatFits:CGSizeMake(width, 1000)].height-16;
        if(KONOTOR_SHOWPROFILEIMAGE){
            float cellHeight= MAX(height+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)))+KONOTOR_VERTICAL_PADDING+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0),KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2;
            [messageHeights setValue:[NSNumber numberWithFloat:cellHeight]  forKey:currentMessage.messageId];
            return cellHeight;
        }
        else{
            float cellHeight= height+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)))+KONOTOR_VERTICAL_PADDING*2+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
            [messageHeights setValue:[NSNumber numberWithFloat:cellHeight]  forKey:currentMessage.messageId];
            return cellHeight;
        }
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypeAudio){
        float cellHeight= KONOTOR_AUDIOMESSAGE_HEIGHT+(KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)+KONOTOR_VERTICAL_PADDING+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?0:KONOTOR_VERTICAL_PADDING))+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?KONOTOR_VERTICAL_PADDING:0));
        [messageHeights setValue:[NSNumber numberWithFloat:cellHeight]  forKey:currentMessage.messageId];
        return cellHeight;
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypePicture){
        float height=MIN([[currentMessage picThumbHeight] floatValue], KONOTOR_IMAGE_MAXHEIGHT);
        float imgwidth=[[currentMessage picThumbWidth] floatValue];
        if(height!=[[currentMessage picThumbHeight] floatValue]){
            imgwidth=[[currentMessage picThumbWidth] floatValue]*(height/[[currentMessage picThumbHeight] floatValue]);
        }
        if(imgwidth>KONOTOR_IMAGE_MAXWIDTH)
        {
            imgwidth=KONOTOR_IMAGE_MAXWIDTH;
            height=[[currentMessage picThumbHeight] floatValue]*(imgwidth/[[currentMessage picThumbWidth] floatValue]);
        }
        
        float txtheight=0.0;
        
#if KONOTOR_ENABLECAPTIONS
        
        if((currentMessage.picCaption)&&(![currentMessage.picCaption isEqualToString:@""])){
            NSString *htmlString = currentMessage.picCaption;
            NSDictionary* fontDict=[[NSDictionary alloc] initWithObjectsAndKeys:KONOTOR_MESSAGETEXT_FONT,NSFontAttributeName,nil];
            NSMutableAttributedString* attributedString=nil;
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")){
                attributedString=[[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            }
            else{
                attributedString=[[NSMutableAttributedString alloc] initWithString:htmlString];
            }

            [attributedString addAttributes:fontDict range:NSMakeRange(0, [attributedString length])];
            

            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
                txtheight=[attributedString boundingRectWithSize:CGSizeMake(width, 1000) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.height;
                
            }
            else{
                UITextView* txtView=[[UITextView alloc] init];
                [txtView setFont:KONOTOR_MESSAGETEXT_FONT];
                [txtView setText:[attributedString string]];
                txtheight=[txtView sizeThatFits:CGSizeMake(width, 1000)].height-16;
            }
        }
#endif
        
        float cellHeight= 16+txtheight+height+(KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?0:KONOTOR_VERTICAL_PADDING))+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?KONOTOR_VERTICAL_PADDING:0));
        [messageHeights setValue:[NSNumber numberWithFloat:cellHeight]  forKey:currentMessage.messageId];
        return cellHeight;
        
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypeHTML){
        UITextView* txtView=[[UITextView alloc] init];
        [txtView setFont:KONOTOR_MESSAGETEXT_FONT];
        NSString *htmlString = currentMessage.text;
        NSDictionary* fontDict=[[NSDictionary alloc] initWithObjectsAndKeys:txtView.font,NSFontAttributeName,nil];
        NSMutableAttributedString* attributedString=nil;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
            attributedString=[[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        }
        else{
            attributedString=[[NSMutableAttributedString alloc] initWithString:htmlString];
        }

        [attributedString addAttributes:fontDict range:NSMakeRange(0, [attributedString length])];
        
        if([txtView respondsToSelector:@selector(setAttributedText:)])
            txtView.attributedText = attributedString;
        else
            [txtView setText:[attributedString string]];
        
        float height=0.0;
        height=[txtView sizeThatFits:CGSizeMake(width, 1000)].height-16;
        if(KONOTOR_SHOWPROFILEIMAGE){
            float cellHeight= MAX(height+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)))+KONOTOR_VERTICAL_PADDING+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0),KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2;
            [messageHeights setValue:[NSNumber numberWithFloat:cellHeight]  forKey:currentMessage.messageId];
            return cellHeight;
        }
        else{
            float cellHeight= height+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)))+KONOTOR_VERTICAL_PADDING*2+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
            [messageHeights setValue:[NSNumber numberWithFloat:cellHeight]  forKey:currentMessage.messageId];
            return cellHeight;
        }
    }
    else
    {
        UITextView* txtView=[[UITextView alloc] init];
        [txtView setFont:KONOTOR_MESSAGETEXT_FONT];
        if(([currentMessage text]!=nil)&&(![[currentMessage text] isEqualToString:@""]))
            [txtView setText:[currentMessage text]];
        else
            [txtView setText:@"Message cannot be displayed. Please upgrade your app to view this message."];
        float height=0.0;//[[currentMessage text] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(width-16, 1000)].height;
        height=[txtView sizeThatFits:CGSizeMake(width, 1000)].height-16;
        if(KONOTOR_SHOWPROFILEIMAGE)
            return MAX(height+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)))+KONOTOR_VERTICAL_PADDING+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0),KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2;
        else
            return height+(isSenderOther?((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_OTHER?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)):((KONOTOR_MESSAGE_BACKGROUND_TOP_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)))+KONOTOR_VERTICAL_PADDING*2+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
    }
}

/* get size of TextView with Text*/

-(CGSize)getSizeOfTextViewWidth:(CGFloat)width text:(NSString *)text withFont:(UIFont *)font
{
    UITextView* txtView=[[UITextView alloc] init];
    [txtView setFont:font];
    [txtView setText:text];
    CGSize size=[txtView sizeThatFits:CGSizeMake(width, 1000)];
    return size;
}

-(CGFloat)getTextViewLineHeight:(CGFloat)width text:(NSString *)text withFont:(UIFont *)font
{
    UITextView* txtView=[[UITextView alloc] init];
    [txtView setFont:font];
    [txtView setText:text];
    return txtView.font.lineHeight;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Konotor playMessageWithMessageID:[(KonotorMessageData*)[messages objectAtIndex:indexPath.row] messageId]];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) refreshView
{
    [self.tableView reloadData];
    [Konotor MarkAllMessagesAsRead];
    
    int lastSpot=loading?numberOfMessagesShown:(numberOfMessagesShown-1);
    if(lastSpot<0) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:lastSpot inSection:0];
    @try {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    @catch (NSException *exception ) {
        indexPath=[NSIndexPath indexPathForRow:(indexPath.row-1) inSection:0];
        @try{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        @catch(NSException *exception){
            
        }

    }
}

- (void) refreshView:(id) spot
{
    [self.tableView reloadData];
    [Konotor MarkAllMessagesAsRead];
    
    int lastSpot=loading?(numberOfMessagesShown-((NSNumber*)spot).intValue):((numberOfMessagesShown-((NSNumber*)spot).intValue));
    if(lastSpot<0) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:lastSpot inSection:0];
    @try {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    @catch (NSException *exception ) {
        indexPath=[NSIndexPath indexPathForRow:(indexPath.row-1) inSection:0];
        @try{
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        @catch(NSException *exception){
            
        }
        
    }
}



- (void) didFinishDownloadingMessages
{
    /*  Commented section to test if downloading messages was successful and message counts have been updated
     int count=[[Konotor getAllMessagesForDefaultConversation] count];
     NSString* messagesDownloadedAlertText=[NSString stringWithFormat:@"%d messages in this conversation", count];
     UIAlertView* konotorAlert=[[UIAlertView alloc] initWithTitle:@"Finished loading messages" message:messagesDownloadedAlertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
     [konotorAlert show];
     */
    loading=NO;
    [self refreshView];
}

- (void) didFinishUploading:(NSString *)messageID
{
    for(UITableViewCell* cell in [self.tableView visibleCells]){
        if([messageID hash]==cell.tag)
        {
            UIImageView* uploadStatus=(UIImageView*)[cell.contentView viewWithTag:KONOTOR_UPLOADSTATUS_TAG];
            [uploadStatus setImage:sentImage];
            for(int i=messageCount-1;i>=0;i--){
                if([(NSString*)[(KonotorMessageData*)[messages objectAtIndex:i] messageId] isEqualToString:messageID])
                {
                    [(KonotorMessageData*)[messages objectAtIndex:i] setUploadStatus:([NSNumber numberWithInt:MessageUploaded])];
                    break;
                }
            }
        }
    }
}

-(void) didEncounterErrorWhileDownloadingConversations
{
    loading=NO;
    [self refreshView];
    
}

- (void) didEncounterErrorWhileDownloading:(NSString *)messageID
{
    //Show Toast
}

- (void) didEncounterErrorWhileUploading:(NSString *)messageID
{
    if(!showingAlert){
        UIAlertView* konotorAlert=[[UIAlertView alloc] initWithTitle:@"Message not sent" message:@"We could not send your message(s) at this time. Check your internet or try later." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [konotorAlert show];
        showingAlert=YES;
    }
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
#if KONOTOR_MESSAGE_SHARE_SUPPORT
    if(alertView.tag==KONOTOR_SHARE_ALERT_TAG){
        if(buttonIndex==1){
            if([MFMailComposeViewController canSendMail]){
                [mailComposer setSubject:@"Sharing a message with you"];
                [mailComposer setMessageBody:copiedText isHTML:NO];
                if(copiedContent){
                    if(copiedMessageType==KonotorMessageTypePicture)
                        [mailComposer addAttachmentData:copiedContent mimeType:copiedMimeType fileName:@"sharedImage.jpg"];
                    else{
                        [mailComposer addAttachmentData:copiedContent mimeType:copiedMimeType fileName:@"sharedAudio.mp4"];
                    }
                }
                
                [[[KonotorFeedbackScreen sharedInstance] conversationViewController]
                 presentViewController:mailComposer animated:NO completion:nil];
            }
            else{
                UIAlertView *errorAlert=[[UIAlertView alloc] initWithTitle:@"Can't send email" message:@"Sorry! Your device is not configured to send email." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
                [errorAlert show];
            }
        }
    }
    else{
#endif
        showingAlert=NO;
#if KONOTOR_MESSAGE_SHARE_SUPPORT
    }
#endif
    
}

- (void) didStartPlaying:(NSString *)messageID
{
    for(UITableViewCell* cell in [self.tableView visibleCells]){
        KonotorMediaUIButton* button=(KonotorMediaUIButton*)[cell viewWithTag:KONOTOR_PLAYBUTTON_TAG];
        if([button.messageID isEqualToString:messageID])
        {
            [button startAnimating];
        }
    }
}

- (void) didFinishPlaying:(NSString *)messageID
{
    for(UITableViewCell* cell in [self.tableView visibleCells]){
        KonotorMediaUIButton* button=(KonotorMediaUIButton*)[cell viewWithTag:KONOTOR_PLAYBUTTON_TAG];
        if([button.messageID isEqualToString:messageID])
        {
            [button stopAnimating];
        }
    }
    
}

-(BOOL) handleRemoteNotification:(NSDictionary*)userInfo
{
    if(!([(NSString*)[userInfo valueForKey:@"source"] isEqualToString:@"konotor"]))
        return NO;
    loading=YES;
    [Konotor DownloadAllMessages];
    
    [self.tableView reloadData];
    
    return YES;
}

-(BOOL) handleRemoteNotification:(NSDictionary*)userInfo withShowScreen:(BOOL)showScreen
{
    return [self handleRemoteNotification:userInfo];
}

- (void) playMedia:(id) sender
{
    KonotorMediaUIButton* playButton=(KonotorMediaUIButton*) sender;
    if(playButton.buttonState==KonotorMediaUIButtonStatePlaying){
        [Konotor StopPlayback];
        [self didFinishPlaying:playButton.messageID];
    }
    else{
        [Konotor playMessageWithMessageID:playButton.messageID];
    }
}



+ (NSString*) stringRepresentationForDate:(NSDate*) date
{
    NSString* timeString;
    
#if KONOTOR_SMART_TIMESTAMP
    NSArray* weekdays=[NSArray arrayWithObjects:@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",nil];
    
    NSDate* today=[[NSDate alloc] init];
    
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0)
    NSCalendar* calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp=[calendar components:(NSWeekdayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDateComponents* comp2=[calendar components:(NSWeekdayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:today];
    
    NSDate* date2=[calendar dateFromComponents:comp];
    NSDate* today2=[calendar dateFromComponents:comp2];
    
    NSDateComponents* comp3=[calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date2 toDate:today2 options:0];
    
#else
    NSCalendar* calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* comp=[calendar components:(NSCalendarUnitWeekday|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDateComponents* comp2=[calendar components:(NSCalendarUnitWeekday|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:today];
    
    NSDate* date2=[calendar dateFromComponents:comp];
    NSDate* today2=[calendar dateFromComponents:comp2];
    
    NSDateComponents* comp3=[calendar components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date2 toDate:today2 options:0];

#endif
    int days=(int)comp3.year*36+(int)comp3.month*30+(int)comp3.day;
    if([comp isEqual:comp2]){
        timeString=[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }
    else{
        if(days>7){
#endif
            timeString=[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
#if KONOTOR_SMART_TIMESTAMP
        }
        else if(days==1)
            timeString=[NSString stringWithFormat:@"Yesterday %@",[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
        else if(days>1)
            timeString=[NSString stringWithFormat:@"%@ %@",[weekdays objectAtIndex:(comp.weekday-1)],[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle]];
    }
#endif
    return timeString;
    
}

#if KONOTOR_MESSAGE_SHARE_SUPPORT
-(void) showMessageActions:(id) sender
{
    UIAlertView* alertdlg=[[UIAlertView alloc] initWithTitle:@"Share" message:@"Share this message via " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Email", nil];
    alertdlg.tag=KONOTOR_SHARE_ALERT_TAG;
    copiedMessageId=[(KonotorShareButton*)sender messageId];
    copiedText=[(UITextView*)[[sender superview] viewWithTag:KONOTOR_MESSAGETEXTVIEW_TAG] text];
    copiedContent=nil;
    copiedMimeType=nil;
    copiedMessageType=KonotorMessageTypeText;
    UIImageView* img=(UIImageView*)[[sender superview] viewWithTag:KONOTOR_PICTURE_TAG];
    if(![img isHidden]){
        copiedContent=UIImageJPEGRepresentation([img image], 0.85);
        copiedMimeType=@"image/jpeg";
        copiedMessageType=KonotorMessageTypePicture;
    }
    
    KonotorMediaUIButton* playButton=(KonotorMediaUIButton*)[[sender superview] viewWithTag:KONOTOR_PLAYBUTTON_TAG];
    if(![playButton isHidden]){
        copiedText=@"Sharing voice message.";
        copiedContent=playButton.message.audioData;
        copiedMimeType=@"audio/mp4";
    }
    [alertdlg show];
}
#endif

#if KONOTOR_MESSAGE_SHARE_SUPPORT

-(void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    mailComposer=nil;
    mailComposer=[[MFMailComposeViewController alloc] init];
    [mailComposer setMailComposeDelegate:self];
    if(result==MFMailComposeResultSent){
        [Konotor shareEventWithMessageID:copiedMessageId shareType:[NSString stringWithFormat:@"%d",copiedMessageType]];
    }

}
#endif


@end
