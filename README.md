# sensor_driven_music_player

****Project Overview:****

The Sensor Driven Music Player, has integrated sensor data (accelerometer)  to control the tempo of a rhythmic sound loop. Users can explore and play various sounds from the Audio list page, dynamically altering the music's speed based on their device's sensor input.

**User Interface:**
The App has 2 screens as follows 
1. Audio List Screen
2. Audio Player Screen

_Audio List Screen:_
In this screen the user can find the list of audio files from which he has to select one audio to play

_Audio Player Screen:_
This  Screen will play the audio and control the tempo based on Accelerometer Sensor data.The user will also be able to see the all three Axis Values on the screen.


_Frontend Technology:_ Flutter

_Platform Tested:_ Android

**Sensor Integration:**

Accessing and collecting data from the mobile device's accelerometer, I mapped this data to modify the speed of the selected sound loop.
The Playback rate is normal, only whenthe mobile device is stable on any axis.
The Audio Playback rate increases when the mobile device starts to be unstable(not completely aligned with any one axis).

**Sensor Used:** Accelerometer

**Functionality:**
Utilizing the freesound.org API to fetch the list of sounds in the first page
Based on selected audio fetching the audio details
The app allows users to play, pause, and dynamically alter the tempo of the loop based on real-time sensor data.




**Github link:** https://github.com/mprem1204/sensor_driven_music_player.git

**Video Link:**

https://drive.google.com/file/d/13ckdw_6T8PUs2TrcU0XeAiPCWmW7n-Hh/view?usp=sharing ,

https://drive.google.com/file/d/16RWm1ExCpHo37JssJPNmaANHARnYhgwv/view?usp=drive_link

**APK Link:**
https://drive.google.com/file/d/1KJZXAPGr0TJxypNxbV9-tT9gXxHxWzjT/view?usp=sharing


**Instructions to Run the App in Android:**

1. Ensure you have the Android and Flutter SDK installed
2. Clone the repo<br />
git clone https://github.com/mprem1204/sensor_driven_music_player.git <br />
cd sensor-driven-music-player
4. Install dependencies<br />
flutter pub get
5. Connect your phone to the system with USB cable
6. Run the application<br />
flutter run


**Further enhancements:**

Would like to change different parameters for every axis like change the tempo for x-axis, volume for y-axis, pitch or some other param for z-axis
Would like to implement Streams If asked to play an entire song instead of preview audio
Improve the UI of the Pages

