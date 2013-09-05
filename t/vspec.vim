let s:root_dir = matchstr(system('git rev-parse --show-cdup'), '[^\n]\+')
execute 'set' 'rtp +=./'.s:root_dir
set rtp+=~/.vim/bundle/unite.vim

describe "vspec#matchers#load()"

    before
        call vspec#matchers#load()
        let g:hogeee = 42
        lockvar! g:hogeee
        noremap m :search('m')<CR>
    end

    it "provide many matchers for vim-vspec"
        Expect 'v:version' to_exist
        Expect '*vspec#test' to_exist
        Expect 'g:hogeee' to_exist_and_default_to 42
        Expect [1, 2, 3] to_include 2
        Expect {'a' : 1} to_include ['a', 1]
        Expect "aiueo" to_include "iue"
        Expect "hogeee" to_match 'e\+$'
        Expect "" to_be_empty
        Expect [] to_be_empty
        Expect {} to_be_empty
        Expect {'a' : 1} to_have_key 'a'
        Expect {'a' : 1} to_have_value 1
        Expect 'm' to_be_mapped
        Expect 'm' to_be_mapped_in 'nv'
        Expect 'g:hogeee' to_be_locked
        Expect '' to_be_in_current_buffer
        Expect expand('~/.vim') to_be_in_dir expand('~')
        Expect expand('~/.vimrc') to_be_in_dir expand('~')
        Expect expand('~/.vimrc') to_be_readable_file
        Expect expand('~/.vimrc') to_be_writable_file
        Expect 'vim' to_be_executable
        Expect expand('~') to_be_directory
        Expect 'unix' to_be_supported
        Expect [1, 2, 3] to_be_type_of []
        Expect 42 to_be_num
        Expect '(U^w^)' to_be_string
        Expect function('tr') to_be_funcref
        Expect [1, 2, 3] to_be_list
        Expect {'tsura' : 'poyo'} to_be_dict
        Expect 3.14 to_be_float
        Expect 'file' to_be_unite_source
        Expect 'buffer' to_be_unite_kind
        Expect 'sorter_rank' to_be_unite_filter
    end

end