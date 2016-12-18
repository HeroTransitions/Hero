# ZCAnimatedLabel
UILabel-like view with easy to extend appear/disappear animation

# Features
* Rich text support (with NSAttributedString)
* Group aniamtion by character/word/line
* Customizable animation start delay for each text block
* Great performance, only changed area is redrawn
* Optional layer-based implementation
* 3D/Geometry transform support (layer based only)
* iOS 5+ compatibility

# Demo

* Default 

![image](http://zippy.gfycat.com/LimitedWigglyGermanshepherd.gif)

* Fall
 
![image](http://zippy.gfycat.com/FantasticGargantuanHog.gif)

* Duang/Spring 

![image](http://zippy.gfycat.com/GrippingMeanJavalina.gif)

* Flyin 

![image](http://zippy.gfycat.com/JampackedCompetentGerbil.gif)

* Focus 

![image](http://zippy.gfycat.com/FeistyShockingGermanshepherd.gif)


* Shapeshift  

![image](http://zippy.gfycat.com/ForkedScalyKagu.gif)

* Reveal 

![image](http://zippy.gfycat.com/GrouchyLastingGrizzlybear.gif)
 
* Thrown

 ![image](http://zippy.gfycat.com/RashDecimalImperatorangel.gif)

* Transparency 

![image](http://zippy.gfycat.com/NeighboringSlightJumpingbean.gif)

* Spin 

![image](http://zippy.gfycat.com/UnderstatedBoldAlpineroadguidetigerbeetle.gif)
* Dash 

![image](http://zippy.gfycat.com/DeadlyUnlinedJunco.gif)
* More to come


# How to use
`ZCAnimatedLabel` is available via CocoaPods. If you don't need all the effect subclasses, simply drag `ZCAnimatedLabel.(h|m)`, `ZCCoreTextLayout.(h|m)` and `ZCEasingUtil.(h|m)` into your project and start customizing your own.


# Subclassing
`ZCAnimatedLabel` has two modes: non-layer based and layer based. In the first mode, `ZCAnimatedLabel` is a flat `UIView`, every stage of animation is drawn using Core Graphics, you can customize redraw area for your animation for better performance. Following methods can be overriden:

* `- (void) textBlockAttributesInit: (ZCTextBlock *) textBlock;`
* `- (void) appearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock;`
* `- (void) disappearStateDrawingForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock;`
* `- (CGRect) redrawAreaForRect: (CGRect) rect textBlock: (ZCTextBlock *) textBlock;`

Second option is layer based, where each text block is a simple `CALayer`, 3D tranform is possible in this mode by setting layer's `transform` property, if redraw area is bigger and not too many text blocks, this can achive a performance gain. Set `self.layerBased` to `YES` and override following methods for customization:

* `- (void) textBlockAttributesInit: (ZCTextBlock *) textBlock;`
* `- (void) appearStateLayerChangesForTextBlock: (ZCTextBlock *) textBlock;`
* `- (void) disappearLayerStateChangesForTextBlock: (ZCTextBlock *) textBlock;`


# Todo
* Merge CALayers no longer animating into a single backing store and reuse CALayer for animating layers. (Even better performance for layerBased implementation)
* More Effects, possily glyph related ones
* Use core animation emmiter



# Thanks to

* [`LTMorhpingLabel`](https://github.com/lexrus/LTMorphingLabel) for heavy inspiration. If you like `ZCAnimatedLabel`, you should definitely this one out. 
* [`AGGeometryKit`](https://github.com/hfossli/AGGeometryKit) for arbitrary shape 3D transform code piece used in `ZCDashLabel`


