Music Player Transition
==============

### Steps:
1. Using storyboard, build your view controllers and views.
  * Drag 1 view to the first VC for the white album background
  * Drag 1 imageView to each VC for the album art
  * Drag 2 labels to each VC for the album title and artist
  * Drag 1 button to each VC for the play/pause button
  * Drag a few more buttons to the second VC for the other media buttons
  * Move all the views to their position and setup the constraints
  * Control-drag the play button to the second VC, select `Present Modally` to create a modal segue
2. In the Identity Inspector, fill in the following:
  * Second VC: set `Hero Enabled` to `On`
  * Back buttons: set `HeroID` to `backButton`
  * Play/pause buttons: set `HeroID` to `playButton`
  * Play button: set `Hero Class` to `rotate(1.6)`
  * Pause button: set `Hero Class` to `rotate(-1.6)`
  * Album art image views: set `HeroID` to `albumArt`
  * Album title labels: set `HeroID` to `albumTitle`
  * Album artist labels: set `HeroID` to `albumArtist`
  * White album backgrounds: set `HeroID` to `albumBackground`

![Music Player Transition Setup](https://github.com/lkzhao/Hero/blob/master/Resources/musicPlayerSetup.png?raw=true)

#### Thats all! Run and see.
Views with matched `heroID` attribute will be automatically transitioned between view controllers.
The `heroClass` attribute gives you more customization on how the transition is handled.
For the playButton, we set the `heroClass` to be `rotate(1.6)`, which adds a rotation animation during the transition. 

Hero also works great programmatically without Storyboard. For detailed explaination about how **Hero ID** & **Hero Class** work and supported animations, read the **[Usage Guide](https://github.com/lkzhao/Hero/blob/master/Resources/guide.md)**, or download the **[Source Code](http://github.com/lkzhao/Hero/zipball/master/)**.
