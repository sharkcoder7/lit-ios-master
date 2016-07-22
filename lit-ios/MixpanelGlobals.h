//
//  MixpanelGlobals.h
//  lit-ios
//
//  Copyright © 2015 Lit Inc. All rights reserved.
//

#ifndef MixpanelGlobals_h
#define MixpanelGlobals_h

static NSString *const kMixpanelToken                   = @"71139a39daf0165fce642f165ab2bb81";

static NSString *const kMixpanelPropertyUserID          = @"UserID";
static NSString *const kMixpanelPropertyContentId       = @"ContentID";
static NSString *const kMixpanelPropertyKeyboardId      = @"KeyboardID";

static NSString *const kMixpanelAction_sendFeedbackFilledOut_Settings = @"sendFeedbackFilledOut_Settings";

static NSString *const kMixpanelAction_cropPhoto = @"cropPhoto";

static NSString *const kMixpanelAction_uploadFromGallery = @"uploadFromGallery";
static NSString *const kMixpanelAction_takePhoto = @"takePhoto";
static NSString *const kMixpanelAction_cancelNewPFPhoto = @"cancelNewPFPhoto";

static NSString *const kMixpanelAction_next_Cropping_Soundbites = @"next_Cropping_Soundbites";

static NSString *const kMixpanelAction_publishKey_NewKey = @"publishKey_NewKey";
static NSString *const kMixpanelAction_fbShare_NewKey = @"fbShare_NewKey";
static NSString *const kMixpanelAction_twitterShare_NewKey = @"twitterShare_NewKey";

static NSString *const kMixpanelAction_next_PreviewApprove_Soundbites = @"next_PreviewApprove_Soundbites";
static NSString *const kMixpanelAction_previewPlay_Soundbites = @"previewPlay_Soundbites";

static NSString *const kMixpanelAction_keyboardSelected_AddToKey = @"keyboardSelected_AddToKey";
static NSString *const kMixpanelAction_newKeyboard_AddToKey = @"newKeyboard_AddToKey";
static NSString *const kMixpanelAction_addToDatabase_AddToKey = @"addToDatabase_AddToKey";

static NSString *const kMixpanelAction_uploadContent_TagView = @"uploadContent_TagView";
static NSString *const kMixpanelAction_previewContent_TagView = @"previewContent_TagView";
static NSString *const kMixpanelAction_emojiSelected_TagView = @"emojiSelected_TagView";

static NSString *const kMixpanelAction_report_3dots_Soundbites = @"report_3dots_Soundbites";
static NSString *const kMixpanelAction_addToKey_3dots_Soundbites = @"addToKey_3dots_Soundbites";
static NSString *const kMixpanelAction_addToFavs_3dots_Soundbites = @"addToFavs_3dots_Soundbites";
static NSString *const kMixpanelAction_removeFav_3dots_Soundbites = @"removeFav_3dots_Soundbites";
static NSString *const kMixpanelAction_share_3dots_Soundbites = @"share_3dots_Soundbites";
static NSString *const kMixpanelAction_cancel_3dots_Soundbites = @"cancel_3dots_Soundbites";

static NSString *const kMixpanelAction_report_3dots_Dubs = @"report_3dots_Dubs";
static NSString *const kMixpanelAction_addToKey_3dots_Dubs = @"addToKey_3dots_Dubs";
static NSString *const kMixpanelAction_addToFavs_3dots_Dubs = @"addToFavs_3dots_Dubs";
static NSString *const kMixpanelAction_removeFav_3dots_Dubs = @"removeFav_3dots_Dubs";
static NSString *const kMixpanelAction_share_3dots_Dubs = @"share_3dots_Dubs";
static NSString *const kMixpanelAction_cancel_3dots_Dubs = @"cancel_3dots_Dubs";

