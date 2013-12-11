//
//  Konotor.h
//  Konotor
//
//  Created by Vignesh G on 04/07/13.
//  Copyright (c) 2013 Vignesh G. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol KonotorDelegate <NSObject>

@optional
-(void) didFinishPlaying:(NSString *)messageID;
-(void) didStartPlaying:(NSString *)messageID;

-(void) didFinishDownloadingMessages;

-(void) didFinishUploading: (NSString *)messageID;
-(void) didEncounterErrorWhileUploading: (NSString *) messageID;
-(void) didEncounterErrorWhileDownloading: (NSString *)messageID;
-(void) didEncounterErrorWhileDownloadingConversations;

-(BOOL) handleRemoteNotification:(NSDictionary*)userInfo;
-(BOOL) handleRemoteNotification:(NSDictionary*)userInfo withShowScreen:(BOOL)showScreen;


@end

enum KonotorMessageType {
    KonotorMessageTypeText = 1,
    KonotorMessageTypeAudio = 2
    };

enum KonotorMessageUploadStatus
{
 MessageNotUploaded= 0,
 MessageUploading =1,
 MessageUploaded =2
};


@interface Konotor : NSObject



+(void) InitWithAppID: (NSString *) AppID AppKey: (NSString *) AppKey withDelegate:(id) delegate;
+(void) setDelegate:(id) delegate;
+(BOOL) handleRemoteNotification:(NSDictionary*)userInfo;
+(BOOL) handleRemoteNotification:(NSDictionary*)userInfo withShowScreen:(BOOL)showScreen;


+(BOOL) addDeviceToken:(NSData *) deviceToken;


+(void) setUserIdentifier: (NSString *) UserIdentifier;
+(void) setUserName: (NSString *) fullName;
+(void) setUserEmail: (NSString *) email;
+(void) setCustomUserProperty:(NSString *) value forKey: (NSString*) key;
+(void) setWelcomeMessage:(NSString *) text;

+(BOOL) isUserMe:(NSString *) userId;
+(BOOL) startRecording;
+(NSString*) stopRecording;
+ (NSTimeInterval) getTimeElapsedSinceStartOfRecording;
+(BOOL) cancelRecording;

+(BOOL) playMessageWithMessageID:(NSString *) messageID;
+(BOOL) playMessageWithMessageID:(NSString *) messageID atTime:(double) time;
+(BOOL) StopPlayback;
+(float) getDecibelLevel;
+(double) getCurrentPlayingAudioTime;
+(NSString *)getCurrentPlayingMessageID;


+(void) uploadVoiceRecordingWithMessageID: (NSString *)messageID;
+(void) uploadTextFeedback:(NSString *)textFeedback;

+(void) DownloadAllMessages;

+(void)MarkMessageAsRead:(NSString *) messageID;
+(void) MarkAllMessagesAsRead;

+(NSArray *) getAllMessagesForConversation:(NSString *)conversationID;
+(NSArray *) getAllMessagesForDefaultConversation;
+(NSArray *) getAllConversations;
+(BOOL) areConversationsDownloading;
+(int) getUnreadMessagesCount;

+(void) newSession;

@end



@interface KonotorConversationData : NSObject
@property (strong, nonatomic) NSString *conversationAlias;
@property (strong, nonatomic) NSNumber *lastUpdated;
@property (strong, nonatomic) NSNumber *unreadMessagesCount;
@end

@interface KonotorMessageData : NSObject
@property (nonatomic, retain) NSNumber * createdMillis;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSString * messageUserId;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * bytes;
@property (nonatomic, retain) NSNumber * durationInSecs;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * uploadStatus;
@property (nonatomic, retain) NSString * text;
@property (nonatomic) BOOL  messageRead;


@end
