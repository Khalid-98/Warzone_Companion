# warzone_companion

Since the API is dead as we discussed, I implemented a bunch of maps to act as data source.
This removes earlier restrictions of exact gamertag and platform, since there is no API call.

I also changed cupertino_icons: to  ^1.0.0 in order to avoid the same error with Part C.
All dependencies' versions are exactly specified.

For this part I created a settings drawer that is accessible through FloatingActionbutton.

First choice will trigger immediate background update and trigger a notification.

Second choice schedules a background database update every 15 minutes.
Note that first one triggers after 5 seconds. Of course the user is notified after each operation.

Third choice cancels all background operations.

Fourth choice schedules a standalone notification, just in case. 

Fifth choice views device info, i.e. battery and connection status. 

Lastly I want offer my gratitude. You have been understanding and supporting for me throughout
the semester. This could have never happened without your help. THANK YOU HOCAM !!

Khalid Ghanem
110510273
 "# Warzone_Companion" 
