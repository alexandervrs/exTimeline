#define ex_timeline_ds_grid_delete_y
///ex_timeline_ds_grid_delete_y(DSGridIndex, y, shift)

/*
 * Removes a row at Y position from a DS grid
 *
 * @param   gridIndex  The DS grid index, real
 * @param   y          The Y position on the DS grid, real
 * @param   shift      (optional) Whether to shift the rest of the grid, boolean
 * 
 * @return  Returns 1 on success, 0 if reached and removed first item, real
 */

var _grid   = argument[0];
var _y      = argument[1];
var _shift  = false;

if (argument_count >= 3) {
    _shift = argument[2];
}

var _grid_width  = ds_grid_width(_grid);
var _grid_height = ds_grid_height(_grid);

if (_grid_height < 2) {

    ds_grid_clear(_grid, "");
    ds_grid_resize(_grid, ds_grid_width(_grid), 1);

    return 0;
}


if (_shift == true) {

    ds_grid_set_grid_region(_grid, _grid, 0, _y+1, _grid_width-1, _y+1, 0, _y);
    for (var _i=_y; _i <= ds_grid_height(_grid); ++_i) {
        ds_grid_set_grid_region(_grid, _grid, 0, _i+1, _grid_width-1, _i+1, 0, _i);    
    }
    
} else {
    
    ds_grid_set_grid_region(_grid, _grid, 0, _y+1, _grid_width-1, _grid_height-_y, 0, _y);
    
}

ds_grid_resize(_grid, _grid_width, _grid_height-1);

return 1;


#define ex_timeline_string_split
///ex_timeline_string_split(string, delimiter)

/**
 * Splits the input string into an array by a delimiter
 *
 * @param   string     The input string, string
 * @param   delimiter  (optional) The delimiter to split at, string
 * 
 * @return  Returns the string parts, array
 */

var _string = argument[0];
var _delimiter = ",";

if (argument_count >= 2) {
    _delimiter = argument[1];
}

var _position = string_pos(_delimiter, _string);
var _array;

if (_position == 0) {
    _array[0] = _string; 
    return _array;
}

var _delimiter_length = string_length(_delimiter);
var _array_length = 0;

while (true) {

    _array[_array_length++] = string_copy(_string, 1, _position - 1);
    _string = string_copy(_string, _position + _delimiter_length, string_length(_string) - _position - _delimiter_length + 1);
    _position = string_pos(_delimiter, _string);
    
    if (_position == 0) {
        _array[_array_length] = _string;
        return _array;
    }
}

#define ex_timeline_suspend_all
///ex_timeline_suspend_all()

with (obj_ex_timeline) {
    _suspended = true;
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Suspended all timelines');
}

return 1;




#define ex_timeline_class_add_timeline
///ex_timeline_class_add_timeline(timelineName, className)

var _name           = argument[0];
var _class_name     = argument[1];
var _list           = obj_ex_timeline._ex_timelines;
var _classes_list   = obj_ex_timeline._ex_timeline_classes;
var _class_list     = -1;
var _resource       = -1;
var _autoincrement  = 0;

// check name column of classes parent grid
_class_list = ex_timeline_class_get_index(_class_name);

// get asset resource
_resource = ex_timeline_get_asset_index(_name);

// resize class list and set autoincrement
if (ds_grid_height(_class_list) <= 0) {
    ds_grid_resize(_class_list, 4, 1);
    ds_grid_clear(_class_list, "");
} else {
    ds_grid_resize(_class_list, 4, ds_grid_height(_class_list)+1);
    _autoincrement = ds_grid_height(_class_list)-1;
}

// add resource to class list
ds_grid_set(_class_list, 0, _autoincrement, _name);           // name
ds_grid_set(_class_list, 1, _autoincrement, _resource);       // resource id
ds_grid_set(_class_list, 2, _autoincrement, 0);               // has played
ds_grid_set(_class_list, 3, _autoincrement, 0);               // is latter

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Added timeline with name "'+string( _name )+'" to timeline class "'+_class_name+'" ['+string( _class_list)+ ', ' +string( _autoincrement )+']'+'');
}

// return grid y position
return _autoincrement;



