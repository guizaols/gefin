@echo off
set PATH=%PATH%;..\..\ruby\1.8.6\bin
call mongrel_rails service::install -N "Inovare - Gerenciador Financeiro - 3005" -c .. -p 3005 -e production
sc config "Inovare - Gerenciador Financeiro - 3005" start= auto
net start "Inovare - Gerenciador Financeiro - 3005"
