export QT_QPA_PLATFORM='eglfs'
export QT_QPA_FB_HIDECURSOR='1'
export QT_QPA_GENERIC_PLUGINS='evdevmouse,evdevkeyboard,evdevkeyboard:/dev/input/lcd_sandwich_buttons,tslib:/dev/input/lcd_sandwich_touchscreen'

#export QT_QPA_EVDEV_KEYBOARD_PARAMETERS="keymap=/etc/lcd_sandwich.qmap"

export QT_QPA_EGLFS_DISABLE_INPUT=1
export QT_QPA_EGLFS_PHYSICAL_WIDTH=105
export QT_QPA_EGLFS_PHYSICAL_HEIGHT=65