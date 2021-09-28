#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {

   //add this lines for prevent  multiple instances of application                   
/*	HANDLE hMutexHandle = CreateMutex(NULL, TRUE, L"com.mutex.fsbackup");
	HWND handle=FindWindowA(NULL, "fsbackup");
	if (GetLastError() == ERROR_ALREADY_EXISTS)
	{
		WINDOWPLACEMENT place = { sizeof(WINDOWPLACEMENT) };
			GetWindowPlacement(handle, &place);
			switch(place.showCmd)
			{
				 case SW_SHOWMAXIMIZED:
					 ShowWindow(handle, SW_SHOWMAXIMIZED);
					 break;
				 case SW_SHOWMINIMIZED:
					 ShowWindow(handle, SW_RESTORE);
					 break;
				 default:
					 ShowWindow(handle, SW_NORMAL);
					 break;
			 }
			 SetWindowPos(0, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW | SWP_NOSIZE | SWP_NOMOVE);
			 SetForegroundWindow(handle);
			
			 // Program already running somewhere
		return(1); // Exit program
	}*/

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"fsbackup", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();

    //add this lines for prevent  multiple instances of application 
   // Upon app closing:
   /*
   ReleaseMutex( hMutexHandle ); // Explicitly release mutex
   CloseHandle( hMutexHandle ); // close handle before terminating
   */

  return EXIT_SUCCESS;
}
