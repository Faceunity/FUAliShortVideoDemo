#!/bin/sh
set -e
set -u
set -o pipefail

function on_error {
  echo "$(realpath -mq "${0}"):$1: error: Unexpected failure"
}
trap 'on_error $LINENO' ERR

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
  # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
  # resources to, so exit 0 (signalling the script phase was successful).
  exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalAnimationEffects.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalCaption.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalFilter.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalFont.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalFont_ios8.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalMV.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalPaster.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/tail.png"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/watermark.png"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Animation_Effects"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Caption"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Face_Sticker"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Filter"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/MV"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Sticker"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcCore/AlivcCore.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcCrop/AlivcCropBasic.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcEdit/AlivcEdit.bundle"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/AlivcIconBeauty@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/AlivcIconBeauty@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/alivc_triangle@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/alivc_triangle@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/avcBackIcon@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/avcBackIcon@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/beauty@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/beauty@3xpng.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image_selected@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image_selected@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/default.metallib"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_ cheekbone@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_ cheekbone@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_adjust@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_adjust@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_beauty_white@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_beauty_white@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_bigeye@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_bigeye@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_buffing@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_buffing@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_chin@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_chin@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_height@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_height@3xpng.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_red@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_red@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_width@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_width@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_jaw@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_jaw@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_lips_width@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_lips_width@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_reset@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_reset@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_Ruddy@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_Ruddy@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_shorface@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_shorface@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_slimface@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_slimface@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_thin_nose@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_thin_nose@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderf.fsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderPointf.fsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderPointv.vsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderv.vsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderYUV.fsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderYUV.vsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_beautySkin@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_beautySkin@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_cameraid@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_cameraid@3x.png"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcRecord/AlivcRecord.bundle"
  install_resource "${PODS_ROOT}/AliyunVideoSDKPro/AliyunVideoSDKPro.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/body_slim.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/controller_cpp.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/face_beautification.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/face_makeup.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/fuzzytoonfilter.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/fxaa.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/tongue.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_bgseg_green.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_face_processor.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_face_processor_lite.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_face_recognizer.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_hairseg.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_hand_processor.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_human_processor.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_human_processor_mb_fast.bundle"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalAnimationEffects.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalCaption.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalFilter.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalFont.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalFont_ios8.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalMV.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/LocalPaster.json"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/tail.png"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/watermark.png"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Animation_Effects"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Caption"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Face_Sticker"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Filter"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/MV"
  install_resource "${PODS_ROOT}/../AlivcCore/AlivcCore/Assets/ShortVideoResource/Sticker"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcCore/AlivcCore.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcCrop/AlivcCropBasic.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcEdit/AlivcEdit.bundle"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/AlivcIconBeauty@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/AlivcIconBeauty@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/alivc_triangle@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/alivc_triangle@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/avcBackIcon@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/avcBackIcon@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/beauty@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/beauty@3xpng.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image_selected@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/bg_btn_image_selected@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/default.metallib"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_ cheekbone@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_ cheekbone@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_adjust@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_adjust@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_beauty_white@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_beauty_white@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_bigeye@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_bigeye@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_buffing@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_buffing@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_chin@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_chin@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_height@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_height@3xpng.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_red@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_red@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_width@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_face_width@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_jaw@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_jaw@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_lips_width@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_lips_width@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_reset@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_reset@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_Ruddy@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_Ruddy@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_shorface@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_shorface@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_slimface@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_slimface@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_thin_nose@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/ic_thin_nose@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderf.fsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderPointf.fsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderPointv.vsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderv.vsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderYUV.fsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shaderYUV.vsh"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_beautySkin@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_beautySkin@3x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_cameraid@2x.png"
  install_resource "${PODS_ROOT}/../AlivcRace/AlivcRace/Assets/shortVideo_cameraid@3x.png"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/AlivcRecord/AlivcRecord.bundle"
  install_resource "${PODS_ROOT}/AliyunVideoSDKPro/AliyunVideoSDKPro.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/body_slim.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/controller_cpp.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/face_beautification.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/face_makeup.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/fuzzytoonfilter.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/fxaa.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/graphics/tongue.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_bgseg_green.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_face_processor.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_face_processor_lite.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_face_recognizer.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_hairseg.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_hand_processor.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_human_processor.bundle"
  install_resource "${PODS_ROOT}/FURenderKit/FURenderKit-v8.0.2/Resources/model/ai_human_processor_mb_fast.bundle"
  install_resource "${PODS_ROOT}/SVProgressHUD/SVProgressHUD/SVProgressHUD.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find -L "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
