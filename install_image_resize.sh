#!/bin/bash
# Quick Image Resize Extension Install

firebase ext:install firebase/storage-resize-images \
  --params='{
    "IMG_BUCKET": "crystalgrimoire-v3-production.appspot.com",
    "IMG_SIZES": "200x200,400x400,800x800,1200x1200",
    "IMG_DELETE_ORIGINAL": "false",
    "IMG_TYPE": "webp",
    "WEBP_QUALITY": "85",
    "INCLUDE_PATH_LIST": "crystal_uploads,user_photos,collection_images"
  }' \
  --project=crystalgrimoire-v3-production