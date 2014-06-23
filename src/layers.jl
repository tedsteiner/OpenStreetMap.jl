### Julia OpenStreetMap Package ###
### MIT License                 ###
### Copyright 2014              ###

### Standard map display "layers." ###
const LAYER_STANDARD = [ 1 => style( 0x7BB6EF, 4 ), # Soft blue
                         2 => style( 0x66C266, 3 ), # Soft green
                         3 => style( 0xE68080, 3 ), # Soft red
                         4 => style( 0xFF9900, 3 ), # Soft orange
                         5 => style( 0xDADA47, 3 ), # Dark yellow
                         6 => style( 0x999999, 2 ), # Dark gray
                         7 => style( 0xE0E0E0, 2 ), # Light gray
                         8 => style( 0x999999, 1 ) ]# Dark gray

const LAYER_CYCLE = [ 1 => style( 0x006600, 3 ), # Green
                      2 => style( 0x5C85FF, 3 ), # Blue
                      3 => style( 0x5C85FF, 2 ), # Blue
                      4 => style( 0x999999, 2 ) ]# Dark gray

const LAYER_PED = [ 1 => style( 0x999999, 3 ), # Dark gray
                    2 => style( 0x999999, 3 ), # Dark gray
                    3 => style( 0x999999, 2 ), # Dark gray
                    4 => style( 0xE0E0E0, 2 ) ]# Light gray

const LAYER_FEATURES = [ 1 => style( 0x9966FF, 1.5 ), # Lavender
                         2 => style( 0xFF0000, 1.5 ), # Red
                         3 => style( 0x000000, 1.5 ), # Black
                         4 => style( 0xFF66FF, 1.5 ), # Pink
                         5 => style( 0x996633, 1.5 ), # Brown
                         6 => style( 0xFF9900, 2.0 ), # Orange
                         7 => style( 0xCC00CC, 1.5 ) ]# Brown
