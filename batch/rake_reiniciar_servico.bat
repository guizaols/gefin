@echo off
net stop "Inovare - Gerenciador Financeiro"
ping 1.1.1.1 -n 20 > nul
net start "Inovare - Gerenciador Financeiro"
