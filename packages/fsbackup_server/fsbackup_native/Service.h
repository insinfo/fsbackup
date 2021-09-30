#pragma once

#ifdef WINSERVICE_EXPORTS
#define WINSERVICE_API __declspec(dllexport)
#else
#define WINSERVICE_API __declspec(dllimport)
#endif


WINSERVICE_API int init(const char* service_name);