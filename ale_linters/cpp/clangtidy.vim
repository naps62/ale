" Author: vdeurzen <tim@kompiler.org>, w0rp <devw0rp@gmail.com>,
" gagbo <gagbobada@gmail.com>
" Description: clang-tidy linter for cpp files

call ale#Set('cpp_clangtidy_executable', 'clang-tidy')
" Set this option to check the checks clang-tidy will apply.
call ale#Set('cpp_clangtidy_checks', ['*'])
" Set this option to manually set some options for clang-tidy.
" This will disable compile_commands.json detection.
call ale#Set('cpp_clangtidy_options', '')
call ale#Set('c_build_dir', '')

function! ale_linters#cpp#clangtidy#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'cpp_clangtidy_executable')
endfunction

function! ale_linters#cpp#clangtidy#GetCommand(buffer) abort
    let l:checks = join(ale#Var(a:buffer, 'cpp_clangtidy_checks'), ',')
    let l:build_dir = ale#Var(a:buffer, 'c_build_dir')

    " c_build_dir has the priority if defined
    if empty(l:build_dir)
        let l:build_dir = ale#c#FindCompileCommands(a:buffer)
    endif

    " Get the extra options if we couldn't find a build directory.
    let l:options = empty(l:build_dir)
    \   ? ale#Var(a:buffer, 'cpp_clangtidy_options')
    \   : ''

    return ale#Escape(ale_linters#cpp#clangtidy#GetExecutable(a:buffer))
    \   . (!empty(l:checks) ? ' -checks=' . ale#Escape(l:checks) : '')
    \   . ' %s'
    \   . (!empty(l:build_dir) ? ' -p ' . ale#Escape(l:build_dir) : '')
    \   . (!empty(l:options) ? ' -- ' . l:options : '')
endfunction

call ale#linter#Define('cpp', {
\   'name': 'clangtidy',
\   'output_stream': 'stdout',
\   'executable_callback': 'ale_linters#cpp#clangtidy#GetExecutable',
\   'command_callback': 'ale_linters#cpp#clangtidy#GetCommand',
\   'callback': 'ale#handlers#gcc#HandleGCCFormat',
\   'lint_file': 1,
\})
