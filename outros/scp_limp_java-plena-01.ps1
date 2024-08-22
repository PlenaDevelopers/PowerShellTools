#Script para remover todas as versões do Java
gwmi Win32_Product -filter "name like 'Java%' AND vendor like 'Oracle%'" | % { $_.Uninstall() }
