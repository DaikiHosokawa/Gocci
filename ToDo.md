



Very Important
==============

- After the next merge (wanke <-> hosokawa) search once again for NSUserDefaults and make sure there is no new reference to user_id or so

Needs Testing
=============

- Icon badge was complety rewritten. Does this still work?


Daiki Hosokawa
==============

<Recorder>

-upload end-> timeline

-入力情報投稿後リセット

-cancel->投稿cancel

<Notification>

-notification->commentのあとに戻れない

-push message test

-mypage/timelineにbadge numを添付 ||testへ

<Action sheet>

-Action sheet icon need

<bottom bar>

-bottom bar design

-Analytics

-Userpage(movie)

-restaurantpage 再生問題

<Other>

-emptyview

-ask Murata about API ver2

-register id を使わない仕様

-near timelineにdistanceを出す

<Collaboration with wanke>

-share(only twitter)->wanke’s advise need

-permission Push notification

-http://test.api.gocci.me/v1/mobile/get/timeline->
 http://test.mobile.api.gocci.me/v1/mobile/get/timeline

-音声流す

-NSUserDefault と　Keychain

-新着→現在地の順にタブ



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