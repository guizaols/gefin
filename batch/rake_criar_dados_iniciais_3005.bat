@echo off
set PATH=%PATH%;..\..\ruby\1.8.6\bin
call rake db:dados_gefin
call rake db:dados_gefin RAILS_ENV=production
