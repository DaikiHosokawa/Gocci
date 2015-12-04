



Very Important
==============

- After the next merge (wanke <-> hosokawa) search once again for NSUserDefaults and make sure there is no new reference to user_id or so

Needs Testing
=============

- Icon badge was complety rewritten. Does this still work?


Daiki Hosokawa
==============

- Add some tasks here...

-  

-  


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