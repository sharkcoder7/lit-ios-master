var ERROR_USER_UNDEFINED                = '{"code": 501, "message": "User Undefined."}';
var ERROR_SONG_UNDEFINED                = '{"code": 502, "message": "Song Undefined."}';
var ERROR_SOUNDBITE_UNDEFINED           = '{"code": 503, "message": "Soundbite Undefined."}';
var ERROR_DUB_VIDEO_UNDEFINED           = '{"code": 504, "message": "Dub Video Undefined."}';
var ERROR_DUB_SNAPSHOT_UNDEFINED        = '{"code": 505, "message": "Dub Snapshot Undefined."}';
var ERROR_SOUNDBITE_AUDIO_UNDEFINED     = '{"code": 506, "message": "Soundbite Audio Undefined."}';
var ERROR_SOUNDBITE_IMAGE_UNDEFINED     = '{"code": 507, "message": "Soundbite Image Undefined."}';
var ERROR_SOUNDBITE_VIDEO_UNDEFINED     = '{"code": 508, "message": "Soundbite Video Undefined."}';
var ERROR_KEYBOARD_CONTENTS_UNDEFINED   = '{"code": 509, "message": "Keyboard Contents Array Undefined."}';
    var ERROR_LYRIC_TEXT_LENGTH             = '{"code": 510, "message": "Lyric text larger than permitted."}';
    var ERROR_DUB_CAPTION_LENGTH            = '{"code": 511, "message": "Dub caption larger than permitted."}';
    var ERROR_SOUNDBITE_CAPTION_LENGTH      = '{"code": 512, "message": "Soundbite caption larger than permitted."}';
    var ERROR_KEYBOARD_NAME_LENGTH          = '{"code": 513, "message": "Keyboard name larger than permitted."}';
var ERROR_REPORT_REFERENCE_UNDEFINED    = '{"code": 514, "message": "Reported object ID undefined."}';
var ERROR_REPORT_CLASS_UNDEFINED        = '{"code": 515, "message": "Reported object class undefined."}';
var ERROR_REPORT_CLASS_INVALID          = '{"code": 516, "message": "Reported object class invalid."}';
var ERROR_REPORT_TEXT_UNDEFINED         = '{"code": 517, "message": "Report text undefined."}';
    var ERROR_REPORT_TEXT_LENGTH            = '{"code": 518, "message": "Report text larger than permitted."}';
var ERROR_REPORT_EMAIL_UNDEFINED        = '{"code": 519, "message": "Report email undefined."}';
    var ERROR_REPORT_EMAIL_INVALID          = '{"code": 520, "message": "Report email invalid."}';
var ERROR_SONG_TITLE_LENGTH             = '{"code": 521, "message": "Song title name larger than permitted."}';
var ERROR_SONG_ARTIST_LENGTH            = '{"code": 522, "message": "Song artist name larger than permitted."}';
var ERROR_SONG_ALBUM_LENGTH             = '{"code": 523, "message": "Song album name larger than permitted."}';
var ERROR_TAG_INVALID                   = '{"code": 524, "message": "Tag string invalid."}';
    var ERROR_LYRIC_TEXT_EMPTY              = '{"code": 525, "message": "Lyric text must not be empty."}';
    var ERROR_DUB_CAPTION_EMPTY             = '{"code": 526, "message": "Dub caption must not be empty."}';
    var ERROR_SOUNDBITE_CAPTION_EMPTY       = '{"code": 527, "message": "Soundbite caption must not be empty."}';
    var ERROR_KEYBOARD_NAME_EMPTY           = '{"code": 528, "message": "Keyboard name must not be empty."}';
    var ERROR_REPORT_TEXT_EMPTY             = '{"code": 529, "message": "Report text must not be empty."}';
    var ERROR_REPORT_EMAIL_EMPTY            = '{"code": 530, "message": "Report email must not be empty."}';
var ERROR_SONG_TITLE_EMPTY              = '{"code": 531, "message": "Song title must not be empty."}';
var ERROR_SONG_ARTIST_EMPTY             = '{"code": 532, "message": "Song artist must not be empty."}';
var ERROR_SONG_ALBUM_EMPTY              = '{"code": 533, "message": "Song album must not be empty."}';
    var ERROR_LYRIC_TEXT_INVALID            = '{"code": 534, "message": "Some characters are not allowed in the lyric text."}';
    var ERROR_DUB_CAPTION_INVALID           = '{"code": 535, "message": "Characters not alphanumeric are not allowed in the dub\'s caption."}';
    var ERROR_SOUNDBITE_CAPTION_INVALID     = '{"code": 536, "message": "Characters not alphanumeric are not allowed in the soundbite\'s caption."}';
    var ERROR_KEYBOARD_NAME_INVALID         = '{"code": 537, "message": "Characters not alphanumeric are not allowed in the keyboard\'s name."}';
    var ERROR_REPORT_TEXT_INVALID           = '{"code": 538, "message": "Some characters are not allowed in the keyboard\'s name."}';
    var ERROR_REPORT_EMAIL_LENGTH         = '{"code": 539, "message": "Report email larger than permitted."}';
var ERROR_FEEDBACK_TEXT_UNDEFINED       = '{"code": 540, "message": "Feedback text undefined."}';
    var ERROR_FEEDBACK_TEXT_LENGTH          = '{"code": 541, "message": "Feedback text larger than permitted."}';
    var ERROR_FEEDBACK_TEXT_EMPTY          = '{"code": 542, "message": "Feedback text must not be empty."}';
    var ERROR_FEEDBACK_TEXT_INVALID          = '{"code": 547, "message": "Feedback text invalid."}';
var ERROR_FEEDBACK_EMAIL_UNDEFINED      = '{"code": 543, "message": "Feedback email undefined."}';
    var ERROR_FEEDBACK_EMAIL_INVALID        = '{"code": 544, "message": "Feedback email invalid."}';
    var ERROR_FEEDBACK_EMAIL_LENGTH         = '{"code": 545, "message": "Feedback email larger than permitted."}';
    var ERROR_FEEDBACK_EMAIL_EMPTY         = '{"code": 546, "message": "Feedback email must not be empty."}';




var _ = require("underscore");



// String limits for / text insertion

var maxKeyboardNameLength = 60;
var maxCaptionLength = 60;
var maxLyricLength = 140;
var maxSongTitleLength = 120;
var maxSongArtistLength = 80;
var maxSongAlbumNameLength = 80;
var maxReportTextLength = 2000;
var maxFeedbackTextLength = maxReportTextLength;
var maxReportEmailLength = 180;
var maxFeedbackEmailLength = maxReportEmailLength;


// Globals

var litUserID = "G1CJRmGnIH";
var litKeyboardID = "eeB7ogUU5q";

// Point System

var pointsUserCreation = 25;                var pointsUserCreationIdentifier = "pointsUserCreation";
var pointsConnectToSocialNetwork = 25;      var pointsConnectToSocialNetworkIdentifier = "pointsConnectToSocialNetwork";
var pointsDubCreation = 20;                 var pointsDubCreationIdentifier = "pointsDubCreation";
var pointsSoundbiteCreation = 10;           var pointsSoundbiteCreationIdentifier = "pointsSoundbiteCreation";
var pointsLyricCreation = 5;                var pointsLyricCreationIdentifier = "pointsLyricCreation";
var pointsAddingToKeyboardInstaller = 2;    var pointsAddingToKeyboardIdentifier = "pointsAddingToKeyboard";
var pointsAddingToKeyboardOwner = 15;       
var pointsAddingToFavsInstaller = 4;        var pointsAddingToFavsIdentifier = "pointsAddingToFavs";
var pointsAddingToFavsOwner = 25;           
var pointsInstallingKeyboardInstaller = 4;  var pointsInstallingKeyboardIdentifier = "pointsInstallingKeyboard";
var pointsInstallingKeyboardOwner = 25;     
var pointsSharingContent = 2;               var pointsSharingContentIdentifier = "pointsSharingContent";
var pointsSharingKeyboard = 3;              var pointsSharingKeyboardIdentifier = "pointsSharingKeyboard";


// Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define("mainFeed", function (request, response) {

    var soundbitesPromise = new Parse.Query("soundbite").addAscending("updatedAt").find();
    var dubsQueryPromise = new Parse.Query("dub").addAscending("updatedAt").find();
    var lyricsQueryPromise = new Parse.Query("lyric").addAscending("updatedAt").find();

    Parse.Promise.when([soundbitesPromise, dubsQueryPromise, lyricsQueryPromise]).then(function (soundbites, dubs, lyrics) {
        response.success(soundbites.concat(dubs).concat(lyrics));
    }, function (error) {
        response.error("Could not retrieve feed " + error.code + ": " + error.message);
    });
});


