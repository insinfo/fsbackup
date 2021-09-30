
// Provides an API for Dart console applications to
// integrate themselves as Windows Services
// The entry point to this API is the Init(...)
// function at the bottom of this file.

// The Init(...) function registers the ServiceMain(...)
// function as the actual windows service function.
// the ServiceMain function does the following:
//
// 1. Registers the ServiceCtrlHandler(...) function 
// as the service control handler, which is essentially
// tasked to handle control requests (in this case we 
// are only handling the request to stop the service).
//
// 2. Creates an event object that and then waits indefinitely 
// for the event to be set.
//
// The ServiceCtrlHandler(...) function responds to a
// close request by setting the event created by the 
// ServiceMain(...) function, essentially freeing 
// the latter from the indefinite wait and terminating
// it.

// The functions in this file don't actually 
// do any work, but keep the Windows Service
// alive. The work be initiated by the calling 
// application either before or after the call to Init(...).

// Because this was developed for the purpose
// of enabling Dart applications to run as 
// Windows Services, it it the Dart Application 
// that needs to call Init(...) using Dart FFI.
// It must also be the Dart Application to 
// spawn an isolate that does the actual work
// before the call to Init(...)

#include <Windows.h>
#include <tchar.h>

#include "service.h"


SERVICE_STATUS        g_ServiceStatus = { 0 };
SERVICE_STATUS_HANDLE g_StatusHandle = NULL;
HANDLE                g_ServiceStopEvent = INVALID_HANDLE_VALUE;


LPWSTR w_service_name;


void UpdateStatus(
    DWORD newState,
    DWORD checkPoint,
    DWORD exitCode,
    DWORD controlsAccepted)
{
    g_ServiceStatus.dwControlsAccepted = controlsAccepted;
    g_ServiceStatus.dwCurrentState = newState;
    g_ServiceStatus.dwWin32ExitCode = exitCode;
    g_ServiceStatus.dwCheckPoint = checkPoint;

    SetServiceStatus(g_StatusHandle, &g_ServiceStatus);
}


// Responds to control events. This implementation is
// only responding to the SERVICE_CONTROL_STOP event
// This method signals the ServiceMain function
// that it can stop waiting before terminating.
void WINAPI ServiceCtrlHandler(DWORD CtrlCode)
{
    if (CtrlCode != SERVICE_CONTROL_STOP || g_ServiceStatus.dwCurrentState != SERVICE_RUNNING)
        return;

    UpdateStatus(SERVICE_STOP_PENDING, 4, 0, 0);

    SetEvent(g_ServiceStopEvent);

}


void InitServiceStatus()
{
    ZeroMemory(&g_ServiceStatus, sizeof(g_ServiceStatus));
    g_ServiceStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    g_ServiceStatus.dwServiceSpecificExitCode = 0;
    UpdateStatus(SERVICE_START_PENDING, 0, 0, 0);
}


// This function essentially creates an event object 
// and enters a holding pattern until that event object 
// is set by the ServiceCtrlHandler(...) in response
// to a close request.

// The function doesn't actually do any work,
// except to keep the Windows Service alive.
void WINAPI ServiceMain(DWORD argc, LPTSTR* argv)
{
    g_StatusHandle = RegisterServiceCtrlHandler(w_service_name, ServiceCtrlHandler);

    if (g_StatusHandle == NULL)
        return;

    InitServiceStatus();

    g_ServiceStopEvent = CreateEvent(NULL, TRUE, FALSE, NULL);

    if (g_ServiceStopEvent == NULL)
    {
        UpdateStatus(SERVICE_STOPPED, 1, GetLastError(), 0);
        return;
    }

    UpdateStatus(SERVICE_RUNNING, 0, 0, SERVICE_ACCEPT_STOP);

    while (WaitForSingleObject(g_ServiceStopEvent, INFINITE) != WAIT_OBJECT_0)
        ;

    CloseHandle(g_ServiceStopEvent);
    UpdateStatus(SERVICE_STOPPED, 3, 0, 0);
}



LPWSTR get_service_name(const char* service_name)
{
    int max_count = strlen(service_name);
    int size = max_count + 1;
    LPWSTR ret = malloc(sizeof(wchar_t) * size);
    size_t outSize;
    mbstowcs_s(&outSize, ret, size, service_name, max_count);
    return ret;
}



/// This is the entry point that should be called
/// by the Dart application (or any application 
/// of a similar kind of platform) in order to 
/// integrate itself as a Windows Service.
/// It registers the ServiceMain(...) function
/// as the service main function. Please consult
/// the comments at that function to understand
/// what it does.
int init(const char* service_name)
{
    w_service_name = get_service_name(service_name);

    SERVICE_TABLE_ENTRY ServiceTable[] =
    {
        {w_service_name, (LPSERVICE_MAIN_FUNCTION)ServiceMain},
        {NULL, NULL}
    };

    if (StartServiceCtrlDispatcher(ServiceTable) == FALSE)
        return GetLastError();
}