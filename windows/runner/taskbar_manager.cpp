#include "taskbar_manager.h"
#include <vector>
#include <iostream>
#include <algorithm>

#define ID_THUMB_PREV 101
#define ID_THUMB_PLAY_PAUSE 102
#define ID_THUMB_NEXT 103

#ifndef THBN_CLICKED
#define THBN_CLICKED 0x1800
#endif

static std::wstring Utf8ToWide(const std::string& str) {
  if (str.empty()) return L"";
  int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
  std::wstring wstr(size_needed, 0);
  MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstr[0], size_needed);
  return wstr;
}

UINT TaskbarManager::GetTaskbarCreatedMessage() {
  static UINT msg = RegisterWindowMessageW(L"TaskbarButtonCreated");
  return msg;
}

TaskbarManager& TaskbarManager::GetInstance() {
  static TaskbarManager instance;
  return instance;
}

TaskbarManager::TaskbarManager() {}

TaskbarManager::~TaskbarManager() {
  Shutdown();
}

void TaskbarManager::EnsureTaskbarList() {
  if (taskbar_list_) return;

  HRESULT hr = CoCreateInstance(
      CLSID_TaskbarList, NULL, CLSCTX_INPROC_SERVER,
      IID_ITaskbarList3, reinterpret_cast<void**>(&taskbar_list_));

  if (SUCCEEDED(hr) && taskbar_list_) {
    taskbar_list_->HrInit();
  }
}

void TaskbarManager::Initialize(HWND hwnd, flutter::BinaryMessenger* messenger) {
  if (!hwnd) return;
  hwnd_ = hwnd;

  // Enable DWM custom iconic thumbnail representation for taskbar hover
  BOOL enable = TRUE;
  DwmSetWindowAttribute(hwnd_, DWMWA_FORCE_ICONIC_REPRESENTATION, &enable, sizeof(enable));
  // Keep DWMWA_HAS_ICONIC_BITMAP false so Alt-Tab and Aero Peek use native live window preview instead of a black/static box
  BOOL disable_iconic_bitmap = FALSE;
  DwmSetWindowAttribute(hwnd_, DWMWA_HAS_ICONIC_BITMAP, &disable_iconic_bitmap, sizeof(disable_iconic_bitmap));

  // Create thumb button icons once
  if (!icon_prev_) {
    icon_prev_ = CreateIconFromShape(0, 20);
    icon_play_ = CreateIconFromShape(1, 20);
    icon_pause_ = CreateIconFromShape(2, 20);
    icon_next_ = CreateIconFromShape(3, 20);
  }

  EnsureTaskbarList();
  CreateThumbButtons();
  SetupMethodChannel(messenger);
  initialized_ = true;
}

void TaskbarManager::Shutdown() {
  if (icon_prev_) { DestroyIcon(icon_prev_); icon_prev_ = nullptr; }
  if (icon_play_) { DestroyIcon(icon_play_); icon_play_ = nullptr; }
  if (icon_pause_) { DestroyIcon(icon_pause_); icon_pause_ = nullptr; }
  if (icon_next_) { DestroyIcon(icon_next_); icon_next_ = nullptr; }

  if (taskbar_list_) {
    taskbar_list_->Release();
    taskbar_list_ = nullptr;
  }
  buttons_added_ = false;
  initialized_ = false;
}

void TaskbarManager::OnTaskbarButtonCreated() {
  buttons_added_ = false;
  EnsureTaskbarList();
  CreateThumbButtons();

  // Re-apply DWM attributes
  BOOL enable = TRUE;
  DwmSetWindowAttribute(hwnd_, DWMWA_FORCE_ICONIC_REPRESENTATION, &enable, sizeof(enable));
  BOOL disable_iconic_bitmap = FALSE;
  DwmSetWindowAttribute(hwnd_, DWMWA_HAS_ICONIC_BITMAP, &disable_iconic_bitmap, sizeof(disable_iconic_bitmap));
  DwmInvalidateIconicBitmaps(hwnd_);
}