static NSString *const kMixpanelAction_report_3dots_Lyrics = @"report_3dots_Lyrics";
static NSString *const kMixpanelAction_addToKey_3dots_Lyrics = @"addToKey_3dots_Lyrics";
static NSString *const kMixpanelAction_addToFavs_3dots_Lyrics = @"addToFavs_3dots_Lyrics";
static NSString *const kMixpanelAction_removeFav_3dots_Lyrics = @"removeFav_3dots_Lyrics";
static NSString *const kMixpanelAction_share_3dots_Lyrics = @"share_3dots_Lyrics";
static NSString *const kMixpanelAction_cancel_3dots_Lyrics = @"cancel_3dots_Lyrics";

static NSString *const kMixpanelAction_search_Lyrics = @"search_Lyrics";
static NSString *const kMixpanelAction_addNew_Lyrics = @"addNew_Lyrics";
static NSString *const kMixpanelAction_3dots_Lyrics = @"3dots_Lyrics";
static NSString *const kMixpanelAction_lyricsContent_Trending = @"lyricsContent_Trending";
static NSString *const kMixpanelAction_lyricsContent_Recent = @"lyricsContent_Recent";

static NSString *const kMixpanelAction_newLyric_lyricForm = @"newLyric_lyricForm";
static NSString *const kMixpanelAction_newLyric_artist = @"newLyric_artist";
static NSString *const kMixpanelAction_newLyric_songName = @"newLyric_songName";
static NSString *const kMixpanelAction_newLyric_Done = @"newLyric_Done";

static NSString *const kMixpanelAction_uploadPressed_Dubs = @"uploadPressed_Dubs";
static NSString *const kMixpanelAction_dubRecording_Dubs = @"dubRecording_Dubs";

static NSString *const kMixpanelAction_searchBaseSound_New_Dubs = @"searchBaseSound_New_Dubs";
static NSString *const kMixpanelAction_3dotsSound_New_Dubs = @"3dotsSound_New_Dubs";
static NSString *const kMixpanelAction_previewSound_New_Dubs = @"previewSound_New_Dubs";

static NSString *const kMixpanelAction_search_Dubs = @"search_Dubs";
static NSString *const kMixpanelAction_addNew_Dubs = @"addNew_Dubs";
static NSString *const kMixpanelAction_3dots_Dubs = @"3dots_Dubs";
static NSString *const kMixpanelAction_dubsContent_Trending = @"dubsContent_Trending";
static NSString *const kMixpanelAction_dubsContent_Recent = @"dubsContent_Recent";

static NSString *const kMixpanelAction_next_PreviewRecording_Soundbites = @"next_PreviewRecording_Soundbites";
static NSString *const kMixpanelAction_previewRecording_Soundbites = @"previewRecording_Soundbites";
static NSString *const kMixpanelAction_previewSound_Soundbites = @"previewSound_Soundbites";

static NSString *const kMixpanelAction_recordSound_Soundbites = @"recordSound_Soundbites";

static NSString *const kMixpanelAction_useiTunes_Create_Soundbites = @"useiTunes_Create_Soundbites";
static NSString *const kMixpanelAction_record_Create_Soundbites = @"record_Create_Soundbites";
static NSString *const kMixpanelAction_cancel_Create_Soundbites = @"cancel_Create_Soundbites";

static NSString *const kMixpanelAction_search_Soundbites = @"search_Soundbites";
static NSString *const kMixpanelAction_addNew_Soundbites = @"addNew_Soundbites";
static NSString *const kMixpanelAction_3dots_Soundbites = @"3dots_Soundbites";
static NSString *const kMixpanelAction_soundbitesContent_Trending = @"soundbitesContent_Trending";
static NSString *const kMixpanelAction_soundbitesContent_Recent = @"soundbitesContent_Recent";

static NSString *const kMixpanelAction_viewPoints = @"viewPoints";

static NSString *const kMixpanelAction_createNewKeyboard_Profile = @"createNewKeyboard_Profile";

