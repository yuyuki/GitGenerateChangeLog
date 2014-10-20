@echo off
pushd ..\.git\hooks
mklink commit-msg ..\..\git-hooks\commit-msg.pl
popd