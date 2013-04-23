@echo off
set PATH=%PATH%;..\..\ruby\1.8.6\bin
call mongrel_rails service::install -N "Inovare - Gerenciador Financeiro" -c .. -p 4005 -e production
sc config "Inovare - Gerenciador Financeiro" start= auto
net start "Inovare - Gerenciador Financeiro"
