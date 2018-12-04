   for /f "tokens=1* delims=." %%i in ('dir /b source\*.svg') do inkscape --without-gui --file=source\%%i.svg --export-pdf=source\%%i.pdf
