((netsh wlan show interfaces) | Select-String "Physical address").tostring().split(":",2).trim()[1]