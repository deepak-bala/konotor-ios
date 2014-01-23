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

UIImage* meImage=nil,*otherImage=nil,*sendingImage=nil,*sentImage=nil;

@implementation KonotorConversationViewController

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
        
    messages=[Konotor getAllMessagesForDefaultConversation];
    
    loading=YES;
    if(![Konotor areConversationsDownloading])
        [Konotor DownloadAllMessages];
    
    if(KONOTOR_SHOWPROFILEIMAGE){
        meImage=[UIImage imageNamed:@"konotor_profile.png"];
        otherImage=[UIImage imageNamed:@"konotor_supportprofile.png"];
    }
    sendingImage=[UIImage imageNamed:@"konotor_uploading.png"];
    sentImage=[UIImage imageNamed:@"konotor_sent.png"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  //   [self.tableView scrollRectToVisible:CGRectMake(0,self.tableView.contentSize.height-50, 2, 50) animated:YES];
    [Konotor MarkAllMessagesAsRead];

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
    messageCount=[messages count];
    if(!loading)
        return messageCount;
    else
        return messageCount+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if((loading)&&(indexPath.row==messageCount))
    {
        static NSString *CellIdentifier = @"KonotorRefreshCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        UIActivityIndicatorView* refreshIndicator=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [refreshIndicator setFrame:CGRectMake(self.view.frame.size.width/2-10, cell.contentView.frame.size.height/2-10, 20, 20)];
        refreshIndicator.tag=KONOTOR_REFRESHINDICATOR_TAG;
        [cell.contentView addSubview:refreshIndicator];
        [refreshIndicator startAnimating];

        return cell;
        
    }
    else if(indexPath.row==messageCount){
        static NSString *CellIdentifier = @"KonotorBlankCell";

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    KonotorMessageData* currentMessage=(KonotorMessageData*)[messages objectAtIndex:indexPath.row];
    
    BOOL showsProfile=KONOTOR_SHOWPROFILEIMAGE;
    BOOL isSenderOther=([Konotor isUserMe:currentMessage.messageUserId])?NO:YES;
    float profileX=0.0, profileY=0.0, messageContentViewX=0.0, messageContentViewY=0.0, messageTextBoxX=0.0, messageTextBoxY=0.0,messageContentViewWidth=0.0,messageTextBoxWidth=0.0;
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
        messageContentViewWidth=MIN(messageDisplayWidth-8*KONOTOR_HORIZONTAL_PADDING,KONOTOR_TEXTMESSAGE_MAXWIDTH);
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
        
        
        UITextView* messageText=[[UITextView alloc] initWithFrame:CGRectMake((KONOTOR_SHOWPROFILEIMAGE?1:0)*(KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_HORIZONTAL_PADDING)+KONOTOR_HORIZONTAL_PADDING, KONOTOR_VERTICAL_PADDING+KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING, self.view.frame.size.width-(KONOTOR_SHOWPROFILEIMAGE?1:0)*(KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_HORIZONTAL_PADDING)-30, 10)];
        [messageText setFont:KONOTOR_MESSAGETEXT_FONT];
        [messageText setBackgroundColor:KONOTOR_MESSAGE_BACKGROUND_COLOR];
        [messageText setDataDetectorTypes:UIDataDetectorTypeAll];
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
        
        UIImageView* uploadStatus=[[UIImageView alloc] initWithFrame:CGRectMake(messageTextBoxX+messageTextBoxWidth-15-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING, KONOTOR_VERTICAL_PADDING+6, 15, 15)];
        [uploadStatus setImage:sentImage];
        uploadStatus.tag=KONOTOR_UPLOADSTATUS_TAG;
        if(KONOTOR_SHOW_UPLOADSTATUS)
            [cell.contentView addSubview:uploadStatus];
        
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
    
    [userNameField setFrame:CGRectMake(messageTextBoxX, messageTextBoxY, messageTextBoxWidth, KONOTOR_USERNAMEFIELD_HEIGHT)];
    
    UIImageView* uploadStatus=(UIImageView*)[cell.contentView viewWithTag:KONOTOR_UPLOADSTATUS_TAG];
    [uploadStatus setFrame:CGRectMake(messageTextBoxX+messageTextBoxWidth-15-6, KONOTOR_VERTICAL_PADDING+6, 15, 15)];
    if([currentMessage uploadStatus].integerValue==MessageUploaded)
       [uploadStatus setImage:sentImage];
    else
       [uploadStatus setImage:sendingImage];
    
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
    }
    
    NSDate* date=[NSDate dateWithTimeIntervalSince1970:currentMessage.createdMillis.longLongValue/1000];
    [timeField setText:[KonotorConversationViewController stringRepresentationForDate:date]];
    
    if(showsProfile){
        UIImageView* profileImage=(UIImageView*)[cell.contentView viewWithTag:KONOTOR_PROFILEIMAGE_TAG];
        if(isSenderOther)
           [profileImage setImage:otherImage];
        else
            [profileImage setImage:meImage];
        [profileImage setFrame:CGRectMake(profileX, profileY, KONOTOR_PROFILEIMAGE_DIMENSION, KONOTOR_PROFILEIMAGE_DIMENSION)];
    }
    
    
    if([currentMessage messageType].integerValue==KonotorMessageTypeText)
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
        
        [messageText setText:currentMessage.text];
        
        CGRect txtMsgFrame=messageText.frame;
       
        txtMsgFrame.origin.x=messageTextBoxX;
        txtMsgFrame.origin.y=messageTextBoxY+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.size.width=messageTextBoxWidth;
        CGSize sizer=[messageText sizeThatFits:CGSizeMake(messageTextBoxWidth, 1000)];
        txtMsgFrame.size.height=sizer.height;
        
        messageText.frame=txtMsgFrame;

        txtMsgFrame.size.height=sizer.height+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.origin.y=messageText.frame.origin.y-KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING;
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;
        

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
        
        [playButton.mediaProgressBar setValue:0.0 animated:NO];
        [playButton.mediaProgressBar setMaximumValue:currentMessage.durationInSecs.floatValue];
        if([[Konotor getCurrentPlayingMessageID] isEqualToString:[currentMessage messageId]])
            [playButton startAnimating];

    }
    else
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
        
        txtMsgFrame.size.height=sizer.height+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
        txtMsgFrame.origin.y=messageText.frame.origin.y-KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING;
        txtMsgFrame.origin.y=messageContentViewY;
        txtMsgFrame.origin.x=messageContentViewX;
        txtMsgFrame.size.width=messageContentViewWidth;
        if(KONOTOR_USESCALLOUTIMAGE)
            messageBackground.frame=txtMsgFrame;

    }
    
    [cell.contentView setClipsToBounds:YES];
    cell.tag=[currentMessage.messageId hash];
    
    return cell;

}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==messageCount)
        return 40;
    KonotorMessageData* currentMessage=(KonotorMessageData*)[messages objectAtIndex:indexPath.row];
    
    float width=MIN((KONOTOR_SHOWPROFILEIMAGE)?(self.view.frame.size.width-KONOTOR_PROFILEIMAGE_DIMENSION-3*KONOTOR_HORIZONTAL_PADDING-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING):(self.view.frame.size.width-8*KONOTOR_HORIZONTAL_PADDING-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING),KONOTOR_TEXTMESSAGE_MAXWIDTH-KONOTOR_MESSAGE_BACKGROUND_IMAGE_SIDE_PADDING);

    if([currentMessage messageType].integerValue==KonotorMessageTypeText){
        UITextView* txtView=[[UITextView alloc] init];
        [txtView setFont:KONOTOR_MESSAGETEXT_FONT];
        [txtView setText:[currentMessage text]];
        float height=0.0;
        height=[txtView sizeThatFits:CGSizeMake(width, 1000)].height-16;
        if(KONOTOR_SHOWPROFILEIMAGE)
            return MAX(height+KONOTOR_VERTICAL_PADDING+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0),KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2;
        else
            return height+KONOTOR_VERTICAL_PADDING*2+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
    }
    else if([currentMessage messageType].integerValue==KonotorMessageTypeAudio){
        return KONOTOR_AUDIOMESSAGE_HEIGHT+(KONOTOR_MESSAGE_BACKGROUND_BOTTOM_PADDING_ME?KONOTOR_MESSAGE_BACKGROUND_IMAGE_TOP_PADDING:0)+KONOTOR_VERTICAL_PADDING+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?0:KONOTOR_VERTICAL_PADDING))+(KONOTOR_SHOW_SENDERNAME?0:(KONOTOR_SHOW_TIMESTAMP?KONOTOR_VERTICAL_PADDING:0));
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
            return MAX(height+KONOTOR_VERTICAL_PADDING+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0),KONOTOR_PROFILEIMAGE_DIMENSION+KONOTOR_VERTICAL_PADDING)+KONOTOR_VERTICAL_PADDING*2;
        else
            return height+KONOTOR_VERTICAL_PADDING*2+16+(KONOTOR_SHOW_SENDERNAME?KONOTOR_USERNAMEFIELD_HEIGHT:0)+(KONOTOR_SHOW_TIMESTAMP?KONOTOR_TIMEFIELD_HEIGHT:0);
    }
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

    int lastSpot=loading?messageCount:(messageCount-1);
    if(lastSpot<0) return;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:lastSpot inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
    UIAlertView* konotorAlert=[[UIAlertView alloc] initWithTitle:@"Message not sent" message:@"We could not send your message at this time. Check your internet or try later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [konotorAlert show];
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
    NSCalendar* calendar=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comp=[calendar components:(NSWeekdayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDateComponents* comp2=[calendar components:(NSWeekdayCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:today];

    NSDate* date2=[calendar dateFromComponents:comp];
    NSDate* today2=[calendar dateFromComponents:comp2];

    NSDateComponents* comp3=[calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date2 toDate:today2 options:0];
    int days=comp3.year*36+comp3.month*30+comp3.day;
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

@end
