#!/system/bin/sh

SKIPUNZIP=1
ASH_STANDALONE=1
unzip_path="/data/adb"

# Define the paths of source folder and the destination folder
source_folder="/data/adb/FreeLink"
destination_folder="/data/adb/FreeLink$(date +%Y%m%d_%H%M%S)"

# Check if the source folder exists
if [ -d "$source_folder" ]; then
    # If the source folder exists, execute the move operation
    mv "$source_folder" "$destination_folder"
    ui_print "- 正在备份已有文件"
    # Delete old folders and update them
    rm -rf "$source_folder"
else
    # If the source folder does not exist, output initial installation information 
    ui_print "- 正在初始安装"
fi

# Set up service directory and clean old installations
if [ -d "/data/adb/modules/FreeLink" ]; then
  rm -rf "/data/adb/modules/FreeLink"
  ui_print "- 旧模块已删除"
fi

ui_print "- 正在释放文件"
unzip -o "$ZIPFILE" 'FreeLink/*' -d $unzip_path >&2
unzip -o "$ZIPFILE" 'webroot/*' -d "$MODPATH" >&2
unzip -j -o "$ZIPFILE" 'FreeLink.sh' -d /data/adb/service.d >&2
unzip -j -o "$ZIPFILE" 'uninstall.sh' -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "action.sh" -d $MODPATH >&2
unzip -j -o "$ZIPFILE" "module.prop" -d $MODPATH >&2
ui_print "- 正在设置权限"
set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/FreeLink/ 0 3005 0755 0644
set_perm_recursive /data/adb/FreeLink/scripts/ 0 3005 0755 0700
set_perm /data/adb/service.d/FreeLink.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm $MODPATH/action.sh 0 0 0755
set_perm /data/adb/FreeLink/scripts/ 0 0 0755
ui_print "- 完成权限设置"
ui_print "- 还原配置文件"

# Customize module name based on environment
if [ "$KSU" = "true" ]; then
  sed -i "s/name=.*/name=FreeLink for KernelSU/g" $MODPATH/module.prop
elif [ "$APATCH" = "true" ]; then
  sed -i "s/name=.*/name=FreeLink for APatch/g" $MODPATH/module.prop
else
  sed -i "s/name=.*/name=FreeLink for Magisk/g" $MODPATH/module.prop
fi

# 找到文件夹对应的最大的数字
largest_folder=$(find /data/adb -maxdepth 1 -type d -name 'FreeLink[0-9]*' | sed 's/.*FreeLink//' | sed 's/_//g' | sort -nr | head -n 1)

# 使用这个最大的数字，重新匹配回原始文件夹名
if [ -n "$largest_folder" ]; then
  for folder in /data/adb/FreeLink*; do
    clean_name=$(echo "$folder" | sed 's/.*FreeLink//' | sed 's/_//g')
    if [ "$clean_name" = "$largest_folder" ]; then
      ui_print "- Found folder: $folder"
      
      # 覆盖 /data/adb/FreeLink/confs 目录中的内容
      if [ -d "$folder/confs" ]; then
        cp -rf "$folder/confs/"* /data/adb/FreeLink/confs/
        ui_print "- Copied contents of $folder/confs to /data/adb/FreeLink/confs/"
        cp -rf "$folder/xray/"* /data/adb/FreeLink/xray/
        ui_print "- Copied contents of $folder/xray to /data/adb/FreeLink/xray/"
        ui_print "- 成功还原配置文件"
      fi
      break
    fi
  done
else
  ui_print "- 首次安装，无备份配置可还原"
fi

ui_print "- enjoy!"