static NSString *const kMixpanelAction_addToFavs_HoldDown_KFeed = @"addToFavs_HoldDown_KFeed";
static NSString *const kMixpanelAction_removeFav_HoldDown_KFeed = @"removeFav_HoldDown_KFeed";
static NSString *const kMixpanelAction_reportCont_HoldDown_KFeed = @"reportCont_HoldDown_KFeed";
static NSString *const kMixpanelAction_shareCont_HoldDown_KFeed = @"shareCont_HoldDown_KFeed";
static NSString *const kMixpanelAction_close_HoldDown_KFeed = @"close_HoldDown_KFeed";

static NSString *const kMixpanelAction_sendFilledOutReport = @"sendFilledOutReport";

static NSString *const kMixpanelAction_report_3dots_KFeed = @"report_3dots_KFeed";
static NSString *const kMixpanelAction_removeKey_3dots_KFeed = @"removeKey_3dots_KFeed";
static NSString *const kMixpanelAction_installKey_3dots_KFeed = @"installKey_3dots_KFeed";
static NSString *const kMixpanelAction_shareKey_3dots_KFeed = @"shareKey_3dots_KFeed";
static NSString *const kMixpanelAction_cancel_3dots_KFeed = @"cancel_3dots_KFeed";

static NSString *const kMixpanelAction_report_3dots_CFeed = @"report_3dots_CFeed";
static NSString *const kMixpanelAction_addToKey_3dots_CFeed = @"addToKey_3dots_CFeed";
static NSString *const kMixpanelAction_addToFavs_3dots_CFeed = @"addToFavs_3dots_CFeed";
static NSString *const kMixpanelAction_removeFav_3dots_CFeed = @"removeFav_3dots_CFeed";
static NSString *const kMixpanelAction_shareCont_3dots_CFeed = @"shareCont_3dots_CFeed";
static NSString *const kMixpanelAction_cancel_3dots_CFeed = @"cancel_3dots_CFeed";

static NSString *const kMixpanelAction_removeFav_Heart_ContentFeed = @"removeFav_Heart_ContentFeed";
static NSString *const kMixpanelAction_addToFav_Heart_ContentFeed = @"addToFav_Heart_ContentFeed ";
static NSString *const kMixpanelAction_addToKeyboard_Plus_ContentFeed = @"addToKeyboard_Plus_ContentFeed";
static NSString *const kMixpanelAction_previewContent_Play_ContentFeed = @"previewContent_Play_ContentFeed";
static NSString *const kMixpanelAction_threeDots_ContentFeed = @"threeDots_ContentFeed";

static NSString *const kMixpanelAction_homeToFeed = @"homeToFeed";
static NSString *const kMixpanelAction_keySegment_Profile = @"keySegment_Profile";
static NSString *const kMixpanelAction_favSegment_Profile = @"favSegment_Profile";
static NSString *const kMixpanelAction_contentSegment_Profile = @"contentSegment_Profile";
static NSString *const kMixpanelAction_uninstallKey_Profile = @"uninstallKey_Profile";
static NSString *const kMixpanelAction_editKey_Profile = @"editKey_Profile";
static NSString *const kMixpanelAction_facebookLink_Profile = @"facebookLink_Profile";
static NSString *const kMixpanelAction_twitterLink_Profile = @"twitterLink_Profile";

static NSString *const kMixpanelAction_facebookLink_Settings = @"facebookLink_Settings";
static NSString *const kMixpanelAction_twitterLink_Settings = @"twitterLink_Settings";
static NSString *const kMixpanelAction_editPFPhoto_Settings = @"editPFPhoto_Settings";
static NSString *const kMixpanelAction_aboutLIT_Settings = @"aboutLIT_Settings";
static NSString *const kMixpanelAction_FAQ_Settings = @"FAQ_Settings";
static NSString *const kMixpanelAction_feedback_Settings = @"feedback_Settings";
static NSString *const kMixpanelAction_termsOfService_Settings = @"termsOfService_Settings";
static NSString *const kMixpanelAction_logout_Settings = @"logout_Settings";

static NSString *const kMixpanelAction_gooeyPlusButton = @"editPFPhoto_Settings";
static NSString *const kMixpanelAction_soundbitesButton_Gooey = @"soundbitesButton_Gooey";
static NSString *const kMixpanelAction_dubsButton_Gooey = @"dubsButton_Gooey";
static NSString *const kMixpanelAction_lyricsButton_Gooey = @"lyricsButton_Gooey";