#define ex_timeline_class_count
///ex_timeline_class_count()

var _classes_list = obj_ex_timeline._ex_timeline_classes;

if (not ds_exists(_classes_list, ds_type_grid)) {
    return 0;
}

if (ds_grid_height(_classes_list) < 2) {

	if (ds_grid_get(_classes_list, 0, 0) == "") {
	return 0;
	}

}

return ds_grid_height(_classes_list);



#define ex_timeline_class_create
///ex_timeline_class_create(className)

var _list           = obj_ex_timeline._ex_timeline_classes;
var _list_max_size  = 2;
var _name           = argument[0];
var _class_list     = -1;
var _autoincrement  = 0;

// create or update the classes list
if (ds_exists(_list, ds_type_grid)) {
    
// workaround
if (ds_grid_get(_list, 0, 0) == "") {

} else {

ds_grid_resize(_list, _list_max_size, ds_grid_height(_list)+1);
_autoincrement = ds_grid_height(_list)-1;

}
    
} else {
    obj_ex_timeline._ex_timeline_classes = ds_grid_create(_list_max_size, 1);
    _list = obj_ex_timeline._ex_timeline_classes;
}

// create a new class grid
_class_list = ds_grid_create(4, 0);

// add new grid
ds_grid_set(_list, 0, _autoincrement, _name);       // name
ds_grid_set(_list, 1, _autoincrement, _class_list); // class grid

var _y = ds_grid_value_y(_list, 0, 0, 1, ds_grid_height(_list), string( _name ));

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Created timeline class with name "'+string( _name )+'" ['+string( _y )+']');
}



#define ex_timeline_class_destroy
///ex_timeline_class_destroy(className)

var _class_name     = argument[0];
var _classes_list   = obj_ex_timeline._ex_timeline_classes;
var _class_list     = -1;

if (not ex_timeline_class_exists(_class_name)) {
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Trying to destroy class but timeline class with name "'+string( _class_name )+'" does not exist');
    }
    return 0;
}

// check name column of classes parent grid
var _y = ds_grid_value_y(_classes_list, 0, 0, 1, ds_grid_height(_classes_list), string( _class_name ));

_class_list = ds_grid_get(_classes_list, 1, _y);

// remove class index
if (ds_grid_height(_classes_list) < 2) {

    ds_grid_clear(_classes_list, "");
    ds_grid_resize(_classes_list, ds_grid_width(_classes_list), 1);

} else {
    ex_timeline_ds_grid_delete_y(_classes_list, _y, true);
}

ds_grid_destroy(_class_list);

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Destroyed timeline class with name "'+string( _class_name )+'" ['+string( _y )+']');
}

return 1;



#define ex_timeline_class_exists
///ex_timeline_class_exists(className)

var _name = argument[0];
var _list = ex_timeline_class_get_index(_name);

if (_list < 0) {
    return 0;    
} else {
    return 1;
}



#define ex_timeline_class_get_index
///ex_timeline_class_get_index(className)

var _class_name     = argument[0];
var _classes_list   = obj_ex_timeline._ex_timeline_classes;
var _class_list     = -1;

// check if classes exist first
if (ex_timeline_class_count() < 1) {
    return -1;
}

// check name column of classes parent grid
var _cy = ds_grid_value_y(_classes_list, 0, 0, 0, ds_grid_height(_classes_list), string( _class_name ));
if (_cy < 0) {
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline class with name "'+string( _class_name )+'"');
    }
    return -1;
}

// get class list
_class_list = ds_grid_get(_classes_list, 1, _cy);

return _class_list;



#define ex_timeline_class_pause
///ex_timeline_class_pause(className)

var _name = argument[0];
var _list = ex_timeline_class_get_index(_name);

if (_list < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_pause( ds_grid_get(_list, 0, _i) );
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Paused all timelines with class "'+string( _name )+'", '+string( _result )+' in total');
}

return _result;



#define ex_timeline_class_play
///ex_timeline_class_play(className, speed, position, loop)

var _name              = argument[0];
var _list              = ex_timeline_class_get_index(_name);
var _timeline_speed    = 1;
var _timeline_position = 0;
var _timeline_loop     = false;