void TaskbarManager::SetupMethodChannel(flutter::BinaryMessenger* messenger) {
  if (!messenger) return;

  channel_ = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "com.looper.player/taskbar",
      &flutter::StandardMethodCodec::GetInstance());

  channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "updateTaskbarControls") {
          const auto* args = std::get_if<flutter::EncodableMap>(call.arguments());
          if (args) {
            bool is_playing = false;
            bool can_prev = true;
            bool can_next = true;

            auto it_playing = args->find(flutter::EncodableValue("isPlaying"));
            if (it_playing != args->end()) {
              if (const bool* val = std::get_if<bool>(&it_playing->second)) {
                is_playing = *val;
              }
            }

            auto it_prev = args->find(flutter::EncodableValue("canSkipPrev"));
            if (it_prev != args->end()) {
              if (const bool* val = std::get_if<bool>(&it_prev->second)) {
                can_prev = *val;
              }
            }

            auto it_next = args->find(flutter::EncodableValue("canSkipNext"));
            if (it_next != args->end()) {
              if (const bool* val = std::get_if<bool>(&it_next->second)) {
                can_next = *val;
              }
            }

            // Extract metadata for the custom thumbnail
            auto it_title = args->find(flutter::EncodableValue("title"));
            if (it_title != args->end()) {
              if (const std::string* val = std::get_if<std::string>(&it_title->second)) {
                current_title_ = Utf8ToWide(*val);
              }
            }

            auto it_artist = args->find(flutter::EncodableValue("artist"));
            if (it_artist != args->end()) {
              if (const std::string* val = std::get_if<std::string>(&it_artist->second)) {
                current_artist_ = Utf8ToWide(*val);
              }
            }

            auto it_album = args->find(flutter::EncodableValue("album"));
            if (it_album != args->end()) {
              if (const std::string* val = std::get_if<std::string>(&it_album->second)) {
                current_album_ = Utf8ToWide(*val);
              }
            }

            auto it_time = args->find(flutter::EncodableValue("timeText"));
            if (it_time != args->end()) {
              if (const std::string* val = std::get_if<std::string>(&it_time->second)) {
                current_time_text_ = Utf8ToWide(*val);
              }
            }

            auto it_prog = args->find(flutter::EncodableValue("progress"));
            if (it_prog != args->end()) {
              if (const double* val = std::get_if<double>(&it_prog->second)) {
                progress_ = *val;
              }
            }

            auto it_accent = args->find(flutter::EncodableValue("accentColor"));
            if (it_accent != args->end()) {
              if (const int64_t* val = std::get_if<int64_t>(&it_accent->second)) {
                accent_color_ = (uint32_t)*val;
              }
            }

            auto it_art = args->find(flutter::EncodableValue("artBytes"));
            if (it_art != args->end()) {
              if (const std::vector<uint8_t>* val = std::get_if<std::vector<uint8_t>>(&it_art->second)) {
                art_rgba_ = *val;
              } else {
                art_rgba_.clear();
              }
            }

            auto it_art_w = args->find(flutter::EncodableValue("artWidth"));
            if (it_art_w != args->end()) {
              if (const int32_t* val = std::get_if<int32_t>(&it_art_w->second)) {
                art_width_ = *val;
              }
            }

            auto it_art_h = args->find(flutter::EncodableValue("artHeight"));
            if (it_art_h != args->end()) {
              if (const int32_t* val = std::get_if<int32_t>(&it_art_h->second)) {
                art_height_ = *val;
              }
            }

            this->UpdateButtons(is_playing, can_prev, can_next);

            // Invalidate DWM thumbnail to redraw immediately
            if (hwnd_) {
              DwmInvalidateIconicBitmaps(hwnd_);
            }
          }
          result->Success(flutter::EncodableValue(true));
        } else {
          result->NotImplemented();
        }
      });
}

