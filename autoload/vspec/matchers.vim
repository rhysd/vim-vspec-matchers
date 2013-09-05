function! s:get_SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeget_SID$')
endfunction
let s:SID = s:get_SID()
delfunction s:get_SID

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
    return match(expr, pattern) != -1
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
    return index(join(getline(1, line('.')), "\n"), a:str) != -1
endfunction

function! s:dir_includes(entry, dir)
    return findfile(a:entry, a:dir) || finddir(a:entry, a:dir)
endfunction

function! s:is_same_type(l, r)
    return type(l) == type(r)
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

function! s:maps_to(from, to)
    return maparg(a:from) ==# a:to
endfunction

function! s:is_unite_source(name)
    return globpath(&rtp, 'autoload/unite/sources/'.name.'.vim') !=# ''
endfunction

function! s:is_unite_filters(name)
    return globpath(&rtp, 'autoload/unite/filters/'.name.'.vim') !=# ''
endfunction

function! s:is_unite_kinds(name)
    return globpath(&rtp, 'autoload/unite/kinds/'.name.'.vim') !=# ''
endfunction

function! s:makes_exception(normal_cmd)
    try
        execute a:normal_cmd
        return 0
    catch
        return 1
    endtry
endfunction

function! vspec#matchers#load()
    call vspec#customize_matcher('to_exist'                , function('exists'))
    call vspec#customize_matcher('to_exist_and_default_to' , function(s:SID.'exists_and_default_to'))
    call vspec#customize_matcher('to_include'              , function(s:SID.'include'))
    call vspec#customize_matcher('to_match'                , function(s:SID.'match'))
    call vspec#customize_matcher('to_be_empty'             , function('empty'))
    call vspec#customize_matcher('to_have_key'             , function('has_key'))
    call vspec#customize_matcher('to_have_value'           , function(s:SID.'has_value'))
    call vspec#customize_matcher('to_be_mapped_in'         , function('hasmapto'))
    call vspec#customize_matcher('to_be_mapped'            , function('hasmapto'))
    call vspec#customize_matcher('to_be_mapped_to'         , function(s:SID.'maps_to'))
    call vspec#customize_matcher('to_be_abbreved_in'       , function(s:SID.'abbrev_in'))
    call vspec#customize_matcher('to_be_abbreved'          , function(s:SID.'abbrev'))
    call vspec#customize_matcher('to_be_locked'            , function('islocked'))
    call vspec#customize_matcher('to_be_in_current_buffer' , function(s:SID.'current_buffer_includes'))
    call vspec#customize_matcher('to_be_in_dir'            , function(s:SID.'dir_includes'))
    call vspec#customize_matcher('to_be_readable_file'     , function('filereadable'))
    call vspec#customize_matcher('to_be_writable_file'     , function('filewritable'))
    call vspec#customize_matcher('to_be_executable'        , function('executable'))
    call vspec#customize_matcher('to_be_directory'         , function('isdirectory'))
    call vspec#customize_matcher('to_be_supported'         , function('has'))
    call vspec#customize_matcher('to_be_type_of'           , function(s:SID.'is_same_type'))
    call vspec#customize_matcher('to_be_num'               , function(s:SID.'is_num'))
    call vspec#customize_matcher('to_be_string'            , function(s:SID.'is_string'))
    call vspec#customize_matcher('to_be_funcref'           , function(s:SID.'is_funcref'))
    call vspec#customize_matcher('to_be_list'              , function(s:SID.'is_list'))
    call vspec#customize_matcher('to_be_dict'              , function(s:SID.'is_dict'))
    call vspec#customize_matcher('to_be_float'             , function(s:SID.'is_float'))
    call vspec#customize_matcher('to_be_unite_source'      , function(s:SID.'is_unite_source'))
    call vspec#customize_matcher('to_be_unite_filters'     , function(s:SID.'is_unite_filters'))
    call vspec#customize_matcher('to_be_unite_kinds'       , function(s:SID.'is_unite_kinds'))
    call vspec#customize_matcher('to_throw_exception'      , function(s:SID.'makes_exception'))
endfunction
