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
    else
        throw "Error: matcher-to_include: unexpected heystack"
    endif
endfunction

function! s:match(expr, pattern)
    return match(expr, pattern) != -1
endfunction

function! s:abbrev(what, mode)
    return hasmapto(a:what, a:mode, 1)
endfunction

function! s:current_buffer_includes(str)
    return index(join(getline(1, line('.')), "\n"), a:str) != -1
endfunction

function! s:dir_includes(entry, dir)
    return findfile(a:entry, a:dir) || finddir(a:entry, a:dir)
endfunction

function! vspec#matchers#load()
    call vspec#customize_matcher('to_exists'               , function('exists'))
    call vspec#customize_matcher('to_exists_and_default_to', function(s:SID.'exists_and_default_to'))
    call vspec#customize_matcher('to_include'              , function(s:SID.'include'))
    call vspec#customize_matcher('to_match'                , function(s:SID.'match'))
    call vspec#customize_matcher('to_be_empty'             , function('empty'))
    call vspec#customize_matcher('to_have_key'             , function('has_key'))
    call vspec#customize_matcher('to_be_mapped_in'         , function('hasmapto'))
    call vspec#customize_matcher('to_be_abbreved_in'       , function(s:SID.'abbrev'))
    call vspec#customize_matcher('to_be_locked'            , function('islocked'))
    call vspec#customize_matcher('to_be_in_current_buffer' , function(s:SID.'current_buffer_includes'))
    call vspec#customize_matcher('to_be_in_dir'            , function(s:SID.'dir_includes'))
    call vspec#customize_matcher('to_be_readable_file'     , function('filereadable'))
    call vspec#customize_matcher('to_be_writable_file'     , function('filewritable'))
    call vspec#customize_matcher('to_be_executable'        , function('executable'))
    call vspec#customize_matcher('to_be_directory'         , function('isdirectory'))
    call vspec#customize_matcher('to_be_supported'         , function('has'))
endfunction