Parse.Cloud.beforeSave("song", function(request, response) {
    if (request.object.isNew()) {
        request.object.set("timesUsed", 1);
    }
    
    if(request.object.get("albumName") == "ClipConverter.cc"){
        request.object.set("albumName","");   
    }
    
    response.success();
});


Parse.Cloud.beforeSave("soundbite", function(request, response) {
    if(request.object.isNew()) {
        setDefaults(request.object);
    }
    
    var state = validateObject(request.object);
    if(state == "success") {
        if (!request.object.isNew() && request.object.dirtyKeys('caption')) {
            console.log('calling update');
            updateMainFeedEntryData(request, response);
        } else {
            response.success();    
        } 
    } else {
        response.error(state);
    }
});

Parse.Cloud.afterSave("soundbite", function(request) {
    if(!request.object.existed()) {
        updateUserPoints(request,pointsSoundbiteCreationIdentifier);
        updateSearchData(request.object);
        insertInMainFeed(request.object,request.object.get("user"));    
        insertInUserCreatedContent(request.user, request.object);
        updateTagObjects(request.object);
    }
});

Parse.Cloud.beforeSave("dub", function(request, response) {
    if(request.object.isNew()) {
        setDefaults(request.object);    
    } 
    
    var state = validateObject(request.object);
    if(state == "success") {
        if (!request.object.isNew() && request.object.dirtyKeys('caption')) {
            console.log('calling update');
            updateMainFeedEntryData(request, response);
        } else {
            response.success();    
        } 
    } else {
        response.error(state);
    }
});

Parse.Cloud.afterSave("dub", function(request) {
    if(!request.object.existed()) {
        updateUserPoints(request,pointsDubCreationIdentifier);
        updateSearchData(request.object);
        insertInMainFeed(request.object,request.object.get("user"));
        insertInUserCreatedContent(request.user, request.object); 
        updateTagObjects(request.object);
    }
});

Parse.Cloud.beforeSave("lyric", function(request, response) {
    if(request.object.isNew()) {
        setDefaults(request.object);    
    }
    
    var state = validateObject(request.object);
    if(state == "success") {
        if (!request.object.isNew() && request.object.dirtyKeys('text')) {
            console.log('calling update');
            updateMainFeedEntryData(request, response);
        } else {
            response.success();    
        } 
    } else {
        response.error(state);
    }
});

Parse.Cloud.afterSave("lyric", function(request) {
    if(!request.object.existed()) {
        updateUserPoints(request,pointsLyricCreationIdentifier);
        updateSearchData(request.object);
        insertInMainFeed(request.object,request.object.get("user"));
        insertInUserCreatedContent(request.user, request.object); 
        updateTagObjects(request.object);
    }
});

Parse.Cloud.beforeSave("tag", function(request, response) {
    if(request.object.isNew()) {
        request.object.set("uses",0);
    } 
    response.success();
});

Parse.Cloud.afterSave("tag", function(request) {
    updateExistingTags(request.object);
});

function updateExistingTags(tag) {
    
    // We need to remove the duplicates of the newly inserted tag
    var Tag = Parse.Object.extend("tag");
    var query = new Parse.Query(Tag);
    query.equalTo("text", tag.get("text")).addAscending("createdAt");
    
    var tagIsUnique = true;
    var primeTag;
    
    query.find().then(function(results) {
      
        if(results.length == 1){
            return;   
        }
        else {
            tagIsUnique = false;    
        }
        
        var tagsToRemove = new Array();
        primeTag = results[0];
        
        for(var i=results.length-1; i>0; i--){
            tagsToRemove.push(results[i]);
        }
        
        // Chain destroy promises, so we don't return until all duplicated
        // tags have been erased from Parse.com
        var promiseSeries = Parse.Promise.as();
        _.each(tagsToRemove, function(objToKill) {
            promiseSeries = promiseSeries.then(function() {
                return objToKill.destroy();
            });
        });
        
        return promiseSeries;
    }).then(function() {
        
        if(!tagIsUnique){
            primeTag.increment("uses");
            // Register a new use of this tag
            var TagUse = Parse.Object.extend("tagUse");
            var aTagUse = new TagUse();
            aTagUse.set("tag",primeTag);
            aTagUse.save(); 
        }  
    });
}
 
Parse.Cloud.afterSave("keyboard", function(request) {
    if(!request.object.existed()) {
        updateSearchData(request.object);  
    }
});
 
Parse.Cloud.afterSave("lyricDownload", function(request) {
    updateUserPoints(request,pointsAddingToKeyboardIdentifier);  
});
 
Parse.Cloud.afterSave("dubDownload", function(request) {
    updateUserPoints(request,pointsAddingToKeyboardIdentifier);  
});
 
Parse.Cloud.afterSave("soundbiteDownload", function(request) {
    updateUserPoints(request,pointsAddingToKeyboardIdentifier);  
});

Parse.Cloud.afterSave("lyricLike", function(request) {
    updateUserPoints(request,pointsAddingToFavsIdentifier);  
});
 
Parse.Cloud.afterSave("dubLike", function(request) {
    updateUserPoints(request,pointsAddingToFavsIdentifier);  
});
 
Parse.Cloud.afterSave("soundbiteLike", function(request) {
    updateUserPoints(request,pointsAddingToFavsIdentifier);  
});


Parse.Cloud.afterSave("keyboardDownload", function(request) {
    if(!request.object.existed()) {
        updateUserPoints(request,pointsInstallingKeyboardIdentifier);  
    }
});


Parse.Cloud.afterSave("lyricUse", function(request) {
    updateUserPoints(request,pointsSharingContentIdentifier);  
    updateObjectUses(request,"lyric");
});
 
Parse.Cloud.afterSave("dubUse", function(request) {
    updateUserPoints(request,pointsSharingContentIdentifier);
    updateObjectUses(request,"dub");
});
 
Parse.Cloud.afterSave("soundbiteUse", function(request) {
    updateUserPoints(request,pointsSharingContentIdentifier); 
    updateObjectUses(request,"soundbite");
});

Parse.Cloud.afterSave("keyboardUse", function(request) {
    updateUserPoints(request,pointsSharingKeyboardIdentifier);  
});




Parse.Cloud.beforeSave(Parse.User, function(request, response) {
    console.log('Saving user req: ' + JSON.stringify(request.user));
    for (dirtyKey in request.object.dirtyKeys()) {
        if (dirtyKey === "authData") {
            updateUserPoints(request,pointsConnectToSocialNetworkIdentifier);  
        }
    }
    response.success();
});

                      
Parse.Cloud.afterSave(Parse.User, function(request) {
        
    console.log("=============== GLOBAL AFTER SAVE");
    
    if(!request.object.existed()) {
        
        console.log("++++++++++++++ After save user: "+request.object.get("username"));
        
        Parse.Cloud.useMasterKey();
        
        if(request.object.get("hidden") != true &&
           request.object.get("hidden") != false)
            request.object.set('hidden',false);
        if(request.object.get("flagged") != true &&
           request.object.get("flagged") != false)
            request.object.set('flagged',false);
        if(isNaN(request.object.get("points"))){
            request.object.set("points",pointsUserCreation);   
        }if(request.object.get("pointsCount") == undefined){
            request.object.set("pointsCount",pointsUserCreation.toString());   
        }
        
        var Keyboard = Parse.Object.extend("keyboard");
        var queryKeyboards = new Parse.Query(Keyboard);
        queryKeyboards.get(litKeyboardID,{
                success: function (result) {
                    
                    console.log("=============== LIT KEYBOARD ID: "+result.id);
                    
                    var KeyboardInstallation = Parse.Object.extend("keyboardInstallations");
                    var litInstallation = new KeyboardInstallation();
                    litInstallation.set("user",request.object);
                    
                    var keyboards = new Array();
                    keyboards.push(result);
                    litInstallation.set("keyboards",keyboards);
                    
                    litInstallation.save();
                    
                    var FavKeyboard = Parse.Object.extend("favKeyboard");
                            var userFavKeyboard = new FavKeyboard();
                            userFavKeyboard.set("contents", []);
                            userFavKeyboard.save(null, {
                                success : function(favKeyboard) {
                                    console.log("=============== FAV KEYBOARD ID: "+favKeyboard.id);
                                    request.object.set("favKeyboard", favKeyboard);
                                },
                                error : function(error){
                                    console.log("FATAL: Couldn't create favorites keyboard for user: " + error.code + ' a ' + error.message);
                                }
                            });
                },
                error: function (error) {
                    console.log("Error Querying Keyboard");
                }
            });
    }
});

