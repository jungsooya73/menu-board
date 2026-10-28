@echo off
chcp 65001 >nul
title 브릿지 커피 메뉴판 올리기
cd /d "%~dp0"

rem ============================================================
rem  메뉴판 올리기 프로그램
rem  이 파일을 더블클릭하면 index.html이 인터넷에 올라가요.
rem  메뉴를 고친 뒤에도 똑같이 더블클릭만 하면 돼요.
rem
rem  ✏️ 인터넷 주소 이름: 아래 = 뒤의 글자가 주소가 돼요.
rem     지금 설정이면 주소는 https://bridge-coffee-gwangju.netlify.app 이에요.
rem     영어 소문자, 숫자, - 만 쓸 수 있어요.
rem     ⚠️ 한 번 올린 뒤에 바꾸면 주소가 새로 생겨서 QR을 다시 인쇄해야 해요.
rem ============================================================
set "SITE_NAME=bridge-coffee-gwangju"

rem ---------- 아래부터는 고치지 않아도 돼요 ----------
set "NETLIFY=npx -y netlify-cli@27.15.0"
set "UPLOAD_DIR=%TEMP%\bridge-menu-upload"
set "SITE_URL=https://%SITE_NAME%.netlify.app"

echo.
echo  ☕ 브릿지 커피 메뉴판을 인터넷에 올릴게요.
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo  ❌ 이 컴퓨터에 Node.js 프로그램이 없어서 올릴 수 없어요.
  echo     열리는 사이트에서 LTS 버튼을 눌러 설치한 뒤 다시 실행해 주세요.
  start https://nodejs.org/ko
  pause
  exit /b 1
)

if not exist "index.html" (
  echo  ❌ 같은 폴더에서 index.html을 찾을 수 없어요.
  pause
  exit /b 1
)

rem index.html 하나만 따로 담아서 올려요. 자료 폴더 등은 올라가지 않아요.
if exist "%UPLOAD_DIR%" rmdir /s /q "%UPLOAD_DIR%"
mkdir "%UPLOAD_DIR%"
copy /y "index.html" "%UPLOAD_DIR%\index.html" >nul

echo  [1/3] 넷리파이 로그인 확인 중... 처음엔 1~2분 걸릴 수 있어요.
%NETLIFY% status 2>&1 | findstr /C:"Not logged in" >nul
if not errorlevel 1 (
  echo.
  echo  🔑 처음 한 번만 로그인이 필요해요.
  echo     인터넷 창이 열리면 구글 계정 등으로 가입하거나 로그인한 뒤
  echo     Authorize 버튼을 눌러 주세요. 끝나면 이 창으로 돌아오세요.
  echo.
  call %NETLIFY% login
)

echo.
echo  [2/3] 메뉴판 올리는 중...
call %NETLIFY% deploy --prod --no-build --dir "%UPLOAD_DIR%" --site-name %SITE_NAME% --message "메뉴판 올리기 프로그램으로 올림"
if errorlevel 1 (
  echo.
  echo  ❌ 올리지 못했어요.
  echo     - 인터넷이 연결되어 있는지 확인해 주세요.
  echo     - 처음 올리는 거라면, 다른 사람이 이미 쓰는 주소 이름일 수 있어요.
  echo       이 파일을 메모장으로 열어서 SITE_NAME 뒤의 이름을 바꿔 보세요.
  pause
  exit /b 1
)

echo.
echo  [3/3] 테이블에 붙일 QR 코드 그림을 만드는 중...
call npx -y qrcode@1.5.4 -o "메뉴판QR.png" -w 800 -m 2 "%SITE_URL%" >nul 2>nul

echo.
echo  ============================================================
echo   🎉 다 올라갔어요!
echo   메뉴판 주소: %SITE_URL%
echo   QR 코드 그림: 이 폴더의 메뉴판QR.png - 인쇄해서 테이블에 붙이세요
echo   메뉴를 고친 뒤 다시 실행해도 주소와 QR은 그대로예요.
echo  ============================================================
echo.
start "" "%SITE_URL%"
pause
