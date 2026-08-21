#ifndef RUNNER_TASKBAR_MANAGER_H_
#define RUNNER_TASKBAR_MANAGER_H_

#include <windows.h>
#include <dwmapi.h>
#include <shobjidl.h>
#include <flutter/binary_messenger.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <memory>
#include <string>
#include <vector>

#ifndef WM_DWMSENDICONICTHUMBNAIL
#define WM_DWMSENDICONICTHUMBNAIL 0x0323
#endif

#ifndef WM_DWMSENDICONICLIVEPREVIEWBITMAP
#define WM_DWMSENDICONICLIVEPREVIEWBITMAP 0x0326
#endif

#ifndef DWMWA_FORCE_ICONIC_REPRESENTATION
#define DWMWA_FORCE_ICONIC_REPRESENTATION 7
#endif

#ifndef DWMWA_HAS_ICONIC_BITMAP
#define DWMWA_HAS_ICONIC_BITMAP 10
#endif

class TaskbarManager {
 public:
  static TaskbarManager& GetInstance();
  static UINT GetTaskbarCreatedMessage();

  void Initialize(HWND hwnd, flutter::BinaryMessenger* messenger);
  void Shutdown();

  void OnTaskbarButtonCreated();
  bool HandleCommand(WPARAM wparam, LPARAM lparam);
  void HandleSendIconicThumbnail(int max_w, int max_h);
  void HandleSendIconicLivePreview(int max_w, int max_h);

 private:
  TaskbarManager();
  ~TaskbarManager();

  void EnsureTaskbarList();
  void SetupMethodChannel(flutter::BinaryMessenger* messenger);
  void CreateThumbButtons();
  void UpdateButtons(bool is_playing, bool can_skip_prev, bool can_skip_next);

  HBITMAP CreateThumbnailBitmap(int target_w, int target_h);
  HICON CreateIconFromShape(int shape_type, int size = 20);

  HWND hwnd_ = nullptr;
  ITaskbarList3* taskbar_list_ = nullptr;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;

  HICON icon_prev_ = nullptr;
  HICON icon_play_ = nullptr;
  HICON icon_pause_ = nullptr;
  HICON icon_next_ = nullptr;

  bool initialized_ = false;
  bool buttons_added_ = false;
  bool is_playing_ = false;
  bool can_prev_ = true;
  bool can_next_ = true;

  // Metadata for custom iconic thumbnail (Corner Mini Player style)
  std::wstring current_title_ = L"No Track Playing";
  std::wstring current_artist_ = L"Looper Player";
  std::wstring current_album_ = L"";
  std::wstring current_time_text_ = L"0:00 / 0:00";
  double progress_ = 0.0;
  uint32_t accent_color_ = 0xFF55DF69;
  std::vector<uint8_t> art_rgba_;
  int art_width_ = 0;
  int art_height_ = 0;
};

#endif  // RUNNER_TASKBAR_MANAGER_H_