if (argument_count >= 2) {
    _timeline_speed = argument[1];
}

if (argument_count >= 3) {
    _timeline_position = argument[2];
}

if (argument_count >= 4) {
    _timeline_loop = argument[3];
}

if (_list < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_play(ds_grid_get(_list, 0, _i), _timeline_speed, _timeline_position, _timeline_loop);
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Playing all timelines with class "'+string( _name )+'", '+string( _result )+' in total, looping "'+string(_timeline_loop)+'"');
}

return _result;



#define ex_timeline_class_resume
///ex_timeline_class_resume(className)

var _name = argument[0];
var _list = ex_timeline_class_get_index(_name);

//ds resize bug workaround
if (ds_grid_get(_list, 0, 0) == "" and ds_grid_height(_list) < 2) {
	
	if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Warning, no timelines exist in class with name "'+string( _name )+'"');
    }
	
	return 0;
}

if (_list < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_resume( ds_grid_get(_list, 0, _i) );
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Resumed all timelines with class "'+string( _name )+'", '+string( _result )+' in total');
}

return _result;



#define ex_timeline_class_set_loop
///ex_timeline_class_set_loop(className, value)

var _name  = argument[0];
var _value = argument[1];
var _list  = ex_timeline_class_get_index(_name);

//ds resize bug workaround
if (ds_grid_get(_list, 0, 0) == "" and ds_grid_height(_list) < 2) {

if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Warning, no timelines exist in class with name "'+string( _name )+'"');
    }

return 0;
}

if (_list < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_set_loop( ds_grid_get(_list, 0, _i), _value );
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Set loop to '+string( _value )+' all timelines with class "'+string( _name )+'", '+string( _result )+' in total');
}

return _result;



#define ex_timeline_class_set_position
///ex_timeline_class_set_position(className, value)

var _name  = argument[0];
var _value = argument[1];
var _list  = ex_timeline_class_get_index(_name);

//ds resize bug workaround
if (ds_grid_get(_list, 0, 0) == "" and ds_grid_height(_list) < 2) {

if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Warning, no timelines exist in class with name "'+string( _name )+'"');
    }

return 0;
}

if (_list < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_set_position( ds_grid_get(_list, 0, _i), _value );
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Set position to '+string( _value )+' all timelines with class "'+string( _name )+'", '+string( _result )+' in total');
}

return _result;



#define ex_timeline_class_set_speed
///ex_timeline_class_set_speed(className, value)

var _name  = argument[0];
var _value = argument[1];
var _list  = ex_timeline_class_get_index(_name);

//ds resize bug workaround
if (ds_grid_get(_list, 0, 0) == "" and ds_grid_height(_list) < 2) {

if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Warning, no timelines exist in class with name "'+string( _name )+'"');
    }

return 0;
}

if (_list < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_set_speed( ds_grid_get(_list, 0, _i), _value );
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Set speed to '+string( _value )+' all timelines with class "'+string( _name )+'", '+string( _result )+' in total');
}

return _result;



#define ex_timeline_class_stop
///ex_timeline_class_stop(className)

var _name = argument[0];
var _list = ex_timeline_class_get_index(_name);

if (_list < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, trying to access non-existing class with name "'+string( _name )+'"');
    }
    
    return 0;

}

var _list_size = ds_grid_height(_list);
var _result    = 0;

// loop through all timelines in the group
for (var _i=0; _i < _list_size; ++_i) {
    
    _result += 1;
    ex_timeline_stop( ds_grid_get(_list, 0, _i) );
    
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Stopped all timelines with class "'+string( _name )+'", '+string( _result )+' in total');
}

return _result;



#define ex_timeline_count
///ex_timeline_count()

var _list = obj_ex_timeline._ex_timelines;

if (not ds_exists(_list, ds_type_grid)) {
	return 0;
}

if (ds_grid_height(_list) < 2) {

	if (ds_grid_get(_list, 0, 0) == "") {
		return 0;
	}

}

return ds_grid_height(_list);



#define ex_timeline_create
///ex_timeline_create(name, speed, position, loop, syncDelta, classes)