Parse.Cloud.define("hideUser", function (request, response) {
    Parse.Cloud.useMasterKey();
    var User = Parse.Object.extend("_User");
    var queryUsers = new Parse.Query(User);
    var userId = request.params.userId;
    console.log(" = = = = = = "+userId);
    queryUsers.get(userId, {
        success: function (myObj) {
            myObj.set("hidden",true);
            myObj.save(null,{
                success: function (myObject) {
                    response.success("User hidden!");
                },
                error: function (error) {
                    response.error(error);
                }
            });
        },
        error: function (err){
            response.error(err);
        }
    });
});

Parse.Cloud.define("revealUser", function (request, response) {
    Parse.Cloud.useMasterKey();
    var User = Parse.Object.extend("_User");
    var queryUsers = new Parse.Query(User);
    var userId = request.params.userId;
    console.log(" = = = = = = "+userId);
    queryUsers.get(userId, {
        success: function (myObj) {
            myObj.set("hidden",false);
            myObj.save(null,{
                success: function (myObject) {
                    response.success("User revealed!");
                },
                error: function (error) {
                    response.error(error);
                }
            });
        },
        error: function (err){
            response.error(err);
        }
    });
});

Parse.Cloud.define("deleteUser", function (request, response) {
    Parse.Cloud.useMasterKey();
    var User = Parse.Object.extend("_User");
    var queryUsers = new Parse.Query(User);
    var userId = request.params.userId;
    console.log(" = = = = = = "+userId);
    queryUsers.get(userId, {
        success: function (myObj) {
            myObj.set("deleted",true);
            myObj.save(null,{
                success: function (myObject) {
                    
                    // Multi query para ocultar sus teclados y elementos creados.
                    // Se espera a que todo termine y después se hace retorna el success
                    
                    var Keyboard = Parse.Object.extend("keyboard");
                    var queryKeyboards = new Parse.Query(Keyboard).equalTo("user", myObject).find();

                    var MainFeed = Parse.Object.extend("mainFeed")
                    var queryMainFeed = new Parse.Query(MainFeed).equalTo("referenceUserId", userId).find();

                    var Soundbite = Parse.Object.extend("soundbite");
                    var querySoundbites = new Parse.Query(Soundbite).equalTo("user", myObject).find();
                    
                    var Dub = Parse.Object.extend("dub");
                    var queryDubs = new Parse.Query(Dub).equalTo("user", myObject).find();
                    
                    var Lyric = Parse.Object.extend("lyric");
                    var queryLyrics = new Parse.Query(Lyric).equalTo("user", myObject).find();

                    Parse.Promise.when([queryKeyboards, queryMainFeed, querySoundbites, queryDubs, queryLyrics]).then(
                        function (keyboards, mainFeeds, soundbites, dubs, lyrics) {

                            hideObjects(keyboards);
                            hideObjects(mainFeeds);
                            hideObjects(soundbites);
                            hideObjects(dubs);
                            hideObjects(lyrics);

                            response.success("User deteled and contents hidden!");

                        }, function (error) {
                            response.error(error);
                        });
                },
                error: function (error) {
                    response.error(error);
                }
            });
        },
        error: function (err){
            response.error(err);
        }
    });
});

function hideObjects(objectArray) {
    for(var i=0; i<objectArray.length; i++){
        objectArray[i].set("hidden",true);
        objectArray[i].save();
    }
}

Parse.Cloud.beforeSave("keyboard", function(request, response) {
    if(request.object.isNew()) {
        setDefaults(request.object);
                
        var state = validateObject(request.object);
        if(state == "success"){response.success();}
        else{response.error(state);}
    }
    
    else {
    if(request.object.dirty("contents")) {
            console.log("=============== CONTENTS CHANGED ================");

            // We need to know the users who have installed the changed keyboard
            var KeyboardInstallations = Parse.Object.extend("keyboardInstallations");
            var queryKeyboardInstallations = new Parse.Query(KeyboardInstallations).include("user").find();

            Parse.Promise.when([queryKeyboardInstallations]).then(
                function (installationObjects) {

                    // We need to keep the IDs of the users who have this keyboard installed
                    var affectedUsers = new Array();

                    var userFound;
                    // Each installation object == one array of keyboards per user, plus the user's ID
                    for(var i=0; i<installationObjects.length; i++){

                        userFound = false;

                        // Each array == a bunch of keyboard's IDs
                        for(var j=0; j<installationObjects[i].get("keyboards").length; j++){

                            if(userFound) break;

                            if(installationObjects[i].get("keyboards")[j] != null){
                                if(installationObjects[i].get("keyboards")[j].id == request.object.id){
                                    affectedUsers.push(installationObjects[i].get("user"));   
                                    userFound = true;
                                }
                            }
                        }
                    }

                    console.log(affectedUsers.length+" will receive the notification");
                    /*
                    console.log("=============== USERS GATHERED ================");
                    for(var i=0; i<affectedUsers.length; i++){
                        console.log("=============== "+i);
                    }
                    console.log("=============== ENDDD GATHERED ================");
                    */

                    // At this point we already have the affected users' IDs. Now we
                    // notify them

                    function sendPushNotification(users) {

                        var promise = new Parse.Promise();

                        var query = new Parse.Query(Parse.Installation);
                        query.containedIn("user", users);

                        Parse.Push.send({
                            where: query,
                            data: {
                                "content-available" : 1,
                                //"sound" : "",
                                "keyboardId" : request.object.id//,
                                //,alert: "Hey there"
                            }
                        }, {
                            success: function() {
                                console.log("success: Parse.Push.send did send push");
                            },
                            error: function(e) {
                                console.log("error: Parse.Push.send code: " + e.code + " msg: " + e.message);
                            }
                        }).then (function(result){
                          promise.resolve(result);
                        }, function(error) {
                          promise.reject(error);
                        });

                        return promise;
                    }

                    var promiseArray = [];
                    var promise = sendPushNotification(affectedUsers);
                    promiseArray.push(promise);
                    /*
                    for(var i=0; i<affectedUsers.length; i++){
                        var promise = sendPushNotification(affectedUsers[i]);
                        promiseArray.push(promise);
                    }
                    */

                    //Returns a new promise that is 
                    //fulfilled when all of the input promises are resolved.          
                    Parse.Promise.when(promiseArray).then(function(result) {
                        console.log("success promise!!")
                        response.success();
                    }, function(error) {
                        console.error("Promise Error: " + error.message);
                        response.error();
                    });

                }, function (error) {
                        response.error(error);
                });
        }
        else {
            response.success();   
        }
    }
});


Parse.Cloud.beforeSave("report", function(request, response) {       
    var state = validateObject(request.object);
    if(state == "success"){response.success();}
    else{response.error(state);}
});


Parse.Cloud.beforeSave("feedback", function(request, response) {       
    var state = validateObject(request.object);
    if(state == "success"){response.success();}
    else{response.error(state);}
});

