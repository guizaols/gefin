@echo off
set PATH=%PATH%;..\..\ruby\1.8.6\bin
call mongrel_rails service::remove -N "Inovare - Gerenciador Financeiro"