var _list                = obj_ex_timeline._ex_timelines;
var _list_max_size       = _ex_timeline._length;
var _autoincrement       = 0;
var _timeline_name       = argument[0];
var _timeline_speed      = 1;
var _timeline_position   = -1;
var _timeline_loop       = false;
var _timeline_sync_delta = false;
var _timeline_classes    = "";

if (argument_count >= 2) {
    _timeline_speed = argument[1];
}

if (argument_count >= 3) {
    _timeline_position = argument[2];
}

if (argument_count >= 4) {
    _timeline_loop = argument[3];
}

if (argument_count >= 5) {
    _timeline_sync_delta = argument[4];
}

// create or update the timeline list
if (ds_exists(_list, ds_type_grid)) {
    
    // workaround
    if (ds_grid_get(_list, 0, 0) == "") {
    
    } else {
    
    ds_grid_resize(_list, _list_max_size, ds_grid_height(_list)+1);
    _autoincrement = ds_grid_height(_list)-1;
    
    }

} else {
    obj_ex_timeline._ex_timelines = ds_grid_create(_list_max_size, 0);
    _list = obj_ex_timeline._ex_timelines;
    ds_grid_resize(_list, _list_max_size, ds_grid_height(_list)+1);
}


// check if timeline with the same name exists
var _y = ds_grid_value_y(_list, 0, 0, ds_grid_width(_list), ds_grid_height(_list), string( _timeline_name ));
if (_y > -1) {
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, timeline name "'+string( _timeline_name )+'" already exists, timeline names must be unique');
    }
    return -1;
}

_timeline_position -= 1;

