echo -off
for %a in fs0 fs1 fs2 fs3 fs4 fs5
  if exist %a:readme-zedk.txt then
    %a:
    type readme-zedk.txt
  endif
endfor

## Uncomment the following lines to launch Setup automatically
## and continue booting afterwards.
#prepare-setup.nsh
#UiApp.efi
#exit
