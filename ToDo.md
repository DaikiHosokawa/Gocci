

Before upload to the App Store
==============================

- disable logging in logging.swift

- disable other strange stuff in const.h

- check your provisining profiles again

- increase the version!

- complete clean of all builds. build from scratch



Bugs
====

- Take video, enter rest data, return without posting, take video again, old data remains

Very Important
==============

- There is a 140 character limit for the posting message. We do not check this at all at the moment... 

Needs Testing
=============



- Push Messages:
    - Do they produce an icon badge?
    - Does it work if Gocci is in Background AND if Gocci is not running at all?




Would be cool
=============

- Let the users set their profile image from twitter or facebook login. half of the code already exists

Daiki Hosokawa
==============



Markus Wanke
============

- restart the scheduler thread everytime the app enters foreground

- Let the user decide what messages he wants. Gettings 100 likes is not fun maybe, but he probably wants to see the messages

- If the user declines camera and/or mic permission, the user will never be able to take a video

- put all the showPopupWithTransitionStyle code douplicates in an extension

- Mute function

- That the image is downloaded everytime is retarded. No saved url

- Show busy indicator on password relogin, sns relogin, username signup