void TaskbarManager::CreateThumbButtons() {
  if (!taskbar_list_ || !hwnd_) return;

  THUMBBUTTON buttons[3] = {};

  // Button 1: Previous
  buttons[0].dwMask = THB_ICON | THB_TOOLTIP | THB_FLAGS;
  buttons[0].iId = ID_THUMB_PREV;
  buttons[0].hIcon = icon_prev_;
  wcscpy_s(buttons[0].szTip, L"Previous Track");
  buttons[0].dwFlags = can_prev_ ? THBF_ENABLED : THBF_DISABLED;

  // Button 2: Play/Pause
  buttons[1].dwMask = THB_ICON | THB_TOOLTIP | THB_FLAGS;
  buttons[1].iId = ID_THUMB_PLAY_PAUSE;
  buttons[1].hIcon = is_playing_ ? icon_pause_ : icon_play_;
  wcscpy_s(buttons[1].szTip, is_playing_ ? L"Pause" : L"Play");
  buttons[1].dwFlags = THBF_ENABLED;

  // Button 3: Next
  buttons[2].dwMask = THB_ICON | THB_TOOLTIP | THB_FLAGS;
  buttons[2].iId = ID_THUMB_NEXT;
  buttons[2].hIcon = icon_next_;
  wcscpy_s(buttons[2].szTip, L"Next Track");
  buttons[2].dwFlags = can_next_ ? THBF_ENABLED : THBF_DISABLED;

  HRESULT hr = taskbar_list_->ThumbBarAddButtons(hwnd_, 3, buttons);
  if (SUCCEEDED(hr)) {
    buttons_added_ = true;
  }
}

void TaskbarManager::UpdateButtons(bool is_playing, bool can_skip_prev, bool can_skip_next) {
  is_playing_ = is_playing;
  can_prev_ = can_skip_prev;
  can_next_ = can_skip_next;

  if (!taskbar_list_ || !hwnd_) return;

  if (!buttons_added_) {
    CreateThumbButtons();
    return;
  }

  THUMBBUTTON buttons[3] = {};

  // Button 1: Previous
  buttons[0].dwMask = THB_ICON | THB_TOOLTIP | THB_FLAGS;
  buttons[0].iId = ID_THUMB_PREV;
  buttons[0].hIcon = icon_prev_;
  wcscpy_s(buttons[0].szTip, L"Previous Track");
  buttons[0].dwFlags = can_skip_prev ? THBF_ENABLED : THBF_DISABLED;

  // Button 2: Play/Pause
  buttons[1].dwMask = THB_ICON | THB_TOOLTIP | THB_FLAGS;
  buttons[1].iId = ID_THUMB_PLAY_PAUSE;
  buttons[1].hIcon = is_playing_ ? icon_pause_ : icon_play_;
  wcscpy_s(buttons[1].szTip, is_playing_ ? L"Pause" : L"Play");
  buttons[1].dwFlags = THBF_ENABLED;

  // Button 3: Next
  buttons[2].dwMask = THB_ICON | THB_TOOLTIP | THB_FLAGS;
  buttons[2].iId = ID_THUMB_NEXT;
  buttons[2].hIcon = icon_next_;
  wcscpy_s(buttons[2].szTip, L"Next Track");
  buttons[2].dwFlags = can_skip_next ? THBF_ENABLED : THBF_DISABLED;

  taskbar_list_->ThumbBarUpdateButtons(hwnd_, 3, buttons);
}

bool TaskbarManager::HandleCommand(WPARAM wparam, LPARAM lparam) {
  int wm_id = LOWORD(wparam);
  int wm_event = HIWORD(wparam);

  if (wm_event == THBN_CLICKED) {
    if (!channel_) return true;

    if (wm_id == ID_THUMB_PREV) {
      channel_->InvokeMethod("onPrevious", nullptr);
      return true;
    } else if (wm_id == ID_THUMB_PLAY_PAUSE) {
      channel_->InvokeMethod("onPlayPause", nullptr);
      return true;
    } else if (wm_id == ID_THUMB_NEXT) {
      channel_->InvokeMethod("onNext", nullptr);
      return true;
    }
  }
  return false;
}

void TaskbarManager::HandleSendIconicThumbnail(int max_w, int max_h) {
  int target_w = (max_w > 0) ? (std::min)(max_w, 280) : 280;
  int target_h = (max_h > 0) ? (std::min)(max_h, 110) : 110;

  HBITMAP hBmp = CreateThumbnailBitmap(target_w, target_h);
  if (hBmp && hwnd_) {
    DwmSetIconicThumbnail(hwnd_, hBmp, 0);
    DeleteObject(hBmp);
  }
}

void TaskbarManager::HandleSendIconicLivePreview(int max_w, int max_h) {
  int target_h = (max_h > 0) ? (std::min)(max_h, 330) : 220;
  int target_w = (int)(target_h * (280.0 / 110.0));
  if (max_w > 0 && target_w > max_w) {
    target_w = max_w;
    target_h = (int)(target_w * (110.0 / 280.0));
  }
  if (target_w < 280) target_w = 280;
  if (target_h < 110) target_h = 110;

  HBITMAP hBmp = CreateThumbnailBitmap(target_w, target_h);
  if (hBmp && hwnd_) {
    DwmSetIconicLivePreviewBitmap(hwnd_, hBmp, nullptr, 0);
    DeleteObject(hBmp);
  }
}