// Mini version of the full validation, taking care of fields affected by
// iOS users' input, mainly texts fields.
function validateObject(object){
    
    // We need to know the object's class to valide different fields
    
    switch(object.className){
     
        case "keyboard":
                        
            if(object.get("displayName").length > maxKeyboardNameLength){return ERROR_KEYBOARD_NAME_LENGTH;}
            else if(object.get("displayName").length == 0){return ERROR_KEYBOARD_NAME_EMPTY;}
            else if(!object.get("displayName").match(/^[A-Z0-9a-z.,¿¡\$?!'-_ç\+/:;()&@"#%*+\s]+$/)){return ERROR_KEYBOARD_NAME_INVALID;}
            else {
                object.set("displayName",capitalize(object.get("displayName")));
                return "success";
            }
            
            break;
            
        case "soundbite":
            
            if(object.get("caption").length > maxCaptionLength){return ERROR_SOUNDBITE_CAPTION_LENGTH;}
            else if(object.get("caption").length == 0){return ERROR_SOUNDBITE_CAPTION_EMPTY;}
            else if(!object.get("caption").match(/^[A-Z0-9a-z.,¿¡\$?!'-_ç\+/:;()&@"#%*+\s]+$/)){return ERROR_SOUNDBITE_CAPTION_INVALID;}
            else {
                object.set("caption",capitalize(object.get("caption")));
                return "success";
            }
            
            break;
            
        case "dub":
            
            if(object.get("caption").length > maxCaptionLength){return ERROR_DUB_CAPTION_LENGTH;}
            else if(object.get("caption").length == 0){return ERROR_DUB_CAPTION_EMPTY;}
            else if(!object.get("caption").match(/^[A-Z0-9a-z.,¿¡\$?!'-_ç\+/:;()&@"#%*+\s]+$/)){return ERROR_DUB_CAPTION_INVALID;}
            else {
                object.set("caption",capitalize(object.get("caption")));
                return "success";
            }
            
            break;
            
        case "lyric":

            if(object.get("text").length > maxLyricLength){return ERROR_LYRIC_TEXT_LENGTH;}
            else if(object.get("text").length == 0){return ERROR_LYRIC_TEXT_EMPTY;}
            //else if(!object.get("text").match(/^[A-Z0-9a-z.,¿¡\$?!'-_ç\+/:;()&@"#%*+\s]+$/)){return ERROR_LYRIC_TEXT_INVALID;}
            else {
                object.set("text",capitalize(object.get("text")));
                return "success";
            }
            
            break;
            
        case "report":
            
            if(object.get("text").length > maxReportTextLength){return ERROR_REPORT_TEXT_LENGTH;}
            else if(object.get("text").length == 0){return ERROR_REPORT_TEXT_EMPTY;}
            //else if(!object.get("text").match(/^[A-Z0-9a-z.,¿¡\$?!'-_ç\+/:;()&@"#%*+\s]+$/)){return ERROR_REPORT_TEXT_INVALID;}
            else if(object.get("email").length > maxReportEmailLength){return ERROR_REPORT_EMAIL_LENGTH;}
            else if(object.get("email").length == 0){return ERROR_REPORT_EMAIL_EMPTY;}
            //else if(!object.get("email").match(/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i)){return ERROR_REPORT_EMAIL_INVALID;}
            else {
                object.set("text",capitalize(object.get("text")));
                return "success";
            }
            
            break;
            
        case "feedback":
            
            if(object.get("text").length > maxFeedbackTextLength){return ERROR_FEEDBACK_TEXT_LENGTH;}
            else if(object.get("text").length == 0){return ERROR_FEEDBACK_TEXT_EMPTY;}
            //else if(!object.get("text").match(/^[A-Z0-9a-z.,¿¡\$?!'-_ç\+/:;()&@"#%*+\s]+$/)){return ERROR_FEEDBACK_TEXT_INVALID;}
            else if(object.get("email").length > maxFeedbackEmailLength){return ERROR_FEEDBACK_EMAIL_LENGTH;}
            else if(object.get("email").length == 0){return ERROR_FEEDBACK_EMAIL_EMPTY;}
            //else if(!object.get("email").match(/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i)){return ERROR_FEEDBACK_EMAIL_INVALID;}
            else {
                object.set("text",capitalize(object.get("text")));
                return "success";
            }
            
            break;
    }
}



// Full validation of all fields, just in case it's needed for covering
// both the CMS and iOS validation with full detail and precaution
function validateObjectFull(object){
    
    // We need to know the object's class to valide different fields
    
    switch(object.className){
     
        case "keyboard":
            
            if(object.get("user") == undefined){return ERROR_USER_UNDEFINED;}
            else if(object.get("displayName").length > maxKeyboardNameLength){return ERROR_KEYBOARD_NAME_LENGTH;}
            else if(object.get("displayName").length == 0){return ERROR_KEYBOARD_NAME_EMPTY;}
            else if(object.get("contents") == undefined){return ERROR_KEYBOARD_CONTENTS_UNDEFINED;}
            else {return "success";}
            
            break;
            
        case "soundbite":
            
            if(object.get("user") == undefined){return ERROR_USER_UNDEFINED;}
            else if(object.get("caption").length > maxCaptionLength){return ERROR_SOUNDBITE_CAPTION_LENGTH;}
            else if(object.get("caption").length == 0){return ERROR_SOUNDBITE_CAPTION_EMPTY;}
            else if(object.get("audio") == undefined){return ERROR_SOUNDBITE_AUDIO_UNDEFINED;}
            else if(object.get("image") == undefined){return ERROR_SOUNDBITE_IMAGE_UNDEFINED;}
            else if(object.get("video") == undefined){return ERROR_SOUNDBITE_VIDEO_UNDEFINED;}
            else {return "success";}
            
            break;
            
        case "dub":
            
            if(object.get("user") == undefined){return ERROR_USER_UNDEFINED;}
            else if(object.get("caption").length > maxCaptionLength){return ERROR_SOUNDBITE_CAPTION_LENGTH;}
            else if(object.get("caption").length == 0){return ERROR_SOUNDBITE_CAPTION_EMPTY;}
            else if(object.get("soundbite") == undefined){return ERROR_SOUNDBITE_UNDEFINED;}
            else if(object.get("video") == undefined){return ERROR_DUB_VIDEO_UNDEFINED;}
            else if(object.get("snapshot") == undefined){return ERROR_DUB_SNAPSHOT_UNDEFINED;}
            else {return "success";}
            
            break;
            
        case "lyric":

            if(object.get("user") == undefined){return ERROR_USER_UNDEFINED;}
            else if(object.get("song") == undefined){return ERROR_SONG_UNDEFINED;}
            else if(object.get("text").length > maxLyricLength){return ERROR_LYRIC_TEXT_LENGTH;}
            else if(object.get("text").length == 0){return ERROR_LYRIC_TEXT_EMPTY;}
            else if(object.get("tags") == "."){return ERROR_TAG_INVALID;}
            else {return "success";}
            
            break;
            
        case "song":
            
            if(object.get("title").length > maxSongTitleLength){return ERROR_SONG_TITLE_LENGTH;}
            else if(object.get("title").length == 0){return ERROR_SONG_TITLE_EMPTY;}
            else if(object.get("artist").length > maxSongArtistLength){return ERROR_SONG_ARTIST_LENGTH;}
            else if(object.get("artist").length == 0){return ERROR_SONG_ARTIST_EMPTY;}
            else if(object.get("albumName").length > maxSongAlbumNameLength){return ERROR_SONG_ALBUM_LENGTH;}
            else if(object.get("albumName").length == 0){return ERROR_SONG_ALBUM_EMPTY;}
            else {return "success";}
            
            break;
            
        case "report":
            
            if(object.get("user") == undefined){return ERROR_USER_UNDEFINED;}
            else if(object.get("referenceId") == undefined){return ERROR_REPORT_REFERENCE_UNDEFINED;}
            else if(object.get("class") == undefined){return ERROR_REPORT_CLASS_UNDEFINED;}
            else if(object.get("text") == undefined){return ERROR_REPORT_TEXT_UNDEFINED;}
            else if(object.get("email") == undefined){return ERROR_REPORT_EMAIL_UNDEFINED;}
            else if(object.get("text").length > maxReportTextLength){return ERROR_REPORT_TEXT_LENGTH;}
            else if(object.get("text").length == 0){return ERROR_REPORT_TEXT_EMPTY;}
            else if(object.get("email").length > maxReportEmailLength){return ERROR_REPORT_EMAIL_LENGTH;}
            else if(object.get("email").length == 0){return ERROR_REPORT_EMAIL_EMPTY;}
            else if(object.get("class") != "keyboard"
                    && object.get("class") != "soundbite"
                    && object.get("class") != "dub"
                    && object.get("class") != "lyric"){
                return ERROR_REPORT_CLASS_INVALID;
            }
            else if(object.get("email") == undefined){return ERROR_REPORT_EMAIL_UNDEFINED;}
            else {return "success";}
            
            break;
    }
}



Parse.Cloud.define("sortSoundbitesBySongAttribute", function (request, response) {

    // Sorting param
    var sortingType = request.params.sortingType;

    // Get all of the soundbites
    var soundbitesQuery = new Parse.Query("soundbite");
    var soundbites = "";

    // We won't return at all until we are done with the ordering, inside this
    // query function
    Parse.Promise.when([soundbitesQuery.find({
            success: function (theSoundbites) {

                // We process the song querying inside a promise so we know
                // when all of the petitions are done.
                Parse.Promise.when([function () {

                        soundbites = theSoundbites;

                        // For each soundbite, we find its song
                        var songQuery = new Parse.Query("song");
                        for (var i = 0; i < soundbites.length; i++) {

                            songQuery.get(soundbites[i].get("song").id, {
                                success: function (theSong) {
                                    soundbites[i].songTitle = theSong.get("title");
                                    soundbites[i].songArtist = theSong.get("artist");
                                    soundbites[i].songAlbum = theSong.get("albumName");
                                },
                                error: function (object, error) {
                                    console.log(error);
                                }
                            });
                        }
                    }])
                    .then(function (resultingSoundbites) {

                    }, function (error) {

                    });

                response.success(soundbites);
            },
            error: function (error) {
                response.error(error);
            }
        })])
        .then(function (resultingSoundbites) {

        }, function (error) {

        });
});

// User creation (only used in CMS)
Parse.Cloud.define("createUser", function (request, response) {

    Parse.Cloud.useMasterKey();

    var newUser = new Parse.User();

    newUser.set("username", request.params.username);
    newUser.set("password", request.params.password);
    newUser.set("email", undefined);
    user.set("points", parseInt(request.params.points));
    user.set("pointsCount", (request.params.points).toString());
    newUser.set("flagged", request.params.flagged);
    newUser.set("hidden", request.params.hidden);

    newUser.signUp(null, {
        success: function () {
            response.success("User created!");
        },
        error: function (error) {
            response.error(error);
        }
    });
});


// User edition (only used in CMS)
Parse.Cloud.define("editUser", function (request, response) {

    if (!request.user) {
        response.error("Must be signed in to call this Cloud Function.")
        return;
    }

    Parse.Cloud.useMasterKey();
    
    var installedKeyboards = [];
    for(var i=0; i<request.params.installedKeyboards.length; i++){
        var pointer = {
            __type: "Pointer",
            className: "keyboard",
            objectId: request.params.installedKeyboards[i]
        };
        installedKeyboards.push(pointer);
    }
    

    var query = new Parse.Query(Parse.User);
    query.equalTo("objectId", request.params.id);
    query.first({
        success: function (user) {
            user.set("username", request.params.username);
            user.set("points", parseInt(request.params.points));
            user.set("pointsCount", (request.params.points).toString());
            user.set("flagged", request.params.flagged);
            user.set("installedKeyboards", installedKeyboards);
            user.save(null,{
                success: function (myObject) {
                    response.success("User modified!");
                },
                error: function (myObject, error) {
                    response.error(error);
                }
            });
            
        },
        error: function (object, error) {
            response.error("Error modifying user.");
        }
    });
});


function setDefaults(object) {
    
    if (object.className == 'keyboard') {
        if (object.get("contents") == undefined) {
            object.set("contents", []);    
        };
        object.set("featured", false);
        if(object.get("priority") == undefined){object.set("priority", 1);}
    }
    object.set("likes", 0);
    object.set("likeCount", "0");
    object.set("flagged", false);
    object.set("hidden", false);
    object.set("uses",0);
    if(object.get("priority") == undefined){object.set("priority", 1);}
    
}
 
 
function insertInMainFeed(object,user) {
    var MainFeedEntry = Parse.Object.extend("mainFeed");
    var mainFeedEntry = new MainFeedEntry();
    mainFeedEntry.set("referenceId", object.id);
    mainFeedEntry.set("referenceUserId", user.id);
    mainFeedEntry.set("class", object.className);
    mainFeedEntry.set("hidden", false);
    if (object.className == 'soundbite' || object.className == 'dub') {
        mainFeedEntry.set('searchData', object.get('caption').toLowerCase() + ' ' + object.get('tags').replace(/;/g, ""));
    } else if (object.className == 'lyric') {
        mainFeedEntry.set('searchData', object.get('text').toLowerCase()  + ' ' + object.get('tags').replace(/;/g, ""));
    }
    mainFeedEntry.save(null, {
        success : function(mainFeedEntry){
            console.log("Entry added to the main feed");
        },
        error : function(mainFeedEntry, error){
            console.log("Couldn't add entry to the main feed: " + error);
        }
    });
}

function updateSearchData(object) {
    
    if(object.className == "soundbite" || object.className == "dub"){
        object.set("searchData",object.get('caption').toLowerCase() + ' ' + object.get('tags').replace(/;/g, " "));
        object.save();
    }
    else if(object.className == "lyric") {
        object.set("searchData",/*object.get('text').toLowerCase() + ' ' + */object.get('tags').replace(/;/g, " "));
        object.save();
    }
    else if(object.className == "keyboard") {
        object.set("searchData",object.get('displayName').toLowerCase());
        object.save();
    }
}

function updateTagObjects(object) {
    
    var tags = object.get("tags");
    
    var tagArray = new Array();
    
    // Only artist + song for the lyrics
    if(object.className == 'lyric'){
        tagArray.push(tags.split(";")[0]);
        tagArray.push(tags.split(";")[1]);
    }
    else {
       tagArray = tags.split(";"); 
    }
    
    if(tagArray.length < 2){
        return;
    }
    
    // Remove duplicates, if any
    var uniqueTagArray = tagArray.slice().sort(function(a,b){return a > b}).reduce(function(a,b){if (a.slice(-1)[0] !== b) a.push(b);return a;},[]);
    

    var Tag = Parse.Object.extend("tag");
    var query = new Parse.Query(Tag);
    
    var tagObjects = new Array();
    
    for (var i=0; i<uniqueTagArray.length; i++) {
        var theTag = new Tag();
        theTag.set("text",uniqueTagArray[i].replace(/^\s\s*/, '').replace(/\s\s*$/, '').replace(/,/g , '').toLowerCase());
        theTag.save(); // Duplicates are handled in the Tag's own beforeSave method
    }
    
    // Save the tags of the object without ";"
    object.set("tags",object.get("tags").replace(/\;/g,' '));
    object.save();
}
 
function updateMainFeedEntryData(request, response) {
    console.log(request.object.id);
    var MainFeed= Parse.Object.extend("mainFeed");
    new Parse.Query(MainFeed).equalTo("referenceId", request.object.id).first(
        {success: function(mainFeedEntry){
            console.log('MainFeedEntry is ' + JSON.stringify(mainFeedEntry));
            if ((mainFeedEntry.get("class") == 'soundbite' || mainFeedEntry.get("class") == 'dub')) {
                mainFeedEntry.set("searchData", request.object.get('caption').toLowerCase() + ' ' + request.object.get('tags'));
            } else if (mainFeedEntry.get("class") == 'lyric') {
                mainFeedEntry.set("searchData", request.object.get('text').toLowerCase() + ' ' + request.object.get('tags'));
                console.log('Updating searchData for object ' + JSON.stringify(request.object));
            }
            mainFeedEntry.set("hidden", request.object.get('hidden'));
            mainFeedEntry.set("priority", request.object.get('priority'));
            mainFeedEntry.save(null, {
                    success : function(mainFeedEntry){
                        console.log("main feed entry updated");
                        response.success();
                    },
                    error : function(mainFeedEntry, error){
                        console.log("Couldn't add entry to the main feed: " + error);
                        response.error(error);
                    }
                });
        },
        error: function (error) {
            console.log('An error occurred ' + error.message);
            response.error(error);
        }}
    );
}

function updateMainFeedHiddenFlag(request, response) {
    console.log(request.object.id);
    var MainFeed= Parse.Object.extend("mainFeed");
    new Parse.Query(MainFeed).equalTo("referenceId", request.object.id).first(
        {success: function(mainFeedEntry){
            console.log('MainFeedEntry is ' + JSON.stringify(mainFeedEntry));
            mainFeedEntry.set("hidden", request.object.get('hidden'));
            mainFeedEntry.save(null, {
                    success : function(mainFeedEntry){
                        console.log("main feed entry updated");
                        response.success();
                    },
                    error : function(mainFeedEntry, error){
                        console.log("Couldn't add entry to the main feed: " + error);
                        response.error(error);
                    }
                });
        },
        error: function (error) {
            console.log('An error occurred ' + error.message);
            response.error(error);
        }}
    );
}


function insertInUserCreatedContent(user, object) {
    var UserCreatedContent = Parse.Object.extend("userCreatedContent");
    var userCreatedContent = new UserCreatedContent();
    userCreatedContent.set("referenceId", object.id);
    userCreatedContent.set("class", object.className);
    userCreatedContent.set("user", user);
    
    return userCreatedContent.save();
}

Parse.Cloud.beforeDelete("keyboard", function(request, response) {
    
    var KeyboardInstallations = Parse.Object.extend("keyboardInstallations");
    var queryKeyboardInstallations = new Parse.Query(KeyboardInstallations).find();
    
    var KeyboardDownload = Parse.Object.extend("keyboardDownload");
    var queryKeyboardDownloads = new Parse.Query(KeyboardDownload).equalTo("keyboard", request.object).find();
    
    var KeyboardLike = Parse.Object.extend("keyboardLikes");
    var queryKeyboardLikes = new Parse.Query(KeyboardLike).equalTo("keyboard", request.object).find();
    
    var KeyboardUse = Parse.Object.extend("keyboardUse");
    var queryKeyboardUses = new Parse.Query(KeyboardUse).equalTo("keyboard", request.object).find();
    
    var KeyboardReport = Parse.Object.extend("report");
    var queryKeyboardReports = new Parse.Query(KeyboardReport).equalTo("referenceId", request.object.id).find();
    
    Parse.Promise.when([queryKeyboardInstallations, queryKeyboardDownloads, queryKeyboardLikes, queryKeyboardUses,  queryKeyboardReports]).then(
        function (installations, downloads, likes, uses, reports) {
            
            removeObjectFromInstallations(request.object,installations);
            removeObjectDownloads(downloads);
            removeObjectLikes(likes);
            removeObjectUses(uses);
            removeObjectReports(reports);
            
            response.success();
            
        }, function (error) {
            response.error(error);
    });
});


Parse.Cloud.beforeDelete("soundbite", function(request, response) {
    
    var Keyboard = Parse.Object.extend("keyboard");
    var queryKeyboards = new Parse.Query(Keyboard).find();
    
    var FavKeyboard = Parse.Object.extend("favKeyboard");
    var queryFavKeyboards = new Parse.Query(FavKeyboard).find();
    
    var MainFeed = Parse.Object.extend("mainFeed")
    var queryMainFeed = new Parse.Query(MainFeed).equalTo("referenceId", request.object.id).find();
    
    var SoundbiteDownload = Parse.Object.extend("soundbiteDownload");
    var querySoundbiteDownloads = new Parse.Query(SoundbiteDownload).equalTo("soundbite", request.object).find();
    
    var SoundbiteUse = Parse.Object.extend("soundbiteUse");
    var querySoundbiteUses = new Parse.Query(SoundbiteUse).equalTo("soundbite", request.object).find();
    
    var SoundbiteReport = Parse.Object.extend("report");
    var querySoundbiteReports = new Parse.Query(SoundbiteReport).equalTo("referenceId", request.object.id).find();
    
    var SoundbiteCreation = Parse.Object.extend("userCreatedContent");
    var querySoundbiteCreations = new Parse.Query(SoundbiteCreation).equalTo("referenceId", request.object.id).find();
    
    Parse.Promise.when([queryKeyboards, queryFavKeyboards, queryMainFeed, querySoundbiteDownloads, querySoundbiteUses, querySoundbiteReports, querySoundbiteCreations]).then(
        function (keyboards, favKeyboards, mainFeeds, downloads, uses, reports, creations) {
            
            removeObjectFromKeyboards(request.object,keyboards);
            removeObjectFromKeyboards(request.object,favKeyboards);
            removeObjectFromMainFeed(mainFeeds);
            removeObjectDownloads(downloads);
            removeObjectUses(uses);
            removeObjectReports(reports);
            removeObjectCreations(creations);
            
            response.success();
            
        }, function (error) {
            response.error(error);
        });
});


Parse.Cloud.beforeDelete("dub", function(request, response) {
    
    var Keyboard = Parse.Object.extend("keyboard");
    var queryKeyboards = new Parse.Query(Keyboard).find();
    
    var FavKeyboard = Parse.Object.extend("favKeyboard");
    var queryFavKeyboards = new Parse.Query(FavKeyboard).find();
    
    var MainFeed = Parse.Object.extend("mainFeed")
    var queryMainFeed = new Parse.Query(MainFeed).equalTo("referenceId", request.object.id).find();
    
    var DubDownload = Parse.Object.extend("dubDownload");
    var queryDubDownloads = new Parse.Query(DubDownload).equalTo("dub", request.object).find();
    
    var DubUse = Parse.Object.extend("dubUse");
    var queryDubUses = new Parse.Query(DubUse).equalTo("dub", request.object).find();
    
    var DubReport = Parse.Object.extend("report");
    var queryDubReports = new Parse.Query(DubReport).equalTo("referenceId", request.object.id).find();
    
    var DubCreation = Parse.Object.extend("userCreatedContent");
    var queryDubCreations = new Parse.Query(DubCreation).equalTo("referenceId", request.object.id).find();
    
    Parse.Promise.when([queryKeyboards, queryFavKeyboards, queryMainFeed, queryDubDownloads, queryDubUses, queryDubReports, queryDubCreations]).then(
        function (keyboards, favKeyboards, mainFeeds, downloads, uses, reports, creations) {
            
            removeObjectFromKeyboards(request.object,keyboards);
            removeObjectFromKeyboards(request.object,favKeyboards);
            removeObjectFromMainFeed(mainFeeds);
            removeObjectDownloads(downloads);
            removeObjectUses(uses);
            removeObjectReports(reports);
            removeObjectCreations(creations);
            
            response.success();
            
        }, function (error) {
            response.error(error);
        });
});


Parse.Cloud.beforeDelete("lyric", function(request, response) {
    
    var Keyboard = Parse.Object.extend("keyboard");
    var queryKeyboards = new Parse.Query(Keyboard).find();
    
    var FavKeyboard = Parse.Object.extend("favKeyboard");
    var queryFavKeyboards = new Parse.Query(FavKeyboard).find();
    
    var MainFeed = Parse.Object.extend("mainFeed")
    var queryMainFeed = new Parse.Query(MainFeed).equalTo("referenceId", request.object.id).find();
    
    var LyricDownload = Parse.Object.extend("lyricDownload");
    var queryLyricDownloads = new Parse.Query(LyricDownload).equalTo("lyric", request.object).find();
    
    var LyricUse = Parse.Object.extend("lyricUse");
    var queryLyricUses = new Parse.Query(LyricUse).equalTo("lyric", request.object).find();
    
    var LyricReport = Parse.Object.extend("report");
    var queryLyricReports = new Parse.Query(LyricReport).equalTo("referenceId", request.object.id).find();
    
    var LyricCreation = Parse.Object.extend("userCreatedContent");
    var queryLyricCreations = new Parse.Query(LyricCreation).equalTo("referenceId", request.object.id).find();
    
    Parse.Promise.when([queryKeyboards, queryFavKeyboards, queryMainFeed, queryLyricDownloads, queryLyricUses, queryLyricReports, queryLyricCreations]).then(
        function (keyboards, favKeyboards, mainFeeds, downloads, uses, reports, creations) {
            
            removeObjectFromKeyboards(request.object,keyboards);
            removeObjectFromKeyboards(request.object,favKeyboards);
            removeObjectFromMainFeed(mainFeeds);
            removeObjectDownloads(downloads);
            removeObjectUses(uses);
            removeObjectReports(reports);
            removeObjectCreations(creations);
            
            response.success();
            
        }, function (error) {
            response.error(error);
        });
});


Parse.Cloud.beforeDelete("tag", function(request, response) {
    
    var TagUse = Parse.Object.extend("tagUse");
    var queryTagUses = new Parse.Query(TagUse).equalTo("tag", request.object).find();
    
    Parse.Promise.when([queryTagUses]).then(
        function (uses) {
            removeObjectUses(uses);
            response.success();
            
        }, function (error) {
            response.error(error);
        });
});


Parse.Cloud.beforeDelete("report", function(request, response) {
    
    var Report = Parse.Object.extend("report");
    var queryReports = new Parse.Query(Report).equalTo("referenceId", request.object.get("referenceId")).find();
                                                       
    Parse.Promise.when([queryReports]).then(
        function (reports) {

            
            // If there are no more reports referencing the same object we're about
            // to remove the report, we can clear its flag
            if(reports.length == 1){

                var Keyboard = Parse.Object.extend("keyboard");
                var Soundbite = Parse.Object.extend("soundbite");
                var Dub = Parse.Object.extend("dub");
                var Lyric = Parse.Object.extend("lyric");

                var referenceClass = request.object.get("class");
                var referenceId = request.object.get("referenceId");
                
                switch(referenceClass){

                    case "keyboard":
                        var query = new Parse.Query(Keyboard);
                        query.get(referenceId, {
                            success: function (result) {
                                result.set("flagged",false);
                                result.save();
                                response.success();
                            },
                            error: function (model, error) {
                                response.error(error);
                            }
                        });
                        break;
                    case "soundbite":
                        var query = new Parse.Query(Soundbite);
                        query.get(referenceId, {
                            success: function (result) {
                                result.set("flagged",false);
                                result.save();
                                response.success();
                            },
                            error: function (model, error) {
                                response.error(error);
                            }
                        });
                        break;
                    case "dub":
                        var query = new Parse.Query(Dub);
                        query.get(referenceId, {
                            success: function (result) {
                                result.set("flagged",false);
                                result.save();
                                response.success();
                            },
                            error: function (model, error) {
                                response.error(error);
                            }
                        });
                        break;
                    case "lyric":
                        var query = new Parse.Query(Lyric);
                        query.get(referenceId, {
                            success: function (result) {
                                result.set("flagged",false);
                                result.save();
                                response.success();
                            },
                            error: function (model, error) {
                                response.error(error);
                            }
                        });
                        break;
                }
            }
            
            // In case there are more reports pointing to the object, we just return
            else{
                response.success();   
            }
            
        }, function (error) {
            response.error(error);
    });
});

Parse.Cloud.beforeDelete(Parse.User, function(request, response) {
   response.error("Users can't be deleted, they can only be hidden!!!");
});


function removeObjectFromInstallations(object,installations) {
        
    // installations[i] == keyboards installed by one user
    for(var i=0; i<installations.length; i++){
        var keyboardArray = [];
        var found = false;
        for(var j=0; j<installations[i].get("keyboards").length; j++){
            if(object.id != installations[i].get("keyboards")[j].id){
                keyboardArray.push(installations[i].get("keyboards")[j]);
            }
            else{found = true;}
        }
        if(found){ // We only set the new array if it had the deleted element
            installations[i].set("keyboards",keyboardArray);
            installations[i].save();
        }
    }
}

function removeObjectFromKeyboards(object,keyboards) {
        
    // keyboards[i] == keyboard that can or can't have the object
    for(var i=0; i<keyboards.length; i++){
        var contentsArray = [];
        var found = false;
        for(var j=0; j<keyboards[i].get("contents").length; j++){
            if(object.id != keyboards[i].get("contents")[j].id){
                contentsArray.push(keyboards[i].get("contents")[j]);
            }
            else{found = true;}
        }
        if(found){ // We only set the new array if it had the deleted element
            keyboards[i].set("contents",contentsArray);
            keyboards[i].save();
        }
    }
}

function removeObjectFromMainFeed(mainFeeds){
        
    // mainFeeds[i] == mainFeeds[0] == element only once in the main feed
    for(var i=0; i<mainFeeds.length; i++){
        mainFeeds[i].destroy();
    }
}

function removeObjectDownloads(downloads){
        
    // downloads[i] == element downloaded once
    for(var i=0; i<downloads.length; i++){
        downloads[i].destroy();
    }
}

function removeObjectLikes(likes){
        
    // likes[i] == element liked once
    for(var i=0; i<likes.length; i++){
        likes[i].destroy();
    }
}

function removeObjectUses(uses){
        
    // uses[i] == element used once
    for(var i=0; i<uses.length; i++){
        uses[i].destroy();
    }
}
        
function removeObjectReports(reports){
        
    // reports[i] == one report for one element
    for(var i=0; i<reports.length; i++){
        reports[i].destroy();
    }
}

function removeObjectCreations(creations){
        
    // creations[i] == one creation for one element
    for(var i=0; i<creations.length; i++){
        creations[i].destroy();
    }
}


Parse.Cloud.afterSave("report", function(request) {
    
    // Flag the reported content
    
    var theReport = request.object;
    var referenceId = theReport.get("referenceId");
    var referenceClass = theReport.get("class");
    
    var Keyboard = Parse.Object.extend("keyboard");
    var Soundbite = Parse.Object.extend("soundbite");
    var Dub = Parse.Object.extend("dub");
    var Lyric = Parse.Object.extend("lyric");
    
    var query;
    
    switch(referenceClass){
            
        case "keyboard":
            query = new Parse.Query(Keyboard);
            break;
        case "soundbite":
            query = new Parse.Query(Soundbite);
            break;
        case "dub":
            query = new Parse.Query(Dub);
            break;
        case "lyric":
            query = new Parse.Query(Lyric);
            break;
    }
    
    query.equalTo("objectId", referenceId);
    query.first({
        success: function (object) {
            object.set("flagged", true);
            object.save();
        },
        error: function (object, error) {
            console.log("Error flagging object after report creation.");
        }
    });
});

// Once a report is dismissed via an action (hiding and object or removing it)
// we need to dismiss all of the reports pointing to the object already affected
Parse.Cloud.define("removeRelatedReports", function (request, response) {
    
    var referencedObjectId = request.params.referenceId;
    
    var Report = Parse.Object.extend("report");
    var queryReports = new Parse.Query(Report).equalTo("referenceId", referencedObjectId).find();
    
    Parse.Promise.when([queryReports]).then(
        function (reports) {
            
            removeObjectReports(reports);
            response.success();
            
        }, function (error) {
            response.error(error);
        });
});



Parse.Cloud.define("retrieveFAQdata", function (request, response) {
    
    
    var faqDataArray = [
    {
    	"question":"Why do we need full access to install the LIT Keyboard?",
    	"answer":"We aren't logging any keystrokes or sending them to our servers. Apple only allows third-party keyboards to access the internet if they have \"Full Access\" turned on. LIT needs internet access because all the content are fetched from the cloud (and cached locally on your device). And we don't see what you type when you use another keyboards."
    },
    {
    	"question":"How do I install the Lit Keyboard?",
    	"answer":"To install the LIT keyboard, go to Settings > General > Keyboard > Keyboards > Add New Keyboard... > LIT > Press LIT Keyboard > Allow Full Access On."
    },
    {
    	"question":"How do I switch keyboards to the LIT Keyboard?",
    	"answer":"Hold down on the 🌐 in your Apple Keyboard and select \"LITKeyboard\"."
    },
    {
    	"question":"How do I switch keyboards when I'm in the LIT Keyboard?",
    	"answer":"Switching keyboards is easy! Simply, swipe left and right to scroll through your installed keyboards. Tip: The colors let you know when you're on a different keyboard."
    },
    {
    	"question":"What's a good shortcut to favorite content I see in the LIT Keyboard or in the keyboard feed?",
    	"answer":"If you really love a piece of content, we recommend you favorite it. You can do this in the keyboard extension or keyboard feed by holding down on a piece of content, then pressing \"Add to favorites\"."
    },
    {
    	"question":"Why do my installed keyboards change sometimes?",
    	"answer":"If you've installed another user's keyboard from the LIT app, that user curates what content is and isn't included dynamically. Once you install another user's keyboard you are \"subscribed\" to any changes the keyboard creator makes - but only when you open the app the changes take effect. If they delete, edit or update the content, your installed keyboard will reflect these changes. Tip: If you love some content, we recommend holding down on the piece of content and adding it to your favorites - that way you have it in your favorites keyboard forever!"
    },
    {
    	"question":"Why do I need to open the app for my keyboards to update?",
    	"answer":"To provide the best possible experience, we wanted to make sure that your keyboard was stable and working in the worst data connection settings (like subways, tunnels, etc...). Your keyboard even works when you're in airplane mode ✈ ."
    },
    {
    	"question":"How do I share content to other apps like WhatsApp and Facebook?",
    	"answer":"To share content to other apps, simply hold down on a piece of content in the feed. Different networks have different methods of content distribution, so most of the content will be saved to your camera roll. You can easily access these in any of your networks by pressing the respective upload button in each app, then selecting the saved content from your camera roll."
    },
    {
    	"question":"Why do I need to copy and paste soundbites and dubs and not lyrics?",
    	"answer":"Per Apple restrictions, users must copy and paste any content that is not solely text in nature."
    },
    {
    	"question":"How do I install a keyboard from the LIT app?",
    	"answer":"Installing a keyboard is as simple as clicking \"Install\", which can be found in the top right of a keyboard in the main LIT application."
    },
    {
    	"question":"How many keyboards can I have?",
    	"answer":"You can have an unlimited number of keyboards, but we recommend 5-10 for a lit use of the product."
    },
    {
    	"question":"How many pieces of content per keyboard?",
    	"answer":"Keyboards can have up to six pieces of content. No more, but can be less."
    },
    {
    	"question":"What's special about the favorites keyboard?",
    	"answer":"The favorites keyboard is lit. There's no maximum for content there, as it's just what you love."
    },
    {
    	"question":"What is the \"LIT Keyboard\" (I never installed that keyboard)?",
    	"answer":"Every install of LIT comes with a curated keyboard, in order to remove the difficulty of curation."
    }
    ];
    
    response.success(faqDataArray);
});


Parse.Cloud.job("updateCreationEntries", function(request, status) {
    // Set up to modify user data
    Parse.Cloud.useMasterKey();
    var counter = 0;
    // Query for all users
    var query = new Parse.Query(Parse.User);
    query.find().then(function(users) {
        status.message('Going for a user');
        var userPromises = [];
        users.forEach(function(user) {
            status.message(user.get('username') + " will be processed.");
            var soundbitesQueryPromise = new Parse.Query("soundbite").equalTo("user", user).addAscending("updatedAt").find();
            var dubsQueryPromise = new Parse.Query("dub").equalTo("user", user).addAscending("updatedAt").find();
            var lyricsQueryPromise = new Parse.Query("lyric").equalTo("user", user).addAscending("updatedAt").find();
            userPromises.push(Parse.Promise.when([soundbitesQueryPromise, 
                                                    dubsQueryPromise, 
                                                    lyricsQueryPromise]).then(function(soundbites, dubs, lyrics) {
                                                        var objectPromises = [];
                                                        soundbites.forEach(function(soundbite) {
                                                            objectPromises.push(insertInUserCreatedContent(user, soundbite));
                                                        });
                                                        dubs.forEach(function(dub) {
                                                            objectPromises.push(insertInUserCreatedContent(user, dub));
                                                        });
                                                        lyrics.forEach(function(lyric) {
                                                            objectPromises.push(insertInUserCreatedContent(user, lyric));
                                                        });
                                                        return Parse.Promise.when(objectPromises);
                                                    }));
        });
        Parse.Promise.when(userPromises).then(function() {
            status.success('YEAH');
        });
    });
});


function updateObjectUses(request,className) {

    var ObjectClass = Parse.Object.extend(className);
    var objectId = "";
    
    if(className == "lyric") {objectId = request.object.get("lyric").id;}
    else if(className == "soundbite") {objectId = request.object.get("soundbite").id;}
    else if(className == "dub") {objectId = request.object.get("dub").id;}

    var query = new Parse.Query(ObjectClass);
    query.equalTo("objectId", objectId);
    query.first({
        success: function (object) {
            object.increment("uses");
            object.save();
        },
        error: function (object, error) {
            response.error("Error " + error.code + ' a ' + error.message);
        }
    });
}


function updateObjectDownloads(request,className) {

    var ObjectClass = Parse.Object.extend(className);
    var objectId = "";
    
    if(className == "lyric") {objectId = request.object.get("lyric").id;}
    else if(className == "soundbite") {objectId = request.object.get("soundbite").id;}
    else if(className == "dub") {objectId = request.object.get("dub").id;}

    var query = new Parse.Query(ObjectClass);
    query.equalTo("objectId", objectId);
    query.first({
        success: function (object) {
            object.increment("downloads");
            object.save();
        },
        error: function (object, error) {
            response.error("Error " + error.code + ' a ' + error.message);
        }
    });
}


function updateUserPoints(request,identifier) {
    
    Parse.Cloud.useMasterKey();
    
    switch(identifier){
     
        case pointsDubCreationIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsDubCreation;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save();
            break;
            
        case pointsSoundbiteCreationIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsSoundbiteCreation;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save();
            break;
            
        case pointsLyricCreationIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsLyricCreation;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save();
            break;
            
        case pointsConnectToSocialNetworkIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.object.get("pointsCount"));
            var newPoints = userPoints + pointsConnectToSocialNetwork;
            request.object.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.object.save();
            
        case pointsInstallingKeyboardIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsInstallingKeyboardInstaller;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save(null, {
                success : function(obj) {

                    var installedKeyboardId = request.object.get("keyboard").id;
                    
                    var Keyboard = Parse.Object.extend("keyboard");
                    var User = Parse.Object.extend("_User");

                    var query = new Parse.Query(Keyboard);
                    query.equalTo("objectId", installedKeyboardId).include("user");
                    query.first({
                        success: function (keyboard) {
                            var keyboardCreator = keyboard.get("user");
                            
                            if(keyboardCreator.id == litUserID){return;}
                            if(keyboardCreator.id != request.user.id) {
                                var keyboardCreatorPoints = parseInt(keyboardCreator.get("pointsCount"));
                                var newKeyboardCreatorPoints = keyboardCreatorPoints + pointsInstallingKeyboardOwner;
                                keyboardCreator.set("pointsCount",newKeyboardCreatorPoints.toString());
                                keyboardCreator.set("points",newKeyboardCreatorPoints);
                                keyboardCreator.save();
                            }
                        },
                        error: function (object, error) {
                            response.error("Error " + error.code + ' a ' + error.message);
                        }
                    });
                },
                error : function(obj, error){
                    console.log("Error: " + error.code + ' a ' + error.message);
                }
            });
            break;
            
        case pointsAddingToKeyboardIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsAddingToKeyboardInstaller;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save(null, {
                success : function(obj) {
                    var downloadedElementId = request.object.get(request.object.className.replace("Download","")).id;
                    
                    var ContentType = Parse.Object.extend(request.object.className.replace("Download",""));

                    var query = new Parse.Query(ContentType);
                    query.equalTo("objectId", downloadedElementId).include("user");
                    query.first({
                        success: function (downloadedElement) {
                            var contentCreator = downloadedElement.get("user");
                            
                            if(contentCreator.id == litUserID){return;}
                            if(contentCreator.id != request.user.id) {
                                var contentCreatorPoints = parseInt(contentCreator.get("pointsCount"));
                                var newContentCreatorPoints = contentCreatorPoints + pointsAddingToKeyboardOwner;
                                contentCreator.set("pointsCount",newContentCreatorPoints.toString());
                                contentCreator.set("points",newContentCreatorPoints);
                                contentCreator.save();
                            }
                        },
                        error: function (object, error) {
                            response.error("Error " + error.code + ' a ' + error.message);
                        }
                    });
                },
                error : function(obj, error){
                    console.log("Error: " + error.code + ' a ' + error.message);
                }
            });
            break;
            
        case pointsAddingToFavsIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsAddingToFavsInstaller;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save(null, {
                success : function(obj) {
                    var favedElementId = request.object.get(request.object.className.replace("Like","")).id;
                    
                    var ContentType = Parse.Object.extend(request.object.className.replace("Like",""));

                    var query = new Parse.Query(ContentType);
                    query.equalTo("objectId", favedElementId).include("user");
                    query.first({
                        success: function (favedElement) {
                            var contentCreator = favedElement.get("user");
                            
                            if(contentCreator.id == litUserID){return;}
                            if(contentCreator.id != request.user.id) {
                                var contentCreatorPoints = parseInt(contentCreator.get("pointsCount"));
                                var newContentCreatorPoints = contentCreatorPoints + pointsAddingToFavsOwner;
                                contentCreator.set("pointsCount",newContentCreatorPoints.toString());
                                contentCreator.set("points",newContentCreatorPoints);
                                contentCreator.save();
                            }
                        },
                        error: function (object, error) {
                            response.error("Error " + error.code + ' a ' + error.message);
                        }
                    });
                },
                error : function(obj, error){
                    console.log("Error: " + error.code + ' a ' + error.message);
                }
            });
            break;
            
        case pointsSharingContentIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsSharingContent;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save();
            break;
            
        case pointsSharingKeyboardIdentifier:
            if(request.user.id == litUserID){return;}
            var userPoints = parseInt(request.user.get("pointsCount"));
            var newPoints = userPoints + pointsSharingKeyboard;
            request.user.set("pointsCount",newPoints.toString());
            request.user.set("points",newPoints);
            request.user.save();
            break;
            
        default:
            break;
    }
}

function capitalize(string) {
    // returns the first letter capitalized + the string from index 1 and out aka. the rest of the string
    return string[0].toUpperCase() + string.substr(1);
}