// add timeline to the list
_list[# _ex_timeline._name,       _autoincrement]                = _timeline_name;
_list[# _ex_timeline._position,   _autoincrement]                = _timeline_position;
_list[# _ex_timeline._speed,      _autoincrement]                = _timeline_speed;
_list[# _ex_timeline._is_playing, _autoincrement]                = false;
_list[# _ex_timeline._is_paused,  _autoincrement]                = false;
_list[# _ex_timeline._sync,       _autoincrement]                = false;
_list[# _ex_timeline._oncomplete, _autoincrement]                = ds_map_create();
_list[# _ex_timeline._oncomplete_arguments, _autoincrement]      = ds_map_create();
_list[# _ex_timeline._duration, _autoincrement]                  = 0;
_list[# _ex_timeline._loop, _autoincrement]                      = _timeline_loop;
_list[# _ex_timeline._sync_delta, _autoincrement]                = _timeline_sync_delta;
_list[# _ex_timeline._position_previous, _autoincrement]         = _timeline_position;
_list[# _ex_timeline._position_floored, _autoincrement]          = floor(_timeline_position);
_list[# _ex_timeline._position_previous_floored, _autoincrement] = floor(_timeline_position);

// set timeline classes (separated by space)
if (argument_count >= 6) {
    
    if (argument[5] != "") {
        
        if (ex_timeline_class_count() > 0) {

            _timeline_classes = argument[5];

            // add timeline to each class
            var _timeline_classes_array = ex_timeline_string_split(_timeline_classes, " ");
            var _timeline_classes_array_size = array_length_1d(_timeline_classes_array);

            for (var _i=0; _i < _timeline_classes_array_size; ++_i) {
                if (ex_timeline_class_exists(_timeline_classes_array[_i])) {
                    ex_timeline_class_add_timeline(_timeline_name, _timeline_classes_array[_i]);
                    if (ex_timeline_get_debug_mode()) {
                        show_debug_message('Timeline: Added timeline "'+string( _timeline_name )+'" under timeline class "'+_timeline_classes_array[_i]+'"');
                    }
                } else {
                    if (ex_timeline_get_debug_mode()) {
                    show_debug_message('exTimeline: Cannot add timeline "'+string( _timeline_name )+'" to non-existent class "'+_timeline_classes_array[_i]+'", you need to create that class first before adding the timeline');
                    }
                }
            }

        }
        
    }
    
}

if (ex_timeline_get_debug_mode()) {
    var _y = ds_grid_value_y(_list, 0, 0, 1, ds_grid_height(_list), string( _timeline_name ));
    show_debug_message('exTimeline: Created timeline with name "'+string( _timeline_name )+'" ['+string( _y )+']');
}

// return grid y position
return _autoincrement;





#define ex_timeline_destroy
///ex_timeline_destroy(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// also destroy the scripts and arguments DS maps
var _dsmap = _list[# _ex_timeline._oncomplete, _y];

if (ds_exists(_dsmap, ds_type_map)) {
    ds_map_destroy(_dsmap);
}

var _dsmap2 = _list[# _ex_timeline._oncomplete_arguments, _y];

if (ds_exists(_dsmap2, ds_type_map)) {
    ds_map_destroy(_dsmap2);
}

// remove timeline
if (ds_grid_height(_list) < 2) {

    ds_grid_clear(_list, "");
    ds_grid_resize(_list, ds_grid_width(_list), 1);

} else {
    ex_timeline_ds_grid_delete_y(_list, _y, true);
}


if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Destroyed timeline with name "'+string( _name )+'"');
}

return 1;



#define ex_timeline_exists
///ex_timeline_exists(name)

var _name = argument[0];
var _list = ex_timeline_get_index(_name);

if (_list < 0) {
    return 0;    
} else {
    return 1;
}



#define ex_timeline_get_asset_index
///ex_timeline_get_asset_index(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

var _y = ex_timeline_get_index(_name);
if (_y < 0) {
    return 0;
}



#define ex_timeline_get_debug_mode
///ex_timeline_get_debug_mode()

gml_pragma("forceinline");

return obj_ex_timeline._ex_timeline_debug_mode;



#define ex_timeline_get_duration
///ex_timeline_get_duration(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// get duration
return _list[# _ex_timeline._duration, _y];





#define ex_timeline_get_index
///ex_timeline_get_index(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check if timelines exist first
if (ex_timeline_count() < 1) {
    return -1;
}

var _y = ds_grid_value_y(_list, 0, 0, 1, ds_grid_height(_list), string( _name ));
if (_y < 0) {
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    _y = -1;
}

return _y;



#define ex_timeline_get_loop
///ex_timeline_get_loop(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// get loop
return _list[# _ex_timeline._loop, _y];




#define ex_timeline_get_name
///ex_timeline_get_name(index)

var _timeline_index = argument[0];
var _list = obj_ex_timeline._ex_timelines;
var _out_name  = "";

if (_list < 0) {
    return "";
}

if (_timeline_index < 0 or _timeline_index > ds_grid_height(_list)) {
    return "";
}

// get timeline name
return _list[# _ex_timeline._name, _timeline_index];




#define ex_timeline_get_position
///ex_timeline_get_position(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// get position
return _list[# _ex_timeline._position_floored, _y];





#define ex_timeline_get_position_previous
///ex_timeline_get_position_previous(name)

// for internal use

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// get previous position
return _list[# _ex_timeline._position_previous_floored, _y];




#define ex_timeline_get_script
///ex_timeline_get_script(name, position)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// get scripts DS map
_dsmap = _list[# _ex_timeline._oncomplete, _y];

if (ds_map_exists(_dsmap, argument[1])) {
    return ds_map_find_value(_dsmap, argument[1]);
} else {
    return -1;
}






#define ex_timeline_get_speed
///ex_timeline_get_speed(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// get speed
return _list[# _ex_timeline._speed, _y];



#define ex_timeline_initialize
///ex_timeline_initialize()

if (instance_exists(obj_ex_timeline)) {
	
	if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Warning, exTimeline system is already initialized');
    }
	
	return 0;
}

// create exTimeline object
instance_create(0, 0, obj_ex_timeline);

return 1;




#define ex_timeline_is_paused
///ex_timeline_is_paused(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

    return 0;
}

// get paused state
return _list[# _ex_timeline._is_paused, _y];




#define ex_timeline_is_playing
///ex_timeline_is_playing(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

    return 0;
}

// get playing state
return _list[# _ex_timeline._is_playing, _y];





#define ex_timeline_pause
///ex_timeline_pause(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// set playing state
_list[# _ex_timeline._is_playing, _y] = false;

// set paused state
_list[# _ex_timeline._is_paused, _y] = true;

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Paused timeline with name: "'+string( _name )+'"');
}

return 1;




#define ex_timeline_pause_all
///ex_timeline_pause_all()

var _ex_timeline_count = ex_timeline_count();
for (var _i=0; _i < _ex_timeline_count; ++_i) {
    ex_timeline_pause(ex_timeline_get_name(_i));
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Paused all timelines');
}

return 1;



#define ex_timeline_play
///ex_timeline_play(name, speed, position, loop, syncDelta)

var _name                = argument[0];
var _list                = obj_ex_timeline._ex_timelines;
var _timeline_speed      = 1;
var _timeline_position   = -1;
var _timeline_loop       = false;
var _timeline_sync_delta = false;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

if (argument_count >= 2) {
    _timeline_speed = argument[1];
} else {
    _timeline_speed = _list[# _ex_timeline._speed, _y];
}

if (argument_count >= 3) {
    _timeline_position = argument[2];
}

if (argument_count >= 4) {
    _timeline_loop = argument[3];
} else {
    _timeline_loop = _list[# _ex_timeline._loop, _y];
}

if (argument_count >= 5) {
    _timeline_sync_delta = argument[4];
} else {
    _timeline_sync_delta = _list[# _ex_timeline._sync_delta, _y];
}

// set values
_list[# _ex_timeline._is_playing, _y] = true;
_list[# _ex_timeline._speed, _y]      = _timeline_speed;
_list[# _ex_timeline._position, _y]   = _timeline_position;
_list[# _ex_timeline._loop, _y]       = _timeline_loop;
_list[# _ex_timeline._sync_delta, _y] = _timeline_sync_delta;

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Started timeline with name: "'+string( _name )+'"');
}

return 1;




#define ex_timeline_restore_all
///ex_timeline_restore_all()

with (obj_ex_timeline) {
    _suspended = false;
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Restored all suspended timelines');
}

return 1;




#define ex_timeline_resume
///ex_timeline_resume(name)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

if (ds_grid_get(_list, 5, _y) == false) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Timeline with name: "'+string( _name )+'" is not paused, resume aborted');
    }
    
    return 0;
}

// set playing state
_list[# _ex_timeline._is_playing, _y] = true;

// set paused state
_list[# _ex_timeline._is_paused, _y] = false;

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Resumed timeline with name: "'+string( _name )+'"');
}

return 1;




#define ex_timeline_resume_all
///ex_timeline_resume_all()

var _ex_timeline_count = ex_timeline_count();
for (var _i=0; _i < _ex_timeline_count; ++_i) {
    ex_timeline_resume(ex_timeline_get_name(_i));
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Resumed all timelines');
}

return 1;



#define ex_timeline_set_debug_mode
///ex_timeline_set_debug_mode(enabled)

obj_ex_timeline._ex_timeline_debug_mode = argument[0];



#define ex_timeline_set_loop
///ex_timeline_set_loop(name, loop)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

    return 0;
}

// set loop
_list[# _ex_timeline._loop, _y] = argument[1];

return 1;




#define ex_timeline_set_position
///ex_timeline_set_position(name, position)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

    return 0;
}

var _position = argument[1];
var _max = ex_timeline_get_duration(_name);
if (_position > _max) {
    _position = _max;
}

// set position
_list[# _ex_timeline._position, _y] = _position;

return 1;


#define ex_timeline_set_position_previous
///ex_timeline_set_position_previous(name, position)

// for internal use

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

    return 0;
}

var _position = argument[1];
var _max = ex_timeline_get_duration(_name);
if (_position > _max) {
    _position = _max;
}

// set previous position
_list[# _ex_timeline._position_previous, _y] = _position;

return 1;






#define ex_timeline_set_script
///ex_timeline_set_script(name, position, script, arguments)

var _name     = argument[0];
var _position = argument[1];
var _script   = argument[2];
var _arguments = ex_timeline_arguments_undefined;
var _list = obj_ex_timeline._ex_timelines;

if (argument[1] < 0) {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, timeline position should be equal or above zero');
    }
    
    return 0;
}

if (argument_count >= 4) {
    _arguments = argument[3];
}

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

    return 0;
}

// get scripts DS map
var _dsmap = _list[# _ex_timeline._oncomplete, _y];

// set the script
if (not ds_map_exists(_dsmap, floor(_position))) {
    ds_map_add(_dsmap, floor(_position), _script);
} else {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, script already exists for position '+string(_position)+' for timeline: "'+string( _name )+'"');
    }
    
    return 0;
}

// set the script arguments
var _dsmap2 = _list[# _ex_timeline._oncomplete_arguments, _y];

if (not ds_map_exists(_dsmap2, floor(_position))) {
    ds_map_add(_dsmap2, floor(_position), _arguments);
} else {
    
    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, script arguments already exist for position '+string(_position)+' for timeline: "'+string( _name )+'"');
    }
    
    return 0;
}


// find max moment
_size = ds_map_size(_dsmap);
_key = ds_map_find_first(_dsmap);
for (var _i=0; _i < _size; ++_i) {
    
    _val = ds_map_find_value(_dsmap, _key);
   
   //show_debug_message("DSKEY: "+string( _key )+"="+string( _val ));
    
    _values[_i] = _key;

    _key = ds_map_find_next(_dsmap, _key);

}

// get new max possible moment
_max = ex_timeline_array_get_max(_values);

// update duration
_list[# _ex_timeline._duration, _y] = _max;

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Added script '+string( script_get_name(_script) )+' ('+string(_script)+') for timeline: "'+string( _name )+'" at position '+string(_position));
}

return 1;


#define ex_timeline_set_speed
///ex_timeline_set_speed(name, speed)

var _name = argument[0];
var _list = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }

return 0;
}

// set speed
_list[# _ex_timeline._speed, _y] = argument[1];

return 1;


#define ex_timeline_stop
///ex_timeline_stop(name)

var _name           = argument[0];
var _list           = obj_ex_timeline._ex_timelines;

// check name column
var _y = ex_timeline_get_index(_name);
if (_y < 0) {

    if (ex_timeline_get_debug_mode()) {
        show_debug_message('exTimeline: Error, could not find timeline with name "'+string( _name )+'"');
    }
    
    return 0;
}

// set speed
_list[# _ex_timeline._speed, _y] = 0;

// set position
_list[# _ex_timeline._position, _y] = -1;

// set playing state
_list[# _ex_timeline._is_playing, _y] = false;

// set paused state
_list[# _ex_timeline._is_paused, _y] = false;

// set loop
_list[# _ex_timeline._loop, _y] = false;

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Stopped timeline with name: "'+string( _name )+'"');
}

return 1;


#define ex_timeline_stop_all
///ex_timeline_stop_all()

var _ex_timeline_count = ex_timeline_count();
for (var _i=0; _i < _ex_timeline_count; ++_i) {
    ex_timeline_stop(ex_timeline_get_name(_i));
}

if (ex_timeline_get_debug_mode()) {
    show_debug_message('exTimeline: Stopped all timelines');
}

return 1;


#define ex_timeline_array_get_max
///ex_timeline_array_get_max(arrayIndex)

/**
 * Returns the maximum array item
 *
 * @param  arrayIndex  The array to get the max from, array
 * 
 * @return Returns the maximum array item, real
 */

gml_pragma("forceinline"); 
 
var _max = 0;
var _values = argument[0];

var _array_length = array_length_1d(_values);
for (var _i=0; _i < _array_length; ++_i) {
    if (_values[_i] > _max) {
        _max = _values[_i];
    }
}

return _max;

#define ex_timeline_string_pad_right
///ex_timeline_string_pad_right(string, length, subject)

/**
 * Pads the string to the desired length with subject string from the right
 *
 * @param   string   The input string, string
 * @param   length   The desired length of the string, real
 * @param   subject  The subject string to use for padding, string
 * 
 * @return  Returns the string to the desired length with subject string from the right, real
 *
 * @license http://gmlscripts.com/license
 */

var _string, _length, _pad, _pad_size, _padding, _out;

_string = argument[0];
_length = argument[1];
_pad    = argument[2];

_pad_size = string_length(_pad);
_padding = max(0, _length - string_length(_string));

_out  = _string;
_out += string_repeat(_pad, _padding div _pad_size);
_out += string_copy(_pad, 1, _padding mod _pad_size);
_out  = string_copy(_out, 1, _length);

return _out;

