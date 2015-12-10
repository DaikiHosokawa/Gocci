



Very Important
==============

- After the next merge (wanke <-> hosokawa) search once again for NSUserDefaults and make sure there is no new reference to user_id or so

Needs Testing
=============

- Icon badge was complety rewritten. Does this still work?


Daiki Hosokawa
==============

<Recorder>

-post test

<Notification>

-push message test 

<bottom bar>

-bottom bar design

<Other>

-Analytics

-sort button

-Userpage(movie)

-restaurantpage 再生問題

-requestpopupのgpsの画像

-emptyview


<Collaboration with wanke>

-share(only twitter)->wanke’s advise need

-http://test.api.gocci.me/v1/mobile/get/timeline->
 http://test.mobile.api.gocci.me/v1/mobile/get/timeline

-音声問題

-NSUserDefault と　Keychain



Markus Wanke
============


 -  Remove the Facebook Sharekit when we get [publish_permission]

 -  Call the new register_device_token URI when the device token changes

 -  why is post_time set in user defaults, try to remove that. look for
    [[NSUserDefaults standardUserDefaults] setValue:nowString forKey:@"post_time"];

 -  You removed setting the FB_CONSUMER_KEY from AppDelegate. that means get rid of SNSUtil now

 -  That the image is downloaded everytime is retarded. No saved url

 -  

 -  

 -  

 -  

 -  

 -  