HBITMAP TaskbarManager::CreateThumbnailBitmap(int target_w, int target_h) {
  BITMAPINFO bmi = {};
  bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
  bmi.bmiHeader.biWidth = target_w;
  bmi.bmiHeader.biHeight = -target_h; // Top-down DIB
  bmi.bmiHeader.biPlanes = 1;
  bmi.bmiHeader.biBitCount = 32;
  bmi.bmiHeader.biCompression = BI_RGB;

  HDC hdc = GetDC(NULL);
  HDC memDC = CreateCompatibleDC(hdc);
  uint32_t* pixels = nullptr;
  HBITMAP hBitmap = CreateDIBSection(memDC, &bmi, DIB_RGB_COLORS, (void**)&pixels, NULL, 0);
  HBITMAP hOldBmp = (HBITMAP)SelectObject(memDC, hBitmap);

  // Fill background: dark slate matching Corner Mini Player #141416
  const uint32_t bg_color = 0xFF141416;
  const uint32_t border_color = 0xFF2A2A32;
  const uint32_t art_bg = 0xFF202026;

  for (int i = 0; i < target_w * target_h; ++i) {
    pixels[i] = bg_color;
  }

  // Draw card border
  for (int x = 0; x < target_w; ++x) {
    pixels[x] = border_color;
    pixels[(target_h - 1) * target_w + x] = border_color;
  }
  for (int y = 0; y < target_h; ++y) {
    pixels[y * target_w] = border_color;
    pixels[y * target_w + (target_w - 1)] = border_color;
  }

  float scale = (float)target_h / 110.0f;
  if (scale < 1.0f) scale = 1.0f;

  // Artwork dimensions
  int art_pad = (int)(12 * scale);
  int art_size = target_h - (art_pad * 2);
  int art_x = art_pad;
  int art_y = art_pad;

  if (!art_rgba_.empty() && art_width_ > 0 && art_height_ > 0) {
    // Scale art_rgba_ (RGBA) to art_size x art_size in target bitmap
    for (int y = 0; y < art_size; ++y) {
      int src_y = (y * art_height_) / art_size;
      for (int x = 0; x < art_size; ++x) {
        int src_x = (x * art_width_) / art_size;
        int src_idx = (src_y * art_width_ + src_x) * 4;
        uint8_t r = art_rgba_[src_idx];
        uint8_t g = art_rgba_[src_idx + 1];
        uint8_t b = art_rgba_[src_idx + 2];
        uint8_t a = art_rgba_[src_idx + 3];

        uint32_t argb = (a << 24) | (r << 16) | (g << 8) | b;
        pixels[(art_y + y) * target_w + (art_x + x)] = argb;
      }
    }
  } else {
    // Draw default stylized vinyl / art square
    for (int y = 0; y < art_size; ++y) {
      for (int x = 0; x < art_size; ++x) {
        pixels[(art_y + y) * target_w + (art_x + x)] = art_bg;
      }
    }
    // Subtle inner vinyl circle
    int cx = art_x + art_size / 2;
    int cy = art_y + art_size / 2;
    int r = art_size / 3;
    for (int y = cy - r; y <= cy + r; ++y) {
      for (int x = cx - r; x <= cx + r; ++x) {
        int dx = x - cx;
        int dy = y - cy;
        if (dx * dx + dy * dy <= r * r) {
          pixels[y * target_w + x] = 0xFF2D2D38;
        }
      }
    }
  }

  // Draw typography & progress bar using GDI
  SetBkMode(memDC, TRANSPARENT);

  int text_x = art_x + art_size + (int)(14 * scale);
  int text_w = target_w - text_x - (int)(14 * scale);

  HFONT hTitleFont = CreateFontW(
      (int)(15 * scale), 0, 0, 0, FW_BOLD, FALSE, FALSE, FALSE,
      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
      CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

  HFONT hArtistFont = CreateFontW(
      (int)(12 * scale), 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
      CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

  HFONT hAlbumFont = CreateFontW(
      (int)(11 * scale), 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
      CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

  HFONT hTimeFont = CreateFontW(
      (int)(11 * scale), 0, 0, 0, FW_SEMIBOLD, FALSE, FALSE, FALSE,
      DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
      CLEARTYPE_QUALITY, DEFAULT_PITCH | FF_DONTCARE, L"Segoe UI");

  // Title
  HFONT hOldFont = (HFONT)SelectObject(memDC, hTitleFont);
  SetTextColor(memDC, RGB(255, 255, 255));
  RECT rcTitle = { text_x, (int)(10 * scale), text_x + text_w, (int)(28 * scale) };
  DrawTextW(memDC, current_title_.c_str(), -1, &rcTitle,
            DT_LEFT | DT_VCENTER | DT_END_ELLIPSIS | DT_SINGLELINE | DT_NOPREFIX);

  // Artist
  SelectObject(memDC, hArtistFont);
  SetTextColor(memDC, RGB(180, 180, 185));
  RECT rcArtist = { text_x, (int)(28 * scale), text_x + text_w, (int)(44 * scale) };
  DrawTextW(memDC, current_artist_.c_str(), -1, &rcArtist,
            DT_LEFT | DT_VCENTER | DT_END_ELLIPSIS | DT_SINGLELINE | DT_NOPREFIX);

  int pb_y = (int)(62 * scale);
  int time_y = (int)(70 * scale);

  // Album (if present)
  if (!current_album_.empty()) {
    SelectObject(memDC, hAlbumFont);
    SetTextColor(memDC, RGB(130, 130, 140));
    RECT rcAlbum = { text_x, (int)(44 * scale), text_x + text_w, (int)(58 * scale) };
    DrawTextW(memDC, current_album_.c_str(), -1, &rcAlbum,
              DT_LEFT | DT_VCENTER | DT_END_ELLIPSIS | DT_SINGLELINE | DT_NOPREFIX);
    pb_y = (int)(66 * scale);
    time_y = (int)(74 * scale);
  }

  // Progress Bar Track
  int pb_h = (std::max)(2, (int)(3 * scale));
  int pb_w = text_w;
  uint32_t pb_track_color = 0xFF2E2E38;
  uint8_t acc_r = (accent_color_ >> 16) & 0xFF;
  uint8_t acc_g = (accent_color_ >> 8) & 0xFF;
  uint8_t acc_b = accent_color_ & 0xFF;
  uint32_t pb_fill_color = 0xFF000000 | (acc_r << 16) | (acc_g << 8) | acc_b;

  int fill_w = (int)(pb_w * std::clamp(progress_, 0.0, 1.0));

  for (int y = pb_y; y < pb_y + pb_h; ++y) {
    for (int x = 0; x < pb_w; ++x) {
      if (x < fill_w) {
        pixels[y * target_w + (text_x + x)] = pb_fill_color;
      } else {
        pixels[y * target_w + (text_x + x)] = pb_track_color;
      }
    }
  }

  // Duration / Time Text
  SelectObject(memDC, hTimeFont);
  SetTextColor(memDC, RGB(140, 140, 150));
  RECT rcTime = { text_x, time_y, text_x + text_w, time_y + (int)(16 * scale) };
  DrawTextW(memDC, current_time_text_.c_str(), -1, &rcTime,
            DT_LEFT | DT_VCENTER | DT_END_ELLIPSIS | DT_SINGLELINE | DT_NOPREFIX);

  SelectObject(memDC, hOldFont);
  DeleteObject(hTitleFont);
  DeleteObject(hArtistFont);
  DeleteObject(hAlbumFont);
  DeleteObject(hTimeFont);

  SelectObject(memDC, hOldBmp);
  DeleteDC(memDC);
  ReleaseDC(NULL, hdc);

  return hBitmap;
}

HICON TaskbarManager::CreateIconFromShape(int shape_type, int size) {
  BITMAPINFO bmi = {};
  bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
  bmi.bmiHeader.biWidth = size;
  bmi.bmiHeader.biHeight = -size; // Top-down DIB
  bmi.bmiHeader.biPlanes = 1;
  bmi.bmiHeader.biBitCount = 32;
  bmi.bmiHeader.biCompression = BI_RGB;

  HDC hdc = GetDC(NULL);
  HDC memDC = CreateCompatibleDC(hdc);
  uint32_t* pixels = nullptr;
  HBITMAP hBitmap = CreateDIBSection(memDC, &bmi, DIB_RGB_COLORS, (void**)&pixels, NULL, 0);
  HBITMAP hOldBmp = (HBITMAP)SelectObject(memDC, hBitmap);

  // Clear 32-bit ARGB buffer to fully transparent black (0x00000000)
  memset(pixels, 0, size * size * sizeof(uint32_t));

  const uint32_t fg_color = 0xFFFFFFFF; // 100% white, full alpha

  // 1-bit monochrome mask (1 = transparent, 0 = opaque)
  int mask_stride = ((size + 31) / 32) * 4;
  std::vector<BYTE> mask_bytes(mask_stride * size, 0xFF);

  auto set_pixel = [&](int x, int y) {
    if (x >= 0 && x < size && y >= 0 && y < size) {
      pixels[y * size + x] = fg_color;
      // Mark mask bit as 0 (opaque)
      mask_bytes[y * mask_stride + (x / 8)] &= ~(1 << (7 - (x % 8)));
    }
  };

  int mid_y = size / 2;
  int pad = size / 5;

  if (shape_type == 0) { // Previous (|◀)
    // Left vertical bar
    for (int y = pad; y <= size - pad; ++y) {
      set_pixel(pad, y);
      set_pixel(pad + 1, y);
    }
    // Left-pointing triangle
    int tri_left = pad + 3;
    int tri_right = size - pad;
    int tri_width = tri_right - tri_left;
    if (tri_width > 0) {
      for (int x = tri_left; x <= tri_right; ++x) {
        float progress = (float)(x - tri_left) / (float)tri_width;
        int half_h = (int)(progress * (size / 2 - pad));
        for (int y = mid_y - half_h; y <= mid_y + half_h; ++y) {
          set_pixel(x, y);
        }
      }
    }
  } else if (shape_type == 1) { // Play (▶)
    int tri_left = pad + 1;
    int tri_right = size - pad;
    int tri_width = tri_right - tri_left;
    if (tri_width > 0) {
      for (int x = tri_left; x <= tri_right; ++x) {
        float progress = (float)(tri_right - x) / (float)tri_width;
        int half_h = (int)(progress * (size / 2 - pad));
        for (int y = mid_y - half_h; y <= mid_y + half_h; ++y) {
          set_pixel(x, y);
        }
      }
    }
  } else if (shape_type == 2) { // Pause (❚❚)
    int bar_w = size / 6;
    if (bar_w < 2) bar_w = 2;
    int bar1_x = pad + 1;
    int bar2_x = size - pad - bar_w - 1;
    for (int y = pad; y <= size - pad; ++y) {
      for (int x = 0; x < bar_w; ++x) {
        set_pixel(bar1_x + x, y);
        set_pixel(bar2_x + x, y);
      }
    }
  } else if (shape_type == 3) { // Next (▶|)
    // Right-pointing triangle
    int tri_left = pad;
    int tri_right = size - pad - 3;
    int tri_width = tri_right - tri_left;
    if (tri_width > 0) {
      for (int x = tri_left; x <= tri_right; ++x) {
        float progress = (float)(tri_right - x) / (float)tri_width;
        int half_h = (int)(progress * (size / 2 - pad));
        for (int y = mid_y - half_h; y <= mid_y + half_h; ++y) {
          set_pixel(x, y);
        }
      }
    }
    // Right vertical bar
    int bar_x = size - pad - 1;
    for (int y = pad; y <= size - pad; ++y) {
      set_pixel(bar_x - 1, y);
      set_pixel(bar_x, y);
    }
  }

  HBITMAP hMonoBmp = CreateBitmap(size, size, 1, 1, mask_bytes.data());

  ICONINFO ii = {};
  ii.fIcon = TRUE;
  ii.xHotspot = 0;
  ii.yHotspot = 0;
  ii.hbmMask = hMonoBmp;
  ii.hbmColor = hBitmap;

  HICON hIcon = CreateIconIndirect(&ii);

  SelectObject(memDC, hOldBmp);
  DeleteObject(hBitmap);
  DeleteObject(hMonoBmp);
  DeleteDC(memDC);
  ReleaseDC(NULL, hdc);

  return hIcon;
}
