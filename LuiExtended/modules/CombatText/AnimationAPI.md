# AnimationObject

Objects that inherit behavior from *AnimationObject*
[AnimationObject3DRotate|#AnimationObject3DRotate], [AnimationObject3DTranslate|#AnimationObject3DTranslate], [AnimationObjectAlpha|#AnimationObjectAlpha], [AnimationObjectColor|#AnimationObjectColor], [AnimationObjectCustom|#AnimationObjectCustom], [AnimationObjectDesaturation|#AnimationObjectDesaturation], [AnimationObjectScale|#AnimationObjectScale], [AnimationObjectScroll|#AnimationObjectScroll], [AnimationObjectSize|#AnimationObjectSize], [AnimationObjectTexture|#AnimationObjectTexture], [AnimationObjectTextureRotate|#AnimationObjectTextureRotate], [AnimationObjectTextureSlide|#AnimationObjectTextureSlide], [AnimationObjectTransformOffset|#AnimationObjectTransformOffset], [AnimationObjectTransformRotation|#AnimationObjectTransformRotation], [AnimationObjectTranslate|#AnimationObjectTranslate]

* GetAnimatedControl()
** *Returns:* *object* *animatedControl*

* GetApplyToChildControlName()
** *Returns:* *string* *applyToChildControlName*

* GetDuration()
** *Returns:* *integer* *durationMs*

* GetEasingFunction()
** *Returns:* *function* *functionRef*

* GetHandler(*string* *eventName*, *string* *name*)
** *Returns:* *function* *functionRef*

* GetTimeline()
** *Returns:* *object* *owningTimeline*

* GetType()
** *Returns:* *[AnimationType|#AnimationType]* *animationObjectType*

* IsEnabled()
** *Returns:* *bool* *isEnabled*

* IsPlaying()
** *Returns:* *bool* *isPlaying*

* SetAnimatedControl(*object* *animatedControl*)

* SetApplyToChildControlName(*string* *applyToChildControlName*)

* SetDuration(*integer* *durationMs*)

* SetEasingFunction(*function* *functionRef*)

* SetEnabled(*bool* *enabled*)

* SetHandler(*string* *eventName*, *function* *functionRef*, *string* *name*, *[ControlHandlerOrder|#ControlHandlerOrder]* *controlHandlerOrder*, *string* *targetName*)

* SetOffsetInParent(*integer* *offset*)

h3. AnimationObject3DRotate

* GetEndPitch()
** *Returns:* *number* *endPitchRadians*

* GetEndRoll()
** *Returns:* *number* *endRollRadians*

* GetEndYaw()
** *Returns:* *number* *endYawRadians*

* GetStartPitch()
** *Returns:* *number* *startPitchRadians*

* GetStartRoll()
** *Returns:* *number* *startRollRadians*

* GetStartYaw()
** *Returns:* *number* *startYawRadians*

* SetEndPitch(*number* *endPitchRadians*)

* SetEndRoll(*number* *endRollRadians*)

* SetEndYaw(*number* *endYawRadians*)

* SetRotationValues(*number* *startPitchRadians*, *number* *startYawRadians*, *number* *startRollRadians*, *number* *endPitchRadians*, *number* *endYawRadians*, *number* *endRollRadians*)

* SetStartPitch(*number* *startPitchRadians*)

* SetStartRoll(*number* *startRollRadians*)

* SetStartYaw(*number* *startYawRadians*)

h3. AnimationObject3DTranslate

* ClearBezierControlPoints()

* GetDeltaOffsetX()
** *Returns:* *number* *deltaX*

* GetDeltaOffsetY()
** *Returns:* *number* *deltaY*

* GetDeltaOffsetZ()
** *Returns:* *number* *deltaZ*

* GetEndOffsetX()
** *Returns:* *number* *endX*

* GetEndOffsetY()
** *Returns:* *number* *endY*

* GetEndOffsetZ()
** *Returns:* *number* *endZ*

* GetStartOffsetX()
** *Returns:* *number* *startX*

* GetStartOffsetY()
** *Returns:* *number* *startY*

* GetStartOffsetZ()
** *Returns:* *number* *startZ*

* GetTranslateDeltas()
** *Returns:* *number* *deltaX*, *number* *deltaY*, *number* *deltaZ*

* SetBezierControlPoint(*luaindex* *index*, *number* *x*, *number* *y*, *number* *z*)

* SetDeltaOffsetX(*number* *deltaX*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetDeltaOffsetY(*number* *deltaY*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetDeltaOffsetZ(*number* *deltaZ*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetEndOffsetX(*number* *endX*)

* SetEndOffsetY(*number* *endY*)

* SetEndOffsetZ(*number* *endZ*)

* SetStartOffsetX(*number* *startX*)

* SetStartOffsetY(*number* *startY*)

* SetStartOffsetZ(*number* *startZ*)

* SetTranslateDeltas(*number* *deltaX*, *number* *deltaY*, *number* *deltaZ*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetTranslateOffsets(*number* *startX*, *number* *startY*, *number* *startZ*, *number* *endX*, *number* *endY*, *number* *endZ*)

h3. AnimationObjectAlpha

* GetEndAlpha()
** *Returns:* *number* *endAlpha*

* GetStartAlpha()
** *Returns:* *number* *startAlpha*

* SetAlphaValues(*number* *startAlpha*, *number* *endAlpha*)

* SetEndAlpha(*number* *endAlpha*)

* SetStartAlpha(*number* *startAlpha*)

h3. AnimationObjectColor

* GetApplyAlpha()
** *Returns:* *bool* *applyAlpha*

* GetEndColor()
** *Returns:* *number* *endR*, *number* *endG*, *number* *endB*, *number* *endA*

* GetStartColor()
** *Returns:* *number* *startR*, *number* *startG*, *number* *startB*, *number* *startA*

* SetApplyAlpha(*bool* *applyAlpha*)

* SetColorValues(*number* *startR*, *number* *startG*, *number* *startB*, *number* *startA*, *number* *endR*, *number* *endG*, *number* *endB*, *number* *endA*)

* SetEndColor(*number* *endR*, *number* *endG*, *number* *endB*, *number* *endA*)

* SetStartColor(*number* *startR*, *number* *startG*, *number* *startB*, *number* *startA*)

h3. AnimationObjectCustom

* SetUpdateFunction(*function* *functionRef*)

h3. AnimationObjectDesaturation

* GetEndDesaturation()
** *Returns:* *number* *endDesaturation*

* GetStartDesaturation()
** *Returns:* *number* *startDesaturation*

* SetDesaturationValues(*number* *startDesaturation*, *number* *endDesaturation*)

* SetEndDesaturation(*number* *endDesaturation*)

* SetStartDesaturation(*number* *startDesaturation*)

h3. AnimationObjectScale

* GetEndScale()
** *Returns:* *number* *endScale*

* GetStartScale()
** *Returns:* *number* *startScale*

* SetEndScale(*number* *endScale*)

* SetScaleValues(*number* *startScale*, *number* *endScale*)

* SetStartScale(*number* *startScale*)

h3. AnimationObjectScroll

* SetHorizontalEnd(*number* *endX*)

* SetHorizontalRelative(*number* *offsetX*)

* SetHorizontalStartAndEnd(*number* *startX*, *number* *endX*)

* SetVerticalEnd(*number* *endY*)

* SetVerticalRelative(*number* *offsetY*)

* SetVerticalStartAndEnd(*number* *startY*, *number* *endY*)

h3. AnimationObjectSize

* SetEndHeight(*number* *endHeight*)

* SetEndWidth(*number* *endWidth*)

* SetStartAndEndHeight(*number* *startHeight*, *number* *endHeight*)

* SetStartAndEndWidth(*number* *startWidth*, *number* *endWidth*)

* SetStartHeight(*number* *startHeight*)

* SetStartWidth(*number* *startWidth*)

h3. AnimationObjectTexture

* GetCellsHigh()
** *Returns:* *integer* *aNumCellsHigh*

* GetCellsWide()
** *Returns:* *integer* *aNumCellsWide*

* IsMirroringAlongX()
** *Returns:* *bool* *mirroring*

* IsMirroringAlongY()
** *Returns:* *bool* *mirroring*

* SetCellsHigh(*integer* *aNumCellsHigh*)

* SetCellsWide(*integer* *aNumCellsWide*)

* SetFramerate(*number* *framesPerSecond*)

* SetImageData(*integer* *aNumCellsWide*, *integer* *aNumCellsHigh*)

* SetMirrorAlongX(*bool* *mirroring*)

* SetMirrorAlongY(*bool* *mirroring*)

h3. AnimationObjectTextureRotate

* GetEndRotation()
** *Returns:* *number* *endRadians*

* GetStartRotation()
** *Returns:* *number* *startRadians*

* SetEndRotation(*number* *endRadians*)

* SetRotationValues(*number* *startRadians*, *number* *endRadians*)

* SetStartRotation(*number* *startRadians*)

h3. AnimationObjectTextureSlide

* SetBaseTextureCoords(*number* *left*, *number* *right*, *number* *top*, *number* *bottom*)

* SetDeltaUFromStart(*number* *slideDistanceU*)

* SetDeltaVFromStart(*number* *slideDistanceV*)

* SetSlideDistances(*number* *slideDistanceU*, *number* *slideDistanceV*)

h3. AnimationObjectTransformOffset

* GetEndOffset()
** *Returns:* *number:nilable* *endX*, *number:nilable* *endY*, *number:nilable* *endZ*

* GetStartOffset()
** *Returns:* *number:nilable* *startX*, *number:nilable* *startY*, *number:nilable* *startZ*

* SetEndOffset(*layout_measurement* *endX*, *layout_measurement* *endY*, *layout_measurement* *endZ*)

* SetEndOffsetX(*layout_measurement* *endX*)

* SetEndOffsetY(*layout_measurement* *endY*)

* SetEndOffsetZ(*layout_measurement* *endZ*)

* SetOffsets(*layout_measurement* *startX*, *layout_measurement* *startY*, *layout_measurement* *startZ*, *layout_measurement* *endX*, *layout_measurement* *endY*, *layout_measurement* *endZ*)

* SetStartOffset(*layout_measurement* *startX*, *layout_measurement* *startY*, *layout_measurement* *startZ*)

* SetStartOffsetX(*layout_measurement* *startX*)

* SetStartOffsetY(*layout_measurement* *startY*)

* SetStartOffsetZ(*layout_measurement* *startZ*)

h3. AnimationObjectTransformRotation

* SetEndRotation(*number* *endXRadians*, *number* *endYRadians*, *number* *endZRadians*)

* SetEndX(*number* *endXRadians*)

* SetEndY(*number* *endYRadians*)

* SetEndZ(*number* *endZRadians*)

* SetMode(*[RotationAnimationMode|#RotationAnimationMode]* *mode*)

* SetRotations(*number* *startXRadians*, *number* *startYRadians*, *number* *startZRadians*, *number* *endXRadians*, *number* *endYRadians*, *number* *endZRadians*)

* SetStartRotation(*number* *startXRadians*, *number* *startYRadians*, *number* *startZRadians*)

* SetStartX(*number* *startXRadians*)

* SetStartY(*number* *startYRadians*)

* SetStartZ(*number* *startZRadians*)

h3. AnimationObjectTransformScale

* SetEndScale(*number* *endScale*)

* SetEndScaleX(*number* *endScaleX*)

* SetEndScaleY(*number* *endScaleY*)

* SetStartScale(*number* *startScale*)

* SetStartScaleX(*number* *startScaleX*)

* SetStartScaleY(*number* *startScaleY*)

h3. AnimationObjectTransformSkew

* SetEndSkewX(*number* *endSkewXRadians*)

* SetEndSkewY(*number* *endSkewYRadians*)

* SetStartSkewX(*number* *startSkewXRadians*)

* SetStartSkewY(*number* *startSkewYRadians*)

h3. AnimationObjectTranslate

* GetAnchorIndex()
** *Returns:* *integer* *anchorIndex*

* GetDeltaOffsetX()
** *Returns:* *number* *deltaX*

* GetDeltaOffsetY()
** *Returns:* *number* *deltaY*

* GetEndOffsetX()
** *Returns:* *number* *endX*

* GetEndOffsetY()
** *Returns:* *number* *endY*

* GetStartOffsetX()
** *Returns:* *number* *startX*

* GetStartOffsetY()
** *Returns:* *number* *startY*

* GetTranslateDeltas()
** *Returns:* *number* *deltaX*, *number* *deltaY*

* SetAnchorIndex(*integer* *anchorIndex*)

* SetDeltaOffsetX(*layout_measurement* *deltaX*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetDeltaOffsetXFromEnd(*layout_measurement* *deltaX*)

* SetDeltaOffsetXFromStart(*layout_measurement* *deltaX*)

* SetDeltaOffsetY(*layout_measurement* *deltaY*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetDeltaOffsetYFromEnd(*layout_measurement* *deltaY*)

* SetDeltaOffsetYFromStart(*layout_measurement* *deltaY*)

* SetEndOffsetX(*layout_measurement* *endX*)

* SetEndOffsetY(*layout_measurement* *endY*)

* SetStartOffsetX(*layout_measurement* *startX*)

* SetStartOffsetY(*layout_measurement* *startY*)

* SetTranslateDeltas(*layout_measurement* *deltaX*, *layout_measurement* *deltaY*, *[TranslateAnimationDeltaType|#TranslateAnimationDeltaType]* *translateAnimationDeltaType*)

* SetTranslateOffsets(*layout_measurement* *startX*, *layout_measurement* *startY*, *layout_measurement* *endX*, *layout_measurement* *endY*)

h3. AnimationTimeline

* ApplyAllAnimationsToControl(*object* *animatedControl*)

* ClearAllCallbacks()

* ClearAnimatedControlFromAllAnimations()

* GetAnimation(*luaindex* *animationIndex*)
** *Returns:* *object* *animation*

* GetAnimationOffset(*object* *animation*)
** *Returns:* *integer* *offset*

* GetAnimationTimeline(*luaindex* *timelineIndex*)
** *Returns:* *object* *timeline*

* GetAnimationTimelineOffset(*object* *animation*)
** *Returns:* *integer* *offset*

* GetDuration()
** *Returns:* *integer* *duration*

* GetFirstAnimation()
** *Returns:* *object* *animation*

* GetFirstAnimationOfType(*[AnimationType|#AnimationType]* *animationType*)
** *Returns:* *object* *animation*

* GetFirstAnimationTimeline()
** *Returns:* *object* *timeline*

* GetFullProgress()
** *Returns:* *number* *progress*

* GetHandler(*string* *eventName*, *string* *name*)
** *Returns:* *function* *functionRef*

* GetLastAnimation()
** *Returns:* *object* *animation*

* GetLastAnimationTimeline()
** *Returns:* *object* *timeline*

* GetMinDuration()
** *Returns:* *integer* *minDuration*

* GetNumAnimationTimelines()
** *Returns:* *integer* *numTimelines*

* GetNumAnimations()
** *Returns:* *integer* *numAnimations*

* GetParent()
** *Returns:* *object* *timeline*

* GetPlaybackLoopsRemaining()
** *Returns:* *integer* *loopsRemaining*

* GetProgress()
** *Returns:* *number* *progress*

* GetSkipAnimationsBehindPlayheadOnInitialPlay()
** *Returns:* *bool* *skipAnimations*

* InsertAnimation(*[AnimationType|#AnimationType]* *animationType*, *object* *animatedControl*, *integer* *offset*)
** *Returns:* *object* *animation*

* InsertAnimationFromVirtual(*string* *animationVirtualName*, *object* *animatedControl*)
** *Returns:* *object* *animation*

* InsertAnimationTimeline(*integer* *offset*, *object* *animatedControl*)
** *Returns:* *object* *animation*

* InsertAnimationTimelineFromVirtual(*string* *animationVirtualName*, *object* *animatedControl*)
** *Returns:* *object* *animation*

* InsertCallback(*function* *functionRef*, *integer* *offset*)
** *Returns:* *function* *functionRefRet*

* IsEnabled()
** *Returns:* *bool* *isEnabled*

* IsPaused()
** *Returns:* *bool* *isPaused*

* IsPlaying()
** *Returns:* *bool* *isPlaying*

* IsPlayingBackward()
** *Returns:* *bool* *reversed*

* Pause()

* PlayBackward()

* PlayForward()

* PlayFromEnd(*integer* *offsetMs*)

* PlayFromStart(*integer* *offsetMs*)

* PlayInstantlyToEnd(*bool* *ignoreCallbacks*)

* PlayInstantlyToStart(*bool* *ignoreCallbacks*)

* Resume()

* SetAllAnimationOffsets(*integer* *offset*)

* SetAnimationOffset(*object* *animation*, *integer* *offset*)

* SetAnimationTimelineOffset(*object* *animation*, *integer* *offset*)

* SetCallbackOffset(*function* *callback*, *integer* *offset*)

* SetEnabled(*bool* *enabled*)

* SetHandler(*string* *eventName*, *function* *functionRef*, *string* *name*, *[ControlHandlerOrder|#ControlHandlerOrder]* *controlHandlerOrder*, *string* *targetName*)

* SetMinDuration(*integer* *minDuration*)

* SetOffsetInParent(*integer* *offset*)

* SetPlaybackLoopCount(*integer* *maxLoopCount*)

* SetPlaybackLoopsRemaining(*integer* *loopsRemaining*)

* SetPlaybackType(*[AnimationPlayback|#AnimationPlayback]* *playbackType*, *integer* *maxLoopCount*)

* SetProgress(*number* *progress*)

* SetSkipAnimationsBehindPlayheadOnInitialPlay(*bool* *skipAnimations*)

* Stop()
