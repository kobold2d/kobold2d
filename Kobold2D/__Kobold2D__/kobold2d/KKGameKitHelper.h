/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#if __IPHONE_OS_VERSION_MAX_ALLOWED

#import <GameKit/GameKit.h>

/** Defines the delegate methods that are forwarded from GameKitHelper. */
@protocol KKGameKitHelperProtocol <NSObject>

/** Called when local player was authenticated or logged off. */
-(void) onLocalPlayerAuthenticationChanged;

@optional
/** Called when friend list was received from Game Center. */
-(void) onFriendListReceived:(NSArray*)friends;
/** Called when player info was received from Game Center. */
-(void) onPlayerInfoReceived:(NSArray*)players;

/** Called when scores where submitted. This can fail, so check for success. */
-(void) onScoresSubmitted:(BOOL)success;
/** Called when scores were received from Game Center. */
-(void) onScoresReceived:(NSArray*)scores;

/** Called when achievement was reported to Game Center. */
-(void) onAchievementReported:(GKAchievement*)achievement;
/** Called when achievement list was received from Game Center. */
-(void) onAchievementsLoaded:(NSDictionary*)achievements;
/** Called to indicate whether the reset achievements command was successful. */
-(void) onResetAchievements:(BOOL)success;

/** Called when a match was found. */
-(void) onMatchFound:(GKMatch*)match;
/** Called to indicate whether adding players to a match was successful. */
-(void) onPlayersAddedToMatch:(BOOL)success;
/** Called when matchmaking activity was received from Game Center. */
-(void) onReceivedMatchmakingActivity:(NSInteger)activity;

/** Called when a player connected to the match. */
-(void) onPlayerConnected:(NSString*)playerID;
/** Called when a player disconnected from a match. */
-(void) onPlayerDisconnected:(NSString*)playerID;
/** Called when the match begins. */
-(void) onStartMatch;
/** Called whenever data from another player was received. */
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID;

/** Called when the matchmaking view was closed. */
-(void) onMatchmakingViewDismissed;
/** Called for any generic error in the matchmaking view. */
-(void) onMatchmakingViewError;
/** Called when the leaderboard view was closed. */
-(void) onLeaderboardViewDismissed;
/** Called when the achievements view was closed. */
-(void) onAchievementsViewDismissed;

@end

/** Singleton that wraps a lot of common Game Kit and Game Center functionality and forwards events to a delegate implementing the GameKitHelperProtocol.
 It ensures that certain functions are only called if Game Center is available on the current device and the local player is authenticated. 
 It also caches achievements so that they don't get lost if the connection is interrupted.
 */
@interface KKGameKitHelper : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKMatchmakerViewControllerDelegate, GKMatchDelegate>
{
@protected
	id<KKGameKitHelperProtocol> delegate;
	BOOL delegateRespondsToReceiveDataSelector;
	BOOL isGameCenterAvailable;
	NSError* lastError;
	
	NSMutableDictionary* achievements;
	NSMutableDictionary* cachedAchievements;
	
	// TODO: cache scores
	
	GKMatch* currentMatch;
	BOOL matchStarted;
}

/** Set your delegate that should receive the KKGameKitHelperProtocol messages. */
@property (nonatomic, assign) id<KKGameKitHelperProtocol> delegate;
/** Check this to see if Game Center is supported on the current Device. See: http://support.apple.com/kb/HT4314 */
@property (nonatomic, readonly) BOOL isGameCenterAvailable;
/** If your delegate receives an error message, you can check this property for the actual NSError object.
 This allows you to print out the cause of the error to console log or display an Alert view. */
@property (nonatomic, readonly) NSError* lastError;
/** The cached achievements of the local player. GameKitHelper will save the achievements between sessions
 to ensure that achievements are updated on Game Center on next app start even if connection was lost. */
