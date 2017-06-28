Hero creates snapshots of your animating views when performing animations. Use the following four modifiers to change how Hero take these snapshots.

#### useOptimizedSnapshot
    
     With this modifier, Hero will create snapshot optimized for different view type when animating.
     For custom views or views with masking, useOptimizedSnapshot might create snapshots
     that appear differently than the actual view.
     In that case, use .useNormalSnapshot or .useSlowRenderSnapshot to disable the optimization.

#### useNormalSnapshot

     Create snapshot using snapshotView(afterScreenUpdates:).

#### useLayerRenderSnapshot

     Create snapshot using layer.render(in: currentContext).
     This is slower than .useNormalSnapshot but gives more accurate snapshot for some views (eg. UIStackView).

#### useNoSnapshot

     Force Hero to not create any snapshot when animating this view. Hence Hero will animate on the view directly.
     This will mess up the view hierarchy. Therefore, view controllers have to rebuild its view structure after the transition finishes.
