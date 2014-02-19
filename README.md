SECollectionViewFlowLayout
==========================

A flow layout for UICollectionView that implements swiping-to-select gestures.

##Functionality
###Panning to select
Just touch down and pan and select items in your UICollectionView, much easier than tapping each item
<p align="center"><img src="http://i.minus.com/ihtAacZ6IYagC.gif"/></p>

###Auto-select rows
If you choose you can enable auto-selecting rows, where if you pan to select an entire row you can continue panning down to select whole rows at a time.

<p align="center"><img src="http://i.minus.com/iQps2LYtvBU85.gif"/></p>

###Pan to deselect
Along with panning to select collection view cells, you can choose to enable panning to deselect, where if you start panning from a selected cell, the panning will deselect cells.

<p align="center"><img src="http://i.minus.com/ic3fsBQ4nzrMj.gif"/></p>

###Auto select cells between touches
If you choose you can enable auto selection of cells between a first and second touch. Where all cells between the two touches will be selected.

<p align="center"><img src="http://i.minus.com/ibgqzbf5s9M4cy.gif"/></p>


##SEQBImagePickerController
The example use case (as seen in the gifs) is using SECollectionViewFlowLayout in combination with [QBImagePickerController](https://github.com/questbeat/QBImagePickerController) to select multiple photos from a UIImagePickerController clone. You can use this image picker in your project by adding to your podfile:
<pre>pod 'SEQBImagePickerController' </pre>

##SECollectionViewFlowLayout
You can also use SECollectionViewFlowLayout in your project and use it with your own UICollectionView.
<pre>pod 'SECollectionViewFlowLayout' </pre>

##Usage

When initializing your `UICollectionViewController` using `initWithCollectionViewLayout:`, allocate a new `SECollectionViewFlowLayout`

```objc
UICollectionViewController *collectionViewController = 
[[UICollectionViewController alloc] initWithCollectionViewLayout:
[SECollectionViewFlowLayout layoutWithAutoSelectRows:YES panToDeselect:YES autoSelectCellsBetweenTouches:YES]];
```

##Contributing
Use [Github issues](https://github.com/cewendel/SECollectionViewFlowLayout/issues) to track bugs and feature requests

##Contact

Chris Wendel
- http://twitter.com/CEWendel
- [chriwend@umich.edu](mailto:chriwend@umich.edu)

##Licence

MIT




