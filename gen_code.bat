@echo off
setlocal EnableDelayedExpansion

set module=github.com/Iori372552686/game_protocol
set bin_dir=.bin
set protoc_dir=..\lib\contrib\protoc\protoc-33.2-win64\bin
set protoc_include=..\lib\contrib\protoc\protoc-33.2-win64\include
set protoc_gen_go=%bin_dir%\protoc-gen-go.exe
set protoc_go_inject_tag=%bin_dir%\protoc-go-inject-tag.exe
set proto_args=

if not exist "%bin_dir%" mkdir "%bin_dir%"

go build -o "%protoc_gen_go%" google.golang.org/protobuf/cmd/protoc-gen-go
if errorlevel 1 goto :end

go build -o "%protoc_go_inject_tag%" github.com/favadi/protoc-go-inject-tag
if errorlevel 1 goto :end

for /f "usebackq delims=" %%f in (`powershell -NoProfile -Command "Get-ChildItem -Path . -Filter *.proto | Where-Object { -not ((Get-Content $_.FullName -Raw) -match 'github.com/Iori372552686/GoOne/api/gen/') } | Sort-Object Name | ForEach-Object { $_.Name }"`) do (
    set proto_args=!proto_args! "%%f"
)

if not defined proto_args (
    echo no protocol-owned proto files found
    goto :end
)

if exist protocol rmdir /s /q protocol

%protoc_dir%\protoc.exe -I. -I"%protoc_include%" --plugin=protoc-gen-go="%protoc_gen_go%" --go_out=. --go_opt=module=%module% --go_opt=paths=import !proto_args!
if errorlevel 1 goto :end

copy /y index.gen.go protocol\index.gen.go >nul

if exist protocol\database.pb.go (
    "%protoc_go_inject_tag%" -input=protocol\database.pb.go
    if errorlevel 1 goto :end
)

:end
endlocal