#Script para remover todas as vers�es do Java
gwmi Win32_Product -filter "name like 'Java%' AND vendor like 'Oracle%'" | % { $_.Uninstall() }
