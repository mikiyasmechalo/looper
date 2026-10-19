#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <shobjidl.h>

#include <wrl/client.h>
#include <string>

#include "flutter_window.h"
#include "utils.h"

static void EnsureStartMenuShortcut() {
  wchar_t exe_path[MAX_PATH];
  if (!::GetModuleFileNameW(nullptr, exe_path, MAX_PATH)) return;

  wchar_t app_data[MAX_PATH];
  if (!::GetEnvironmentVariableW(L"APPDATA", app_data, MAX_PATH)) return;

  std::wstring shortcut_path = std::wstring(app_data) + L"\\Microsoft\\Windows\\Start Menu\\Programs\\Looper Player.lnk";

  Microsoft::WRL::ComPtr<IShellLinkW> shell_link;
  if (FAILED(::CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&shell_link)))) {
    return;
  }

  shell_link->SetPath(exe_path);
  std::wstring dir = exe_path;
  size_t last_slash = dir.find_last_of(L"\\/");
  if (last_slash != std::wstring::npos) {
    dir = dir.substr(0, last_slash);
    shell_link->SetWorkingDirectory(dir.c_str());
  }
  shell_link->SetIconLocation(exe_path, 0);

  Microsoft::WRL::ComPtr<IPropertyStore> prop_store;
  if (SUCCEEDED(shell_link.As(&prop_store))) {
    PROPVARIANT pv;
    ::PropVariantInit(&pv);
    pv.vt = VT_LPWSTR;
    pv.pwszVal = const_cast<wchar_t*>(L"Looper Player");
    PROPERTYKEY key;
    key.fmtid = {0x9F4C2855, 0x9F79, 0x4B39, {0xA8, 0xD0, 0xE1, 0xD4, 0x2D, 0xE1, 0xD5, 0xF3}};
    key.pid = 5;
    prop_store->SetValue(key, pv);
    prop_store->Commit();
  }

  Microsoft::WRL::ComPtr<IPersistFile> persist_file;
  if (SUCCEEDED(shell_link.As(&persist_file))) {
    persist_file->Save(shortcut_path.c_str(), TRUE);
  }
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new one when we're not running in a release build.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Set explicit AppUserModelID to match Start Menu shortcut and prevent "Unknown app" in Action Center
  ::SetCurrentProcessExplicitAppUserModelID(L"Looper Player");

  // Initialize COM for the Windows runner.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // Synchronize Start Menu shortcut with the current running binary and AUMID
  EnsureStartMenuShortcut();

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"Looper", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
