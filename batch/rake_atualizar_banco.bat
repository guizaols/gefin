@echo off
set PATH=%PATH%;..\..\ruby\1.8.6\bin
call rake db:migrate RAILS_ENV=production
call rake db:migrate RAILS_ENV=development