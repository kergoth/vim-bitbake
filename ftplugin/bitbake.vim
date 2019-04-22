" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

let b:undo_ftplugin = "setl cms< sts< sw< et< sua< inc<"

setlocal commentstring=#\ %s
setlocal softtabstop=4 shiftwidth=4 expandtab
setlocal suffixesadd+=.bbclass
setlocal include=^require\\\s\\\+\\\zs.*\\\ze\\\|^include\\\s\\\+\\\zs.*\\\ze\\\|inherit\\\s\\\+\\\(\\\zs\\\S\\\+\\\ze\\\)\\\+

if exists('g:bitbake_set_path') && !empty('g:bitbake_set_path')
  let print_bbpath = globpath(&rtp, 'scripts/print-bbpath')
  if print_bbpath == ''
    finish
  endif

  let s:shellredir = &shellredir
  set shellredir=>
  silent let s:output = system(print_bbpath)
  let &shellredir = s:shellredir

  if v:shell_error
    let b:bitbake_path = []
  else
    let s:bbpath = split(s:output, '\n')[0]
    let b:bitbake_path = split(s:bbpath, ':')
  endif
  let b:bitbake_classes_path = map(copy(b:bitbake_path), 'v:val . "/classes"')
end

if exists('g:loaded_apathy')
  call apathy#Prepend('path', b:bitbake_path)
  call apathy#Prepend('path', b:bitbake_classes_path)

  call apathy#Undo()
else
  setlocal path=.,,
  let &l:path += join(b:bitbake_path, ',')
  let &l:path += join(b:bitbake_classes_path, ',')
end
