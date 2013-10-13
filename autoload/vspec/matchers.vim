function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_SID$')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

function! s:make_matcher(name, func)
    call vspec#customize_matcher(a:name, function(a:func))
endfunction

function! s:exists_and_default_to(var, default)
    return exists(a:var) && {a:var} == a:default
endfunction

function! s:include(heystack, needle)
    let t = type(a:heystack)
    if t == type("")
        return stridx(a:heystack, a:needle) != -1
    elseif t == type([])
        return index(a:heystack, a:needle) != -1
    elseif t == type({})
        if type(a:needle) != type([])
            throw "Error: matcher-to_include: needle must be array if heystack is dict"
        endif
        if len(a:needle) != 2
            throw "Error: matcher-to_include: needle must have pair of key and value if heystack is dict"
        endif
        return has_key(a:heystack, a:needle[0]) && a:heystack[a:needle[0]] == a:needle[1]
    else
        throw "Error: matcher-to_include: unexpected heystack"
    endif
endfunction

function! s:match(expr, pattern)
    return match(a:expr, a:pattern) != -1
endfunction

function! s:has_value(dict, value)
    for v in values(a:dict)
        if a:value == v
            return 1
        endif
    endfor
    return 0
endfunction

function! s:abbrev_in(what, mode)
    return hasmapto(a:what, a:mode, 1)
endfunction

function! s:abbrev(what)
    return hasmapto(a:what, "nvo", 1)
endfunction

function! s:current_buffer_includes(str)
    return stridx(join(getline(1, line('$')), "\n"), a:str) != -1
endfunction

function! s:dir_includes(entry, dir)
    return findfile(a:entry, a:dir) !=# '' || finddir(a:entry, a:dir) !=# ''
endfunction

function! s:is_same_type(l, r)
    return type(a:l) == type(a:r)
endfunction

function! s:is_num(v)
    return s:is_same_type(a:v, 0)
endfunction

function! s:is_string(v)
    return s:is_same_type(a:v, "")
endfunction

function! s:is_funcref(v)
    return s:is_same_type(a:v, function('tr'))
endfunction

function! s:is_list(v)
    return s:is_same_type(a:v, [])
endfunction

function! s:is_dict(v)
    return type(a:v) == type({})
endfunction

function! s:is_float(v)
    return s:is_same_type(a:v, 0.0)
endfunction

function! s:maps_to(from, to, mode)
    return maparg(a:from, a:mode) ==# a:to
endfunction

function! s:is_maparg_in(lhs, mode)
    return maparg(a:lhs, a:mode) !=# ''
endfunction

function! s:is_unite_source(name)
    return globpath(&rtp, 'autoload/unite/sources/'.a:name.'.vim') !=# ''
endfunction

function! s:is_unite_filter(name)
    return globpath(&rtp, 'autoload/unite/filters/'.a:name.'.vim') !=# ''
endfunction

function! s:is_unite_kind(name)
    return globpath(&rtp, 'autoload/unite/kinds/'.a:name.'.vim') !=# ''
endfunction

function! s:makes_exception(normal_cmd)
    try
        execute a:normal_cmd
        return 0
    catch
        return 1
    endtry
endfunction

function! s:is_the_answer(v)
    return a:v == 42
endfunction

function! s:is_loaded(plugin)
    return exists('g:'.a:plugin.'_loaded') || exists('g:loaded_'.a:plugin)
endfunction

function! s:is_installed(plugin)
    for path in split(&runtimepath, ',')
        let ret = filereadable(path . '/plugin/' . a:plugin . '.vim')
                              \ || filereadable(path . '/autoload/' . a:plugin . '.vim')
                              \ || isdirectory(path . '/autoload/' . a:plugin)
        if ret | return 1 | endif
    endfor
    return 0
endfunction

function! s:moves_cursor(cmd)
    let _ = deepcopy(getpos('.'))
    execute a:cmd
    return getpos('.') != _
endfunction

function! s:changes_variable(cmd, var)
    let _ = deepcopy({a:var})
    execute a:cmd
    return _ !=# {a:var}
