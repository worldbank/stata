** Makes QR codes containing text.

cap prog drop txt2qr
prog def txt2qr

version 9.0

syntax anything using/ , [save] [replace]

copy `"http://chart.apis.google.com/chart?cht=qr&chs=400x400&chl=`anything'&chld=H|0"' `using' , `s' `replace'

end