@property (nonatomic, readonly) NSMutableDictionary* achievements;
/** The current match object. May be nil if there's no match. */
@property (nonatomic, retain) GKMatch* currentMatch;
/** Indicates whether the current match has already started. */
@property (nonatomic, readonly) BOOL matchStarted;

/** returns the singleton object, like this: [KKGameKitHelper sharedGameKitHelper] */
+(KKGameKitHelper*) sharedGameKitHelper;

// Player authentication, info
/** try to authenticate the local player */
-(void) authenticateLocalPlayer;
/** request the local player's friends */
-(void) getLocalPlayerFriends;
/** requests info about a set of players */
-(void) getPlayerInfo:(NSArray*)players;

// Scores
/** submit a score to Game Center */
-(void) submitScore:(int64_t)score category:(NSString*)category;

/** request the scores of a set of players, in a given category, range and scopes */
-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category 
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope 
					   timeScope:(GKLeaderboardTimeScope)timeScope;

/** convenience method, requests the Top 10 all time global highscores */
-(void) retrieveTopTenAllTimeGlobalScores;

// Achievements
/** returns a cached achievement by its identifier */
-(GKAchievement*) getAchievementByID:(NSString*)identifier;
/** Send an achievement update to Game Center. The message will only be sent if completion percent is greater than
 any percent previously submitted (Game Center does not allow achievements to regress and would simply ignore such a message). */
-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent;
/** Resets all achievement progress. Be very careful with this, should only be run after the player has understood the consequences.
 You'll use it rather often during development however. It will also clean all cached achievements. */
-(void) resetAchievements;
/** Try to send any cached Achievements to Game Center. If updating an achievement fails for any reason, the achievement is cached.
 By default, GameKitHelper will call this method when the local player is authenticated, so that any previously gained achievements
 are hopefully sent the next time the player runs the App. */
-(void) reportCachedAchievements;
/** Saves all cached achievements to persist them between sessions. By default every time an achievement is cached the cached
 achievements are saved to disk, so they also persist even when the App crashes. */
-(void) saveCachedAchievements;
/** Starts obtaining the local player's achievements from Game Center. */
-(void) loadAchievements;

// Matchmaking
/** Disconnect from the current match */
-(void) disconnectCurrentMatch;
/** creates the handler for processing match invitations from other players */
-(void) setupMatchInvitationHandlerWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers;
/** Request a match for the given request. */
-(void) findMatchForRequest:(GKMatchRequest*)request;
/** Request to add players to a match. */
-(void) addPlayersToMatch:(GKMatchRequest*)request;
/** Cancels any matchmaking request currently in progress. */
-(void) cancelMatchmakingRequest;
/** Request the matchmaking activity to get an indicator on how many games are played. */
-(void) queryMatchmakingActivity;

// Sending/Receiving Data
/** sends the given NSData to all players (unreliably) */
-(void) sendDataToAllPlayers:(NSData*)data;
/** sends the given NSData to all players either reliably (safe but slow) or unreliably (arrival not guaranteed, but fast) */
-(void) sendDataToAllPlayers:(NSData*)data reliable:(BOOL)reliable;
/** sends the given pointer with the given length to all players (unreliably) */
-(void) sendDataToAllPlayers:(void*)data length:(NSUInteger)length;
/** sends the given pointer with the given length to all players either reliably (safe but slow) or unreliably (arrival not guaranteed, but fast) */
-(void) sendDataToAllPlayers:(void*)data length:(NSUInteger)length reliable:(BOOL)reliable;

// Game Center Views
/** Brings up the Game Center Leaderboard view. */
-(void) showLeaderboard;
/** Brings up the Game Center Achievements view. */
-(void) showAchievements;
/** Brings up the Game Center Matchmaking view after receiving an invite. */
-(void) showMatchmakerWithInvite:(GKInvite*)invite;
/** Brings up the Game Center Matchmaking view with a match request. */
-(void) showMatchmakerWithRequest:(GKMatchRequest*)request;

@end


@interface GKMatchmakerViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

#endif
