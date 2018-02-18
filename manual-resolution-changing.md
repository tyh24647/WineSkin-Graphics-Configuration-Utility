Hey, since resolution switching isn't working for you, here's what should fix it for both apps:

##BFME2:

**Updating the app data**

- Configuring the Options File

 - Right click on the Rise of the Witch King app

 - Click "Show Package Contents"

 - Navigate to "drive_c" --> "Wineskin" --> "My The Lord of the Rings, The Rise of the Witch-king Files"

 - Right-click on "Options.ini", then "Open With" --> "Other..."

 - Click "TextEdit" and open the file

 - Where it says "Resolution", change the values to fit your resolution, such as this example:

    Resolution = 1920 1080

 - Save the file

 - Repeat this process for the "Options.ini" file in "drive_c" --> "Wineskin" --> "My Battle for Middle-earth(tm) II Files"

- Configuring Wineskin

 - Right click the ROTWK app

 - Click "Show Package Contents"

 - Double-click "Wineskin"

 - Click "Advanced"

 - Under "EXE Flags", Type "-xres MyResolutionXValue -yres MyResolutionYValue" -- for example:

    -xres 1920 -yres 1080

 - Click "Test Run" to verify the settings have been changed

- Instead of running the app via the custom port launcher, run the app directly or through the T3A Launcher

--------

BFME1:

- Do the same process as above, but in the BFME1 app

~~Note: You'll only have to do that process in one spot instead of two, since BFME1 doesn't have an expansion pack~~

-----
&nbsp;
 

Let me know whether or not this fixes your issues! 