endfunction

function! s:makes_exception_of(cmd, errcode)
    try
        execute a:cmd
        return 0
    catch
        if v:exception =~# ':'.a:errcode.':'
            return 1
        else
            return 0
        endif
    endtry
endfunction

function! s:changes_current_buffer(cmd)
    let _ = deepcopy(getline(1, line('$')))
    execute a:cmd
    return getline(1, line('$')) !=# _
endfunction

function! s:changes_global_var(cmd)
    return s:changes_variable(a:cmd, 'g:')
endfunction

function! s:current_line_is(str)
    return getline('.') ==# a:str
endfunction

function! vspec#matchers#load()
    call s:make_matcher('to_exist'                 , 'exists')
    call s:make_matcher('to_exist_and_default_to'  , s:SID.'exists_and_default_to')
    call s:make_matcher('to_include'               , s:SID.'include')
    call s:make_matcher('to_match'                 , s:SID.'match')
    call s:make_matcher('to_be_empty'              , 'empty')
    call s:make_matcher('to_have_key'              , 'has_key')
    call s:make_matcher('to_have_value'            , s:SID.'has_value')
    call s:make_matcher('to_be_mapped_in'          , 'hasmapto')
    call s:make_matcher('to_be_mapped'             , 'hasmapto')
    call s:make_matcher('to_map_in'                , s:SID.'is_maparg_in')
    call s:make_matcher('to_map_to'                , s:SID.'maps_to')
    call s:make_matcher('to_be_abbreved_in'        , s:SID.'abbrev_in')
    call s:make_matcher('to_be_abbreved'           , s:SID.'abbrev')
    call s:make_matcher('to_be_locked'             , 'islocked')
    call s:make_matcher('to_be_in_current_buffer'  , s:SID.'current_buffer_includes')
    call s:make_matcher('to_be_in_dir'             , s:SID.'dir_includes')
    call s:make_matcher('to_be_readable_file'      , 'filereadable')
    call s:make_matcher('to_be_writable_file'      , 'filewritable')
    call s:make_matcher('to_be_executable'         , 'executable')
    call s:make_matcher('to_be_directory'          , 'isdirectory')
    call s:make_matcher('to_be_supported'          , 'has')
    call s:make_matcher('to_be_type_of'            , s:SID.'is_same_type')
    call s:make_matcher('to_be_num'                , s:SID.'is_num')
    call s:make_matcher('to_be_string'             , s:SID.'is_string')
    call s:make_matcher('to_be_funcref'            , s:SID.'is_funcref')
    call s:make_matcher('to_be_list'               , s:SID.'is_list')
    call s:make_matcher('to_be_dict'               , s:SID.'is_dict')
    call s:make_matcher('to_be_float'              , s:SID.'is_float')
    call s:make_matcher('to_be_unite_source'       , s:SID.'is_unite_source')
    call s:make_matcher('to_be_unite_filter'       , s:SID.'is_unite_filter')
    call s:make_matcher('to_be_unite_kind'         , s:SID.'is_unite_kind')
    call s:make_matcher('to_throw_exception'       , s:SID.'makes_exception')
    call s:make_matcher('to_throw_exception_of'    , s:SID.'makes_exception_of')
    call s:make_matcher('to_be_loaded'             , s:SID.'is_loaded')
    call s:make_matcher('to_be_installed'          , s:SID.'is_installed')
    call s:make_matcher('to_move_cursor'           , s:SID.'moves_cursor')
    call s:make_matcher('to_change_var'            , s:SID.'changes_variable')
    call s:make_matcher('to_change_global_var'     , s:SID.'changes_global_var')
    call s:make_matcher('to_change_current_buffer' , s:SID.'changes_current_buffer')
    call s:make_matcher('to_be_current_line'       , s:SID.'current_line_is')
    call s:make_matcher('to_be_the_answer_to_the_ultimate_question_of_life_the_universe_and_everything', s:SID.'is_the_answer')
endfunction