static NSString *const kMixpanelAction_settings_TopBar = @"settings_TopBar";
static NSString *const kMixpanelAction_profile_TopBar = @"profile_TopBar";
static NSString *const kMixpanelAction_keyboard_FeedSegment = @"keyboard_FeedSegment";
static NSString *const kMixpanelAction_content_FeedSegment = @"content_FeedSegment";
static NSString *const kMixpanelAction_keyboardFeed_Search = @"keyboardFeed_Search";
static NSString *const kMixpanelAction_contentFeed_Search = @"contentFeed_Search";
static NSString *const kMixpanelAction_removeKeyboard = @"removeKeyboard";
static NSString *const kMixpanelAction_installKeyboard = @"installKeyboard";
static NSString *const kMixpanelAction_like_KeyboardFeed = @"like_KeyboardFeed";
static NSString *const kMixpanelAction_dots_KeyboardFeed = @"dots_KeyboardFeed";

static NSString *const kMixpanelAction_videoContentPreview_KeyboardFeed = @"videoContentPreview_KeyboardFeed";
static NSString *const kMixpanelAction_soundContentPreview_KeyboardFeed = @"soundContentPreview_KeyboardFeed";
static NSString *const kMixpanelAction_lyricContentPreview_KeyboardFeed = @"lyricContentPreview_KeyboardFeed";
static NSString *const kMixpanelAction_holdDownContentContainer_KeyboardFeed = @"holdDownContentContainer_KeyboardFeed";

static NSString *const kMixpanelAction_no_PushNotif = @"no_PushNotif";
static NSString *const kMixpanelAction_yes_PushNotif = @"yes_PushNotif";
static NSString *const kMixpanelAction_fullAccessInfo = @"fullAccessInfo";
static NSString *const kMixpanelAction_proceedToLogin = @"proceedToLogin";
static NSString *const kMixpanelAction_proceedToLit = @"proceedToLit";

static NSString *const kMixpanelAction_facebookLogin = @"facebookLogin";
static NSString *const kMixpanelAction_twitterLogin = @"twitterLogin";
static NSString *const kMixpanelAction_termsOfService_Login = @"termsOfService_Login";
static NSString *const kMixpanelAction_loginQuestionMark = @"loginQuestionMark";

//

static NSString *const kMixpanelAction_keyExt_OK_Onboard4 = @"keyExt_OK_Onboard4";
static NSString *const kMixpanelAction_keyExt_OK_Onboard3 = @"keyExt_OK_Onboard3";
static NSString *const kMixpanelAction_keyExt_OK_Onboard2 = @"keyExt_OK_Onboard2";
static NSString *const kMixpanelAction_keyExt_OK_Onboard1 = @"keyExt_OK_Onboard1";

static NSString *const kMixpanelAction_addToFavs_HoldDown_KExtension = @"addToFavs_HoldDown_KExtension";
static NSString *const kMixpanelAction_removeFav_HoldDown_KExtension = @"removeFav_HoldDown_KExtension";
static NSString *const kMixpanelAction_shareCont_HoldDown_KExtension = @"shareCont_HoldDown_KExtension";
static NSString *const kMixpanelAction_close_HoldDown_KExtension = @"close_HoldDown_KExtension";

static NSString *const kMixpanelAction_videoContentPreview_KExtension = @"videoContentPreview_KExtension";
static NSString *const kMixpanelAction_soundContentPreview_KExtension = @"soundContentPreview_KExtensio";
static NSString *const kMixpanelAction_lyricContentPreview_KExtension = @"lyricContentPreview_KExtension";
static NSString *const kMixpanelAction_holdDownContentContainer_KExtension = @"holdDownContentContainer_KExtension";

static NSString *const kMixpanelAction_swipeKeyboard_KExtension = @"swipeKeyboard_KExtension";

#endif /* MixpanelGlobals_h */
